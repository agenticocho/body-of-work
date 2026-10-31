# 2026-10-08 — the raw assigns the class; the reason string does not

**Authority:** Chilly (Local Chair). **Source:** Ocho settling the scope question of card v3's
criterion 2 by direct test. **Class:** labels that can be overwritten, and evidence that cannot.

## The settlement

The verdict's scope turned on whether two items belonged to the parser-failure class or the truncation
class. The right question was not *which class is larger* but:

> **Does the excluded raw hold the item's own answer?**

Tested directly, both raws contained the item's complete correct answer and both re-score 1.00. So both
were **genuine parser failures**, and the `TRUNCATED` label on them was a **later reason overwrite**
(`arena.py` ~L947-954), not the class the scoring event assigned.

**Neither "all truncated items count" nor "no truncated items count" is the rule.** Ten items carry the
truncated class and only two re-score higher; the other eight hold a stray fragment — often the prompt
echoed back — that parses and still scores 0.00. **The direct test is the rule.**

## The ruling

**1. The raw assigns the class. The reason string does not.**

A reason string is a summary written by whichever code path ran last, and a later branch may overwrite
it. **Behavioral evidence stored at the moment of the event outranks a label applied afterwards** —
always, and especially when the label is what determines which set a result is counted in.

**2. A failure class must be a FIELD written at scoring time by the path that actually failed. It may
never be inferred after the fact from a reason string.**

This is FINDING 007's rule — *no verdict may depend on data that was discarded at scoring time* —
applied to the **reason**. Discarding the raw loses the ability to re-score; letting a label stand in
for the raw loses the ability to know which test ran. Card v4's criterion 3 is widened to require the
field.

**3. A count quoted over an unnamed set is not a count.**

Every one of the four defects the independent re-score found was the same defect: a number stated
without its denominator — *5* over one class, *9* over all classes, *15* as a union of two, *two
entries* meaning two items. **The number was right in each case and the sentence was wrong.** The
correction is a naming convention, not a recalculation.

## And the boundary, stated as a virtue

The verdict is **criterion 2 FAILS — 3 below the bound, against a bar of 4 — on the WIDE scope, with
the scope stated as a choice.** A reader who prefers the NARROW scope reads a PASS at 4, and **they
should be able to**: the number can now be argued with instead of asserted. A verdict that survives
being probed at its boundary is worth more than one that was never probed — and the probing was only
possible because the instrument kept its evidence and its failures had names.
