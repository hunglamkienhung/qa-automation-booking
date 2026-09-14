"""The FE branch for the mini-stay app surfaces. Binds ../../features/fe-mini-stay.feature.
Mirror of node/fe/ui/steps/stay.steps.js. The `page` fixture is pytest-playwright's;
the comparison figures come from the store (opened by the shared @stay "store is open"
Background) and the rows, so the FE branch checks the pages against the same data the
BE branch reads. The booking-setup Givens (a held / confirmed booking) are shared from
the be steps.
"""

from __future__ import annotations

import json
import re

from pytest_bdd import given, parsers, scenarios, then, when

from be.api.venues.stay import ApiUnreachable, MiniStay
from fe.ui.pages.stay import ScreenNotReady, StayPage

scenarios("fe-mini-stay.feature")

stay = MiniStay()
UNREACHABLE = (ScreenNotReady, ApiUnreachable)


def fmt(cents, currency):
    return f"{currency} {cents / 100:.2f}"


def screen(qa, description, fn):
    if qa.source_error:
        qa.unobservable(description, "the source could not be reached -- " + qa.source_error)
        return
    try:
        passed, detail = fn()
    except UNREACHABLE as err:
        qa.unobservable(description, str(err))
        return
    qa.check(description, passed, detail)


def active_hotels(qa):
    return qa.store.all("SELECT * FROM hotels WHERE active = 1 ORDER BY id")


# ---------------------------------------------------------------- entry / setup


@given("the home page is open")
def home_open(page, qa):
    page.set_viewport_size({"width": 1440, "height": 900})
    qa.stay_page = StayPage(page)

    def go():
        qa.stay_page.open("/")
        qa.screen["hotels"] = qa.stay_page.hotels()
    qa.fetch_or_block(UNREACHABLE, go)


@given(parsers.parse("the booking reaches {state:w}"))
def booking_reaches(qa, state):
    if qa.source_error:
        return
    try:
        if state == "confirmed":
            qa.api = stay.post(f"/bookings/{qa.booking['id']}/confirm", None, token=qa.guest["token"])
        elif state == "cancelled":
            qa.api = stay.post(f"/bookings/{qa.booking['id']}/cancel", None, token=qa.guest["token"])
        if qa.api and qa.api["status"] < 300:
            qa.booking = qa.api["body"]
    except ApiUnreachable as err:
        qa.source_error = str(err)


# ---------------------------------------------------------------- navigation


def _open_read(qa, path, key, reader, extra=None):
    def go():
        qa.stay_page.open(path)
        try:
            qa.screen[key] = reader()
        except ScreenNotReady:
            qa.screen[key] = None
        if extra:
            extra()
    qa.fetch_or_block(UNREACHABLE, go)


@when(parsers.parse("the hotel page for hotel {hid:d} is opened"))
def hotel_page_opened(qa, hid):
    _open_read(qa, "/hotel/" + str(hid), "rooms", lambda: qa.stay_page.rooms(), extra=lambda: qa.screen.__setitem__("hotelId", hid))


@when("the booking page is opened")
def booking_page_opened(qa):
    _open_read(qa, "/booking/" + str(qa.booking["id"]), "booking", lambda: qa.stay_page.booking())


@when(parsers.parse("the booking page for {bid:d} is opened"))
def booking_page_for_opened(qa, bid):
    _open_read(qa, "/booking/" + str(bid), "booking", lambda: qa.stay_page.booking())


@when("the guest's booking list is opened")
def guest_list_opened(qa):
    _open_read(qa, "/guest/" + str(qa.guest["id"]) + "/bookings", "bookings", lambda: qa.stay_page.guest_bookings())


@when("the admin page is opened")
def admin_page_opened(qa):
    _open_read(qa, "/admin", "admin", lambda: qa.stay_page.admin())


# ---------------------------------------------------------------- home


@then("the home page lists the active hotels, once each")
def home_active(qa):
    def ev():
        ids = sorted(h["id"] for h in qa.screen["hotels"])
        want = [h["id"] for h in active_hotels(qa)]
        return (ids == want, f"screen {json.dumps(ids)}, active {json.dumps(want)}")
    screen(qa, "home == active hotels", ev)


@then("the home page does not list the inactive hotel")
def home_excludes(qa):
    screen(qa, "home excludes inactive", lambda: (not any(h["id"] == 3 for h in qa.screen["hotels"]), "ids " + ",".join(str(h["id"]) for h in qa.screen["hotels"])))


@then("every hotel row shows a three-letter currency code")
def hotel_rows_currency(qa):
    def ev():
        bad = [h for h in qa.screen["hotels"] if not re.match(r"^[A-Z]{3}$", h["currency"])]
        return (not bad and len(qa.screen["hotels"]) > 0, json.dumps(bad[:2]) if bad else ",".join(h["currency"] for h in qa.screen["hotels"]))
    screen(qa, "hotel rows show currency", ev)


@then("the home page shows at least one hotel")
def home_non_empty(qa):
    screen(qa, "home non-empty", lambda: (len(qa.screen["hotels"]) > 0, f"{len(qa.screen['hotels'])} hotels"))


# ---------------------------------------------------------------- hotel rooms


@then("every room name on screen equals the room row")
def room_names(qa):
    def ev():
        if not qa.screen.get("rooms"):
            return (False, "no rooms")
        bad = []
        for m in qa.screen["rooms"]:
            row = qa.store.get("SELECT name FROM room_types WHERE id = ?", m["id"])
            if not row or m["name"] != row["name"]:
                bad.append(m)
        return (not bad and len(qa.screen["rooms"]) > 0, json.dumps(bad[:2]) if bad else f"{len(qa.screen['rooms'])} rooms")
    screen(qa, "room names == rows", ev)


