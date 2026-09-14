'use strict';

const { Given, When, Then, Before, After } = require('@cucumber/cucumber');
const { Store, DbUnreachable, throwaway } = require('../store');
const { MiniStay, ApiUnreachable, futureRange, DAY } = require('../../api/venues/stay');

/**
 * Steps for features/be-mini-stay-db.feature, plus the shared "drive the
 * service" Givens the pricing, booking, availability and security features
 * reuse. Every scenario builds its own state through the API (a fresh guest, a
 * fresh booking on a distinct future date range) and reads the rows straight
 * from the file, so scenarios never collide however they interleave.
 */

const stay = new MiniStay();
const UNREACHABLE = [DbUnreachable, ApiUnreachable];
const j = (v) => JSON.stringify(v);
const nowSec = () => Math.floor(Date.now() / 1000);
const OCCUPYING = "(status IN ('confirmed','checked_in','checked_out') OR (status = 'held' AND hold_expires_at > ?))";

Before({ tags: '@stay' }, function () {
  this.store = null; this.stay = stay; this.guest = null; this.booking = null;
  this.quote = null; this.noted = {}; this.api = null; this.tmp = null;
});
After({ tags: '@stay' }, function () {
  if (this.tmp) { try { this.tmp.close(); } catch { /* fine */ } }
  if (this.store) this.store.close();
});

async function act(world, fn) {
  if (world.sourceError) return undefined;
  try { return await fn(); } catch (err) { if (UNREACHABLE.some((C) => err instanceof C)) { world.sourceError = err.message; return undefined; } throw err; }
}
async function check(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  let r; try { r = await fn(); } catch (err) { if (UNREACHABLE.some((C) => err instanceof C)) { world.unobservable(description, err.message); return; } throw err; }
  world.check(description, r.passed, r.detail);
}
function occupied(store, roomId, nightSec) {
  return store.get(`SELECT COUNT(*) AS n FROM bookings WHERE room_type_id = ? AND check_in <= ? AND check_out > ? AND ${OCCUPYING}`, roomId, nightSec, nightSec, nowSec()).n;
}

// ---------------------------------------------------------------- Background

Given('the store is open and the service is reachable', { timeout: 30_000 }, async function () {
  if (this.sourceError) return;
  try { this.store = new Store(); } catch (err) { if (err instanceof DbUnreachable) { this.sourceError = err.message; return; } throw err; }
  const r = await act(this, () => stay.get('/hotels'));
  if (this.sourceError) return;
  if (!r || r.status !== 200) this.sourceError = 'mini-stay did not answer /hotels: ' + (r ? r.status : 'no response');
  this.evidence('storeFile', this.store.file);
});

// ---------------------------------------------------------------- drive the service (shared)

Given('a guest', { timeout: 30_000 }, async function () { await act(this, async () => { this.guest = await stay.newGuest(); }); });

// Each "don't-care" hold lands on its own future night so scenarios never fight
// over inventory; scenarios that must share a night compute one range in-step.
let OFFSET_COUNTER = 0;
const nextOffset = () => 400 + (OFFSET_COUNTER++);
async function holdBooking(world, { room = 1, nights = 2, offset, ttl } = {}) {
  await act(world, async () => {
    if (!world.guest) world.guest = await stay.newGuest();
    if (offset === undefined) offset = nextOffset();
    const range = futureRange(offset, nights);
    const body = { room_type_id: room, ...range };
    if (ttl !== undefined) body.hold_ttl_seconds = ttl;
    world.booking = await stay.hold(world.guest.token, body);
    world.api = { status: 201, body: world.booking };
  });
}
Given('a held booking', { timeout: 30_000 }, async function () { await holdBooking(this, {}); });
Given(/^a held booking of room (\d+) for (\d+) nights starting (\d+) days out$/, { timeout: 30_000 }, async function (room, nights, offset) { await holdBooking(this, { room: Number(room), nights: Number(nights), offset: Number(offset) }); });
Given(/^a held booking of room (\d+) for (\d+) nights$/, { timeout: 30_000 }, async function (room, nights) { await holdBooking(this, { room: Number(room), nights: Number(nights) }); });

