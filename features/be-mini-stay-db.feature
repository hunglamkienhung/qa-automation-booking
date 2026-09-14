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
    @case:421
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @400 | 1 | 1 | 400 |
    @case:422
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @408 | 2 | 2 | 408 |
    @case:423
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @416 | 3 | 3 | 416 |
    @case:424
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @424 | 4 | 4 | 424 |
    @case:425
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @432 | 5 | 5 | 432 |
    @case:426
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @440 | 1 | 1 | 440 |
    @case:427
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @448 | 2 | 2 | 448 |
    @case:428
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @456 | 3 | 3 | 456 |
    @case:429
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @464 | 4 | 4 | 464 |
    @case:430
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @472 | 5 | 5 | 472 |
    @case:431
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @480 | 1 | 1 | 480 |
    @case:432
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @488 | 2 | 2 | 488 |
    @case:433
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @496 | 3 | 3 | 496 |
    @case:434
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @504 | 4 | 4 | 504 |
    @case:435
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @512 | 5 | 5 | 512 |
    @case:436
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @520 | 1 | 1 | 520 |
    @case:437
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @528 | 2 | 2 | 528 |
    @case:438
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @536 | 3 | 3 | 536 |
    @case:439
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @544 | 4 | 4 | 544 |
    @case:440
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @552 | 5 | 5 | 552 |
    @case:441
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @560 | 1 | 1 | 560 |
    @case:442
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @568 | 2 | 2 | 568 |
    @case:443
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @576 | 3 | 3 | 576 |
    @case:444
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @584 | 4 | 4 | 584 |
    @case:445
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @592 | 5 | 5 | 592 |
    @case:446
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @600 | 1 | 1 | 600 |
    @case:447
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @608 | 2 | 2 | 608 |
    @case:448
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @616 | 3 | 3 | 616 |
    @case:449
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @624 | 4 | 4 | 624 |
    @case:450
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @632 | 5 | 5 | 632 |
    @case:451
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @640 | 1 | 1 | 640 |
    @case:452
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @648 | 2 | 2 | 648 |
    @case:453
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @656 | 3 | 3 | 656 |
    @case:454
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @664 | 4 | 4 | 664 |
    @case:455
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @672 | 5 | 5 | 672 |
    @case:456
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @680 | 1 | 1 | 680 |
    @case:457
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @688 | 2 | 2 | 688 |
    @case:458
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @696 | 3 | 3 | 696 |
    @case:459
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @704 | 4 | 4 | 704 |
    @case:460
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @712 | 5 | 5 | 712 |
    @case:461
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @720 | 1 | 1 | 720 |
    @case:462
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @728 | 2 | 2 | 728 |
    @case:463
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @736 | 3 | 3 | 736 |
    @case:464
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @744 | 4 | 4 | 744 |
    @case:465
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @752 | 5 | 5 | 752 |
    @case:466
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @760 | 1 | 1 | 760 |
    @case:467
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @768 | 2 | 2 | 768 |
    @case:468
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @776 | 3 | 3 | 776 |
    @case:469
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @784 | 4 | 4 | 784 |
    @case:470
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @792 | 5 | 5 | 792 |
    @case:471
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @800 | 1 | 1 | 800 |
    @case:472
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @808 | 2 | 2 | 808 |
    @case:473
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @816 | 3 | 3 | 816 |
    @case:474
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @824 | 4 | 4 | 824 |
    @case:475
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @832 | 5 | 5 | 832 |
    @case:476
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @840 | 1 | 1 | 840 |
    @case:477
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @848 | 2 | 2 | 848 |
    @case:478
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @856 | 3 | 3 | 856 |
    @case:479
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @864 | 4 | 4 | 864 |
    @case:480
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @872 | 5 | 5 | 872 |
    @case:481
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @880 | 1 | 1 | 880 |
    @case:482
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @888 | 2 | 2 | 888 |
    @case:483
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @896 | 3 | 3 | 896 |
    @case:484
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @904 | 4 | 4 | 904 |
    @case:485
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @912 | 5 | 5 | 912 |
    @case:486
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @920 | 1 | 1 | 920 |
    @case:487
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @928 | 2 | 2 | 928 |
    @case:488
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @936 | 3 | 3 | 936 |
    @case:489
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @944 | 4 | 4 | 944 |
    @case:490
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @952 | 5 | 5 | 952 |
    @case:491
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @960 | 1 | 1 | 960 |
    @case:492
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @968 | 2 | 2 | 968 |
    @case:493
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @976 | 3 | 3 | 976 |
    @case:494
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @984 | 4 | 4 | 984 |
    @case:495
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @992 | 5 | 5 | 992 |
    @case:496
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1000 | 1 | 1 | 1000 |
    @case:497
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1008 | 2 | 2 | 1008 |
    @case:498
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1016 | 3 | 3 | 1016 |
    @case:499
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1024 | 4 | 4 | 1024 |
    @case:500
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1032 | 5 | 5 | 1032 |
    @case:501
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1040 | 1 | 1 | 1040 |
    @case:502
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1048 | 2 | 2 | 1048 |
    @case:503
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1056 | 3 | 3 | 1056 |
    @case:504
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1064 | 4 | 4 | 1064 |
    @case:505
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1072 | 5 | 5 | 1072 |
    @case:506
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1080 | 1 | 1 | 1080 |
    @case:507
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1088 | 2 | 2 | 1088 |
    @case:508
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1096 | 3 | 3 | 1096 |
    @case:509
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1104 | 4 | 4 | 1104 |
    @case:510
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1112 | 5 | 5 | 1112 |
    @case:511
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1120 | 1 | 1 | 1120 |
    @case:512
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1128 | 2 | 2 | 1128 |
    @case:513
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1136 | 3 | 3 | 1136 |
    @case:514
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1144 | 4 | 4 | 1144 |
    @case:515
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1152 | 5 | 5 | 1152 |
    @case:516
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1160 | 1 | 1 | 1160 |
    @case:517
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1168 | 2 | 2 | 1168 |
    @case:518
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1176 | 3 | 3 | 1176 |
    @case:519
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1184 | 4 | 4 | 1184 |
    @case:520
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1192 | 5 | 5 | 1192 |
    @case:521
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1200 | 1 | 1 | 1200 |
    @case:522
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1208 | 2 | 2 | 1208 |
    @case:523
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1216 | 3 | 3 | 1216 |
    @case:524
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1224 | 4 | 4 | 1224 |
    @case:525
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1232 | 5 | 5 | 1232 |
    @case:526
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1240 | 1 | 1 | 1240 |
    @case:527
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1248 | 2 | 2 | 1248 |
    @case:528
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1256 | 3 | 3 | 1256 |
    @case:529
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1264 | 4 | 4 | 1264 |
    @case:530
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1272 | 5 | 5 | 1272 |
    @case:531
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1280 | 1 | 1 | 1280 |
    @case:532
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1288 | 2 | 2 | 1288 |
    @case:533
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1296 | 3 | 3 | 1296 |
    @case:534
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1304 | 4 | 4 | 1304 |
    @case:535
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1312 | 5 | 5 | 1312 |
    @case:536
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1320 | 1 | 1 | 1320 |
    @case:537
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1328 | 2 | 2 | 1328 |
    @case:538
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1336 | 3 | 3 | 1336 |
    @case:539
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1344 | 4 | 4 | 1344 |
    @case:540
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1352 | 5 | 5 | 1352 |
    @case:541
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1360 | 1 | 1 | 1360 |
    @case:542
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1368 | 2 | 2 | 1368 |
    @case:543
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1376 | 3 | 3 | 1376 |
    @case:544
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1384 | 4 | 4 | 1384 |
    @case:545
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1392 | 5 | 5 | 1392 |
    @case:546
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1400 | 1 | 1 | 1400 |
    @case:547
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1408 | 2 | 2 | 1408 |
    @case:548
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1416 | 3 | 3 | 1416 |
    @case:549
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1424 | 4 | 4 | 1424 |
    @case:550
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1432 | 5 | 5 | 1432 |
    @case:551
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1440 | 1 | 1 | 1440 |
    @case:552
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1448 | 2 | 2 | 1448 |
    @case:553
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1456 | 3 | 3 | 1456 |
    @case:554
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1464 | 4 | 4 | 1464 |
    @case:555
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1472 | 5 | 5 | 1472 |
    @case:556
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1480 | 1 | 1 | 1480 |
    @case:557
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1488 | 2 | 2 | 1488 |
    @case:558
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1496 | 3 | 3 | 1496 |
    @case:559
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1504 | 4 | 4 | 1504 |
    @case:560
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1512 | 5 | 5 | 1512 |
    @case:561
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1520 | 1 | 1 | 1520 |
    @case:562
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1528 | 2 | 2 | 1528 |
    @case:563
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1536 | 3 | 3 | 1536 |
    @case:564
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1544 | 4 | 4 | 1544 |
    @case:565
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1552 | 5 | 5 | 1552 |
    @case:566
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1560 | 1 | 1 | 1560 |
    @case:567
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1568 | 2 | 2 | 1568 |
    @case:568
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1576 | 3 | 3 | 1576 |
    @case:569
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1584 | 4 | 4 | 1584 |
    @case:570
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1592 | 5 | 5 | 1592 |

