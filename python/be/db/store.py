"""Read-only access to the mini-stay SQLite file. Mirror of node/be/db/store.js.

Both stacks open the same file the service writes. A missing file is DbUnreachable
and grades Blocked. The WAL store must live on a native Linux filesystem for a WSL
reader to memory-map it -- set MINI_STAY_DB to a /tmp path when running under WSL.
"""

from __future__ import annotations

import os
import sqlite3
from pathlib import Path

DB_FILE = Path(os.environ.get("MINI_STAY_DB") or Path(__file__).resolve().parents[3] / "services" / "mini-stay" / "data" / "mini-stay.db")
SCHEMA = Path(__file__).resolve().parents[3] / "services" / "mini-stay" / "db" / "schema.sql"


class DbUnreachable(Exception):
    pass


def _rows(cur):
    cols = [c[0] for c in cur.description] if cur.description else []
    return [dict(zip(cols, r)) for r in cur.fetchall()]


class Store:
    def __init__(self, file: Path = DB_FILE) -> None:
        self.file = Path(file)
        if not self.file.exists():
            raise DbUnreachable(f"no store at {self.file} -- start mini-stay (services/mini-stay/serve.sh up)")
        try:
            self.db = sqlite3.connect(f"file:{self.file.as_posix()}?mode=ro", uri=True, timeout=5, isolation_level=None)
            self.db.execute("SELECT 1 FROM hotels").fetchall()
        except sqlite3.Error as err:
            raise DbUnreachable(f"cannot open {self.file}: {err}") from err

    def close(self):
        try:
            self.db.close()
        except sqlite3.Error:
            pass

    def all(self, sql, *p):
        return _rows(self.db.execute(sql, p))

    def get(self, sql, *p):
        r = self.all(sql, *p)
        return r[0] if r else None

    def count(self, table, where="", *p):
        return int(self.get(f"SELECT COUNT(*) AS n FROM {table} {where}", *p)["n"])

    def tables(self):
        return [r["name"] for r in self.all("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")]

    def events(self, booking_id):
        """The events of one booking, oldest first -- the audit of its lifecycle."""
        return self.all("SELECT * FROM booking_events WHERE booking_id = ? ORDER BY id", booking_id)

    def ledger(self, booking_id):
        """Ledger rows tied to one booking (payment, refund)."""
        return self.all("SELECT * FROM ledger WHERE booking_id = ? ORDER BY id", booking_id)

    def ledger_sum(self, reason):
        return int(self.get("SELECT COALESCE(SUM(delta_cents),0) AS s FROM ledger WHERE reason = ?", reason)["s"])


def throwaway():
    """A throwaway in-memory store with the schema applied, for constraint checks."""
    db = sqlite3.connect(":memory:", isolation_level=None)
    db.execute("PRAGMA foreign_keys = ON")
    db.executescript(SCHEMA.read_text(encoding="utf-8").replace("PRAGMA journal_mode = WAL;", ""))
    return db
