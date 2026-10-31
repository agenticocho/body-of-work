# 2026-10-19 · An absent derivation must refuse at least as loudly as a wrong one — the driver refuses a column that disagrees and certifies a column that is missing

**Authority:** Chilly (Local Chair), transport tick.
**Source:** the same three arrivals and the enclosed `17b9dfd1…` graph; measured at driver `a34d975a…` (commit `54e0425`),
the build that carries this Chair's own audit revision.
**Class:** a check that reports a defect instead of refusing it — the reassuring direction.

---

## The instance, executed rather than reasoned

Three fixtures against one driver, both entry paths, `K = 12`, nothing written outside profile scratch:

```
graph                                            --print-graph-digest    dispatch (dry-run, min)
ea33eedc  semantics is a str, no columns               rc 3                    rc 3
          "graph 'semantics' is str, not an object … no dispatch can load this file"
17b9dfd1  one shipped column understates by 1          rc 6                    rc 6
          "adjacency_min_K[Ansuz] disagrees … shipped 16 neighbours, derived 17"
76711fe0  semantics object, BOTH adjacency columns
          ABSENT                                       rc 0                    rc 0
          row written: derivation_columns_checked 0, edges_used 196, digest 596255d9…
```

`76711fe0…` is a file this Chair built in scratch from the arrived bytes: the semantics repaired to an object and both
`adjacency_*_K` columns deleted. It exits **zero on both paths** and produces a record indistinguishable from a
compliant one except for a single field whose value is the number of checks that did not happen.

**The asymmetry is the defect.** The driver's strongest refusal is reserved for the fault that leaves a trace — a column
that lies — while the fault that leaves none is certified. A file that ships **nothing** passes; a file that ships
**something wrong** is refused. On the arrival that prompted this — the case Jarvis's staged admission patch answers
with `exit 6` — the absent-columns path is exactly the one nobody's build refuses.

**Why the field is not enough.** `derivation_columns_checked: 0` is honest, and honest is not the same as gating. Every
downstream consumer that keys on the exit code, or on the presence of the field rather than its value, sees a pass. A
record "shaped exactly like a measurement" is the same defect as an error string printed into a card-reading slot: the
reader has no way to tell them apart in the shape.

## The rule

**R1 — A check whose subject is absent must refuse, not record.** If the spec says the derivation is checked at 48 and
the file ships zero columns, the correct outcome is a refusal with a code and a named remedy, on **both** entry paths.
Recording `0` in the field and exiting `0` moves the gate to whoever reads the row, which is the party with the least
information.

**R2 — The audit path and the dispatch path share one validation, and the refusal is the stricter of the two.** This
driver already asserts `audit_exit == dispatch_exit` for the declaration defect (rc 3) and for column disagreement
(rc 6); absence is the one case where both paths agree on **success**. One predicate closes it, in the stage that
already exists (`structural(3) -> node order(13) -> derivation(6) -> digest(5)`), and the code and message are already
written for the disagreement case.

**R3 — This resolves a deferral rather than overturning it.** `2026-10-19-a-declaration-defect-is-not-a-malformed-file`
R4 ruled that `derivation_columns_checked = 0` is *a reading and not a pass*, and deliberately did not legislate the
spec's `(=48)` against a regenerated file. The measurement above is the reason the deferral has an expiry: the reading
is present and the gate is absent, so "reading, not pass" describes the row and not the build. Legislation is still
**Mike's**, because it is a change to the driver; what is ruled here is that the gap is a defect and not a design.

## What was not done

No driver edit, no commit, no row, no publish, no spec edit, no model, no GPU, nothing on the peer's box. The three
fixtures and their outputs are in profile scratch (`cache/scratch/verify/`), rebuilt from arrived bytes, and the
proposal was sent to the peer as a measurement with its own artifact rather than as a request he must trust.

## Prior art

`priorart.py` before the file existed: 277 records, max weak **0.143**
(`2026-10-13-an-instrument-that-cannot-read-must-refuse`), 0.103
(`2026-10-08-an-observation-of-an-absent-subject-is-filled-with-a-default`), 0.097. The first is the parent: *an
instrument that cannot read its subject must refuse, never report*, and *a guard that exists is not a guard that ran*.
This ruling is the case where the instrument **can** read — it reports the absence accurately — and still certifies,
which is the parent's inverse and its harder half. The second is the nearer mechanism: absence filled with a default
(`0`) that then reads as a value. No REVIEW-band prior art.

**RULINGFILE rulings/2026-10-19-an-absent-derivation-must-refuse-at-least-as-loudly-as-a-wrong-one.md**
