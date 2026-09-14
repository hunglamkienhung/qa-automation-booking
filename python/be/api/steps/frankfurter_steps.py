"""Steps for be-frankfurter-api.feature. Mirror of node/be/api/steps/frankfurter.steps.js
-- a plugin module. The convert steps are pure and deterministic -- they never touch
the network, so they always grade. The live steps read Frankfurter; a transport failure
sets source_error and grades Blocked. One step converts a real stay total at a real
historical rate, so the multi-currency path is checked end to end.
"""

from __future__ import annotations

import json

import pytest
from pytest_bdd import parsers, then, when

from be.api.venues import frankfurter as fx

FLOAT = r"-?\d+(?:\.\d+)?"


@pytest.fixture(autouse=True)
def frankfurter_scenario(request, qa):
    if request.node.get_closest_marker("frankfurter") is None:
        yield
        return
    qa.converted = None
    qa.noted_conv = None
    qa.hist = None
    qa.hist2 = None
    qa.latest = None
    qa.stay_total = None
    qa.stay_rate = None
    qa.stay_converted = None
    yield


def live(qa, fn):
    if qa.source_error:
        return None
    try:
        return fn()
    except fx.FxUnreachable as err:
        qa.source_error = str(err)
        return None


def check(qa, description, fn):
    if qa.source_error:
        qa.unobservable(description, "the source could not be reached -- " + qa.source_error)
        return
    passed, detail = fn()
    qa.check(description, passed, detail)


# ---------------------------------------------------------------- pure conversion


@when(parsers.re(rf"the conversion of (?P<cents>-?\d+) cents at rate (?P<rate>{FLOAT}) is computed"))
def conversion_computed(qa, cents, rate):
    qa.converted = fx.convert(int(cents), float(rate))


@when(parsers.re(rf"the conversion of (?P<cents>-?\d+) cents at rate (?P<rate>{FLOAT}) is noted"))
def conversion_noted(qa, cents, rate):
    qa.noted_conv = fx.convert(int(cents), float(rate))


@then(parsers.parse("the conversion is {out:d}"))
def conversion_is(qa, out):
    qa.check("conversion == " + str(out), qa.converted == out, "converted " + str(qa.converted))


@then("the conversion is at least the noted conversion")
def conversion_at_least(qa):
    qa.check("conversion did not fall", qa.converted >= qa.noted_conv, f"noted {qa.noted_conv}, new {qa.converted}")


# ---------------------------------------------------------------- live historical


@when("the historical rates are fetched")
def historical_fetched(qa):
    def go():
        qa.hist = fx.historical()["body"]
    live(qa, go)


@when("the historical rates are fetched again")
def historical_fetched_again(qa):
    def go():
        qa.hist2 = fx.historical()["body"]
    live(qa, go)


@when(parsers.parse("a stay total of {total:d} is converted at the historical euro rate"))
def stay_converted_eur(qa, total):
    if qa.source_error:
        return
    qa.stay_total = total
    qa.stay_rate = qa.hist["rates"]["EUR"]
    qa.stay_converted = fx.convert(total, qa.stay_rate)


@when(parsers.parse("a stay total of {total:d} is converted at the historical pound rate"))
def stay_converted_gbp(qa, total):
    if qa.source_error:
        return
    qa.stay_total = total
    qa.stay_rate = qa.hist["rates"]["GBP"]
    qa.stay_converted = fx.convert(total, qa.stay_rate)


@then("the historical response carries a rates object")
def historical_has_rates(qa):
    def ev():
        r = qa.hist and qa.hist.get("rates")
        return (bool(r) and isinstance(r, dict) and len(r) > 0, json.dumps(r) if r else "no rates")
    check(qa, "historical has rates", ev)


@then("the historical response is one unit of US dollars")
def historical_one_unit(qa):
    check(qa, "historical amount 1 base USD", lambda: (bool(qa.hist) and qa.hist.get("amount") == 1 and qa.hist.get("base") == "USD", f"amount {qa.hist['amount']}, base {qa.hist['base']}" if qa.hist else "no response"))


@then("the historical euro rate is a positive number")
def historical_eur_positive(qa):
    def ev():
        v = qa.hist and qa.hist.get("rates") and qa.hist["rates"].get("EUR")
        return (fx.is_finite_number(v) and v > 0, "EUR " + str(v))
    check(qa, "historical EUR > 0", ev)


@then("the historical pound rate is a positive number")
def historical_gbp_positive(qa):
    def ev():
        v = qa.hist and qa.hist.get("rates") and qa.hist["rates"].get("GBP")
        return (fx.is_finite_number(v) and v > 0, "GBP " + str(v))
    check(qa, "historical GBP > 0", ev)


@then("both historical reads return identical rates")
def historical_stable(qa):
    check(qa, "historical stable across reads", lambda: (json.dumps(qa.hist["rates"]) == json.dumps(qa.hist2["rates"]), "a " + json.dumps(qa.hist["rates"]) + " b " + json.dumps(qa.hist2["rates"])))


@then("the converted stay is positive and equals the pure conversion")
def converted_stay_consistent(qa):
    check(qa, "converted stay positive and consistent", lambda: (qa.stay_converted > 0 and qa.stay_converted == fx.convert(qa.stay_total, qa.stay_rate), f"converted {qa.stay_converted} at rate {qa.stay_rate}"))


# ---------------------------------------------------------------- live latest


@when("the latest rates are fetched")
def latest_fetched(qa):
    def go():
        qa.latest = fx.latest()["body"]
    live(qa, go)


@then("the latest response carries a rates object")
def latest_has_rates(qa):
    def ev():
        r = qa.latest and qa.latest.get("rates")
        return (bool(r) and isinstance(r, dict) and len(r) > 0, json.dumps(r) if r else "no rates")
    check(qa, "latest has rates", ev)


@then("the latest euro rate is a positive finite number")
def latest_eur_positive(qa):
    def ev():
        v = qa.latest and qa.latest.get("rates") and qa.latest["rates"].get("EUR")
        return (fx.is_finite_number(v) and v > 0, "EUR " + str(v))
    check(qa, "latest EUR positive finite", ev)


@then("the latest response names a date")
def latest_names_date(qa):
    import re

    def ev():
        d = qa.latest and qa.latest.get("date")
        return (isinstance(d, str) and re.match(r"^\d{4}-\d{2}-\d{2}$", d) is not None, d if qa.latest else "no response")
    check(qa, "latest has a date", ev)


@then("every latest rate is a positive number")
def latest_all_positive(qa):
    def ev():
        r = (qa.latest and qa.latest.get("rates")) or {}
        bad = [(k, v) for k, v in r.items() if not fx.is_finite_number(v) or v <= 0]
        return (len(r) > 0 and not bad, "bad " + json.dumps(bad) if bad else json.dumps(r))
    check(qa, "latest rates all positive", ev)


@then("the latest response is one unit of US dollars")
def latest_one_unit(qa):
    check(qa, "latest amount 1 base USD", lambda: (bool(qa.latest) and qa.latest.get("amount") == 1 and qa.latest.get("base") == "USD", f"amount {qa.latest['amount']}, base {qa.latest['base']}" if qa.latest else "no response"))
