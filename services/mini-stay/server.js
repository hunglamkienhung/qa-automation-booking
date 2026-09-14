#!/usr/bin/env node
'use strict';

const http = require('http');
const path = require('path');
const { URL } = require('url');
const { open } = require('./lib/db');
const H = require('./lib/http');

/**
 * mini-stay: a small hotel-booking backend over one SQLite file. Node standard
 * library only. It serves search, pricing, holds, the stay lifecycle and
 * cancellation over one REST API, plus small labelled HTML pages for Playwright.
 *
 * The thing a booking system must never do is sell the same room twice for the
 * same night. Availability is checked and the booking inserted inside one
 * IMMEDIATE transaction, so concurrent requests for the last room serialise and
 * exactly one wins. A booking runs a state machine (held -> confirmed ->
 * checked_in -> checked_out, with cancelled/expired/no_show as exits), each
 * transition gated by the actor and the current status and written to
 * booking_events. Money is integer cents: a stay is nights x nightly rate plus
 * an integer-bps tax, and a cancellation refunds a policy-and-timing-dependent
 * fraction, posted to a ledger.
 */

const cfg = {
  port: Number(process.env.MINI_STAY_PORT || 8150),
  dbFile: process.env.MINI_STAY_DB || path.join(__dirname, 'data', 'mini-stay.db'),
  adminToken: process.env.MINI_STAY_ADMIN_TOKEN || 'admin-token',
};
const DAY = 86400;
const HOLD_TTL = Number(process.env.MINI_STAY_HOLD_TTL || 900);   // seconds a hold lives by default

const now = () => Math.floor(Date.now() / 1000);
const fmt = (cents, currency) => currency + ' ' + (cents / 100).toFixed(2);

function json(res, status, body, extra = {}) { res.writeHead(status, { 'content-type': 'application/json; charset=utf-8', ...extra }); res.end(JSON.stringify(body)); }
function html(res, status, body) { res.writeHead(status, { 'content-type': 'text/html; charset=utf-8' }); res.end('<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">' + body); }
function esc(s) { return String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c])); }
function readBody(req) {
  return new Promise((resolve, reject) => {
    let d = '';
    req.on('data', (c) => { d += c; if (d.length > 65536) reject(new H.ApiError(413, 'too_large', 'body too large')); });
    req.on('end', () => { try { resolve(d ? JSON.parse(d) : {}); } catch { reject(new H.ApiError(400, 'bad_request', 'body is not JSON')); } });
  });
}

// ---- pricing: integer cents, integer-bps tax, half-up rounding ----
const roundBps = (amount, bps) => Math.floor((amount * bps + 5000) / 10000);   // half-up amount*bps/10000
/** refund fraction (bps) for a cancellation policy given whole days before check-in. */
function refundBps(cancellation, daysBefore) {
  if (cancellation === 'nonrefundable') return 0;
  if (cancellation === 'flexible') return daysBefore >= 1 ? 10000 : 0;
  // moderate
  if (daysBefore >= 7) return 10000;
  if (daysBefore >= 1) return 5000;
  return 0;
}

// booking lifecycle: action -> { from, to, actor }
const TRANSITIONS = {
  confirm: { from: 'held', to: 'confirmed', actor: 'guest' },
  'check-in': { from: 'confirmed', to: 'checked_in', actor: 'hotelier' },
  'check-out': { from: 'checked_in', to: 'checked_out', actor: 'hotelier' },
  'no-show': { from: 'confirmed', to: 'no_show', actor: 'hotelier' },
};
const OCCUPYING = "(status IN ('confirmed','checked_in','checked_out') OR (status = 'held' AND hold_expires_at > ?))";

