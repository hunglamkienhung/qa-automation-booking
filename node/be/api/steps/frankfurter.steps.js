'use strict';

const { When, Then } = require('@cucumber/cucumber');
const fx = require('../venues/frankfurter');

/**
 * Steps for features/be-frankfurter-api.feature. The convert steps are pure and
 * deterministic -- they never touch the network, so they always grade. The live
 * steps read Frankfurter; a transport failure sets sourceError and grades
 * Blocked. One step converts a real stay total at a real historical rate, so the
 * multi-currency path is checked end to end.
 */

async function live(world, fn) {
  if (world.sourceError) return undefined;
  try { return await fn(); } catch (err) { if (err instanceof fx.FxUnreachable) { world.sourceError = err.message; return undefined; } throw err; }
}
function check(world, description, fn) {
  if (world.sourceError) { world.unobservable(description, 'the source could not be reached -- ' + world.sourceError); return; }
  const r = fn(); world.check(description, r.passed, r.detail);
}
const j = (v) => JSON.stringify(v);

// ---------------------------------------------------------------- pure conversion

When('the conversion of {int} cents at rate {float} is computed', function (cents, rate) { this.converted = fx.convert(cents, rate); });
When('the conversion of {int} cents at rate {float} is noted', function (cents, rate) { this.notedConv = fx.convert(cents, rate); });
Then('the conversion is {int}', function (out) { this.check('conversion == ' + out, this.converted === out, 'converted ' + this.converted); });
Then('the conversion is at least the noted conversion', function () { this.check('conversion did not fall', this.converted >= this.notedConv, `noted ${this.notedConv}, new ${this.converted}`); });

// ---------------------------------------------------------------- live historical

When('the historical rates are fetched', { timeout: 30_000 }, async function () { await live(this, async () => { this.hist = (await fx.historical()).body; }); });
When('the historical rates are fetched again', { timeout: 30_000 }, async function () { await live(this, async () => { this.hist2 = (await fx.historical()).body; }); });
When('a stay total of {int} is converted at the historical euro rate', function (total) { if (this.sourceError) return; this.stayTotal = total; this.stayRate = this.hist.rates.EUR; this.stayConverted = fx.convert(total, this.stayRate); });
When('a stay total of {int} is converted at the historical pound rate', function (total) { if (this.sourceError) return; this.stayTotal = total; this.stayRate = this.hist.rates.GBP; this.stayConverted = fx.convert(total, this.stayRate); });

Then('the historical response carries a rates object', function () { check(this, 'historical has rates', () => { const r = this.hist && this.hist.rates; return { passed: !!r && typeof r === 'object' && Object.keys(r).length > 0, detail: r ? j(r) : 'no rates' }; }); });
Then('the historical response is one unit of US dollars', function () { check(this, 'historical amount 1 base USD', () => ({ passed: !!this.hist && this.hist.amount === 1 && this.hist.base === 'USD', detail: this.hist ? `amount ${this.hist.amount}, base ${this.hist.base}` : 'no response' })); });
Then('the historical euro rate is a positive number', function () { check(this, 'historical EUR > 0', () => { const v = this.hist && this.hist.rates && this.hist.rates.EUR; return { passed: fx.isFiniteNumber(v) && v > 0, detail: 'EUR ' + v }; }); });
Then('the historical pound rate is a positive number', function () { check(this, 'historical GBP > 0', () => { const v = this.hist && this.hist.rates && this.hist.rates.GBP; return { passed: fx.isFiniteNumber(v) && v > 0, detail: 'GBP ' + v }; }); });
Then('both historical reads return identical rates', function () { check(this, 'historical stable across reads', () => ({ passed: j(this.hist.rates) === j(this.hist2.rates), detail: 'a ' + j(this.hist.rates) + ' b ' + j(this.hist2.rates) })); });
Then('the converted stay is positive and equals the pure conversion', function () { check(this, 'converted stay positive and consistent', () => ({ passed: this.stayConverted > 0 && this.stayConverted === fx.convert(this.stayTotal, this.stayRate), detail: `converted ${this.stayConverted} at rate ${this.stayRate}` })); });

// ---------------------------------------------------------------- live latest

When('the latest rates are fetched', { timeout: 30_000 }, async function () { await live(this, async () => { this.latest = (await fx.latest()).body; }); });
Then('the latest response carries a rates object', function () { check(this, 'latest has rates', () => { const r = this.latest && this.latest.rates; return { passed: !!r && typeof r === 'object' && Object.keys(r).length > 0, detail: r ? j(r) : 'no rates' }; }); });
Then('the latest euro rate is a positive finite number', function () { check(this, 'latest EUR positive finite', () => { const v = this.latest && this.latest.rates && this.latest.rates.EUR; return { passed: fx.isFiniteNumber(v) && v > 0, detail: 'EUR ' + v }; }); });
Then('the latest response names a date', function () { check(this, 'latest has a date', () => ({ passed: !!this.latest && typeof this.latest.date === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(this.latest.date), detail: this.latest ? this.latest.date : 'no response' })); });
Then('every latest rate is a positive number', function () { check(this, 'latest rates all positive', () => { const r = (this.latest && this.latest.rates) || {}; const bad = Object.entries(r).filter(([, v]) => !fx.isFiniteNumber(v) || v <= 0); return { passed: Object.keys(r).length > 0 && bad.length === 0, detail: bad.length ? 'bad ' + j(bad) : j(r) }; }); });
Then('the latest response is one unit of US dollars', function () { check(this, 'latest amount 1 base USD', () => ({ passed: !!this.latest && this.latest.amount === 1 && this.latest.base === 'USD', detail: this.latest ? `amount ${this.latest.amount}, base ${this.latest.base}` : 'no response' })); });
