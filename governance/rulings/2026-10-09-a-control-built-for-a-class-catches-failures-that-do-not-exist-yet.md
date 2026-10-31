# A CONTROL BUILT FOR A CLASS CATCHES FAILURES THAT DO NOT EXIST YET

**Filed:** 2026-10-09 - Local Chair (Chilly)

## THE OBSERVATION

Four attempts to make one test runnable, each failing differently, and each caught by a check that had been
written before it:

    composition check     caught a source that reached 0 LOST in 30 positions
    composition check     caught a source that reached only one side
    reading plies         caught hits that were ONE crossing sampled six times, not six observations
    measuring first       caught an acceptance rate of 0.00 before any budget was spent
    reading the continues caught a missing source skipped SILENTLY, narrowing the monitor's own scope

**And the person who built them said the thing worth keeping:**

> **Every check that caught a failure was built before the failure it caught. None of them was built to catch
> that particular one.**

## THE RULE

> **A CONTROL BUILT FOR A KNOWN FAILURE CATCHES ONLY THAT FAILURE. A CONTROL BUILT FOR A CLASS CATCHES
> FAILURES THAT DO NOT EXIST YET.**

**A control aimed at a specific failure is satisfied by that failure and blind to the next one.** The
composition check was written to ask *"did the sample reach both sides"* -- a property, not an incident -- so it
fired on two different sources for two different reasons, neither of which was anticipated when it was written.

**This is why "add a check for the bug you just found" is the weaker repair.** It closes the instance and leaves
the class. The stronger repair is to name the **property** the instance violated and check that -- which is also
why the checks above kept firing after the specific bug was fixed.

## AND WHAT MAKES AN UNANTICIPATED FAILURE VISIBLE AT ALL

**The outcome rows were written down before each draw.** A failure that lands on a row is a **result**; a failure
that lands on nothing is **absorbed** -- it becomes a number in a table, or a quiet re-scoping, and nobody
learns there was a failure. *A pre-registered outcome row is what converts a surprise into a finding.*

This is why the sequence reads as four failures rather than one slow success. **The failures were visible
because their shapes were named in advance**, and the one thing that would have hidden them -- a reach threshold
quietly lowered until the sample fit -- was refused five times over.

## COROLLARIES

- **Name the property, not the incident.** *"Did the sample reach both edges"* outlives *"did that bug recur"*.
- **Pre-register the outcome table, not only the threshold.** The rows are what make a failure legible.
- **A monitor's own failure modes are in scope.** A skip, an unreadable form, a missing source, and a dead
  process all present as the same output -- nothing to report -- so a monitor needs a control on its READING,
  not only on its verdict.
- **When two cheap designs each fail a different requirement, the requirements are in tension by construction
  and no parameter will resolve it.** Four iterations on a walk-based generator did not converge because a walk
  cannot be both dense in a narrow window and independent. **The answer was a different kind of source, and the
  signal was that each fix satisfied one requirement by violating the other.**
- **A 0.00 acceptance rate is a refutation, not a disappointment** -- and reporting the question as UNREACHABLE
  with the available tooling is a result, not a failure to try hard enough.
