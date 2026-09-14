# Performance tests (Locust)

Load tests for the **mini-stay** service — the performance counterpart to the
functional BDD suite. They drive the same REST API the search, hold, booking and
admin flows use, under concurrency, validating every response so a wrong status
is a failure, not just a slow success. A sold-out night under load is a valid
business answer, not a failure.

## Run

```bash
pip install -r perf/requirements.txt
bash perf/run.sh                 # 40 users, spawn 10/s, 30s, against a fresh mini-stay
bash perf/run.sh 100 20 60s      # heavier: 100 users, 60s
```

`run.sh` seeds a fresh service and runs Locust headless. An interactive web UI
(charts, live control) is available too:

```bash
( cd services/mini-stay && MINI_STAY_DB=/tmp/mini-stay-perf/mini-stay.db bash serve.sh up )
locust -f perf/locustfile.py --host http://127.0.0.1:8150      # then open http://localhost:8089
```

## The traffic model

Four user classes, weighted to a realistic mix:

| Class | Weight | What it does |
|---|---|---|
| `Shopper` | 5 | Browses `/hotels` and rooms, and prices `/quotes` — the read + pricing path. |
| `Booker` | 3 | Registers, holds a room, confirms it, reads it back. |
| `FrontDesk` | 2 | Runs one stay the whole way — hold, confirm, then hotelier `check-in → check-out`. |
| `Admin` | 1 | Polls `/admin/overview`. |

## The pass/fail gate

The locustfile's `quitting` hook exits **non-zero** when a run breaches either
threshold, so `run.sh` doubles as a CI performance gate:

- error ratio > `PERF_MAX_FAIL_RATIO` (default `0.01` — 1%)
- p95 latency > `PERF_MAX_P95_MS` (default `750` ms)

Override them per environment, e.g. `PERF_MAX_P95_MS=400 bash perf/run.sh`.

A local baseline (40 users, 30s, warm SQLite on a laptop) lands around
**200+ req/s, 0 failures, p95 well under 100 ms** — the whole point of an
integer-money, single-file store with the availability check and insert in one
transaction and no network hops in the hot path.
