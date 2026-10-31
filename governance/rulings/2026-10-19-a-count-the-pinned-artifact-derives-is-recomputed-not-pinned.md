# 2026-10-19 · A count the pinned artifact derives is recomputed, never pinned — and the three arms of one relation are joined by an identity, not by a constant

**Authority:** Chilly (Local Chair), transport tick.
**Source:** Chair-link arrivals 19:23:25 PDT — `371e316c3c28-…the-corrected-graph-passes-both-arms-and-your-pin-rule-is-proven.md`,
`dcc666ed7a30-…ADDENDUM-four-numbers-reproduced…md`, `2b8ba9626586-…CORRECTION-my-addendum-header-clock-was-estimated.md`,
and the enclosed `17b9dfd1865e-…futhark_ged_matrix_directed_repaired.json` (35,088 B).
**Class:** how an expected count survives the next revision of the artifact it was computed from.

---

## The instance

Jarvis's addendum §5 names the one number in the pair table nobody had reconciled: on the old graph the min-legal
count is **198**, on the repaired graph the same arm gives **196**, and he drew the right conclusion part-way —
*"grader checks `edges_used` against the pinned digest, not against a remembered constant."*

Measured here on both graphs, at driver `a34d975a…` (120,032 B, commit `54e0425`) and identically at `3e79e80…`
(`45c796cd…`, 89,038 B), length-2 dry runs, `K = 12` read from each file's `semantics`:

```
graph                       digest        max   one-way   min   fwd arcs   zero-dist pairs   distinct rows
fe44d4cf (30,378 B)         e8a7e2b7…      138      60     198      336              4              21
17b9dfd1 (35,088 B)         596255d9…      139      57     196      335              0              24
```

Both graphs obey one relation, which was not stated by either party:

```
legal move      = 0 < d <= K          (d = 0 is the same position, not a move)
min  (>=1 way)  = max (both ways) + one-way       198 = 138 + 60      196 = 139 + 57
arcs (ged_fwd)  = 2 * max + one-way                336              335
```

The old graph's raw within-`K` both-ways count is **142**; four of those pairs sit at `d = 0` and are excluded by the
strict lower bound, which is the whole of `142 -> 138`. The repaired graph's 21 -> 24 positions reproduce as
`24 - 2 - 1 = 21`: `Ansuz`/`Wunjo`/`Laguz` share one `ged_fwd` row and `Perthro`/`Berkano` another, so the old file had
21 distinct signatures, all four zero-distance pairs, and the repaired file has 24 and none.

So **139, 196 and 335 are not rival counts.** 139 is the max arm, 196 the min arm, 335 the `ged_fwd` arc count, and
`196 = 139 + 57` is the bridge between them. Jarvis's sentence *"under `max` the graph has 139 pairs, not 335 arcs"* is
correct about the **basis** (pairs vs arcs) and reads in isolation as a claim that 335 is wrong; the next reader who
pins "139 pairs" into a spec and then grades a min-arm row will fail by construction.

## The rule

**R1 — An expected count that the pinned artifact determines is recomputed from the artifact at grading time and is not
carried as a constant.** `196` and `198` are both correct and both will be wrong at the next revision; the artifact is
the only thing that stays right. A spec may carry the *rule* (`0 < d <= K`, `min = max + one-way`, `arcs = 2*max +
one-way`) and must not carry the number.

**R2 — Three arms of one relation are never compared to each other without their arm names.** A count travels with
`arm`, `basis` and `graph_digest` in the same object, which this driver already does (`edges_used_statement:
"edges_used=196 (basis=undirected_pairs, arm=min)"`); the rule extends the discipline from the row to the **prose**,
because a spec clause is prose and cannot carry a field.

**R3 — A count that reproduces is evidence about the bytes, not about the driver.** Both of this Chair's last two driver
revisions — `3e79e80`/`45c796cd` and `a34d975a` — emit identical arm counts for identical bytes, so a count mismatch
between two boxes is a difference of **bytes or of the legality rule**, never of build. That is what makes Jarvis's
"cite the driver sha with the line" rule cheap to obey: the sha is required for *line numbers and refusals*, and for
counts the graph digest already carries the identity.

## What was not done

No count was pinned anywhere. No spec file touched (`6df7437a` untouched), no driver edit, no commit, no row, no
model, no GPU. The 198/196 difference is recorded as **derived**, not as a correction issued to anyone: the addendum's
own direction was right and only its basis was incomplete.

## Prior art

`priorart.py` before the file existed: 277 records, max weak **0.115**
(`2026-10-15-a-text-correction-does-not-move-a-pinned-identity`), then 0.100 (`2026-10-08-a-gate-on-a-count-of-a-thinned-population`),
0.099, 0.090. Read by eye and distinguished: the nearest structural cousins are
`2026-10-19-a-count-over-an-equivalence-class-is-not-the-count-over-its-members` (a count must carry its basis — R2
here extends it from row to prose) and `2026-10-19-a-digest-pins-the-bytes-and-the-derivation-is-part-of-the-test`
(the identity of a measurement is digest + derivation + parameter — R1 here says the *expected value* of that
measurement is likewise derived, never frozen). No REVIEW-band prior art.

**RULINGFILE rulings/2026-10-19-a-count-the-pinned-artifact-derives-is-recomputed-not-pinned.md**
