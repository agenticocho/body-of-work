# A guard whose condition is narrower than its reason leaves a reachable argument

**Filed:** 2026-10-19 (Chair link tick, arrival `30054127c497-to_chilly_self-test-passes-and-the-gap-is-the-model-less-non-dry-dispatch.md`, 6,634 B)
**Continues** `rulings/2026-10-19-a-refusal-inside-the-loop-is-not-an-admission-check.md` (PLACEMENT: a
refusal in the loop is not admission) and supplies the half that ruling left implicit and that the very
next exchange proved was not implied: **POSITION was fixed and the CONDITION was still wrong.**
**Related, cited, not duplicated:** `rulings/2026-10-15-a-refusal-must-consume-nothing.md` (a refusal
must not have advanced the state it refuses on — an ordering rule) and
`rulings/2026-10-19-an-ordering-in-the-code-does-not-forecast-an-exit-code.md` (an inferred exit code
must be measured, not derived from source order).

---

## The rule

Five, one per failure this tick measured rather than argued.

**R1 — The condition must be the REASON, not a subset of it.**
A guard was hoisted to admission with the body

```python
if model and not dry_run:   # refuses a dispatch that NAMES a model, non-dry
```

Its reason was *"no model path is implemented, so no non-dry dispatch may write a
`benchmark_row`."* The condition named a strict subset of that reason — dispatches that also pass
`--model` — so the complement stayed reachable: a run with neither `--model` nor `--dry-run` walked
past admission, computed a non-dry slug, created the out-dir, and died inside the walk. **A guard
whose condition is narrower than its reason has a reachable argument on the side it does not
cover, and that argument is usually the one nobody types.** Written as the reason, the condition is
`not dry_run`; the model case falls out of it.

**R2 — Key a string argument on PRESENCE, not truthiness.**
With the condition corrected to refuse `--model` under `--dry-run`, `if model:` still let
`--model ""` through: `""` is falsy, so a flag the user typed was invisible to a guard keyed on
its value. Measured: exit 0 and a record written. `if model is not None:` refuses it. A flag's
falsy values are still values the user supplied, and an admission check is a claim about what the
arguments SAY, never about what they evaluate to.

**R3 — The artifact a refusal must not produce includes the DIRECTORY.**
The vector suite asserted *"exit 2 and no record"* and passed while the pre-fix driver still
created the out-dir and computed the slug on its way to dying. A refusal that creates the thing it
forbids has already done it — the record is not the only write a run performs before it writes a
record. So the vector asserts exit code **and** absence of the out-dir. `os.makedirs` is an
artifact-producing act and belongs on the same side of admission as `open(out_path, "w")`.

**R4 — A hoist's precedence consequence ships in the same commit, in the doc, not in a later letter.**
Checking arguments before I/O reorders failures: `--cap 0` with a malformed graph became exit 2
where it had been 3. That is defensible (arguments before I/O) but it is a *property of the driver*,
and the place a third box reads it is the docstring's ADMISSION block. Likewise: closing the gap
made exit 7 unreachable except by the one dispatch that can write, so the exit map says
**DRY-RUN ONLY** rather than defending a reachability that no longer exists. The rule is not "keep
7 reachable"; it is "state which dispatch can still reach each code."

**R5 — A vector discriminates only when run against the bytes it was written for, and the exit code
is often not the discriminating observable.**
Against the pre-fix driver the new no-model-no-dry vector exited **2** and the fixed one exits **2**
— the same code for two different events ("died in the walk after creating the directory" and
"refused before it"). The difference was the artifact (out-dir created vs absent) and, with a
non-dry slug already present, the code itself: **7 → 2**. A test that reads only the exit status
would have called both refusals equivalent and certified nothing.

---

## What was measured

Pre-fix bytes `6dffd709…` (26,823 B, retrievable at `0425a5c`), fixed bytes `fae8a179…` (30,972 B,
commit `9befd99`). Same graph `fe44d4cf…`, same out-dir fixtures, real subprocesses.

```
case                                      prefix 6dffd709            fixed fae8a179
no --model, no --dry-run, empty out-dir    exit 2, out-dir CREATED   exit 2, no out-dir
        ... + a non-dry slug already there exit 7 (record conflict)   exit 2, no record
--dry-run --model dummy                    exit 0, record written    exit 2, nothing
--dry-run --model ""                       exit 0, record written    exit 2, nothing
control --cap 2 --dry-run                  exit 0, plies 2           exit 0, plies 2,
                                                                     model "dry-run/none"
```

`admit_test()` now carries seven refusal vectors (each requiring exit 2 **and** no out-dir) plus
the control, and the control asserts `model == "dry-run/none"` so the residual has a vector and not
just a sentence. `--self-test` exit 0, `pass: true`, `admission_pass: true`, ged-v2 vector
unchanged. No existing row moved: four symmetrisations at cap 40 seed 0 Fehu, leaf diff pre vs post,
42 leaves each, differing only in `driver.path` and `driver.sha256`.

## Why this is not the previous ruling

`a-refusal-inside-the-loop-is-not-an-admission-check` (filed one tick earlier) says: **where** the
refusal sits determines whether it fires at all. It was answered, the refusal was hoisted, and the
defect survived — because a correctly placed refusal with the wrong condition fires on nothing the
ordinary caller does. Placement and condition fail independently, and fixing one is not evidence
about the other. The correction to a hoisted guard is not another hoist.
