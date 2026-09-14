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
      | room 1 for 31 nights | 1 | 31 |
    @case:282
    Examples:
      | label | room | nights |
      | room 1 for 32 nights | 1 | 32 |
    @case:283
    Examples:
      | label | room | nights |
      | room 1 for 33 nights | 1 | 33 |
    @case:284
    Examples:
      | label | room | nights |
      | room 1 for 34 nights | 1 | 34 |
    @case:285
    Examples:
      | label | room | nights |
      | room 2 for 1 nights | 2 | 1 |
    @case:286
    Examples:
      | label | room | nights |
      | room 2 for 2 nights | 2 | 2 |
    @case:287
    Examples:
      | label | room | nights |
      | room 2 for 3 nights | 2 | 3 |
    @case:288
    Examples:
      | label | room | nights |
      | room 2 for 4 nights | 2 | 4 |
    @case:289
    Examples:
      | label | room | nights |
      | room 2 for 5 nights | 2 | 5 |
    @case:290
    Examples:
      | label | room | nights |
      | room 2 for 6 nights | 2 | 6 |
    @case:291
    Examples:
      | label | room | nights |
      | room 2 for 7 nights | 2 | 7 |
    @case:292
    Examples:
      | label | room | nights |
      | room 2 for 8 nights | 2 | 8 |
    @case:293
    Examples:
      | label | room | nights |
      | room 2 for 9 nights | 2 | 9 |
    @case:294
    Examples:
      | label | room | nights |
      | room 2 for 10 nights | 2 | 10 |
    @case:295
    Examples:
      | label | room | nights |
      | room 2 for 11 nights | 2 | 11 |
    @case:296
    Examples:
      | label | room | nights |
      | room 2 for 12 nights | 2 | 12 |
    @case:297
    Examples:
      | label | room | nights |
      | room 2 for 13 nights | 2 | 13 |
    @case:298
    Examples:
      | label | room | nights |
      | room 2 for 14 nights | 2 | 14 |
    @case:299
    Examples:
      | label | room | nights |
      | room 2 for 15 nights | 2 | 15 |
    @case:300
    Examples:
      | label | room | nights |
      | room 2 for 16 nights | 2 | 16 |
    @case:301
    Examples:
      | label | room | nights |
      | room 2 for 17 nights | 2 | 17 |
    @case:302
    Examples:
      | label | room | nights |
      | room 2 for 18 nights | 2 | 18 |
    @case:303
    Examples:
      | label | room | nights |
      | room 2 for 19 nights | 2 | 19 |
    @case:304
    Examples:
      | label | room | nights |
      | room 2 for 20 nights | 2 | 20 |
    @case:305
    Examples:
      | label | room | nights |
      | room 2 for 21 nights | 2 | 21 |
    @case:306
    Examples:
      | label | room | nights |
      | room 2 for 22 nights | 2 | 22 |
    @case:307
    Examples:
      | label | room | nights |
      | room 2 for 23 nights | 2 | 23 |
    @case:308
    Examples:
      | label | room | nights |
      | room 2 for 24 nights | 2 | 24 |
    @case:309
    Examples:
      | label | room | nights |
      | room 2 for 25 nights | 2 | 25 |
    @case:310
    Examples:
      | label | room | nights |
      | room 2 for 26 nights | 2 | 26 |
    @case:311
    Examples:
      | label | room | nights |
      | room 2 for 27 nights | 2 | 27 |
    @case:312
    Examples:
      | label | room | nights |
      | room 2 for 28 nights | 2 | 28 |
    @case:313
    Examples:
      | label | room | nights |
      | room 2 for 29 nights | 2 | 29 |
    @case:314
    Examples:
      | label | room | nights |
      | room 2 for 30 nights | 2 | 30 |
    @case:315
    Examples:
      | label | room | nights |
      | room 2 for 31 nights | 2 | 31 |
    @case:316
    Examples:
      | label | room | nights |
      | room 2 for 32 nights | 2 | 32 |
    @case:317
    Examples:
      | label | room | nights |
      | room 2 for 33 nights | 2 | 33 |
    @case:318
    Examples:
      | label | room | nights |
      | room 2 for 34 nights | 2 | 34 |
    @case:319
    Examples:
      | label | room | nights |
      | room 3 for 1 nights | 3 | 1 |
    @case:320
    Examples:
      | label | room | nights |
      | room 3 for 2 nights | 3 | 2 |
    @case:321
    Examples:
      | label | room | nights |
      | room 3 for 3 nights | 3 | 3 |
    @case:322
    Examples:
      | label | room | nights |
      | room 3 for 4 nights | 3 | 4 |
    @case:323
    Examples:
      | label | room | nights |
      | room 3 for 5 nights | 3 | 5 |
    @case:324
    Examples:
      | label | room | nights |
      | room 3 for 6 nights | 3 | 6 |
    @case:325
    Examples:
      | label | room | nights |
      | room 3 for 7 nights | 3 | 7 |
    @case:326
    Examples:
      | label | room | nights |
      | room 3 for 8 nights | 3 | 8 |
    @case:327
    Examples:
      | label | room | nights |
      | room 3 for 9 nights | 3 | 9 |
    @case:328
    Examples:
      | label | room | nights |
      | room 3 for 10 nights | 3 | 10 |
    @case:329
    Examples:
      | label | room | nights |
      | room 3 for 11 nights | 3 | 11 |
    @case:330
    Examples:
      | label | room | nights |
      | room 3 for 12 nights | 3 | 12 |
    @case:331
    Examples:
      | label | room | nights |
      | room 3 for 13 nights | 3 | 13 |
    @case:332
    Examples:
      | label | room | nights |
      | room 3 for 14 nights | 3 | 14 |
    @case:333
    Examples:
      | label | room | nights |
      | room 3 for 15 nights | 3 | 15 |
    @case:334
    Examples:
      | label | room | nights |
      | room 3 for 16 nights | 3 | 16 |
    @case:335
    Examples:
      | label | room | nights |
      | room 3 for 17 nights | 3 | 17 |
    @case:336
    Examples:
      | label | room | nights |
      | room 3 for 18 nights | 3 | 18 |
    @case:337
    Examples:
      | label | room | nights |
      | room 3 for 19 nights | 3 | 19 |
    @case:338
    Examples:
      | label | room | nights |
      | room 3 for 20 nights | 3 | 20 |
    @case:339
    Examples:
      | label | room | nights |
      | room 3 for 21 nights | 3 | 21 |
    @case:340
    Examples:
      | label | room | nights |
      | room 3 for 22 nights | 3 | 22 |
    @case:341
    Examples:
      | label | room | nights |
      | room 3 for 23 nights | 3 | 23 |
    @case:342
    Examples:
      | label | room | nights |
      | room 3 for 24 nights | 3 | 24 |
    @case:343
    Examples:
      | label | room | nights |
      | room 3 for 25 nights | 3 | 25 |
    @case:344
    Examples:
      | label | room | nights |
      | room 3 for 26 nights | 3 | 26 |
    @case:345
    Examples:
      | label | room | nights |
      | room 3 for 27 nights | 3 | 27 |
    @case:346
    Examples:
      | label | room | nights |
      | room 3 for 28 nights | 3 | 28 |
    @case:347
    Examples:
      | label | room | nights |
      | room 3 for 29 nights | 3 | 29 |
    @case:348
    Examples:
      | label | room | nights |
      | room 3 for 30 nights | 3 | 30 |
    @case:349
    Examples:
      | label | room | nights |
      | room 3 for 31 nights | 3 | 31 |
    @case:350
    Examples:
      | label | room | nights |
      | room 3 for 32 nights | 3 | 32 |
    @case:351
    Examples:
      | label | room | nights |
      | room 3 for 33 nights | 3 | 33 |
    @case:352
    Examples:
      | label | room | nights |
      | room 3 for 34 nights | 3 | 34 |
    @case:353
    Examples:
      | label | room | nights |
      | room 4 for 1 nights | 4 | 1 |
    @case:354
    Examples:
      | label | room | nights |
      | room 4 for 2 nights | 4 | 2 |
    @case:355
    Examples:
      | label | room | nights |
      | room 4 for 3 nights | 4 | 3 |
    @case:356
    Examples:
      | label | room | nights |
      | room 4 for 4 nights | 4 | 4 |
    @case:357
    Examples:
      | label | room | nights |
      | room 4 for 5 nights | 4 | 5 |
    @case:358
    Examples:
      | label | room | nights |
      | room 4 for 6 nights | 4 | 6 |
    @case:359
    Examples:
      | label | room | nights |
      | room 4 for 7 nights | 4 | 7 |
    @case:360
    Examples:
      | label | room | nights |
      | room 4 for 8 nights | 4 | 8 |
    @case:361
    Examples:
      | label | room | nights |
      | room 4 for 9 nights | 4 | 9 |
    @case:362
    Examples:
      | label | room | nights |
      | room 4 for 10 nights | 4 | 10 |
    @case:363
    Examples:
      | label | room | nights |
      | room 4 for 11 nights | 4 | 11 |
    @case:364
    Examples:
      | label | room | nights |
      | room 4 for 12 nights | 4 | 12 |
    @case:365
    Examples:
      | label | room | nights |
      | room 4 for 13 nights | 4 | 13 |
    @case:366
    Examples:
      | label | room | nights |
      | room 4 for 14 nights | 4 | 14 |
    @case:367
    Examples:
      | label | room | nights |
      | room 4 for 15 nights | 4 | 15 |
    @case:368
    Examples:
      | label | room | nights |
      | room 4 for 16 nights | 4 | 16 |
    @case:369
    Examples:
      | label | room | nights |
      | room 4 for 17 nights | 4 | 17 |
    @case:370
    Examples:
      | label | room | nights |
      | room 4 for 18 nights | 4 | 18 |
    @case:371
    Examples:
      | label | room | nights |
      | room 4 for 19 nights | 4 | 19 |
    @case:372
    Examples:
      | label | room | nights |
      | room 4 for 20 nights | 4 | 20 |
    @case:373
    Examples:
      | label | room | nights |
      | room 4 for 21 nights | 4 | 21 |
    @case:374
    Examples:
      | label | room | nights |
      | room 4 for 22 nights | 4 | 22 |
    @case:375
    Examples:
      | label | room | nights |
      | room 4 for 23 nights | 4 | 23 |
    @case:376
    Examples:
      | label | room | nights |
      | room 4 for 24 nights | 4 | 24 |
    @case:377
    Examples:
      | label | room | nights |
      | room 4 for 25 nights | 4 | 25 |
    @case:378
    Examples:
      | label | room | nights |
      | room 4 for 26 nights | 4 | 26 |
    @case:379
    Examples:
      | label | room | nights |
      | room 4 for 27 nights | 4 | 27 |
    @case:380
    Examples:
      | label | room | nights |
      | room 4 for 28 nights | 4 | 28 |
    @case:381
    Examples:
      | label | room | nights |
      | room 4 for 29 nights | 4 | 29 |
    @case:382
    Examples:
      | label | room | nights |
      | room 4 for 30 nights | 4 | 30 |
    @case:383
    Examples:
      | label | room | nights |
      | room 4 for 31 nights | 4 | 31 |
    @case:384
    Examples:
      | label | room | nights |
      | room 4 for 32 nights | 4 | 32 |
    @case:385
    Examples:
      | label | room | nights |
      | room 4 for 33 nights | 4 | 33 |
    @case:386
    Examples:
      | label | room | nights |
      | room 4 for 34 nights | 4 | 34 |
    @case:387
    Examples:
      | label | room | nights |
      | room 5 for 1 nights | 5 | 1 |
    @case:388
    Examples:
      | label | room | nights |
      | room 5 for 2 nights | 5 | 2 |
    @case:389
    Examples:
      | label | room | nights |
      | room 5 for 3 nights | 5 | 3 |
    @case:390
    Examples:
      | label | room | nights |
      | room 5 for 4 nights | 5 | 4 |
    @case:391
    Examples:
      | label | room | nights |
      | room 5 for 5 nights | 5 | 5 |
    @case:392
    Examples:
      | label | room | nights |
      | room 5 for 6 nights | 5 | 6 |
    @case:393
    Examples:
      | label | room | nights |
      | room 5 for 7 nights | 5 | 7 |
    @case:394
    Examples:
      | label | room | nights |
      | room 5 for 8 nights | 5 | 8 |
    @case:395
    Examples:
      | label | room | nights |
      | room 5 for 9 nights | 5 | 9 |
    @case:396
    Examples:
      | label | room | nights |
      | room 5 for 10 nights | 5 | 10 |
    @case:397
    Examples:
      | label | room | nights |
      | room 5 for 11 nights | 5 | 11 |
    @case:398
    Examples:
      | label | room | nights |
      | room 5 for 12 nights | 5 | 12 |
    @case:399
    Examples:
      | label | room | nights |
      | room 5 for 13 nights | 5 | 13 |
    @case:400
    Examples:
      | label | room | nights |
      | room 5 for 14 nights | 5 | 14 |
    @case:401
    Examples:
      | label | room | nights |
      | room 5 for 15 nights | 5 | 15 |
    @case:402
    Examples:
      | label | room | nights |
      | room 5 for 16 nights | 5 | 16 |
    @case:403
    Examples:
      | label | room | nights |
      | room 5 for 17 nights | 5 | 17 |
    @case:404
    Examples:
      | label | room | nights |
      | room 5 for 18 nights | 5 | 18 |
    @case:405
    Examples:
      | label | room | nights |
      | room 5 for 19 nights | 5 | 19 |
    @case:406
    Examples:
      | label | room | nights |
      | room 5 for 20 nights | 5 | 20 |
    @case:407
    Examples:
      | label | room | nights |
      | room 5 for 21 nights | 5 | 21 |
    @case:408
    Examples:
      | label | room | nights |
      | room 5 for 22 nights | 5 | 22 |
    @case:409
    Examples:
      | label | room | nights |
      | room 5 for 23 nights | 5 | 23 |
    @case:410
    Examples:
      | label | room | nights |
      | room 5 for 24 nights | 5 | 24 |
    @case:411
    Examples:
      | label | room | nights |
      | room 5 for 25 nights | 5 | 25 |
    @case:412
    Examples:
      | label | room | nights |
      | room 5 for 26 nights | 5 | 26 |
    @case:413
    Examples:
      | label | room | nights |
      | room 5 for 27 nights | 5 | 27 |
    @case:414
    Examples:
      | label | room | nights |
      | room 5 for 28 nights | 5 | 28 |
    @case:415
    Examples:
      | label | room | nights |
      | room 5 for 29 nights | 5 | 29 |
    @case:416
    Examples:
      | label | room | nights |
      | room 5 for 30 nights | 5 | 30 |
    @case:417
    Examples:
      | label | room | nights |
      | room 5 for 31 nights | 5 | 31 |
    @case:418
    Examples:
      | label | room | nights |
      | room 5 for 32 nights | 5 | 32 |
    @case:419
    Examples:
      | label | room | nights |
      | room 5 for 33 nights | 5 | 33 |
    @case:420
    Examples:
      | label | room | nights |
      | room 5 for 34 nights | 5 | 34 |


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

  Scenario Outline: A quote for room <room> for <nights> nights is internally consistent
    When I request a quote for room <room> for <nights> nights
    Then the quote is internally consistent

    @case:721
    Examples:
      | room | nights |
      | 1 | 1 |
    @case:722
    Examples:
      | room | nights |
      | 1 | 2 |
    @case:723
    Examples:
      | room | nights |
      | 1 | 3 |
    @case:724
    Examples:
      | room | nights |
      | 1 | 4 |
    @case:725
    Examples:
      | room | nights |
      | 1 | 5 |
    @case:726
    Examples:
      | room | nights |
      | 1 | 6 |
    @case:727
    Examples:
      | room | nights |
      | 1 | 7 |
    @case:728
    Examples:
      | room | nights |
      | 1 | 8 |
    @case:729
    Examples:
      | room | nights |
      | 1 | 9 |
    @case:730
    Examples:
      | room | nights |
      | 1 | 10 |
    @case:731
    Examples:
      | room | nights |
      | 1 | 11 |
    @case:732
    Examples:
      | room | nights |
      | 1 | 12 |
    @case:733
    Examples:
      | room | nights |
      | 1 | 13 |
    @case:734
    Examples:
      | room | nights |
      | 1 | 14 |
    @case:735
    Examples:
      | room | nights |
      | 1 | 15 |
    @case:736
    Examples:
      | room | nights |
      | 1 | 16 |
    @case:737
    Examples:
      | room | nights |
      | 1 | 17 |
    @case:738
    Examples:
      | room | nights |
      | 1 | 18 |
    @case:739
    Examples:
      | room | nights |
      | 1 | 19 |
    @case:740
    Examples:
      | room | nights |
      | 1 | 20 |
    @case:741
    Examples:
      | room | nights |
      | 1 | 21 |
    @case:742
    Examples:
      | room | nights |
      | 1 | 22 |
    @case:743
    Examples:
      | room | nights |
      | 1 | 23 |
    @case:744
    Examples:
      | room | nights |
      | 1 | 24 |
    @case:745
    Examples:
      | room | nights |
      | 1 | 25 |
    @case:746
    Examples:
      | room | nights |
      | 1 | 26 |
    @case:747
    Examples:
      | room | nights |
      | 1 | 27 |
    @case:748
    Examples:
      | room | nights |
      | 1 | 28 |
    @case:749
    Examples:
      | room | nights |
      | 1 | 29 |
    @case:750
    Examples:
      | room | nights |
      | 1 | 30 |
    @case:751
    Examples:
      | room | nights |
      | 2 | 1 |
    @case:752
    Examples:
      | room | nights |
      | 2 | 2 |
    @case:753
    Examples:
      | room | nights |
      | 2 | 3 |
    @case:754
    Examples:
      | room | nights |
      | 2 | 4 |
    @case:755
    Examples:
      | room | nights |
      | 2 | 5 |
    @case:756
    Examples:
      | room | nights |
      | 2 | 6 |
    @case:757
    Examples:
      | room | nights |
      | 2 | 7 |
    @case:758
    Examples:
      | room | nights |
      | 2 | 8 |
    @case:759
    Examples:
      | room | nights |
      | 2 | 9 |
    @case:760
    Examples:
      | room | nights |
      | 2 | 10 |
    @case:761
    Examples:
      | room | nights |
      | 2 | 11 |
    @case:762
    Examples:
      | room | nights |
      | 2 | 12 |
    @case:763
    Examples:
      | room | nights |
      | 2 | 13 |
    @case:764
    Examples:
      | room | nights |
      | 2 | 14 |
    @case:765
    Examples:
      | room | nights |
      | 2 | 15 |
    @case:766
    Examples:
      | room | nights |
      | 2 | 16 |
    @case:767
    Examples:
      | room | nights |
      | 2 | 17 |
    @case:768
    Examples:
      | room | nights |
      | 2 | 18 |
    @case:769
    Examples:
      | room | nights |
      | 2 | 19 |
    @case:770
    Examples:
      | room | nights |
      | 2 | 20 |
    @case:771
    Examples:
      | room | nights |
      | 2 | 21 |
    @case:772
    Examples:
      | room | nights |
      | 2 | 22 |
    @case:773
    Examples:
      | room | nights |
      | 2 | 23 |
    @case:774
    Examples:
      | room | nights |
      | 2 | 24 |
    @case:775
    Examples:
      | room | nights |
      | 2 | 25 |
    @case:776
    Examples:
      | room | nights |
      | 2 | 26 |
    @case:777
    Examples:
      | room | nights |
      | 2 | 27 |
    @case:778
    Examples:
      | room | nights |
      | 2 | 28 |
    @case:779
    Examples:
      | room | nights |
      | 2 | 29 |
    @case:780
    Examples:
      | room | nights |
      | 2 | 30 |
    @case:781
    Examples:
      | room | nights |
      | 3 | 1 |
    @case:782
    Examples:
      | room | nights |
      | 3 | 2 |
    @case:783
    Examples:
      | room | nights |
      | 3 | 3 |
    @case:784
    Examples:
      | room | nights |
      | 3 | 4 |
    @case:785
    Examples:
      | room | nights |
      | 3 | 5 |
    @case:786
    Examples:
      | room | nights |
      | 3 | 6 |
    @case:787
    Examples:
      | room | nights |
      | 3 | 7 |
    @case:788
    Examples:
      | room | nights |
      | 3 | 8 |
    @case:789
    Examples:
      | room | nights |
      | 3 | 9 |
    @case:790
    Examples:
      | room | nights |
      | 3 | 10 |
    @case:791
    Examples:
      | room | nights |
      | 3 | 11 |
    @case:792
    Examples:
      | room | nights |
      | 3 | 12 |
    @case:793
    Examples:
      | room | nights |
      | 3 | 13 |
    @case:794
    Examples:
      | room | nights |
      | 3 | 14 |
    @case:795
    Examples:
      | room | nights |
      | 3 | 15 |
    @case:796
    Examples:
      | room | nights |
      | 3 | 16 |
    @case:797
    Examples:
      | room | nights |
      | 3 | 17 |
    @case:798
    Examples:
      | room | nights |
      | 3 | 18 |
    @case:799
    Examples:
      | room | nights |
      | 3 | 19 |
    @case:800
    Examples:
      | room | nights |
      | 3 | 20 |
    @case:801
    Examples:
      | room | nights |
      | 3 | 21 |
    @case:802
    Examples:
      | room | nights |
      | 3 | 22 |
    @case:803
    Examples:
      | room | nights |
      | 3 | 23 |
    @case:804
    Examples:
      | room | nights |
      | 3 | 24 |
    @case:805
    Examples:
      | room | nights |
      | 3 | 25 |
    @case:806
    Examples:
      | room | nights |
      | 3 | 26 |
    @case:807
    Examples:
      | room | nights |
      | 3 | 27 |
    @case:808
    Examples:
      | room | nights |
      | 3 | 28 |
    @case:809
    Examples:
      | room | nights |
      | 3 | 29 |
    @case:810
    Examples:
      | room | nights |
      | 3 | 30 |
    @case:811
    Examples:
      | room | nights |
      | 4 | 1 |
    @case:812
    Examples:
      | room | nights |
      | 4 | 2 |
    @case:813
    Examples:
      | room | nights |
      | 4 | 3 |
    @case:814
    Examples:
      | room | nights |
      | 4 | 4 |
    @case:815
    Examples:
      | room | nights |
      | 4 | 5 |
    @case:816
    Examples:
      | room | nights |
      | 4 | 6 |
    @case:817
    Examples:
      | room | nights |
      | 4 | 7 |
    @case:818
    Examples:
      | room | nights |
      | 4 | 8 |
    @case:819
    Examples:
      | room | nights |
      | 4 | 9 |
    @case:820
    Examples:
      | room | nights |
      | 4 | 10 |
    @case:821
    Examples:
      | room | nights |
      | 4 | 11 |
    @case:822
    Examples:
      | room | nights |
      | 4 | 12 |
    @case:823
    Examples:
      | room | nights |
      | 4 | 13 |
    @case:824
    Examples:
      | room | nights |
      | 4 | 14 |
    @case:825
    Examples:
      | room | nights |
      | 4 | 15 |
    @case:826
    Examples:
      | room | nights |
      | 4 | 16 |
    @case:827
    Examples:
      | room | nights |
      | 4 | 17 |
    @case:828
    Examples:
      | room | nights |
      | 4 | 18 |
    @case:829
    Examples:
      | room | nights |
      | 4 | 19 |
    @case:830
    Examples:
      | room | nights |
      | 4 | 20 |
    @case:831
    Examples:
      | room | nights |
      | 4 | 21 |
    @case:832
    Examples:
      | room | nights |
      | 4 | 22 |
    @case:833
    Examples:
      | room | nights |
      | 4 | 23 |
    @case:834
    Examples:
      | room | nights |
      | 4 | 24 |
    @case:835
    Examples:
      | room | nights |
      | 4 | 25 |
    @case:836
    Examples:
      | room | nights |
      | 4 | 26 |
    @case:837
    Examples:
      | room | nights |
      | 4 | 27 |
    @case:838
    Examples:
      | room | nights |
      | 4 | 28 |
    @case:839
    Examples:
      | room | nights |
      | 4 | 29 |
    @case:840
    Examples:
      | room | nights |
      | 4 | 30 |
    @case:841
    Examples:
      | room | nights |
      | 5 | 1 |
    @case:842
    Examples:
      | room | nights |
      | 5 | 2 |
    @case:843
    Examples:
      | room | nights |
      | 5 | 3 |
    @case:844
    Examples:
      | room | nights |
      | 5 | 4 |
    @case:845
    Examples:
      | room | nights |
      | 5 | 5 |
    @case:846
    Examples:
      | room | nights |
      | 5 | 6 |
    @case:847
    Examples:
      | room | nights |
      | 5 | 7 |
    @case:848
    Examples:
      | room | nights |
      | 5 | 8 |
    @case:849
    Examples:
      | room | nights |
      | 5 | 9 |
    @case:850
    Examples:
      | room | nights |
      | 5 | 10 |
    @case:851
    Examples:
      | room | nights |
      | 5 | 11 |
    @case:852
    Examples:
      | room | nights |
      | 5 | 12 |
    @case:853
    Examples:
      | room | nights |
      | 5 | 13 |
    @case:854
    Examples:
      | room | nights |
      | 5 | 14 |
    @case:855
    Examples:
      | room | nights |
      | 5 | 15 |
    @case:856
    Examples:
      | room | nights |
      | 5 | 16 |
    @case:857
    Examples:
      | room | nights |
      | 5 | 17 |
    @case:858
    Examples:
      | room | nights |
      | 5 | 18 |
    @case:859
    Examples:
      | room | nights |
      | 5 | 19 |
    @case:860
    Examples:
      | room | nights |
      | 5 | 20 |
    @case:861
    Examples:
      | room | nights |
      | 5 | 21 |
    @case:862
    Examples:
      | room | nights |
      | 5 | 22 |
    @case:863
    Examples:
      | room | nights |
      | 5 | 23 |
    @case:864
    Examples:
      | room | nights |
      | 5 | 24 |
    @case:865
    Examples:
      | room | nights |
      | 5 | 25 |
    @case:866
    Examples:
      | room | nights |
      | 5 | 26 |
    @case:867
    Examples:
      | room | nights |
      | 5 | 27 |
    @case:868
    Examples:
      | room | nights |
      | 5 | 28 |
    @case:869
    Examples:
      | room | nights |
      | 5 | 29 |
    @case:870
    Examples:
      | room | nights |
      | 5 | 30 |

  Scenario Outline: A quote for room <room> for <nights> nights reports <nights> nights
    When I request a quote for room <room> for <nights> nights
    Then the quote is for <nights> nights

    @case:871
    Examples:
      | room | nights |
      | 1 | 1 |
    @case:872
    Examples:
      | room | nights |
      | 1 | 2 |
    @case:873
    Examples:
      | room | nights |
      | 1 | 3 |
    @case:874
    Examples:
      | room | nights |
      | 1 | 4 |
    @case:875
    Examples:
      | room | nights |
      | 1 | 5 |
    @case:876
    Examples:
      | room | nights |
      | 1 | 6 |
    @case:877
    Examples:
      | room | nights |
      | 1 | 7 |
    @case:878
    Examples:
      | room | nights |
      | 1 | 8 |
    @case:879
    Examples:
      | room | nights |
      | 1 | 9 |
    @case:880
    Examples:
      | room | nights |
      | 1 | 10 |
    @case:881
    Examples:
      | room | nights |
      | 1 | 11 |
    @case:882
    Examples:
      | room | nights |
      | 1 | 12 |
    @case:883
    Examples:
      | room | nights |
      | 1 | 13 |
    @case:884
    Examples:
      | room | nights |
      | 1 | 14 |
    @case:885
    Examples:
      | room | nights |
      | 1 | 15 |
    @case:886
    Examples:
      | room | nights |
      | 1 | 16 |
    @case:887
    Examples:
      | room | nights |
      | 1 | 17 |
    @case:888
    Examples:
      | room | nights |
      | 1 | 18 |
    @case:889
    Examples:
      | room | nights |
      | 1 | 19 |
    @case:890
    Examples:
      | room | nights |
      | 1 | 20 |
    @case:891
    Examples:
      | room | nights |
      | 1 | 21 |
    @case:892
    Examples:
      | room | nights |
      | 1 | 22 |
    @case:893
    Examples:
      | room | nights |
      | 1 | 23 |
    @case:894
    Examples:
      | room | nights |
      | 1 | 24 |
    @case:895
    Examples:
      | room | nights |
      | 1 | 25 |
    @case:896
    Examples:
      | room | nights |
      | 1 | 26 |
    @case:897
    Examples:
      | room | nights |
      | 2 | 1 |
    @case:898
    Examples:
      | room | nights |
      | 2 | 2 |
    @case:899
    Examples:
      | room | nights |
      | 2 | 3 |
    @case:900
    Examples:
      | room | nights |
      | 2 | 4 |
    @case:901
    Examples:
      | room | nights |
      | 2 | 5 |
    @case:902
    Examples:
      | room | nights |
      | 2 | 6 |
    @case:903
    Examples:
      | room | nights |
      | 2 | 7 |
    @case:904
    Examples:
      | room | nights |
      | 2 | 8 |
    @case:905
    Examples:
      | room | nights |
      | 2 | 9 |
    @case:906
    Examples:
      | room | nights |
      | 2 | 10 |
    @case:907
    Examples:
      | room | nights |
      | 2 | 11 |
    @case:908
    Examples:
      | room | nights |
      | 2 | 12 |
    @case:909
    Examples:
      | room | nights |
      | 2 | 13 |
    @case:910
    Examples:
      | room | nights |
      | 2 | 14 |
    @case:911
    Examples:
      | room | nights |
      | 2 | 15 |
    @case:912
    Examples:
      | room | nights |
      | 2 | 16 |
    @case:913
    Examples:
      | room | nights |
      | 2 | 17 |
    @case:914
    Examples:
      | room | nights |
      | 2 | 18 |
    @case:915
    Examples:
      | room | nights |
      | 2 | 19 |
    @case:916
    Examples:
      | room | nights |
      | 2 | 20 |
    @case:917
    Examples:
      | room | nights |
      | 2 | 21 |
    @case:918
    Examples:
      | room | nights |
      | 2 | 22 |
    @case:919
    Examples:
      | room | nights |
      | 2 | 23 |
    @case:920
    Examples:
      | room | nights |
      | 2 | 24 |
    @case:921
    Examples:
      | room | nights |
      | 2 | 25 |
    @case:922
    Examples:
      | room | nights |
      | 2 | 26 |
    @case:923
    Examples:
      | room | nights |
      | 3 | 1 |
    @case:924
    Examples:
      | room | nights |
      | 3 | 2 |
    @case:925
    Examples:
      | room | nights |
      | 3 | 3 |
    @case:926
    Examples:
      | room | nights |
      | 3 | 4 |
    @case:927
    Examples:
      | room | nights |
      | 3 | 5 |
    @case:928
    Examples:
      | room | nights |
      | 3 | 6 |
    @case:929
    Examples:
      | room | nights |
      | 3 | 7 |
    @case:930
    Examples:
      | room | nights |
      | 3 | 8 |
    @case:931
    Examples:
      | room | nights |
      | 3 | 9 |
    @case:932
    Examples:
      | room | nights |
      | 3 | 10 |
    @case:933
    Examples:
      | room | nights |
      | 3 | 11 |
    @case:934
    Examples:
      | room | nights |
      | 3 | 12 |
    @case:935
    Examples:
      | room | nights |
      | 3 | 13 |
    @case:936
    Examples:
      | room | nights |
      | 3 | 14 |
    @case:937
    Examples:
      | room | nights |
      | 3 | 15 |
    @case:938
    Examples:
      | room | nights |
      | 3 | 16 |
    @case:939
    Examples:
      | room | nights |
      | 3 | 17 |
    @case:940
    Examples:
      | room | nights |
      | 3 | 18 |
    @case:941
    Examples:
      | room | nights |
      | 3 | 19 |
    @case:942
    Examples:
      | room | nights |
      | 3 | 20 |
    @case:943
    Examples:
      | room | nights |
      | 3 | 21 |
    @case:944
    Examples:
      | room | nights |
      | 3 | 22 |
    @case:945
    Examples:
      | room | nights |
      | 3 | 23 |
    @case:946
    Examples:
      | room | nights |
      | 3 | 24 |
    @case:947
    Examples:
      | room | nights |
      | 3 | 25 |
    @case:948
    Examples:
      | room | nights |
      | 3 | 26 |
    @case:949
    Examples:
      | room | nights |
      | 4 | 1 |
    @case:950
    Examples:
      | room | nights |
      | 4 | 2 |
    @case:951
    Examples:
      | room | nights |
      | 4 | 3 |
    @case:952
    Examples:
      | room | nights |
      | 4 | 4 |
    @case:953
    Examples:
      | room | nights |
      | 4 | 5 |
    @case:954
    Examples:
      | room | nights |
      | 4 | 6 |
    @case:955
    Examples:
      | room | nights |
      | 4 | 7 |
    @case:956
    Examples:
      | room | nights |
      | 4 | 8 |
    @case:957
    Examples:
      | room | nights |
      | 4 | 9 |
    @case:958
    Examples:
      | room | nights |
      | 4 | 10 |
    @case:959
    Examples:
      | room | nights |
      | 4 | 11 |
    @case:960
    Examples:
      | room | nights |
      | 4 | 12 |
    @case:961
    Examples:
      | room | nights |
      | 4 | 13 |
    @case:962
    Examples:
      | room | nights |
      | 4 | 14 |
    @case:963
    Examples:
      | room | nights |
      | 4 | 15 |
    @case:964
    Examples:
      | room | nights |
      | 4 | 16 |
    @case:965
    Examples:
      | room | nights |
      | 4 | 17 |
    @case:966
    Examples:
      | room | nights |
      | 4 | 18 |
    @case:967
    Examples:
      | room | nights |
      | 4 | 19 |
    @case:968
    Examples:
      | room | nights |
      | 4 | 20 |
    @case:969
    Examples:
      | room | nights |
      | 4 | 21 |
    @case:970
    Examples:
      | room | nights |
      | 4 | 22 |
    @case:971
    Examples:
      | room | nights |
      | 4 | 23 |
    @case:972
    Examples:
      | room | nights |
      | 4 | 24 |
    @case:973
    Examples:
      | room | nights |
      | 4 | 25 |
    @case:974
    Examples:
      | room | nights |
      | 4 | 26 |
    @case:975
    Examples:
      | room | nights |
      | 5 | 1 |
    @case:976
    Examples:
      | room | nights |
      | 5 | 2 |
    @case:977
    Examples:
      | room | nights |
      | 5 | 3 |
    @case:978
    Examples:
      | room | nights |
      | 5 | 4 |
    @case:979
    Examples:
      | room | nights |
      | 5 | 5 |
    @case:980
    Examples:
      | room | nights |
      | 5 | 6 |
    @case:981
    Examples:
      | room | nights |
      | 5 | 7 |
    @case:982
    Examples:
      | room | nights |
      | 5 | 8 |
    @case:983
    Examples:
      | room | nights |
      | 5 | 9 |
    @case:984
    Examples:
      | room | nights |
      | 5 | 10 |
    @case:985
    Examples:
      | room | nights |
      | 5 | 11 |
    @case:986
    Examples:
      | room | nights |
      | 5 | 12 |
    @case:987
    Examples:
      | room | nights |
      | 5 | 13 |
    @case:988
    Examples:
      | room | nights |
      | 5 | 14 |
    @case:989
    Examples:
      | room | nights |
      | 5 | 15 |
    @case:990
    Examples:
      | room | nights |
      | 5 | 16 |
    @case:991
    Examples:
      | room | nights |
      | 5 | 17 |
    @case:992
    Examples:
      | room | nights |
      | 5 | 18 |
    @case:993
    Examples:
      | room | nights |
      | 5 | 19 |
    @case:994
    Examples:
      | room | nights |
      | 5 | 20 |
    @case:995
    Examples:
      | room | nights |
      | 5 | 21 |
    @case:996
    Examples:
      | room | nights |
      | 5 | 22 |
    @case:997
    Examples:
      | room | nights |
      | 5 | 23 |
    @case:998
    Examples:
      | room | nights |
      | 5 | 24 |
    @case:999
    Examples:
      | room | nights |
      | 5 | 25 |
    @case:1000
    Examples:
      | room | nights |
      | 5 | 26 |
