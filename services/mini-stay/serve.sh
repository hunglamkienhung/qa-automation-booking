#!/usr/bin/env bash
# Run mini-stay against a local SQLite file, or stop it.
#   ./serve.sh up | down | status
# Detached with setsid so it survives the launching shell. The WAL store must
# live on a native Linux filesystem for a WSL reader to memory-map it -- set
# MINI_STAY_DB to a /tmp path.
set -euo pipefail
cd "$(dirname "$0")"
PORT="${MINI_STAY_PORT:-8150}"
export MINI_STAY_PORT="${PORT}"
LOG="${MINI_STAY_LOG:-/tmp/mini-stay-${PORT}.log}"
PIDFILE="/tmp/mini-stay-${PORT}.pid"
free_port() {
  if command -v fuser >/dev/null 2>&1; then fuser -k "${PORT}/tcp" 2>/dev/null || true
  elif command -v lsof >/dev/null 2>&1; then lsof -ti tcp:"${PORT}" 2>/dev/null | xargs -r kill 2>/dev/null || true; fi
}
case "${1:-up}" in
  up)
    [ -f "${PIDFILE}" ] && kill "$(cat "${PIDFILE}")" 2>/dev/null || true
    pkill -f "mini-stay/server.js" 2>/dev/null || true
    free_port
    sleep 0.4
    if [ -n "${MINI_STAY_DB:-}" ]; then rm -f "${MINI_STAY_DB}" "${MINI_STAY_DB}-shm" "${MINI_STAY_DB}-wal" 2>/dev/null || true; else rm -rf ./data 2>/dev/null || true; fi
    setsid nohup node "$(pwd)/server.js" > "${LOG}" 2>&1 < /dev/null &
    echo $! > "${PIDFILE}"; disown || true
    for i in $(seq 1 40); do curl -sf "http://127.0.0.1:${PORT}/hotels" >/dev/null 2>&1 && break; sleep 0.2; done
    curl -s "http://127.0.0.1:${PORT}/hotels" >/dev/null && echo "mini-stay up on ${PORT} (db ${MINI_STAY_DB:-./data/mini-stay.db})" || { echo "did not come up"; cat "${LOG}"; exit 1; }
    ;;
  down) [ -f "${PIDFILE}" ] && kill "$(cat "${PIDFILE}")" 2>/dev/null || true; rm -f "${PIDFILE}"; echo "stopped" ;;
  status) curl -s "http://127.0.0.1:${PORT}/hotels" && echo || echo "not running" ;;
  *) echo "usage: $0 up|down|status" >&2; exit 2 ;;
esac
