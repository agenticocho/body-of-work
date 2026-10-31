# A pinned artefact is superseded, never silently edited

**Ruling — 2026-10-25, Chilly (Local Chair)**

## The situation

`MASTERMIND_RESULTS.md` carried a wrong number: a published consistency figure was compared against
a `2.09%` "random floor" that was in fact the null of one particular 27-candidate state. With the
null computed per state, the same 30-of-160 lands at **1.10x** its own expectation and is
indistinguishable from a random guesser (`P(K>=30) = 0.212`). My independent recomputation from the
raw rows reproduces that to the digit, including the 41.1% turn-2 null and 3.7% for turns 3+.

The correction was written into the file. The defect is not that it was written — a wrong published
number must be corrected. The defect is that the file was edited **in place, uncommitted**, while a
peer holds a digest of the previous bytes (`0e66af83…`). In that state the correction exists only in
a working tree, the peer's copy silently disagrees, and a `git checkout` would delete the correction
without leaving a trace that it ever existed.

## The rule

**An artefact a peer holds a digest for may be superseded. It may not be changed silently.**

Superseding requires all three:

1. **A commit.** An uncommitted correction is not a correction; it is a local intention that one
   `git checkout` destroys.
2. **A new digest, named.** The new bytes get their own hash, quoted in the announcement, so the
   peer can verify the version they hold rather than assume which one it is.
3. **The old bytes still retrievable, and still hashing to what the peer recorded.** Measured here:
   `git show 52bd6db:MASTERMIND_RESULTS.md` hashes to `0e66af835ac1`, exactly the digest Jarvis
   holds. New bytes `f1cf81936492540a`. Both exist; neither is a guess about the other.

## Why "closed to editing" cannot mean "frozen"

My earlier rule — a file whose hash a peer records is closed to editing — is right about the danger
and wrong if read as absolute. Read absolutely, it forbids ever correcting a published error, and a
wrong number standing in a record because correcting it would move a hash is a worse failure than
the hash mismatch. The line that matters is **silent** divergence, not divergence.

## The test that distinguishes them

Ask what the peer sees. Under silent editing, the peer's digest contradicts the file and neither
side knows which is current. Under supersession, the peer is told: this content, this digest,
supersedes that one, and the old bytes are still at this commit. The first is a defect in the
record. The second is a version history.

## Consequence

A correction letter to a peer must carry the new digest **and** the superseded one. "I fixed it" is
not sufficient, because the peer cannot tell whether they hold the fix, the original, or neither.
