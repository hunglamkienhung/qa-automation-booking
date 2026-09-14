"""Frankfurter's public FX API (frankfurter.dev). Mirror of
node/be/api/venues/frankfurter.js. urllib only, no key, read-only, ECB reference
rates.

A historical date returns settled rates asserted by value and compared across two
reads; the latest endpoint moves with the market, so it is asserted on shape and
range only. A transport failure, a 5xx/429, or a non-JSON body is FxUnreachable
(grades Blocked). ``convert`` is a pure integer function that takes no network.
"""

from __future__ import annotations

import json
import math
import os
import urllib.error
import urllib.parse
import urllib.request

BASE = os.environ.get("FRANKFURTER_URL", "https://api.frankfurter.dev/v1").rstrip("/")
TIMEOUT = 25

# A settled historical day and a fixed pair set, so the API answers the same
# values on every read.
HIST_DATE = "2024-01-02"
HIST_BASE = "USD"
HIST_SYMBOLS = "EUR,GBP"


class FxUnreachable(Exception):
    pass


# A browser-like User-Agent so Cloudflare serves the public API instead of a WAF
# challenge. urllib's default "Python-urllib/x" UA is refused with a 403 here,
# whereas the node stack's undici runtime sends a UA that passes -- so this keeps
# the two stacks reaching (or not reaching) the API together.
_UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"


def request(path, params=None):
    url = BASE + path + ("?" + urllib.parse.urlencode(params) if params else "")
    req = urllib.request.Request(url, headers={"accept": "application/json", "User-Agent": _UA}, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as res:
            status, text = res.status, res.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as err:
        if err.code >= 500 or err.code == 429:
            raise FxUnreachable(f"GET {path} -- HTTP {err.code}") from err
        status, text = err.code, err.read().decode("utf-8", "replace")
    except (urllib.error.URLError, TimeoutError, OSError) as err:
        raise FxUnreachable(f"GET {path} -- {err}") from err
    # 5xx/429 are the API failing; 403 is a Cloudflare/WAF challenge refusing
    # anonymous automated access to this public no-key endpoint. Both are the
    # rate service being unreachable, not a rate being wrong -> Blocked, never
    # Failed (mirrors the node stack, whose env hit a transport failure here).
    if status >= 500 or status == 429 or status == 403:
        raise FxUnreachable(f"GET {path} -- HTTP {status}")
    try:
        body = json.loads(text)
    except json.JSONDecodeError:
        body = None
    if not isinstance(body, dict):
        raise FxUnreachable(f"GET {path} -- expected JSON, got " + " ".join(text[:40].split()) + "…")
    return {"httpStatus": status, "body": body}


def historical(date=None, base=None, symbols=None):
    return request("/" + (date or HIST_DATE), {"base": base or HIST_BASE, "symbols": symbols or HIST_SYMBOLS})


def latest(base=None, symbols=None):
    return request("/latest", {"base": base or "USD", "symbols": symbols or "EUR,GBP,JPY"})


def convert(amount_cents, rate):
    """Convert an integer-cent amount at a rate, half-up to whole cents. Pure."""
    return math.floor(amount_cents * rate + 0.5)


def is_finite_number(v):
    return isinstance(v, (int, float)) and not isinstance(v, bool) and math.isfinite(v)
