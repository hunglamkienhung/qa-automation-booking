@module:04-mini-stay-availability @be @api @stay @availability
Feature: Inventory and no overbooking

  The one thing a booking system must never do is sell the same room twice for
  the same night. Availability is the number of rooms of a type free for every
  night of a range, counting confirmed stays and live holds but not expired ones.
  A hold is accepted only if a room is free for the whole range, and the check
  and the insert happen inside one IMMEDIATE transaction -- so even when many
  guests race for the last room, exactly as many succeed as there are rooms.

  Every scenario takes a fresh future night so it never contends with another,
  except where it deliberately makes two bookings fight over the same nights.

  Background:
    Given the store is open and the service is reachable

  # ---------------------------------------------------------------- the scarce room

  @case:103 @priority:high
  Scenario: A fresh night on the scarce room shows one available
    Given a fresh night for the scarce room
    When the availability for that window is read
    Then the availability is 1

  @case:104 @priority:high
  Scenario: Holding the scarce room drops its availability to nought
    Given a fresh night for the scarce room
    And the scarce room is held for that window
    When the availability for that window is read
    Then the availability is 0

  @case:105 @priority:high
  Scenario: A second hold on the held scarce room is refused
    Given a fresh night for the scarce room
    And the scarce room is held for that window
    When another guest holds the scarce room for that window
    Then the request is refused with code "sold_out"

  @case:106 @priority:medium
  Scenario: Confirming the held scarce room keeps availability at nought
    Given a fresh night for the scarce room
    And the scarce room is held and confirmed for that window
    When the availability for that window is read
    Then the availability is 0

  @case:107 @priority:high
  Scenario: Cancelling frees the scarce room again
    Given a fresh night for the scarce room
    And the scarce room is held for that window
    And that hold is cancelled
    When the availability for that window is read
    Then the availability is 1

  @case:108 @priority:high
  Scenario: An expired hold does not occupy the scarce room
    Given a fresh night for the scarce room
    And the scarce room is held for that window with a hold that expires at once
    When the availability for that window is read
    Then the availability is 1

  # ---------------------------------------------------------------- the race (the whole point)

  @case:109 @priority:high
  Scenario: When many guests race for the last room exactly one wins
    Given a fresh night for the scarce room
    When 8 guests hold the scarce room for that window at once
    Then exactly 1 hold succeeds and the rest are sold out

  @case:110 @priority:high
  Scenario: The race is decided the same way every time
    Given a fresh night for the scarce room
    When 12 guests hold the scarce room for that window at once
    Then exactly 1 hold succeeds and the rest are sold out

  @case:111 @priority:high
  Scenario: A race for a room with several in stock fills exactly the stock
    Given a fresh night for room 2
    When 10 guests hold that room for that window at once
    Then exactly 4 holds succeed and the rest are sold out

  # ---------------------------------------------------------------- overlapping ranges

  @case:112 @priority:high
  Scenario: An overlapping range cannot also take the scarce room
    Given a fresh 2-night window for the scarce room
    And the scarce room is held for that window
    When a guest holds the scarce room shifted one night later
    Then the request is refused with code "sold_out"

  @case:113 @priority:high
  Scenario: The nights immediately after are free
    Given a fresh 2-night window for the scarce room
    And the scarce room is held for that window
    When a guest holds the scarce room for the two nights immediately after
    Then the hold succeeds

  @case:114 @priority:medium
  Scenario: A one-night overlap of a longer stay is still a conflict
    Given a fresh 3-night window for the scarce room
    And the scarce room is held for that window
    When a guest holds the scarce room shifted two nights later
    Then the request is refused with code "sold_out"

  # ---------------------------------------------------------------- rooms with more than one in stock

  @case:115 @priority:high
  Scenario: A fresh night on a four-room type shows four available
    Given a fresh night for room 2
    When the availability for that window is read
    Then the availability is 4

  @case:116 @priority:high
  Scenario: Filling a four-room type refuses the fifth hold
    Given a fresh night for room 2
    And the room is held 4 times for that window
    When another guest holds that room for that window
    Then the request is refused with code "sold_out"

  @case:117 @priority:medium
  Scenario: Cancelling one of several restores one room
    Given a fresh night for room 2
    And the room is held 4 times for that window
    And one of those holds is cancelled
    When the availability for that window is read
    Then the availability is 1

  @case:118 @priority:medium
  Scenario: A multi-night hold occupies every night of its range
    Given a fresh 3-night window for the scarce room
    And the scarce room is held for that window
    When the availability for that window is read
    Then the availability is 0

  # ---------------------------------------------------------------- the availability endpoint itself

  @case:119 @priority:medium
  Scenario: Availability of a check-out on the check-in day is refused
    Given a fresh night for the scarce room
    When the availability for a zero-night window is read
    Then the request is refused with status 422

  @case:120 @priority:low
  Scenario: Availability of an unknown room is not found
    When the availability of room 999 for a fresh night is read
    Then the request is refused with status 404

  Scenario Outline: A fresh night on room <room> shows its full inventory of <inventory>
    Given a fresh night for room <room>
    When the availability for that window is read
    Then the availability is <inventory>

    @case:121
    Examples:
      | room | inventory |
      | 1 | 8 |
    @case:122
    Examples:
      | room | inventory |
      | 2 | 4 |
    @case:123
    Examples:
      | room | inventory |
      | 3 | 1 |
    @case:124
    Examples:
      | room | inventory |
      | 4 | 6 |
    @case:125
    Examples:
      | room | inventory |
      | 5 | 3 |

  # ---------------------------------------------------------------- races on several rooms

  Scenario Outline: A race for room <room> fills exactly its <inventory> rooms
    Given a fresh night for room <room>
    When <racers> guests hold that room for that window at once
    Then exactly <inventory> holds succeed and the rest are sold out

    @case:126
    Examples:
      | room | inventory | racers |
      | 1 | 8 | 15 |
    @case:127
    Examples:
      | room | inventory | racers |
      | 4 | 6 | 12 |
    @case:128
    Examples:
      | room | inventory | racers |
      | 5 | 3 | 9 |
    @case:129
    Examples:
      | room | inventory | racers |
      | 3 | 1 | 6 |
    @case:237
    Examples:
      | room | inventory | racers |
      | 1 | 8 | 20 |
    @case:238
    Examples:
      | room | inventory | racers |
      | 2 | 4 | 8 |
    @case:239
    Examples:
      | room | inventory | racers |
      | 4 | 6 | 10 |
    @case:240
    Examples:
      | room | inventory | racers |
      | 5 | 3 | 7 |
    @case:241
    Examples:
      | room | inventory | racers |
      | 2 | 4 | 12 |
    @case:242
    Examples:
      | room | inventory | racers |
      | 4 | 6 | 6 |

  @case:130 @priority:medium
  Scenario: A freed room can be taken again
    Given a fresh night for the scarce room
    And the scarce room is held for that window
    And that hold is cancelled
    When the scarce room is held for that window again
    Then the hold succeeds
