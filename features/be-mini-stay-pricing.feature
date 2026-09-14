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

    @case:251
    Examples:
      | label | room | nights |
      | room 1 for 1 nights | 1 | 1 |
    @case:252
    Examples:
      | label | room | nights |
      | room 1 for 2 nights | 1 | 2 |
    @case:253
    Examples:
      | label | room | nights |
      | room 1 for 3 nights | 1 | 3 |
    @case:254
    Examples:
      | label | room | nights |
      | room 1 for 4 nights | 1 | 4 |
    @case:255
    Examples:
      | label | room | nights |
      | room 1 for 5 nights | 1 | 5 |
    @case:256
    Examples:
      | label | room | nights |
      | room 1 for 6 nights | 1 | 6 |
    @case:257
    Examples:
      | label | room | nights |
      | room 1 for 7 nights | 1 | 7 |
    @case:258
    Examples:
      | label | room | nights |
      | room 1 for 8 nights | 1 | 8 |
    @case:259
    Examples:
      | label | room | nights |
      | room 1 for 9 nights | 1 | 9 |
    @case:260
    Examples:
      | label | room | nights |
      | room 1 for 10 nights | 1 | 10 |
    @case:261
    Examples:
      | label | room | nights |
      | room 1 for 11 nights | 1 | 11 |
    @case:262
    Examples:
      | label | room | nights |
      | room 1 for 12 nights | 1 | 12 |
    @case:263
    Examples:
      | label | room | nights |
      | room 1 for 13 nights | 1 | 13 |
    @case:264
    Examples:
      | label | room | nights |
      | room 1 for 14 nights | 1 | 14 |
    @case:265
    Examples:
      | label | room | nights |
      | room 1 for 15 nights | 1 | 15 |
    @case:266
    Examples:
      | label | room | nights |
      | room 1 for 16 nights | 1 | 16 |
    @case:267
    Examples:
      | label | room | nights |
      | room 1 for 17 nights | 1 | 17 |
    @case:268
    Examples:
      | label | room | nights |
      | room 1 for 18 nights | 1 | 18 |
    @case:269
    Examples:
      | label | room | nights |
      | room 1 for 19 nights | 1 | 19 |
    @case:270
    Examples:
      | label | room | nights |
      | room 1 for 20 nights | 1 | 20 |
    @case:271
    Examples:
      | label | room | nights |
      | room 1 for 21 nights | 1 | 21 |
    @case:272
    Examples:
      | label | room | nights |
      | room 1 for 22 nights | 1 | 22 |
    @case:273
    Examples:
      | label | room | nights |
      | room 1 for 23 nights | 1 | 23 |
    @case:274
    Examples:
      | label | room | nights |
      | room 1 for 24 nights | 1 | 24 |
    @case:275
    Examples:
      | label | room | nights |
      | room 1 for 25 nights | 1 | 25 |
    @case:276
    Examples:
      | label | room | nights |
      | room 1 for 26 nights | 1 | 26 |
    @case:277
    Examples:
      | label | room | nights |
      | room 1 for 27 nights | 1 | 27 |
    @case:278
    Examples:
      | label | room | nights |
      | room 1 for 28 nights | 1 | 28 |
    @case:279
    Examples:
      | label | room | nights |
      | room 1 for 29 nights | 1 | 29 |
    @case:280
    Examples:
      | label | room | nights |
      | room 1 for 30 nights | 1 | 30 |
    @case:281
    Examples:
      | label | room | nights |
      | room 2 for 1 nights | 2 | 1 |
    @case:282
    Examples:
      | label | room | nights |
      | room 2 for 2 nights | 2 | 2 |
    @case:283
    Examples:
      | label | room | nights |
      | room 2 for 3 nights | 2 | 3 |
    @case:284
    Examples:
      | label | room | nights |
      | room 2 for 4 nights | 2 | 4 |
    @case:285
    Examples:
      | label | room | nights |
      | room 2 for 5 nights | 2 | 5 |
    @case:286
    Examples:
      | label | room | nights |
      | room 2 for 6 nights | 2 | 6 |
    @case:287
    Examples:
      | label | room | nights |
      | room 2 for 7 nights | 2 | 7 |
    @case:288
    Examples:
      | label | room | nights |
      | room 2 for 8 nights | 2 | 8 |
    @case:289
    Examples:
      | label | room | nights |
      | room 2 for 9 nights | 2 | 9 |
    @case:290
    Examples:
      | label | room | nights |
      | room 2 for 10 nights | 2 | 10 |
    @case:291
    Examples:
      | label | room | nights |
      | room 2 for 11 nights | 2 | 11 |
    @case:292
    Examples:
      | label | room | nights |
      | room 2 for 12 nights | 2 | 12 |
    @case:293
    Examples:
      | label | room | nights |
      | room 2 for 13 nights | 2 | 13 |
    @case:294
    Examples:
      | label | room | nights |
      | room 2 for 14 nights | 2 | 14 |
    @case:295
    Examples:
      | label | room | nights |
      | room 2 for 15 nights | 2 | 15 |
    @case:296
    Examples:
      | label | room | nights |
      | room 2 for 16 nights | 2 | 16 |
    @case:297
    Examples:
      | label | room | nights |
      | room 2 for 17 nights | 2 | 17 |
    @case:298
    Examples:
      | label | room | nights |
      | room 2 for 18 nights | 2 | 18 |
    @case:299
    Examples:
      | label | room | nights |
      | room 2 for 19 nights | 2 | 19 |
    @case:300
    Examples:
      | label | room | nights |
      | room 2 for 20 nights | 2 | 20 |
    @case:301
    Examples:
      | label | room | nights |
      | room 2 for 21 nights | 2 | 21 |
    @case:302
    Examples:
      | label | room | nights |
      | room 2 for 22 nights | 2 | 22 |
    @case:303
    Examples:
      | label | room | nights |
      | room 2 for 23 nights | 2 | 23 |
    @case:304
    Examples:
      | label | room | nights |
      | room 2 for 24 nights | 2 | 24 |
    @case:305
    Examples:
      | label | room | nights |
      | room 2 for 25 nights | 2 | 25 |
    @case:306
    Examples:
      | label | room | nights |
      | room 2 for 26 nights | 2 | 26 |
    @case:307
    Examples:
      | label | room | nights |
      | room 2 for 27 nights | 2 | 27 |
    @case:308
    Examples:
      | label | room | nights |
      | room 2 for 28 nights | 2 | 28 |
    @case:309
    Examples:
      | label | room | nights |
      | room 2 for 29 nights | 2 | 29 |
    @case:310
    Examples:
      | label | room | nights |
      | room 2 for 30 nights | 2 | 30 |
    @case:311
    Examples:
      | label | room | nights |
      | room 3 for 1 nights | 3 | 1 |
    @case:312
    Examples:
      | label | room | nights |
      | room 3 for 2 nights | 3 | 2 |
    @case:313
    Examples:
      | label | room | nights |
      | room 3 for 3 nights | 3 | 3 |
    @case:314
    Examples:
      | label | room | nights |
      | room 3 for 4 nights | 3 | 4 |
    @case:315
    Examples:
      | label | room | nights |
      | room 3 for 5 nights | 3 | 5 |
    @case:316
    Examples:
      | label | room | nights |
      | room 3 for 6 nights | 3 | 6 |
    @case:317
    Examples:
      | label | room | nights |
      | room 3 for 7 nights | 3 | 7 |
    @case:318
    Examples:
      | label | room | nights |
      | room 3 for 8 nights | 3 | 8 |
    @case:319
    Examples:
      | label | room | nights |
      | room 3 for 9 nights | 3 | 9 |
    @case:320
    Examples:
      | label | room | nights |
      | room 3 for 10 nights | 3 | 10 |
    @case:321
    Examples:
      | label | room | nights |
      | room 3 for 11 nights | 3 | 11 |
    @case:322
    Examples:
      | label | room | nights |
      | room 3 for 12 nights | 3 | 12 |
    @case:323
    Examples:
      | label | room | nights |
      | room 3 for 13 nights | 3 | 13 |
    @case:324
    Examples:
      | label | room | nights |
      | room 3 for 14 nights | 3 | 14 |
    @case:325
    Examples:
      | label | room | nights |
      | room 3 for 15 nights | 3 | 15 |
    @case:326
    Examples:
      | label | room | nights |
      | room 3 for 16 nights | 3 | 16 |
    @case:327
    Examples:
      | label | room | nights |
      | room 3 for 17 nights | 3 | 17 |
    @case:328
    Examples:
      | label | room | nights |
      | room 3 for 18 nights | 3 | 18 |
    @case:329
    Examples:
      | label | room | nights |
      | room 3 for 19 nights | 3 | 19 |
    @case:330
    Examples:
      | label | room | nights |
      | room 3 for 20 nights | 3 | 20 |
    @case:331
    Examples:
      | label | room | nights |
      | room 3 for 21 nights | 3 | 21 |
    @case:332
    Examples:
      | label | room | nights |
      | room 3 for 22 nights | 3 | 22 |
    @case:333
    Examples:
      | label | room | nights |
      | room 3 for 23 nights | 3 | 23 |
    @case:334
    Examples:
      | label | room | nights |
      | room 3 for 24 nights | 3 | 24 |
    @case:335
    Examples:
      | label | room | nights |
      | room 3 for 25 nights | 3 | 25 |
    @case:336
    Examples:
      | label | room | nights |
      | room 3 for 26 nights | 3 | 26 |
    @case:337
    Examples:
      | label | room | nights |
      | room 3 for 27 nights | 3 | 27 |
    @case:338
    Examples:
      | label | room | nights |
      | room 3 for 28 nights | 3 | 28 |
    @case:339
    Examples:
      | label | room | nights |
      | room 3 for 29 nights | 3 | 29 |
    @case:340
    Examples:
      | label | room | nights |
      | room 3 for 30 nights | 3 | 30 |
    @case:341
    Examples:
      | label | room | nights |
      | room 4 for 1 nights | 4 | 1 |
    @case:342
    Examples:
      | label | room | nights |
      | room 4 for 2 nights | 4 | 2 |
    @case:343
    Examples:
      | label | room | nights |
      | room 4 for 3 nights | 4 | 3 |
    @case:344
    Examples:
      | label | room | nights |
      | room 4 for 4 nights | 4 | 4 |
    @case:345
    Examples:
      | label | room | nights |
      | room 4 for 5 nights | 4 | 5 |
    @case:346
    Examples:
      | label | room | nights |
      | room 4 for 6 nights | 4 | 6 |
    @case:347
    Examples:
      | label | room | nights |
      | room 4 for 7 nights | 4 | 7 |
    @case:348
    Examples:
      | label | room | nights |
      | room 4 for 8 nights | 4 | 8 |
    @case:349
    Examples:
      | label | room | nights |
      | room 4 for 9 nights | 4 | 9 |
    @case:350
    Examples:
      | label | room | nights |
      | room 4 for 10 nights | 4 | 10 |
    @case:351
    Examples:
      | label | room | nights |
      | room 4 for 11 nights | 4 | 11 |
    @case:352
    Examples:
      | label | room | nights |
      | room 4 for 12 nights | 4 | 12 |
    @case:353
    Examples:
      | label | room | nights |
      | room 4 for 13 nights | 4 | 13 |
    @case:354
    Examples:
      | label | room | nights |
      | room 4 for 14 nights | 4 | 14 |
    @case:355
    Examples:
      | label | room | nights |
      | room 4 for 15 nights | 4 | 15 |
    @case:356
    Examples:
      | label | room | nights |
      | room 4 for 16 nights | 4 | 16 |
    @case:357
    Examples:
      | label | room | nights |
      | room 4 for 17 nights | 4 | 17 |
    @case:358
    Examples:
      | label | room | nights |
      | room 4 for 18 nights | 4 | 18 |
    @case:359
    Examples:
      | label | room | nights |
      | room 4 for 19 nights | 4 | 19 |
    @case:360
    Examples:
      | label | room | nights |
      | room 4 for 20 nights | 4 | 20 |
    @case:361
    Examples:
      | label | room | nights |
      | room 4 for 21 nights | 4 | 21 |
    @case:362
    Examples:
      | label | room | nights |
      | room 4 for 22 nights | 4 | 22 |
    @case:363
    Examples:
      | label | room | nights |
      | room 4 for 23 nights | 4 | 23 |
    @case:364
    Examples:
      | label | room | nights |
      | room 4 for 24 nights | 4 | 24 |
    @case:365
    Examples:
      | label | room | nights |
      | room 4 for 25 nights | 4 | 25 |
    @case:366
    Examples:
      | label | room | nights |
      | room 4 for 26 nights | 4 | 26 |
    @case:367
    Examples:
      | label | room | nights |
      | room 4 for 27 nights | 4 | 27 |
    @case:368
    Examples:
      | label | room | nights |
      | room 4 for 28 nights | 4 | 28 |
    @case:369
    Examples:
      | label | room | nights |
      | room 4 for 29 nights | 4 | 29 |
    @case:370
    Examples:
      | label | room | nights |
      | room 4 for 30 nights | 4 | 30 |
    @case:371
    Examples:
      | label | room | nights |
      | room 5 for 1 nights | 5 | 1 |
    @case:372
    Examples:
      | label | room | nights |
      | room 5 for 2 nights | 5 | 2 |
    @case:373
    Examples:
      | label | room | nights |
      | room 5 for 3 nights | 5 | 3 |
    @case:374
    Examples:
      | label | room | nights |
      | room 5 for 4 nights | 5 | 4 |
    @case:375
    Examples:
      | label | room | nights |
      | room 5 for 5 nights | 5 | 5 |
    @case:376
    Examples:
      | label | room | nights |
      | room 5 for 6 nights | 5 | 6 |
    @case:377
    Examples:
      | label | room | nights |
      | room 5 for 7 nights | 5 | 7 |
    @case:378
    Examples:
      | label | room | nights |
      | room 5 for 8 nights | 5 | 8 |
    @case:379
    Examples:
      | label | room | nights |
      | room 5 for 9 nights | 5 | 9 |
    @case:380
    Examples:
      | label | room | nights |
      | room 5 for 10 nights | 5 | 10 |
    @case:381
    Examples:
      | label | room | nights |
      | room 5 for 11 nights | 5 | 11 |
    @case:382
    Examples:
      | label | room | nights |
      | room 5 for 12 nights | 5 | 12 |
    @case:383
    Examples:
      | label | room | nights |
      | room 5 for 13 nights | 5 | 13 |
    @case:384
    Examples:
      | label | room | nights |
      | room 5 for 14 nights | 5 | 14 |
    @case:385
    Examples:
      | label | room | nights |
      | room 5 for 15 nights | 5 | 15 |
    @case:386
    Examples:
      | label | room | nights |
      | room 5 for 16 nights | 5 | 16 |
    @case:387
    Examples:
      | label | room | nights |
      | room 5 for 17 nights | 5 | 17 |
    @case:388
    Examples:
      | label | room | nights |
      | room 5 for 18 nights | 5 | 18 |
    @case:389
    Examples:
      | label | room | nights |
      | room 5 for 19 nights | 5 | 19 |
    @case:390
    Examples:
      | label | room | nights |
      | room 5 for 20 nights | 5 | 20 |
    @case:391
    Examples:
      | label | room | nights |
      | room 5 for 21 nights | 5 | 21 |
    @case:392
    Examples:
      | label | room | nights |
      | room 5 for 22 nights | 5 | 22 |
    @case:393
    Examples:
      | label | room | nights |
      | room 5 for 23 nights | 5 | 23 |
    @case:394
    Examples:
      | label | room | nights |
      | room 5 for 24 nights | 5 | 24 |
    @case:395
    Examples:
      | label | room | nights |
      | room 5 for 25 nights | 5 | 25 |
    @case:396
    Examples:
      | label | room | nights |
      | room 5 for 26 nights | 5 | 26 |
    @case:397
    Examples:
      | label | room | nights |
      | room 5 for 27 nights | 5 | 27 |
    @case:398
    Examples:
      | label | room | nights |
      | room 5 for 28 nights | 5 | 28 |
    @case:399
    Examples:
      | label | room | nights |
      | room 5 for 29 nights | 5 | 29 |
    @case:400
    Examples:
      | label | room | nights |
      | room 5 for 30 nights | 5 | 30 |

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
