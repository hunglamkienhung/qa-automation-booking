# Hotel booking — test cases

1000 cases across a self-written mini-stay service (a real SQLite store behind the search, hold, booking lifecycle and cancellation flows) and the live Frankfurter FX API. Generated from `../features/*.feature` by `build.js`; do not edit by hand.

## mini-stay-db (202)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 1 | BE/DB | High | The store has the documented tables |
| 2 | BE/DB | High | A room's capacity and inventory are bounded by CHECK |
| 3 | BE/DB | High | A room type references a real hotel |
| 4 | BE/DB | High | A booking references a real guest, hotel and room type |
| 5 | BE/DB | High | A booking event references a real booking |
| 6 | BE/DB | High | Money amounts are bounded by CHECK |
| 7 | BE/DB | High | A booking's dates run forward and cover at least one night |
| 8 | BE/DB | High | A booking status is one of the lifecycle states |
| 9 | BE/DB | Medium | A booking event names a known actor |
| 10 | BE/DB | Medium | A cancellation policy is one of the known kinds |
| 11 | BE/DB | Medium | A ledger entry is a real, non-zero amount with a known reason and party |
| 12 | BE/DB | Medium | A hotel's tax rate is not negative |
| 13 | BE/DB | Medium | An idempotency key is unique across bookings |
| 14 | BE/DB | Medium | Seeding twice leaves the same rows |
| 15 | BE/DB | High | Holding a room writes a held booking with the priced money |
| 16 | BE/DB | High | A held booking snapshots the rate and the cancellation policy |
| 17 | BE/DB | High | The hold expiry is the creation time plus the hold window |
| 18 | BE/DB | High | Confirming a hold moves it to confirmed and records the transition |
| 19 | BE/DB | High | Confirming posts the price to the ledger |
| 20 | BE/DB | Medium | A held booking has posted nothing to the ledger |
| 21 | BE/DB | High | A full stay writes an event for every transition |
| 22 | BE/DB | High | Cancelling a confirmed booking records the transition and a refund |
| 23 | BE/DB | Medium | Cancelling an unpaid hold refunds nothing |
| 24 | BE/DB | Medium | A no-show is a hotelier transition off a confirmed booking |
| 25 | BE/DB | High | Confirming an expired hold marks it expired and pays nothing |
| 26 | BE/DB | High | A held booking occupies one room on each of its nights |
| 27 | BE/DB | High | The scarce room is never occupied beyond its inventory |
| 28 | BE/DB | Medium | A cancelled hold stops occupying the room |
| 29 | BE/DB | Medium | No booking references a missing guest, hotel or room type |
| 30 | BE/DB | Medium | Every confirmed or cancelled booking's ledger matches its state |
| 31 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 32 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 33 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 34 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 35 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 36 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 37 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 38 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 39 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 40 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 217 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 218 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 219 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 220 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 221 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 222 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 223 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 224 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 225 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 226 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 227 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 228 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 421 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 422 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 423 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 424 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 425 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 426 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 427 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 428 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 429 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 430 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 431 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 432 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 433 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 434 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 435 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 436 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 437 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 438 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 439 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 440 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 441 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 442 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 443 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 444 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 445 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 446 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 447 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 448 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 449 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 450 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 451 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 452 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 453 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 454 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 455 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 456 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 457 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 458 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 459 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 460 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 461 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 462 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 463 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 464 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 465 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 466 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 467 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 468 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 469 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 470 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 471 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 472 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 473 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 474 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 475 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 476 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 477 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 478 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 479 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 480 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 481 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 482 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 483 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 484 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 485 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 486 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 487 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 488 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 489 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 490 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 491 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 492 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 493 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 494 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 495 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 496 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 497 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 498 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 499 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 500 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 501 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 502 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 503 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 504 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 505 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 506 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 507 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 508 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 509 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 510 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 511 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 512 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 513 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 514 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 515 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 516 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 517 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 518 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 519 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 520 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 521 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 522 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 523 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 524 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 525 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 526 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 527 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 528 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 529 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 530 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 531 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 532 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 533 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 534 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 535 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 536 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 537 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 538 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 539 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 540 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 541 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 542 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 543 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 544 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 545 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 546 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 547 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 548 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 549 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 550 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 551 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 552 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 553 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 554 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 555 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 556 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 557 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 558 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 559 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 560 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 561 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 562 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 563 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 564 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 565 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 566 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 567 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 568 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 569 | BE/DB | Medium | A <label> hold prices and occupies correctly |
| 570 | BE/DB | Medium | A <label> hold prices and occupies correctly |

