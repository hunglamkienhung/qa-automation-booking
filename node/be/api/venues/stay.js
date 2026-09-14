'use strict';

/**
 * HTTP client for the mini-stay service. Node's built-in fetch; no library.
 *
 * A response is returned whole -- status, lower-cased headers, parsed body --
 * so a step can assert on any of them. Only a transport failure is
 * ApiUnreachable (grades Blocked); a 4xx/5xx is an answer, often the one under
 * test.
 *
 * The convenience methods drive the flows end to end -- price a stay, hold a
 * room, confirm and run it to checked_out -- so a step can set up whatever
 * lifecycle state it needs. `futureRange` builds a UTC-midnight night range far
 * enough out that a cancellation is always "in advance"; scenarios that must not
 * collide over inventory pass distinct offsets.
 */

const BASE = (process.env.MINI_STAY_URL || 'http://127.0.0.1:8150').replace(/\/+$/, '');
const ADMIN_TOKEN = process.env.MINI_STAY_ADMIN_TOKEN || 'admin-token';
const SEED_GUEST = 'gst_seed_aria';
const SEED_GUEST2 = 'gst_seed_bruno';
const SEED_HOTELIER = 'htl_seed_priya';
const DAY = 86400;

class ApiUnreachable extends Error {}

/** A night range starting `offsetDays` from today (UTC midnight), `nights` long. */
function futureRange(offsetDays, nights = 2) {
  const midnight = Math.floor(Date.now() / 1000 / DAY) * DAY;
  const checkIn = midnight + offsetDays * DAY;
  return { check_in: checkIn, check_out: checkIn + nights * DAY };
}

class MiniStay {
  constructor(base = BASE) { this.base = base; this.adminToken = ADMIN_TOKEN; this.seedGuest = SEED_GUEST; this.seedGuest2 = SEED_GUEST2; this.seedHotelier = SEED_HOTELIER; }

  async request(method, path, { token, body, headers = {} } = {}) {
    const h = { ...headers };
    if (token) h.authorization = 'Bearer ' + token;
    const init = { method, headers: h };
    if (body !== undefined) { h['content-type'] = 'application/json'; init.body = JSON.stringify(body); }
    let res;
    try { res = await fetch(this.base + path, init); } catch (err) {
      throw new ApiUnreachable('mini-stay at ' + this.base + ' did not answer ' + method + ' ' + path + ': ' + (err.cause && err.cause.message ? err.cause.message : err.message));
    }
    const text = await res.text();
    let parsed = null; try { parsed = text ? JSON.parse(text) : null; } catch { parsed = null; }
    return { status: res.status, headers: Object.fromEntries([...res.headers.entries()].map(([k, v]) => [k.toLowerCase(), v])), body: parsed, text };
  }
  get(p, o) { return this.request('GET', p, o); }
  post(p, body, o = {}) { return this.request('POST', p, { ...o, body }); }
  patch(p, body, o = {}) { return this.request('PATCH', p, { ...o, body }); }

  async newGuest(name = 'Guest') { const r = await this.post('/guests', { name }); if (r.status !== 201) throw new Error('create guest failed: HTTP ' + r.status + ' ' + r.text); return r.body; }
  async newHotelier(name = 'Hotelier') { const r = await this.post('/hoteliers', { name }); if (r.status !== 201) throw new Error('create hotelier failed: HTTP ' + r.status + ' ' + r.text); return r.body; }

  quote({ room_type_id = 1, check_in, check_out } = {}) { return this.post('/quotes', { room_type_id, check_in, check_out }); }

  /** Hold a room for a guest; returns the booking body (throws on a non-2xx). */
  async hold(guestToken, opts) {
    const r = await this.post('/bookings', opts, { token: guestToken });
    if (r.status !== 201 && r.status !== 200) throw new Error('hold failed: HTTP ' + r.status + ' ' + r.text);
    return r.body;
  }
  /** Hold and confirm; returns the confirmed booking body. */
  async book(guestToken, opts) {
    const b = await this.hold(guestToken, opts);
    const r = await this.post(`/bookings/${b.id}/confirm`, undefined, { token: guestToken });
    if (r.status !== 200) throw new Error('confirm failed: HTTP ' + r.status + ' ' + r.text);
    return r.body;
  }
}

module.exports = { MiniStay, ApiUnreachable, BASE, ADMIN_TOKEN, futureRange, DAY };
