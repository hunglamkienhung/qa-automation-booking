"""Steps for be-mini-stay-security.feature. Mirror of node/be/api/steps/security.steps.js
-- a plugin module. These probe the API's authorization boundaries -- no token, a
forged token, the wrong party, a booking or hotel that is not yours. Most setup Givens
(a held/confirmed booking, a guest) and lifecycle Whens are shared from the other @stay
steps; only the adversarial requests and the secret-hygiene assertions are new.
qa.api is always the last response.
"""

from __future__ import annotations

import json
import re

from pytest_bdd import given, parsers, then, when

from be.api.venues.stay import ApiUnreachable, MiniStay, future_range
from be.db.store import DbUnreachable

stay = MiniStay()
FORGED = "gst_forged000000000000000000"


def send(qa, method, path, **opts):
    if qa.source_error:
        return
    try:
        qa.api = stay.request(method, path, **opts)
    except ApiUnreachable as err:
        qa.source_error = str(err)


def check(qa, description, fn):
    if qa.source_error:
        qa.unobservable(description, "the source could not be reached -- " + qa.source_error)
        return
    passed, detail = fn()
    qa.check(description, passed, detail)


# A minted token is a JSON string value "gst_<...>" or "htl_<...>"; match the
# quoted value, not the bare prefix, to avoid false positives on field names.
def leaks_token(obj, admin_token):
    text = json.dumps(obj or {})
    return re.search(r'"(gst|htl)_[A-Za-z0-9_-]{8,}"', text) is not None or ('"' + admin_token + '"') in text


# ---------------------------------------------------------------- cross-party setup


@given("another guest has a booking")
def another_guest_booking(qa):
    if qa.source_error:
        return
    try:
        owner = stay.new_guest("Owner")
        b = stay.hold(owner["token"], {"room_type_id": 1, **future_range(220, 2)})
        qa.owner_booking_id = b["id"]
        qa.guest = stay.new_guest("Snoop")  # the attacker
    except (ApiUnreachable, DbUnreachable) as err:
        qa.source_error = str(err)


@given("a priced quote")
def a_priced_quote(qa):
    send(qa, "POST", "/quotes", body={"room_type_id": 1, **future_range(30, 2)})
    qa.quote = qa.api and qa.api["body"]


# ---------------------------------------------------------------- adversarial requests


@when("a room is held with no token")
def held_no_token(qa):
    send(qa, "POST", "/bookings", body={"room_type_id": 1, **future_range(230, 2)})


@when("a room is held with a forged token")
def held_forged(qa):
    send(qa, "POST", "/bookings", token=FORGED, body={"room_type_id": 1, **future_range(231, 2)})


@when("a hotelier tries to hold a room")
def hotelier_holds(qa):
    send(qa, "POST", "/bookings", token=stay.seed_hotelier, body={"room_type_id": 1, **future_range(232, 2)})


@when("the guest reads that booking")
def guest_reads_that(qa):
    send(qa, "GET", "/bookings/" + str(qa.owner_booking_id), token=qa.guest["token"])


@when("the guest cancels that booking")
def guest_cancels_that(qa):
    send(qa, "POST", "/bookings/" + str(qa.owner_booking_id) + "/cancel", token=qa.guest["token"])


@when("the guest confirms that booking")
def guest_confirms_that(qa):
    send(qa, "POST", "/bookings/" + str(qa.owner_booking_id) + "/confirm", token=qa.guest["token"])


@when("a hotelier who owns no hotel checks the booking in")
def hotelier_no_hotel(qa):
    if qa.source_error:
        return
    try:
        other = stay.new_hotelier("Nobody")
    except ApiUnreachable as err:
        qa.source_error = str(err)
        return
    send(qa, "POST", "/bookings/" + str(qa.booking["id"]) + "/check-in", token=other["token"])


@when("the overview is read with the guest's token")
def overview_guest_token(qa):
    send(qa, "GET", "/admin/overview", token=qa.guest["token"])


@when("the admin booking list is read with the guest's token")
def admin_list_guest_token(qa):
    send(qa, "GET", "/admin/bookings", token=qa.guest["token"])


@when("the overview is read with a token that extends the admin token")
def overview_extended_admin(qa):
    send(qa, "GET", "/admin/overview", token=stay.admin_token + "x")


@when("a guest registers")
def guest_registers(qa):
    send(qa, "POST", "/guests", body={"name": "Sec Guest"})


@when("the admin reads the overview")
def admin_reads_overview(qa):
    send(qa, "GET", "/admin/overview", token=stay.admin_token)


# ---------------------------------------------------------------- generic assertions


@then(parsers.parse("the response status is {status:d}"))
def response_status(qa, status):
    check(qa, "response status " + str(status), lambda: (bool(qa.api) and qa.api["status"] == status, f"{qa.api['status']} {json.dumps(qa.api['body'])}" if qa.api else "no response"))


@then(parsers.parse('the response is an error with code "{code}"'))
def response_error_code(qa, code):
    check(qa, "error code " + code, lambda: (bool(qa.api) and qa.api["body"] and qa.api["body"].get("code") == code, json.dumps(qa.api["body"]) if qa.api and qa.api["body"] else "no body"))


@then("the response carries a token")
def response_carries_token(qa):
    def ev():
        t = (qa.api and qa.api["body"] or {}).get("token")
        return (isinstance(t, str) and len(t) > 0, "token " + ("present" if t else "absent"))
    check(qa, "response carries a token", ev)


# ---------------------------------------------------------------- secret hygiene


@then("the quote response carries no bearer token")
def quote_no_token(qa):
    check(qa, "quote body has no token", lambda: (not leaks_token(qa.quote, stay.admin_token), "TOKEN LEAKED" if leaks_token(qa.quote, stay.admin_token) else "clean"))


@then("the booking response carries no bearer token")
def booking_no_token(qa):
    check(qa, "booking body has no token", lambda: (not leaks_token(qa.booking, stay.admin_token), "TOKEN LEAKED" if leaks_token(qa.booking, stay.admin_token) else "clean"))


@then("the read response carries no bearer token")
def read_no_token(qa):
    check(qa, "read body has no token", lambda: (not leaks_token(qa.api and qa.api["body"], stay.admin_token), "TOKEN LEAKED" if leaks_token(qa.api and qa.api["body"], stay.admin_token) else "clean"))


@then("the overview response carries no bearer token")
def overview_no_token(qa):
    check(qa, "overview body has no token", lambda: (not leaks_token(qa.api and qa.api["body"], stay.admin_token), "TOKEN LEAKED" if leaks_token(qa.api and qa.api["body"], stay.admin_token) else "clean"))
