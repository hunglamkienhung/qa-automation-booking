@module:06-mini-stay-fe @fe @stay
Feature: The mini-stay app surfaces, checked against their own data

  Playwright drives the pages the mini-stay service renders -- the hotel home, a
  hotel's rooms, a booking, a guest's bookings and the admin overview. The
  figures on screen are compared with the rows behind them, read through the DB
  the FE never touches directly, so the FE branch checks the same invariants the
  BE branch does, one layer further out. A page that never loads is Blocked,
  never Failed.

  Background:
    Given the store is open and the service is reachable
    And the home page is open

  # ---------------------------------------------------------------- home

  @case:149 @priority:high
  Scenario: The home page lists exactly the active hotels
    Then the home page lists the active hotels, once each

  @case:150 @priority:high
  Scenario: The inactive hotel does not appear on the home page
    Then the home page does not list the inactive hotel

  @case:151 @priority:medium
  Scenario: Each hotel row shows a currency code
    Then every hotel row shows a three-letter currency code

  @case:152 @priority:low
  Scenario: The home page is not empty
    Then the home page shows at least one hotel

  # ---------------------------------------------------------------- a hotel's rooms

  @case:153 @priority:high
  Scenario: A hotel page lists its room types
    When the hotel page for hotel 1 is opened
    Then every room name on screen equals the room row

  @case:154 @priority:high
  Scenario: Room rates are shown in the hotel's currency
    When the hotel page for hotel 1 is opened
    Then every room rate on screen equals the room row in the hotel's currency

  @case:155 @priority:medium
  Scenario: Each room shows its inventory and cancellation policy
    When the hotel page for hotel 2 is opened
    Then every room shows its inventory and cancellation policy from the rows

  @case:156 @priority:low
  Scenario: An unknown hotel page is not found
    When the hotel page for hotel 999 is opened
    Then the page reports not found

  # ---------------------------------------------------------------- a booking

  @case:157 @priority:high
  Scenario: A booking page shows the total it was priced at
    Given a held booking
    When the booking page is opened
    Then the booking page total equals the stored total

  @case:158 @priority:high
  Scenario: A booking page shows the nights and status
    Given a held booking
    When the booking page is opened
    Then the booking page shows the nights from the row
    And the booking page shows status "held"

  @case:159 @priority:medium
  Scenario: A booking page total is a currency amount
    Given a held booking
    When the booking page is opened
    Then the booking page total is shown as a currency amount

  @case:160 @priority:low
  Scenario: An unknown booking page is not found
    When the booking page for 999999 is opened
    Then the page reports not found

  Scenario Outline: A <state> booking page shows that status
    Given a held booking
    And the booking reaches <state>
    When the booking page is opened
    Then the booking page shows status "<state>"

    @case:161
    Examples:
      | state |
      | confirmed |
    @case:162
    Examples:
      | state |
      | cancelled |

  # ---------------------------------------------------------------- a guest's bookings

  @case:163 @priority:high
  Scenario: A guest's booking list shows the booking they held
    Given a held booking
    When the guest's booking list is opened
    Then the guest's booking list includes the held booking

  @case:164 @priority:medium
  Scenario: Each booking row links to its booking page
    Given a held booking
    When the guest's booking list is opened
    Then each booking row links to its booking page

  @case:165 @priority:medium
  Scenario: A booking list total is a currency amount
    Given a held booking
    When the guest's booking list is opened
    Then every booking row total is a currency amount

  # ---------------------------------------------------------------- admin overview

  @case:166 @priority:high
  Scenario: The admin page shows the payment taken as a number
    When the admin page is opened
    Then the admin payment is shown as a number

  @case:167 @priority:medium
  Scenario: Every admin status count is a non-negative integer
    When the admin page is opened
    Then every admin status count is a non-negative integer

  @case:168 @priority:medium
  Scenario: A confirmed booking shows up in the admin counts
    Given a confirmed booking
    When the admin page is opened
    Then the admin counts include a confirmed booking
