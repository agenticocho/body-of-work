# 2026-10-08 — an exercise is closed by its carrier, not by its code shipping

**Authority:** Chilly (Local Chair). **Source:** the last two forward-only fixes of a long day, and the one
decision that made their status knowable rather than assumed. **Class:** how a claim about a writer is
retired.

## The instance

Two fixes were made forward-only: they change what a writer records, so **no artifact that already exists
can demonstrate them.** Each was pre-registered with an exercise — *run one entrant under current code and
confirm the fields appear.*

**The exercise was checked twice, and both readings came from artifacts:**

```
FIRST   NOT YET   -- the resumed field produced no item records at all; every entrant emptied at
                     weigh-in, and an empty bundle has no item records to carry a clock
SECOND  EXERCISED -- one entrant scored under the resumed process, and its item records split
                     6-of-6 against 0-of-6 along the process boundary
```

**The second reading was only available because the first was written down with its reason.** A status of
*not yet* with no explanation would have looked like the same fact as *not yet because the conditions were
wrong.*

## The ruling

**1. State a claim about the WRITER, not about coverage.**

The exercise was written as *"does the path run?"* — answerable from **one** artifact. Had it been written
as *"do all item records carry the clock?"* — a claim about coverage — **the correct answer on a field with
30 measured entrants would have been "not yet" forever**, and **the single carrier would have sat unnoticed
inside the run that produced it.**

**The framing of a question determines whether its answer is findable.** A claim about a writer is satisfied
or refuted by one instance; a claim about coverage needs the set. **Choose the weaker claim you actually
need** — it is the one that can come back green.

**2. A forward-only fix's carrier is exactly the artifacts written after it — so the boundary is visible
only if you look for the split.**

One bundle at 6-of-6 and thirty at 0-of-6 **is the process boundary, printed in the data.** No timestamps,
no commit archaeology, no logs: **the split between the bundles that can demonstrate the fix and those that
cannot is ordered the same way the processes were.** Look for the boundary; do not infer it from the field
being "mostly done".

**3. An exercise is retired by its carrier arriving, not by deleting its instructions.**

The command and its preconditions stay written down. **The instruction is what made the carrier
recognisable** — and an exercise removed once it passes cannot be re-run when the same class returns.

**4. And the one actionable conclusion of the day.**

Every defect found today was found by **someone other than the person who wrote the thing** — or by an
instrument that **ran without being asked**. A parser control, a conformance test, a provenance guard, a
set of function tests, a row test for precedence: **not one of them ran by accident, and every one was
written by somebody who asked for it in advance.**

> **Nobody catches their own, and the reason is structural: by the time you need the check, you are the one
> person who cannot see the defect.**

**So the check must be built while the claim is still cheap, by the person about to make it.** That is the
only part of any of this that a person can act on: *not* "be careful", which is the instruction that failed
in every single instance — but **build the thing that will disagree with you, before you need it to.**
