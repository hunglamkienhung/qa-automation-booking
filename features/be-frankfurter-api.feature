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

    @case:401
    Examples:
      | low | high |
      | 0.10 | 0.20 |
    @case:402
    Examples:
      | low | high |
      | 0.15 | 0.28 |
    @case:403
    Examples:
      | low | high |
      | 0.20 | 0.36 |
    @case:404
    Examples:
      | low | high |
      | 0.25 | 0.44 |
    @case:405
    Examples:
      | low | high |
      | 0.30 | 0.52 |
    @case:406
    Examples:
      | low | high |
      | 0.35 | 0.60 |
    @case:407
    Examples:
      | low | high |
      | 0.40 | 0.68 |
    @case:408
    Examples:
      | low | high |
      | 0.45 | 0.55 |
    @case:409
    Examples:
      | low | high |
      | 0.50 | 0.63 |
    @case:410
    Examples:
      | low | high |
      | 0.55 | 0.71 |
    @case:411
    Examples:
      | low | high |
      | 0.60 | 0.79 |
    @case:412
    Examples:
      | low | high |
      | 0.65 | 0.87 |
    @case:413
    Examples:
      | low | high |
      | 0.70 | 0.95 |
    @case:414
    Examples:
      | low | high |
      | 0.75 | 1.03 |
    @case:415
    Examples:
      | low | high |
      | 0.80 | 0.90 |
    @case:416
    Examples:
      | low | high |
      | 0.85 | 0.98 |
    @case:417
    Examples:
      | low | high |
      | 0.90 | 1.06 |
    @case:418
    Examples:
      | low | high |
      | 0.95 | 1.14 |
    @case:419
    Examples:
      | low | high |
      | 1.00 | 1.22 |
    @case:420
    Examples:
      | low | high |
      | 1.05 | 1.30 |
    @case:421
    Examples:
      | low | high |
      | 1.10 | 1.38 |
    @case:422
    Examples:
      | low | high |
      | 1.15 | 1.25 |
    @case:423
    Examples:
      | low | high |
      | 1.20 | 1.33 |
    @case:424
    Examples:
      | low | high |
      | 1.25 | 1.41 |
    @case:425
    Examples:
      | low | high |
      | 1.30 | 1.49 |
    @case:426
    Examples:
      | low | high |
      | 1.35 | 1.57 |
    @case:427
    Examples:
      | low | high |
      | 1.40 | 1.65 |
    @case:428
    Examples:
      | low | high |
      | 1.45 | 1.73 |
    @case:429
    Examples:
      | low | high |
      | 1.50 | 1.60 |
    @case:430
    Examples:
      | low | high |
      | 1.55 | 1.68 |
    @case:431
    Examples:
      | low | high |
      | 0.10 | 0.26 |
    @case:432
    Examples:
      | low | high |
      | 0.15 | 0.34 |
    @case:433
    Examples:
      | low | high |
      | 0.20 | 0.42 |
    @case:434
    Examples:
      | low | high |
      | 0.25 | 0.50 |
    @case:435
    Examples:
      | low | high |
      | 0.30 | 0.58 |
    @case:436
    Examples:
      | low | high |
      | 0.35 | 0.45 |
    @case:437
    Examples:
      | low | high |
      | 0.40 | 0.53 |
    @case:438
    Examples:
      | low | high |
      | 0.45 | 0.61 |
    @case:439
    Examples:
      | low | high |
      | 0.50 | 0.69 |
    @case:440
    Examples:
      | low | high |
      | 0.55 | 0.77 |
    @case:441
    Examples:
      | low | high |
      | 0.60 | 0.85 |
    @case:442
    Examples:
      | low | high |
      | 0.65 | 0.93 |
    @case:443
    Examples:
      | low | high |
      | 0.70 | 0.80 |
    @case:444
    Examples:
      | low | high |
      | 0.75 | 0.88 |
    @case:445
    Examples:
      | low | high |
      | 0.80 | 0.96 |
    @case:446
    Examples:
      | low | high |
      | 0.85 | 1.04 |
    @case:447
    Examples:
      | low | high |
      | 0.90 | 1.12 |
    @case:448
    Examples:
      | low | high |
      | 0.95 | 1.20 |
    @case:449
    Examples:
      | low | high |
      | 1.00 | 1.28 |
    @case:450
    Examples:
      | low | high |
      | 1.05 | 1.15 |
    @case:451
    Examples:
      | low | high |
      | 1.10 | 1.23 |
    @case:452
    Examples:
      | low | high |
      | 1.15 | 1.31 |
    @case:453
    Examples:
      | low | high |
      | 1.20 | 1.39 |
    @case:454
    Examples:
      | low | high |
      | 1.25 | 1.47 |
    @case:455
    Examples:
      | low | high |
      | 1.30 | 1.55 |
    @case:456
    Examples:
      | low | high |
      | 1.35 | 1.63 |
    @case:457
    Examples:
      | low | high |
      | 1.40 | 1.50 |
    @case:458
    Examples:
      | low | high |
      | 1.45 | 1.58 |
    @case:459
    Examples:
      | low | high |
      | 1.50 | 1.66 |
    @case:460
    Examples:
      | low | high |
      | 1.55 | 1.74 |
    @case:461
    Examples:
      | low | high |
      | 0.10 | 0.32 |
    @case:462
    Examples:
      | low | high |
      | 0.15 | 0.40 |
    @case:463
    Examples:
      | low | high |
      | 0.20 | 0.48 |
    @case:464
    Examples:
      | low | high |
      | 0.25 | 0.35 |
    @case:465
    Examples:
      | low | high |
      | 0.30 | 0.43 |
    @case:466
    Examples:
      | low | high |
      | 0.35 | 0.51 |
    @case:467
    Examples:
      | low | high |
      | 0.40 | 0.59 |
    @case:468
    Examples:
      | low | high |
      | 0.45 | 0.67 |
    @case:469
    Examples:
      | low | high |
      | 0.50 | 0.75 |
    @case:470
    Examples:
      | low | high |
      | 0.55 | 0.83 |
    @case:471
    Examples:
      | low | high |
      | 0.60 | 0.70 |
    @case:472
    Examples:
      | low | high |
      | 0.65 | 0.78 |
    @case:473
    Examples:
      | low | high |
      | 0.70 | 0.86 |
    @case:474
    Examples:
      | low | high |
      | 0.75 | 0.94 |
    @case:475
    Examples:
      | low | high |
      | 0.80 | 1.02 |
    @case:476
    Examples:
      | low | high |
      | 0.85 | 1.10 |
    @case:477
    Examples:
      | low | high |
      | 0.90 | 1.18 |
    @case:478
    Examples:
      | low | high |
      | 0.95 | 1.05 |
    @case:479
    Examples:
      | low | high |
      | 1.00 | 1.13 |
    @case:480
    Examples:
      | low | high |
      | 1.05 | 1.21 |
    @case:481
    Examples:
      | low | high |
      | 1.10 | 1.29 |
    @case:482
    Examples:
      | low | high |
      | 1.15 | 1.37 |
    @case:483
    Examples:
      | low | high |
      | 1.20 | 1.45 |
    @case:484
    Examples:
      | low | high |
      | 1.25 | 1.53 |
    @case:485
    Examples:
      | low | high |
      | 1.30 | 1.40 |
    @case:486
    Examples:
      | low | high |
      | 1.35 | 1.48 |
    @case:487
    Examples:
      | low | high |
      | 1.40 | 1.56 |
    @case:488
    Examples:
      | low | high |
      | 1.45 | 1.64 |
    @case:489
    Examples:
      | low | high |
      | 1.50 | 1.72 |
    @case:490
    Examples:
      | low | high |
      | 1.55 | 1.80 |
    @case:491
    Examples:
      | low | high |
      | 0.10 | 0.38 |
    @case:492
    Examples:
      | low | high |
      | 0.15 | 0.25 |
    @case:493
    Examples:
      | low | high |
      | 0.20 | 0.33 |
    @case:494
    Examples:
      | low | high |
      | 0.25 | 0.41 |
    @case:495
    Examples:
      | low | high |
      | 0.30 | 0.49 |
    @case:496
    Examples:
      | low | high |
      | 0.35 | 0.57 |
    @case:497
    Examples:
      | low | high |
      | 0.40 | 0.65 |
    @case:498
    Examples:
      | low | high |
      | 0.45 | 0.73 |
    @case:499
    Examples:
      | low | high |
      | 0.50 | 0.60 |
    @case:500
    Examples:
      | low | high |
      | 0.55 | 0.68 |
    @case:501
    Examples:
      | low | high |
      | 0.60 | 0.76 |
    @case:502
    Examples:
      | low | high |
      | 0.65 | 0.84 |
    @case:503
    Examples:
      | low | high |
      | 0.70 | 0.92 |
    @case:504
    Examples:
      | low | high |
      | 0.75 | 1.00 |
    @case:505
    Examples:
      | low | high |
      | 0.80 | 1.08 |
    @case:506
    Examples:
      | low | high |
      | 0.85 | 0.95 |
    @case:507
    Examples:
      | low | high |
      | 0.90 | 1.03 |
    @case:508
    Examples:
      | low | high |
      | 0.95 | 1.11 |
    @case:509
    Examples:
      | low | high |
      | 1.00 | 1.19 |
    @case:510
    Examples:
      | low | high |
      | 1.05 | 1.27 |
    @case:511
    Examples:
      | low | high |
      | 1.10 | 1.35 |
    @case:512
    Examples:
      | low | high |
      | 1.15 | 1.43 |
    @case:513
    Examples:
      | low | high |
      | 1.20 | 1.30 |
    @case:514
    Examples:
      | low | high |
      | 1.25 | 1.38 |
    @case:515
    Examples:
      | low | high |
      | 1.30 | 1.46 |
    @case:516
    Examples:
      | low | high |
      | 1.35 | 1.54 |
    @case:517
    Examples:
      | low | high |
      | 1.40 | 1.62 |
    @case:518
    Examples:
      | low | high |
      | 1.45 | 1.70 |
    @case:519
    Examples:
      | low | high |
      | 1.50 | 1.78 |
    @case:520
    Examples:
      | low | high |
      | 1.55 | 1.65 |
    @case:521
    Examples:
      | low | high |
      | 0.10 | 0.23 |
    @case:522
    Examples:
      | low | high |
      | 0.15 | 0.31 |
    @case:523
    Examples:
      | low | high |
      | 0.20 | 0.39 |
    @case:524
    Examples:
      | low | high |
      | 0.25 | 0.47 |
    @case:525
    Examples:
      | low | high |
      | 0.30 | 0.55 |
    @case:526
    Examples:
      | low | high |
      | 0.35 | 0.63 |
    @case:527
    Examples:
      | low | high |
      | 0.40 | 0.50 |
    @case:528
    Examples:
      | low | high |
      | 0.45 | 0.58 |
    @case:529
    Examples:
      | low | high |
      | 0.50 | 0.66 |
    @case:530
    Examples:
      | low | high |
      | 0.55 | 0.74 |
    @case:531
    Examples:
      | low | high |
      | 0.60 | 0.82 |
    @case:532
    Examples:
      | low | high |
      | 0.65 | 0.90 |
    @case:533
    Examples:
      | low | high |
      | 0.70 | 0.98 |
    @case:534
    Examples:
      | low | high |
      | 0.75 | 0.85 |
    @case:535
    Examples:
      | low | high |
      | 0.80 | 0.93 |
    @case:536
    Examples:
      | low | high |
      | 0.85 | 1.01 |
    @case:537
    Examples:
      | low | high |
      | 0.90 | 1.09 |
    @case:538
    Examples:
      | low | high |
      | 0.95 | 1.17 |
    @case:539
    Examples:
      | low | high |
      | 1.00 | 1.25 |
    @case:540
    Examples:
      | low | high |
      | 1.05 | 1.33 |
    @case:541
    Examples:
      | low | high |
      | 1.10 | 1.20 |
    @case:542
    Examples:
      | low | high |
      | 1.15 | 1.28 |
    @case:543
    Examples:
      | low | high |
      | 1.20 | 1.36 |
    @case:544
    Examples:
      | low | high |
      | 1.25 | 1.44 |
    @case:545
    Examples:
      | low | high |
      | 1.30 | 1.52 |
    @case:546
    Examples:
      | low | high |
      | 1.35 | 1.60 |
    @case:547
    Examples:
      | low | high |
      | 1.40 | 1.68 |
    @case:548
    Examples:
      | low | high |
      | 1.45 | 1.55 |
    @case:549
    Examples:
      | low | high |
      | 1.50 | 1.63 |
    @case:550
    Examples:
      | low | high |
      | 1.55 | 1.71 |
    @case:551
    Examples:
      | low | high |
      | 0.10 | 0.29 |
    @case:552
    Examples:
      | low | high |
      | 0.15 | 0.37 |
    @case:553
    Examples:
      | low | high |
      | 0.20 | 0.45 |
    @case:554
    Examples:
      | low | high |
      | 0.25 | 0.53 |
    @case:555
    Examples:
      | low | high |
      | 0.30 | 0.40 |
    @case:556
    Examples:
      | low | high |
      | 0.35 | 0.48 |
    @case:557
    Examples:
      | low | high |
      | 0.40 | 0.56 |
    @case:558
    Examples:
      | low | high |
      | 0.45 | 0.64 |
    @case:559
    Examples:
      | low | high |
      | 0.50 | 0.72 |
    @case:560
    Examples:
      | low | high |
      | 0.55 | 0.80 |
    @case:561
    Examples:
      | low | high |
      | 0.60 | 0.88 |
    @case:562
    Examples:
      | low | high |
      | 0.65 | 0.75 |
    @case:563
    Examples:
      | low | high |
      | 0.70 | 0.83 |
    @case:564
    Examples:
      | low | high |
      | 0.75 | 0.91 |
    @case:565
    Examples:
      | low | high |
      | 0.80 | 0.99 |
    @case:566
    Examples:
      | low | high |
      | 0.85 | 1.07 |
    @case:567
    Examples:
      | low | high |
      | 0.90 | 1.15 |
    @case:568
    Examples:
      | low | high |
      | 0.95 | 1.23 |
    @case:569
    Examples:
      | low | high |
      | 1.00 | 1.10 |
    @case:570
    Examples:
      | low | high |
      | 1.05 | 1.18 |
    @case:571
    Examples:
      | low | high |
      | 1.10 | 1.26 |
    @case:572
    Examples:
      | low | high |
      | 1.15 | 1.34 |
    @case:573
    Examples:
      | low | high |
      | 1.20 | 1.42 |
    @case:574
    Examples:
      | low | high |
      | 1.25 | 1.50 |
    @case:575
    Examples:
      | low | high |
      | 1.30 | 1.58 |
    @case:576
    Examples:
      | low | high |
      | 1.35 | 1.45 |
    @case:577
    Examples:
      | low | high |
      | 1.40 | 1.53 |
    @case:578
    Examples:
      | low | high |
      | 1.45 | 1.61 |
    @case:579
    Examples:
      | low | high |
      | 1.50 | 1.69 |
    @case:580
    Examples:
      | low | high |
      | 1.55 | 1.77 |
    @case:581
    Examples:
      | low | high |
      | 0.10 | 0.35 |
    @case:582
    Examples:
      | low | high |
      | 0.15 | 0.43 |
    @case:583
    Examples:
      | low | high |
      | 0.20 | 0.30 |
    @case:584
    Examples:
      | low | high |
      | 0.25 | 0.38 |
    @case:585
    Examples:
      | low | high |
      | 0.30 | 0.46 |
    @case:586
    Examples:
      | low | high |
      | 0.35 | 0.54 |
    @case:587
    Examples:
      | low | high |
      | 0.40 | 0.62 |
    @case:588
    Examples:
      | low | high |
      | 0.45 | 0.70 |
    @case:589
    Examples:
      | low | high |
      | 0.50 | 0.78 |
    @case:590
    Examples:
      | low | high |
      | 0.55 | 0.65 |
    @case:591
    Examples:
      | low | high |
      | 0.60 | 0.73 |
    @case:592
    Examples:
      | low | high |
      | 0.65 | 0.81 |
    @case:593
    Examples:
      | low | high |
      | 0.70 | 0.89 |
    @case:594
    Examples:
      | low | high |
      | 0.75 | 0.97 |
    @case:595
    Examples:
      | low | high |
      | 0.80 | 1.05 |
    @case:596
    Examples:
      | low | high |
      | 0.85 | 1.13 |
    @case:597
    Examples:
      | low | high |
      | 0.90 | 1.00 |
    @case:598
    Examples:
      | low | high |
      | 0.95 | 1.08 |
    @case:599
    Examples:
      | low | high |
      | 1.00 | 1.16 |
    @case:600
    Examples:
      | low | high |
      | 1.05 | 1.24 |
    @case:601
    Examples:
      | low | high |
      | 1.10 | 1.32 |
    @case:602
    Examples:
      | low | high |
      | 1.15 | 1.40 |
    @case:603
    Examples:
      | low | high |
      | 1.20 | 1.48 |
    @case:604
    Examples:
      | low | high |
      | 1.25 | 1.35 |
    @case:605
    Examples:
      | low | high |
      | 1.30 | 1.43 |
    @case:606
    Examples:
      | low | high |
      | 1.35 | 1.51 |
    @case:607
    Examples:
      | low | high |
      | 1.40 | 1.59 |
    @case:608
    Examples:
      | low | high |
      | 1.45 | 1.67 |
    @case:609
    Examples:
      | low | high |
      | 1.50 | 1.75 |
    @case:610
    Examples:
      | low | high |
      | 1.55 | 1.83 |
    @case:611
    Examples:
      | low | high |
      | 0.10 | 0.20 |
    @case:612
    Examples:
      | low | high |
      | 0.15 | 0.28 |
    @case:613
    Examples:
      | low | high |
      | 0.20 | 0.36 |
    @case:614
    Examples:
      | low | high |
      | 0.25 | 0.44 |
    @case:615
    Examples:
      | low | high |
      | 0.30 | 0.52 |
    @case:616
    Examples:
      | low | high |
      | 0.35 | 0.60 |
    @case:617
    Examples:
      | low | high |
      | 0.40 | 0.68 |
    @case:618
    Examples:
      | low | high |
      | 0.45 | 0.55 |
    @case:619
    Examples:
      | low | high |
      | 0.50 | 0.63 |
    @case:620
    Examples:
      | low | high |
      | 0.55 | 0.71 |
    @case:621
    Examples:
      | low | high |
      | 0.60 | 0.79 |
    @case:622
    Examples:
      | low | high |
      | 0.65 | 0.87 |
    @case:623
    Examples:
      | low | high |
      | 0.70 | 0.95 |
    @case:624
    Examples:
      | low | high |
      | 0.75 | 1.03 |
    @case:625
    Examples:
      | low | high |
      | 0.80 | 0.90 |
    @case:626
    Examples:
      | low | high |
      | 0.85 | 0.98 |
    @case:627
    Examples:
      | low | high |
      | 0.90 | 1.06 |
    @case:628
    Examples:
      | low | high |
      | 0.95 | 1.14 |
    @case:629
    Examples:
      | low | high |
      | 1.00 | 1.22 |
    @case:630
    Examples:
      | low | high |
      | 1.05 | 1.30 |
    @case:631
    Examples:
      | low | high |
      | 1.10 | 1.38 |
    @case:632
    Examples:
      | low | high |
      | 1.15 | 1.25 |
    @case:633
    Examples:
      | low | high |
      | 1.20 | 1.33 |
    @case:634
    Examples:
      | low | high |
      | 1.25 | 1.41 |
    @case:635
    Examples:
      | low | high |
      | 1.30 | 1.49 |
    @case:636
    Examples:
      | low | high |
      | 1.35 | 1.57 |
    @case:637
    Examples:
      | low | high |
      | 1.40 | 1.65 |
    @case:638
    Examples:
      | low | high |
      | 1.45 | 1.73 |
    @case:639
    Examples:
      | low | high |
      | 1.50 | 1.60 |
    @case:640
    Examples:
      | low | high |
      | 1.55 | 1.68 |
    @case:641
    Examples:
      | low | high |
      | 0.10 | 0.26 |
    @case:642
    Examples:
      | low | high |
      | 0.15 | 0.34 |
    @case:643
    Examples:
      | low | high |
      | 0.20 | 0.42 |
    @case:644
    Examples:
      | low | high |
      | 0.25 | 0.50 |
    @case:645
    Examples:
      | low | high |
      | 0.30 | 0.58 |
    @case:646
    Examples:
      | low | high |
      | 0.35 | 0.45 |
    @case:647
    Examples:
      | low | high |
      | 0.40 | 0.53 |
    @case:648
    Examples:
      | low | high |
      | 0.45 | 0.61 |
    @case:649
    Examples:
      | low | high |
      | 0.50 | 0.69 |
    @case:650
    Examples:
      | low | high |
      | 0.55 | 0.77 |
    @case:651
    Examples:
      | low | high |
      | 0.60 | 0.85 |
    @case:652
    Examples:
      | low | high |
      | 0.65 | 0.93 |
    @case:653
    Examples:
      | low | high |
      | 0.70 | 0.80 |
    @case:654
    Examples:
      | low | high |
      | 0.75 | 0.88 |
    @case:655
    Examples:
      | low | high |
      | 0.80 | 0.96 |
    @case:656
    Examples:
      | low | high |
      | 0.85 | 1.04 |
    @case:657
    Examples:
      | low | high |
      | 0.90 | 1.12 |
    @case:658
    Examples:
      | low | high |
      | 0.95 | 1.20 |
    @case:659
    Examples:
      | low | high |
      | 1.00 | 1.28 |
    @case:660
    Examples:
      | low | high |
      | 1.05 | 1.15 |
    @case:661
    Examples:
      | low | high |
      | 1.10 | 1.23 |
    @case:662
    Examples:
      | low | high |
      | 1.15 | 1.31 |
    @case:663
    Examples:
      | low | high |
      | 1.20 | 1.39 |
    @case:664
    Examples:
      | low | high |
      | 1.25 | 1.47 |
    @case:665
    Examples:
      | low | high |
      | 1.30 | 1.55 |
    @case:666
    Examples:
      | low | high |
      | 1.35 | 1.63 |
    @case:667
    Examples:
      | low | high |
      | 1.40 | 1.50 |
    @case:668
    Examples:
      | low | high |
      | 1.45 | 1.58 |
    @case:669
    Examples:
      | low | high |
      | 1.50 | 1.66 |
    @case:670
    Examples:
      | low | high |
      | 1.55 | 1.74 |
    @case:671
    Examples:
      | low | high |
      | 0.10 | 0.32 |
    @case:672
    Examples:
      | low | high |
      | 0.15 | 0.40 |
    @case:673
    Examples:
      | low | high |
      | 0.20 | 0.48 |
    @case:674
    Examples:
      | low | high |
      | 0.25 | 0.35 |
    @case:675
    Examples:
      | low | high |
      | 0.30 | 0.43 |
    @case:676
    Examples:
      | low | high |
      | 0.35 | 0.51 |
    @case:677
    Examples:
      | low | high |
      | 0.40 | 0.59 |
    @case:678
    Examples:
      | low | high |
      | 0.45 | 0.67 |
    @case:679
    Examples:
      | low | high |
      | 0.50 | 0.75 |
    @case:680
    Examples:
      | low | high |
      | 0.55 | 0.83 |
    @case:681
    Examples:
      | low | high |
      | 0.60 | 0.70 |
    @case:682
    Examples:
      | low | high |
      | 0.65 | 0.78 |
    @case:683
    Examples:
      | low | high |
      | 0.70 | 0.86 |
    @case:684
    Examples:
      | low | high |
      | 0.75 | 0.94 |
    @case:685
    Examples:
      | low | high |
      | 0.80 | 1.02 |
    @case:686
    Examples:
      | low | high |
      | 0.85 | 1.10 |
    @case:687
    Examples:
      | low | high |
      | 0.90 | 1.18 |
    @case:688
    Examples:
      | low | high |
      | 0.95 | 1.05 |
    @case:689
    Examples:
      | low | high |
      | 1.00 | 1.13 |
    @case:690
    Examples:
      | low | high |
      | 1.05 | 1.21 |
    @case:691
    Examples:
      | low | high |
      | 1.10 | 1.29 |
    @case:692
    Examples:
      | low | high |
      | 1.15 | 1.37 |
    @case:693
    Examples:
      | low | high |
      | 1.20 | 1.45 |
    @case:694
    Examples:
      | low | high |
      | 1.25 | 1.53 |
    @case:695
    Examples:
      | low | high |
      | 1.30 | 1.40 |
    @case:696
    Examples:
      | low | high |
      | 1.35 | 1.48 |
    @case:697
    Examples:
      | low | high |
      | 1.40 | 1.56 |
    @case:698
    Examples:
      | low | high |
      | 1.45 | 1.64 |
    @case:699
    Examples:
      | low | high |
      | 1.50 | 1.72 |
    @case:700
    Examples:
      | low | high |
      | 1.55 | 1.80 |
    @case:701
    Examples:
      | low | high |
      | 0.10 | 0.38 |
    @case:702
    Examples:
      | low | high |
      | 0.15 | 0.25 |
    @case:703
    Examples:
      | low | high |
      | 0.20 | 0.33 |
    @case:704
    Examples:
      | low | high |
      | 0.25 | 0.41 |
    @case:705
    Examples:
      | low | high |
      | 0.30 | 0.49 |
    @case:706
    Examples:
      | low | high |
      | 0.35 | 0.57 |
    @case:707
    Examples:
      | low | high |
      | 0.40 | 0.65 |
    @case:708
    Examples:
      | low | high |
      | 0.45 | 0.73 |
    @case:709
    Examples:
      | low | high |
      | 0.50 | 0.60 |
    @case:710
    Examples:
      | low | high |
      | 0.55 | 0.68 |
    @case:711
    Examples:
      | low | high |
      | 0.60 | 0.76 |
    @case:712
    Examples:
      | low | high |
      | 0.65 | 0.84 |
    @case:713
    Examples:
      | low | high |
      | 0.70 | 0.92 |
    @case:714
    Examples:
      | low | high |
      | 0.75 | 1.00 |
    @case:715
    Examples:
      | low | high |
      | 0.80 | 1.08 |
    @case:716
    Examples:
      | low | high |
      | 0.85 | 0.95 |
    @case:717
    Examples:
      | low | high |
      | 0.90 | 1.03 |
    @case:718
    Examples:
      | low | high |
      | 0.95 | 1.11 |
    @case:719
    Examples:
      | low | high |
      | 1.00 | 1.19 |
    @case:720
    Examples:
      | low | high |
      | 1.05 | 1.27 |
    @case:721
    Examples:
      | low | high |
      | 1.10 | 1.35 |
    @case:722
    Examples:
      | low | high |
      | 1.15 | 1.43 |
    @case:723
    Examples:
      | low | high |
      | 1.20 | 1.30 |
    @case:724
    Examples:
      | low | high |
      | 1.25 | 1.38 |
    @case:725
    Examples:
      | low | high |
      | 1.30 | 1.46 |
    @case:726
    Examples:
      | low | high |
      | 1.35 | 1.54 |
    @case:727
    Examples:
      | low | high |
      | 1.40 | 1.62 |
    @case:728
    Examples:
      | low | high |
      | 1.45 | 1.70 |
    @case:729
    Examples:
      | low | high |
      | 1.50 | 1.78 |
    @case:730
    Examples:
      | low | high |
      | 1.55 | 1.65 |
    @case:731
    Examples:
      | low | high |
      | 0.10 | 0.23 |
    @case:732
    Examples:
      | low | high |
      | 0.15 | 0.31 |
    @case:733
    Examples:
      | low | high |
      | 0.20 | 0.39 |
    @case:734
    Examples:
      | low | high |
      | 0.25 | 0.47 |
    @case:735
    Examples:
      | low | high |
      | 0.30 | 0.55 |
    @case:736
    Examples:
      | low | high |
      | 0.35 | 0.63 |
    @case:737
    Examples:
      | low | high |
      | 0.40 | 0.50 |
    @case:738
    Examples:
      | low | high |
      | 0.45 | 0.58 |
    @case:739
    Examples:
      | low | high |
      | 0.50 | 0.66 |
    @case:740
    Examples:
      | low | high |
      | 0.55 | 0.74 |
    @case:741
    Examples:
      | low | high |
      | 0.60 | 0.82 |
    @case:742
    Examples:
      | low | high |
      | 0.65 | 0.90 |
    @case:743
    Examples:
      | low | high |
      | 0.70 | 0.98 |
    @case:744
    Examples:
      | low | high |
      | 0.75 | 0.85 |
    @case:745
    Examples:
      | low | high |
      | 0.80 | 0.93 |
    @case:746
    Examples:
      | low | high |
      | 0.85 | 1.01 |
    @case:747
    Examples:
      | low | high |
      | 0.90 | 1.09 |
    @case:748
    Examples:
      | low | high |
      | 0.95 | 1.17 |
    @case:749
    Examples:
      | low | high |
      | 1.00 | 1.25 |
    @case:750
    Examples:
      | low | high |
      | 1.05 | 1.33 |
    @case:751
    Examples:
      | low | high |
      | 1.10 | 1.20 |
    @case:752
    Examples:
      | low | high |
      | 1.15 | 1.28 |
    @case:753
    Examples:
      | low | high |
      | 1.20 | 1.36 |
    @case:754
    Examples:
      | low | high |
      | 1.25 | 1.44 |
    @case:755
    Examples:
      | low | high |
      | 1.30 | 1.52 |
    @case:756
    Examples:
      | low | high |
      | 1.35 | 1.60 |
    @case:757
    Examples:
      | low | high |
      | 1.40 | 1.68 |
    @case:758
    Examples:
      | low | high |
      | 1.45 | 1.55 |
    @case:759
    Examples:
      | low | high |
      | 1.50 | 1.63 |
    @case:760
    Examples:
      | low | high |
      | 1.55 | 1.71 |
    @case:761
    Examples:
      | low | high |
      | 0.10 | 0.29 |
    @case:762
    Examples:
      | low | high |
      | 0.15 | 0.37 |
    @case:763
    Examples:
      | low | high |
      | 0.20 | 0.45 |
    @case:764
    Examples:
      | low | high |
      | 0.25 | 0.53 |
    @case:765
    Examples:
      | low | high |
      | 0.30 | 0.40 |
    @case:766
    Examples:
      | low | high |
      | 0.35 | 0.48 |
    @case:767
    Examples:
      | low | high |
      | 0.40 | 0.56 |
    @case:768
    Examples:
      | low | high |
      | 0.45 | 0.64 |
    @case:769
    Examples:
      | low | high |
      | 0.50 | 0.72 |
    @case:770
    Examples:
      | low | high |
      | 0.55 | 0.80 |
    @case:771
    Examples:
      | low | high |
      | 0.60 | 0.88 |
    @case:772
    Examples:
      | low | high |
      | 0.65 | 0.75 |
    @case:773
    Examples:
      | low | high |
      | 0.70 | 0.83 |
    @case:774
    Examples:
      | low | high |
      | 0.75 | 0.91 |
    @case:775
    Examples:
      | low | high |
      | 0.80 | 0.99 |
    @case:776
    Examples:
      | low | high |
      | 0.85 | 1.07 |
    @case:777
    Examples:
      | low | high |
      | 0.90 | 1.15 |
    @case:778
    Examples:
      | low | high |
      | 0.95 | 1.23 |
    @case:779
    Examples:
      | low | high |
      | 1.00 | 1.10 |
    @case:780
    Examples:
      | low | high |
      | 1.05 | 1.18 |
    @case:781
    Examples:
      | low | high |
      | 1.10 | 1.26 |
    @case:782
    Examples:
      | low | high |
      | 1.15 | 1.34 |
    @case:783
    Examples:
      | low | high |
      | 1.20 | 1.42 |
    @case:784
    Examples:
      | low | high |
      | 1.25 | 1.50 |
    @case:785
    Examples:
      | low | high |
      | 1.30 | 1.58 |
    @case:786
    Examples:
      | low | high |
      | 1.35 | 1.45 |
    @case:787
    Examples:
      | low | high |
      | 1.40 | 1.53 |
    @case:788
    Examples:
      | low | high |
      | 1.45 | 1.61 |
    @case:789
    Examples:
      | low | high |
      | 1.50 | 1.69 |
    @case:790
    Examples:
      | low | high |
      | 1.55 | 1.77 |
    @case:791
    Examples:
      | low | high |
      | 0.10 | 0.35 |
    @case:792
    Examples:
      | low | high |
      | 0.15 | 0.43 |
    @case:793
    Examples:
      | low | high |
      | 0.20 | 0.30 |
    @case:794
    Examples:
      | low | high |
      | 0.25 | 0.38 |
    @case:795
    Examples:
      | low | high |
      | 0.30 | 0.46 |
    @case:796
    Examples:
      | low | high |
      | 0.35 | 0.54 |
    @case:797
    Examples:
      | low | high |
      | 0.40 | 0.62 |
    @case:798
    Examples:
      | low | high |
      | 0.45 | 0.70 |
    @case:799
    Examples:
      | low | high |
      | 0.50 | 0.78 |
    @case:800
    Examples:
      | low | high |
      | 0.55 | 0.65 |

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
