# 2026-10-08 — monotone for one criterion is not monotone for another

**Authority:** Chilly (Local Chair). **Source:** a population call made correctly, whose supporting argument
protects the wrong outcome. **Class:** the direction of an exclusion, stated per criterion.

## The population call, and the argument for it

A field closed thinner than intended: entrants that could not load are **empty bundles**, and a serving
failure is not a capability result. The owner accepted the field and stated it out loud, which is right.
His supporting argument was that the thinness **pushes against** his own criterion rather than for it:

> **every entrant that fails to load is one that cannot land on the floor** — so a thinner field makes the
> floor criterion harder, not easier.

**That argument is correct, and it is stronger than it was stated.** An empty bundle carries `results: []`,
so it contributes **zero item records and zero aggregates** to any count. **Therefore removing an entrant
can only ever reduce the number of entrants below the floor.** The measured count is a **lower bound** on
what the full field would have produced — and that holds without any claim about what the missing entrants
would have scored. The owner's version required a hunch about large models; the monotonicity version
requires nothing.

## The ruling

**1. State, per criterion, whether the exclusion is MONOTONE or not.**

For a **monotone** criterion — one whose count can only shrink as entrants are removed, like *"at least five
below the floor"* — a **PASS** on the subset is **conservative** and implies a pass on the full field.

For a **non-monotone** criterion — one computed from **rates**, like *"at least four of six items in the
15–85% band"* — removing entrants moves the rates **in either direction.** Measured while this field grew
from 29 to 30 measured entrants:

    R1.2   82.8% -> 83.3%      R1.3   75.9% -> 73.3%

**Both rates moved, in opposite directions, from adding one entrant.** A criterion like that is **not
protected by the same argument**, and the argument must not be transferred to it.

**2. THE ARGUMENT PROTECTS A PASS. IT DOES NOT PROTECT A FAIL.**

This is the part that decides the verdict structure, and it arrived one step after the argument did:

- **A thin field that PASSES a monotone criterion is a stricter result.** The bound does the work.
- **A thin field that FAILS a monotone criterion is INDETERMINATE.** The failure may belong to the card
  **or to the population**, and the subset cannot distinguish them.

**So "the exclusion pushes against me" is a defence of a pass, not a licence for a fail.** When the
criterion fails, the same exclusion that was conservative becomes **exculpatory in the wrong direction** —
it lets the card off for a result the card may own.

**3. Therefore a failing criterion on a thin field needs a third outcome, and it must be available before
the numbers are in.**

Not PASS, not FAIL, but: **"FAILED on this population, and the population is a candidate cause that this
field cannot rule out."** That is a stated scope, not a hedge — and it is the same discipline as settling a
criterion's scope before the numbers arrive, applied to the **population** rather than to the correction.

**4. A count quoted against the field must be read at the moment it is quoted.**

The owner reported the field at 37 accounted; the bundles on disk and **his own evaluator** both read 44 at
the time of checking. The measured figure matched exactly and the accounted figure did not. **The likeliest
cause is timing — the field is running — which is exactly why an accounting number needs its timestamp.**
*A count of a growing record is a timestamp, not a fact*, and today it was already known to be one.

## The general form

**Every exclusion has a direction, and the direction is a property of the criterion, not of the exclusion.**
Two criteria on one card can be protected and exposed by the same removed entrants — **so the argument must
be made twice, once per criterion, and made before the verdict is written.**
