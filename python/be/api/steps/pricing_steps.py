"""Steps for be-mini-stay-pricing.feature. Mirror of node/be/api/steps/pricing.steps.js
-- a plugin module. The @stay Before/After setup and the "store is open" Background
live in be/db/steps/stay_steps.py.

The "matches the pricing formula" check recomputes the total client-side from the
nightly rate and tax the quote reports, in the same integer basis-point arithmetic
the service uses -- an independent witness of the price. This module also defines the
generic "refused with code/status" steps that every @stay @api tier shares.
"""

from __future__ import annotations

import json

from pytest_bdd import parsers, then, when

from be.api.venues.stay import DAY, ApiUnreachable, MiniStay, future_range

stay = MiniStay()


def round_bps(amount, bps):
    return (amount * bps + 5000) // 10000  # half-up amount*bps/10000


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


def request_quote(qa, room, dates):
    def go():
        qa.api = stay.post("/quotes", {"room_type_id": room, **dates})
        qa.quote = qa.api["body"] if qa.api["status"] == 200 else None
    act(qa, go)


# ---------------------------------------------------------------- Whens


@when(parsers.parse("I request a quote for room {room:d} for {nights:d} nights"))
def quote_room_nights(qa, room, nights):
    request_quote(qa, room, future_range(30, nights))


@when(parsers.parse("I request a quote for room {room:d} with a zero-night stay"))
def quote_zero_night(qa, room):
    r = future_range(30, 1)
    request_quote(qa, room, {"check_in": r["check_in"], "check_out": r["check_in"]})


@when(parsers.parse("I request a quote for room {room:d} for half a night"))
def quote_half_night(qa, room):
    r = future_range(30, 1)
    request_quote(qa, room, {"check_in": r["check_in"], "check_out": r["check_in"] + DAY // 2})


@when(parsers.parse("I request a quote for room {room:d} with check-out before check-in"))
def quote_checkout_before(qa, room):
    r = future_range(30, 1)
    request_quote(qa, room, {"check_in": r["check_in"], "check_out": r["check_in"] - DAY})


# ---------------------------------------------------------------- Thens


@then(parsers.parse("the quote total is {total:d}"))
def quote_total_is(qa, total):
    def ev():
        if qa.quote and qa.quote["total_cents"] == total:
            return (True, "total " + str(qa.quote["total_cents"]))
        detail = ("total " + str(qa.quote["total_cents"])) if qa.quote else (f"{qa.api['status']} {json.dumps(qa.api['body'])}" if qa.api else "no response")
        return (False, detail)
    check(qa, "quote total " + str(total), ev)


@then("the quote total matches the pricing formula")
def quote_matches_formula(qa):
    def ev():
        q = qa.quote
        if not q:
            return (False, f"{qa.api['status']} {json.dumps(qa.api['body'])}" if qa.api else "no quote")
        base = q["nights"] * q["nightly_rate_cents"]
        tax = round_bps(base, q["tax_bps"])
        return (q["total_cents"] == base + tax and q["base_cents"] == base and q["tax_cents"] == tax, f"service {q['total_cents']}, reference {base + tax} (base {base}, tax {tax})")
    check(qa, "total == reference formula", ev)


@then("the quote is internally consistent")
def quote_consistent(qa):
    def ev():
        q = qa.quote
        if not q:
            return (False, "no quote")
        base = q["nights"] * q["nightly_rate_cents"]
        return (q["base_cents"] == base and q["tax_cents"] == round_bps(base, q["tax_bps"]) and q["total_cents"] == q["base_cents"] + q["tax_cents"], json.dumps({"base": q["base_cents"], "tax": q["tax_cents"], "total": q["total_cents"]}))
    check(qa, "quote internally consistent", ev)


@then(parsers.parse('the quote shows the cancellation policy "{policy}"'))
def quote_cancellation(qa, policy):
    check(qa, "quote cancellation " + policy, lambda: (bool(qa.quote) and qa.quote["cancellation"] == policy, qa.quote["cancellation"] if qa.quote else "no quote"))


@then(parsers.parse("the quote is for {nights:d} nights"))
def quote_nights(qa, nights):
    check(qa, "quote nights " + str(nights), lambda: (bool(qa.quote) and qa.quote["nights"] == nights, ("nights " + str(qa.quote["nights"])) if qa.quote else "no quote"))


# ---------------------------------------------------------------- generic refusals, shared across @stay @api tiers


def _refused_code(qa, code):
    def ev():
        ok = bool(qa.api) and qa.api["status"] >= 400 and qa.api["body"] and qa.api["body"].get("code") == code
        return (ok, f"{qa.api['status']} {json.dumps(qa.api['body'])}" if qa.api else "no response")
    check(qa, "refused with code " + code, ev)


def _refused_status(qa, status):
    def ev():
        return (bool(qa.api) and qa.api["status"] == status, f"{qa.api['status']} {json.dumps(qa.api['body'])}" if qa.api else "no response")
    check(qa, "refused with status " + str(status), ev)


@then(parsers.parse('the quote is refused with code "{code}"'))
def quote_refused_code(qa, code):
    _refused_code(qa, code)


@then(parsers.parse("the quote is refused with status {status:d}"))
def quote_refused_status(qa, status):
    _refused_status(qa, status)


@then(parsers.parse('the request is refused with code "{code}"'))
def request_refused_code(qa, code):
    _refused_code(qa, code)


@then(parsers.parse("the request is refused with status {status:d}"))
def request_refused_status(qa, status):
    _refused_status(qa, status)
