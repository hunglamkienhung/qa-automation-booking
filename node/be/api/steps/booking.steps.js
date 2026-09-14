'use strict';

const { When, Then } = require('@cucumber/cucumber');
const { MiniStay, ApiUnreachable, futureRange, DAY } = require('../venues/stay');

/**
 * Steps for features/be-mini-stay-booking.feature. The cancellation refund is
 * recomputed here from the room's policy and how many whole days ahead the
 * cancellation is -- the same integer arithmetic the service uses -- so the
 * assertion is an independent witness. The generic "refused with code/status"
 * steps live in pricing.steps.js.
 */

const stay = new MiniStay();
const roundBps = (amount, bps) => Math.floor((amount * bps + 5000) / 10000);
function refundBps(cancellation, daysBefore) {
  if (cancellation === 'nonrefundable') return 0;
  if (cancellation === 'flexible') return daysBefore >= 1 ? 10000 : 0;
  if (daysBefore >= 7) return 10000;
  if (daysBefore >= 1) return 5000;
  return 0;
}

async function act(world, fn) {
  if (world.sourceError) return undefined;
  try { return await fn(); } catch (err) { if (err instanceof ApiUnreachable) { world.sourceError = err.message; return undefined; } throw err; }
}
function check(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  const r = fn(); world.check(description, r.passed, r.detail);
}
const j = (v) => JSON.stringify(v);
const now = () => Math.floor(Date.now() / 1000);

async function holdAction(world, room, nights, offset, key, token) {
  const range = futureRange(offset, nights);
  const body = { room_type_id: room, ...range };
  if (key) body.idempotency_key = key;
  world.lastHoldReq = body;
  await act(world, async () => { world.api = await stay.post('/bookings', body, token ? { token } : {}); if (world.api.status === 201 || world.api.status === 200) world.booking = world.api.body; });
}

When('the guest holds room {int} for {int} nights {int} days out', async function (room, nights, offset) { await holdAction(this, room, nights, offset, null, this.guest.token); });
When('the guest holds room {int} for {int} nights with key {string}', async function (room, nights, key) { await holdAction(this, room, nights, 210, key, this.guest.token); this.firstHold = this.api; });
When('the guest holds again with key {string}', async function (key) { await act(this, async () => { this.api = await stay.post('/bookings', { ...this.lastHoldReq, idempotency_key: key }, { token: this.guest.token }); if (this.api.status < 300) this.booking = this.api.body; }); this.secondHold = this.api; });
When('an anonymous caller holds room {int} for {int} nights', async function (room, nights) { await holdAction(this, room, nights, 210, null, null); });

When('the guest confirms the booking', async function () { await act(this, async () => { this.api = await stay.post(`/bookings/${this.booking.id}/confirm`, undefined, { token: this.guest.token }); if (this.api.status < 300) this.booking = this.api.body; }); });
When('the guest cancels the booking', async function () { await act(this, async () => { this.api = await stay.post(`/bookings/${this.booking.id}/cancel`, undefined, { token: this.guest.token }); if (this.api.status < 300) this.booking = this.api.body; }); });
When('the guest tries to check the booking in', async function () { await act(this, async () => { this.api = await stay.post(`/bookings/${this.booking.id}/check-in`, undefined, { token: this.guest.token }); }); });
When('the hotelier checks the booking in', async function () { await hotelier(this, 'check-in'); });
When('the hotelier checks the booking out', async function () { await hotelier(this, 'check-out'); });
When('the hotelier marks the booking a no-show', async function () { await hotelier(this, 'no-show'); });
async function hotelier(world, action) { await act(world, async () => { world.api = await stay.post(`/bookings/${world.booking.id}/${action}`, undefined, { token: stay.seedHotelier }); if (world.api.status < 300) world.booking = world.api.body; }); }

When('the guest reads the booking', async function () { await act(this, async () => { this.api = await stay.get('/bookings/' + this.booking.id, { token: this.guest.token }); }); });
When('the guest lists their bookings', async function () { await act(this, async () => { this.api = await stay.get('/bookings', { token: this.guest.token }); }); });

Then('the booking response is {word}', function (status) {
  check(this, 'booking status ' + status, () => ({ passed: !!this.booking && this.booking.status === status, detail: this.booking ? this.booking.status : (this.api ? this.api.status + ' ' + j(this.api.body) : 'no response') }));
});
Then('both holds return the same booking', function () {
  check(this, 'idempotent hold returns same booking', () => { const a = this.firstHold && this.firstHold.body, b = this.secondHold && this.secondHold.body; return { passed: !!a && !!b && a.id === b.id, detail: `first ${a && a.id}, second ${b && b.id}` }; });
});
Then('the booking reads back held with at least one event', function () {
  check(this, 'booking reads held with events', () => { const b = this.api && this.api.body; return { passed: !!b && b.status === 'held' && Array.isArray(b.events) && b.events.length >= 1, detail: b ? `${b.status}, ${b.events ? b.events.length : 0} events` : 'no body' }; });
});
Then('the booking list includes this booking', function () {
  check(this, 'booking list includes this booking', () => { const bs = this.api && this.api.body && this.api.body.bookings; return { passed: Array.isArray(bs) && bs.some((x) => x.id === this.booking.id), detail: bs ? bs.map((x) => x.id).join(',') : 'no list' }; });
});
Then('the refund matches the cancellation policy', function () {
  check(this, 'refund == policy formula', () => {
    const b = this.api && this.api.body; if (!b) return { passed: false, detail: 'no response' };
    const daysBefore = Math.floor((this.booking.check_in - now()) / DAY);
    const want = roundBps(this.booking.total_cents, refundBps(this.booking.cancellation, daysBefore));
    return { passed: b.refund_cents === want, detail: `refund ${b.refund_cents}, expected ${want} (policy ${this.booking.cancellation}, ${daysBefore}d before, total ${this.booking.total_cents})` };
  });
});
Then('the refund is {int}', function (amount) {
  check(this, 'refund is ' + amount, () => { const b = this.api && this.api.body; return { passed: !!b && b.refund_cents === amount, detail: b ? 'refund ' + b.refund_cents : 'no response' }; });
});
