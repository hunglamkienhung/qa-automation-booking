'use strict';

const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');

/**
 * Read-only access to the mini-stay SQLite file -- the same file the service
 * writes. The DB tier asserts on its rows; the API tier reads them to compare
 * with HTTP responses. A missing file is DbUnreachable and grades Blocked.
 */

const DB_FILE = process.env.MINI_STAY_DB
  || path.join(__dirname, '..', '..', '..', 'services', 'mini-stay', 'data', 'mini-stay.db');
const SCHEMA = path.join(__dirname, '..', '..', '..', 'services', 'mini-stay', 'db', 'schema.sql');

class DbUnreachable extends Error {}

class Store {
  constructor(file = DB_FILE) {
    if (!fs.existsSync(file)) throw new DbUnreachable('no store at ' + file + ' -- start mini-stay (services/mini-stay/serve.sh up)');
    this.file = file;
    try { this.db = new DatabaseSync(file, { readOnly: true }); } catch (err) { throw new DbUnreachable('cannot open ' + file + ': ' + err.message); }
  }
  close() { try { this.db.close(); } catch { /* already closed */ } }
  all(sql, ...p) { return this.db.prepare(sql).all(...p); }
  get(sql, ...p) { return this.db.prepare(sql).get(...p); }
  count(table, where = '', ...p) { return Number(this.get(`SELECT COUNT(*) AS n FROM ${table} ${where}`, ...p).n); }
  tables() { return this.all("SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name").map((r) => r.name); }

  /** The events of one booking, oldest first -- the audit of its lifecycle. */
  events(bookingId) { return this.all('SELECT * FROM booking_events WHERE booking_id = ? ORDER BY id', bookingId); }
  /** Ledger rows tied to one booking (payment, refund). */
  ledger(bookingId) { return this.all('SELECT * FROM ledger WHERE booking_id = ? ORDER BY id', bookingId); }
  ledgerSum(reason) { return Number(this.get('SELECT COALESCE(SUM(delta_cents),0) AS s FROM ledger WHERE reason = ?', reason).s); }
}

/** A throwaway in-memory store with the schema applied, for constraint checks. */
function throwaway() {
  const db = new DatabaseSync(':memory:');
  db.exec('PRAGMA foreign_keys = ON');
  db.exec(fs.readFileSync(SCHEMA, 'utf8').replace(/PRAGMA journal_mode = WAL;/, ''));
  return db;
}

module.exports = { Store, DbUnreachable, DB_FILE, throwaway };
