-- Deterministic seed. Idempotent: INSERT OR IGNORE by primary key. Money in
-- cents, tax in basis points. One hotel is inactive on purpose, one room type is
-- non-refundable on purpose, and one room type has an inventory of exactly 1 so
-- the overbooking and concurrency scenarios have a scarce room to fight over.
-- Guests are created through the API, so those rows never collide between runs.

-- Two active hotels priced in different currencies (so the FX tier has something
-- real to convert), and one inactive hotel that must not be bookable.
INSERT OR IGNORE INTO hotels (id, name, city, currency, tax_bps, active) VALUES
  (1, 'Harbour View',   'Lisbon',   'EUR', 1200, 1),
  (2, 'Cedar Lodge',    'Denver',   'USD', 1500, 1),
  (3, 'Shuttered Inn',  'Nowhere',  'USD', 1000, 0);   -- inactive on purpose

-- Room types. Inventory is generous except the "Penthouse" (1 room) which the
-- overbooking/concurrency tier contends over. Cancellation policies span the
-- three tiers so refunds can be exercised across a grid.
INSERT OR IGNORE INTO room_types (id, hotel_id, name, nightly_rate_cents, capacity, inventory, cancellation) VALUES
  (1, 1, 'Standard Double', 12000, 2, 8,  'flexible'),
  (2, 1, 'Sea-View Suite',  22000, 3, 4,  'moderate'),
  (3, 1, 'Penthouse',       80000, 4, 1,  'nonrefundable'),   -- inventory 1: the scarce room
  (4, 2, 'Queen Room',      15000, 2, 6,  'flexible'),
  (5, 2, 'Family Cabin',    26000, 5, 3,  'moderate'),
  (6, 3, 'Ghost Room',      10000, 2, 5,  'flexible');        -- on the inactive hotel

-- One seeded hotelier owns the two active hotels; its token authenticates the
-- front-desk actions (confirm, check-in, check-out, no-show). A second hotelier,
-- created through the API, owns nothing -- the security tier uses it to prove a
-- hotelier cannot touch a hotel it does not own.
INSERT OR IGNORE INTO hoteliers (id, name, token, created_at) VALUES
  (1, 'Priya Vance', 'htl_seed_priya', 1700000000);
INSERT OR IGNORE INTO hotel_owners (hotel_id, hotelier_id) VALUES
  (1, 1), (2, 1), (3, 1);

-- One seeded guest the booking flows authenticate with; a second is seeded so
-- cross-guest access (IDOR) can be shown to fail. Further guests are created
-- through the API and own nothing.
INSERT OR IGNORE INTO guests (id, name, token, created_at) VALUES
  (1, 'Aria Holt',   'gst_seed_aria', 1700000000),
  (2, 'Bruno Salk',  'gst_seed_bruno', 1700000000);
