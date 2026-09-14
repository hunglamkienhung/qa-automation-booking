# qa-automation-booking

![Pytest-BDD](https://img.shields.io/badge/Pytest--BDD-tests-0A9EDC?logo=pytest&logoColor=white)
![Cucumber](https://img.shields.io/badge/Cucumber-BDD-23D96C?logo=cucumber&logoColor=white)
![Playwright](https://img.shields.io/badge/Playwright-E2E-2EAD33?logo=playwright&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-store-003B57?logo=sqlite&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![Node](https://img.shields.io/badge/Node-24-5FA04E?logo=nodedotjs&logoColor=white)
[![CI](https://github.com/hunglamkienhung/qa-automation-booking/actions/workflows/ci.yml/badge.svg)](https://github.com/hunglamkienhung/qa-automation-booking/actions/workflows/ci.yml)

QA automation for a **hotel-booking** domain, built as a working system rather
than a slideshow. One booking service with the thing this software must never do
— **sell the same room twice for the same night** — proven correct even when
many guests race for the last room. It is tested at **every layer it has**
(database, API, and screen) by **two independent stacks** (Node with Cucumber,
Python with pytest-bdd) that read **one** shared set of Gherkin features and must
return the **same verdict for every case**.

Nothing here needs an account, a key, or a paid service. Clone it and it runs.

[Tiếng Việt](README.vi.md) · [Grading](docs/GRADING.md) ·
[Gherkin](docs/GHERKIN.md) · [Queue format](docs/QUEUE-FORMAT.md)

## The two systems under test

| System | Access | What it is |
|---|---|---|
| **mini-stay** | read + write, real DB | A small booking backend in `services/mini-stay`: one SQLite file, Node standard library only, a REST API for search, holds, the booking lifecycle and cancellation, and small labelled HTML pages for Playwright. |
| **frankfurter.dev** | read-only, live | A live, keyless FX API (ECB reference rates). A settled historical rate converts a stay price; nobody here can tune it to pass. |

**250 cases**, each with an immutable ID, run in **both** stacks and reconciled
case-by-case. Every layer the service has is tested at that layer:

| Layer | Target | Cases | Where |
|---|---|---|---|
| DB | mini-stay SQLite, opened directly | 52 | `be/db` |
| API | pricing — nights × rate + integer-bps tax | 54 | `be/api` |
| API | booking lifecycle — hold, confirm, check-in/out, cancel, expiry, no-show | 36 | `be/api` |
| API | availability — no overbooking, including under concurrency | 34 | `be/api` |
| API | authorization boundaries (security) | 18 | `be/api` |
| API | Frankfurter + the conversion built on it | 36 | `be/api` |
| FE | mini-stay app pages (Playwright) | 20 | `fe/ui` |
| | **Total** | **250** | |

## The invariant worth the whole repo

**No room is sold beyond its inventory for any night.** Availability is the
number of rooms of a type free for every night of a range, counting confirmed
stays and live holds but not expired ones. A hold is accepted only if a room is
free for the whole range, and the check and the insert happen inside one
`BEGIN IMMEDIATE` transaction. So when many guests fire a hold at the last room
**at the same instant**, they serialise and **exactly one wins** — the
availability tier proves it with a real race (`Promise.all` in Node, a thread
pool in Python) and asserts that exactly as many succeed as there are rooms in
stock, no more. Overlapping date ranges conflict; adjacent ones do not; an
expired hold frees the room; a cancellation frees it.

## The money and the machine

`mini-stay` is where the **write** paths live, and it is deliberately exact.

**Pricing is integer arithmetic.** A stay is the nights times the room's nightly
rate, plus the hotel's tax charged as integer basis points on that subtotal,
rounded half-up to the cent — so the price is exact and both stacks agree. The
pricing tier pins it with golden numbers and checks it against an independent
reimplementation across a grid of rooms and lengths.

**A cancellation refunds a policy-and-timing-dependent fraction.** Each room
carries a cancellation policy (flexible, moderate, non-refundable); the refund
depends on the policy and on how many whole days ahead the cancellation is,
computed in whole cents. The rate, tax and policy are snapshotted onto the
booking, so a later price change never rewrites an existing booking's money.

**A booking runs a gated, audited state machine.** `held → confirmed →
checked_in → checked_out`, with `cancelled`, `expired` (the hold lapsed before it
was confirmed) and `no_show` as exits. Each transition is gated by **who** you
are (only the front desk checks a guest in) and by **what state** the booking is
in, and every transition is written to `booking_events`; confirming takes the
payment and cancelling posts the refund, both to a `ledger`.

**The security tier** probes the API like an attacker — a request with no token,
a forged token, the wrong party's token, or a valid token for a booking or hotel
that is not yours must be refused (401 unauthenticated, 403 forbidden, 404 when
the answer must not even reveal a booking exists), with positive controls so a
refusal is a real gate and not a broken endpoint.

**The live tier** reads Frankfurter with no key. A settled **historical** rate is
asserted by value and for stability across two reads; the **latest** rate moves
with the market, so it is asserted on shape and range only. A pure
`convert(cents, rate)` turns a price into another currency in whole cents, and
converting a real stay total at a real historical rate shows the multi-currency
path end to end.

## The two ideas worth a minute

**One Gherkin set, two stacks, one verdict.** `features/*.feature` are shared.
`node/` runs them with Cucumber; `python/` runs the same files with pytest-bdd.
A per-case disagreement is itself a finding — the logic is being read differently
in two places — and the build fails on it.

**Failed > Blocked > Passed, and an outage is never a failure.** A case is
Failed only when an observed proposition is wrong. When the live source
(Frankfurter, a down service) cannot be reached, the case is **Blocked**, never
Failed — so a flaky network can never masquerade as broken business logic. The
CI gate checks the *shape* of a run against `fixtures/expected-results.json`. See
[docs/GRADING.md](docs/GRADING.md).

## Run in 30 seconds

```bash
# the shared grading core, both stacks
cd core/node && node --test "selftest/*.test.js"
cd ../python && pip install -e . && python -m pytest selftest -q
```

## Run the whole suite

Each step below is exactly what CI runs (`scripts/*.sh`), so it works by hand too.

```bash
# backend, one stack, no browser (seed mini-stay, then DB + pricing + booking + availability + security + Frankfurter)
bash scripts/run-be.sh node       # or: python

# the app pages (installs a chromium browser)
bash scripts/run-fe.sh node       # or: python

# the whole suite, then verify the run's shape against the baseline
bash scripts/gate.sh node
```

By hand, one tier at a time:

```bash
( cd services/mini-stay && bash serve.sh up )    # fresh seeded service
cd node && QA_DOMAIN_ROOT=.. npx cucumber-js --tags "@be and @availability"
```

Prerequisites: Node ≥ 22.13 (for `node:sqlite`) and Python ≥ 3.11. The FE
scripts install their own browser. A devcontainer with all of it is in
[.devcontainer/](.devcontainer/devcontainer.json). A Locust load test is in
[perf/](perf/README.md).

## Layout

```
core/            one grading/queue/report/bugflow core, vendored into this repo
services/
  mini-stay/     SQLite + REST + HTML — the booking service under test
features/        one Gherkin set, shared by both stacks
fixtures/        testcases.json (IDs) · expected-results.json (shape)
node/  python/   the two stacks: be/{db,api} fe/ui
testcases/       catalogue generated from the features (never drifts)
perf/            a Locust load test with a pass/fail gate
scripts/         the exact commands CI runs; reproducible by hand
docs/            grading rules, Gherkin conventions, queue format
.github/workflows/ci.yml
```

## Notes

- The pricing, refund and conversion assertions do not read the service's own
  number back — they **recompute** it in the same integer arithmetic and compare,
  so a wiring or rounding bug surfaces as a mismatch.
- The lifecycle is checked from three sides: the API tier drives the transitions
  and asserts the role gates and error codes; the DB tier reads the
  `booking_events` audit and the `ledger` directly; the FE tier reads the hotel,
  booking and admin pages and compares them with the same rows.
- Each scenario takes a fresh future night so it never contends with another,
  except where it deliberately makes two bookings fight over the same nights.
- The catalogue is generated from the feature files by `testcases/build.js`, so
  it can never drift from what runs — CI checks it with `--check`.

## Honest scope

The live-source tier (Frankfurter) depends on a third party that can be slow or
unreachable; those cases are written to grade **Blocked**, not Failed, when that
happens, and the conversion logic built on it is a pure function checked
deterministically with no network. The self-written mini-stay service is fully
deterministic and is where the pricing, the state machine, the money invariants,
the no-overbooking guarantee and the authorization boundaries are exercised.
