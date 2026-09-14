"""Steps for be-mini-stay-db.feature, plus the shared "drive the service" Givens
that the pricing, booking, availability and security features reuse. Mirror of
node/be/db/steps/stay.steps.js -- a plugin module.

Every scenario builds its own state through the API -- a fresh guest, a fresh
booking on a distinct future date range -- and reads the rows straight from the
file, so scenarios never collide however they interleave. A source that is not
reachable (no store, service down) sets source_error and grades Blocked.

Each "don't-care" hold lands on its own future night via the module-level
OFFSET_COUNTER, so scenarios never fight over inventory; scenarios that must share
a night compute one range in-step. Mirror of the node module-level counter.
"""

from __future__ import annotations

import json
import sqlite3
import time
from pathlib import Path

import pytest
from pytest_bdd import given, parsers, then, when

from be.api.venues.stay import DAY, ApiUnreachable, MiniStay, future_range
from be.db.store import DbUnreachable, Store, throwaway

stay = MiniStay()
UNREACHABLE = (DbUnreachable, ApiUnreachable)
SEED = Path(__file__).resolve().parents[4] / "services" / "mini-stay" / "db" / "seed.sql"

OCCUPYING = "(status IN ('confirmed','checked_in','checked_out') OR (status = 'held' AND hold_expires_at > ?))"


def _now_sec():
    return int(time.time())


@pytest.fixture(autouse=True)
def stay_scenario(request, qa):
    if request.node.get_closest_marker("stay") is None:
        yield
        return
    qa.store = None
    qa.stay = stay
    qa.guest = None
    qa.booking = None
    qa.quote = None
    qa.noted = {}
    qa.api = None
    qa.tmp = None
    yield
    if getattr(qa, "tmp", None) is not None:
        try:
            qa.tmp.close()
        except sqlite3.Error:
            pass
    if getattr(qa, "store", None) is not None:
        qa.store.close()


# ---------------------------------------------------------------- helpers


def act(qa, fn):
    if qa.source_error:
        return None
    try:
        return fn()
    except UNREACHABLE as err:
        qa.source_error = str(err)
        return None


def check(qa, description, fn):
    if qa.source_error:
        qa.unobservable(description, "the source could not be reached -- " + qa.source_error)
        return
    try:
        passed, detail = fn()
    except UNREACHABLE as err:
        qa.unobservable(description, str(err))
        return
    qa.check(description, passed, detail)


def occupied(store, room_id, night_sec):
    return store.get(
        f"SELECT COUNT(*) AS n FROM bookings WHERE room_type_id = ? AND check_in <= ? AND check_out > ? AND {OCCUPYING}",
        room_id, night_sec, night_sec, _now_sec(),
    )["n"]


# ---------------------------------------------------------------- Background


@given("the store is open and the service is reachable")
def store_open(qa):
    if qa.source_error:
        return
    try:
        qa.store = Store()
    except DbUnreachable as err:
        qa.source_error = str(err)
        return
    r = act(qa, lambda: stay.get("/hotels"))
    if qa.source_error:
        return
    if not r or r["status"] != 200:
        qa.source_error = "mini-stay did not answer /hotels: " + (str(r["status"]) if r else "no response")
        return
    qa.evidence("storeFile", str(qa.store.file))


# ---------------------------------------------------------------- drive the service (shared with @api tiers)


@given("a guest")
def a_guest(qa):
    def go():
        qa.guest = stay.new_guest()
    act(qa, go)


# Module-level: each default hold takes a unique future night.
_OFFSET_COUNTER = [0]


def _next_offset():
    v = 400 + _OFFSET_COUNTER[0]
    _OFFSET_COUNTER[0] += 1
    return v


def hold_booking(qa, room=1, nights=2, offset=None, ttl=None):
    def go():
        if not qa.guest:
            qa.guest = stay.new_guest()
        off = _next_offset() if offset is None else offset
        rng = future_range(off, nights)
        body = {"room_type_id": room, **rng}
        if ttl is not None:
            body["hold_ttl_seconds"] = ttl
        qa.booking = stay.hold(qa.guest["token"], body)
        qa.api = {"status": 201, "body": qa.booking}
    act(qa, go)


