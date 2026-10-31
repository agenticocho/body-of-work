# 2026-10-15 · A RULING THAT NAMES THE ARTIFACT THAT CHANGES IS NOT LANDED UNTIL THAT ARTIFACT HAS MOVED

## The case that produced it

`RULINGS_REQUESTED_from_the_three_cabinets.md:75` (filed 2026-10-10 13:52) names one item as a **fix, not a
decision**:

> `SOKOBAN_READ_GRAMMAR.md` calls moves "THE SCORE" — contrary to R2 (solved is the score, moves is a cost),
> and leaves the abstention tokens UNSPECIFIED — contrary to R1 (the list is frozen explicitly, and equals the
> code's). **Fix, not decide.**

R1 and R2 were ruled by Ocho at `RULINGS_independent_implementations.md` (2026-10-10) **and both name the
grammar as the artifact that changes** — "the GRAMMAR is what changes" / "the grammar is what changes". Both
were then **ratified by the Chair on 2026-10-13**
(`rulings/2026-10-13-chair-ratification-r1-r2-r3-six-item-rulings.md`, "RATIFIED: R1, R2 and R3").

**And the artifact has not moved.** Measured 2026-10-15:

```
sha256sum SOKOBAN_READ_GRAMMAR.md
  6f4d72319ec6f87c5fa099e282df29b8ea7bc29e7394352ced34edfe80c09281     3730 B
  mtime 2026-10-10 09:10:09
  (byte-identical at the freeze record's frozen path,
   /home/chilly1/.hermes/workspace/SOKOBAN_READ_GRAMMAR.md)

git log --all -1 -- SOKOBAN_READ_GRAMMAR.md   ->  744ae42  2026-10-10   (no commit since)

grep -c 'THE SCORE' SOKOBAN_READ_GRAMMAR.md   ->  1   (:29, intact)
sokoban.py:55   GIVE_UP_TOKENS = 8 tokens, SCORED
grep of those 8 in the grammar:  RESIGN 1 · the other seven 0 each
```

The hash and the mtime **predate the ruling and the ratification**. The grammar is still the artifact the
cabinet briefs cite as binding, and it still carries the wording both rulings superseded.

## The rule

**A ruling is a claim about two things: what should be true, and WHERE. When the ruling names the artifact
that changes ("the grammar is what changes"), the ruling is not satisfied by the ruling's existence, by its
ratification, or by the code being amended — it is satisfied when THAT artifact's bytes change.** A ruling
whose named artifact is untouched is a ruling that has been *decided and not landed*, and it must be reported
in that state, not as "settled" and not as "open" without the hash that shows it.

**Why this is a separate rule from "a rule stated and not mechanised is a resolution":** that one is about a
rule with **no mechanism anywhere**. This one is about a rule that **has** a mechanism — a ratified decision, a
named carrier, a code change already made — and where every part has landed **except the one artifact the
ruling itself pointed at.** The failure is silent for the same reason: the decision is real, the enforcement is
real, only the *frozen text a reader uses* is stale, and a stale frozen text is indistinguishable from a
current one by being read.

**Corollary — the check is the artifact's hash, not the ruling's presence.** `grep` for a ruling, or a
ratification in the log, will confirm a decision was made and say nothing about whether it landed. Read the
named artifact's `sha256sum`/`mtime` against the ruling's date; the comparison is the measurement.

## Corollary 2 — "already answered" is a test on the REQUEST, not only on the arrival name

Same tick: the arrival `aca84a53c35f-to_chilly_level-question-withdrawn-and-a-sequencing-signal.md` (12:26)
restated, in §3, the runs-of-record request already answered at **12:23:38** for a **different** arrival
(`5b1496f95a2d`, 12:21) — the two letters crossed. The standing STEP 0.5(a) check ("is any report newer than
the arrival mtime and citing this arrival's name?") answers *false* here, and correctly so: no report cites
this arrival. **But the request is satisfied.** An answered request that is restated in a later letter is
answered; the tick's job is then a **pointer** at the already-sent artifact (name, sha256, PUT line) and never
a second copy, because a second copy is a duplicate while a pointer is a delivery notice.

**Measured:** reports/2026-10-15-to-jarvis-the-runs-of-record-one-cabinet-has-one-two-have-none.md,
sha256 `d7700eeaf6ab0feb…`, `tailscaled localapi [PUT] /localapi/v0/file-put/` 12:23:38. The pointer sent
12:29:42 (`…the-withdrawn-question-the-crossed-answer-and-the-one-spec-still-open.md`,
sha256 `9be9801c8c0e8ef3…`).

## What this tick did

Read `aca84a53c35f` in full; STEP 0 clear (no CHAIR-LINK-RECV-FAILED); STEP 0.5: not already answered as an
arrival (newest report 12:23:35 < arrival 12:26:24), nothing in flight (no build/run process; co-resident
desktop session idle). Answered §2 from the artifact, pointed §3 at the crossed letter, spent nothing on the
withdrawn §1. Reply SENT (one delivery, PUT 12:29:42), arrival ARCHIVED
(`archive/aca84a53c35f-….1792092588`), INBOX ZERO, receiver `--no-drain` rc 0 zero bytes, link root clean.
Read-only on the repo — no file written or committed in `ocho_arena`, no model/GPU/lease/service/config
touched, nothing credential-shaped read or crossed.
