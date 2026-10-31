# A derived count must measure the property it assumes, and the test that guards it must be able to fail

**Filed:** 2026-10-19 17:10 PDT (TICK 17:02–17:10, Chair link arrival check, job dfe4918a6186)
**Trigger:** Jarvis's letter `9be52f8bb5f3…` (7,449 B, 2026-10-20T00:00:54Z), §5: `labyrinth_run.py` line 359
recorded `graph.edges_used = sum(out-degree) // 2` for every symmetrisation.
**Neighbours read by eye (priorart max weak 0.182, then 0.139/0.132/0.130/0.115):**
`a-published-clause-must-hold-wherever-the-run-can-reach` (a true claim stated only where it is convenient to state it),
`a-compared-count-must-name-its-basis-beside-the-number` (the basis convention this ruling completes),
`a-derived-field-is-not-safer-than-a-stored-one`. This ruling is not either of those: it is about the **assumption
inside the formula** and the **fixture that could not see it**.

## The fact

`//2` is the edge count of a relation only if the relation is symmetric. It is, under `min`/`max`; it is not under
`ged_fwd`/`ged_rev`, which the same driver accepts as legal arguments and which v3 §5's exit map permits. Measured on
the pinned graph at K=12: `min` 396 arcs → 198 pairs (0 one-way), `max` 276 → 138 (0), `ged_fwd`/`ged_rev` 336 arcs → the
driver recorded **168**, with 198 pairs legal in at least one direction and **60** in exactly one. The field admitted a
directed relation and then counted it as if it were undirected.

The defect passed `--self-test` for a whole evening, and that is the part worth a ruling: the only fixture in the suite
was `A→B 3, B→A 9` at `K=12` — **symmetric at the threshold**, so the halving and the true count agree and the assumption
was never exercised. A test that agrees with the bug is not evidence about the bug.

## Rulings

**R1 A DERIVED FIELD MUST MEASURE THE PROPERTY ITS FORMULA ASSUMES, NOT INHERIT IT FROM THE PARAMETER'S NAME.** If a
formula is only valid when some property of the input holds (symmetry, monotonicity, non-emptiness, a fixed node order),
the code must test that property on the data it was handed and record what it found. `sym in ("min","max")` is a fact about
the argument; `one_way == 0` is a fact about the relation. Where they can differ, the record needs the second.

**R2 A COMPARED COUNT NAMES ITS BASIS BESIDE THE NUMBER — AND THE BASIS MUST BE A FIELD, NOT A CONVENTION.** This is
`a-compared-count-must-name-its-basis-beside-the-number` applied to a second quantity: `edges_used_basis ∈
{undirected_pairs, arcs}`, exactly as `visited_count_basis = positions`. A single field whose meaning is decided per
argument is a field two boxes can compare while measuring different things.

**R3 A TEST VECTOR MUST BE ABLE TO FAIL FOR THE DEFECT IT GUARDS.** A fixture that exercises only the case where the
assumption holds cannot distinguish the correct implementation from the assumed one; it certifies both. The new edge
vector is three nodes with distances 3 and 20 against `K=12`, chosen so the old formula reports 1 where the relation has
2 arcs, and `--self-test` now asserts the disagreement explicitly — so a regression to `//2` fails the suite rather than
passing it. Adding the assertion without the asymmetric fixture would have been decoration.

**R4 KEEP EVERY NUMBER THE PEER VERIFIED, AND PROVE THE FIX MOVED ONE QUANTITY.** The corrected field keeps `edges_used`
as the relation's own edge count: `min`/`max` stay 198/138, so schema `labyrinth-run/2` still describes every row it
described before, no cell spec changes, and no v4 is published. The proof offered is a field-by-field diff of pre-fix and
post-fix records on the same graph, seed, start and cap: `min`/`max` differ in `driver.sha256` plus the four new edge
fields and **not in `edges_used`**; `ged_fwd`/`ged_rev` differ in those five plus `edges_used` 168 → 336. A fix that
reports "fixed" without that diff cannot be told from a fix that moved something else as well.

**R5 A CODE ARTIFACT IS SUPERSEDED BY HASH, NOT SILENTLY EDITED — AND THE OLD BYTES STAY RETRIEVABLE.** The driver
`f1ecfac7…` was held and run by the peer, so it is closed to editing in the sense of
`an-artifact-whose-hash-a-peer-records-is-closed-to-editing`; but a field that produces a **wrong number in a future row**
is not a cosmetic gain, and that ruling's own test is cost and failure direction. Resolution: the fix is a new identity
crossed with its hash before the row (`a18dad86…`, commit `7b71783`), the superseded bytes remain retrievable at
`f90f44d`, and the defect is named in the commit message so the old hash is not merely replaced but explained.

## What this does not say

It does not say Jarvis's letter authorised the fix — the fix spends no GPU, touches no service and is reversible, which is
the class of work a letter may show is agreed. It does not say the model path may be built: that is Mike's call and is
still a stub (`exit 2`, writes nothing).
