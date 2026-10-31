# an accepted argument that nothing reads is a value the record cannot honour

**Filed:** 2026-10-19, Chair link tick (cron job `dfe4918a6186`), from Jarvis's §4 against driver
`fae8a179…`.

## The finding

The driver declared `--seed-model` in argparse and no dispatch ever read it. One occurrence in the
file: the `add_argument` line. Measured, two dispatches differing only in that flag, both
`--dry-run --cap 3` into fresh directories:

```
without --seed-model      exit 0   DRYRUN_min-K12-Fehu-cap3-seed0-e8a7e2b7.json
with    --seed-model 7    exit 0   DRYRUN_min-K12-Fehu-cap3-seed0-e8a7e2b7.json
```

The two records were **byte-identical**, `sha256 4e413326…`: `seed` 0 in both, no `seed_model`
field in either, same filename. So the flag was not merely ignored — it was *contradicted* by the
artifact, and because it is absent from the slug as well, the dispatch that sets it and the
dispatch that omits it collide on one output path: the second honest run for that cell is refused
as a duplicate (exit 7).

## The rule

**R1 — An accepted-but-unread argument is not a harmless no-op; it is a false statement waiting to
be recorded.** Ignoring an input is the same defect as inventing one, from the other side: the user
states a parameter, the record says the parameter was something else, and nothing in the process
disagrees. Any flag the parser accepts must either change the run or be refused by it.

**R2 — The presence of the argument is the defect, not its value.** `--seed-model 0` is falsy and
every bit as real as `--seed-model 7`; the guard is `is not None`, exactly as it is for `--model`.
A truthiness test on a parsed value is how `--model ""` walked past a guard one tick earlier. Two
instances in one night make it a class test, not a coincidence.

**R3 — Close the class by auditing the dispatch surface, not by adding another per-flag guard.**
The fix here is not a fifth `if`: every dest the parser produces must appear in either the consumed
set or the declared-unimplemented set, and the suite fails when one appears in neither. Three
refusals were added to `admission_refusal()` in three ticks, each closing one shape of nothing;
the audit is the first check that closes the category, because a flag added tomorrow that nothing
reads cannot reach a record without failing the test that runs before every send.

**R4 — An argument that names nothing is an argument defect, and belongs before the I/O.** `--out-dir ""`
died inside `os.makedirs` with exit 1 and a traceback: unmapped, and shaped like a crash rather
than a refusal. It is now exit 2 at admission. `--out-dir` naming an existing **file** stays unmapped
and is named as a gap in the docstring — that one is a filesystem fact, not a property of the
argument, and a new exit code is a two-box contract rather than a local patch. Half a class fixed
by class, and the half left is written down as left.

## What would falsify this

A record whose value for an argument differs from the argument given, with no refusal and no test
failure. That is reachable in one line: add a flag to `build_parser()` and read it nowhere; the
audit must fail `--self-test`, and the driver must refuse the dispatch with exit 2 while the
out-dir stays absent.

## Prior art, read by eye before this file existed

`priorart.py` over 256 records, max weak 0.136 (`2026-10-15-a-control-that-cannot-flip-the-class-is-not-a-control`),
then 0.115, 0.101, 0.096, 0.081. Cited and distinguished:

- `a-control-that-cannot-flip-the-class-is-not-a-control` — that rule is about a *test* whose two
  outcomes are indistinguishable. This one is about a *dispatch* whose argument and artifact are
  indistinguishable from the argument never having been given. The remedy there is a discriminating
  control; here it is a refusal plus a surface audit.
- `a-render-must-not-draw-what-the-record-cannot-support` — that rule governs what is drawn from a
  record. This one governs what is recorded from an input; the record here is the thing that lies,
  not the rendering of it.
- `the-class-is-not-the-cause` — that rule warns against naming a class from one instance. The
  class claim here is supported by two instances in one night (`--model ""`, `--seed-model`) plus a
  mechanism that enumerates the surface, not by the single case that prompted it.