async function confirmBooking(world) { await act(world, async () => { world.api = await stay.post(`/bookings/${world.booking.id}/confirm`, undefined, { token: world.guest.token }); if (world.api.status < 300) world.booking = world.api.body; }); }
Given('the booking is confirmed', { timeout: 30_000 }, async function () { await confirmBooking(this); });
Given('a confirmed booking', { timeout: 30_000 }, async function () { await holdBooking(this, {}); await confirmBooking(this); });
Given(/^a confirmed booking of room (\d+) starting (\d+) days out$/, { timeout: 30_000 }, async function (room, offset) { await holdBooking(this, { room: Number(room), nights: 2, offset: Number(offset) }); await confirmBooking(this); });

async function hotelierAction(world, action) { await act(world, async () => { world.api = await stay.post(`/bookings/${world.booking.id}/${action}`, undefined, { token: stay.seedHotelier }); if (world.api.status < 300) world.booking = world.api.body; }); }
Given('the booking is checked in', { timeout: 30_000 }, async function () { await hotelierAction(this, 'check-in'); });
Given('the booking is checked out', { timeout: 30_000 }, async function () { await hotelierAction(this, 'check-out'); });
Given('the booking is marked a no-show', { timeout: 30_000 }, async function () { await hotelierAction(this, 'no-show'); });
Given('the booking is cancelled', { timeout: 30_000 }, async function () { await act(this, async () => { this.api = await stay.post(`/bookings/${this.booking.id}/cancel`, undefined, { token: this.guest.token }); if (this.api.status < 300) this.booking = this.api.body; }); });

Given('a hold that has already expired', { timeout: 30_000 }, async function () { await holdBooking(this, { room: 2, nights: 1, offset: 55, ttl: -1 }); });
Given('confirming the expired hold is attempted', { timeout: 30_000 }, async function () { await act(this, async () => { this.api = await stay.post(`/bookings/${this.booking.id}/confirm`, undefined, { token: this.guest.token }); if (this.api.status < 300) this.booking = this.api.body; }); });

Given(/^the scarce room is fully booked for (\d+) nights? starting (\d+) days out$/, { timeout: 30_000 }, async function (nights, offset) {
  await act(this, async () => {
    const g = await stay.newGuest();
    const range = futureRange(Number(offset), Number(nights));
    this.scarceRange = range;
    this.booking = await stay.hold(g.token, { room_type_id: 3, ...range });
    this.api = { status: 201, body: this.booking };
  });
});

// ---------------------------------------------------------------- schema (throwaway)

Then('the store has tables {}', async function (list) {
  const want = list.split(/,\s*/);
  await check(this, 'store has the documented tables', () => { const have = this.store.tables(); const missing = want.filter((t) => !have.includes(t)); return { passed: missing.length === 0, detail: missing.length ? 'missing ' + missing.join(', ') : have.length + ' tables' }; });
});

Given('a throwaway database with the schema applied', function () {
  this.tmp = throwaway();
  this.tmp.exec("INSERT INTO hotels (id, name, city, currency, tax_bps, active) VALUES (1, 'H', 'C', 'USD', 1000, 1)");
  this.tmp.exec("INSERT INTO room_types (id, hotel_id, name, nightly_rate_cents, capacity, inventory, cancellation) VALUES (1, 1, 'R', 10000, 2, 5, 'flexible')");
  this.tmp.exec("INSERT INTO guests (id, name, token, created_at) VALUES (1, 'G', 'gtok', 1)");
  this.tmp.exec("INSERT INTO hoteliers (id, name, token, created_at) VALUES (1, 'HT', 'htok', 1)");
  this.tmp.exec("INSERT INTO hotel_owners (hotel_id, hotelier_id) VALUES (1, 1)");
  this.tmp.exec("INSERT INTO bookings (id, guest_id, hotel_id, room_type_id, check_in, check_out, nights, nightly_rate_cents, currency, base_cents, tax_cents, total_cents, cancellation, status, hold_expires_at, idempotency_key, created_at) VALUES (1, 1, 1, 1, 1000, 87400, 1, 10000, 'USD', 10000, 1000, 11000, 'flexible', 'held', 9999999999, NULL, 1)");
});
Given('a throwaway database with the schema and seed applied', function () {
  const fs = require('fs'); const path = require('path');
  this.tmp = throwaway();
  this.tmp.exec(fs.readFileSync(path.join(__dirname, '..', '..', '..', '..', 'services', 'mini-stay', 'db', 'seed.sql'), 'utf8'));
});

