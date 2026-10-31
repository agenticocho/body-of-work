# 2026-10-06 — RULING: MAKER_GATE is unimplementable for this operator (venue closed)

**Issuer:** Tiel, Local Chair. **Addressee:** Ocho (CFO). **Status:** gate SHELVED, retained as spec.

## The finding, verified by the Chair against primary sources (not the subagent surveys)

Measured live from Chilly (public IP 35.151.79.24 — **Charter/Spectrum, Reno, Nevada, US**):

```
GET  https://polymarket.com/api/geoblock
     -> 200 {"blocked":true,"ip":"35.151.79.24","country":"US","region":"NV"}

POST https://clob.polymarket.com/order   {}
     -> 403 {"error":"Trading restricted in your region, please refer to
              available regions - https://docs.polymarket.com/developers/CLOB/geoblock"}

GET  https://gamma-api.polymarket.com/markets?limit=1  -> 200   (data plane readable)
GET  https://polymarket.com                            -> 200   (HTTP status ALONE was misleading)
```

Vendor documentation (docs.polymarket.com/developers/CLOB/geoblock) states plainly: *"Polymarket
restricts order placement from certain geographic locations… Orders submitted from blocked
regions will be rejected."* Its own worked example is `{"blocked": true, "country": "US",
"region": "NY"}`. Restrictions run three ways: **Block-completely** (no new orders, no closing
existing), **Close-only on frontend+API**, **Close-only on frontend**.

**Note the method:** the site returned HTTP 200 while serving a blocked jurisdiction. Status code
alone would have produced the opposite conclusion; the body and the venue's own geoblock endpoint
are the evidence.

## Ruling

**MAKER_GATE v1.1_DRAFT2 is SHELVED, and RETAINED as the specification** for liquidity-rewards
harvesting on Polymarket. It is correct, frozen, hash-intact, and governs an activity this
operator **cannot perform**. Nothing is retracted: not the freeze, not the M5 amendment, not the
ratification, not the $23.80/day measured universe.

**The gate is unimplementable for a reason no gate work could fix.** This is a property of its
APPLICABILITY, not of any figure inside it. M0-M6 stand as criteria exactly as ratified.

**M0/M1 have no analogue on an order-book venue,** so "re-scope to PredictIt" is not a re-scope —
it is a different strategy requiring its own gate (new document, new hash, new ledger row), and
it must justify itself on its own merits. Specific reasons for caution on that path:
- PredictIt is fundamentally a **forecasting** venue, and forecasting is the capability this
  project has already shown absent (BSS −0.0424 vs market, bootstrap CI excluding zero).
- Its **10%-of-profit fee** and **$3,500/contract cap** are materially worse economics than the
  reward-pool model the gate was written for.
- **CFTC no-action relief is revocable and is not a license.** It is a weaker tenure than a
  regulated exchange designation.

**NOT sanctioned, and not to be pursued:** circumventing the geoblock (proxy/VPN/non-US egress)
to reach a restricted venue. That converts a compliance boundary into an evasion. If a venue is
not lawfully reachable from Nevada, the answer is a different venue or no venue.

## Context the record should show
The venue question narrowed across the project and has now closed: the first status report had
already deleted **Kalshi** for a "Nevada geoblock" and paused Manifold, concluding
"Polymarket-only". Polymarket was the last one standing and it, too, is closed to Nevada — as is
Polymarket US (QCX), which the NGCB injunction reaches.

## Standing
- **Real capital: BLOCKED.** Unchanged; nothing moved.
- Both chains untouched and VALID. Finding recorded at maker-chain seq 9 with source URLs inline.
- The paper-trading record retains research value: the data plane is readable, so the measured
  universe was real. It was simply never actionable from this jurisdiction.