## mini-stay-pricing (504)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 41 | BE/API | High | A two-night standard double is priced to the cent |
| 42 | BE/API | High | A three-night standard double |
| 43 | BE/API | High | A two-night sea-view suite |
| 44 | BE/API | High | A one-night penthouse |
| 45 | BE/API | High | A two-night queen room at the other hotel's tax rate |
| 46 | BE/API | High | A three-night family cabin |
| 47 | BE/API | Medium | A quote is internally consistent |
| 48 | BE/API | Medium | A quote carries the room's cancellation policy |
| 49 | BE/API | Medium | A quote reports the number of nights it priced |
| 50 | BE/API | Medium | <label> prices to the reference formula |
| 51 | BE/API | Medium | <label> prices to the reference formula |
| 52 | BE/API | Medium | <label> prices to the reference formula |
| 53 | BE/API | Medium | <label> prices to the reference formula |
| 54 | BE/API | Medium | <label> prices to the reference formula |
| 55 | BE/API | Medium | <label> prices to the reference formula |
| 56 | BE/API | Medium | <label> prices to the reference formula |
| 57 | BE/API | Medium | <label> prices to the reference formula |
| 58 | BE/API | Medium | <label> prices to the reference formula |
| 59 | BE/API | Medium | <label> prices to the reference formula |
| 60 | BE/API | Medium | <label> prices to the reference formula |
| 61 | BE/API | Medium | <label> prices to the reference formula |
| 62 | BE/API | Medium | <label> prices to the reference formula |
| 63 | BE/API | Medium | <label> prices to the reference formula |
| 64 | BE/API | Medium | <label> prices to the reference formula |
| 65 | BE/API | Medium | <label> prices to the reference formula |
| 66 | BE/API | Medium | <label> prices to the reference formula |
| 67 | BE/API | Medium | <label> prices to the reference formula |
| 68 | BE/API | Medium | <label> prices to the reference formula |
| 69 | BE/API | Medium | <label> prices to the reference formula |
| 70 | BE/API | High | A check-out on the check-in day is refused |
| 71 | BE/API | High | A stay that is not a whole number of nights is refused |
| 72 | BE/API | Medium | A quote for a room that does not exist is not found |
| 73 | BE/API | High | A room at an inactive hotel cannot be priced |
| 74 | BE/API | Medium | A check-out before the check-in is refused |
| 197 | BE/API | Medium | <label> prices to the reference formula |
| 198 | BE/API | Medium | <label> prices to the reference formula |
| 199 | BE/API | Medium | <label> prices to the reference formula |
| 200 | BE/API | Medium | <label> prices to the reference formula |
| 201 | BE/API | Medium | <label> prices to the reference formula |
| 202 | BE/API | Medium | <label> prices to the reference formula |
| 203 | BE/API | Medium | <label> prices to the reference formula |
| 204 | BE/API | Medium | <label> prices to the reference formula |
| 205 | BE/API | Medium | <label> prices to the reference formula |
| 206 | BE/API | Medium | <label> prices to the reference formula |
| 207 | BE/API | Medium | <label> prices to the reference formula |
| 208 | BE/API | Medium | <label> prices to the reference formula |
| 209 | BE/API | Medium | <label> prices to the reference formula |
| 210 | BE/API | Medium | <label> prices to the reference formula |
| 211 | BE/API | Medium | <label> prices to the reference formula |
| 212 | BE/API | Medium | <label> prices to the reference formula |
| 213 | BE/API | Medium | <label> prices to the reference formula |
| 214 | BE/API | Medium | <label> prices to the reference formula |
| 215 | BE/API | Medium | <label> prices to the reference formula |
| 216 | BE/API | Medium | <label> prices to the reference formula |
| 251 | BE/API | Medium | <label> prices to the reference formula |
| 252 | BE/API | Medium | <label> prices to the reference formula |
| 253 | BE/API | Medium | <label> prices to the reference formula |
| 254 | BE/API | Medium | <label> prices to the reference formula |
| 255 | BE/API | Medium | <label> prices to the reference formula |
| 256 | BE/API | Medium | <label> prices to the reference formula |
| 257 | BE/API | Medium | <label> prices to the reference formula |
| 258 | BE/API | Medium | <label> prices to the reference formula |
| 259 | BE/API | Medium | <label> prices to the reference formula |
| 260 | BE/API | Medium | <label> prices to the reference formula |
| 261 | BE/API | Medium | <label> prices to the reference formula |
| 262 | BE/API | Medium | <label> prices to the reference formula |
| 263 | BE/API | Medium | <label> prices to the reference formula |
| 264 | BE/API | Medium | <label> prices to the reference formula |
| 265 | BE/API | Medium | <label> prices to the reference formula |
| 266 | BE/API | Medium | <label> prices to the reference formula |
| 267 | BE/API | Medium | <label> prices to the reference formula |
| 268 | BE/API | Medium | <label> prices to the reference formula |
| 269 | BE/API | Medium | <label> prices to the reference formula |
| 270 | BE/API | Medium | <label> prices to the reference formula |
| 271 | BE/API | Medium | <label> prices to the reference formula |
| 272 | BE/API | Medium | <label> prices to the reference formula |
| 273 | BE/API | Medium | <label> prices to the reference formula |
| 274 | BE/API | Medium | <label> prices to the reference formula |
| 275 | BE/API | Medium | <label> prices to the reference formula |
| 276 | BE/API | Medium | <label> prices to the reference formula |
| 277 | BE/API | Medium | <label> prices to the reference formula |
| 278 | BE/API | Medium | <label> prices to the reference formula |
| 279 | BE/API | Medium | <label> prices to the reference formula |
| 280 | BE/API | Medium | <label> prices to the reference formula |
| 281 | BE/API | Medium | <label> prices to the reference formula |
| 282 | BE/API | Medium | <label> prices to the reference formula |
| 283 | BE/API | Medium | <label> prices to the reference formula |
| 284 | BE/API | Medium | <label> prices to the reference formula |
| 285 | BE/API | Medium | <label> prices to the reference formula |
| 286 | BE/API | Medium | <label> prices to the reference formula |
| 287 | BE/API | Medium | <label> prices to the reference formula |
| 288 | BE/API | Medium | <label> prices to the reference formula |
| 289 | BE/API | Medium | <label> prices to the reference formula |
| 290 | BE/API | Medium | <label> prices to the reference formula |
| 291 | BE/API | Medium | <label> prices to the reference formula |
| 292 | BE/API | Medium | <label> prices to the reference formula |
| 293 | BE/API | Medium | <label> prices to the reference formula |
| 294 | BE/API | Medium | <label> prices to the reference formula |
| 295 | BE/API | Medium | <label> prices to the reference formula |
| 296 | BE/API | Medium | <label> prices to the reference formula |
| 297 | BE/API | Medium | <label> prices to the reference formula |
| 298 | BE/API | Medium | <label> prices to the reference formula |
| 299 | BE/API | Medium | <label> prices to the reference formula |
| 300 | BE/API | Medium | <label> prices to the reference formula |
| 301 | BE/API | Medium | <label> prices to the reference formula |
| 302 | BE/API | Medium | <label> prices to the reference formula |
| 303 | BE/API | Medium | <label> prices to the reference formula |
| 304 | BE/API | Medium | <label> prices to the reference formula |
| 305 | BE/API | Medium | <label> prices to the reference formula |
| 306 | BE/API | Medium | <label> prices to the reference formula |
| 307 | BE/API | Medium | <label> prices to the reference formula |
| 308 | BE/API | Medium | <label> prices to the reference formula |
| 309 | BE/API | Medium | <label> prices to the reference formula |
| 310 | BE/API | Medium | <label> prices to the reference formula |
| 311 | BE/API | Medium | <label> prices to the reference formula |
| 312 | BE/API | Medium | <label> prices to the reference formula |
| 313 | BE/API | Medium | <label> prices to the reference formula |
| 314 | BE/API | Medium | <label> prices to the reference formula |
| 315 | BE/API | Medium | <label> prices to the reference formula |
| 316 | BE/API | Medium | <label> prices to the reference formula |
| 317 | BE/API | Medium | <label> prices to the reference formula |
| 318 | BE/API | Medium | <label> prices to the reference formula |
| 319 | BE/API | Medium | <label> prices to the reference formula |
| 320 | BE/API | Medium | <label> prices to the reference formula |
| 321 | BE/API | Medium | <label> prices to the reference formula |
| 322 | BE/API | Medium | <label> prices to the reference formula |
| 323 | BE/API | Medium | <label> prices to the reference formula |
| 324 | BE/API | Medium | <label> prices to the reference formula |
| 325 | BE/API | Medium | <label> prices to the reference formula |
| 326 | BE/API | Medium | <label> prices to the reference formula |
| 327 | BE/API | Medium | <label> prices to the reference formula |
| 328 | BE/API | Medium | <label> prices to the reference formula |
| 329 | BE/API | Medium | <label> prices to the reference formula |
| 330 | BE/API | Medium | <label> prices to the reference formula |
| 331 | BE/API | Medium | <label> prices to the reference formula |
| 332 | BE/API | Medium | <label> prices to the reference formula |
| 333 | BE/API | Medium | <label> prices to the reference formula |
| 334 | BE/API | Medium | <label> prices to the reference formula |
| 335 | BE/API | Medium | <label> prices to the reference formula |
| 336 | BE/API | Medium | <label> prices to the reference formula |
| 337 | BE/API | Medium | <label> prices to the reference formula |
| 338 | BE/API | Medium | <label> prices to the reference formula |
| 339 | BE/API | Medium | <label> prices to the reference formula |
| 340 | BE/API | Medium | <label> prices to the reference formula |
| 341 | BE/API | Medium | <label> prices to the reference formula |
| 342 | BE/API | Medium | <label> prices to the reference formula |
| 343 | BE/API | Medium | <label> prices to the reference formula |
| 344 | BE/API | Medium | <label> prices to the reference formula |
| 345 | BE/API | Medium | <label> prices to the reference formula |
| 346 | BE/API | Medium | <label> prices to the reference formula |
| 347 | BE/API | Medium | <label> prices to the reference formula |
| 348 | BE/API | Medium | <label> prices to the reference formula |
| 349 | BE/API | Medium | <label> prices to the reference formula |
| 350 | BE/API | Medium | <label> prices to the reference formula |
| 351 | BE/API | Medium | <label> prices to the reference formula |
| 352 | BE/API | Medium | <label> prices to the reference formula |
| 353 | BE/API | Medium | <label> prices to the reference formula |
| 354 | BE/API | Medium | <label> prices to the reference formula |
| 355 | BE/API | Medium | <label> prices to the reference formula |
| 356 | BE/API | Medium | <label> prices to the reference formula |
| 357 | BE/API | Medium | <label> prices to the reference formula |
| 358 | BE/API | Medium | <label> prices to the reference formula |
| 359 | BE/API | Medium | <label> prices to the reference formula |
| 360 | BE/API | Medium | <label> prices to the reference formula |
| 361 | BE/API | Medium | <label> prices to the reference formula |
| 362 | BE/API | Medium | <label> prices to the reference formula |
| 363 | BE/API | Medium | <label> prices to the reference formula |
| 364 | BE/API | Medium | <label> prices to the reference formula |
| 365 | BE/API | Medium | <label> prices to the reference formula |
| 366 | BE/API | Medium | <label> prices to the reference formula |
| 367 | BE/API | Medium | <label> prices to the reference formula |
| 368 | BE/API | Medium | <label> prices to the reference formula |
| 369 | BE/API | Medium | <label> prices to the reference formula |
| 370 | BE/API | Medium | <label> prices to the reference formula |
| 371 | BE/API | Medium | <label> prices to the reference formula |
| 372 | BE/API | Medium | <label> prices to the reference formula |
| 373 | BE/API | Medium | <label> prices to the reference formula |
| 374 | BE/API | Medium | <label> prices to the reference formula |
| 375 | BE/API | Medium | <label> prices to the reference formula |
| 376 | BE/API | Medium | <label> prices to the reference formula |
| 377 | BE/API | Medium | <label> prices to the reference formula |
| 378 | BE/API | Medium | <label> prices to the reference formula |
| 379 | BE/API | Medium | <label> prices to the reference formula |
| 380 | BE/API | Medium | <label> prices to the reference formula |
| 381 | BE/API | Medium | <label> prices to the reference formula |
| 382 | BE/API | Medium | <label> prices to the reference formula |
| 383 | BE/API | Medium | <label> prices to the reference formula |
| 384 | BE/API | Medium | <label> prices to the reference formula |
| 385 | BE/API | Medium | <label> prices to the reference formula |
| 386 | BE/API | Medium | <label> prices to the reference formula |
| 387 | BE/API | Medium | <label> prices to the reference formula |
| 388 | BE/API | Medium | <label> prices to the reference formula |
| 389 | BE/API | Medium | <label> prices to the reference formula |
| 390 | BE/API | Medium | <label> prices to the reference formula |
| 391 | BE/API | Medium | <label> prices to the reference formula |
| 392 | BE/API | Medium | <label> prices to the reference formula |
| 393 | BE/API | Medium | <label> prices to the reference formula |
| 394 | BE/API | Medium | <label> prices to the reference formula |
| 395 | BE/API | Medium | <label> prices to the reference formula |
| 396 | BE/API | Medium | <label> prices to the reference formula |
| 397 | BE/API | Medium | <label> prices to the reference formula |
| 398 | BE/API | Medium | <label> prices to the reference formula |
| 399 | BE/API | Medium | <label> prices to the reference formula |
| 400 | BE/API | Medium | <label> prices to the reference formula |
| 401 | BE/API | Medium | <label> prices to the reference formula |
| 402 | BE/API | Medium | <label> prices to the reference formula |
| 403 | BE/API | Medium | <label> prices to the reference formula |
| 404 | BE/API | Medium | <label> prices to the reference formula |
| 405 | BE/API | Medium | <label> prices to the reference formula |
| 406 | BE/API | Medium | <label> prices to the reference formula |
| 407 | BE/API | Medium | <label> prices to the reference formula |
| 408 | BE/API | Medium | <label> prices to the reference formula |
| 409 | BE/API | Medium | <label> prices to the reference formula |
| 410 | BE/API | Medium | <label> prices to the reference formula |
| 411 | BE/API | Medium | <label> prices to the reference formula |
| 412 | BE/API | Medium | <label> prices to the reference formula |
| 413 | BE/API | Medium | <label> prices to the reference formula |
| 414 | BE/API | Medium | <label> prices to the reference formula |
| 415 | BE/API | Medium | <label> prices to the reference formula |
| 416 | BE/API | Medium | <label> prices to the reference formula |
| 417 | BE/API | Medium | <label> prices to the reference formula |
| 418 | BE/API | Medium | <label> prices to the reference formula |
| 419 | BE/API | Medium | <label> prices to the reference formula |
| 420 | BE/API | Medium | <label> prices to the reference formula |
| 721 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 722 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 723 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 724 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 725 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 726 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 727 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 728 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 729 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 730 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 731 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 732 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 733 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 734 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 735 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 736 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 737 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 738 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 739 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 740 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 741 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 742 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 743 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 744 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 745 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 746 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 747 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 748 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 749 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 750 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 751 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 752 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 753 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 754 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 755 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 756 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 757 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 758 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 759 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 760 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 761 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 762 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 763 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 764 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 765 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 766 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 767 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 768 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 769 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 770 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 771 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 772 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 773 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 774 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 775 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 776 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 777 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 778 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 779 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 780 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 781 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 782 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 783 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 784 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 785 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 786 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 787 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 788 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 789 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 790 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 791 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 792 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 793 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 794 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 795 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 796 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 797 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 798 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 799 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 800 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 801 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 802 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 803 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 804 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 805 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 806 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 807 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 808 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 809 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 810 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 811 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 812 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 813 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 814 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 815 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 816 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 817 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 818 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 819 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 820 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 821 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 822 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 823 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 824 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 825 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 826 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 827 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 828 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 829 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 830 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 831 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 832 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 833 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 834 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 835 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 836 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 837 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 838 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 839 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 840 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 841 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 842 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 843 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 844 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 845 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 846 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 847 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 848 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 849 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 850 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 851 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 852 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 853 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 854 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 855 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 856 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 857 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 858 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 859 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 860 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 861 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 862 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 863 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 864 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 865 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 866 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 867 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 868 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 869 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 870 | BE/API | Medium | A quote for room <room> for <nights> nights is internally consistent |
| 871 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 872 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 873 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 874 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 875 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 876 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 877 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 878 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 879 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 880 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 881 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 882 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 883 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 884 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 885 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 886 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 887 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 888 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 889 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 890 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 891 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 892 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 893 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 894 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 895 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 896 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 897 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 898 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 899 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 900 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 901 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 902 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 903 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 904 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 905 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 906 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 907 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 908 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 909 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 910 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 911 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 912 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 913 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 914 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 915 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 916 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 917 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 918 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 919 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 920 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 921 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 922 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 923 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 924 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 925 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 926 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 927 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 928 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 929 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 930 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 931 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 932 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 933 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 934 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 935 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 936 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 937 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 938 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 939 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 940 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 941 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 942 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 943 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 944 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 945 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 946 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 947 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 948 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 949 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 950 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 951 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 952 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 953 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 954 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 955 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 956 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 957 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 958 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 959 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 960 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 961 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 962 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 963 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 964 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 965 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 966 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 967 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 968 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 969 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 970 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 971 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 972 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 973 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 974 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 975 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 976 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 977 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 978 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 979 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 980 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 981 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 982 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 983 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 984 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 985 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 986 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 987 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 988 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 989 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 990 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 991 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 992 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 993 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 994 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 995 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 996 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 997 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 998 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 999 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |
| 1000 | BE/API | Medium | A quote for room <room> for <nights> nights reports <nights> nights |