function main() {
  const db = open(cfg.dbFile);
  const q = {
    hotels: db.prepare('SELECT * FROM hotels WHERE active = 1 ORDER BY id'),
    hotel: db.prepare('SELECT * FROM hotels WHERE id = ?'),
    rooms: db.prepare('SELECT * FROM room_types WHERE hotel_id = ? ORDER BY id'),
    room: db.prepare('SELECT * FROM room_types WHERE id = ?'),
    ownerOf: db.prepare('SELECT hotelier_id FROM hotel_owners WHERE hotel_id = ?'),

    insGuest: db.prepare('INSERT INTO guests (name, token, created_at) VALUES (?, ?, ?)'),
    guestByToken: db.prepare('SELECT * FROM guests WHERE token = ?'),
    guest: db.prepare('SELECT * FROM guests WHERE id = ?'),
    insHotelier: db.prepare('INSERT INTO hoteliers (name, token, created_at) VALUES (?, ?, ?)'),
    hotelierByToken: db.prepare('SELECT * FROM hoteliers WHERE token = ?'),

    insBooking: db.prepare('INSERT INTO bookings (guest_id, hotel_id, room_type_id, check_in, check_out, nights, nightly_rate_cents, currency, base_cents, tax_cents, total_cents, cancellation, status, hold_expires_at, idempotency_key, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'held\', ?, ?, ?)'),
    booking: db.prepare('SELECT * FROM bookings WHERE id = ?'),
    bookingByKey: db.prepare('SELECT * FROM bookings WHERE idempotency_key = ?'),
    bookingsByGuest: db.prepare('SELECT * FROM bookings WHERE guest_id = ? ORDER BY id'),
    bookingsByHotel: db.prepare('SELECT * FROM bookings WHERE hotel_id = ? ORDER BY id'),
    allBookings: db.prepare('SELECT * FROM bookings ORDER BY id'),
    setStatus: db.prepare('UPDATE bookings SET status = ? WHERE id = ?'),
    setStatusRefund: db.prepare('UPDATE bookings SET status = ?, refund_cents = ? WHERE id = ?'),
    occupiedOnNight: db.prepare('SELECT COUNT(*) AS n FROM bookings WHERE room_type_id = ? AND check_in <= ? AND check_out > ? AND ' + OCCUPYING),
    insEvent: db.prepare('INSERT INTO booking_events (booking_id, from_status, to_status, actor, created_at) VALUES (?, ?, ?, ?, ?)'),
    events: db.prepare('SELECT * FROM booking_events WHERE booking_id = ? ORDER BY id'),
    insLedger: db.prepare('INSERT INTO ledger (party_type, party_id, delta_cents, reason, booking_id, created_at) VALUES (?, ?, ?, ?, ?, ?)'),
    statusCounts: db.prepare('SELECT status, COUNT(*) AS n FROM bookings GROUP BY status'),
    ledgerBy: db.prepare("SELECT COALESCE(SUM(delta_cents),0) AS s FROM ledger WHERE reason = ?"),
  };

  const tx = (fn) => { db.exec('BEGIN IMMEDIATE'); try { const r = fn(); db.exec('COMMIT'); return r; } catch (e) { db.exec('ROLLBACK'); throw e; } };

  function bearer(req) { const m = /^Bearer\s+(\S+)$/i.exec(req.headers.authorization || ''); return m ? m[1] : null; }
  function requireGuest(req) { const g = q.guestByToken.get(bearer(req) || ''); if (!g) throw new H.ApiError(401, 'unauthenticated', 'a guest Bearer token is required'); return g; }
  function requireHotelier(req) { const h = q.hotelierByToken.get(bearer(req) || ''); if (!h) throw new H.ApiError(401, 'unauthenticated', 'a hotelier Bearer token is required'); return h; }
  function isAdmin(req) { return bearer(req) === cfg.adminToken; }
  function requireAdmin(req) { if (!isAdmin(req)) throw new H.ApiError(401, 'unauthenticated', 'the admin token is required'); }
  /** The hotelier that owns this hotel must be the caller (or the admin). 401 if unauthenticated, 403 if the wrong hotelier. */
  function requireHotelOwner(req, hotelId) {
    if (isAdmin(req)) return null;
    const h = requireHotelier(req);
    const o = q.ownerOf.get(Number(hotelId));
    if (!o || o.hotelier_id !== h.id) throw new H.ApiError(403, 'forbidden', 'this hotel is not yours');
    return h;
  }

  const roomView = (r) => ({ id: r.id, hotel_id: r.hotel_id, name: r.name, nightly_rate_cents: r.nightly_rate_cents, capacity: r.capacity, inventory: r.inventory, cancellation: r.cancellation });
  const bookingView = (b) => ({ id: b.id, guest_id: b.guest_id, hotel_id: b.hotel_id, room_type_id: b.room_type_id, check_in: b.check_in, check_out: b.check_out, nights: b.nights, nightly_rate_cents: b.nightly_rate_cents, currency: b.currency, base_cents: b.base_cents, tax_cents: b.tax_cents, total_cents: b.total_cents, cancellation: b.cancellation, status: b.status, hold_expires_at: b.hold_expires_at, refund_cents: b.refund_cents });

  /** Price a stay from a room type and a date range. Returns the money and the derived nights, or throws a 4xx. */
  function price(room, checkIn, checkOut) {
    if (!Number.isInteger(checkIn) || !Number.isInteger(checkOut)) throw new H.ApiError(400, 'bad_request', 'check_in and check_out are unix seconds');
    if (checkOut <= checkIn) throw new H.ApiError(422, 'bad_dates', 'check_out must be after check_in');
    const span = checkOut - checkIn;
    if (span % DAY !== 0) throw new H.ApiError(422, 'bad_dates', 'dates must be whole nights apart');
    const nights = span / DAY;
    const hotel = q.hotel.get(room.hotel_id);
    const base = nights * room.nightly_rate_cents;
    const tax = roundBps(base, hotel.tax_bps);
    return { nights, hotel, base, tax, total: base + tax };
  }
  /** Rooms of this type free for every night of [checkIn, checkOut). Excludes expired holds. */
  function roomsAvailable(room, checkIn, checkOut, atSec) {
    let minFree = room.inventory;
    for (let d = checkIn; d < checkOut; d += DAY) {
      const occupied = q.occupiedOnNight.get(room.id, d, d, atSec).n;
      minFree = Math.min(minFree, room.inventory - occupied);
    }
    return minFree;
  }

  function transition(booking, action) {
    const t = TRANSITIONS[action];
    if (booking.status !== t.from) throw new H.ApiError(409, 'bad_state', `cannot ${action} a booking that is ${booking.status}`, { status: booking.status });
    q.setStatus.run(t.to, booking.id);
    q.insEvent.run(booking.id, t.from, t.to, t.actor, now());
  }

  async function route(req, res, url) {
    const parts = url.pathname.replace(/\/+$/, '').split('/').filter(Boolean);
    const [a, b, c] = parts;

    // ---- app screens (HTML) ----
    if (req.method === 'GET' && parts.length === 0) return renderHome(res);
    if (req.method === 'GET' && a === 'hotel' && b && !c) return renderHotel(res, b);
    if (req.method === 'GET' && a === 'booking' && b) return renderBooking(res, b);
    if (req.method === 'GET' && a === 'guest' && b && c === 'bookings') return renderGuestBookings(res, b);
    if (req.method === 'GET' && a === 'admin' && !b) return renderAdmin(res);

    // ---- health ----
    if (req.method === 'GET' && a === 'health') return json(res, 200, { ok: true, hotels: q.hotels.all().length, bookings: q.allBookings.all().length, ts: now() });

    // ---- onboarding ----
    if (req.method === 'POST' && a === 'guests' && !b) { const body = await readBody(req); const tok = H.token('gst'); const info = q.insGuest.run(String(body.name || 'Guest'), tok, now()); return json(res, 201, { id: Number(info.lastInsertRowid), token: tok }); }
    if (req.method === 'POST' && a === 'hoteliers' && !b) { const body = await readBody(req); const tok = H.token('htl'); const info = q.insHotelier.run(String(body.name || 'Hotelier'), tok, now()); return json(res, 201, { id: Number(info.lastInsertRowid), token: tok }); }

    // ---- search ----
    if (req.method === 'GET' && a === 'hotels' && !b) return json(res, 200, { hotels: q.hotels.all().map((h) => ({ id: h.id, name: h.name, city: h.city, currency: h.currency, tax_bps: h.tax_bps })) });
    if (req.method === 'GET' && a === 'hotels' && b && c === 'rooms') { const h = q.hotel.get(Number(b)); if (!h || !h.active) throw new H.ApiError(404, 'not_found', 'no such hotel'); return json(res, 200, { hotel_id: h.id, currency: h.currency, rooms: q.rooms.all(h.id).map(roomView) }); }
    if (req.method === 'GET' && a === 'hotels' && b && c === 'bookings') { requireHotelOwner(req, b); return json(res, 200, { hotel_id: Number(b), bookings: q.bookingsByHotel.all(Number(b)).map(bookingView) }); }

    // ---- pricing ----
    if (req.method === 'POST' && a === 'quotes' && !b) {
      const body = await readBody(req);
      const room = q.room.get(Number(body.room_type_id));
      if (!room) throw new H.ApiError(404, 'not_found', 'no such room type');
      const hotel = q.hotel.get(room.hotel_id);
      if (!hotel.active) throw new H.ApiError(409, 'hotel_inactive', 'this hotel is not taking bookings');
      const p = price(room, Number(body.check_in), Number(body.check_out));
      return json(res, 200, { room_type_id: room.id, hotel_id: hotel.id, currency: hotel.currency, nights: p.nights, nightly_rate_cents: room.nightly_rate_cents, base_cents: p.base, tax_cents: p.tax, total_cents: p.total, tax_bps: hotel.tax_bps, cancellation: room.cancellation });
    }

    // ---- availability ----
    if (req.method === 'GET' && a === 'rooms' && b && c === 'availability') {
      const room = q.room.get(Number(b)); if (!room) throw new H.ApiError(404, 'not_found', 'no such room type');
      const ci = Number(url.searchParams.get('check_in')); const co = Number(url.searchParams.get('check_out'));
      if (!Number.isInteger(ci) || !Number.isInteger(co) || co <= ci || (co - ci) % DAY !== 0) throw new H.ApiError(422, 'bad_dates', 'check_in/check_out must be whole nights apart');
      const free = roomsAvailable(room, ci, co, now());
      return json(res, 200, { room_type_id: room.id, inventory: room.inventory, available: Math.max(0, free) });
    }

    // ---- bookings ----
    if (req.method === 'POST' && a === 'bookings' && !b) {
      const guest = requireGuest(req); const body = await readBody(req);
      const key = body.idempotency_key ? String(body.idempotency_key) : null;
      if (key) { const prior = q.bookingByKey.get(key); if (prior) return json(res, 200, { ...bookingView(prior), idempotent_replay: true }); }
      const room = q.room.get(Number(body.room_type_id));
      if (!room) throw new H.ApiError(404, 'not_found', 'no such room type');
      const hotel = q.hotel.get(room.hotel_id);
      if (!hotel.active) throw new H.ApiError(409, 'hotel_inactive', 'this hotel is not taking bookings');
      const checkIn = Number(body.check_in); const checkOut = Number(body.check_out);
      const p = price(room, checkIn, checkOut);
      const ttl = Number.isInteger(Number(body.hold_ttl_seconds)) ? Number(body.hold_ttl_seconds) : HOLD_TTL;
      const id = tx(() => {
        const at = now();
        if (roomsAvailable(room, checkIn, checkOut, at) < 1) throw new H.ApiError(409, 'sold_out', 'no room of this type is free for those nights');
        const info = q.insBooking.run(guest.id, hotel.id, room.id, checkIn, checkOut, p.nights, room.nightly_rate_cents, hotel.currency, p.base, p.tax, p.total, room.cancellation, at + ttl, key, at);
        const bid = Number(info.lastInsertRowid);
        q.insEvent.run(bid, null, 'held', 'guest', at);
        return bid;
      });
      return json(res, 201, bookingView(q.booking.get(id)));
    }
    if (req.method === 'GET' && a === 'bookings' && !b) { const guest = requireGuest(req); return json(res, 200, { bookings: q.bookingsByGuest.all(guest.id).map(bookingView) }); }
    if (req.method === 'GET' && a === 'bookings' && b && !c) {
      const booking = q.booking.get(Number(b));
      if (!booking) throw new H.ApiError(404, 'not_found', 'no such booking');
      if (!isAdmin(req)) { const tok = bearer(req); const g = tok && q.guestByToken.get(tok); const htl = tok && q.hotelierByToken.get(tok); const owns = htl && (q.ownerOf.get(booking.hotel_id) || {}).hotelier_id === htl.id; if (!owns && (!g || g.id !== booking.guest_id)) throw new H.ApiError(404, 'not_found', 'no such booking'); }
      return json(res, 200, { ...bookingView(booking), events: q.events.all(booking.id).map((e) => ({ from: e.from_status, to: e.to_status, actor: e.actor })) });
    }
    // guest actions: confirm, cancel
    if (req.method === 'POST' && a === 'bookings' && b && c === 'confirm') {
      const guest = requireGuest(req); const booking = q.booking.get(Number(b));
      if (!booking || booking.guest_id !== guest.id) throw new H.ApiError(404, 'not_found', 'no such booking');
      if (booking.status !== 'held') throw new H.ApiError(409, 'bad_state', `cannot confirm a booking that is ${booking.status}`, { status: booking.status });
      if (now() > booking.hold_expires_at) { tx(() => { q.setStatus.run('expired', booking.id); q.insEvent.run(booking.id, 'held', 'expired', 'system', now()); }); throw new H.ApiError(409, 'hold_expired', 'the hold lapsed before it was confirmed'); }
      tx(() => { transition(booking, 'confirm'); q.insLedger.run('hotel', booking.hotel_id, booking.total_cents, 'payment', booking.id, now()); });
      return json(res, 200, bookingView(q.booking.get(booking.id)));
    }
    if (req.method === 'POST' && a === 'bookings' && b && c === 'cancel') {
      const guest = requireGuest(req); const booking = q.booking.get(Number(b));
      if (!booking || booking.guest_id !== guest.id) throw new H.ApiError(404, 'not_found', 'no such booking');
      if (booking.status !== 'held' && booking.status !== 'confirmed') throw new H.ApiError(409, 'bad_state', `cannot cancel a booking that is ${booking.status}`, { status: booking.status });
      const at = now(); const daysBefore = Math.floor((booking.check_in - at) / DAY);
      const wasPaid = booking.status === 'confirmed';
      const refund = wasPaid ? roundBps(booking.total_cents, refundBps(booking.cancellation, daysBefore)) : 0;
      tx(() => {
        q.setStatusRefund.run('cancelled', refund, booking.id);
        q.insEvent.run(booking.id, booking.status, 'cancelled', 'guest', at);
        if (refund > 0) q.insLedger.run('hotel', booking.hotel_id, -refund, 'refund', booking.id, at);
      });
      return json(res, 200, { ...bookingView(q.booking.get(booking.id)), refund_cents: refund });
    }
    // hotelier actions: check-in, check-out, no-show
    if (req.method === 'POST' && a === 'bookings' && b && c && ['check-in', 'check-out', 'no-show'].includes(c)) {
      const booking = q.booking.get(Number(b));
      if (!booking) throw new H.ApiError(404, 'not_found', 'no such booking');
      requireHotelOwner(req, booking.hotel_id);
      tx(() => transition(booking, c));
      return json(res, 200, bookingView(q.booking.get(booking.id)));
    }

    // ---- admin ----
    if (req.method === 'GET' && a === 'admin' && b === 'overview') {
      requireAdmin(req);
      const counts = {}; for (const r of q.statusCounts.all()) counts[r.status] = r.n;
      const payment = q.ledgerBy.get('payment').s; const refund = -q.ledgerBy.get('refund').s;
      return json(res, 200, { bookings_by_status: counts, payment_cents: payment, refund_cents: refund, net_cents: payment - refund });
    }
    if (req.method === 'GET' && a === 'admin' && b === 'bookings') { requireAdmin(req); return json(res, 200, { bookings: q.allBookings.all().map(bookingView) }); }

    if (['GET', 'POST', 'PATCH', 'DELETE'].includes(req.method)) throw new H.ApiError(404, 'not_found', 'no such route');
    throw new H.ApiError(405, 'method_not_allowed', 'method not allowed');
  }

  // ---- HTML renderers (labelled for Playwright) ----
  function renderHome(res) {
    const rows = q.hotels.all().map((h) => `<li class="hotel" data-id="${h.id}"><a href="/hotel/${h.id}">${esc(h.name)}</a> <span class="city">${esc(h.city)}</span> <span class="currency">${esc(h.currency)}</span></li>`).join('');
    return html(res, 200, `<title>mini-stay</title><h1>mini-stay</h1><nav class="apps"><a href="/admin">Admin</a></nav><ul class="hotels">${rows}</ul>`);
  }
  function renderHotel(res, id) {
    const h = q.hotel.get(Number(id)); if (!h) return html(res, 404, '<title>hotel</title><p>no such hotel</p>');
    const rows = q.rooms.all(h.id).map((r) => `<li class="room" data-id="${r.id}"><span class="name">${esc(r.name)}</span> <span class="rate">${fmt(r.nightly_rate_cents, h.currency)}</span> <span class="inventory">${r.inventory}</span> <span class="cancellation">${esc(r.cancellation)}</span></li>`).join('');
    return html(res, 200, `<title>${esc(h.name)}</title><h1 class="hotel-name">${esc(h.name)}</h1><p class="currency">${esc(h.currency)}</p><ul class="rooms">${rows}</ul>`);
  }
  function renderBooking(res, id) {
    const b = q.booking.get(Number(id)); if (!b) return html(res, 404, '<title>booking</title><p>no such booking</p>');
    return html(res, 200, `<title>booking ${b.id}</title><h1 class="booking-id">Booking ${b.id}</h1><p class="status">${esc(b.status)}</p><p class="nights">${b.nights}</p><p class="total">${fmt(b.total_cents, b.currency)}</p><p class="cancellation">${esc(b.cancellation)}</p>`);
  }
  function renderGuestBookings(res, id) {
    const g = q.guest.get(Number(id)); if (!g) return html(res, 404, '<title>bookings</title><p>no such guest</p>');
    const rows = q.bookingsByGuest.all(g.id).map((b) => `<li class="booking" data-id="${b.id}"><a href="/booking/${b.id}">Booking ${b.id}</a> <span class="status">${esc(b.status)}</span> <span class="total">${fmt(b.total_cents, b.currency)}</span></li>`).join('');
    return html(res, 200, `<title>${esc(g.name)} bookings</title><h1 class="guest">${esc(g.name)}</h1><ul class="bookings">${rows}</ul>`);
  }
  function renderAdmin(res) {
    const counts = {}; for (const r of q.statusCounts.all()) counts[r.status] = r.n;
    const rows = Object.entries(counts).map(([s, n]) => `<li class="count" data-status="${esc(s)}"><span class="s">${esc(s)}</span> <span class="n">${n}</span></li>`).join('');
    const payment = q.ledgerBy.get('payment').s;
    return html(res, 200, `<title>mini-stay admin</title><h1>Admin</h1><p class="payment">${(payment / 100).toFixed(2)}</p><ul class="counts">${rows}</ul>`);
  }

  const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://localhost');
    try { await route(req, res, url); }
    catch (err) { if (err instanceof H.ApiError) json(res, err.status, H.errorBody(err)); else { console.error(err); json(res, 500, { error: 'internal error', code: 'internal' }); } }
  });
  server.listen(cfg.port, '127.0.0.1', () => console.error(`mini-stay on http://127.0.0.1:${cfg.port}  db ${cfg.dbFile}`));
  const shutdown = () => { server.close(); db.close(); process.exit(0); };
  process.on('SIGINT', shutdown); process.on('SIGTERM', shutdown);
}

if (require.main === module) main();
module.exports = { cfg, roundBps, refundBps };
