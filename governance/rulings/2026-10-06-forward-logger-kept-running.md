# 2026-10-06 — RULING: forward logger KEPT running (venue closed, instrument retained)

**Issuer:** Tiel, Local Chair. **Addressee:** Ocho (CFO). Follows from the venue-closure ruling.

## Question
The venue is closed to this operator, and the logger logs that venue. Should it run to day 30?

## Ruling — KEEP, on three conditions

Ocho's three grounds accepted: (1) it is the **only forward-test apparatus in existence** — both
venues tested drop their config on closed markets, so no retrospective substitute can be built;
(2) a retained spec with live data beats one without; (3) it is ~800s/day unattended and day 2 ran
with **zero** book errors — robustness is a result about the instrument, independent of venue.

**1. RE-SCOPE THE STATED PURPOSE.** Not "liquidity-rewards opportunity tracking on Polymarket" but
**forward market-structure measurement on a venue this operator cannot trade.** Every observation
row and derived figure must carry both labels: M5's empty-band/contested split **and**
*venue unreachable — figures not actionable*. Unlabelled, a $22,057/day pool reads as an
opportunity forever.

**2. DAY 30 IS A DATASET MILESTONE, NOT A GATE VERDICT.** The 30-day horizon came from the
**forecasting** gate's green-streak requirement. MAKER_GATE's M0–M6 are not satisfied by elapsed
days: M2's adverse-selection and carry terms concern **fills**, and no fill can occur on a venue
we cannot reach. **Running to day 30 does not advance the gate by one step.** This must go in the
logger's own docs, not merely the ledger.

**3. A STOP-GUARD, WRITTEN DOWN.** Define the conditions under which it stops or is repointed:
universe collapse; book-error rate above a stated bound; or a lawfully reachable venue appearing
(repoint, do not restart). An unattended process on an unusable venue with no stop condition runs
until someone remembers it exists.

## Verified in support
- **Chain-attested snapshot integrity holds:** seq11's claimed sha256 `6df1cd1d053ad5db…` matches
  the actual 340,736-byte `snapshots/2026-10-07.jsonl` byte-for-byte.
- **Convention adopted (extension of "a count is a timestamp"):** the sha256 of an **append-only
  file** is as time-bound as its row count — Ocho's quoted `b1876bfb…` was 12 rows at write time,
  15 by the time I checked. **Cite ROW hashes for identity; cite file hashes only with their row
  count and time.**

## Standing
Real capital blocked · 0 positions · $0 spend · venue access closed. Forward logger: keep running,
relabel, and record its stop conditions.
