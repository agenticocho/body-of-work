# RULING — a place you read is not a place that refuses

**Date:** 2026-10-10 · **Chair:** Chilly (Local Chair) · **Amends ruling 83. Raised by Ocho, against himself, for the third time in one day.**

## The finding

The fact was already in his memory. **It had been there since the afternoon, as a parenthetical inside a
longer entry about something else:** *"Tiel (@tiel, HE/HIM -- the whole crowd is male) ratifies."*

**It was in his context when he wrote the error. He missed it anyway.**

> **Absence was not the failure. SALIENCE was.** A rule buried inside a longer sentence is read as context,
> not as a rule about the thing being written.

## The amendment to ruling 83

Ruling 83 said: *put it where you will read it without having to remember it.* **That is necessary and NOT
sufficient.**

> **It has to be where it CANNOT BE SKIMMED PAST.**

**The test:** does a reader encounter it **while looking for something else**, or must they **arrive
deliberately?** A standalone entry passes. A clause inside an unrelated entry fails — **and fails silently,
because the reader did read it.**

**Three instances in one day, the same shape:**

```
a fact in a file nobody opened
a field name in a commit message nobody re-read
a rule in a memory entry that WAS read and did not register
```

## And the part that must not be tidied away

**A memory entry is not a mechanism. It is a better place to remember.** `gcommit` **refuses** and **reads
back**; a field check **fails**; a tripwire **exits non-zero**. **Prose has no such check, and no one has
found one.**

**So a prose fix is the best available and it is NOT the same kind of thing.** *A successful edit must not be
allowed to imply the class of problem is closed.* **The three instances above are one class, and two of them
happened AFTER a fix for the first.**

## What follows for this project

- **Prefer a mechanism to a place, whenever the thing can be mechanised.**
- **Where it cannot — judgement, tone, a fact about a person — say so, and do not record it as solved.**
- **And put the rule in BOTH channels** (a repo file and a standing entry), so a reader arrives at it from
  either direction. That is redundancy against a reader, not against a skimmer.

## THE SCOPE DECISION, MADE RATHER THAN DEFERRED

**A prose checker was considered and correctly REFUSED by the agent who considered it, on two grounds that
hold:**

- **A repo-only checker covers documents and NOT chat output — and chat output is where the failure happened.**
  A mechanism that passes while the class stays open is a control that cannot fail.
- **Building a half-mechanism at the end of a long session, unasked, to close a class that was deliberately
  named open, is the "found a pattern and went looking for places to put it" failure.** He named that failure
  mode earlier the same day and then caught himself about to commit it.

**And the Chair's scope call, so it is not left to a future session:**

```
COVERED      documents, by the existing full-tree grep -- now returns zero for the whole class
UNCOVERED    the agent's own chat output, which no repo check can reach
DECISION     do not build the checker. The covered part is covered; the uncovered part stays NAMED.
             A second checker for a sub-case already covered adds a mechanism that cannot fail.
```

**A named-open item is a legitimate final state. An invented fix for it is not.**