## mini-stay-booking (36)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 75 | BE/API | High | Holding a room returns a held booking |
| 76 | BE/API | High | Holding twice with one idempotency key makes one booking |
| 77 | BE/API | High | Holding without a token is unauthenticated |
| 78 | BE/API | High | A room at an inactive hotel cannot be held |
| 79 | BE/API | High | Confirming a hold takes the payment and confirms the booking |
| 80 | BE/API | High | Confirming an expired hold is refused and expires the hold |
| 81 | BE/API | Medium | A booking can be read back with its events |
| 82 | BE/API | Medium | A guest's booking list includes what they held |
| 83 | BE/API | High | The hotelier checks a confirmed guest in and out |
| 84 | BE/API | High | A guest cannot work the front desk |
| 85 | BE/API | High | A no-show is a hotelier action on a confirmed booking |
| 86 | BE/API | High | Cancelling a flexible booking well ahead refunds in full |
| 87 | BE/API | High | A non-refundable booking refunds nothing |
| 88 | BE/API | High | Cancelling an unpaid hold refunds nothing |
| 89 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 90 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 91 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 92 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 93 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 94 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 95 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 96 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 97 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 98 | BE/API | High | A confirmed booking cannot be confirmed again |
| 99 | BE/API | High | A held booking cannot be checked in before it is confirmed |
| 100 | BE/API | High | A checked-out booking cannot be cancelled |
| 101 | BE/API | Medium | A booking cannot be checked out before it is checked in |
| 102 | BE/API | Medium | A cancelled booking cannot be confirmed |
| 229 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 230 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 231 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 232 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 233 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 234 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 235 | BE/API | Medium | Cancelling a <label> booking refunds per policy |
| 236 | BE/API | Medium | Cancelling a <label> booking refunds per policy |