function fails(db, sql, params, re) {
  try { db.prepare(sql).run(...params); return { passed: false, detail: 'insert succeeded' }; } catch (err) { return { passed: re.test(err.message), detail: err.message }; }
}
const B = "INSERT INTO bookings (guest_id, hotel_id, room_type_id, check_in, check_out, nights, nightly_rate_cents, currency, base_cents, tax_cents, total_cents, cancellation, status, hold_expires_at, created_at) VALUES ";
Then('inserting a room type with zero capacity fails a CHECK', function () { this.observe('capacity > 0', () => fails(this.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory) VALUES (1, 'X', 100, 0, 1)", [], /CHECK constraint failed/)); });
Then('inserting a room type with negative inventory fails a CHECK', function () { this.observe('inventory >= 0', () => fails(this.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory) VALUES (1, 'X', 100, 2, -1)", [], /CHECK constraint failed/)); });
Then('inserting a room type for a missing hotel fails a FOREIGN KEY', function () { this.observe('room_types.hotel_id FK', () => fails(this.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory) VALUES (999, 'X', 100, 2, 1)", [], /FOREIGN KEY constraint failed/)); });
Then('inserting a booking for a missing guest fails a FOREIGN KEY', function () { this.observe('bookings.guest_id FK', () => fails(this.tmp, B + "(999, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 1)", [], /FOREIGN KEY constraint failed/)); });
Then('inserting a booking for a missing room type fails a FOREIGN KEY', function () { this.observe('bookings.room_type_id FK', () => fails(this.tmp, B + "(1, 1, 999, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 1)", [], /FOREIGN KEY constraint failed/)); });
Then('inserting a booking event for a missing booking fails a FOREIGN KEY', function () { this.observe('booking_events.booking_id FK', () => fails(this.tmp, "INSERT INTO booking_events (booking_id, from_status, to_status, actor, created_at) VALUES (999, NULL, 'held', 'guest', 1)", [], /FOREIGN KEY constraint failed/)); });
Then('inserting a room type with a negative nightly rate fails a CHECK', function () { this.observe('nightly_rate_cents >= 0', () => fails(this.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory) VALUES (1, 'X', -1, 2, 1)", [], /CHECK constraint failed/)); });
Then('inserting a booking with a negative total fails a CHECK', function () { this.observe('total_cents >= 0', () => fails(this.tmp, B + "(1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, -1, 'flexible', 'held', 1, 1)", [], /CHECK constraint failed/)); });
Then('inserting a booking with negative tax fails a CHECK', function () { this.observe('tax_cents >= 0', () => fails(this.tmp, B + "(1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, -1, 100, 'flexible', 'held', 1, 1)", [], /CHECK constraint failed/)); });
Then('inserting a booking whose check-out is before its check-in fails a CHECK', function () { this.observe('check_out > check_in', () => fails(this.tmp, B + "(1, 1, 1, 87400, 1000, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 1)", [], /CHECK constraint failed/)); });
Then('inserting a booking with zero nights fails a CHECK', function () { this.observe('nights > 0', () => fails(this.tmp, B + "(1, 1, 1, 1000, 87400, 0, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 1)", [], /CHECK constraint failed/)); });
Then('inserting a booking with status {string} fails a CHECK', function (status) { this.observe('booking status CHECK', () => fails(this.tmp, B + "(1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', ?, 1, 1)", [status], /CHECK constraint failed/)); });
Then('inserting a booking event with actor {string} fails a CHECK', function (actor) { this.observe('booking_events actor CHECK', () => fails(this.tmp, "INSERT INTO booking_events (booking_id, from_status, to_status, actor, created_at) VALUES (1, NULL, ?, ?, 1)", ['held', actor], /CHECK constraint failed/)); });
Then('inserting a room type with cancellation {string} fails a CHECK', function (policy) { this.observe('cancellation CHECK', () => fails(this.tmp, "INSERT INTO room_types (hotel_id, name, nightly_rate_cents, capacity, inventory, cancellation) VALUES (1, 'X', 100, 2, 1, ?)", [policy], /CHECK constraint failed/)); });
Then('inserting a ledger row with zero delta fails a CHECK', function () { this.observe('ledger delta <> 0', () => fails(this.tmp, "INSERT INTO ledger (party_type, party_id, delta_cents, reason, booking_id, created_at) VALUES ('hotel', 1, 0, 'payment', 1, 1)", [], /CHECK constraint failed/)); });
Then('inserting a ledger row with reason {string} fails a CHECK', function (reason) { this.observe('ledger reason CHECK', () => fails(this.tmp, "INSERT INTO ledger (party_type, party_id, delta_cents, reason, booking_id, created_at) VALUES (?, 1, 10, ?, 1, 1)", ['hotel', reason], /CHECK constraint failed/)); });
Then('inserting a ledger row with party type {string} fails a CHECK', function (party) { this.observe('ledger party_type CHECK', () => fails(this.tmp, "INSERT INTO ledger (party_type, party_id, delta_cents, reason, booking_id, created_at) VALUES (?, 1, 10, ?, 1, 1)", [party, 'payment'], /CHECK constraint failed/)); });
Then('inserting a hotel with a negative tax rate fails a CHECK', function () { this.observe('tax_bps >= 0', () => fails(this.tmp, "INSERT INTO hotels (id, name, city, currency, tax_bps, active) VALUES (2, 'Z', 'C', 'USD', -1, 1)", [], /CHECK constraint failed/)); });
Then('inserting two bookings with the same idempotency key fails on the second', function () {
  this.observe('idempotency_key UNIQUE', () => {
    const a = fails(this.tmp, "INSERT INTO bookings (guest_id, hotel_id, room_type_id, check_in, check_out, nights, nightly_rate_cents, currency, base_cents, tax_cents, total_cents, cancellation, status, hold_expires_at, idempotency_key, created_at) VALUES (1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 'K', 1)", [], /never/);
    if (a.detail !== 'insert succeeded') return { passed: false, detail: 'first: ' + a.detail };
    return fails(this.tmp, "INSERT INTO bookings (guest_id, hotel_id, room_type_id, check_in, check_out, nights, nightly_rate_cents, currency, base_cents, tax_cents, total_cents, cancellation, status, hold_expires_at, idempotency_key, created_at) VALUES (1, 1, 1, 1000, 87400, 1, 100, 'USD', 100, 0, 100, 'flexible', 'held', 1, 'K', 1)", [], /UNIQUE constraint failed/);
  });
});
Then('applying the seed again changes no row counts', function () {
  const fs = require('fs'); const path = require('path');
  this.observe('seed idempotent', () => {
    const tables = ['hotels', 'room_types', 'guests', 'hoteliers', 'hotel_owners'];
    const before = tables.map((t) => this.tmp.prepare('SELECT COUNT(*) AS n FROM ' + t).get().n);
    this.tmp.exec(fs.readFileSync(path.join(__dirname, '..', '..', '..', '..', 'services', 'mini-stay', 'db', 'seed.sql'), 'utf8'));
    const after = tables.map((t) => this.tmp.prepare('SELECT COUNT(*) AS n FROM ' + t).get().n);
    return { passed: j(before) === j(after), detail: 'before ' + j(before) + ', after ' + j(after) };
  });
});

// ---------------------------------------------------------------- booking rows

Then('the booking row is held', async function () { await bookingStatusRow(this, 'held'); });
Then('the booking row is confirmed', async function () { await bookingStatusRow(this, 'confirmed'); });
Then('the booking row is cancelled', async function () { await bookingStatusRow(this, 'cancelled'); });
Then('the booking row is expired', async function () { await bookingStatusRow(this, 'expired'); });
Then('the booking row is no_show', async function () { await bookingStatusRow(this, 'no_show'); });
async function bookingStatusRow(world, status) {
  await check(world, 'booking status row ' + status, () => { const b = world.store.get('SELECT status FROM bookings WHERE id = ?', world.booking.id); return { passed: !!b && b.status === status, detail: b ? b.status : 'no booking' }; });
}
Then('the booking total row equals its base plus tax', async function () {
  await check(this, 'total == base + tax', () => { const b = this.store.get('SELECT * FROM bookings WHERE id = ?', this.booking.id); return { passed: b.total_cents === b.base_cents + b.tax_cents, detail: `base ${b.base_cents} + tax ${b.tax_cents} = ${b.total_cents}` }; });
});
Then('the booking\'s first event moves to held by the guest', async function () {
  await check(this, 'first event held by guest', () => { const e = this.store.events(this.booking.id)[0]; return { passed: !!e && e.from_status === null && e.to_status === 'held' && e.actor === 'guest', detail: e ? `${e.from_status}->${e.to_status} by ${e.actor}` : 'no events' }; });
});
Then('the booking row snapshots the room\'s nightly rate and cancellation policy', async function () {
  await check(this, 'booking snapshots rate + policy', () => { const b = this.store.get('SELECT * FROM bookings WHERE id = ?', this.booking.id); const r = this.store.get('SELECT nightly_rate_cents, cancellation FROM room_types WHERE id = ?', b.room_type_id); return { passed: b.nightly_rate_cents === r.nightly_rate_cents && b.cancellation === r.cancellation, detail: `booking ${b.nightly_rate_cents}/${b.cancellation}, room ${r.nightly_rate_cents}/${r.cancellation}` }; });
});
Then('the booking hold expiry is after its creation time', async function () {
  await check(this, 'hold_expires_at > created_at', () => { const b = this.store.get('SELECT hold_expires_at, created_at FROM bookings WHERE id = ?', this.booking.id); return { passed: b.hold_expires_at > b.created_at, detail: `created ${b.created_at}, expires ${b.hold_expires_at}` }; });
});
Then('a booking event records held to confirmed by the guest', async function () { await eventRecords(this, 'held', 'confirmed', 'guest'); });
Then('a booking event records confirmed to cancelled by the guest', async function () { await eventRecords(this, 'confirmed', 'cancelled', 'guest'); });
Then('a booking event records confirmed to no_show by the hotelier', async function () { await eventRecords(this, 'confirmed', 'no_show', 'hotelier'); });
async function eventRecords(world, from, to, actor) {
  await check(world, `event ${from}->${to} by ${actor}`, () => { const e = world.store.events(world.booking.id).find((x) => x.from_status === from && x.to_status === to); return { passed: !!e && e.actor === actor, detail: e ? `by ${e.actor}` : 'no such event' }; });
}
Then('a payment ledger row for the booking equals its total', async function () {
  await check(this, 'payment ledger == total', () => { const b = this.store.get('SELECT total_cents FROM bookings WHERE id = ?', this.booking.id); const row = this.store.ledger(this.booking.id).find((l) => l.reason === 'payment'); return { passed: !!row && row.delta_cents === b.total_cents, detail: row ? `ledger ${row.delta_cents}, total ${b.total_cents}` : 'no payment row' }; });
});
Then('the booking has no ledger rows', async function () {
  await check(this, 'no ledger rows', () => { const n = this.store.ledger(this.booking.id).length; return { passed: n === 0, detail: n + ' ledger rows' }; });
});
Then('the booking has no refund ledger rows', async function () {
  await check(this, 'no refund rows', () => { const n = this.store.ledger(this.booking.id).filter((l) => l.reason === 'refund').length; return { passed: n === 0, detail: n + ' refund rows' }; });
});
Then('a refund ledger row for the booking is a debit', async function () {
  await check(this, 'refund ledger < 0', () => { const row = this.store.ledger(this.booking.id).find((l) => l.reason === 'refund'); return { passed: !!row && row.delta_cents < 0, detail: row ? 'refund ' + row.delta_cents : 'no refund row' }; });
});
Then('the booking has exactly one payment ledger row', async function () {
  await check(this, 'exactly one payment row', () => { const n = this.store.ledger(this.booking.id).filter((l) => l.reason === 'payment').length; return { passed: n === 1, detail: n + ' payment rows' }; });
});
Then('the booking\'s events run held, confirmed, checked_in, checked_out', async function () {
  await check(this, 'lifecycle events in order', () => { const seq = this.store.events(this.booking.id).map((e) => e.to_status); return { passed: j(seq) === j(['held', 'confirmed', 'checked_in', 'checked_out']), detail: seq.join(' -> ') }; });
});

// ---------------------------------------------------------------- inventory invariant

Then('each night of the booking shows one room of that type occupied', async function () {
  await check(this, 'one room occupied each night', () => {
    const b = this.store.get('SELECT * FROM bookings WHERE id = ?', this.booking.id);
    const bad = [];
    for (let d = b.check_in; d < b.check_out; d += DAY) { const n = occupied(this.store, b.room_type_id, d); if (n < 1) bad.push(`night ${d}: ${n}`); }
    return { passed: bad.length === 0, detail: bad.length ? bad.join(', ') : b.nights + ' nights each occupied' };
  });
});
Then('no night shows that room occupied beyond its inventory', async function () {
  await check(this, 'occupied <= inventory', () => {
    const r = this.store.get('SELECT inventory FROM room_types WHERE id = 3');
    const bad = [];
    for (let d = this.scarceRange.check_in; d < this.scarceRange.check_out; d += DAY) { const n = occupied(this.store, 3, d); if (n > r.inventory) bad.push(`night ${d}: ${n} > ${r.inventory}`); }
    return { passed: bad.length === 0, detail: bad.length ? bad.join(', ') : 'within inventory' };
  });
});
Then('a further hold on that room and night is refused', async function () {
  await check(this, 'further hold refused', async () => { const g = await stay.newGuest(); const r = await stay.post('/bookings', { room_type_id: 3, ...this.scarceRange }, { token: g.token }); return { passed: r.status === 409 && r.body && r.body.code === 'sold_out', detail: r.status + ' ' + j(r.body) }; });
});
Then('no room of that type is occupied on that night', async function () {
  await check(this, 'room freed after cancel', () => { const b = this.store.get('SELECT * FROM bookings WHERE id = ?', this.booking.id); const n = occupied(this.store, b.room_type_id, b.check_in); return { passed: n === 0, detail: n + ' occupied' }; });
});

// ---------------------------------------------------------------- integrity

Then('no bookings row references a guest missing from guests', async function () {
  await check(this, 'no orphan booking->guest', () => { const n = this.store.count('bookings b', 'WHERE NOT EXISTS (SELECT 1 FROM guests g WHERE g.id = b.guest_id)'); return { passed: n === 0, detail: n + ' orphans' }; });
});
Then('no bookings row references a room type missing from room_types', async function () {
  await check(this, 'no orphan booking->room', () => { const n = this.store.count('bookings b', 'WHERE NOT EXISTS (SELECT 1 FROM room_types r WHERE r.id = b.room_type_id)'); return { passed: n === 0, detail: n + ' orphans' }; });
});
