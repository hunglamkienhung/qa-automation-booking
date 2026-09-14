"""HTTP client for the mini-stay service. Mirror of node/be/api/venues/stay.js.
urllib only. A transport failure is ApiUnreachable (grades Blocked); a 4xx/5xx is
an answer, often the one under test. The convenience methods drive the flows end
to end -- price a stay, hold a room, confirm and run it to checked_out -- so a step
can set up whatever lifecycle state it needs. ``future_range`` builds a UTC-midnight
night range far enough out that a cancellation is always "in advance"; scenarios
that must not collide over inventory pass distinct offsets.
"""

from __future__ import annotations

import json
import os
import time
import urllib.error
import urllib.request

BASE = os.environ.get("MINI_STAY_URL", "http://127.0.0.1:8150").rstrip("/")
ADMIN_TOKEN = os.environ.get("MINI_STAY_ADMIN_TOKEN", "admin-token")
SEED_GUEST = "gst_seed_aria"
SEED_GUEST2 = "gst_seed_bruno"
SEED_HOTELIER = "htl_seed_priya"
DAY = 86400


class ApiUnreachable(Exception):
    pass


def future_range(offset_days, nights=2):
    """A night range starting ``offset_days`` from today (UTC midnight), ``nights`` long."""
    midnight = int(time.time() // DAY) * DAY
    check_in = midnight + offset_days * DAY
    return {"check_in": check_in, "check_out": check_in + nights * DAY}


class MiniStay:
    def __init__(self, base: str = BASE) -> None:
        self.base = base
        self.admin_token = ADMIN_TOKEN
        self.seed_guest = SEED_GUEST
        self.seed_guest2 = SEED_GUEST2
        self.seed_hotelier = SEED_HOTELIER

    def request(self, method, path, token=None, body=None, headers=None):
        h = dict(headers or {})
        if token:
            h["Authorization"] = "Bearer " + token
        data = None
        if body is not None:
            h["Content-Type"] = "application/json"
            data = json.dumps(body).encode()
        req = urllib.request.Request(self.base + path, data=data, headers=h, method=method)
        try:
            with urllib.request.urlopen(req, timeout=15) as res:
                status, text = res.status, res.read().decode("utf-8", "replace")
                resp_headers = {k.lower(): v for k, v in res.headers.items()}
        except urllib.error.HTTPError as err:
            status, text = err.code, err.read().decode("utf-8", "replace")
            resp_headers = {k.lower(): v for k, v in (err.headers or {}).items()}
        except (urllib.error.URLError, TimeoutError, OSError) as err:
            raise ApiUnreachable(f"mini-stay at {self.base} did not answer {method} {path}: {err}") from err
        try:
            parsed = json.loads(text) if text else None
        except json.JSONDecodeError:
            parsed = None
        return {"status": status, "headers": resp_headers, "body": parsed, "text": text}

    def get(self, p, **kw):
        return self.request("GET", p, **kw)

    def post(self, p, body=None, **kw):
        return self.request("POST", p, body=body, **kw)

    def patch(self, p, body=None, **kw):
        return self.request("PATCH", p, body=body, **kw)

    def new_guest(self, name="Guest"):
        r = self.post("/guests", {"name": name})
        if r["status"] != 201:
            raise RuntimeError("create guest failed: HTTP " + str(r["status"]) + " " + r["text"])
        return r["body"]

    def new_hotelier(self, name="Hotelier"):
        r = self.post("/hoteliers", {"name": name})
        if r["status"] != 201:
            raise RuntimeError("create hotelier failed: HTTP " + str(r["status"]) + " " + r["text"])
        return r["body"]

    def quote(self, room_type_id=1, check_in=None, check_out=None):
        return self.post("/quotes", {"room_type_id": room_type_id, "check_in": check_in, "check_out": check_out})

    def hold(self, guest_token, opts):
        """Hold a room for a guest; returns the booking body (raises on a non-2xx)."""
        r = self.post("/bookings", opts, token=guest_token)
        if r["status"] not in (201, 200):
            raise RuntimeError("hold failed: HTTP " + str(r["status"]) + " " + r["text"])
        return r["body"]

    def book(self, guest_token, opts):
        """Hold and confirm; returns the confirmed booking body."""
        b = self.hold(guest_token, opts)
        r = self.post(f"/bookings/{b['id']}/confirm", None, token=guest_token)
        if r["status"] != 200:
            raise RuntimeError("confirm failed: HTTP " + str(r["status"]) + " " + r["text"])
        return r["body"]
