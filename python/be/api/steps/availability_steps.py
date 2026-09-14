"""Steps for be-mini-stay-availability.feature -- the overbooking and concurrency
invariant. Mirror of node/be/api/steps/availability.steps.js -- a plugin module.

Each scenario claims a fresh future night (a monotonic module-level offset) so it
never contends with another; the race steps fire N holds at once with a
ThreadPoolExecutor (each thread registers a fresh guest, then POSTs the booking) and
assert exactly as many succeed as the room has in stock. The service serializes the
check-and-insert inside one IMMEDIATE transaction, so exactly `inventory` win. The
generic "refused with code/status" steps live in pricing_steps.py.
"""

from __future__ import annotations

import json
from concurrent.futures import ThreadPoolExecutor

from pytest_bdd import given, parsers, then, when

from be.api.venues.stay import ApiUnreachable, MiniStay, future_range

stay = MiniStay()

# Module-level: spaced so windows and shifts never overlap the next scenario.
_AV = [0]


def _fresh_offset():
    v = 600 + _AV[0] * 10
    _AV[0] += 1
    return v


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


def fresh_window(qa, room, nights):
    qa.av_room = room
    qa.av_nights = nights
    qa.av_offset = _fresh_offset()
    qa.av_range = future_range(qa.av_offset, nights)
    qa.held_list = []


@given("a fresh night for the scarce room")
def fresh_night_scarce(qa):
    fresh_window(qa, 3, 1)


@given(parsers.parse("a fresh night for room {room:d}"))
def fresh_night_room(qa, room):
    fresh_window(qa, room, 1)


@given(parsers.parse("a fresh {nights:d}-night window for the scarce room"))
def fresh_window_scarce(qa, nights):
    fresh_window(qa, 3, nights)


def hold_once(qa, room, rng):
    def go():
        g = stay.new_guest("racer")
        qa.api = stay.post("/bookings", {"room_type_id": room, **rng}, token=g["token"])
        if qa.api["status"] == 201:
            qa.held_list.append({"id": qa.api["body"]["id"], "token": g["token"]})
        return qa.api
    return act(qa, go)


@given("the scarce room is held for that window")
def scarce_held(qa):
    hold_once(qa, qa.av_room, qa.av_range)


@given("the scarce room is held and confirmed for that window")
def scarce_held_confirmed(qa):
    def go():
        g = stay.new_guest()
        b = stay.hold(g["token"], {"room_type_id": qa.av_room, **qa.av_range})
        stay.post(f"/bookings/{b['id']}/confirm", None, token=g["token"])
        qa.held_list.append({"id": b["id"], "token": g["token"]})
    act(qa, go)


@given("the scarce room is held for that window with a hold that expires at once")
def scarce_held_expires(qa):
    def go():
        g = stay.new_guest()
        qa.api = stay.post("/bookings", {"room_type_id": qa.av_room, **qa.av_range, "hold_ttl_seconds": -1}, token=g["token"])
    act(qa, go)


@given("that hold is cancelled")
def that_hold_cancelled(qa):
    def go():
        h = qa.held_list[0]
        qa.api = stay.post(f"/bookings/{h['id']}/cancel", None, token=h["token"])
    act(qa, go)


@given(parsers.parse("the room is held {k:d} times for that window"))
def room_held_k_times(qa, k):
    for _ in range(k):
        hold_once(qa, qa.av_room, qa.av_range)


@given("one of those holds is cancelled")
def one_hold_cancelled(qa):
    def go():
        h = qa.held_list[0]
        qa.api = stay.post(f"/bookings/{h['id']}/cancel", None, token=h["token"])
    act(qa, go)


# ---------------------------------------------------------------- Whens


@when("the availability for that window is read")
def availability_read(qa):
    def go():
        qa.api = stay.get(f"/rooms/{qa.av_room}/availability?check_in={qa.av_range['check_in']}&check_out={qa.av_range['check_out']}")
    act(qa, go)


@when("the availability for a zero-night window is read")
def availability_zero(qa):
    def go():
        qa.api = stay.get(f"/rooms/{qa.av_room}/availability?check_in={qa.av_range['check_in']}&check_out={qa.av_range['check_in']}")
    act(qa, go)


@when(parsers.parse("the availability of room {room:d} for a fresh night is read"))
def availability_fresh(qa, room):
    r = future_range(_fresh_offset(), 1)

    def go():
        qa.api = stay.get(f"/rooms/{room}/availability?check_in={r['check_in']}&check_out={r['check_out']}")
    act(qa, go)


@when("another guest holds the scarce room for that window")
def another_holds_scarce(qa):
    hold_once(qa, qa.av_room, qa.av_range)


@when("another guest holds that room for that window")
def another_holds_room(qa):
    hold_once(qa, qa.av_room, qa.av_range)


@when("the scarce room is held for that window again")
def scarce_held_again(qa):
    hold_once(qa, qa.av_room, qa.av_range)


@when("a guest holds the scarce room shifted one night later")
def scarce_shift_one(qa):
    hold_once(qa, qa.av_room, future_range(qa.av_offset + 1, qa.av_nights))


@when("a guest holds the scarce room shifted two nights later")
def scarce_shift_two(qa):
    hold_once(qa, qa.av_room, future_range(qa.av_offset + 2, qa.av_nights))


@when("a guest holds the scarce room for the two nights immediately after")
def scarce_two_after(qa):
    hold_once(qa, qa.av_room, future_range(qa.av_offset + qa.av_nights, 2))


def race(qa, room, rng, n):
    def go():
        guests = [stay.new_guest("racer") for _ in range(n)]

        def hold(g):
            return stay.post("/bookings", {"room_type_id": room, **rng}, token=g["token"])["status"]

        with ThreadPoolExecutor(max_workers=n) as ex:
            qa.race_statuses = list(ex.map(hold, guests))
    act(qa, go)


@when(parsers.parse("{n:d} guests hold the scarce room for that window at once"))
def race_scarce(qa, n):
    race(qa, qa.av_room, qa.av_range, n)


@when(parsers.parse("{n:d} guests hold that room for that window at once"))
def race_room(qa, n):
    race(qa, qa.av_room, qa.av_range, n)


# ---------------------------------------------------------------- Thens


@then(parsers.parse("the availability is {n:d}"))
def availability_is(qa, n):
    def ev():
        ok = bool(qa.api) and qa.api["body"] and qa.api["body"].get("available") == n
        detail = ("available " + str(qa.api["body"]["available"])) if (qa.api and qa.api["body"]) else (f"{qa.api['status']} {json.dumps(qa.api['body'])}" if qa.api else "no response")
        return (ok, detail)
    check(qa, "availability " + str(n), ev)


@then("the hold succeeds")
def hold_succeeds(qa):
    check(qa, "hold succeeds", lambda: (bool(qa.api) and qa.api["status"] == 201, f"{qa.api['status']} {json.dumps(qa.api['body'])}" if qa.api else "no response"))


def _race_check(qa, k):
    def ev():
        s = qa.race_statuses or []
        ok = len([x for x in s if x == 201])
        conflict = len([x for x in s if x == 409])
        return (ok == k and conflict == len(s) - k, f"{ok} x 201, {conflict} x 409 of {len(s)}")
    check(qa, f"exactly {k} of the race win", ev)


@then(parsers.parse("exactly {k:d} holds succeed and the rest are sold out"))
def exactly_k_succeed(qa, k):
    _race_check(qa, k)


@then(parsers.parse("exactly {k:d} hold succeeds and the rest are sold out"))
def exactly_k_succeeds(qa, k):
    _race_check(qa, k)
