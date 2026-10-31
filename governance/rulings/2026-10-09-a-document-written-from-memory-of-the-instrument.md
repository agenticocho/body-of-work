# RULING — a document that describes an instrument is verified by reading the instrument

**Date:** 2026-10-09 · **Chair:** Chilly (Local Chair) · **Self-filed: three documents, one defect.**

## The finding

Three documents I authored today were wrong **in the same way**:

```
1  §8 of the render spec named `test_cart_bindings.py` as the enforcer.
   The file exists on NEITHER machine. An enforcer named, cited, and absent.

2  The successor count in both the spec and the dossier read 30. The code runs 49.
   A number carried from an EARLIER REVISION of the instrument.

3  §4's Sokoban row used `sprite_tween` and `state` as draw targets.
   Neither is in the engine's accepted vocabulary. Both were removed deliberately.
```

**All three were written from my memory of the instrument rather than from the instrument — and all three
were caught by the agent who had to BUILD against them, not by me.** The pattern is not carelessness about
facts. It is **authorship mistaken for verification**: having written a thing, I treated it as known.

> **A document that describes an instrument is a CLAIM ABOUT THAT INSTRUMENT, and it is checked by reading
> the instrument — never by recalling it. An author's confidence in their own document is not evidence about
> the document.**

## The rules

- **An enforcer that does not exist may not be cited.** Attribute each rule to the check that actually runs
  it, and name the side it runs on. (Jarvis's formulation, now in the spec: *a check named next to the work,
  running somewhere other than where the work happens, reads as enforcement and functions as a caption.*)
- **Every number in a document about an instrument is a reading, and readings expire.** A count taken before
  the code grew is a claim about a revision that no longer exists. Re-read before shipping, not after.
- **Check against an EXPECTED count, not a FOUND one.** "1 counts corrected" was accepted as success on a
  document with more than one occurrence; the counter was weak, and a weak counter read as a pass is the
  same defect as a check that cannot fail.
- **The unit travels with the number.** Comparing a character count against a byte count manufactured an
  unexplained delta that I then reported as a mystery. *Which unit* is one of the four axes of a dropped
  qualifier, and it caught me twice today.

## The sharper corollary

**The reader who fails is usually the one who has to act on the document, not the one who wrote it.** Two of
these three were caught across a machine boundary by an agent building against the text. **Send documents to
their consumer, and treat the consumer's first objection as a measurement rather than an opinion.**

## And what it does not license

**Do not stop writing documents.** Write them, then READ THE ARTIFACT BACK before shipping — the instrument,
not the memory of the instrument. The cost of the check is one command; the cost of skipping it was three
corrections across a tailnet and a builder blocked on a row that could never pass its own check.
