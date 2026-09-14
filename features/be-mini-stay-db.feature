@module:01-mini-stay-db @be @db @stay
Feature: The mini-stay store, read directly

  Both stacks open the SQLite file the mini-stay service writes and assert on its
  rows. The service is driven through its HTTP API to create state -- a room
  held, a booking confirmed, a stay run to checked_out, a cancellation -- and the
  rows, events and ledger are then read straight from the file.

  The booking lifecycle is a state machine (held -> confirmed -> checked_in ->
  checked_out, with cancelled/expired/no_show as exits), audited row by row in
  booking_events; on confirm the price is posted to a ledger and on cancellation
  a refund is posted back. The one thing the store must never show is a room
  sold beyond its inventory for a night -- an invariant the availability tier
  drives to its edge and this tier reads from the rows.

  Background:
    Given the store is open and the service is reachable

  # ---------------------------------------------------------------- schema (throwaway db)

  @case:1 @priority:high
  Scenario: The store has the documented tables
    Then the store has tables hotels, room_types, guests, hoteliers, hotel_owners, bookings, booking_events, ledger

  @case:2 @priority:high
  Scenario: A room's capacity and inventory are bounded by CHECK
    Given a throwaway database with the schema applied
    Then inserting a room type with zero capacity fails a CHECK
    And inserting a room type with negative inventory fails a CHECK

  @case:3 @priority:high
  Scenario: A room type references a real hotel
    Given a throwaway database with the schema applied
    Then inserting a room type for a missing hotel fails a FOREIGN KEY

  @case:4 @priority:high
  Scenario: A booking references a real guest, hotel and room type
    Given a throwaway database with the schema applied
    Then inserting a booking for a missing guest fails a FOREIGN KEY
    And inserting a booking for a missing room type fails a FOREIGN KEY

  @case:5 @priority:high
  Scenario: A booking event references a real booking
    Given a throwaway database with the schema applied
    Then inserting a booking event for a missing booking fails a FOREIGN KEY

  @case:6 @priority:high
  Scenario: Money amounts are bounded by CHECK
    Given a throwaway database with the schema applied
    Then inserting a room type with a negative nightly rate fails a CHECK
    And inserting a booking with a negative total fails a CHECK
    And inserting a booking with negative tax fails a CHECK

  @case:7 @priority:high
  Scenario: A booking's dates run forward and cover at least one night
    Given a throwaway database with the schema applied
    Then inserting a booking whose check-out is before its check-in fails a CHECK
    And inserting a booking with zero nights fails a CHECK

  @case:8 @priority:high
  Scenario: A booking status is one of the lifecycle states
    Given a throwaway database with the schema applied
    Then inserting a booking with status "reserved" fails a CHECK

  @case:9 @priority:medium
  Scenario: A booking event names a known actor
    Given a throwaway database with the schema applied
    Then inserting a booking event with actor "robot" fails a CHECK

  @case:10 @priority:medium
  Scenario: A cancellation policy is one of the known kinds
    Given a throwaway database with the schema applied
    Then inserting a room type with cancellation "whenever" fails a CHECK

  @case:11 @priority:medium
  Scenario: A ledger entry is a real, non-zero amount with a known reason and party
    Given a throwaway database with the schema applied
    Then inserting a ledger row with zero delta fails a CHECK
    And inserting a ledger row with reason "tip" fails a CHECK
    And inserting a ledger row with party type "government" fails a CHECK

  @case:12 @priority:medium
  Scenario: A hotel's tax rate is not negative
    Given a throwaway database with the schema applied
    Then inserting a hotel with a negative tax rate fails a CHECK

  @case:13 @priority:medium
  Scenario: An idempotency key is unique across bookings
    Given a throwaway database with the schema applied
    Then inserting two bookings with the same idempotency key fails on the second

  @case:14 @priority:medium
  Scenario: Seeding twice leaves the same rows
    Given a throwaway database with the schema and seed applied
    Then applying the seed again changes no row counts

  # ---------------------------------------------------------------- holding writes the right rows

  @case:15 @priority:high
  Scenario: Holding a room writes a held booking with the priced money
    Given a held booking
    Then the booking row is held
    And the booking total row equals its base plus tax
    And the booking's first event moves to held by the guest

  @case:16 @priority:high
  Scenario: A held booking snapshots the rate and the cancellation policy
    Given a held booking
    Then the booking row snapshots the room's nightly rate and cancellation policy

  @case:17 @priority:high
  Scenario: The hold expiry is the creation time plus the hold window
    Given a held booking
    Then the booking hold expiry is after its creation time

  # ---------------------------------------------------------------- confirming and the money

  @case:18 @priority:high
  Scenario: Confirming a hold moves it to confirmed and records the transition
    Given a held booking
    And the booking is confirmed
    Then the booking row is confirmed
    And a booking event records held to confirmed by the guest

  @case:19 @priority:high
  Scenario: Confirming posts the price to the ledger
    Given a held booking
    And the booking is confirmed
    Then a payment ledger row for the booking equals its total

  @case:20 @priority:medium
  Scenario: A held booking has posted nothing to the ledger
    Given a held booking
    Then the booking has no ledger rows

  # ---------------------------------------------------------------- the full lifecycle, audited

  @case:21 @priority:high
  Scenario: A full stay writes an event for every transition
    Given a held booking
    And the booking is confirmed
    And the booking is checked in
    And the booking is checked out
    Then the booking's events run held, confirmed, checked_in, checked_out

  @case:22 @priority:high
  Scenario: Cancelling a confirmed booking records the transition and a refund
    Given a confirmed booking of room 1 starting 40 days out
    And the booking is cancelled
    Then the booking row is cancelled
    And a refund ledger row for the booking is a debit
    And a booking event records confirmed to cancelled by the guest

  @case:23 @priority:medium
  Scenario: Cancelling an unpaid hold refunds nothing
    Given a held booking
    And the booking is cancelled
    Then the booking row is cancelled
    And the booking has no refund ledger rows

  @case:24 @priority:medium
  Scenario: A no-show is a hotelier transition off a confirmed booking
    Given a held booking
    And the booking is confirmed
    And the booking is marked a no-show
    Then the booking row is no_show
    And a booking event records confirmed to no_show by the hotelier

  @case:25 @priority:high
  Scenario: Confirming an expired hold marks it expired and pays nothing
    Given a hold that has already expired
    And confirming the expired hold is attempted
    Then the booking row is expired
    And the booking has no ledger rows

  # ---------------------------------------------------------------- the inventory invariant, from the rows

  @case:26 @priority:high
  Scenario: A held booking occupies one room on each of its nights
    Given a held booking of room 3 for 2 nights starting 70 days out
    Then each night of the booking shows one room of that type occupied

  @case:27 @priority:high
  Scenario: The scarce room is never occupied beyond its inventory
    Given the scarce room is fully booked for 1 night starting 80 days out
    Then no night shows that room occupied beyond its inventory
    And a further hold on that room and night is refused

  @case:28 @priority:medium
  Scenario: A cancelled hold stops occupying the room
    Given a held booking of room 3 for 1 nights starting 90 days out
    And the booking is cancelled
    Then no room of that type is occupied on that night

  # ---------------------------------------------------------------- integrity

  @case:29 @priority:medium
  Scenario: No booking references a missing guest, hotel or room type
    Then no bookings row references a guest missing from guests
    And no bookings row references a room type missing from room_types

  @case:30 @priority:medium
  Scenario: Every confirmed or cancelled booking's ledger matches its state
    Given a confirmed booking of room 1 starting 40 days out
    Then the booking has exactly one payment ledger row

  # ---------------------------------------------------------------- parameterised holds

  Scenario Outline: A <label> hold prices and occupies correctly
    Given a held booking of room <room> for <nights> nights starting <offset> days out
    Then the booking total row equals its base plus tax
    And each night of the booking shows one room of that type occupied

    @case:31
    Examples:
      | label | room | nights | offset |
      | standard double | 1 | 2 | 100 |
    @case:32
    Examples:
      | label | room | nights | offset |
      | sea-view suite | 2 | 3 | 110 |
    @case:33
    Examples:
      | label | room | nights | offset |
      | queen room | 4 | 1 | 120 |
    @case:34
    Examples:
      | label | room | nights | offset |
      | family cabin | 5 | 5 | 130 |
    @case:35
    Examples:
      | label | room | nights | offset |
      | penthouse long stay | 3 | 7 | 140 |
    @case:36
    Examples:
      | label | room | nights | offset |
      | standard long stay | 1 | 10 | 150 |
    @case:37
    Examples:
      | label | room | nights | offset |
      | suite short | 2 | 1 | 160 |
    @case:38
    Examples:
      | label | room | nights | offset |
      | queen mid | 4 | 4 | 170 |
    @case:39
    Examples:
      | label | room | nights | offset |
      | cabin short | 5 | 2 | 180 |
    @case:40
    Examples:
      | label | room | nights | offset |
      | double week | 1 | 7 | 190 |
    @case:217
    Examples:
      | label | room | nights | offset |
      | double a | 1 | 2 | 200 |
    @case:218
    Examples:
      | label | room | nights | offset |
      | double b | 1 | 3 | 205 |
    @case:219
    Examples:
      | label | room | nights | offset |
      | suite a | 2 | 2 | 210 |
    @case:220
    Examples:
      | label | room | nights | offset |
      | suite b | 2 | 4 | 215 |
    @case:221
    Examples:
      | label | room | nights | offset |
      | queen a | 4 | 1 | 220 |
    @case:222
    Examples:
      | label | room | nights | offset |
      | queen b | 4 | 3 | 225 |
    @case:223
    Examples:
      | label | room | nights | offset |
      | cabin a | 5 | 2 | 230 |
    @case:224
    Examples:
      | label | room | nights | offset |
      | cabin b | 5 | 5 | 235 |
    @case:225
    Examples:
      | label | room | nights | offset |
      | double c | 1 | 4 | 240 |
    @case:226
    Examples:
      | label | room | nights | offset |
      | suite c | 2 | 1 | 245 |
    @case:227
    Examples:
      | label | room | nights | offset |
      | queen c | 4 | 5 | 250 |
    @case:228
    Examples:
      | label | room | nights | offset |
      | cabin c | 5 | 3 | 255 |
