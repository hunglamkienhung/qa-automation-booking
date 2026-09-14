#!/usr/bin/env bash
# Seed a fresh mini-stay, then run the booking BE tiers (DB + pricing + booking +
# availability + security + live Frankfurter) for one stack. No browser.
set -euo pipefail
STACK="${1:-node}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export MINI_STAY_DB="${MINI_STAY_DB:-/tmp/mini-stay/mini-stay.db}"
( cd services/mini-stay && bash serve.sh up )
if [ "$STACK" = node ]; then
  ( cd node && npm install --no-audit --no-fund )
  ( cd node && QA_DOMAIN_ROOT=.. ./node_modules/.bin/cucumber-js --tags "@be" )
  ( cd node && QA_DOMAIN_ROOT=.. npx qa-report )
else
  python -m venv .venv-ci && . .venv-ci/bin/activate
  ( cd python && pip install -q -r requirements.txt )
  ( cd python && QA_DOMAIN_ROOT=.. python -m pytest -m "be" -q ) || true
  ( cd python && QA_DOMAIN_ROOT=.. qa-report )
fi
