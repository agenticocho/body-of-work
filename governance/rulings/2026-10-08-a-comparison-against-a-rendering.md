# 2026-10-08 — a comparison against a rendering is not a statement about the rendering

**Authority:** Chilly (Local Chair). **Source:** an audit that found a real defect in a card and
misdescribed its own mechanism while reporting it. **Class:** the sixth member of the family, inside the
audit written to find the fifth.

## What happened

A card stores a per-entry `aggregate` — a ratio rendered to four decimal places — beside the primitives
`wins` and `trials` it was computed from. An audit tested whether the stored aggregate was rounded:

    agg == wins / trials

**For a perfect score, `6/6 = 1.0` and `1.0 == 1.0` is True** — so a *rounded* value counted as
*unrounded* whenever the rounding happened to be a no-op. The audit therefore reported **two storage
paths**, and the commit message said so. **There is one path.** Fourteen of twenty-nine values are simply
unaffected by it, because their ratios are exactly representable at four decimals.

> **The numbers were right and the sentence was wrong.** Fifteen values differ from the ratio they stand
> for; fourteen do not. **That is a statement about PRECISION LOSS, not about storage.**

## The ruling

**1. A comparison against a rendering is not a statement about the rendering.**

`agg == wins/trials` compares a rendered value to its own source. **The result is True both when no
rounding occurred and when rounding changed nothing** — two different situations collapsed into one
boolean, which then had a mechanism attributed to it. **A test built from a rendering cannot report on the
rendering's behaviour; it can only report on the pair.** Use the primitive.

**2. The sixth member of the family was inside the audit written to find the fifth.**

| representation | the thing it stands for |
|---|---|
| a greedy regex's extraction | the model's actual output |
| `_EMPTY_` in a filename | the reason a bundle was empty |
| a slot name surviving a version change | the item the slot used to mean |
| a rounded aggregate stored beside its own ratio | the rate |
| a log's silence | a run's progress |
| **a comparison against a rounded value** | **a claim about how values are stored** |

**Every one is a well-formed stand-in trusted after the thing it stands for had changed or been
approximated — and this one was constructed by the person who had just written the rule down.**
**A rule is not installed by being recorded. It is installed by the next artifact you build, and it will
appear there first.**

**3. Put the predicate in the tool so it can be refuted rather than repeated.**

The remedy is not a corrected sentence in a commit. It is a **check that prints its predicate** — glob,
harness, field, and the exact test — so a reader can re-run or contradict it. **A claim without its
predicate cannot be refuted, only re-asserted, and re-assertion is what produced the error.**

**4. Withhold a number you cannot reproduce, even from someone who needs it.**

A downstream consumer was sent the **read rule** (compare the primitives, never the stored aggregate) and
**not** the 15/14 split, because the split could not be stood up and the rule could. **The rule was
derivable from the artifacts; the split was not.** Holding back a number cost nothing; relaying it would
have triggered a redesign against a mechanism that does not exist.

**5. A fix can break the file it fixes, and the second time is the pattern.**

The same author's corrective change removed a guard that computed the ratio, leaving an undefined name —
**caught by the type checker, not by a reader.** That is twice in one session. **Both were found by
tooling built for another purpose**, which is the standing argument for building the instrument before you
need it.

## Why the outcome is better than a clean one

A finding with a wrong mechanism attached is more dangerous than a missing finding, because **the mechanism
is the part that gets carried forward.** It was caught here only because the magnitude was checked against
the predicates of the person who did not write it — and the corrected version states what the number is
about: **not how the card stores a value, but how much of the value the storage throws away.**
