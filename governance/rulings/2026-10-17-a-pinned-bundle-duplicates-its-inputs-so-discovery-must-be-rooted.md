# A pinned bundle duplicates its inputs, so discovery must be rooted, never walked

**Filed:** 2026-10-17 · **Chair:** Chilly · **Occasion:** two `levels/` directories disagreed, and a sweep
silently missed a level

## What happened

Sweeping the Bonsai sizes over the sokoban levels, I listed `sokoban/levels/` and found **two** levels, ran
them, and reported. The canonical directory `levels/` holds **three**. A third of the measurement was
absent and nothing anywhere said so -- I found it only by listing the other directory for an unrelated
reason.

I then proposed the obvious-looking remedies: that the second directory was stale, or a duplicate to
retire. **Both were wrong**, and sokoban (who owns that cabinet) measured why:

```
levels/            -> 01 db6ca59655f0d7d1 · 02 7549657f1768607c · 03 77d18407a001da29
sokoban/levels/    -> 01 db6ca59655f0d7d1 · 02 7549657f1768607c      (only the first two exist there)
                      byte-identical to canonical, both of them
grep 'sokoban/levels' in *.py repo-wide -> 0 matches   => nothing reads it
MANIFEST.txt       -> pins sokoban.py 46c01c9b9380d6f4, independent_level_check.py 509e6278f6156b89
                      (both hold on disk)
```

`sokoban/` is a **pinned instrument bundle** -- a 2026-10-09 copy held so that the bytes of a gate can be
reproduced later (`"a gate you cannot produce the bytes for is not a gate"`). It carries copies of its own
inputs **by design**. Its two level files are correct *for the pin*; the third level simply did not exist
on that date. **That is staleness with a bound, not a defect** -- and deleting it would break a manifest
while buying nothing, because the bytes duplicate the canonical ones.

I verified every one of those claims independently before accepting them (digests, byte-identity, the zero
grep, both manifest pins).

## The rule

**Input discovery must be rooted at the declared directory, never a tree-wide glob or `find`.**

A pinned bundle holds copies of its inputs by design, and **because the copies are byte-identical there is
nothing in the bytes to flag the collision.** A tree-wide walk yields the same level twice, under two
paths, with identical content, and no signal that one of them is a frozen exhibit rather than a source.
The failure is silent in the worst way: the run succeeds, the artifact is well-formed, and a level is
simply missing from the set.

Corollaries:

1. **"Nothing reads it" is the test for whether a duplicate is live** -- and it is a measurement (a grep),
   not an inference from the directory's name or its date.
2. **A copy that reproduces canonical bytes is not stale-to-delete.** Its age is bounded to the pin, and
   the right action is to declare it read-only evidence, never to retire it.
3. **Where a walk is unavoidable, exclude the bundles explicitly** -- because the exclusion is the only
   place the distinction can live.

## Why this is worth a ruling rather than a note

It is the third face of one shape this week. A sha256 match is **common origin, not resemblance** (already
ruled). Two readers in two namespaces are not reading the same file (already ruled). And now: **the same
bytes under two paths are not two sources** -- and a discovery routine that treats them as two is not
merely wasteful, it is silently incomplete. In all three, the instrument was sound and the *reader's
model of the world* was wrong.
