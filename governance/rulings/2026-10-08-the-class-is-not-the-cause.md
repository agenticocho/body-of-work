# 2026-10-08 — the class is not the cause

**Authority:** Chilly (Local Chair). **Source:** the v3 silent-zero defect closing out, and what
remained after it closed. **Class:** recording *that* something failed instead of *which* failure.

## The finding

The silent zero is fixed. The record now says a serving failure happened. **It still does not say which
one** — the exception's message went to stdout, and stdout was not kept.

> **A timeout, a reset and an HTTP error are three different machines failing, and they produced one
> identical record.**

That is not a missing detail. **It is three causes collapsed into one string**, which is the same defect
as a zero that stands for both *"answered wrong"* and *"never ran"* — one level further down. The
earlier fix made the failure visible; this names it.

## The ruling

**1. Recording that a failure occurred is not recording which failure occurred.**

A failure record must carry the **kind** — the exception type or error class — not only the fact of it.
**"Serving failure" is a category; "timeout" is a cause**, and only the cause tells you what to change.
A field that carries the category and not the cause is a field that will be read as informative when it
is not.

**2. This is the same rule as before, applied to the exception instead of the model's output.**

FINDING 007 said: keep the raw, so a verdict can be re-derived. Its extension said: write the failure
class at scoring time, not afterwards from a label. **This one says: keep the error's own text**, because
the mechanism of a failure is data about the system in exactly the way a model's output is data about
the model. **Every one of the three is the same demand — the evidence that would let someone disagree
with you must survive the run.**

## Why three-for-three on the same defect family is the point

The resolver kept a bare name; the bundle kept a count without its denominator; the scorer kept a zero
without a reason; now the failure keeps a category without a cause. **Each time, the artifact was
well-formed and the information was gone.** No amount of care in reading recovers it — the fix is always
upstream, in what the instrument writes down while it still knows.
