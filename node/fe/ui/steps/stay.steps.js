'use strict';

const { Given, When, Then } = require('@cucumber/cucumber');
const { StayPage, ScreenNotReady } = require('../pages/stay');
const { MiniStay, ApiUnreachable } = require('../../../be/api/venues/stay');

/**
 * Steps for features/fe-mini-stay.feature -- the only steps in this domain that
 * drive a browser. The comparison figures come from the store (this.store,
 * opened by the @stay Before hook) and the rows, so the FE branch checks the
 * pages against the same data the BE branch reads. The booking-setup Givens (a
 * held / confirmed booking) are shared from the be steps.
 */

const stay = new MiniStay();
const fmt = (cents, currency) => currency + ' ' + (cents / 100).toFixed(2);

Given('the home page is open', { timeout: 90_000 }, async function () {
  this.stayPage = new StayPage(this.page);
  await this.fetchOrBlock([ScreenNotReady], async () => { await this.stayPage.open('/'); this.screen.hotels = await this.stayPage.hotels(); });
});
Given('the booking reaches {word}', { timeout: 30_000 }, async function (state) {
  if (this.sourceError) return;
  try {
    if (state === 'confirmed') { this.api = await stay.post(`/bookings/${this.booking.id}/confirm`, undefined, { token: this.guest.token }); }
    else if (state === 'cancelled') { this.api = await stay.post(`/bookings/${this.booking.id}/cancel`, undefined, { token: this.guest.token }); }
    if (this.api && this.api.status < 300) this.booking = this.api.body;
  } catch (err) { if (err instanceof ApiUnreachable) { this.sourceError = err.message; return; } throw err; }
});

async function screen(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  let r;
  try { r = await fn(); } catch (err) { if (err instanceof ScreenNotReady || err instanceof ApiUnreachable) { world.unobservable(description, err.message); return; } throw err; }
  world.check(description, r.passed, r.detail);
}
const activeHotels = (world) => world.store.all('SELECT * FROM hotels WHERE active = 1 ORDER BY id');

// ---------------------------------------------------------------- navigation

When('the hotel page for hotel {int} is opened', { timeout: 90_000 }, async function (id) { await this.fetchOrBlock([ScreenNotReady], async () => { await this.stayPage.open('/hotel/' + id); this.screen.rooms = await this.stayPage.rooms().catch(() => null); this.screen.hotelId = id; }); });
When('the booking page is opened', { timeout: 90_000 }, async function () { await this.fetchOrBlock([ScreenNotReady], async () => { await this.stayPage.open('/booking/' + this.booking.id); this.screen.booking = await this.stayPage.booking().catch(() => null); }); });
When('the booking page for {int} is opened', { timeout: 90_000 }, async function (id) { await this.fetchOrBlock([ScreenNotReady], async () => { await this.stayPage.open('/booking/' + id); this.screen.booking = await this.stayPage.booking().catch(() => null); }); });
When('the guest\'s booking list is opened', { timeout: 90_000 }, async function () { await this.fetchOrBlock([ScreenNotReady], async () => { await this.stayPage.open('/guest/' + this.guest.id + '/bookings'); this.screen.bookings = await this.stayPage.guestBookings().catch(() => null); }); });
When('the admin page is opened', { timeout: 90_000 }, async function () { await this.fetchOrBlock([ScreenNotReady], async () => { await this.stayPage.open('/admin'); this.screen.admin = await this.stayPage.admin().catch(() => null); }); });

// ---------------------------------------------------------------- home

Then('the home page lists the active hotels, once each', async function () {
  await screen(this, 'home == active hotels', async () => { const ids = this.screen.hotels.map((h) => h.id).sort((a, b) => a - b); const want = activeHotels(this).map((h) => h.id); return { passed: JSON.stringify(ids) === JSON.stringify(want), detail: `screen ${JSON.stringify(ids)}, active ${JSON.stringify(want)}` }; });
});
Then('the home page does not list the inactive hotel', async function () {
  await screen(this, 'home excludes inactive', async () => ({ passed: !this.screen.hotels.some((h) => h.id === 3), detail: 'ids ' + this.screen.hotels.map((h) => h.id).join(',') }));
});
Then('every hotel row shows a three-letter currency code', async function () {
  await screen(this, 'hotel rows show currency', async () => { const bad = this.screen.hotels.filter((h) => !/^[A-Z]{3}$/.test(h.currency)); return { passed: bad.length === 0 && this.screen.hotels.length > 0, detail: bad.length ? JSON.stringify(bad.slice(0, 2)) : this.screen.hotels.map((h) => h.currency).join(',') }; });
});
Then('the home page shows at least one hotel', async function () {
  await screen(this, 'home non-empty', async () => ({ passed: this.screen.hotels.length > 0, detail: this.screen.hotels.length + ' hotels' }));
});

// ---------------------------------------------------------------- hotel rooms