## mini-stay-availability (34)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 103 | BE/API | High | A fresh night on the scarce room shows one available |
| 104 | BE/API | High | Holding the scarce room drops its availability to nought |
| 105 | BE/API | High | A second hold on the held scarce room is refused |
| 106 | BE/API | Medium | Confirming the held scarce room keeps availability at nought |
| 107 | BE/API | High | Cancelling frees the scarce room again |
| 108 | BE/API | High | An expired hold does not occupy the scarce room |
| 109 | BE/API | High | When many guests race for the last room exactly one wins |
| 110 | BE/API | High | The race is decided the same way every time |
| 111 | BE/API | High | A race for a room with several in stock fills exactly the stock |
| 112 | BE/API | High | An overlapping range cannot also take the scarce room |
| 113 | BE/API | High | The nights immediately after are free |
| 114 | BE/API | Medium | A one-night overlap of a longer stay is still a conflict |
| 115 | BE/API | High | A fresh night on a four-room type shows four available |
| 116 | BE/API | High | Filling a four-room type refuses the fifth hold |
| 117 | BE/API | Medium | Cancelling one of several restores one room |
| 118 | BE/API | Medium | A multi-night hold occupies every night of its range |
| 119 | BE/API | Medium | Availability of a check-out on the check-in day is refused |
| 120 | BE/API | Low | Availability of an unknown room is not found |
| 121 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 122 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 123 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 124 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 125 | BE/API | Medium | A fresh night on room <room> shows its full inventory of <inventory> |
| 126 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 127 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 128 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 129 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 130 | BE/API | Medium | A freed room can be taken again |
| 237 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 238 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 239 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 240 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 241 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |
| 242 | BE/API | Medium | A race for room <room> fills exactly its <inventory> rooms |

