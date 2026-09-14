'use strict';

const { When, Then } = require('@cucumber/cucumber');
const { MiniStay, ApiUnreachable, futureRange, DAY } = require('../venues/stay');

/**
 * Steps for features/be-mini-stay-pricing.feature. The "matches the pricing
 * formula" check recomputes the total client-side from the nightly rate and tax
 * the quote reports, in the same integer basis-point arithmetic the service uses
 * -- an independent witness of the price. The generic "refused with code/status"
 * steps live here and are shared across every @stay @api tier.
 */

const stay = new MiniStay();
const roundBps = (amount, bps) => Math.floor((amount * bps + 5000) / 10000);   // half-up amount*bps/10000

async function act(world, fn) {
  if (world.sourceError) return undefined;
  try { return await fn(); } catch (err) { if (err instanceof ApiUnreachable) { world.sourceError = err.message; return undefined; } throw err; }
}
function check(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  const r = fn(); world.check(description, r.passed, r.detail);
}
const j = (v) => JSON.stringify(v);

async function requestQuote(world, room, dates) {
  await act(world, async () => { world.api = await stay.post('/quotes', { room_type_id: room, ...dates }); world.quote = world.api.status === 200 ? world.api.body : null; });
}
When('I request a quote for room {int} for {int} nights', async function (room, nights) { await requestQuote(this, room, futureRange(30, nights)); });
When('I request a quote for room {int} with a zero-night stay', async function (room) { const r = futureRange(30, 1); await requestQuote(this, room, { check_in: r.check_in, check_out: r.check_in }); });
When('I request a quote for room {int} for half a night', async function (room) { const r = futureRange(30, 1); await requestQuote(this, room, { check_in: r.check_in, check_out: r.check_in + DAY / 2 }); });
When('I request a quote for room {int} with check-out before check-in', async function (room) { const r = futureRange(30, 1); await requestQuote(this, room, { check_in: r.check_in, check_out: r.check_in - DAY }); });

Then('the quote total is {int}', function (total) {
  check(this, 'quote total ' + total, () => ({ passed: !!this.quote && this.quote.total_cents === total, detail: this.quote ? 'total ' + this.quote.total_cents : (this.api ? this.api.status + ' ' + j(this.api.body) : 'no response') }));
});
Then('the quote total matches the pricing formula', function () {
  check(this, 'total == reference formula', () => {
    const q = this.quote; if (!q) return { passed: false, detail: this.api ? this.api.status + ' ' + j(this.api.body) : 'no quote' };
    const base = q.nights * q.nightly_rate_cents;
    const tax = roundBps(base, q.tax_bps);
    return { passed: q.total_cents === base + tax && q.base_cents === base && q.tax_cents === tax, detail: `service ${q.total_cents}, reference ${base + tax} (base ${base}, tax ${tax})` };
  });
});
Then('the quote is internally consistent', function () {
  check(this, 'quote internally consistent', () => {
    const q = this.quote; if (!q) return { passed: false, detail: 'no quote' };
    const base = q.nights * q.nightly_rate_cents;
    return { passed: q.base_cents === base && q.tax_cents === roundBps(base, q.tax_bps) && q.total_cents === q.base_cents + q.tax_cents, detail: j({ base: q.base_cents, tax: q.tax_cents, total: q.total_cents }) };
  });
});
Then('the quote shows the cancellation policy {string}', function (policy) {
  check(this, 'quote cancellation ' + policy, () => ({ passed: !!this.quote && this.quote.cancellation === policy, detail: this.quote ? this.quote.cancellation : 'no quote' }));
});
Then('the quote is for {int} nights', function (nights) {
  check(this, 'quote nights ' + nights, () => ({ passed: !!this.quote && this.quote.nights === nights, detail: this.quote ? 'nights ' + this.quote.nights : 'no quote' }));
});

// ---- generic refusals, shared across the @stay @api tiers ----
Then('the quote is refused with code {string}', function (code) { refusedCode(this, code); });
Then('the quote is refused with status {int}', function (status) { refusedStatus(this, status); });
Then('the request is refused with code {string}', function (code) { refusedCode(this, code); });
Then('the request is refused with status {int}', function (status) { refusedStatus(this, status); });
function refusedCode(world, code) {
  check(world, 'refused with code ' + code, () => ({ passed: !!world.api && world.api.status >= 400 && world.api.body && world.api.body.code === code, detail: world.api ? world.api.status + ' ' + j(world.api.body) : 'no response' }));
}
function refusedStatus(world, status) {
  check(world, 'refused with status ' + status, () => ({ passed: !!world.api && world.api.status === status, detail: world.api ? world.api.status + ' ' + j(world.api.body) : 'no response' }));
}