@given("a held booking")
def a_held_booking(qa):
    hold_booking(qa)


@given(parsers.re(r"^a held booking of room (?P<room>\d+) for (?P<nights>\d+) nights starting (?P<offset>\d+) days out$"))
def a_held_booking_full(qa, room, nights, offset):
    hold_booking(qa, room=int(room), nights=int(nights), offset=int(offset))


@given(parsers.re(r"^a held booking of room (?P<room>\d+) for (?P<nights>\d+) nights$"))
def a_held_booking_rn(qa, room, nights):
    hold_booking(qa, room=int(room), nights=int(nights))


def confirm_booking(qa):
    def go():
        qa.api = stay.post(f"/bookings/{qa.booking['id']}/confirm", None, token=qa.guest["token"])
        if qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    act(qa, go)


@given("the booking is confirmed")
@when("the booking is confirmed")
def the_booking_is_confirmed(qa):
    confirm_booking(qa)


@given("a confirmed booking")
def a_confirmed_booking(qa):
    hold_booking(qa)
    confirm_booking(qa)


@given(parsers.re(r"^a confirmed booking of room (?P<room>\d+) starting (?P<offset>\d+) days out$"))
def a_confirmed_booking_full(qa, room, offset):
    hold_booking(qa, room=int(room), nights=2, offset=int(offset))
    confirm_booking(qa)


def hotelier_action(qa, action):
    def go():
        qa.api = stay.post(f"/bookings/{qa.booking['id']}/{action}", None, token=stay.seed_hotelier)
        if qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    act(qa, go)


@given("the booking is checked in")
@when("the booking is checked in")
def the_booking_is_checked_in(qa):
    hotelier_action(qa, "check-in")


@given("the booking is checked out")
@when("the booking is checked out")
def the_booking_is_checked_out(qa):
    hotelier_action(qa, "check-out")


@given("the booking is marked a no-show")
@when("the booking is marked a no-show")
def the_booking_is_no_show(qa):
    hotelier_action(qa, "no-show")


@given("the booking is cancelled")
@when("the booking is cancelled")
def the_booking_is_cancelled(qa):
    def go():
        qa.api = stay.post(f"/bookings/{qa.booking['id']}/cancel", None, token=qa.guest["token"])
        if qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    act(qa, go)


@given("a hold that has already expired")
def a_hold_expired(qa):
    hold_booking(qa, room=2, nights=1, offset=55, ttl=-1)


@given("confirming the expired hold is attempted")
def confirming_expired(qa):
    def go():
        qa.api = stay.post(f"/bookings/{qa.booking['id']}/confirm", None, token=qa.guest["token"])
        if qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    act(qa, go)


@given(parsers.re(r"^the scarce room is fully booked for (?P<nights>\d+) nights? starting (?P<offset>\d+) days out$"))
def scarce_fully_booked(qa, nights, offset):
    def go():
        g = stay.new_guest()
        rng = future_range(int(offset), int(nights))
        qa.scarce_range = rng
        qa.booking = stay.hold(g["token"], {"room_type_id": 3, **rng})
        qa.api = {"status": 201, "body": qa.booking}
    act(qa, go)


# ---------------------------------------------------------------- schema (throwaway)


@then(parsers.re(r"^the store has tables (?P<lst>.+)$"))
def store_has_tables(qa, lst):
    want = [t.strip() for t in lst.split(",")]

    def ev():
        have = qa.store.tables()
        missing = [t for t in want if t not in have]
        return (not missing, "missing " + ", ".join(missing) if missing else f"{len(have)} tables")
    check(qa, "store has the documented tables", ev)


