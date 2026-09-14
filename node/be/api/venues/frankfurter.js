'use strict';

/**
 * Frankfurter's public FX API: frankfurter.dev. No key, read-only, ECB
 * reference rates.
 *
 * Two shapes are used. A historical date (`/v1/<date>`) returns settled rates
 * that never change, so those are asserted by value and compared across two
 * reads. The latest endpoint (`/v1/latest`) moves with the market, so it is
 * asserted on shape and plausible range only.
 *
 * A transport failure, a 5xx/429, or a non-JSON body is FxUnreachable, which
 * grades Blocked: the rate service being unreachable is not a rate being wrong.
 *
 * `convert` is a pure function -- the QA-side derivation that turns a price in
 * one currency into another at a given rate, in whole cents with explicit
 * half-up rounding. It takes no network, so the scenarios that exercise it are
 * deterministic; the live tier feeds a real historical rate through it.
 */

const BASE = (process.env.FRANKFURTER_URL || 'https://api.frankfurter.dev/v1').replace(/\/+$/, '');
const TIMEOUT_MS = 25_000;

// A settled historical day and a fixed pair set, so the API answers the same
// values on every read.
const HIST_DATE = '2024-01-02';
const HIST_BASE = 'USD';
const HIST_SYMBOLS = 'EUR,GBP';

class FxUnreachable extends Error {}

async function request(path, params) {
  const url = BASE + path + (params ? '?' + new URLSearchParams(params).toString() : '');
  const init = { method: 'GET', headers: { accept: 'application/json' }, signal: AbortSignal.timeout(TIMEOUT_MS) };
  let res;
  try { res = await fetch(url, init); } catch (err) { throw new FxUnreachable('GET ' + path + ' -- ' + (err.cause && err.cause.code ? err.cause.code : (err.name || err.message))); }
  const text = await res.text();
  if (res.status >= 500 || res.status === 429) throw new FxUnreachable('GET ' + path + ' -- HTTP ' + res.status);
  let body; try { body = JSON.parse(text); } catch { body = null; }
  if (body === null || typeof body !== 'object') throw new FxUnreachable('GET ' + path + ' -- expected JSON, got ' + text.slice(0, 40).replace(/\s+/g, ' ') + '…');
  return { httpStatus: res.status, body };
}

const historical = (opts = {}) => request('/' + (opts.date || HIST_DATE), { base: opts.base || HIST_BASE, symbols: opts.symbols || HIST_SYMBOLS });
const latest = (opts = {}) => request('/latest', { base: opts.base || 'USD', symbols: opts.symbols || 'EUR,GBP,JPY' });

/** Convert an integer-cent amount at a rate, half-up to whole cents. Pure. */
function convert(amountCents, rate) { return Math.floor(amountCents * rate + 0.5); }

const isFiniteNumber = (v) => typeof v === 'number' && Number.isFinite(v);

module.exports = { BASE, HIST_DATE, HIST_BASE, HIST_SYMBOLS, FxUnreachable, request, historical, latest, convert, isFiniteNumber };
