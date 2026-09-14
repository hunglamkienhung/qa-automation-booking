@module:03-mini-stay-booking @be @api @stay @booking
Feature: The booking lifecycle

  A booking is held against a room, confirmed (which takes the payment), then run
  by the front desk from checked_in to checked_out. It can be cancelled (with a
  refund that depends on the room's cancellation policy and how far ahead the
  cancellation is), left to expire if the hold lapses before it is confirmed, or
  marked a no-show. Every refund is whole cents; every transition is gated by the
  actor and the current status.

  These scenarios drive the flow over HTTP and check the money and the state,
  including the transitions the lifecycle must refuse.

  Background:
    Given the store is open and the service is reachable

  # ---------------------------------------------------------------- holding

  @case:75 @priority:high
  Scenario: Holding a room returns a held booking
    Given a guest
    When the guest holds room 1 for 2 nights 200 days out
    Then the booking response is held

  @case:76 @priority:high
  Scenario: Holding twice with one idempotency key makes one booking
    Given a guest
    When the guest holds room 1 for 2 nights with key "bk-abc-1"
    And the guest holds again with key "bk-abc-1"
    Then both holds return the same booking

  @case:77 @priority:high
  Scenario: Holding without a token is unauthenticated
    When an anonymous caller holds room 1 for 2 nights
    Then the request is refused with status 401

  @case:78 @priority:high
  Scenario: A room at an inactive hotel cannot be held
    Given a guest
    When the guest holds room 6 for 2 nights 200 days out
    Then the request is refused with code "hotel_inactive"

  # ---------------------------------------------------------------- confirming

  @case:79 @priority:high
  Scenario: Confirming a hold takes the payment and confirms the booking
    Given a held booking
    When the guest confirms the booking
    Then the booking response is confirmed

  @case:80 @priority:high
  Scenario: Confirming an expired hold is refused and expires the hold
    Given a hold that has already expired
    When the guest confirms the booking
    Then the request is refused with code "hold_expired"

  @case:81 @priority:medium
  Scenario: A booking can be read back with its events
    Given a held booking
    When the guest reads the booking
    Then the booking reads back held with at least one event

  @case:82 @priority:medium
  Scenario: A guest's booking list includes what they held
    Given a held booking
    When the guest lists their bookings
    Then the booking list includes this booking

  # ---------------------------------------------------------------- the front desk

  @case:83 @priority:high
  Scenario: The hotelier checks a confirmed guest in and out
    Given a confirmed booking
    When the hotelier checks the booking in
    Then the booking response is checked_in
    When the hotelier checks the booking out
    Then the booking response is checked_out

  @case:84 @priority:high
  Scenario: A guest cannot work the front desk
    Given a confirmed booking
    When the guest tries to check the booking in
    Then the request is refused with status 401

  @case:85 @priority:high
  Scenario: A no-show is a hotelier action on a confirmed booking
    Given a confirmed booking
    When the hotelier marks the booking a no-show
    Then the booking response is no_show

  # ---------------------------------------------------------------- cancellation refunds

  @case:86 @priority:high
  Scenario: Cancelling a flexible booking well ahead refunds in full
    Given a confirmed booking of room 1 starting 40 days out
    When the guest cancels the booking
    Then the refund matches the cancellation policy

  @case:87 @priority:high
  Scenario: A non-refundable booking refunds nothing
    Given a confirmed booking of room 3 starting 40 days out
    When the guest cancels the booking
    Then the refund is 0

  @case:88 @priority:high
  Scenario: Cancelling an unpaid hold refunds nothing
    Given a held booking
    When the guest cancels the booking
    Then the booking response is cancelled
    And the refund is 0

  Scenario Outline: Cancelling a <label> booking refunds per policy
    Given a confirmed booking of room <room> starting <offset> days out
    When the guest cancels the booking
    Then the refund matches the cancellation policy

    @case:89
    Examples:
      | label | room | offset |
      | flexible, far ahead | 1 | 40 |
    @case:90
    Examples:
      | label | room | offset |
      | flexible, day before | 1 | 1 |
    @case:91
    Examples:
      | label | room | offset |
      | moderate, far ahead | 2 | 40 |
    @case:92
    Examples:
      | label | room | offset |
      | moderate, mid window | 2 | 4 |
    @case:93
    Examples:
      | label | room | offset |
      | moderate, day before | 2 | 1 |
    @case:94
    Examples:
      | label | room | offset |
      | nonrefundable, far ahead | 3 | 43 |
    @case:95
    Examples:
      | label | room | offset |
      | flexible other hotel | 4 | 30 |
    @case:96
    Examples:
      | label | room | offset |
      | moderate cabin far | 5 | 20 |
    @case:97
    Examples:
      | label | room | offset |
      | moderate cabin mid | 5 | 3 |
    @case:229
    Examples:
      | label | room | offset |
      | flexible far b | 1 | 10 |
    @case:230
    Examples:
      | label | room | offset |
      | moderate far b | 2 | 10 |
    @case:231
    Examples:
      | label | room | offset |
      | flexible mid | 4 | 5 |
    @case:232
    Examples:
      | label | room | offset |
      | moderate day before b | 5 | 2 |
    @case:233
    Examples:
      | label | room | offset |
      | flexible near | 1 | 3 |
    @case:234
    Examples:
      | label | room | offset |
      | moderate mid b | 2 | 6 |
    @case:235
    Examples:
      | label | room | offset |
      | flexible day before b | 4 | 1 |
    @case:236
    Examples:
      | label | room | offset |
      | moderate far c | 5 | 8 |

  # ---------------------------------------------------------------- transitions the lifecycle must refuse

  @case:98 @priority:high
  Scenario: A confirmed booking cannot be confirmed again
    Given a held booking
    And the booking is confirmed
    When the guest confirms the booking
    Then the request is refused with code "bad_state"

  @case:99 @priority:high
  Scenario: A held booking cannot be checked in before it is confirmed
    Given a held booking
    When the hotelier checks the booking in
    Then the request is refused with code "bad_state"

  @case:100 @priority:high
  Scenario: A checked-out booking cannot be cancelled
    Given a confirmed booking
    And the booking is checked in
    And the booking is checked out
    When the guest cancels the booking
    Then the request is refused with code "bad_state"

  @case:101 @priority:medium
  Scenario: A booking cannot be checked out before it is checked in
    Given a confirmed booking
    When the hotelier checks the booking out
    Then the request is refused with code "bad_state"

  @case:102 @priority:medium
  Scenario: A cancelled booking cannot be confirmed
    Given a held booking
    And the booking is cancelled
    When the guest confirms the booking
    Then the request is refused with code "bad_state"
