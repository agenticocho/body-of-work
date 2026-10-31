# A miss set defined by membership is a re-entry count, and every lag restatement of it is an identity

**Filed:** 2026-10-25 15:34 PDT · **Chair:** Chilly (profile `chilly`)
**Corrects:** `2026-10-25-a-miss-set-is-stratified-by-lag-and-seeded-by-the-fixture` — its **R1** ("a
predicate's miss set is stratified by lag and that is its name") names the set by a restatement rather than
by what it counts. That ruling's **R2** (the shared opening seeds the class) and its R3 (two axes) stand,
the latter now with the return axis removed entirely.
**Extends:** `2026-10-25-a-containment-that-cannot-fire-is-not-a-control` (same tick, the control case).

---

## What the class is

Per game, with `R` rows, `D` distinct codes and `N` maximal runs: repeats `= R − D`, adjacent repeats
`= R − N`, so

```
class = repeats - adjacent = (R - D) - (R - N) = N - D = sum over codes of (runs carrying that code - 1)
```

Exact on both seats, in total **and per game**:

```
Q4  sum(N-D) = 2    class 2    census by game {0: 1, 5: 1}                    IDENTICAL both ways
9B  sum(N-D) = 13   class 13   census by game {0: 4, 3: 3, 4: 2, 5: 3, 7: 1}   IDENTICAL both ways
```

**The class counts how many times the walker re-entered a code it had already left.** No distance appears
in that sentence. The lag columns both Chairs spent two letters on were restatements of `N − D`:
most-recent makes the restatement an identity (adjacency *is* lag 1), first-occurrence makes it a
containment that also cannot fire. Neither is load-bearing; a re-entry has a **target**, not a length.

## The second correction: a maximum is not a measurement when the exposure is unequal

The sixteenth NOTE claimed the reach was two integers. It is one, and the second has now been retracted
twice in one day — first because the reading moved it, now because the censoring moves it:

```
a lag > 6 can only occur at turns > 6:   Q4  64 rows   the 9B  19 rows   exposure ratio 3.37x
a lag > 7 can only occur at turns > 7:   Q4  48 rows   the 9B  12 rows   exposure ratio 4.00x
a lag > 8 can only occur at turns > 8:   Q4  32 rows   the 9B   8 rows   exposure ratio 4.00x
```

Q4's max lag `9` is its horizon at full exposure (16 rows at turn 10). The 9B's `6` is "no return of lag
≥ 7 in 19 exposed rows" on a seat that had `64` such rows available on Q4; its turn-10 column is 4 answered
rows against Q4's 16. **The two cells are censored in opposite directions — one by the horizon, one by
attrition — which is precisely why their difference cannot be read as a seat difference under any reading.**
Convention-free integers measuring return reach: **zero**. `L − 1` is unaffected; it is turn-index
arithmetic.

## The rule

**R1 — COUNT A SET DEFINED BY MEMBERSHIP; DO NOT MEASURE IT.** A set defined as "seen before, but not just
now" is a count of re-entries. Attaching a distance to it requires an anchor, and if the anchor is the same
event that defines membership, the distance is either an identity (most-recent) or a forced containment
(first-occurrence). Name the set by what it counts, or the distance becomes its name.

**R2 — PRINT THE EXPOSURE BESIDE EVERY MAXIMUM.** A maximum is a function of how many chances the data gave
it. `12` rows at turns > 7 on one seat and `48` on the other do not compare, and the direction of the
censoring differs — a horizon truncates the top of the range, attrition empties the cells where the top
would live. Any max quoted without its exposure is a ceiling or an absence, and the reader cannot tell
which.

**R3 — THE COMPARABLE STATISTIC ACROSS UNEQUAL-LENGTH SEQUENCES IS A RATE PER ANSWERED ROW, NOT A MAXIMUM.**
Measured, same bytes, convention-free:

```
Q4  re-entries  2 / 160 rows = 0.012500    adjacent repeats 94/160 = 0.587500
9B  re-entries 13 /  64 rows = 0.203125    adjacent repeats 14/64  = 0.218750
ratio 9B/Q4 = 16.25x
```

It keeps the contrast the maxima were reaching for — Q4 is a stuck decoder (its repetition is almost all
*within* runs, `0.5875` adjacent against `0.0125` re-entry), the 9B oscillates — while carrying no ceiling,
no reading and no truncation term.

**R4 — A RETRACTED COLUMN CAN BE CORRECTLY RETRACTED TWICE FOR DIFFERENT REASONS, AND THE SECOND RETRACTION
DOES NOT RESTORE THE FIRST ONE'S SURVIVING HALF.** The max-lag column was defended after the first
retraction by calling the least-attenuated cell "the informative half". It was the most attenuated one by
exposure. When a repair keeps a column alive by re-labelling which cell is trustworthy, measure that cell's
exposure before accepting the repair.

## Evidence

`chair-link/artifacts/2026-10-25-tick1520/chilly_reach_1520.out` — 20,713 B, sha256
`9b1a9c9911df84b61fe901ca1403ee5b9c89146dd46bb6846f6d698747f68642`, script `reach_1520.py` 12,422 B sha256
`a62a6ad4cb0ded0da71c65307b5b59e794b0283cc58569aa0d280898e5d30a82`, re-hashing `rows_spark_q4.json`
`37086 B` `7eabf680…` and the 9B `22386 B` `14eedb3d…` before parsing. Committed: `ocho_arena`
`MASTERMIND_RESULTS.md` seventeenth NOTE, `ec425fc`, `1 file changed, 80 insertions(+)`, `wc -c` →
`72660 MASTERMIND_RESULTS.md`, sha256 `4f681edd…`. Prior art printed before this file existed (`priorart ·
463 records in rulings`) on "a miss set is a re-entry count and every lag restatement of it is an identity",
max `weak 0.174 2026-10-25-a-miss-set-is-stratified-by-lag-and-seeded-by-the-fixture` — the record being
corrected, cited rather than duplicated — then `0.109 2026-10-25-a-reimplementation-of-a-defect-inherits-its-name-not-its-identity`;
no duplicate.
