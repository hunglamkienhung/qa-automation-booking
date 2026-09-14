"""Page objects for the mini-stay app surfaces. Mirror of node/fe/ui/pages/stay.js.
Reads by label so the assertions are about the booking product, not the markup.
A page that never loads raises ScreenNotReady (grades Blocked).
"""

from __future__ import annotations

import os

BASE = os.environ.get("MINI_STAY_URL", "http://127.0.0.1:8150").rstrip("/")


class ScreenNotReady(Exception):
    pass


class StayPage:
    def __init__(self, page) -> None:
        self.page = page
        self.base = BASE

    def open(self, path):
        try:
            self.page.goto(self.base + path, wait_until="domcontentloaded", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady(f"mini-stay page {path} did not load: {err}") from err

    def hotels(self):
        try:
            self.page.wait_for_selector("ul.hotels li.hotel", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady("home never rendered") from err
        return self.page.eval_on_selector_all("ul.hotels li.hotel", """els => els.map(el => ({
            id: Number(el.getAttribute('data-id')),
            name: el.querySelector('a') ? el.querySelector('a').textContent.trim() : '',
            href: el.querySelector('a') ? el.querySelector('a').getAttribute('href') : '',
            city: el.querySelector('.city') ? el.querySelector('.city').textContent.trim() : '',
            currency: el.querySelector('.currency') ? el.querySelector('.currency').textContent.trim() : '',
        }))""")

    def rooms(self):
        try:
            self.page.wait_for_selector("ul.rooms li.room", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady("hotel page never rendered") from err
        return self.page.eval_on_selector_all("ul.rooms li.room", """els => els.map(el => ({
            id: Number(el.getAttribute('data-id')),
            name: el.querySelector('.name') ? el.querySelector('.name').textContent.trim() : '',
            rateText: el.querySelector('.rate') ? el.querySelector('.rate').textContent.trim() : '',
            inventoryText: el.querySelector('.inventory') ? el.querySelector('.inventory').textContent.trim() : '',
            cancellationText: el.querySelector('.cancellation') ? el.querySelector('.cancellation').textContent.trim() : '',
        }))""")

    def booking(self):
        try:
            self.page.wait_for_selector("h1.booking-id", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady("booking page never rendered") from err
        return {
            "idText": self.page.eval_on_selector("h1.booking-id", "e => e.textContent.trim()"),
            "statusText": self.page.eval_on_selector(".status", "e => e.textContent.trim()"),
            "nightsText": self.page.eval_on_selector(".nights", "e => e.textContent.trim()"),
            "totalText": self.page.eval_on_selector(".total", "e => e.textContent.trim()"),
        }

    def guest_bookings(self):
        try:
            self.page.wait_for_selector("ul.bookings", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady("guest bookings never rendered") from err
        return self.page.eval_on_selector_all("ul.bookings li.booking", """els => els.map(el => ({
            id: Number(el.getAttribute('data-id')),
            href: el.querySelector('a') ? el.querySelector('a').getAttribute('href') : '',
            statusText: el.querySelector('.status') ? el.querySelector('.status').textContent.trim() : '',
            totalText: el.querySelector('.total') ? el.querySelector('.total').textContent.trim() : '',
        }))""")

    def admin(self):
        try:
            self.page.wait_for_selector("ul.counts", timeout=15000)
        except Exception as err:  # noqa: BLE001
            raise ScreenNotReady("admin page never rendered") from err
        payment_text = self.page.eval_on_selector(".payment", "e => e.textContent.trim()")
        counts = self.page.eval_on_selector_all("ul.counts li.count", """els => els.map(el => ({
            status: el.getAttribute('data-status'),
            n: el.querySelector('.n') ? el.querySelector('.n').textContent.trim() : '',
        }))""")
        return {"paymentText": payment_text, "counts": counts}
