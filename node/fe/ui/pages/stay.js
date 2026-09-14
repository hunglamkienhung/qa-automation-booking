'use strict';

/**
 * Page objects for the mini-stay app surfaces. The server renders small,
 * labelled HTML pages -- the hotel home, a hotel's rooms, a booking, a guest's
 * bookings and the admin overview. Each page object reads by label so the
 * assertions are about the booking product, not the markup. A page that never
 * loads (service down) surfaces as ScreenNotReady, which the steps turn into
 * Blocked.
 */

const BASE = (process.env.MINI_STAY_URL || 'http://127.0.0.1:8150').replace(/\/+$/, '');

class ScreenNotReady extends Error {}

class StayPage {
  constructor(page) { this.page = page; this.base = BASE; }

  async open(path) {
    try { await this.page.goto(this.base + path, { waitUntil: 'domcontentloaded', timeout: 15_000 }); }
    catch (err) { throw new ScreenNotReady('mini-stay page ' + path + ' did not load: ' + err.message); }
  }

  async hotels() {
    await this.page.waitForSelector('ul.hotels li.hotel', { timeout: 15_000 }).catch(() => { throw new ScreenNotReady('home never rendered'); });
    return this.page.$$eval('ul.hotels li.hotel', (els) => els.map((el) => ({
      id: Number(el.getAttribute('data-id')),
      name: el.querySelector('a') ? el.querySelector('a').textContent.trim() : '',
      href: el.querySelector('a') ? el.querySelector('a').getAttribute('href') : '',
      city: el.querySelector('.city') ? el.querySelector('.city').textContent.trim() : '',
      currency: el.querySelector('.currency') ? el.querySelector('.currency').textContent.trim() : '',
    })));
  }

  async rooms() {
    await this.page.waitForSelector('ul.rooms li.room', { timeout: 15_000 }).catch(() => { throw new ScreenNotReady('hotel page never rendered'); });
    return this.page.$$eval('ul.rooms li.room', (els) => els.map((el) => ({
      id: Number(el.getAttribute('data-id')),
      name: el.querySelector('.name') ? el.querySelector('.name').textContent.trim() : '',
      rateText: el.querySelector('.rate') ? el.querySelector('.rate').textContent.trim() : '',
      inventoryText: el.querySelector('.inventory') ? el.querySelector('.inventory').textContent.trim() : '',
      cancellationText: el.querySelector('.cancellation') ? el.querySelector('.cancellation').textContent.trim() : '',
    })));
  }

  async booking() {
    await this.page.waitForSelector('h1.booking-id', { timeout: 15_000 }).catch(() => { throw new ScreenNotReady('booking page never rendered'); });
    return {
      idText: await this.page.$eval('h1.booking-id', (e) => e.textContent.trim()),
      statusText: await this.page.$eval('.status', (e) => e.textContent.trim()),
      nightsText: await this.page.$eval('.nights', (e) => e.textContent.trim()),
      totalText: await this.page.$eval('.total', (e) => e.textContent.trim()),
    };
  }

  async guestBookings() {
    await this.page.waitForSelector('ul.bookings', { timeout: 15_000 }).catch(() => { throw new ScreenNotReady('guest bookings never rendered'); });
    return this.page.$$eval('ul.bookings li.booking', (els) => els.map((el) => ({
      id: Number(el.getAttribute('data-id')),
      href: el.querySelector('a') ? el.querySelector('a').getAttribute('href') : '',
      statusText: el.querySelector('.status') ? el.querySelector('.status').textContent.trim() : '',
      totalText: el.querySelector('.total') ? el.querySelector('.total').textContent.trim() : '',
    })));
  }

  async admin() {
    await this.page.waitForSelector('ul.counts', { timeout: 15_000 }).catch(() => { throw new ScreenNotReady('admin page never rendered'); });
    const paymentText = await this.page.$eval('.payment', (e) => e.textContent.trim());
    const counts = await this.page.$$eval('ul.counts li.count', (els) => els.map((el) => ({ status: el.getAttribute('data-status'), n: el.querySelector('.n') ? el.querySelector('.n').textContent.trim() : '' })));
    return { paymentText, counts };
  }
}

module.exports = { StayPage, ScreenNotReady, BASE };
