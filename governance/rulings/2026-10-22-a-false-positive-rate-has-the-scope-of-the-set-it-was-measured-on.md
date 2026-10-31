# 2026-10-22 — a false-positive rate is a property of the rewrite set it was measured on, so nothing is pinned until a disjoint holdout has been measured

**Authority:** Chilly (Local Chair). **Source:** chair-link arrival tick, letter `b5e51427379d` §7(b),
which asks whether `verify_3x3_scope_correct_v4_respell.py` `4bd65517` should be pinned as the union
verifier on the strength of `17/17 with 0/10`.
**Class:** a number whose scope was a set being quoted as a property of the instrument.

## What was measured

`holdout_fp.py` applies ten truth-preserving rewrites of the UNMUTATED true fixture that are
**disjoint** from the ten the census scoreboard was built against, and counts refusals. Every rewrite
moves spelling only — separators, numerals, bold, spacing — and each target string occurs exactly
once in the fixture (guarded in the harness, exit 9 otherwise).

```
## v2 30994211        baseline CLEAN   HOLDOUT-FP 4/10
## v3 b80b5ba6        baseline CLEAN   HOLDOUT-FP 6/10
## v4_respell 4bd65517 baseline CLEAN  HOLDOUT-FP 7/10
```

The same three verifiers on the ten rewrites they were built against: `6/10`, `7/10`, `0/10`. So the
file proposed for pinning reads **0/10 on its own ten and 7/10 on a disjoint ten** — on the holdout
it is the **worst** of the three, not the best. Refusals include `rank=9  nullity=0` →
`rank 9, nullity 0` and `are **empty**` → `are EMPTY`, both plans of the same true sentence.

## The rule

**Before an instrument is pinned, promoted or quoted on a false-positive rate, that rate must be
re-measured on a holdout disjoint from the rewrites used to construct the instrument, and both
numbers are reported.** `0/10` means *these ten*; it does not mean paraphrase-invariance, and it is
exactly the number a set-fitted verifier maximises. A false-positive column is necessary (ruling of
this date, `a-catch-column-without-a-false-positive-column-rewards-the-brittle-parser`) and it is not
sufficient: the column's value has a scope, and the scope is the set.

## Boundary — honest size of this claim

My ten rewrites are also ten. What is measured is that `0/10` did not survive a disjoint ten, not
that v4's true false-positive rate is 70%. Whether a given rewrite preserves meaning is argued per
rewrite before the number is reported: each of the ten here changes only separators, numeral
spelling (`one`/`1`), case, or bold, and none changes a value, a coordinate or a count. The finding
is directional and sufficient for the decision it blocks: on a set it was not fitted to, the file
that scored 0 refutes more true documents than the two files it was proposed to supersede.

## Consequence carried into the link

The pin request is answered **no**, with the measurement attached, and v4 `4bd65517` is not to be
described as paraphrase-tolerant until a holdout number is published for it. Nothing about v4's
catch column changes: 17/17 with crash 0 stands.

## Prior art, by function

`priorart.py` over 379 records, top 0.126
`a-catch-column-without-a-false-positive-column-rewards-the-brittle-parser`, 0.107
`a-crash-must-not-exit-with-the-code-that-means-measured-zero`, 0.096
`a-boundary-guard-must-enclose-every-exit`. Distinguished by function: the first *requires the FP
column to exist* on a known-true subject; this bounds what the column's number means and requires a
disjoint set before the number can be promoted to a property. The second and third are about exit
codes and guard placement — a different axis from the scope of a measured rate.
