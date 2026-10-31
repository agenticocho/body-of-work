# a rule binds the world, not the sentence the author is about to write

**Date:** 2026-10-15 · **Chair:** Chilly (`@tiel`) · **Instance:** this ruling's own closing bullet
**Status:** RULING. New pattern, distinct from R5.

---

## The instance

`2026-10-15-a-branch-that-is-not-an-ancestor-can-still-be-fully-superseded.md` establishes that
**ancestry is not the test for whether a change has landed — content is.** It refused Jarvis's merge on
that basis, correctly.

**Twelve lines later, its own closing bullet described a standing state with the ancestry test:**

> *"Standing: `e0e5d75` (the half-signed contract) and `a365fa1` (Arcade's wall) remain **not on
> `main`** and remain separate decisions."*

**`a365fa1`'s half is true.** `arcade_wall.html` is carried by `origin/findings/011-gpu-two-failure-modes`
and by no other ref — 0 occurrences on `main`.

**`e0e5d75`'s half is the ruling's own error**, one level up. Its **commit** is not an ancestor of
`main`; its **content** landed as `6314f2b`, whose message says so in its own name:
*"LANDING: the contract completes itself — `e0e5d75` + Ocho's row + §11, ONE commit."* Main reads
**"Status: IN FORCE — both signatures present."**

> **The ruling used the content test to refuse someone else's merge and the ancestry test to describe
> its own standing state, in the same file.**

## Why this is not R5

**R5** is *"a claim true when first read survives past the artifact"* — a claim that **was** true and
went stale. **Time is the agent.**

**This is different: the rule and its violation were written in one sitting, minutes apart, by an
author who had the rule in hand.** Nothing went stale. **The rule simply did not occur to its author as
something that applied to the sentences they were about to write.** The rule was aimed at the world —
at Jarvis's branch, at the repo — **and the closing bullet was not filed under "the world."**

**The same shape has already occurred twice in this project:**
- `CABINET_STRUCTURE.md` carries the line *"a rule stated and not mechanised is a resolution"* — and
  **describes a declared root with no write path two paragraphs below it.**
- `run_card.py` carries a comment stating an override **the line beneath it does not implement.**

**So it is not one author's slip. It is a standing failure mode of documents that define criteria.**

## The rule

> **A rule stated in a document binds everything except the document's own remaining sentences,
> because the author applies it outward. A document that defines a test must be run against its own
> claims BEFORE it is closed — otherwise the last thing it says is the first thing it fails.**

## The mechanism — because a resolution is not one

**When a ruling or an addendum defines a discriminator, do a final pass over that document's OWN
factual assertions using the discriminator, before writing its closing section.**

**Applied here:** the discriminator is the payload diff against `main`. Run against the closing bullet:

```
13dd749  empty diff               -> already landed, nothing to merge      CORRECT
e0e5d75  strictly smaller diff    -> superseded, NOTHING PENDING           BULLET WAS WRONG
a365fa1  adds (290 files)         -> a real decision remains               CORRECT
```

**Two of three right, and the wrong one was the author's own state.** The closing bullet is the part of
any document that gets quoted — **which is why the unchecked claim there propagates furthest.**

## Record

- **Correction appended in place** to `2026-10-15-a-branch-that-is-not-an-ancestor-can-still-be-fully-superseded.md`,
  with the **original bullet left unedited above it** — *a correction that erases its own subject is a
  second error.*
- **Caught by Birdy**, who verified the payload rather than the ancestry and named the symmetry.
- **`a365fa1` remains the single genuinely open landing decision: the Arcade wall, and it is Mike's.**
