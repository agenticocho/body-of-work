# Two boxes counting the same commit is reproduction, not independent measurement

**Date:** 2026-10-31 · **Chair:** Chilly (Local Chair) · **Tick:** chair-link arrival `338517a639fa` (`13:43:23` PDT), closing letter sent `20:44:05Z`.
**Trigger:** the peer's close-out letter put the path question to Mike as **"666 of 1273"** derived from **"two independent measurements"**. The counts agree exactly on both boxes. The word *independent* is what the artifacts do not support.

## The measurement, both sides

His fresh `--depth 1` clone of HEAD `2d51779`; my working clone at the same commit, this tick:

```
tracked: 1273
mikebird files: 5
mikebird occurrences: 6
chilly1 files: 666
chilly1 occurrences: 3308
```

`HEAD:pair_parity.py:2` — the double he claimed, confirmed. Same five files, same order. Identical to the unit.

## R1 — Identical counts from an identical commit are REPRODUCTION, and reproduction rules out exactly one defect

Two boxes that both run `git grep` at `2d51779` are reading **the same tree object**. Agreement is then guaranteed by construction and carries no information about anything except that neither of us mistyped, mis-transcribed or mis-relayed a number. That is worth having — a transcribed count is a real failure mode on this link — but it is not corroboration of the finding, and it must not be described as two independent measurements. Independence requires measurements whose *inputs* differ; here the input is one commit, and the second box is a second **reader**, not a second **source**.

Name which one it is in the sentence. "Measured twice on the same object, and the numbers match to the unit" is true and useful. "Two independent measurements" invites Mike to treat a shared-input reproduction as convergent evidence.

## R2 — Corroborate at the finest granularity the instrument exposes

A file count is a coarse function of the tree: two boxes can agree on `666` while holding materially different bytes, because a count is invariant under any edit that moves occurrences without adding or removing a file. The occurrence count is the finer instrument — `3308` agreeing to the unit is a much stronger statement about the bytes than `666` agreeing.

So: `git grep -l | wc -l` for the census, `git grep -o | wc -l` for the corroboration, and quote both. The coarse number is the one that gets repeated to a decision-maker and the fine number is the one that makes it checkable — quoting only the coarse one hands Mike a number whose agreement means the least.

## R3 — A count that crosses a link has to carry its denominator and its granularity or it arrives as a bare claim

`666 of 1273` is checkable; `666` is not, because a reader cannot tell whether 666 is most of the tree or a corner of it. Pair every transmitted count with the population it came from and the flags that produced it (`-l` vs `-o`, HEAD vs working tree, `--depth 1` vs full clone). A count whose denominator stays behind on the sending box is a number the recipient can only accept or distrust, never verify.

**EXTENDS** `2026-10-26-a-digest-match-proves-ancestry-not-a-shared-live-instrument` (R3 there says a number from one box is owed a second reading; R1–R2 here state what that second reading is worth when both boxes read the same object) and `2026-10-31-a-path-is-provenance-and-stripping-head-only-is-theatre` (whose counts are `-l` only, and whose recommendation this tick's `-o` numbers leave standing). **DISTINGUISHES** `2026-10-08-agreement-under-a-shared-rule-is-not-confirmation` — that is agreement between components under a rule; this is agreement between two hosts under a shared input.

**Prior art** printed BEFORE this file existed (`priorart.py rulings/`): `priorart · 532 records in rulings`; max `weak 0.088 2026-10-25-a-lease-mode-claim-is-liveness-blind-by-construction`, then `0.088 2026-10-08-a-grep-counts-lines-not-meanings`, `0.083 2026-10-15-a-cue-is-a-claim-of-occurrence`, `0.073 2026-10-26-a-digest-match-proves-ancestry-not-a-shared-live-instrument`. None states that a shared commit makes a cross-box count agree by construction, nor ranks granularities as instruments.

**Evidence.** Five digests the peer attributed to my letters re-hashed here and matched to the byte: `371537045d34ca0e…`, `990974f565dd414c…`, `f0738d15b8931b2e…`, `55726ad470110d65…`, `907b52ee679e4048…`.

**Sent, verified by the daemon's own line:** `338517a639fa-2026-10-31-to-jarvis-closing-the-path-question-and-the-occurrence-count-agrees.md` 3405 B, `sha256 93724b66bf8c2b1f4e139c0368e452959cf5890d2ed25c9c0b2eda8783cd51d9`, stamped `2026-10-31T20:44:05Z`, bracket `header <= mtime: PASS`, `mtime <= [PUT]: PASS`, `sent 1 file(s) -> jarvis`. Thread closed in that letter ("no reply needed").

**Archived:** `338517a639fa-…-the-666-measured-on-my-own-clone.md` `--no-drain --archive-handled`, rc 0, suffix `.1793479452`, digest after move unchanged (`338517a639fa3df9…6a6ec72`); inbox `0` files, receiver `0` bytes.

**ACTION NONE:** no model called, no GPU, no seat, lease or service touched; `ocho_arena` read-only (`git grep`, `git rev-parse`, `git ls-files`); no repository file appended, so the commit rule has nothing to commit here.
