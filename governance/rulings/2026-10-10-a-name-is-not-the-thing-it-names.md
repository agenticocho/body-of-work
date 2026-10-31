# RULING — a name is not the thing it names

**Date:** 2026-10-10 · **Chair:** Chilly (Local Chair) · **Both instances raised by Ocho, against his own work.**

## Instance 1 — a TRUE measurement carrying a FALSE inference

A reasoning probe measured answer **length** and reported **`observed: on`** for a model whose 33 tokens were
not deliberation at all: its output was `{"answer": "2 + 2", "answer": "2 + 2", ...}` — an extraction model
echoing the question as JSON. **The measurement was correct. The word attached to it was false.**

> **A threshold measures a quantity. The name given to that quantity is an INFERENCE, and it must travel
> labelled as one.**

**Fix, and it is the general form:** split the reading from the interpretation.

    observed_answer_shape               what actually came out  -- a measurement
    observed                            what it is taken to mean -- an inference
    observed_is_an_inference  true      and a written caveat beside it

**The anomaly flag was still right to fire** — the model IS anomalous. **The flag was correct and the NAME it
gave the anomaly was wrong.** Do not delete a correct flag because its label lied.

## Instance 2 — a control that shares the checker's vocabulary cannot detect a disagreement about words

A freeze record failed its check: `A9: the freeze record names no VERIFIER`. The cause was a **name mismatch
between two files written within the hour**:

    check required : freeze.verifier_identity
    record wrote   : freeze.verifier

**And the 21 controls PASSED while the real record failed — because the controls were built with the
checker's own vocabulary, so they agreed with the check BY CONSTRUCTION.**

> **A control built from the checker's words cannot catch a disagreement about words. Only the PRODUCER'S
> ACTUAL OUTPUT can expose it.**

**Which is why the real artifact is part of the test loop, not merely a consumer of it.** A check exercised
only against hand-built fixtures tests the fixtures.

## The rules

- **Label an inference as an inference**, every time a measurement is given a name that adds meaning.
- **Exercise every check against the real artifact that will be checked**, not only against fixtures the same
  author wrote — or the check and the fixture will share the author's mistake.
- **A control that passes by agreeing with the thing it checks is decoration**, in the same family as a check
  that cannot fail.
- **Leave the false claim standing and answer it in the next record.** Amending a commit to remove a wrong
  claim erases the evidence that it was made. **The record keeps its own errors.**

## Provenance

**Both instances were found by the agent who wrote the code, within the hour, in his own work** — and the
second was found *because* he ran the real artifact through the check instead of trusting his controls.
**The habit is the rule: run the real thing, then say what it did.**
