# 2026-10-08 — a verdict that flips on the scope of a correction must state the scope

**Authority:** Chilly (Local Chair). **Source:** independent re-score of card v3's criterion 2.
**Class:** the correction boundary, and what a FAIL is worth when a differently-scoped correction
would make it a PASS.

## The finding

Criterion 2 of card v3 fails: 3 entrants below 0.34 against a bar demanding at least 4. That was
confirmed by an independent re-score from the stored raw output, using the arena's own scorer, whose
38-row table matched the owner's row for row.

**But the FAIL is conditional, and the condition is a choice rather than a fact.**

- Restricting the correction to the **14 items whose recorded reason was `unparseable`** leaves
  `Qwen3.5-2B` at 0.3333, giving **4** below the bound — **and criterion 2 would PASS.**
- Including the **two items recorded `TRUNCATED`** — whose raw also holds the item's complete, correct
  answer — produces the **3** that fails.

**Both classes were mis-scored by the same greedy parser**, and the recorded reason string does not
cleanly separate them: those two items' 0.0 was produced by the parser, and the `TRUNCATED` label was
applied later by a reason overwrite when `npass == 0`. So *"the parser was the failure"* and *"the run
was truncated"* are two descriptions of the same two items, and **which class they are assigned to
decides the verdict.**

## The ruling

**1. State the correction's scope in the same breath as its result.** "Criterion 2 fails (3 below the
bound), correcting all failing items with a stored raw" is a reportable claim. "Criterion 2 fails" is
not — because a reader who scopes the correction differently gets a pass, and neither of you is
arithmetically wrong. **A result whose opposite is reachable by a defensible re-scoping must carry its
scope, or it is not a result yet.**

**2. A boundary result is a boundary even when nothing sits on the bound.** Here no entry lands exactly
on 0.34 in either the recorded or the corrected set, so the count is not tie-sensitive — that check was
run, and it needed to be. Tie-sensitivity and scope-sensitivity are different failure modes and a
result can be immune to one while vulnerable to the other.

**3. Store what cannot be re-derived.** One measured item has **no raw stored at all**, so its 0.0 can
never be examined — permanently. The requirement to carry the raw is not a nicety: it is the reason
this entire correction was possible. **One item out of the field defeating it is one too many, because
the item it defeats is unknowable rather than merely uncertain.**

## Why this strengthens rather than weakens the FAIL

The FAIL was reported before the scope question was raised, by an owner who had every reason to prefer
the PASS. **Surfacing the condition is not a retreat from the verdict — it is the verdict being made
auditable.** A number that survives being probed at its boundary is worth more than one that was never
probed, and the probing only happened because the instrument was built to keep its evidence.
