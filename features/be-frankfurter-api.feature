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
    @case:571
    Examples:
      | low | high |
      | 0.10 | 0.20 |
    @case:572
    Examples:
      | low | high |
      | 0.15 | 0.28 |
    @case:573
    Examples:
      | low | high |
      | 0.20 | 0.36 |
    @case:574
    Examples:
      | low | high |
      | 0.25 | 0.44 |
    @case:575
    Examples:
      | low | high |
      | 0.30 | 0.52 |
    @case:576
    Examples:
      | low | high |
      | 0.35 | 0.60 |
    @case:577
    Examples:
      | low | high |
      | 0.40 | 0.68 |
    @case:578
    Examples:
      | low | high |
      | 0.45 | 0.55 |
    @case:579
    Examples:
      | low | high |
      | 0.50 | 0.63 |
    @case:580
    Examples:
      | low | high |
      | 0.55 | 0.71 |
    @case:581
    Examples:
      | low | high |
      | 0.60 | 0.79 |
    @case:582
    Examples:
      | low | high |
      | 0.65 | 0.87 |
    @case:583
    Examples:
      | low | high |
      | 0.70 | 0.95 |
    @case:584
    Examples:
      | low | high |
      | 0.75 | 1.03 |
    @case:585
    Examples:
      | low | high |
      | 0.80 | 0.90 |
    @case:586
    Examples:
      | low | high |
      | 0.85 | 0.98 |
    @case:587
    Examples:
      | low | high |
      | 0.90 | 1.06 |
    @case:588
    Examples:
      | low | high |
      | 0.95 | 1.14 |
    @case:589
    Examples:
      | low | high |
      | 1.00 | 1.22 |
    @case:590
    Examples:
      | low | high |
      | 1.05 | 1.30 |
    @case:591
    Examples:
      | low | high |
      | 1.10 | 1.38 |
    @case:592
    Examples:
      | low | high |
      | 1.15 | 1.25 |
    @case:593
    Examples:
      | low | high |
      | 1.20 | 1.33 |
    @case:594
    Examples:
      | low | high |
      | 1.25 | 1.41 |
    @case:595
    Examples:
      | low | high |
      | 1.30 | 1.49 |
    @case:596
    Examples:
      | low | high |
      | 1.35 | 1.57 |
    @case:597
    Examples:
      | low | high |
      | 1.40 | 1.65 |
    @case:598
    Examples:
      | low | high |
      | 1.45 | 1.73 |
    @case:599
    Examples:
      | low | high |
      | 1.50 | 1.60 |
    @case:600
    Examples:
      | low | high |
      | 1.55 | 1.68 |
    @case:601
    Examples:
      | low | high |
      | 0.10 | 0.26 |
    @case:602
    Examples:
      | low | high |
      | 0.15 | 0.34 |
    @case:603
    Examples:
      | low | high |
      | 0.20 | 0.42 |
    @case:604
    Examples:
      | low | high |
      | 0.25 | 0.50 |
    @case:605
    Examples:
      | low | high |
      | 0.30 | 0.58 |
    @case:606
    Examples:
      | low | high |
      | 0.35 | 0.45 |
    @case:607
    Examples:
      | low | high |
      | 0.40 | 0.53 |
    @case:608
    Examples:
      | low | high |
      | 0.45 | 0.61 |
    @case:609
    Examples:
      | low | high |
      | 0.50 | 0.69 |
    @case:610
    Examples:
      | low | high |
      | 0.55 | 0.77 |
    @case:611
    Examples:
      | low | high |
      | 0.60 | 0.85 |
    @case:612
    Examples:
      | low | high |
      | 0.65 | 0.93 |
    @case:613
    Examples:
      | low | high |
      | 0.70 | 0.80 |
    @case:614
    Examples:
      | low | high |
      | 0.75 | 0.88 |
    @case:615
    Examples:
      | low | high |
      | 0.80 | 0.96 |
    @case:616
    Examples:
      | low | high |
      | 0.85 | 1.04 |
    @case:617
    Examples:
      | low | high |
      | 0.90 | 1.12 |
    @case:618
    Examples:
      | low | high |
      | 0.95 | 1.20 |
    @case:619
    Examples:
      | low | high |
      | 1.00 | 1.28 |
    @case:620
    Examples:
      | low | high |
      | 1.05 | 1.15 |
    @case:621
    Examples:
      | low | high |
      | 1.10 | 1.23 |
    @case:622
    Examples:
      | low | high |
      | 1.15 | 1.31 |
    @case:623
    Examples:
      | low | high |
      | 1.20 | 1.39 |
    @case:624
    Examples:
      | low | high |
      | 1.25 | 1.47 |
    @case:625
    Examples:
      | low | high |
      | 1.30 | 1.55 |
    @case:626
    Examples:
      | low | high |
      | 1.35 | 1.63 |
    @case:627
    Examples:
      | low | high |
      | 1.40 | 1.50 |
    @case:628
    Examples:
      | low | high |
      | 1.45 | 1.58 |
    @case:629
    Examples:
      | low | high |
      | 1.50 | 1.66 |
    @case:630
    Examples:
      | low | high |
      | 1.55 | 1.74 |
    @case:631
    Examples:
      | low | high |
      | 0.10 | 0.32 |
    @case:632
    Examples:
      | low | high |
      | 0.15 | 0.40 |
    @case:633
    Examples:
      | low | high |
      | 0.20 | 0.48 |
    @case:634
    Examples:
      | low | high |
      | 0.25 | 0.35 |
    @case:635
    Examples:
      | low | high |
      | 0.30 | 0.43 |
    @case:636
    Examples:
      | low | high |
      | 0.35 | 0.51 |
    @case:637
    Examples:
      | low | high |
      | 0.40 | 0.59 |
    @case:638
    Examples:
      | low | high |
      | 0.45 | 0.67 |
    @case:639
    Examples:
      | low | high |
      | 0.50 | 0.75 |
    @case:640
    Examples:
      | low | high |
      | 0.55 | 0.83 |
    @case:641
    Examples:
      | low | high |
      | 0.60 | 0.70 |
    @case:642
    Examples:
      | low | high |
      | 0.65 | 0.78 |
    @case:643
    Examples:
      | low | high |
      | 0.70 | 0.86 |
    @case:644
    Examples:
      | low | high |
      | 0.75 | 0.94 |
    @case:645
    Examples:
      | low | high |
      | 0.80 | 1.02 |
    @case:646
    Examples:
      | low | high |
      | 0.85 | 1.10 |
    @case:647
    Examples:
      | low | high |
      | 0.90 | 1.18 |
    @case:648
    Examples:
      | low | high |
      | 0.95 | 1.05 |
    @case:649
    Examples:
      | low | high |
      | 1.00 | 1.13 |
    @case:650
    Examples:
      | low | high |
      | 1.05 | 1.21 |
    @case:651
    Examples:
      | low | high |
      | 1.10 | 1.29 |
    @case:652
    Examples:
      | low | high |
      | 1.15 | 1.37 |
    @case:653
    Examples:
      | low | high |
      | 1.20 | 1.45 |
    @case:654
    Examples:
      | low | high |
      | 1.25 | 1.53 |
    @case:655
    Examples:
      | low | high |
      | 1.30 | 1.40 |
    @case:656
    Examples:
      | low | high |
      | 1.35 | 1.48 |
    @case:657
    Examples:
      | low | high |
      | 1.40 | 1.56 |
    @case:658
    Examples:
      | low | high |
      | 1.45 | 1.64 |
    @case:659
    Examples:
      | low | high |
      | 1.50 | 1.72 |
    @case:660
    Examples:
      | low | high |
      | 1.55 | 1.80 |
    @case:661
    Examples:
      | low | high |
      | 0.10 | 0.38 |
    @case:662
    Examples:
      | low | high |
      | 0.15 | 0.25 |
    @case:663
    Examples:
      | low | high |
      | 0.20 | 0.33 |
    @case:664
    Examples:
      | low | high |
      | 0.25 | 0.41 |
    @case:665
    Examples:
      | low | high |
      | 0.30 | 0.49 |
    @case:666
    Examples:
      | low | high |
      | 0.35 | 0.57 |
    @case:667
    Examples:
      | low | high |
      | 0.40 | 0.65 |
    @case:668
    Examples:
      | low | high |
      | 0.45 | 0.73 |
    @case:669
    Examples:
      | low | high |
      | 0.50 | 0.60 |
    @case:670
    Examples:
      | low | high |
      | 0.55 | 0.68 |
    @case:671
    Examples:
      | low | high |
      | 0.60 | 0.76 |
    @case:672
    Examples:
      | low | high |
      | 0.65 | 0.84 |
    @case:673
    Examples:
      | low | high |
      | 0.70 | 0.92 |
    @case:674
    Examples:
      | low | high |
      | 0.75 | 1.00 |
    @case:675
    Examples:
      | low | high |
      | 0.80 | 1.08 |
    @case:676
    Examples:
      | low | high |
      | 0.85 | 0.95 |
    @case:677
    Examples:
      | low | high |
      | 0.90 | 1.03 |
    @case:678
    Examples:
      | low | high |
      | 0.95 | 1.11 |
    @case:679
    Examples:
      | low | high |
      | 1.00 | 1.19 |
    @case:680
    Examples:
      | low | high |
      | 1.05 | 1.27 |
    @case:681
    Examples:
      | low | high |
      | 1.10 | 1.35 |
    @case:682
    Examples:
      | low | high |
      | 1.15 | 1.43 |
    @case:683
    Examples:
      | low | high |
      | 1.20 | 1.30 |
    @case:684
    Examples:
      | low | high |
      | 1.25 | 1.38 |
    @case:685
    Examples:
      | low | high |
      | 1.30 | 1.46 |
    @case:686
    Examples:
      | low | high |
      | 1.35 | 1.54 |
    @case:687
    Examples:
      | low | high |
      | 1.40 | 1.62 |
    @case:688
    Examples:
      | low | high |
      | 1.45 | 1.70 |
    @case:689
    Examples:
      | low | high |
      | 1.50 | 1.78 |
    @case:690
    Examples:
      | low | high |
      | 1.55 | 1.65 |
    @case:691
    Examples:
      | low | high |
      | 0.10 | 0.23 |
    @case:692
    Examples:
      | low | high |
      | 0.15 | 0.31 |
    @case:693
    Examples:
      | low | high |
      | 0.20 | 0.39 |
    @case:694
    Examples:
      | low | high |
      | 0.25 | 0.47 |
    @case:695
    Examples:
      | low | high |
      | 0.30 | 0.55 |
    @case:696
    Examples:
      | low | high |
      | 0.35 | 0.63 |
    @case:697
    Examples:
      | low | high |
      | 0.40 | 0.50 |
    @case:698
    Examples:
      | low | high |
      | 0.45 | 0.58 |
    @case:699
    Examples:
      | low | high |
      | 0.50 | 0.66 |
    @case:700
    Examples:
      | low | high |
      | 0.55 | 0.74 |
    @case:701
    Examples:
      | low | high |
      | 0.60 | 0.82 |
    @case:702
    Examples:
      | low | high |
      | 0.65 | 0.90 |
    @case:703
    Examples:
      | low | high |
      | 0.70 | 0.98 |
    @case:704
    Examples:
      | low | high |
      | 0.75 | 0.85 |
    @case:705
    Examples:
      | low | high |
      | 0.80 | 0.93 |
    @case:706
    Examples:
      | low | high |
      | 0.85 | 1.01 |
    @case:707
    Examples:
      | low | high |
      | 0.90 | 1.09 |
    @case:708
    Examples:
      | low | high |
      | 0.95 | 1.17 |
    @case:709
    Examples:
      | low | high |
      | 1.00 | 1.25 |
    @case:710
    Examples:
      | low | high |
      | 1.05 | 1.33 |
    @case:711
    Examples:
      | low | high |
      | 1.10 | 1.20 |
    @case:712
    Examples:
      | low | high |
      | 1.15 | 1.28 |
    @case:713
    Examples:
      | low | high |
      | 1.20 | 1.36 |
    @case:714
    Examples:
      | low | high |
      | 1.25 | 1.44 |
    @case:715
    Examples:
      | low | high |
      | 1.30 | 1.52 |
    @case:716
    Examples:
      | low | high |
      | 1.35 | 1.60 |
    @case:717
    Examples:
      | low | high |
      | 1.40 | 1.68 |
    @case:718
    Examples:
      | low | high |
      | 1.45 | 1.55 |
    @case:719
    Examples:
      | low | high |
      | 1.50 | 1.63 |
    @case:720
    Examples:
      | low | high |
      | 1.55 | 1.71 |


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
