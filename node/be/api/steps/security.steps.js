'use strict';

const { Given, When, Then } = require('@cucumber/cucumber');
const { MiniStay, ApiUnreachable, futureRange } = require('../venues/stay');
const { DbUnreachable } = require('../../db/store');

/**
 * Steps for features/be-mini-stay-security.feature. These probe the API's
 * authorization boundaries -- no token, a forged token, the wrong party, a
 * booking or hotel that is not yours. Most setup Givens (a held/confirmed
 * booking, a guest) and lifecycle Whens are shared from the other @stay steps;
 * only the adversarial requests and the secret-hygiene assertions are new.
 */

const stay = new MiniStay();
const FORGED = 'gst_forged000000000000000000';

async function send(world, method, path, opts = {}) {
  if (world.sourceError) return;
  try { world.api = await stay.request(method, path, opts); } catch (err) { if (err instanceof ApiUnreachable) { world.sourceError = err.message; return; } throw err; }
}
function check(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  const r = fn(); world.check(description, r.passed, r.detail);
}
const j = (v) => JSON.stringify(v);
function leaksToken(obj, adminToken) {
  const text = j(obj || {});
  return /"(gst|htl)_[A-Za-z0-9_-]{8,}"/.test(text) || text.includes('"' + adminToken + '"');
}

// ---------------------------------------------------------------- cross-party setup

Given('another guest has a booking', { timeout: 30_000 }, async function () {
  if (this.sourceError) return;
  try {
    const owner = await stay.newGuest('Owner');
    const b = await stay.hold(owner.token, { room_type_id: 1, ...futureRange(220, 2) });
    this.ownerBookingId = b.id;
    this.guest = await stay.newGuest('Snoop');   // the attacker
  } catch (err) { if (err instanceof ApiUnreachable || err instanceof DbUnreachable) { this.sourceError = err.message; return; } throw err; }
});
Given('a priced quote', { timeout: 30_000 }, async function () { await send(this, 'POST', '/quotes', { body: { room_type_id: 1, ...futureRange(30, 2) } }); this.quote = this.api && this.api.body; });

// ---------------------------------------------------------------- adversarial requests

When('a room is held with no token', async function () { await send(this, 'POST', '/bookings', { body: { room_type_id: 1, ...futureRange(230, 2) } }); });
When('a room is held with a forged token', async function () { await send(this, 'POST', '/bookings', { token: FORGED, body: { room_type_id: 1, ...futureRange(231, 2) } }); });
When('a hotelier tries to hold a room', async function () { await send(this, 'POST', '/bookings', { token: stay.seedHotelier, body: { room_type_id: 1, ...futureRange(232, 2) } }); });
When('the guest reads that booking', async function () { await send(this, 'GET', '/bookings/' + this.ownerBookingId, { token: this.guest.token }); });
When('the guest cancels that booking', async function () { await send(this, 'POST', '/bookings/' + this.ownerBookingId + '/cancel', { token: this.guest.token }); });
When('the guest confirms that booking', async function () { await send(this, 'POST', '/bookings/' + this.ownerBookingId + '/confirm', { token: this.guest.token }); });
When('a hotelier who owns no hotel checks the booking in', async function () { const other = await stay.newHotelier('Nobody'); await send(this, 'POST', '/bookings/' + this.booking.id + '/check-in', { token: other.token }); });
When('the overview is read with the guest\'s token', async function () { await send(this, 'GET', '/admin/overview', { token: this.guest.token }); });
When('the admin booking list is read with the guest\'s token', async function () { await send(this, 'GET', '/admin/bookings', { token: this.guest.token }); });
When('the overview is read with a token that extends the admin token', async function () { await send(this, 'GET', '/admin/overview', { token: stay.adminToken + 'x' }); });
When('a guest registers', async function () { await send(this, 'POST', '/guests', { body: { name: 'Sec Guest' } }); });
When('the admin reads the overview', async function () { await send(this, 'GET', '/admin/overview', { token: stay.adminToken }); });

// ---------------------------------------------------------------- generic assertions

Then('the response status is {int}', function (status) {
  check(this, 'response status ' + status, () => ({ passed: !!this.api && this.api.status === status, detail: this.api ? this.api.status + ' ' + j(this.api.body) : 'no response' }));
});
Then('the response is an error with code {string}', function (code) {
  check(this, 'error code ' + code, () => ({ passed: !!this.api && this.api.body && this.api.body.code === code, detail: this.api && this.api.body ? j(this.api.body) : 'no body' }));
});
Then('the response carries a token', function () {
  check(this, 'response carries a token', () => { const t = (this.api && this.api.body || {}).token; return { passed: typeof t === 'string' && t.length > 0, detail: 'token ' + (t ? 'present' : 'absent') }; });
});

// ---------------------------------------------------------------- secret hygiene

Then('the quote response carries no bearer token', function () { check(this, 'quote body has no token', () => ({ passed: !leaksToken(this.quote, stay.adminToken), detail: leaksToken(this.quote, stay.adminToken) ? 'TOKEN LEAKED' : 'clean' })); });
Then('the booking response carries no bearer token', function () { check(this, 'booking body has no token', () => ({ passed: !leaksToken(this.booking, stay.adminToken), detail: leaksToken(this.booking, stay.adminToken) ? 'TOKEN LEAKED' : 'clean' })); });
Then('the read response carries no bearer token', function () { check(this, 'read body has no token', () => ({ passed: !leaksToken(this.api && this.api.body, stay.adminToken), detail: leaksToken(this.api && this.api.body, stay.adminToken) ? 'TOKEN LEAKED' : 'clean' })); });
Then('the overview response carries no bearer token', function () { check(this, 'overview body has no token', () => ({ passed: !leaksToken(this.api && this.api.body, stay.adminToken), detail: leaksToken(this.api && this.api.body, stay.adminToken) ? 'TOKEN LEAKED' : 'clean' })); });
