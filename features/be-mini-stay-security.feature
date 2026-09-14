@module:05-mini-stay-security @be @api @stay @security
Feature: The mini-stay authorization surface, probed like an attacker

  Guests, hoteliers and the operator share one API, so the only thing keeping one
  party out of another's data is the token check on each route. This tier probes
  those checks directly: a request with no token, a forged token, the wrong
  party's token, or a valid token for a booking or hotel that is not yours must
  be refused -- 401 when the caller is not authenticated, 403 when they are but
  not allowed, 404 when the answer must not even reveal a booking exists. The
  positive controls confirm the rightful owner still gets through.

  Background:
    Given the store is open and the service is reachable

  # ---------------------------------------------------------------- the booking gate

  @case:131 @priority:high
  Scenario: Holding a room requires a guest token
    When a room is held with no token
    Then the response status is 401
    And the response is an error with code "unauthenticated"

  @case:132 @priority:high
  Scenario: A forged guest token is refused
    When a room is held with a forged token
    Then the response status is 401

  @case:133 @priority:high
  Scenario: A hotelier token is not accepted as a guest
    When a hotelier tries to hold a room
    Then the response status is 401

  @case:134 @priority:high
  Scenario: A guest token is not accepted at the front desk
    Given a confirmed booking
    When the guest tries to check the booking in
    Then the response status is 401

  # ---------------------------------------------------------------- cross-party access (IDOR)

  @case:135 @priority:high
  Scenario: A guest cannot read another guest's booking
    Given another guest has a booking
    When the guest reads that booking
    Then the response status is 404

  @case:136 @priority:high
  Scenario: A guest cannot cancel another guest's booking
    Given another guest has a booking
    When the guest cancels that booking
    Then the response status is 404

  @case:137 @priority:high
  Scenario: A guest cannot confirm another guest's booking
    Given another guest has a booking
    When the guest confirms that booking
    Then the response status is 404

  @case:138 @priority:high
  Scenario: A hotelier cannot work a hotel it does not own
    Given a confirmed booking
    When a hotelier who owns no hotel checks the booking in
    Then the response status is 403

  # ---------------------------------------------------------------- the operator gate

  @case:139 @priority:high
  Scenario: The admin overview rejects a guest token
    Given a guest
    When the overview is read with the guest's token
    Then the response status is 401

  @case:140 @priority:high
  Scenario: The admin booking list rejects a guest token
    Given a guest
    When the admin booking list is read with the guest's token
    Then the response status is 401

  @case:141 @priority:high
  Scenario: A token that only extends the admin token is rejected
    When the overview is read with a token that extends the admin token
    Then the response status is 401

  # ---------------------------------------------------------------- positive controls

  @case:142 @priority:high
  Scenario: The owning guest still reads their own booking
    Given a held booking
    When the guest reads the booking
    Then the response status is 200

  @case:143 @priority:high
  Scenario: The owning hotelier still checks a guest in
    Given a confirmed booking
    When the hotelier checks the booking in
    Then the response status is 200

  @case:144 @priority:medium
  Scenario: Guest onboarding is open and issues a token
    When a guest registers
    Then the response status is 201
    And the response carries a token

  # ---------------------------------------------------------------- secret hygiene

  @case:145 @priority:medium
  Scenario: A quote response never carries a bearer token
    Given a priced quote
    Then the quote response carries no bearer token

  @case:146 @priority:medium
  Scenario: A booking response never carries a bearer token
    Given a held booking
    Then the booking response carries no bearer token

  @case:147 @priority:medium
  Scenario: A booking read never carries a bearer token
    Given a held booking
    When the guest reads the booking
    Then the read response carries no bearer token

  @case:148 @priority:medium
  Scenario: The admin overview never carries a bearer token
    Given a held booking
    When the admin reads the overview
    Then the overview response carries no bearer token