## mini-stay-security (18)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 131 | BE/API | High | Holding a room requires a guest token |
| 132 | BE/API | High | A forged guest token is refused |
| 133 | BE/API | High | A hotelier token is not accepted as a guest |
| 134 | BE/API | High | A guest token is not accepted at the front desk |
| 135 | BE/API | High | A guest cannot read another guest's booking |
| 136 | BE/API | High | A guest cannot cancel another guest's booking |
| 137 | BE/API | High | A guest cannot confirm another guest's booking |
| 138 | BE/API | High | A hotelier cannot work a hotel it does not own |
| 139 | BE/API | High | The admin overview rejects a guest token |
| 140 | BE/API | High | The admin booking list rejects a guest token |
| 141 | BE/API | High | A token that only extends the admin token is rejected |
| 142 | BE/API | High | The owning guest still reads their own booking |
| 143 | BE/API | High | The owning hotelier still checks a guest in |
| 144 | BE/API | Medium | Guest onboarding is open and issues a token |
| 145 | BE/API | Medium | A quote response never carries a bearer token |
| 146 | BE/API | Medium | A booking response never carries a bearer token |
| 147 | BE/API | Medium | A booking read never carries a bearer token |
| 148 | BE/API | Medium | The admin overview never carries a bearer token |

## mini-stay-fe (20)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 149 | FE/UI | High | The home page lists exactly the active hotels |
| 150 | FE/UI | High | The inactive hotel does not appear on the home page |
| 151 | FE/UI | Medium | Each hotel row shows a currency code |
| 152 | FE/UI | Low | The home page is not empty |
| 153 | FE/UI | High | A hotel page lists its room types |
| 154 | FE/UI | High | Room rates are shown in the hotel's currency |
| 155 | FE/UI | Medium | Each room shows its inventory and cancellation policy |
| 156 | FE/UI | Low | An unknown hotel page is not found |
| 157 | FE/UI | High | A booking page shows the total it was priced at |
| 158 | FE/UI | High | A booking page shows the nights and status |
| 159 | FE/UI | Medium | A booking page total is a currency amount |
| 160 | FE/UI | Low | An unknown booking page is not found |
| 161 | FE/UI | Medium | A <state> booking page shows that status |
| 162 | FE/UI | Medium | A <state> booking page shows that status |
| 163 | FE/UI | High | A guest's booking list shows the booking they held |
| 164 | FE/UI | Medium | Each booking row links to its booking page |
| 165 | FE/UI | Medium | A booking list total is a currency amount |
| 166 | FE/UI | High | The admin page shows the payment taken as a number |
| 167 | FE/UI | Medium | Every admin status count is a non-negative integer |
| 168 | FE/UI | Medium | A confirmed booking shows up in the admin counts |

