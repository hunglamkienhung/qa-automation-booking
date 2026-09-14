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

    @case:801
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @400 | 1 | 1 | 400 |
    @case:802
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @408 | 2 | 2 | 408 |
    @case:803
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @416 | 3 | 3 | 416 |
    @case:804
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @424 | 4 | 4 | 424 |
    @case:805
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @432 | 5 | 5 | 432 |
    @case:806
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @440 | 1 | 1 | 440 |
    @case:807
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @448 | 2 | 2 | 448 |
    @case:808
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @456 | 3 | 3 | 456 |
    @case:809
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @464 | 4 | 4 | 464 |
    @case:810
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @472 | 5 | 5 | 472 |
    @case:811
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @480 | 1 | 1 | 480 |
    @case:812
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @488 | 2 | 2 | 488 |
    @case:813
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @496 | 3 | 3 | 496 |
    @case:814
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @504 | 4 | 4 | 504 |
    @case:815
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @512 | 5 | 5 | 512 |
    @case:816
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @520 | 1 | 1 | 520 |
    @case:817
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @528 | 2 | 2 | 528 |
    @case:818
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @536 | 3 | 3 | 536 |
    @case:819
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @544 | 4 | 4 | 544 |
    @case:820
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @552 | 5 | 5 | 552 |
    @case:821
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @560 | 1 | 1 | 560 |
    @case:822
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @568 | 2 | 2 | 568 |
    @case:823
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @576 | 3 | 3 | 576 |
    @case:824
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @584 | 4 | 4 | 584 |
    @case:825
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @592 | 5 | 5 | 592 |
    @case:826
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @600 | 1 | 1 | 600 |
    @case:827
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @608 | 2 | 2 | 608 |
    @case:828
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @616 | 3 | 3 | 616 |
    @case:829
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @624 | 4 | 4 | 624 |
    @case:830
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @632 | 5 | 5 | 632 |
    @case:831
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @640 | 1 | 1 | 640 |
    @case:832
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @648 | 2 | 2 | 648 |
    @case:833
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @656 | 3 | 3 | 656 |
    @case:834
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @664 | 4 | 4 | 664 |
    @case:835
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @672 | 5 | 5 | 672 |
    @case:836
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @680 | 1 | 1 | 680 |
    @case:837
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @688 | 2 | 2 | 688 |
    @case:838
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @696 | 3 | 3 | 696 |
    @case:839
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @704 | 4 | 4 | 704 |
    @case:840
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @712 | 5 | 5 | 712 |
    @case:841
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @720 | 1 | 1 | 720 |
    @case:842
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @728 | 2 | 2 | 728 |
    @case:843
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @736 | 3 | 3 | 736 |
    @case:844
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @744 | 4 | 4 | 744 |
    @case:845
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @752 | 5 | 5 | 752 |
    @case:846
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @760 | 1 | 1 | 760 |
    @case:847
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @768 | 2 | 2 | 768 |
    @case:848
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @776 | 3 | 3 | 776 |
    @case:849
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @784 | 4 | 4 | 784 |
    @case:850
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @792 | 5 | 5 | 792 |
    @case:851
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @800 | 1 | 1 | 800 |
    @case:852
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @808 | 2 | 2 | 808 |
    @case:853
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @816 | 3 | 3 | 816 |
    @case:854
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @824 | 4 | 4 | 824 |
    @case:855
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @832 | 5 | 5 | 832 |
    @case:856
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @840 | 1 | 1 | 840 |
    @case:857
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @848 | 2 | 2 | 848 |
    @case:858
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @856 | 3 | 3 | 856 |
    @case:859
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @864 | 4 | 4 | 864 |
    @case:860
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @872 | 5 | 5 | 872 |
    @case:861
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @880 | 1 | 1 | 880 |
    @case:862
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @888 | 2 | 2 | 888 |
    @case:863
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @896 | 3 | 3 | 896 |
    @case:864
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @904 | 4 | 4 | 904 |
    @case:865
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @912 | 5 | 5 | 912 |
    @case:866
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @920 | 1 | 1 | 920 |
    @case:867
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @928 | 2 | 2 | 928 |
    @case:868
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @936 | 3 | 3 | 936 |
    @case:869
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @944 | 4 | 4 | 944 |
    @case:870
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @952 | 5 | 5 | 952 |
    @case:871
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @960 | 1 | 1 | 960 |
    @case:872
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @968 | 2 | 2 | 968 |
    @case:873
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @976 | 3 | 3 | 976 |
    @case:874
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @984 | 4 | 4 | 984 |
    @case:875
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @992 | 5 | 5 | 992 |
    @case:876
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1000 | 1 | 1 | 1000 |
    @case:877
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1008 | 2 | 2 | 1008 |
    @case:878
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1016 | 3 | 3 | 1016 |
    @case:879
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1024 | 4 | 4 | 1024 |
    @case:880
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1032 | 5 | 5 | 1032 |
    @case:881
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1040 | 1 | 1 | 1040 |
    @case:882
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1048 | 2 | 2 | 1048 |
    @case:883
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1056 | 3 | 3 | 1056 |
    @case:884
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1064 | 4 | 4 | 1064 |
    @case:885
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1072 | 5 | 5 | 1072 |
    @case:886
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1080 | 1 | 1 | 1080 |
    @case:887
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1088 | 2 | 2 | 1088 |
    @case:888
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1096 | 3 | 3 | 1096 |
    @case:889
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1104 | 4 | 4 | 1104 |
    @case:890
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1112 | 5 | 5 | 1112 |
    @case:891
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1120 | 1 | 1 | 1120 |
    @case:892
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1128 | 2 | 2 | 1128 |
    @case:893
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1136 | 3 | 3 | 1136 |
    @case:894
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1144 | 4 | 4 | 1144 |
    @case:895
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1152 | 5 | 5 | 1152 |
    @case:896
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1160 | 1 | 1 | 1160 |
    @case:897
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1168 | 2 | 2 | 1168 |
    @case:898
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1176 | 3 | 3 | 1176 |
    @case:899
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1184 | 4 | 4 | 1184 |
    @case:900
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1192 | 5 | 5 | 1192 |
    @case:901
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1200 | 1 | 1 | 1200 |
    @case:902
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1208 | 2 | 2 | 1208 |
    @case:903
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1216 | 3 | 3 | 1216 |
    @case:904
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1224 | 4 | 4 | 1224 |
    @case:905
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1232 | 5 | 5 | 1232 |
    @case:906
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1240 | 1 | 1 | 1240 |
    @case:907
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1248 | 2 | 2 | 1248 |
    @case:908
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1256 | 3 | 3 | 1256 |
    @case:909
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1264 | 4 | 4 | 1264 |
    @case:910
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1272 | 5 | 5 | 1272 |
    @case:911
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1280 | 1 | 1 | 1280 |
    @case:912
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1288 | 2 | 2 | 1288 |
    @case:913
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1296 | 3 | 3 | 1296 |
    @case:914
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1304 | 4 | 4 | 1304 |
    @case:915
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1312 | 5 | 5 | 1312 |
    @case:916
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1320 | 1 | 1 | 1320 |
    @case:917
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1328 | 2 | 2 | 1328 |
    @case:918
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1336 | 3 | 3 | 1336 |
    @case:919
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1344 | 4 | 4 | 1344 |
    @case:920
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1352 | 5 | 5 | 1352 |
    @case:921
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1360 | 1 | 1 | 1360 |
    @case:922
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1368 | 2 | 2 | 1368 |
    @case:923
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1376 | 3 | 3 | 1376 |
    @case:924
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1384 | 4 | 4 | 1384 |
    @case:925
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1392 | 5 | 5 | 1392 |
    @case:926
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1400 | 1 | 1 | 1400 |
    @case:927
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1408 | 2 | 2 | 1408 |
    @case:928
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1416 | 3 | 3 | 1416 |
    @case:929
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1424 | 4 | 4 | 1424 |
    @case:930
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1432 | 5 | 5 | 1432 |
    @case:931
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1440 | 1 | 1 | 1440 |
    @case:932
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1448 | 2 | 2 | 1448 |
    @case:933
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1456 | 3 | 3 | 1456 |
    @case:934
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1464 | 4 | 4 | 1464 |
    @case:935
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1472 | 5 | 5 | 1472 |
    @case:936
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1480 | 1 | 1 | 1480 |
    @case:937
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1488 | 2 | 2 | 1488 |
    @case:938
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1496 | 3 | 3 | 1496 |
    @case:939
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1504 | 4 | 4 | 1504 |
    @case:940
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1512 | 5 | 5 | 1512 |
    @case:941
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1520 | 1 | 1 | 1520 |
    @case:942
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1528 | 2 | 2 | 1528 |
    @case:943
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1536 | 3 | 3 | 1536 |
    @case:944
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1544 | 4 | 4 | 1544 |
    @case:945
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1552 | 5 | 5 | 1552 |
    @case:946
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1560 | 1 | 1 | 1560 |
    @case:947
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1568 | 2 | 2 | 1568 |
    @case:948
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1576 | 3 | 3 | 1576 |
    @case:949
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1584 | 4 | 4 | 1584 |
    @case:950
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1592 | 5 | 5 | 1592 |
    @case:951
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1600 | 1 | 1 | 1600 |
    @case:952
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1608 | 2 | 2 | 1608 |
    @case:953
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1616 | 3 | 3 | 1616 |
    @case:954
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1624 | 4 | 4 | 1624 |
    @case:955
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1632 | 5 | 5 | 1632 |
    @case:956
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1640 | 1 | 1 | 1640 |
    @case:957
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1648 | 2 | 2 | 1648 |
    @case:958
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1656 | 3 | 3 | 1656 |
    @case:959
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1664 | 4 | 4 | 1664 |
    @case:960
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1672 | 5 | 5 | 1672 |
    @case:961
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1680 | 1 | 1 | 1680 |
    @case:962
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1688 | 2 | 2 | 1688 |
    @case:963
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1696 | 3 | 3 | 1696 |
    @case:964
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1704 | 4 | 4 | 1704 |
    @case:965
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1712 | 5 | 5 | 1712 |
    @case:966
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1720 | 1 | 1 | 1720 |
    @case:967
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1728 | 2 | 2 | 1728 |
    @case:968
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1736 | 3 | 3 | 1736 |
    @case:969
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1744 | 4 | 4 | 1744 |
    @case:970
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1752 | 5 | 5 | 1752 |
    @case:971
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1760 | 1 | 1 | 1760 |
    @case:972
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1768 | 2 | 2 | 1768 |
    @case:973
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1776 | 3 | 3 | 1776 |
    @case:974
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1784 | 4 | 4 | 1784 |
    @case:975
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1792 | 5 | 5 | 1792 |
    @case:976
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1800 | 1 | 1 | 1800 |
    @case:977
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1808 | 2 | 2 | 1808 |
    @case:978
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1816 | 3 | 3 | 1816 |
    @case:979
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1824 | 4 | 4 | 1824 |
    @case:980
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1832 | 5 | 5 | 1832 |
    @case:981
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1840 | 1 | 1 | 1840 |
    @case:982
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1848 | 2 | 2 | 1848 |
    @case:983
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1856 | 3 | 3 | 1856 |
    @case:984
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1864 | 4 | 4 | 1864 |
    @case:985
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1872 | 5 | 5 | 1872 |
    @case:986
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1880 | 1 | 1 | 1880 |
    @case:987
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1888 | 2 | 2 | 1888 |
    @case:988
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1896 | 3 | 3 | 1896 |
    @case:989
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1904 | 4 | 4 | 1904 |
    @case:990
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1912 | 5 | 5 | 1912 |
    @case:991
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1920 | 1 | 1 | 1920 |
    @case:992
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1928 | 2 | 2 | 1928 |
    @case:993
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1936 | 3 | 3 | 1936 |
    @case:994
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1944 | 4 | 4 | 1944 |
    @case:995
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1952 | 5 | 5 | 1952 |
    @case:996
    Examples:
      | label | room | nights | offset |
      | hold 1x1 @1960 | 1 | 1 | 1960 |
    @case:997
    Examples:
      | label | room | nights | offset |
      | hold 2x2 @1968 | 2 | 2 | 1968 |
    @case:998
    Examples:
      | label | room | nights | offset |
      | hold 3x3 @1976 | 3 | 3 | 1976 |
    @case:999
    Examples:
      | label | room | nights | offset |
      | hold 4x4 @1984 | 4 | 4 | 1984 |
    @case:1000
    Examples:
      | label | room | nights | offset |
      | hold 5x5 @1992 | 5 | 5 | 1992 |
