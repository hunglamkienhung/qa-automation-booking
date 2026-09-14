"""Steps for be-mini-stay-booking.feature. Mirror of node/be/api/steps/booking.steps.js
-- a plugin module. The cancellation refund is recomputed here from the room's policy
and how many whole days ahead the cancellation is -- the same integer arithmetic the
service uses -- so the assertion is an independent witness. The generic "refused with
code/status" steps live in pricing_steps.py.
"""

from __future__ import annotations

import json
import math
import time

from pytest_bdd import parsers, then, when

from be.api.venues.stay import DAY, ApiUnreachable, MiniStay, future_range

stay = MiniStay()


def round_bps(amount, bps):
    return (amount * bps + 5000) // 10000


def refund_bps(cancellation, days_before):
    if cancellation == "nonrefundable":
        return 0
    if cancellation == "flexible":
        return 10000 if days_before >= 1 else 0
    if days_before >= 7:
        return 10000
    if days_before >= 1:
        return 5000
    return 0


def act(qa, fn):
    if qa.source_error:
        return None
    try:
        return fn()
    except ApiUnreachable as err:
        qa.source_error = str(err)
        return None


def check(qa, description, fn):
    if qa.source_error:
        qa.unobservable(description, "the source could not be reached -- " + qa.source_error)
        return
    passed, detail = fn()
    qa.check(description, passed, detail)


def _now():
    return int(time.time())


def hold_action(qa, room, nights, offset, key, token):
    rng = future_range(offset, nights)
    body = {"room_type_id": room, **rng}
    if key:
        body["idempotency_key"] = key
    qa.last_hold_req = body

    def go():
        qa.api = stay.post("/bookings", body, token=token)
        if qa.api["status"] in (201, 200):
            qa.booking = qa.api["body"]
    act(qa, go)


# ---------------------------------------------------------------- Whens


@when(parsers.parse("the guest holds room {room:d} for {nights:d} nights {offset:d} days out"))
def guest_holds(qa, room, nights, offset):
    hold_action(qa, room, nights, offset, None, qa.guest["token"])


@when(parsers.parse('the guest holds room {room:d} for {nights:d} nights with key "{key}"'))
def guest_holds_key(qa, room, nights, key):
    hold_action(qa, room, nights, 210, key, qa.guest["token"])
    qa.first_hold = qa.api


@when(parsers.parse('the guest holds again with key "{key}"'))
def guest_holds_again(qa, key):
    def go():
        qa.api = stay.post("/bookings", {**qa.last_hold_req, "idempotency_key": key}, token=qa.guest["token"])
        if qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    act(qa, go)
    qa.second_hold = qa.api


@when(parsers.parse("an anonymous caller holds room {room:d} for {nights:d} nights"))
def anon_holds(qa, room, nights):
    hold_action(qa, room, nights, 210, None, None)


@when("the guest confirms the booking")
def guest_confirms(qa):
    def go():
        qa.api = stay.post(f"/bookings/{qa.booking['id']}/confirm", None, token=qa.guest["token"])
        if qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    act(qa, go)


@when("the guest cancels the booking")
def guest_cancels(qa):
    def go():
        qa.api = stay.post(f"/bookings/{qa.booking['id']}/cancel", None, token=qa.guest["token"])
        if qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    act(qa, go)


@when("the guest tries to check the booking in")
def guest_tries_check_in(qa):
    def go():
        qa.api = stay.post(f"/bookings/{qa.booking['id']}/check-in", None, token=qa.guest["token"])
    act(qa, go)


def _hotelier(qa, action):
    def go():
        qa.api = stay.post(f"/bookings/{qa.booking['id']}/{action}", None, token=stay.seed_hotelier)
        if qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    act(qa, go)


@when("the hotelier checks the booking in")
def hotelier_check_in(qa):
    _hotelier(qa, "check-in")


@when("the hotelier checks the booking out")
def hotelier_check_out(qa):
    _hotelier(qa, "check-out")


@when("the hotelier marks the booking a no-show")
def hotelier_no_show(qa):
    _hotelier(qa, "no-show")


@when("the guest reads the booking")
def guest_reads(qa):
    def go():
        qa.api = stay.get("/bookings/" + str(qa.booking["id"]), token=qa.guest["token"])
    act(qa, go)


@when("the guest lists their bookings")
def guest_lists(qa):
    def go():
        qa.api = stay.get("/bookings", token=qa.guest["token"])
    act(qa, go)


# ---------------------------------------------------------------- Thens


@then(parsers.parse("the booking response is {status:w}"))
def booking_response_is(qa, status):
    def ev():
        if qa.booking and qa.booking["status"] == status:
            return (True, qa.booking["status"])
        detail = qa.booking["status"] if qa.booking else (f"{qa.api['status']} {json.dumps(qa.api['body'])}" if qa.api else "no response")
        return (False, detail)
    check(qa, "booking status " + status, ev)


@then("both holds return the same booking")
def both_holds_same(qa):
    def ev():
        a = qa.first_hold and qa.first_hold["body"]
        b = qa.second_hold and qa.second_hold["body"]
        return (bool(a) and bool(b) and a["id"] == b["id"], f"first {a and a.get('id')}, second {b and b.get('id')}")
    check(qa, "idempotent hold returns same booking", ev)


@then("the booking reads back held with at least one event")
def reads_back_held(qa):
    def ev():
        b = qa.api and qa.api["body"]
        ok = bool(b) and b.get("status") == "held" and isinstance(b.get("events"), list) and len(b["events"]) >= 1
        return (ok, f"{b['status']}, {len(b['events']) if b.get('events') else 0} events" if b else "no body")
    check(qa, "booking reads held with events", ev)


@then("the booking list includes this booking")
def list_includes(qa):
    def ev():
        bs = qa.api and qa.api["body"] and qa.api["body"].get("bookings")
        return (isinstance(bs, list) and any(x["id"] == qa.booking["id"] for x in bs), ",".join(str(x["id"]) for x in bs) if bs else "no list")
    check(qa, "booking list includes this booking", ev)


@then("the refund matches the cancellation policy")
def refund_matches(qa):
    def ev():
        b = qa.api and qa.api["body"]
        if not b:
            return (False, "no response")
        days_before = math.floor((qa.booking["check_in"] - _now()) / DAY)
        want = round_bps(qa.booking["total_cents"], refund_bps(qa.booking["cancellation"], days_before))
        return (b.get("refund_cents") == want, f"refund {b.get('refund_cents')}, expected {want} (policy {qa.booking['cancellation']}, {days_before}d before, total {qa.booking['total_cents']})")
    check(qa, "refund == policy formula", ev)


@then(parsers.parse("the refund is {amount:d}"))
def refund_is(qa, amount):
    def ev():
        b = qa.api and qa.api["body"]
        return (bool(b) and b.get("refund_cents") == amount, ("refund " + str(b.get("refund_cents"))) if b else "no response")
    check(qa, "refund is " + str(amount), ev)