@then("every room rate on screen equals the room row in the hotel's currency")
def room_rates(qa):
    def ev():
        if not qa.screen.get("rooms"):
            return (False, "no rooms")
        hotel = qa.store.get("SELECT currency FROM hotels WHERE id = ?", qa.screen["hotelId"])
        bad = []
        for m in qa.screen["rooms"]:
            row = qa.store.get("SELECT nightly_rate_cents FROM room_types WHERE id = ?", m["id"])
            if not row or m["rateText"] != fmt(row["nightly_rate_cents"], hotel["currency"]):
                bad.append(m)
        return (not bad, json.dumps(bad[:2]) if bad else "rates match " + hotel["currency"])
    screen(qa, "room rates == rows", ev)


@then("every room shows its inventory and cancellation policy from the rows")
def room_inventory_policy(qa):
    def ev():
        if not qa.screen.get("rooms"):
            return (False, "no rooms")
        bad = []
        for m in qa.screen["rooms"]:
            row = qa.store.get("SELECT inventory, cancellation FROM room_types WHERE id = ?", m["id"])
            if not row or m["inventoryText"] != str(row["inventory"]) or m["cancellationText"] != row["cancellation"]:
                bad.append(m)
        return (not bad, json.dumps(bad[:2]) if bad else "match")
    screen(qa, "room inventory + policy == rows", ev)


@then("the page reports not found")
def page_not_found(qa):
    def ev():
        txt = qa.stay_page.page.text_content("body")
        return (re.search(r"no such", txt, re.I) is not None, txt[:60])
    screen(qa, "page not found", ev)


# ---------------------------------------------------------------- booking page


@then("the booking page total equals the stored total")
def booking_page_total(qa):
    def ev():
        b = qa.screen.get("booking")
        row = qa.store.get("SELECT total_cents, currency FROM bookings WHERE id = ?", qa.booking["id"])
        return (bool(b) and b["totalText"] == fmt(row["total_cents"], row["currency"]), b["totalText"] + " vs " + fmt(row["total_cents"], row["currency"]) if b else "no page")
    screen(qa, "booking page total == stored", ev)


@then("the booking page shows the nights from the row")
def booking_page_nights(qa):
    def ev():
        b = qa.screen.get("booking")
        row = qa.store.get("SELECT nights FROM bookings WHERE id = ?", qa.booking["id"])
        return (bool(b) and b["nightsText"] == str(row["nights"]), b["nightsText"] + " vs " + str(row["nights"]) if b else "no page")
    screen(qa, "booking page nights == stored", ev)


@then(parsers.parse('the booking page shows status "{status}"'))
def booking_page_status(qa, status):
    screen(qa, "booking page status " + status, lambda: (bool(qa.screen.get("booking")) and qa.screen["booking"]["statusText"] == status, qa.screen["booking"]["statusText"] if qa.screen.get("booking") else "no page"))


@then("the booking page total is shown as a currency amount")
def booking_page_total_format(qa):
    screen(qa, "booking total format", lambda: (bool(qa.screen.get("booking")) and re.match(r"^[A-Z]{3} \d+\.\d{2}$", qa.screen["booking"]["totalText"]) is not None, qa.screen["booking"]["totalText"] if qa.screen.get("booking") else "no page"))


# ---------------------------------------------------------------- guest bookings


@then("the guest's booking list includes the held booking")
def guest_list_includes(qa):
    def ev():
        ids = [b["id"] for b in (qa.screen.get("bookings") or [])]
        return (qa.booking["id"] in ids, "ids " + ",".join(map(str, ids)))
    screen(qa, "booking list includes held", ev)


@then("each booking row links to its booking page")
def booking_rows_link(qa):
    def ev():
        rows = qa.screen.get("bookings") or []
        bad = [b for b in rows if b["href"] != "/booking/" + str(b["id"])]
        return (not bad and len(rows) > 0, json.dumps(bad[:2]) if bad else f"{len(rows)} links")
    screen(qa, "booking rows link", ev)


@then("every booking row total is a currency amount")
def booking_row_totals(qa):
    def ev():
        rows = qa.screen.get("bookings") or []
        bad = [b for b in rows if not re.match(r"^[A-Z]{3} \d+\.\d{2}$", b["totalText"])]
        return (not bad and len(rows) > 0, ",".join(b["totalText"] for b in bad) if bad else "all currency amounts")
    screen(qa, "booking row totals are currency", ev)


# ---------------------------------------------------------------- admin


@then("the admin payment is shown as a number")
def admin_payment_format(qa):
    screen(qa, "admin payment format", lambda: (bool(qa.screen.get("admin")) and re.match(r"^\d+\.\d{2}$", qa.screen["admin"]["paymentText"]) is not None, qa.screen["admin"]["paymentText"] if qa.screen.get("admin") else "no page"))


@then("every admin status count is a non-negative integer")
def admin_counts_nonneg(qa):
    def ev():
        counts = (qa.screen.get("admin") and qa.screen["admin"]["counts"]) or []
        bad = [c for c in counts if not re.match(r"^\d+$", c["n"]) or int(c["n"]) < 0]
        return (not bad and len(counts) > 0, json.dumps(bad) if bad else f"{len(counts)} counts")
    screen(qa, "admin counts are non-negative ints", ev)


@then("the admin counts include a confirmed booking")
def admin_counts_confirmed(qa):
    def ev():
        counts = (qa.screen.get("admin") and qa.screen["admin"]["counts"]) or []
        row = next((c for c in counts if c["status"] == "confirmed"), None)
        return (bool(row) and int(row["n"]) >= 1, "confirmed " + row["n"] if row else "no confirmed count")
    screen(qa, "admin counts include confirmed", ev)
