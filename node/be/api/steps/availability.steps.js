'use strict';

const { Given, When, Then } = require('@cucumber/cucumber');
const { MiniStay, ApiUnreachable, futureRange, DAY } = require('../venues/stay');

/**
 * Steps for features/be-mini-stay-availability.feature -- the overbooking and
 * concurrency invariant. Each scenario claims a fresh future night (a
 * monotonic offset) so it never contends with another; the race steps fire N
 * holds at once with Promise.all and assert exactly as many succeed as the room
 * has in stock. The generic "refused with code/status" steps live in
 * pricing.steps.js.
 */

const stay = new MiniStay();
let AV = 0;
const freshOffset = () => 600 + (AV++) * 10;   // spaced so windows and shifts never overlap the next scenario

async function act(world, fn) {
  if (world.sourceError) return undefined;
  try { return await fn(); } catch (err) { if (err instanceof ApiUnreachable) { world.sourceError = err.message; return undefined; } throw err; }
}
function check(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  const r = fn(); world.check(description, r.passed, r.detail);
}
const j = (v) => JSON.stringify(v);

function freshWindow(world, room, nights) {
  world.avRoom = room; world.avNights = nights; world.avOffset = freshOffset();
  world.avRange = futureRange(world.avOffset, nights);
  world.heldList = [];
}
Given('a fresh night for the scarce room', function () { freshWindow(this, 3, 1); });
Given('a fresh night for room {int}', function (room) { freshWindow(this, room, 1); });
Given('a fresh {int}-night window for the scarce room', function (nights) { freshWindow(this, 3, nights); });

async function holdOnce(world, room, range) {
  return act(world, async () => { const g = await stay.newGuest('racer'); world.api = await stay.post('/bookings', { room_type_id: room, ...range }, { token: g.token }); if (world.api.status === 201) world.heldList.push({ id: world.api.body.id, token: g.token }); return world.api; });
}
Given('the scarce room is held for that window', async function () { await holdOnce(this, this.avRoom, this.avRange); });
Given('the scarce room is held and confirmed for that window', async function () {
  await act(this, async () => { const g = await stay.newGuest(); const b = await stay.hold(g.token, { room_type_id: this.avRoom, ...this.avRange }); await stay.post(`/bookings/${b.id}/confirm`, undefined, { token: g.token }); this.heldList.push({ id: b.id, token: g.token }); });
});
Given('the scarce room is held for that window with a hold that expires at once', async function () {
  await act(this, async () => { const g = await stay.newGuest(); this.api = await stay.post('/bookings', { room_type_id: this.avRoom, ...this.avRange, hold_ttl_seconds: -1 }, { token: g.token }); });
});
Given('that hold is cancelled', async function () { await act(this, async () => { const h = this.heldList[0]; this.api = await stay.post(`/bookings/${h.id}/cancel`, undefined, { token: h.token }); }); });
Given('the room is held {int} times for that window', async function (k) { for (let i = 0; i < k; i++) await holdOnce(this, this.avRoom, this.avRange); });
Given('one of those holds is cancelled', async function () { await act(this, async () => { const h = this.heldList[0]; this.api = await stay.post(`/bookings/${h.id}/cancel`, undefined, { token: h.token }); }); });

When('the availability for that window is read', async function () { await act(this, async () => { this.api = await stay.get(`/rooms/${this.avRoom}/availability?check_in=${this.avRange.check_in}&check_out=${this.avRange.check_out}`); }); });
When('the availability for a zero-night window is read', async function () { await act(this, async () => { this.api = await stay.get(`/rooms/${this.avRoom}/availability?check_in=${this.avRange.check_in}&check_out=${this.avRange.check_in}`); }); });
When('the availability of room {int} for a fresh night is read', async function (room) { const r = futureRange(freshOffset(), 1); await act(this, async () => { this.api = await stay.get(`/rooms/${room}/availability?check_in=${r.check_in}&check_out=${r.check_out}`); }); });

When('another guest holds the scarce room for that window', async function () { await holdOnce(this, this.avRoom, this.avRange); });
When('another guest holds that room for that window', async function () { await holdOnce(this, this.avRoom, this.avRange); });
When('the scarce room is held for that window again', async function () { await holdOnce(this, this.avRoom, this.avRange); });
When('a guest holds the scarce room shifted one night later', async function () { await holdOnce(this, this.avRoom, futureRange(this.avOffset + 1, this.avNights)); });
When('a guest holds the scarce room shifted two nights later', async function () { await holdOnce(this, this.avRoom, futureRange(this.avOffset + 2, this.avNights)); });
When('a guest holds the scarce room for the two nights immediately after', async function () { await holdOnce(this, this.avRoom, futureRange(this.avOffset + this.avNights, 2)); });

async function race(world, room, range, n) {
  await act(world, async () => {
    const guests = await Promise.all(Array.from({ length: n }, () => stay.newGuest('racer')));
    const results = await Promise.all(guests.map((g) => stay.post('/bookings', { room_type_id: room, ...range }, { token: g.token })));
    world.raceStatuses = results.map((r) => r.status);
  });
}
When('{int} guests hold the scarce room for that window at once', async function (n) { await race(this, this.avRoom, this.avRange, n); });
When('{int} guests hold that room for that window at once', async function (n) { await race(this, this.avRoom, this.avRange, n); });

Then('the availability is {int}', function (n) {
  check(this, 'availability ' + n, () => ({ passed: !!this.api && this.api.body && this.api.body.available === n, detail: this.api && this.api.body ? 'available ' + this.api.body.available : (this.api ? this.api.status + ' ' + j(this.api.body) : 'no response') }));
});
Then('the hold succeeds', function () {
  check(this, 'hold succeeds', () => ({ passed: !!this.api && this.api.status === 201, detail: this.api ? this.api.status + ' ' + j(this.api.body) : 'no response' }));
});
Then('exactly {int} holds succeed and the rest are sold out', function (k) {
  check(this, `exactly ${k} of the race win`, () => {
    const s = this.raceStatuses || [];
    const ok = s.filter((x) => x === 201).length; const conflict = s.filter((x) => x === 409).length;
    return { passed: ok === k && conflict === s.length - k, detail: `${ok} x 201, ${conflict} x 409 of ${s.length}` };
  });
});
Then('exactly {int} hold succeeds and the rest are sold out', function (k) {
  check(this, `exactly ${k} of the race wins`, () => {
    const s = this.raceStatuses || [];
    const ok = s.filter((x) => x === 201).length; const conflict = s.filter((x) => x === 409).length;
    return { passed: ok === k && conflict === s.length - k, detail: `${ok} x 201, ${conflict} x 409 of ${s.length}` };
  });
});
