# 2026-10-08 — a failed execution must never be recordable as a result

**Authority:** Chilly (Local Chair). **Source:** the harness defect found at source by Ocho, and the
fix he shipped. **Class:** the instrument, again — the sixth instance in one day, and the first one
whose signature is *silence* rather than a wrong number.

## The defect

One `continue` on a serving exception lost three things at once:

| what was lost | consequence |
|---|---|
| the **raw** | nothing to re-parse, so the item can never be corrected |
| the **reason** | no explanation to argue with |
| **that the trial never ran** | a serving failure became indistinguishable from a model failure |

The mechanism is three lines of ordinary code: a flag initialised to the empty string, an exception
handler that skips past the persistence, and a guard that tested the reason for **truthiness** — so an
empty reason suppressed the key entirely, and the bundle shipped a bare `0.0`.

**One item out of 822 was affected. The number is not the finding; the signature is.** A model that
cannot do a task and a model that was never asked are different facts, and the record could not tell
them apart. That is the same shape as 26 zero-byte bundles recorded as measurements, one level down.

## The ruling

**1. A failed execution must be recorded as a failure, never as a result.**

If a trial did not complete, the record must say so *in the item*, with the failure's type, in a field
written by the path that failed. **"We never got an answer" is a legitimate outcome and must have its
own representation.** A zero that stands for both *"answered wrong"* and *"never ran"* is a zero that
means nothing.

**2. Never guard on the truthiness of a human-readable field.**

`if npass == 0 and why` silently drops the record when the reason is empty — which is exactly the case
most in need of recording. **A guard must test the condition, not the explanation's presence.** The
empty reason is the moment to write a fallback, not the moment to write nothing.

**2b. Correction, measured after this ruling was first written.** The fix was described as "fixed twice
over, because either alone leaves a hole." Verified by isolating each half against the pre-fix source,
that is wrong:

| half | alone | verdict |
|---|---|---|
| the exception path writes the class and a reason | **closes it** | **load-bearing** |
| the guard loosened from `npass == 0 and why` to `npass == 0` | **still reproduces the silent zero** | defence-in-depth |

**The write from the failing path is the fix. The guard change cannot close it alone** — with the
`continue` still skipping both the raw append and the scorer call, there is no reason in existence to
write, so loosening the guard only substitutes an empty-string reason for a missing key. **Stated
because "either alone" implies both are necessary, and a future refactor that keeps the guard and drops
the write would read as safe when it is not.**

**3. The honest scope of a fix is forward.**

The new check reports red today — one hit across 822 item records — and goes green only for fields
written after the fix. **That is correct.** A test that cannot fail on the defect it was written for is
decoration; a test that fails on the historic instance while passing the fix is a measurement.

**4. A check must be able to fail, and it must be seen failing.**

Same rule as every check on this project, and it was satisfied here by running it against the existing
field rather than a fixture: **822 records scanned, one hit, exit 1.** The scope of the claim is the
scope of the scan.

## Two self-inflicted catches worth keeping

The fix's own author hit two traps this repo has now recorded twice each: **a counter used before it was
written** (caught by the type checker, the same defect as `staged_as` in the game contract), and **a
check reading `card_version` off the bundle when it lives on the entry row** — the wrong-level trap.
**Both were found by tooling and review rather than by the defect surfacing in a result.** That is the
argument for building the instruments before you need them.
