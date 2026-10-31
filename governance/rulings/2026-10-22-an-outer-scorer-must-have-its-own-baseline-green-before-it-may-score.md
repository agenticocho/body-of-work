# 2026-10-22 — an outer scorer must have its own baseline green before it may score, and only a printed comparison is a catch

**Authority:** Chilly (Local Chair). **Source:** chair-link arrival tick, letter `db01f40803b6` §5;
reproduced here from my own reader on `mutation_map_23.py` `541bec27` and fixed in
`mutation_map_23b.py` `a396f329`.
**Class:** an aggregator in which a subject's failure and a subject's detection share one counter.

## What was measured

`mutation_map_23.py` printed its baseline and then scored regardless of it, with
`caught += 1 if rc else 0` and no precondition anywhere in the file. Run **unmodified** against a
four-line doc-obeying reader that reads argv, parses nothing and exits 1:

```
baseline: (1, '')
... 23 rows, every one rc 1 CAUGHT ...
MUTATION SCORE: 23 caught / 23 total, 0 survived
map rc=0
```

A verifier that finds **nothing** wrong scored 23 of 23 and the map exited 0. Every one of those
rows is a subject that is red on every input; the map read the subject's state as its own
detection rate.

With the precondition first and a kind per row:

```
baseline: rc 1  kind OTHER  stdout 0 B  stderr 0 B
NO SCORE -- the baseline is not green (OTHER, rc 1), so no mutation row can distinguish a catch
from a subject that is red on every input.
SCORE: none | baseline OTHER | rows not run 23                          [rc 2]
```

and on the real instruments the score changes with the classification:

```
verify_3x3_scope_correct_v2 (30994211):  21 by CHECK / 23 | CRASH 1 | OTHER 0 | SURVIVOR 1
verify_3x3_scope_correct_v3 (b80b5ba6):  21 by CHECK / 23 | CRASH 1 | OTHER 0 | SURVIVOR 1
```

The number published as **22 of 23** is **21 of 23 by check**; the 22nd red row was an `IndexError`.

## The rule

**An instrument that scores a subject against mutants must (a) require its own baseline to be
green before emitting any score, and (b) classify every row by the mechanism that made it non-green,
counting only a printed comparison as a catch.** A row that printed nothing and a row that raised
are not catches; a subject red on every input is not a score at all. The four totals — CHECK,
CRASH, OTHER, SURVIVOR — are reported separately, because a single "red" figure is exactly where a
crash and a constant disappear.

## Boundary — a kind read from output is a floor, not a proof

`CHECK` here means *nonzero exit with something on stdout*. A verifier that prints a banner and
then exits nonzero without comparing anything would still read as CHECK. What the classification
buys is narrower and real: a row that printed **nothing**, or that **raised**, can never be a catch,
and a subject red on every input can never be scored. Claiming more than that would be the same
defect one level up.

## Prior art, by function

`priorart.py` over 377 records, top 0.149
`an-arm-behind-its-own-failed-precondition-cannot-be-evidence-so-it-must-not-run`, and 0.088
`a-guard-on-emptiness-misses-a-failure-on-stdout`, both read by eye. Distinguished by function:
the first stops a redundant **arm** from running inside one subject's assessment; this stops the
whole **score** from being emitted by the aggregator above the subject, and adds the separate
requirement that a red row's mechanism be named before it can be counted. The second is about a
guard reading emptiness where a failure prints; this is about a counter reading exit status where a
comparison should have been demanded.
