"""Locust load test for the mini-stay service.

This is the performance counterpart to the functional BDD suite: the same REST
API the search, hold, booking and admin flows use, driven under concurrency. The
user classes model the real traffic mix -- lots of searching and quoting, fewer
bookings, a slice of full front-desk stays, and admin reads -- and every request
validates its response so a wrong status counts as a failure, not just a slow
success. A sold-out response under load is a valid business answer, not a
failure.

Run it headless with a pass/fail gate (see perf/run.sh):

    locust -f perf/locustfile.py --headless -u 40 -r 10 -t 30s \
        --host http://127.0.0.1:8150

The `quitting` hook fails the run (non-zero exit) if the error ratio or the p95
latency crosses the thresholds below, so it can gate a pipeline.
"""

from __future__ import annotations

import os
import random
import time

from locust import HttpUser, between, events, task

MAX_FAIL_RATIO = float(os.environ.get("PERF_MAX_FAIL_RATIO", "0.01"))   # 1%
MAX_P95_MS = float(os.environ.get("PERF_MAX_P95_MS", "750"))

ADMIN_TOKEN = os.environ.get("MINI_STAY_ADMIN_TOKEN", "admin-token")
SEED_HOTELIER = "htl_seed_priya"
DAY = 86400
ROOMS = [1, 2, 4, 5]   # rooms with several in stock, to keep sold-out noise low


def _future_range():
    midnight = (int(time.time()) // DAY) * DAY
    check_in = midnight + random.randint(1, 3000) * DAY
    return {"check_in": check_in, "check_out": check_in + random.randint(1, 5) * DAY}


def _post(client, path, name, token=None, json=None, expect=(200, 201)):
    headers = {"authorization": "Bearer " + token} if token else {}
    with client.post(path, json=json, headers=headers, name=name, catch_response=True) as r:
        if r.status_code in expect:
            r.success()
        else:
            r.failure(f"{r.status_code} {r.text[:80]}")
        return r


def _get(client, path, name, token=None):
    headers = {"authorization": "Bearer " + token} if token else {}
    with client.get(path, headers=headers, name=name, catch_response=True) as r:
        if r.status_code == 200:
            r.success()
        else:
            r.failure(f"{r.status_code} {r.text[:80]}")
        return r


def _register_guest(client):
    g = _post(client, "/guests", "POST /guests", json={"name": "Load"}, expect=(201,))
    return g.json()["token"] if g.status_code == 201 else None


class Shopper(HttpUser):
    """Searching and quoting -- the read + pricing path."""

    weight = 5
    wait_time = between(0.1, 0.5)

    @task(3)
    def browse(self):
        _get(self.client, "/hotels", "GET /hotels")
        _get(self.client, "/hotels/1/rooms", "GET /hotels/[id]/rooms")

    @task(5)
    def quote(self):
        _post(self.client, "/quotes", "POST /quotes", json={"room_type_id": random.choice(ROOMS), **_future_range()}, expect=(200,))


class Booker(HttpUser):
    """Holds a room, confirms it, reads it back. A sold-out night is fine."""

    weight = 3
    wait_time = between(0.2, 0.8)

    @task
    def hold_and_confirm(self):
        token = _register_guest(self.client)
        if not token:
            return
        b = _post(self.client, "/bookings", "POST /bookings", token=token, json={"room_type_id": random.choice(ROOMS), **_future_range()}, expect=(201, 409))
        if b.status_code != 201:
            return   # sold out for those nights -- a valid answer
        bid = b.json()["id"]
        _post(self.client, f"/bookings/{bid}/confirm", "POST /bookings/[id]/confirm", token=token)
        _get(self.client, f"/bookings/{bid}", "GET /bookings/[id]", token=token)


class FrontDesk(HttpUser):
    """A full stay: hold, confirm, then the hotelier checks in and out."""

    weight = 2
    wait_time = between(0.3, 1.0)

    @task
    def full_stay(self):
        token = _register_guest(self.client)
        if not token:
            return
        b = _post(self.client, "/bookings", "POST /bookings", token=token, json={"room_type_id": random.choice(ROOMS), **_future_range()}, expect=(201, 409))
        if b.status_code != 201:
            return
        bid = b.json()["id"]
        if _post(self.client, f"/bookings/{bid}/confirm", "POST /bookings/[id]/confirm", token=token).status_code != 200:
            return
        _post(self.client, f"/bookings/{bid}/check-in", "POST /bookings/[id]/check-in", token=SEED_HOTELIER)
        _post(self.client, f"/bookings/{bid}/check-out", "POST /bookings/[id]/check-out", token=SEED_HOTELIER)


class Admin(HttpUser):
    """The operator dashboard polling its overview."""

    weight = 1
    wait_time = between(0.5, 1.5)

    @task
    def overview(self):
        _get(self.client, "/admin/overview", "GET /admin/overview", token=ADMIN_TOKEN)


@events.quitting.add_listener
def _gate(environment, **_kw):
    stats = environment.stats.total
    p95 = stats.get_response_time_percentile(0.95)
    fail_ratio = stats.fail_ratio
    print(f"\nperf gate: requests={stats.num_requests} fails={stats.num_failures} "
          f"fail_ratio={fail_ratio:.4f} p95={p95}ms rps={stats.total_rps:.1f}")
    reasons = []
    if stats.num_requests == 0:
        reasons.append("no requests were made")
    if fail_ratio > MAX_FAIL_RATIO:
        reasons.append(f"fail ratio {fail_ratio:.4f} > {MAX_FAIL_RATIO}")
    if p95 and p95 > MAX_P95_MS:
        reasons.append(f"p95 {p95}ms > {MAX_P95_MS}ms")
    if reasons:
        print("perf gate FAILED: " + "; ".join(reasons))
        environment.process_exit_code = 1
    else:
        print("perf gate PASSED")
        environment.process_exit_code = 0
