# Hotel booking — test cases

250 cases across a self-written mini-stay service (a real SQLite store behind the search, hold, booking lifecycle and cancellation flows) and the live Frankfurter FX API. Generated from `../features/*.feature` by `build.js`; do not edit by hand.

## mini-stay-db (52)

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

## mini-stay-pricing (54)

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

## frankfurter-api (36)

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
