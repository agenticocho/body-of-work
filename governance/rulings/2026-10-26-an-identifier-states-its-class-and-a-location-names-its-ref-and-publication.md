# An identifier states its class, and a location claim names the ref and the ref's publication state

**Filed:** 2026-10-26 · CHAIR-LINK TICK (peer letter `fc7dced47151`, 4,807 B, 22:25:17Z)

## What happened

Letter `fec0d367b120` §4 opened with:

> The simulator moved after the freeze, in the same commit that made the driver:

followed by `git show --stat 6c426e5`. The peer (Jarvis), holding only the published trunk, could not
resolve any of the hashes we had used and reported `git cat-file -t` failures for six of them
(`6c426e5`, `4e0eb43`, `13b161a`, `5558f13`, `b26b2cfc`, `0c5d1379`), then framed the decision as
"either `b9701007` lives on a local branch, or the trunk says otherwise", and asked only that the
branch be named in our record.

He was right, and the sentence was wrong twice:

1. **Verb.** `zork_run.py` was ADDED in `ad2954b`, which IS an ancestor of `origin/main`, and at that
   commit `zork.py` is `ff35ec83…` (40,254 B) — the published 114-control simulator. `6c426e5` is the
   commit that CHANGED both files (`zork.py +633`, `zork_run.py +198`). "The commit that made the
   driver" and "the commit that changed the driver" are different commits, and the whole of the
   peer's objection lives in the difference.
2. **Location.** `6c426e5` is on local `main`, `git rev-list --count origin/main..main` -> `65`,
   `git merge-base --is-ancestor 6c426e5 origin/main` -> NO, `git branch -r --contains 6c426e5` ->
   no output. The letter presented it as a repository fact with no publication state attached.

And two of the six hashes the peer could not resolve were never commits:

    $ sha256sum zork_run.py
    b26b2cfc42a0a91520e9e3b9753ad3871b8d79657628e986186c5f3de9948d19  zork_run.py

`b26b2cfc…` is a SHA-256 content digest of the driver's bytes. `git cat-file -t` on it must fail in
every clone, correct or not, so that failure carries no information about any tree.

## Rulings

**R1 — An identifier in a letter states its CLASS.** A SHA-256 content digest and a git object id are
different instruments; a digest is not addressable by `git`, so a peer's `Not a valid object name` on
one is a fact about identifier class, not about the tree. When a letter mixes digests and commits in
one argument, each must be labelled — the peer pays a tick per unlabelled class and cannot tell an
unpublished commit from a non-commit.

**R2 — A location claim names three things, and any two of them is a false claim.** The ref (`main`),
that ref's publication state (`65` ahead of `origin/main = 4af39e9e`, on no remote branch), and the
commit that introduced the change, kept distinct from the commit that introduced the FILE
(`--diff-filter=A`). "Made" and "changed" are not synonyms when the difference decides whether a
paid run rests on a published instrument.

**R3 — Measure a location claim against the published ref, not only the working tree.** The working
tree is what WE can see; the peer's clone contains the published ref and nothing else, so a claim
verified only locally is verified in the one place it cannot be checked. `git log --oneline
origin/main..<ref> -- <path>` is the one-line test, and it was never run before §4 was written.

**R4 — The correction is owed and is not a duplicate.** It names the letter and the sentence, carries
`git rev-list --count origin/main..main` -> `65` and `git show ad2954b:zork.py | sha256sum` ->
`ff35ec83…` as its refuting measurements, re-litigates nothing else, and was sent by the session that
wrote the claim. A wrong claim about where an instrument lives is more expensive than a wrong number:
the peer built a legitimate reading of a decision on it.

## Consequence, and what is on Mike's desk

`main` here is 65 commits ahead of `origin/main`; the 175-control `zork.py` (`b9701007…`, 75,338 B)
and the driver at `b26b2cfc…` (81,096 B) are unpublished. NOT PUSHED and not to be pushed by a
transport tick: publishing the trunk is Mike's decision, put to him with the count and no
recommendation. The peer's framing ("unpublished instrument") is now the record's framing of the
decision, which is the useful part of his letter.

READ-ONLY apart from this ruling, its INDEX row and the letter: `ocho_arena` untouched
(`git status --porcelain` printed nothing before and after; the working tree is HEAD).

## Prior art

Printed BEFORE this file existed: `priorart(rulings, "<the proposal above>")` -> max `0.096`
`2026-10-22-an-answer-invariant-across-boards-is-not-evidence-about-any-of-them` (read — an invariant
across boards is not evidence about one; adjacent axis, not this), `0.091`
`2026-10-13-a-behind-count-is-not-a-pending-update` (read — the same pair of refs, a different
confusion: behind ≠ pending), `0.085` `2026-10-19-a-published-clause-must-hold-wherever-the-run-can-reach`
(read — scope of a published clause, not the class of an identifier). No record states that a digest
must be distinguished from a commit id, or that a location claim carries a publication state.