@given("a throwaway database with the schema applied")
def throwaway_db(qa):
    qa.tmp = throwaway()
    qa.tmp.execute("INSERT INTO hotels (id, name, city, currency, tax_bps, active) VALUES (1, 'H', 'C', 'USD', 1000, 1)")
    qa.tmp.execute("INSERT INTO room_types (id, hotel_id, name, nightly_rate_cents, capacity, inventory, cancellation) VALUES (1, 1, 'R', 10000, 2, 5, 'flexible')")
    qa.tmp.execute("INSERT INTO guests (id, name, token, created_at) VALUES (1, 'G', 'gtok', 1)")
    qa.tmp.execute("INSERT INTO hoteliers (id, name, token, created_at) VALUES (1, 'HT', 'htok', 1)")
    qa.tmp.execute("INSERT INTO hotel_owners (hotel_id, hotelier_id) VALUES (1, 1)")
    qa.tmp.execute("INSERT INTO bookings (id, guest_id, hotel_id, room_type_id, check_in, check_out, nights, nightly_rate_cents, currency, base_cents, tax_cents, total_cents, cancellation, status, hold_expires_at, idempotency_key, created_at) VALUES (1, 1, 1, 1, 1000, 87400, 1, 10000, 'USD', 10000, 1000, 11000, 'flexible', 'held', 9999999999, NULL, 1)")


@given("a throwaway database with the schema and seed applied")
def throwaway_seeded(qa):
    qa.tmp = throwaway()
    qa.tmp.executescript(SEED.read_text(encoding="utf-8"))


def _fails(db, sql, params, needle):
    try:
        db.execute(sql, params)
        return (False, "insert succeeded")
    except sqlite3.Error as err:
        return (needle in str(err), str(err))


_B = "INSERT INTO bookings (guest_id, hotel_id, room_type_id, check_in, check_out, nights, nightly_rate_cents, currency, base_cents, tax_cents, total_cents, cancellation, status, hold_expires_at, created_at) VALUES "


