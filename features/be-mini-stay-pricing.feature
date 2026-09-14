@module:02-mini-stay-pricing @be @api @stay @pricing
Feature: Pricing a stay

  A stay costs the nights times the room's nightly rate, plus the hotel's tax
  charged as integer basis points on that subtotal, rounded half-up to the cent.
  Everything is whole cents, so the two stacks agree exactly.

  These scenarios pin the arithmetic with golden numbers, check it against an
  independent reimplementation across a grid of rooms and lengths, confirm each
  quote is internally consistent, and reject inputs a hotel must never price.

  Background:
    Given the store is open and the service is reachable

  # ---------------------------------------------------------------- golden numbers

  @case:41 @priority:high
  Scenario: A two-night standard double is priced to the cent
    When I request a quote for room 1 for 2 nights
    Then the quote total is 26880

  @case:42 @priority:high
  Scenario: A three-night standard double
    When I request a quote for room 1 for 3 nights
    Then the quote total is 40320

  @case:43 @priority:high
  Scenario: A two-night sea-view suite
    When I request a quote for room 2 for 2 nights
    Then the quote total is 49280

  @case:44 @priority:high
  Scenario: A one-night penthouse
    When I request a quote for room 3 for 1 nights
    Then the quote total is 89600

  @case:45 @priority:high
  Scenario: A two-night queen room at the other hotel's tax rate
    When I request a quote for room 4 for 2 nights
    Then the quote total is 34500

  @case:46 @priority:high
  Scenario: A three-night family cabin
    When I request a quote for room 5 for 3 nights
    Then the quote total is 89700

  @case:47 @priority:medium
  Scenario: A quote is internally consistent
    When I request a quote for room 2 for 4 nights
    Then the quote is internally consistent

  @case:48 @priority:medium
  Scenario: A quote carries the room's cancellation policy
    When I request a quote for room 3 for 2 nights
    Then the quote shows the cancellation policy "nonrefundable"

  @case:49 @priority:medium
  Scenario: A quote reports the number of nights it priced
    When I request a quote for room 1 for 5 nights
    Then the quote is for 5 nights

  # ---------------------------------------------------------------- the grid, against an independent formula

  Scenario Outline: <label> prices to the reference formula
    When I request a quote for room <room> for <nights> nights
    Then the quote total matches the pricing formula

    @case:50
    Examples:
      | label | room | nights |
      | double 1 night | 1 | 1 |
    @case:51
    Examples:
      | label | room | nights |
      | double 4 nights | 1 | 4 |
    @case:52
    Examples:
      | label | room | nights |
      | double 7 nights | 1 | 7 |
    @case:53
    Examples:
      | label | room | nights |
      | double 14 nights | 1 | 14 |
    @case:54
    Examples:
      | label | room | nights |
      | suite 1 night | 2 | 1 |
    @case:55
    Examples:
      | label | room | nights |
      | suite 5 nights | 2 | 5 |
    @case:56
    Examples:
      | label | room | nights |
      | suite 10 nights | 2 | 10 |
    @case:57
    Examples:
      | label | room | nights |
      | penthouse 2 nights | 3 | 2 |
    @case:58
    Examples:
      | label | room | nights |
      | penthouse 3 nights | 3 | 3 |
    @case:59
    Examples:
      | label | room | nights |
      | penthouse 7 nights | 3 | 7 |
    @case:60
    Examples:
      | label | room | nights |
      | queen 1 night | 4 | 1 |
    @case:61
    Examples:
      | label | room | nights |
      | queen 3 nights | 4 | 3 |
    @case:62
    Examples:
      | label | room | nights |
      | queen 8 nights | 4 | 8 |
    @case:63
    Examples:
      | label | room | nights |
      | cabin 1 night | 5 | 1 |
    @case:64
    Examples:
      | label | room | nights |
      | cabin 2 nights | 5 | 2 |
    @case:65
    Examples:
      | label | room | nights |
      | cabin 6 nights | 5 | 6 |
    @case:66
    Examples:
      | label | room | nights |
      | cabin 12 nights | 5 | 12 |
    @case:67
    Examples:
      | label | room | nights |
      | double 21 nights | 1 | 21 |
    @case:68
    Examples:
      | label | room | nights |
      | suite 30 nights | 2 | 30 |
    @case:69
    Examples:
      | label | room | nights |
      | queen 15 nights | 4 | 15 |
    @case:197
    Examples:
      | label | room | nights |
      | double 2 nights b | 1 | 2 |
    @case:198
    Examples:
      | label | room | nights |
      | double 5 nights | 1 | 5 |
    @case:199
    Examples:
      | label | room | nights |
      | double 9 nights | 1 | 9 |
    @case:200
    Examples:
      | label | room | nights |
      | double 28 nights | 1 | 28 |
    @case:201
    Examples:
      | label | room | nights |
      | suite 2 nights b | 2 | 2 |
    @case:202
    Examples:
      | label | room | nights |
      | suite 3 nights | 2 | 3 |
    @case:203
    Examples:
      | label | room | nights |
      | suite 7 nights | 2 | 7 |
    @case:204
    Examples:
      | label | room | nights |
      | suite 21 nights | 2 | 21 |
    @case:205
    Examples:
      | label | room | nights |
      | penthouse 1 night b | 3 | 1 |
    @case:206
    Examples:
      | label | room | nights |
      | penthouse 5 nights | 3 | 5 |
    @case:207
    Examples:
      | label | room | nights |
      | penthouse 14 nights | 3 | 14 |
    @case:208
    Examples:
      | label | room | nights |
      | queen 2 nights | 4 | 2 |
    @case:209
    Examples:
      | label | room | nights |
      | queen 5 nights | 4 | 5 |
    @case:210
    Examples:
      | label | room | nights |
      | queen 10 nights | 4 | 10 |
    @case:211
    Examples:
      | label | room | nights |
      | cabin 3 nights | 5 | 3 |
    @case:212
    Examples:
      | label | room | nights |
      | cabin 4 nights | 5 | 4 |
    @case:213
    Examples:
      | label | room | nights |
      | cabin 9 nights | 5 | 9 |
    @case:214
    Examples:
      | label | room | nights |
      | cabin 20 nights | 5 | 20 |
    @case:215
    Examples:
      | label | room | nights |
      | double 12 nights | 1 | 12 |
    @case:216
    Examples:
      | label | room | nights |
      | suite 6 nights | 2 | 6 |

  # ---------------------------------------------------------------- inputs a hotel must never price

  @case:70 @priority:high
  Scenario: A check-out on the check-in day is refused
    When I request a quote for room 1 with a zero-night stay
    Then the quote is refused with code "bad_dates"

  @case:71 @priority:high
  Scenario: A stay that is not a whole number of nights is refused
    When I request a quote for room 1 for half a night
    Then the quote is refused with code "bad_dates"

  @case:72 @priority:medium
  Scenario: A quote for a room that does not exist is not found
    When I request a quote for room 999 for 2 nights
    Then the quote is refused with status 404

  @case:73 @priority:high
  Scenario: A room at an inactive hotel cannot be priced
    When I request a quote for room 6 for 2 nights
    Then the quote is refused with code "hotel_inactive"

  @case:74 @priority:medium
  Scenario: A check-out before the check-in is refused
    When I request a quote for room 1 with check-out before check-in
    Then the quote is refused with code "bad_dates"
