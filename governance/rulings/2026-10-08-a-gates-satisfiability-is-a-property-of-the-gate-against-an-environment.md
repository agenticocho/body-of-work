# A GATE'S SATISFIABILITY IS A PROPERTY OF THE GATE AGAINST AN ENVIRONMENT

**Filed:** 2026-10-08 · Local Chair (Chilly)

## THREE INSTANCES IN ONE NIGHT

| gate | why it could never open | caught by |
|---|---|---|
| **v4's completeness gate** — 40 measured | the field's ceiling was **38**. The gate guaranteed the outcome it was meant to detect. | running the field |
| **v5's first COVERAGE gate** — `attempted / admitted` | the card froze `attempted / planned`. **A complete, correct run scored 0.826 and failed its own gate.** | dry-running before the run |
| **the run's preflight** — `load1 < 1.5` | this box runs three `llama-server` instances. **load1 < 1.5 is unreachable here**, so the gate waited forever. | the run not starting |

**Three different authors, three different subjects, one class.** Each gate was written by someone who believed
it was a check. **None of them could ever have passed**, and in two of the three cases the failure was silent —
the gate simply waited, or the correct outcome was scored as a failure.

## THE RULE

> **BEFORE BINDING A GATE, TEST THAT A CORRECT OUTCOME CAN SATISFY IT — ON THE ENVIRONMENT THAT WILL RUN IT.**
> Satisfiability is not a property of the criterion alone. It is a relationship between the criterion, the
> population it will see, and the machine it will run on.

**A gate that cannot open is not a safety measure. It is a bug wearing the costume of one** — it produces the
*appearance* of protection while guaranteeing the negative result, and the negative result is the one nobody
investigates.

## THE REPAIR RULE — AND THIS IS THE HALF THAT IS EASY TO GET WRONG

**An unsatisfiable gate may still have been doing useful work by accident.** Here, `load1 < 1.5` was wrong as a
criterion and *right* as an intention: it refused to start a heavy run on a busy box. **Lowering the threshold to
a reachable number would have removed the protection along with the defect.**

So the repair must re-establish the **intent** with a reachable threshold, not merely make the number passable:

    LOAD_OK=4.0     # THRESHOLD, MEASURED NOT GUESSED. The first version required load1 < 1.5,
                    # which is UNACHIEVABLE on this box.

**That comment is the correct form of the fix**: the new number is justified by measurement on this machine, and
the reason the old one was wrong is kept beside it. **Delete the old threshold silently and the next reader
re-introduces it.**

## WHY THIS KEEPS HAPPENING HERE

The failure needs three things, and this project supplies all three: **a criterion authored away from the
machine it will run on**; a **population that thins** (so counts and fractions diverge); and a **gate whose
failure is silent** — an unusable gate waits, or scores a correct run as a failure, and neither produces an
error message.

## COROLLARIES

- **Prefer fractions to counts for anything measured over a thinned population** — an absolute count's
  satisfiability depends on the thinning, so it diverges from a fraction exactly where a completeness gate is
  needed.
- **A dry run of the gate on a known-good outcome is the cheapest test in the project** — it caught instance 2
  before a single measurement was taken.
- **A gate that has never opened is not evidence that the thing it guards is unsafe. It is evidence that the gate
  has never been tested.**
- **When you repair a gate, say what it was for** — otherwise the next reader inherits the number without the
  intention and cannot tell a threshold from an accident.
