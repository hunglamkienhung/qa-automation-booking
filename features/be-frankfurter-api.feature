@module:07-frankfurter-api @be @api @frankfurter
Feature: Frankfurter's public FX API, read-only, and the conversion built on it

  Two things are checked here. `convert` is a pure function -- it turns a price in
  one currency into another at a given rate, in whole cents with half-up
  rounding -- so its scenarios are deterministic and need no network. The live
  scenarios read Frankfurter over HTTPS with no key: a settled historical date
  returns rates asserted by value and for stability across two reads; the latest
  endpoint moves with the market, so it is asserted on shape and range only.
  Converting a real stay price at a real historical rate shows the path a
  multi-currency quote would take end to end.

  On a transport failure -- the API unreachable, timing out, or serving a
  challenge page -- the live scenarios report Blocked, never Failed: the rate
  service being unreachable is not a rate being wrong.

  # ---------------------------------------------------------------- the conversion (pure, deterministic)

  @case:169 @priority:high
  Scenario: Converting at parity leaves the amount unchanged
    When the conversion of 99999 cents at rate 1.0 is computed
    Then the conversion is 99999

  @case:170 @priority:high
  Scenario: Converting at a half rate halves the amount
    When the conversion of 26880 cents at rate 0.5 is computed
    Then the conversion is 13440

  @case:171 @priority:high
  Scenario: Converting nothing is nothing
    When the conversion of 0 cents at rate 1.2345 is computed
    Then the conversion is 0

  @case:172 @priority:high
  Scenario: An inexact conversion rounds half-up to the cent
    When the conversion of 12345 cents at rate 1.2345 is computed
    Then the conversion is 15240

  @case:173 @priority:medium
  Scenario: A rate above parity raises the amount
    When the conversion of 100000 cents at rate 1.1 is computed
    Then the conversion is 110000

  Scenario Outline: Converting <cents> at rate <rate> gives <out>
    When the conversion of <cents> cents at rate <rate> is computed
    Then the conversion is <out>

    @case:174
    Examples:
      | cents | rate | out |
      | 100000 | 0.9 | 90000 |
    @case:175
    Examples:
      | cents | rate | out |
      | 200000 | 0.75 | 150000 |
    @case:176
    Examples:
      | cents | rate | out |
      | 33333 | 1.5 | 50000 |
    @case:177
    Examples:
      | cents | rate | out |
      | 26880 | 0.91274 | 24534 |
    @case:178
    Examples:
      | cents | rate | out |
      | 50000 | 0.8 | 40000 |
    @case:179
    Examples:
      | cents | rate | out |
      | 123456 | 1.25 | 154320 |
    @case:180
    Examples:
      | cents | rate | out |
      | 1000000 | 0.333 | 333000 |
    @case:181
    Examples:
      | cents | rate | out |
      | 89600 | 0.79085 | 70860 |
    @case:243
    Examples:
      | cents | rate | out |
      | 40320 | 0.9 | 36288 |
    @case:244
    Examples:
      | cents | rate | out |
      | 49280 | 1.1 | 54208 |
    @case:245
    Examples:
      | cents | rate | out |
      | 34500 | 0.86 | 29670 |
    @case:246
    Examples:
      | cents | rate | out |
      | 89700 | 0.75 | 67275 |
    @case:247
    Examples:
      | cents | rate | out |
      | 15000 | 1.05 | 15750 |
    @case:248
    Examples:
      | cents | rate | out |
      | 75000 | 0.9128 | 68460 |
    @case:249
    Examples:
      | cents | rate | out |
      | 250000 | 0.5 | 125000 |
    @case:250
    Examples:
      | cents | rate | out |
      | 9999 | 1.3333 | 13332 |

  Scenario Outline: A higher rate never converts to less, from <low> to <high>
    When the conversion of 100000 cents at rate <low> is noted
    And the conversion of 100000 cents at rate <high> is computed
    Then the conversion is at least the noted conversion

    @case:182
    Examples:
      | low | high |
      | 0.5 | 0.9 |
    @case:183
    Examples:
      | low | high |
      | 0.9 | 1.5 |
    @case:184
    Examples:
      | low | high |
      | 1.0 | 2.0 |

  # ---------------------------------------------------------------- the live historical rate (value-stable)

  @case:185 @priority:high
  Scenario: The historical endpoint answers with rates
    When the historical rates are fetched
    Then the historical response carries a rates object

  @case:186 @priority:high
  Scenario: The historical response is for one unit of the base currency
    When the historical rates are fetched
    Then the historical response is one unit of US dollars

  @case:187 @priority:high
  Scenario: The historical euro rate is a positive number
    When the historical rates are fetched
    Then the historical euro rate is a positive number

  @case:188 @priority:medium
  Scenario: The historical pound rate is a positive number
    When the historical rates are fetched
    Then the historical pound rate is a positive number

  @case:189 @priority:high
  Scenario: The historical rate is stable across two reads
    When the historical rates are fetched
    And the historical rates are fetched again
    Then both historical reads return identical rates

  @case:190 @priority:high
  Scenario: A stay converted at the real historical euro rate is positive and consistent
    When the historical rates are fetched
    And a stay total of 26880 is converted at the historical euro rate
    Then the converted stay is positive and equals the pure conversion

  @case:191 @priority:medium
  Scenario: A stay converted at the real historical pound rate is positive and consistent
    When the historical rates are fetched
    And a stay total of 89600 is converted at the historical pound rate
    Then the converted stay is positive and equals the pure conversion

  # ---------------------------------------------------------------- the live latest rate (shape only)

  @case:192 @priority:high
  Scenario: The latest endpoint answers with a rates object
    When the latest rates are fetched
    Then the latest response carries a rates object

  @case:193 @priority:medium
  Scenario: The latest euro rate is a positive finite number
    When the latest rates are fetched
    Then the latest euro rate is a positive finite number

  @case:194 @priority:medium
  Scenario: The latest response names its date
    When the latest rates are fetched
    Then the latest response names a date

  @case:195 @priority:low
  Scenario: Every latest rate is a positive number
    When the latest rates are fetched
    Then every latest rate is a positive number

  @case:196 @priority:low
  Scenario: The latest response is one unit of the base currency
    When the latest rates are fetched
    Then the latest response is one unit of US dollars
