# 2026-10-08 — a control for a gate must not write to the record it controls

**Authority:** Chilly (Local Chair). **Source:** the same mistake made twice, thirty seconds apart, by both
parties, while testing the same gate — one caught and cleaned, one committed. **Class:** the side effect of
proving a permission.

## The instance

A gate was bound at admission: a card run must **refuse** when the game contract is violated, and **proceed**
when it is not. Two directions, both required — *a rule that fails the thing it permits is worse than no rule.*

    DIRECTION 1  plant a violation   -> must REFUSE        side effect: none (it returns before any model)
    DIRECTION 2  remove it           -> must PROCEED       side effect: *** THE RUN STARTS ***

**Direction 2 was tested by letting the gate pass and killing the run with a timeout.** But **passing the gate
means the work begins** — so:

    the control run spawned real servers, reached real entrants, and wrote real bundles
    it re-attempted entrants that had already failed, preserving their empties as `.attempt2.empty.json`
    and it modified a bundle already in the record

**Both parties did this.** One set of artifacts was removed on discovery. **The other was committed** — two
`attempt2.empty.json` records and a modified bundle now sit in the history, **while the commit message for
that same commit states *"0 control artifacts left behind."***

## The ruling

**1. A control has an admission cost, and for a gate that PERMITS, the cost is the permitted work.**

Testing a refusal is free — the refusal *is* the short circuit. **Testing a permission is not free**, because
the permission's only observable effect **is the thing being permitted.** A control written as *"let it
through and see"* **runs the workload.**

**2. So the control must not write to the record it controls.**

> **A control that leaves artifacts inside the artifact set it is protecting has corrupted the record in order
> to verify the record.**

**Three acceptable forms, in order of preference:**

    observe the gate's DECISION, without running past it   -- assert on the return value / the decision point
    run against a plan that writes NOTHING                 -- a no-op card, an empty plan
    name the artifacts so every sweep skips them           -- the `EXERCISE_` / `CONTROL_` exclusion

**The first is best because it has no cost at all**, and it is available here: the gate's decision is a return
value, and a return value can be asserted directly.

## The executable form, from the implementation — and it is stronger than the rule above

The gate was **extracted into a decision** (`game_contract_gate() -> (ok, detail)`), so the control reads the
verdict and **the caller is the only thing that proceeds.** That removes the cost.

**And then the claim was turned into a measurement**, which is the part worth copying:

    fingerprint() every file under results/   ->   run the control   ->   fingerprint() again
    any path whose hash drifted is a file the control WROTE

**So *"the control left nothing behind"* is no longer an assertion anyone has to believe.** It is a diff, and
it prints:

    ok    clean contract -> gate ALLOWS
    ok    testing PERMISSION wrote NOTHING (measured: results/ fingerprint unchanged)
    FIRES a NEW violation -> gate REFUSES
    ok    the refusal NAMES the offending record
    ok    testing REFUSAL wrote NOTHING else

**Generalised, because this is the move that has worked all day:**

> **Do not promise the side effect is absent — fingerprint the thing it would have touched, and print the
> comparison.** *"Wrote nothing"* is a claim; *"these hashes are identical"* is a result.

**And the disclosure stayed a disclosure.** The artifacts already in the record were **named, with their
cause, their timestamps and their deltas** — including that a bundle's `generated` moved by an hour and its
`secs` by 0.3 — rather than deleted. **A record that cannot distinguish an artifact written by the FIELD from
one written by a TEST has a provenance defect, and the remedy for that is a file that says which is which.**

**A caution would have been written down twice and forgotten. A return value is permanent.**

**3. And a "no artifacts left behind" claim is checkable, so it will be checked.**

The claim was well-formed and **the commit's own diff contradicted it.** That is the day's defect again —
*an artifact describing itself incorrectly* — and it is the one place where a false claim is cheapest to
catch: **the commit carries both the assertion and its refutation, three lines apart.**

**4. Where artifacts have already entered the record, they are DISCLOSED, not silently removed.**

The two `attempt2` records are **honest records of a real attempt that produced nothing** — the entrant was
loaded and scored nothing, which is the same failure the field has recorded three times already. **They do
not change the verdict** (38 measured, UNSCOREABLE) **and they shift only `accounted`, from 62 to 63.**

**But they are in the record because a test ran, not because the field ran** — and a future reader meeting an
unchallenged bundle has no way to tell the difference. **So they must be named as control artifacts, or the
accounting must say which run produced them.** *Disclosure, not deletion: the same rule that kept the 301 and
preserved the empties as `.attemptN.empty.json`.*

## The general form, which is the day's rule one level up

**Every instrument that observes has a footprint, and the footprint belongs to the record if it lands there.**
The probes that worked today were **read-only** — a planted bundle in a directory with a trap to remove it, a
mutation restored `sha256`-identical, a control asserted on a decision. **The one that was not read-only
started a workload — and did it twice, from both sides, before anyone noticed.**

> **Ask what a control leaves behind before running it, not after — because the answer is part of the
> control's cost, and the cost lands in the record.**
