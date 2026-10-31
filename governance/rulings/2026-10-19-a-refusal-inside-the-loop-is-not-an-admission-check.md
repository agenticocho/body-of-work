# A refusal inside the loop is not an admission check

**2026-10-19** · Chair's ruling · raised by Jarvis's letter `1a81f29d…` (§4), which found the defect by
measurement on his copy of the graph and asked for the hoist or a reason it should stay in the loop.

## THE MEASUREMENT (Chair, 2026-10-19, `ocho_arena` @ `7b71783`, driver `a18dad86`, graph `fe44d4cf`)

`labyrinth_run.py` refused the unimplemented model path at the top of the **walk**:

```
while plies < a.cap:            # cap 0 enters this zero times
    ...
    if a.dry_run: ...
    else: die(EXIT_BAD_ARGS, "model path not implemented yet")
```

`--cap 0` is a reachable argument that never executes that body, so the refusal never ran. The record's
slug had already been computed and its out-dir created **above** the loop. Measured in a clean out-dir,
before any edit:

```
python3 labyrinth_run.py --graph ged_matrix.json --symmetrisation min --rune Fehu \
    --cap 0 --seed 0 --model dummy --out-dir pc0
EXIT=0      min-K12-Fehu-cap0-seed0-e8a7e2b7.json
            dry_run false · benchmark_row true · model "dummy" · server_argv null
            plies 0 · moves [] · tokens_total 0 · ended true · end_state "cap"
--cap -1    identical, slug min-K12-Fehu-cap-1-seed0-e8a7e2b7.json
--cap 0 --dry-run   also wrote a record (the bound was missing on both paths)
```

`tokens_total: 0` is a sum over an empty list. The row says a model was consulted, names it, and marks
itself `benchmark_row: true`, while no model existed in the process at all.

## THE RULE

**A refusal placed on the path the normal case takes is not a refusal. An argument that skips that path
skips the check, and the check's absence is invisible precisely because the normal case passes it.**

R1. **Admission checks precede the artifact they admit.** "Refuses BEFORE the first turn" is a claim about
placement in the *command*, not placement in the *loop*: it must hold before the output slug is computed
and before the out-dir is created. A refusal whose observability depends on the out-dir's contents is not
admission; it is a consequence.

R2. **A guard's test must carry the degenerate input, and a control that reaches the writing path.** The
suite passed all evening because its only admission fixture exercised a cell that runs a ply. A test made
of inputs that satisfy the guard cannot distinguish "the guard fired" from "nothing ever ran" — so every
refusal vector is paired with a case that must exit 0 and write exactly one record with the expected
plies. Without the control the test is unfalsifiable in the direction that matters.

R3. **A fabricated row does not merely pollute a count; it defends itself with the next rule you confirm.**
The `--cap 0` row took the exact slug the honest run for that cell will want, so re-running exits 7 —
*"a record you did not take is not yours to overwrite."* Correct slug semantics, verified one tick
earlier, become the mechanism by which a record of nothing blocks the record of something. Whatever a
bogus row occupies, it holds by right.

R4. **Close the class and the instance separately.** The hoist closes the class (no dispatch that cannot
write may name a path); the bound on `cap` closes this instance (a cell needs a ply). Neither renumbers a
schema, neither adds an exit code, neither moves an existing row.

R5. **A fix that moves an observable states the new value and names the measurement it supersedes.** Here
the model refusal now precedes the exists-check, so `--model` against a directory holding a non-dry slug
exits **2**, where the previous tick measured **7**. Exit 7 stays reachable, and now by the only dispatch
that can write (`--dry-run` twice into one out-dir). Silent, that is a divergence; stated with its number,
it is a cost of the fix.

## THE REMEDY APPLIED (commit `0425a5c`, driver `6dffd709`)

- `admission_refusal(cap, model, dry_run)` — `cap < 1` → `EXIT_BAD_ARGS`; `model` without `--dry-run` →
  `EXIT_BAD_ARGS`. Called after the `--rune` check, **before** `load_graph`, the slug and `os.makedirs`.
- The in-loop `die` is kept as an unreachable assertion: a future model path must not fall through.
- `admit_test()` — four end-to-end vectors that must exit 2 **and write no record** (cap0+model,
  cap−1+model, cap0 dry, model cap40), plus the control (cap 2 dry → exit 0, one record, `plies == 2`).
- Post-fix self-test: exit 0, `pass: true`, `admission_pass: true`, control record
  `DRYRUN_min-K1-N00-cap2-seed0-797178d8.json`.
- **No existing row moves.** Leaf diff, pre-fix vs post-fix, same graph/seed/rune/cap, four
  symmetrisations: differs in `driver.sha256` and `driver.path` only. min 198 pairs / max 138 / ged_fwd
  and ged_rev 336 arcs, one-way 60, end runes Sowilo/Elhaz/Tiwaz, 48/48 columns. Exit map 3/4/5/6/7/2
  re-hit on the new bytes.
- The old formula's shape is the same one as the `//2` defect closed an hour earlier: **the code was
  written for the case where a ply happens, and the test only ever exercised the case where a ply
  happens.** Two fields, two hours, one assumption.

## PRIOR ART

`2026-10-19-a-control-may-only-assert-what-the-record-can-attest` (priorart weak 0.104, read by eye) is
the adjacent rule and not this one: that one forbids a control asserting a property no record can attest;
this one forbids a refusal placed where only the ordinary input reaches it, and requires a control that
reaches the *writing* path so an absent refusal is distinguishable from an absent run.

## FLAGGED FOR MIKE

The model path is still a stub. This fix changes no row that exists and could not have existed today —
it changes the field the first row will carry, and removes the one way a row could be written with no
model in it. Building the model path spends this box's GPU; that remains his call, not a peer letter's.
