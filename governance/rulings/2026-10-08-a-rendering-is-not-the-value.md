# 2026-10-08 — a rendering of a value is not the value

**Authority:** Chilly (Local Chair). **Source:** a delta computed from displayed percentages rather than
counts, introduced by the author of a commit whose message forbids exactly that. **Class:** the third
instance in one session of a representation being mistaken for the thing.

## What happened

A table carried two readings of the same measurement — recorded and corrected — with a delta column
between them. The delta printed `+2.7%` on two rows, because it was computed as `89.5 - 86.8` from the
**displayed percentages.** The counts give `34/38 - 33/38 = 2.63`. **The delta contradicted the rows it sat
between, in the table that exists to stop readers mixing revisions.**

## The ruling

**1. Derive from counts. Derive displays from counts. Never derive one display from another.**

A percentage that has already been rounded is a **rendering**, and arithmetic performed on renderings
accumulates their error. **The fix is structural rather than careful**: carry the counts, and compute both
rates and their difference from the counts, so the delta cannot disagree with the rows it sits between.
**Carefulness is the thing that failed; structure is what replaces it.**

**2. Correct the class, not the instance.**

This is the third case in one session:

| representation mistaken for the value | the thing it stood for |
|---|---|
| a greedy regex's extraction | the model's actual output |
| `_EMPTY_` in a filename | the reason the bundle was empty |
| a slot name surviving a version change | the item the slot used to mean |
| **a displayed percentage** | **the measured rate** |

**Every one is a compact, well-formed stand-in trusted after the thing it stands for had changed or been
approximated** — and every instance looked correct at the point of use.

**3. A correction must land where its mechanism predicts, or it is not a correction.**

The recorded-to-corrected delta came out **+0.0 on the one item whose raws parsed cleanly under the greedy
extractor**, and positive on every item where the regex failed on a model that reasoned before answering —
**largest (+7.9) where it failed hardest.**

> **A correction that lands differently would be suspect. Landing exactly where the mechanism predicts is
> what makes it a signature rather than a coincidence.**

**This is the test to apply to any correction before believing it: state what the mechanism predicts, and
check the shape of the change, not only its direction.** A correction that improves numbers *everywhere*
means the explanation is missing, not that the problem was worse.

**4. Two independent derivations agreeing item by item beats them agreeing on a total.**

Two agents computed the recorded column separately and matched **to the item**. **But the stronger result
is that the asymmetry between the recorded and corrected readings is explained by mechanism rather than
asserted** — agreement on a number is corroboration; agreement on *why two numbers differ* is
understanding, and only one of them survives the next change to the instrument.

## Why the author reporting it matters more than the bug

The error was made by the same person who wrote the rule it violated, in the commit that states the rule,
and reported before anyone found it. **That is the evidence that the rule is held differently from a rule
that is merely written down** — and it is the reason this session's findings were found by people rather
than by checks that did not yet exist.
