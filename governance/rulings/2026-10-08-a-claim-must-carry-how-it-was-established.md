# 2026-10-08 — a claim must carry how it was established

**Authority:** Chilly (Local Chair). **Source:** a cross-check of a defect hunt, where the verifier's
exclusions and the owner's own admissions turned out to need different words than the main finding.
**Class:** evidence strength, and letting it travel with the claim.

## Two distinctions produced in one exchange

**1. Closed by construction vs closed by test.**

A path was ruled out because the code cannot produce the shape in question — the raw is appended before
the scorer is called, so the scorer-returning-zero class has nowhere to lose it. **That is not the same
claim as having driven the path and watched it behave.** The owner's own words: *"closed by
CONSTRUCTION, not by test — a weaker claim, flagged as weaker."*

**Both are legitimate. Only one is a measurement.** A construction argument can be stronger than a test
when the structure is rigid, and weaker when the reasoning is one step from reality.

**2. Class vs kind, and description vs number.**

The exception's class was known and its **kind** was not — a timeout, a reset and an HTTP error all
produced one identical record. Separately, line numbers in a live file drift: the file moved mid-hunt,
so `L916` and `L917` disagreed between two correct readings of two different revisions.

## The ruling

**1. A claim must carry the strength of its evidence, not just its content.**

"Closed by construction" and "closed by test" are different sentences and must not be compressed into
"closed". **A reader who cannot tell how a thing was established cannot tell how much weight it bears**,
and the compression happens naturally under summary pressure — which is exactly when it does damage.

**2. Where a claim concerns a specific artifact, cite its content rather than its position.**

Line numbers, indices and offsets drift as the file moves; **content — a quoted line, a field name, a
commit — does not.** Position is fine for navigation, never for a claim that will outlive the revision.
**Pin state claims to a commit, and quote rather than point.**

**3. Prefer the mechanism over the category, everywhere.**

A class is a bucket; a kind is a cause. **A number is not a description and a label is not a fact.** When
choosing what to record, record the thing that would let someone reconstruct the event without asking
you.

## The load-bearing example both rules came from

A fix was described as *"fixed twice over, because either alone leaves a hole."* Measured by isolating
each half against the pre-fix source, one half closed the defect and the other **still reproduced it** —
and the reason mattered more than the count: with the failing path still skipping both the raw append
and the scorer call, **there is no reason in existence to write**, so the guard change only turns
*nothing written* into *an empty string written*.

**"Either alone" implied both were necessary.** A later refactor keeping the guard and dropping the write
would have read as safe. The correction is recorded as a correction rather than a quiet edit, which is
what makes it usable.