## frankfurter-api (186)

| ID | Layer | Priority | Title |
|---|---|---|---|
| 169 | BE/API | High | Converting at parity leaves the amount unchanged |
| 170 | BE/API | High | Converting at a half rate halves the amount |
| 171 | BE/API | High | Converting nothing is nothing |
| 172 | BE/API | High | An inexact conversion rounds half-up to the cent |
| 173 | BE/API | Medium | A rate above parity raises the amount |
| 174 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 175 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 176 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 177 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 178 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 179 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 180 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 181 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 182 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 183 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 184 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 185 | BE/API | High | The historical endpoint answers with rates |
| 186 | BE/API | High | The historical response is for one unit of the base currency |
| 187 | BE/API | High | The historical euro rate is a positive number |
| 188 | BE/API | Medium | The historical pound rate is a positive number |
| 189 | BE/API | High | The historical rate is stable across two reads |
| 190 | BE/API | High | A stay converted at the real historical euro rate is positive and consistent |
| 191 | BE/API | Medium | A stay converted at the real historical pound rate is positive and consistent |
| 192 | BE/API | High | The latest endpoint answers with a rates object |
| 193 | BE/API | Medium | The latest euro rate is a positive finite number |
| 194 | BE/API | Medium | The latest response names its date |
| 195 | BE/API | Low | Every latest rate is a positive number |
| 196 | BE/API | Low | The latest response is one unit of the base currency |
| 243 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 244 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 245 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 246 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 247 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 248 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 249 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 250 | BE/API | Medium | Converting <cents> at rate <rate> gives <out> |
| 571 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 572 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 573 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 574 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 575 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 576 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 577 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 578 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 579 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 580 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 581 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 582 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 583 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 584 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 585 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 586 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 587 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 588 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 589 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 590 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 591 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 592 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 593 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 594 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 595 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 596 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 597 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 598 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 599 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 600 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 601 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 602 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 603 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 604 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 605 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 606 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 607 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 608 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 609 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 610 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 611 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 612 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 613 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 614 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 615 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 616 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 617 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 618 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 619 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 620 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 621 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 622 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 623 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 624 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 625 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 626 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 627 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 628 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 629 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 630 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 631 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 632 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 633 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 634 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 635 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 636 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 637 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 638 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 639 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 640 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 641 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 642 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 643 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 644 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 645 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 646 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 647 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 648 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 649 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 650 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 651 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 652 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 653 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 654 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 655 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 656 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 657 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 658 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 659 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 660 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 661 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 662 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 663 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 664 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 665 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 666 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 667 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 668 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 669 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 670 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 671 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 672 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 673 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 674 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 675 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 676 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 677 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 678 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 679 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 680 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 681 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 682 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 683 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 684 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 685 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 686 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 687 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 688 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 689 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 690 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 691 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 692 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 693 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 694 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 695 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 696 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 697 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 698 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 699 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 700 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 701 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 702 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 703 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 704 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 705 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 706 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 707 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 708 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 709 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 710 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 711 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 712 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 713 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 714 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 715 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 716 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 717 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 718 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 719 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
| 720 | BE/API | Medium | A higher rate never converts to less, from <low> to <high> |
