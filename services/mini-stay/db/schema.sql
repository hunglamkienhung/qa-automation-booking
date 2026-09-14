-- mini-stay: a small but real hotel-booking backend over one SQLite file.
-- The tables are the object under test; every test stack opens this same file
-- and asserts on its rows, and the REST layer (search, hold, confirm, the stay
-- lifecycle, cancellation) reads and writes it.
--
-- Money is stored in integer minor units (cents), never a float; tax and refund
-- fractions are integer basis points (bps, /10000). The invariants a hotel must
-- not break are enforced here so a bug surfaces as a constraint violation, not a
-- quietly wrong number or a double-booked room: a room is never sold beyond its
-- inventory for any night (checked in the service inside an IMMEDIATE
-- transaction), a booking runs one lifecycle (held -> confirmed -> checked_in ->
-- checked_out, with cancelled/expired/no_show as exits) audited in
-- booking_events, and the money moved is posted to a ledger.

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS hotels (
  id         INTEGER PRIMARY KEY,
  name       TEXT    NOT NULL,
  city       TEXT    NOT NULL,
  currency   TEXT    NOT NULL,                                    -- ISO 4217, the hotel prices in this
  tax_bps    INTEGER NOT NULL CHECK (tax_bps >= 0),              -- city/occupancy tax on the room subtotal
  active     INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
);

-- A rateable room type with a finite inventory of interchangeable rooms and a
-- cancellation policy. nightly_rate is what one room costs per night.
CREATE TABLE IF NOT EXISTS room_types (
  id               INTEGER PRIMARY KEY,
  hotel_id         INTEGER NOT NULL REFERENCES hotels(id),
  name             TEXT    NOT NULL,
  nightly_rate_cents INTEGER NOT NULL CHECK (nightly_rate_cents >= 0),
  capacity         INTEGER NOT NULL CHECK (capacity > 0),        -- guests one room sleeps
  inventory        INTEGER NOT NULL CHECK (inventory >= 0),      -- rooms of this type the hotel has
  cancellation     TEXT    NOT NULL DEFAULT 'flexible'
                     CHECK (cancellation IN ('flexible', 'moderate', 'nonrefundable'))
);

CREATE TABLE IF NOT EXISTS guests (
  id         INTEGER PRIMARY KEY,
  name       TEXT    NOT NULL,
  token      TEXT    UNIQUE,
  created_at INTEGER NOT NULL
);

-- A hotelier owns hotels and works their front desk (confirm/check-in/out).
CREATE TABLE IF NOT EXISTS hoteliers (
  id         INTEGER PRIMARY KEY,
  name       TEXT    NOT NULL,
  token      TEXT    UNIQUE,
  created_at INTEGER NOT NULL
);
-- Which hotelier owns which hotel (a hotel has exactly one owner here).
CREATE TABLE IF NOT EXISTS hotel_owners (
  hotel_id    INTEGER PRIMARY KEY REFERENCES hotels(id),
  hotelier_id INTEGER NOT NULL REFERENCES hoteliers(id)
);

-- A booking of one room of a type for a night range [check_in, check_out).
-- Dates are unix seconds at UTC midnight; nights = (check_out - check_in)/86400.
-- The rate, tax and cancellation policy are snapshotted so a later price change
-- never rewrites an existing booking's money.
CREATE TABLE IF NOT EXISTS bookings (
  id                 INTEGER PRIMARY KEY,
  guest_id           INTEGER NOT NULL REFERENCES guests(id),
  hotel_id           INTEGER NOT NULL REFERENCES hotels(id),
  room_type_id       INTEGER NOT NULL REFERENCES room_types(id),
  check_in           INTEGER NOT NULL,
  check_out          INTEGER NOT NULL CHECK (check_out > check_in),
  nights             INTEGER NOT NULL CHECK (nights > 0),
  nightly_rate_cents INTEGER NOT NULL CHECK (nightly_rate_cents >= 0),
  currency           TEXT    NOT NULL,
  base_cents         INTEGER NOT NULL CHECK (base_cents >= 0),
  tax_cents          INTEGER NOT NULL CHECK (tax_cents >= 0),
  total_cents        INTEGER NOT NULL CHECK (total_cents >= 0),
  cancellation       TEXT    NOT NULL CHECK (cancellation IN ('flexible', 'moderate', 'nonrefundable')),
  status             TEXT    NOT NULL DEFAULT 'held'
                       CHECK (status IN ('held', 'confirmed', 'checked_in', 'checked_out', 'cancelled', 'expired', 'no_show')),
  hold_expires_at    INTEGER,                                    -- while 'held', the hold lapses after this
  refund_cents       INTEGER CHECK (refund_cents IS NULL OR refund_cents >= 0),
  idempotency_key    TEXT    UNIQUE,
  created_at         INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS bookings_room ON bookings(room_type_id);
CREATE INDEX IF NOT EXISTS bookings_guest ON bookings(guest_id);

CREATE TABLE IF NOT EXISTS booking_events (
  id         INTEGER PRIMARY KEY,
  booking_id INTEGER NOT NULL REFERENCES bookings(id),
  from_status TEXT,
  to_status  TEXT    NOT NULL,
  actor      TEXT    NOT NULL CHECK (actor IN ('guest', 'hotelier', 'admin', 'system')),
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS booking_events_booking ON booking_events(booking_id);

-- The money moved: a payment in when a hold is confirmed, a refund out when a
-- confirmed booking is cancelled. Deltas are from the hotel's side.
CREATE TABLE IF NOT EXISTS ledger (
  id         INTEGER PRIMARY KEY,
  party_type TEXT    NOT NULL CHECK (party_type IN ('hotel', 'guest')),
  party_id   INTEGER,
  delta_cents INTEGER NOT NULL CHECK (delta_cents <> 0),
  reason     TEXT    NOT NULL CHECK (reason IN ('payment', 'refund')),
  booking_id INTEGER REFERENCES bookings(id),
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS ledger_booking ON ledger(booking_id);
