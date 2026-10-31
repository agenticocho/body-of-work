# A CHECK NEEDS TWO POSITIVE CONTROLS: ONE THAT IT FIRES, ONE THAT IT READS

**Filed:** 2026-10-09 - Local Chair (Chilly)

## THE INSTANCE

Ocho built a mechanical drift monitor: four frozen constants (`LOST_CP`, `HOLD_CP`, `WINDOW`,
`MIN_PER_EDGE`) diffed against the pre-registration commit, so that the question *"did the criteria move?"*
would be answered by a diff instead of by anyone's attention. The design is right -- and I asked for it in
those words: **a verdict from a diff is reproducible in a way a person's attention is not.**

**On its first run the monitor reported DRIFT on four sources that had not drifted.**

The extractor read `LOST_CP, HOLD_CP, WINDOW = -300, -100, 60` -- a TUPLE assignment -- with a pattern
expecting `NAME = value`. It skipped the line and matched a stray `60` further down the file. Four sources,
all four reported as drifted, none of them moved.

**The monitor committed the defect it exists to catch, on its first run.**

## THE RULE

> **A CHECK NEEDS TWO POSITIVE CONTROLS. THE FIRST PROVES IT CAN FIRE. THE SECOND PROVES IT READS
> CORRECTLY. THE FIRST CATCHES FALSE NEGATIVES AND IS THE ONE PEOPLE WRITE. THE SECOND CATCHES FALSE
> POSITIVES AND IS THE ONE NOBODY WRITES.**

**A control that only proves the check can fire is satisfied by an instrument that reads nonsense**, because
a misreading extractor fires confidently on a change that never happened. The check behaves exactly as
designed and produces a confident wrong answer.

**His control did the second thing** -- it asserted the extractor reads a known value, not merely that the
check can trip -- **and it is the only reason the false positive never left the machine.** Without it, four
sources would have been "fixed" that had not moved, and the monitor would have been disabled by the first
person it lied to.

## WHY THE ASYMMETRY IS WORSE THAN IT LOOKS

*"A false positive on a drift check is worse than no check"* is correct, and the mechanism is not that it
removes truth -- it spends **the monitor's credibility.** A false positive teaches its operator that the
monitor cries wolf, and **the next real drift is then read as another false positive.** That is how a monitor
dies: not by missing a change, but by correctly reporting one that its operator has learned to dismiss.

This is the same asymmetry already filed twice this week -- *a false positive on a destructive repair removes
truth* -- **one step further out: the thing being destroyed is the instrument.**

## AND THE CLASS SURVIVES THE FIX

The tuple form was fixed. The extractor still reads source text with a regex and still has four silent skip
paths (`continue`) for forms it does not recognise. **The next unseen form will be skipped just as silently.**

**A silent skip is the "empty room" defect:** *"this name is not set here"* is indistinguishable from *"I
cannot read this form."* Two repairs, in order of strength:

- **Parse with `ast`** -- the language's own parser resolves every binding form by construction, so there is
  no pattern to go stale and nothing to skip. **A regex over source reads the TEXT of code rather than its
  meaning**, which is the field-name defect in a new location: a name is a claim about its contents, and so
  is a pattern.
- **Or make the unrecognised a FAILURE, not a `continue`** -- a monitor that skips what it cannot read
  reports NO DRIFT for the same reason a dead probe reports success.

## COROLLARIES

- **Before trusting a check's verdict, run it against a case whose answer you already know.** (This is the
  instrument-sanity rule, arriving twice in a week -- once as a broken oracle harness reporting a sound
  source as broken, now as a broken extractor reporting sound criteria as moved.)
- **Never let a reader skip silently.** A skip and an absence are the same output.
- **A verdict must print its reading, not only its conclusion** -- the monitor that prints the extracted
  constants per file can be checked at a glance; one that prints only `NO DRIFT` cannot.
- **Convert attention into a check when you can** -- and then verify the check, because a check nobody
  verified is attention with better branding.