Then('every room name on screen equals the room row', async function () {
  await screen(this, 'room names == rows', async () => { if (!this.screen.rooms) return { passed: false, detail: 'no rooms' }; const bad = this.screen.rooms.filter((m) => { const row = this.store.get('SELECT name FROM room_types WHERE id = ?', m.id); return !row || m.name !== row.name; }); return { passed: bad.length === 0 && this.screen.rooms.length > 0, detail: bad.length ? JSON.stringify(bad.slice(0, 2)) : this.screen.rooms.length + ' rooms' }; });
});
Then('every room rate on screen equals the room row in the hotel\'s currency', async function () {
  await screen(this, 'room rates == rows', async () => { if (!this.screen.rooms) return { passed: false, detail: 'no rooms' }; const hotel = this.store.get('SELECT currency FROM hotels WHERE id = ?', this.screen.hotelId); const bad = this.screen.rooms.filter((m) => { const row = this.store.get('SELECT nightly_rate_cents FROM room_types WHERE id = ?', m.id); return !row || m.rateText !== fmt(row.nightly_rate_cents, hotel.currency); }); return { passed: bad.length === 0, detail: bad.length ? JSON.stringify(bad.slice(0, 2)) : 'rates match ' + hotel.currency }; });
});
Then('every room shows its inventory and cancellation policy from the rows', async function () {
  await screen(this, 'room inventory + policy == rows', async () => { if (!this.screen.rooms) return { passed: false, detail: 'no rooms' }; const bad = this.screen.rooms.filter((m) => { const row = this.store.get('SELECT inventory, cancellation FROM room_types WHERE id = ?', m.id); return !row || m.inventoryText !== String(row.inventory) || m.cancellationText !== row.cancellation; }); return { passed: bad.length === 0, detail: bad.length ? JSON.stringify(bad.slice(0, 2)) : 'match' }; });
});
Then('the page reports not found', async function () {
  await screen(this, 'page not found', async () => { const txt = await this.page.textContent('body'); return { passed: /no such/i.test(txt), detail: txt.slice(0, 60) }; });
});

// ---------------------------------------------------------------- booking page

Then('the booking page total equals the stored total', async function () {
  await screen(this, 'booking page total == stored', async () => { const b = this.screen.booking; const row = this.store.get('SELECT total_cents, currency FROM bookings WHERE id = ?', this.booking.id); return { passed: !!b && b.totalText === fmt(row.total_cents, row.currency), detail: b ? b.totalText + ' vs ' + fmt(row.total_cents, row.currency) : 'no page' }; });
});
Then('the booking page shows the nights from the row', async function () {
  await screen(this, 'booking page nights == stored', async () => { const b = this.screen.booking; const row = this.store.get('SELECT nights FROM bookings WHERE id = ?', this.booking.id); return { passed: !!b && b.nightsText === String(row.nights), detail: b ? b.nightsText + ' vs ' + row.nights : 'no page' }; });
});
Then('the booking page shows status {string}', async function (status) {
  await screen(this, 'booking page status ' + status, async () => ({ passed: !!this.screen.booking && this.screen.booking.statusText === status, detail: this.screen.booking ? this.screen.booking.statusText : 'no page' }));
});
Then('the booking page total is shown as a currency amount', async function () {
  await screen(this, 'booking total format', async () => ({ passed: !!this.screen.booking && /^[A-Z]{3} \d+\.\d{2}$/.test(this.screen.booking.totalText), detail: this.screen.booking ? this.screen.booking.totalText : 'no page' }));
});

// ---------------------------------------------------------------- guest bookings

Then('the guest\'s booking list includes the held booking', async function () {
  await screen(this, 'booking list includes held', async () => { const ids = (this.screen.bookings || []).map((b) => b.id); return { passed: ids.includes(this.booking.id), detail: 'ids ' + ids.join(',') }; });
});
Then('each booking row links to its booking page', async function () {
  await screen(this, 'booking rows link', async () => { const bad = (this.screen.bookings || []).filter((b) => b.href !== '/booking/' + b.id); return { passed: bad.length === 0 && (this.screen.bookings || []).length > 0, detail: bad.length ? JSON.stringify(bad.slice(0, 2)) : (this.screen.bookings || []).length + ' links' }; });
});
Then('every booking row total is a currency amount', async function () {
  await screen(this, 'booking row totals are currency', async () => { const bad = (this.screen.bookings || []).filter((b) => !/^[A-Z]{3} \d+\.\d{2}$/.test(b.totalText)); return { passed: bad.length === 0 && (this.screen.bookings || []).length > 0, detail: bad.length ? bad.map((b) => b.totalText).join(',') : 'all currency amounts' }; });
});

// ---------------------------------------------------------------- admin

Then('the admin payment is shown as a number', async function () {
  await screen(this, 'admin payment format', async () => ({ passed: !!this.screen.admin && /^\d+\.\d{2}$/.test(this.screen.admin.paymentText), detail: this.screen.admin ? this.screen.admin.paymentText : 'no page' }));
});
Then('every admin status count is a non-negative integer', async function () {
  await screen(this, 'admin counts are non-negative ints', async () => { const counts = (this.screen.admin && this.screen.admin.counts) || []; const bad = counts.filter((c) => !/^\d+$/.test(c.n) || Number(c.n) < 0); return { passed: bad.length === 0 && counts.length > 0, detail: bad.length ? JSON.stringify(bad) : counts.length + ' counts' }; });
});
Then('the admin counts include a confirmed booking', async function () {
  await screen(this, 'admin counts include confirmed', async () => { const row = (this.screen.admin && this.screen.admin.counts || []).find((c) => c.status === 'confirmed'); return { passed: !!row && Number(row.n) >= 1, detail: row ? 'confirmed ' + row.n : 'no confirmed count' }; });
});
