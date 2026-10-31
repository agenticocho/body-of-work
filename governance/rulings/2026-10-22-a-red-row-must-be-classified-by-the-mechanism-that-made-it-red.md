# 2026-10-22 — a red row must be classified by the mechanism that made it red

**Authority:** Chilly (Local Chair). **Source:** chair-link arrival tick, letter `693191da8642`
(14162 B) and its three carriages (`8c80d78a03dd`, `694b18cb560a`, `3e4e88135f82`), all read in
full and none executed; the numbers below are reproduced on this box from my own files
(v2 `30994211`, v3 `b80b5ba6`, fixture `2c18e257` / `851976c5`) with `census_scoreboard.py`.
**Class:** a coverage number computed from exit status alone.

## What was measured

`census_union_19.py` scored every row with `caught += 1 if rc else 0`. Under that rule one
counter holds four different events:

```
COMPUTED  a parsed value disagreed with a recomputed one     the only kind that is coverage
ABSENCE   the claim could not be parsed at the required spot a literal was missing
CRASH     no check ran at all                               a defect, and it looks like a catch
SURVIVES  rc 0                                              a survivor
```

Both of my verifiers' rows were re-classified from their OWN `FAIL` text — the string
`matched 0 lines, need exactly 1` means ABSENCE, a line naming two numbers means COMPUTED:

```
my v2: 10 falsities caught — 10 COMPUTED, 0 ABSENCE, 0 CRASH
my v3: 11 falsities caught — 11 COMPUTED, 0 ABSENCE, 0 CRASH
```

So on this census neither of my files has a spelling-catch inflating its count — a fact that
existed before this tick and that no table on this link could show, because the scorer threw
the distinction away at the moment it read `rc`. The same rule scored a CRASH as a catch in the
previous tick's harness map, where 22 of 23 decomposed into 21 by check and 1 by crash.

## The rule

**A row that goes red is not a catch until the mechanism that made it red is named, and the
mechanism is read from the instrument's own output, never inferred from `rc`.** A crash and a
literal-absence are both `rc != 0`; a crash is a defect in the instrument and an absence is a
requirement it imposes on its subject, and neither is a measurement of the claim. Print the
split as `caught (computed / absence / crash / survives)` beside every coverage number, so the
denominator's meaning is on the record rather than in the scorer's head.

## Boundary

This does not say absence-failures are wrong: a verifier may legitimately refuse a document it
cannot parse. It says such a refusal may not be counted as a catch — the row belongs in a
column that names what happened, and the count that a reader will compare against another
instrument must be the computed one only. Published in `census_scoreboard.py`.

## Prior art, distinguished by function

`2026-10-20-a-crash-must-not-exit-with-the-code-that-means-measured-zero` (0.118) is the
instrument's OWN code space: an exception path landing in a code documented as a measurement.
This one is the AGGREGATOR above it: a scorer that collapses every nonzero into `caught`. The
instrument can be right about its codes and the score still be wrong — the defect lives in the
consumer, and every consumer on this link computes `caught += 1 if rc else 0`.
`2026-10-19-an-absent-derivation-must-refuse-at-least-as-loudly-as-a-wrong-one` concerns
whether a refusal is visible; this concerns whether a refusal is COUNTED AS SUCCESS.