@then("inserting a room type with zero capacity fails a CHECK")
def rt_zero_capacity(qa):
    qa.observe("capacity > 0", lambda: _fails(qa.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory) VALUES (1, 'X', 100, 0, 1)", (), "CHECK constraint failed"))


@then("inserting a room type with negative inventory fails a CHECK")
def rt_neg_inventory(qa):
    qa.observe("inventory >= 0", lambda: _fails(qa.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory) VALUES (1, 'X', 100, 2, -1)", (), "CHECK constraint failed"))


@then("inserting a room type for a missing hotel fails a FOREIGN KEY")
def rt_missing_hotel(qa):
    qa.observe("room_types.hotel_id FK", lambda: _fails(qa.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory) VALUES (999, 'X', 100, 2, 1)", (), "FOREIGN KEY constraint failed"))


@then("inserting a booking for a missing guest fails a FOREIGN KEY")
def bk_missing_guest(qa):
    qa.observe("bookings.guest_id FK", lambda: _fails(qa.tmp, _B + "(999, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 1)", (), "FOREIGN KEY constraint failed"))


@then("inserting a booking for a missing room type fails a FOREIGN KEY")
def bk_missing_room(qa):
    qa.observe("bookings.room_type_id FK", lambda: _fails(qa.tmp, _B + "(1, 1, 999, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 1)", (), "FOREIGN KEY constraint failed"))


@then("inserting a booking event for a missing booking fails a FOREIGN KEY")
def be_missing_booking(qa):
    qa.observe("booking_events.booking_id FK", lambda: _fails(qa.tmp, "INSERT INTO booking_events (booking_id, from_status, to_status, actor, created_at) VALUES (999, NULL, 'held', 'guest', 1)", (), "FOREIGN KEY constraint failed"))


@then("inserting a room type with a negative nightly rate fails a CHECK")
def rt_neg_rate(qa):
    qa.observe("nightly_rate_cents >= 0", lambda: _fails(qa.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory) VALUES (1, 'X', -1, 2, 1)", (), "CHECK constraint failed"))


@then("inserting a booking with a negative total fails a CHECK")
def bk_neg_total(qa):
    qa.observe("total_cents >= 0", lambda: _fails(qa.tmp, _B + "(1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, -1, 'flexible', 'held', 1, 1)", (), "CHECK constraint failed"))


@then("inserting a booking with negative tax fails a CHECK")
def bk_neg_tax(qa):
    qa.observe("tax_cents >= 0", lambda: _fails(qa.tmp, _B + "(1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, -1, 100, 'flexible', 'held', 1, 1)", (), "CHECK constraint failed"))


@then("inserting a booking whose check-out is before its check-in fails a CHECK")
def bk_bad_dates(qa):
    qa.observe("check_out > check_in", lambda: _fails(qa.tmp, _B + "(1, 1, 1, 87400, 1000, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 1)", (), "CHECK constraint failed"))


@then("inserting a booking with zero nights fails a CHECK")
def bk_zero_nights(qa):
    qa.observe("nights > 0", lambda: _fails(qa.tmp, _B + "(1, 1, 1, 1000, 87400, 0, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 1)", (), "CHECK constraint failed"))


@then(parsers.parse('inserting a booking with status "{status}" fails a CHECK'))
def bk_status_check(qa, status):
    qa.observe("booking status CHECK", lambda: _fails(qa.tmp, _B + "(1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', ?, 1, 1)", (status,), "CHECK constraint failed"))


@then(parsers.parse('inserting a booking event with actor "{actor}" fails a CHECK'))
def be_actor_check(qa, actor):
    qa.observe("booking_events actor CHECK", lambda: _fails(qa.tmp, "INSERT INTO booking_events (booking_id, from_status, to_status, actor, created_at) VALUES (1, NULL, ?, ?, 1)", ("held", actor), "CHECK constraint failed"))


@then(parsers.parse('inserting a room type with cancellation "{policy}" fails a CHECK'))
def rt_cancellation_check(qa, policy):
    qa.observe("cancellation CHECK", lambda: _fails(qa.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory, cancellation) VALUES (1, 'X', 100, 2, 1, ?)", (policy,), "CHECK constraint failed"))


@then("inserting a ledger row with zero delta fails a CHECK")
def ledger_zero(qa):
    qa.observe("ledger delta <> 0", lambda: _fails(qa.tmp, "INSERT INTO ledger (party_type, party_id, delta_cents, reason, booking_id, created_at) VALUES ('hotel', 1, 0, 'payment', 1, 1)", (), "CHECK constraint failed"))


@then(parsers.parse('inserting a ledger row with reason "{reason}" fails a CHECK'))
def ledger_reason(qa, reason):
    qa.observe("ledger reason CHECK", lambda: _fails(qa.tmp, "INSERT INTO ledger (party_type, party_id, delta_cents, reason, booking_id, created_at) VALUES (?, 1, 10, ?, 1, 1)", ("hotel", reason), "CHECK constraint failed"))


@then(parsers.parse('inserting a ledger row with party type "{party}" fails a CHECK'))
def ledger_party(qa, party):
    qa.observe("ledger party_type CHECK", lambda: _fails(qa.tmp, "INSERT INTO ledger (party_type, party_id, delta_cents, reason, booking_id, created_at) VALUES (?, 1, 10, ?, 1, 1)", (party, "payment"), "CHECK constraint failed"))


@then("inserting a hotel with a negative tax rate fails a CHECK")
def hotel_neg_tax(qa):
    qa.observe("tax_bps >= 0", lambda: _fails(qa.tmp, "INSERT INTO hotels (id, name, city, currency, tax_bps, active) VALUES (2, 'Z', 'C', 'USD', -1, 1)", (), "CHECK constraint failed"))


@then("inserting two bookings with the same idempotency key fails on the second")
def idempotency_unique(qa):
    def ev():
        ins = "INSERT INTO bookings (guest_id, hotel_id, room_type_id, check_in, check_out, nights, nightly_rate_cents, currency, base_cents, tax_cents, total_cents, cancellation, status, hold_expires_at, idempotency_key, created_at) VALUES (1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 'K', 1)"
        a = _fails(qa.tmp, ins, (), "never")
        if a[1] != "insert succeeded":
            return (False, "first: " + a[1])
        return _fails(qa.tmp, ins, (), "UNIQUE constraint failed")
    qa.observe("idempotency_key UNIQUE", ev)


@then("applying the seed again changes no row counts")
def seed_idempotent(qa):
    def ev():
        tables = ["hotels", "room_types", "guests", "hoteliers", "hotel_owners"]
        before = [qa.tmp.execute("SELECT COUNT(*) FROM " + t).fetchone()[0] for t in tables]
        qa.tmp.executescript(SEED.read_text(encoding="utf-8"))
        after = [qa.tmp.execute("SELECT COUNT(*) FROM " + t).fetchone()[0] for t in tables]
        return (before == after, f"before {json.dumps(before)}, after {json.dumps(after)}")
    qa.observe("seed idempotent", ev)


# ---------------------------------------------------------------- booking rows


def _booking_status_row(qa, status):
    def ev():
        b = qa.store.get("SELECT status FROM bookings WHERE id = ?", qa.booking["id"])
        return (bool(b) and b["status"] == status, b["status"] if b else "no booking")
    check(qa, "booking status row " + status, ev)


@then("the booking row is held")
def booking_row_held(qa):
    _booking_status_row(qa, "held")


@then("the booking row is confirmed")
def booking_row_confirmed(qa):
    _booking_status_row(qa, "confirmed")


@then("the booking row is cancelled")
def booking_row_cancelled(qa):
    _booking_status_row(qa, "cancelled")


@then("the booking row is expired")
def booking_row_expired(qa):
    _booking_status_row(qa, "expired")


@then("the booking row is no_show")
def booking_row_no_show(qa):
    _booking_status_row(qa, "no_show")


@then("the booking total row equals its base plus tax")
def booking_total_base_tax(qa):
    def ev():
        b = qa.store.get("SELECT * FROM bookings WHERE id = ?", qa.booking["id"])
        return (b["total_cents"] == b["base_cents"] + b["tax_cents"], f"base {b['base_cents']} + tax {b['tax_cents']} = {b['total_cents']}")
    check(qa, "total == base + tax", ev)


@then("the booking's first event moves to held by the guest")
def booking_first_event(qa):
    def ev():
        evs = qa.store.events(qa.booking["id"])
        e = evs[0] if evs else None
        return (bool(e) and e["from_status"] is None and e["to_status"] == "held" and e["actor"] == "guest", f"{e['from_status']}->{e['to_status']} by {e['actor']}" if e else "no events")
    check(qa, "first event held by guest", ev)


@then("the booking row snapshots the room's nightly rate and cancellation policy")
def booking_snapshots(qa):
    def ev():
        b = qa.store.get("SELECT * FROM bookings WHERE id = ?", qa.booking["id"])
        r = qa.store.get("SELECT nightly_rate_cents, cancellation FROM room_types WHERE id = ?", b["room_type_id"])
        return (b["nightly_rate_cents"] == r["nightly_rate_cents"] and b["cancellation"] == r["cancellation"], f"booking {b['nightly_rate_cents']}/{b['cancellation']}, room {r['nightly_rate_cents']}/{r['cancellation']}")
    check(qa, "booking snapshots rate + policy", ev)


@then("the booking hold expiry is after its creation time")
def booking_hold_expiry(qa):
    def ev():
        b = qa.store.get("SELECT hold_expires_at, created_at FROM bookings WHERE id = ?", qa.booking["id"])
        return (b["hold_expires_at"] > b["created_at"], f"created {b['created_at']}, expires {b['hold_expires_at']}")
    check(qa, "hold_expires_at > created_at", ev)


def _event_records(qa, frm, to, actor):
    def ev():
        e = next((x for x in qa.store.events(qa.booking["id"]) if x["from_status"] == frm and x["to_status"] == to), None)
        return (bool(e) and e["actor"] == actor, f"by {e['actor']}" if e else "no such event")
    check(qa, f"event {frm}->{to} by {actor}", ev)


@then("a booking event records held to confirmed by the guest")
def event_held_confirmed(qa):
    _event_records(qa, "held", "confirmed", "guest")


@then("a booking event records confirmed to cancelled by the guest")
def event_confirmed_cancelled(qa):
    _event_records(qa, "confirmed", "cancelled", "guest")


@then("a booking event records confirmed to no_show by the hotelier")
def event_confirmed_no_show(qa):
    _event_records(qa, "confirmed", "no_show", "hotelier")


@then("a payment ledger row for the booking equals its total")
def payment_ledger_total(qa):
    def ev():
        b = qa.store.get("SELECT total_cents FROM bookings WHERE id = ?", qa.booking["id"])
        row = next((l for l in qa.store.ledger(qa.booking["id"]) if l["reason"] == "payment"), None)
        return (bool(row) and row["delta_cents"] == b["total_cents"], f"ledger {row['delta_cents']}, total {b['total_cents']}" if row else "no payment row")
    check(qa, "payment ledger == total", ev)


@then("the booking has no ledger rows")
def booking_no_ledger(qa):
    def ev():
        n = len(qa.store.ledger(qa.booking["id"]))
        return (n == 0, f"{n} ledger rows")
    check(qa, "no ledger rows", ev)


@then("the booking has no refund ledger rows")
def booking_no_refund(qa):
    def ev():
        n = len([l for l in qa.store.ledger(qa.booking["id"]) if l["reason"] == "refund"])
        return (n == 0, f"{n} refund rows")
    check(qa, "no refund rows", ev)


@then("a refund ledger row for the booking is a debit")
def refund_ledger_debit(qa):
    def ev():
        row = next((l for l in qa.store.ledger(qa.booking["id"]) if l["reason"] == "refund"), None)
        return (bool(row) and row["delta_cents"] < 0, "refund " + str(row["delta_cents"]) if row else "no refund row")
    check(qa, "refund ledger < 0", ev)


@then("the booking has exactly one payment ledger row")
def booking_one_payment(qa):
    def ev():
        n = len([l for l in qa.store.ledger(qa.booking["id"]) if l["reason"] == "payment"])
        return (n == 1, f"{n} payment rows")
    check(qa, "exactly one payment row", ev)


@then("the booking's events run held, confirmed, checked_in, checked_out")
def booking_lifecycle_events(qa):
    def ev():
        seq = [e["to_status"] for e in qa.store.events(qa.booking["id"])]
        return (seq == ["held", "confirmed", "checked_in", "checked_out"], " -> ".join(seq))
    check(qa, "lifecycle events in order", ev)


# ---------------------------------------------------------------- inventory invariant


@then("each night of the booking shows one room of that type occupied")
def each_night_occupied(qa):
    def ev():
        b = qa.store.get("SELECT * FROM bookings WHERE id = ?", qa.booking["id"])
        bad = []
        d = b["check_in"]
        while d < b["check_out"]:
            n = occupied(qa.store, b["room_type_id"], d)
            if n < 1:
                bad.append(f"night {d}: {n}")
            d += DAY
        return (not bad, ", ".join(bad) if bad else f"{b['nights']} nights each occupied")
    check(qa, "one room occupied each night", ev)


@then("no night shows that room occupied beyond its inventory")
def no_overbooking(qa):
    def ev():
        r = qa.store.get("SELECT inventory FROM room_types WHERE id = 3")
        bad = []
        d = qa.scarce_range["check_in"]
        while d < qa.scarce_range["check_out"]:
            n = occupied(qa.store, 3, d)
            if n > r["inventory"]:
                bad.append(f"night {d}: {n} > {r['inventory']}")
            d += DAY
        return (not bad, ", ".join(bad) if bad else "within inventory")
    check(qa, "occupied <= inventory", ev)


@then("a further hold on that room and night is refused")
def further_hold_refused(qa):
    def ev():
        g = stay.new_guest()
        r = stay.post("/bookings", {"room_type_id": 3, **qa.scarce_range}, token=g["token"])
        return (r["status"] == 409 and r["body"] and r["body"].get("code") == "sold_out", f"{r['status']} {json.dumps(r['body'])}")
    check(qa, "further hold refused", ev)


@then("no room of that type is occupied on that night")
def no_room_occupied(qa):
    def ev():
        b = qa.store.get("SELECT * FROM bookings WHERE id = ?", qa.booking["id"])
        n = occupied(qa.store, b["room_type_id"], b["check_in"])
        return (n == 0, f"{n} occupied")
    check(qa, "room freed after cancel", ev)


# ---------------------------------------------------------------- integrity


@then("no bookings row references a guest missing from guests")
def no_orphan_booking_guest(qa):
    check(qa, "no orphan booking->guest", lambda: ((lambda n: (n == 0, f"{n} orphans"))(qa.store.count("bookings b", "WHERE NOT EXISTS (SELECT 1 FROM guests g WHERE g.id = b.guest_id)"))))


@then("no bookings row references a room type missing from room_types")
def no_orphan_booking_room(qa):
    check(qa, "no orphan booking->room", lambda: ((lambda n: (n == 0, f"{n} orphans"))(qa.store.count("bookings b", "WHERE NOT EXISTS (SELECT 1 FROM room_types r WHERE r.id = b.room_type_id)"))))
