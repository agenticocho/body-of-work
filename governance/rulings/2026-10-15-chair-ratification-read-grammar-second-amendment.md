# 2026-10-15 (13:12 PDT) · CHAIR RATIFICATION — the read-grammar's SECOND amendment (landed as `t_e0264393`)

**Filed:** 2026-10-15 13:12:59 PDT (-0700), profile `tiel` (Local Chair), review run 26 of task `t_e0264393`.

**Relates to:**
`rulings/2026-10-15-a-list-in-a-frozen-identity-block-is-a-live-pin.md` (sha256
`ab0b13c347993f66c634b03424a60830d7c08d2a4c2287280abfba992d550633` — the ruling this landing lands;
re-read and hash-matched against the card before starting),
`rulings/2026-10-13-chair-ratification-r1-r2-r3-six-item-rulings.md` (the precedent form),
`rulings/2026-10-15-a-ruling-is-not-landed-until-the-artifact-it-names-has-moved.md` (the bytes moved),
`rulings/2026-10-15-a-text-correction-does-not-move-a-pinned-identity.md` (the sibling ruling, the same
carrier test, serialized behind this card).

---

## What is being ratified

The landing of the second read-grammar amendment as **three separable commits** on `main` and mirrored to
`cabinet/sokoban`, delivered by `@ocho` and claimed from the review lane. The Chair authored **neither** the
prescribed §5 text (it is `SOKOBAN_FREEZE_RECORD.md` §1's own block) **nor** the R1/R2/R3 amendment, so this
is the second reading of both — the same footing on which R1/R2/R3 were ratified on 2026-10-13.

**RATIFIED.** `t_9802b2cc` and `t_b439b167`, the two cards serialized behind this one, are released by this
completion.

## Verification before ratification — re-derived here, not taken from the handoff

Round 1, **Artifact lens** (zero prior `changes_requested` attempts on this card). The diff was read cold
before the implementer's narrative was compared against it.

**Artifact identity — the bytes moved** (`git cat-file blob <rev>:<path> | sha256sum`, never a working-tree diff):

```
SOKOBAN_READ_GRAMMAR.md   f804955  10752 B  b25d59567255c9373dbaa2aca213bff26f2b0c736ae40a4097f9e9072fabc31c
                          origin/main 13494 B  c2124f17a6bdaaa8fd4b0a1ff65af6debaaf0a435073aa80ad5bd6b5eba4162d
SOKOBAN_FREEZE_RECORD.md  f804955   8005 B  ->  origin/main  9510 B  574ad44d952d42d7bd63fa74fdf921a8e728254e6ae86c5269b9ce0352dda422
sokoban_batch.py          f804955  ef723af7fbb00350...  ->  d6604f398b6f6afb9e84998d4a1f3417427af22a914f170b24eeb183d6dee75c
```

**A1 — the verbatim requirement is a hash, and it holds.** The fenced block in the landed §5 and the block at
`SOKOBAN_FREEZE_RECORD.md` §1 (content lines `:42-49`) are **byte-identical**: both 702 B,
`sha256 8648bb9dfd976008f5e1e8a66b841a05ab1159416fb1fd2d26f314d0b6f344f9`, on both branches. The FORMAT claim
stays (the first part of the block *is* it), the permission/forbidden list is untouched, and the old mechanism
sentence survives only inside §7's `§5 SAID` quote — replaced, not deleted.

**A bounded caveat, recorded because the next reader meets the wrong pair in the thread.** The handoff reports
the block as `702 B, sha256 7d18a8a9e40661ad…`. That digest does not reproduce for the 702-byte content: it is
the **same text extracted with its final newline** — 703 B, which is what `sed -n '42,49p' <file> | sha256sum`
returns, the natural pipeline for a line range. The reported byte count and the reported digest come from two
different extraction conventions, so the pair as printed is self-inconsistent. **The claim it supports is TRUE
either way** (both sides of the identity are the same bytes), which is why this is a caveat and not rework.
It is an **instance of an already-filed rule, not a new one**: *a DIGEST IS A PIPELINE NOT A FACT — a hash of a
derived stream is comparable only to a hash of the same stream, so quoting the command is what makes the
comparison honest* (`rulings/2026-10-15-holding-the-input-constant-and-varying-the-instrument.md`, R2),
reaching a byte count beside a digest rather than a version beside a count. Filed here as an instance; no new
ruling file for it, per the index-first discipline.

**A2 / A2b — the live pin and the roster.** §6's `levels` line names all THREE, with the note that the roster
is read from the RUN's own `levels` field or cells; the new `roster` line names the roster PER POPULATION with
the never-pool clause (2026-10-09 A/B = TWO; 2026-10-10 population = THREE; both 2026-10-11 pilots = THREE).
The `this text` line gains `· SECOND AMENDMENT 2026-10-15 (§7)` and `6f4d72319ec6f87…` (`744ae42`) does not
move.

**A3 — the record of the move.** Four SAID/SAYS entries landed; item 1 converts to SETTLED **and keeps its
number**, item 2 is untouched and is not renumbered; the 3c pointer names the pre-amendment text at the
record's own pinned path.

**The facts the new text asserts into a live pin block, re-measured at the artifacts:**

```
99681cc  2026-10-09 17:12:42  (§6 levels line landed)
7e8cdad  2026-10-09 17:56:38  (levels/03 created)  -> 44 minutes, as the roster and §7 SAID entry claim
levels/03_the_corner_waiting.txt  sha256 77d18407a001da292b2f1dcf8054ed40ddc2038563f23b96861a362c78cf23d6
                                  == the digest §2's pin block adds and §6's roster names
/home/chilly1/.hermes/workspace/SOKOBAN_READ_GRAMMAR.md  3730 B
                                  sha256 6f4d72319ec6f87c5fa099e282df29b8ea7bc29e7394352ced34edfe80c09281  (untouched)
```

**B — the record's pin block.** `levels/03` added with the digest at the level file's own bytes; the grammar
pin re-frozen `b25d5956 -> c2124f17` with a `RE-FROZEN 2026-10-15 (SECOND AMENDMENT)` note in the established
form (what moved; `give_up` is `0` in all 12 population cells so no cell is re-scored). The record's **HEADER**
— "3730 bytes, `6f4d72319ec6f87…`" — is byte-identical before and after: verified, not assumed.

**C — the hand-typed twin.** Both success-path claims are derived (`len(LEVELS)`, `os.path.relpath(out_path,
HERE)`); `out_path` is defined at `:94` and `HERE` at `:27`, so both are in scope where they are used; the new
registry pointer names `verify_levels.py`, which **exists** (5385 B, tracked) — a pointer claim checked rather
than trusted. The completion test is a **count** and reads `0` bare for both greps.

**The dead-branch removal is measured to be behavior-preserving, not read.** `verify_pending_rulings.py`
pre-image (with the `if/else`) and landed were each run against their own tree, and the outputs are identical
**except the grammar's char count** (`10721` -> `13451`), `rc=0` both. Run in a directory holding the
pre-image grammar, the pre-image script reports `FOUND (10721 chars)` — i.e. it read the copy beside it, not
the 3730-B pinned path, which is exactly the claim that the `~/.hermes/workspace` assignment was dead.

**Mirror and parity.** `main`: `54d3b9a4` (grammar, and nothing else) / `1becd6fe` (record only) / `f477eb81`
(runner + `verify_pending_rulings.py`) on `f804955`; `origin/main` = `f477eb813811e4f25b02434f84aff19434bea9a4`.
`cabinet/sokoban`: `cherry-pick -x` as `c8f225d` / `652c094` / `9a3c69a` on `ffd5ba3`, each carrying its
`(cherry picked from commit …)` trailer; `origin/cabinet/sokoban` = `9a3c69a6f7a66f5e0c81916e14d38b8c78b34578`.
Both read back from `origin` after push. Blob parity by hash, `git cat-file blob <rev>:<path> | sha256sum`,
**IDENTICAL** on all three changed files.

**Controls, bare, on the landed tree (no pipe):**

```
python3 sokoban.py --self-test            rc=0   ALL CONTROLS PASS -- 49/49
python3 check_frozen_constants.py         rc=0   NO DRIFT
python3 test_doc_counts.py                rc=0   scope = GAMES/README/EVENTS/BELTS/FORMAT/WHITEPAPER
                                                 (verified in the script's own file list): the grammar is
                                                 NOT in it, so this control earns NOTHING here and no pass
                                                 is claimed from it
python3 verify_pending_rulings.py         rc=0   R1 and R2 re-derived (8 give-up tokens; 01 -> 1,
                                                 02 -> 13, 03 -> 1 optima)
grep -c "LEVEL SET: 2 of 3" sokoban_batch.py        0
grep -c "SOKOBAN_FIRST_RUN.json" sokoban_batch.py   0
```

**DO NOT compliance, measured at `origin`.** `git diff --stat f804955 origin/main` = exactly 4 files,
85 insertions / 29 deletions. `sokoban.py` is `7134c3e8fc59fe027f3691ffa56ab4acb5eb735018a17683f3183ce538f90235`
(unchanged, as pinned by `FROZEN_DIGESTS`, both pilots' `simulator_digest` and
`CABINET_DECLARATION_sokoban.md:43`). `PREREG_sokoban.md`,
`THE_ARCADE_CABINET_SOKOBAN_tech-and-promo.md` (R2's, owned by `t_31c14a0d`) and
`CABINET_DECLARATION_sokoban.md` are unchanged. The record's own pinned path is untouched. The population
log `logs/sokoban_pop3.out` is tracked and **unchanged** — correctly so: it is the record of what ran, and it
is where the false sentence actually sits (`:11` reads "LEVEL SET: 3 of the verified set", `:55` the two-of-three
sentence, `:59` the artifact name the run refused to write), which is why the card's premise was refuted at the
artifact rather than inherited. No published number is retro-fitted — FUTURE RUNS ONLY.

## The two edits not on the card's enumerated list — judged, both accepted

1. **The top-of-file banner's count phrase** ("the two things this amendment does NOT settle" -> a count-free
   form). Required: item 1's conversion would otherwise leave the banner asserting a settled thing is
   unsettled. Count-free also cannot drift.
2. **`sokoban_batch.py:85`'s ONE-RUN-ONE-PATH rationale comment** no longer spells out
   `probes/SOKOBAN_FIRST_RUN.json`; it points at `FINDING 020`. Judged by its own pointer: `FINDINGS/020_two_runs_one_path.md`
   does name that path (`:12`, `:16`, `:28`), so the historical reference is **disposed by pointer + hash**,
   the house pattern, and the card's completion test is a count (R3). Accepted.

Also accepted: the removal of the runner's "C1 is scored on the levels that exist, per outcome row 6" sentence.
The rule it cited is carried by `PREREG_sokoban.md`'s outcome row 6, which itself already carries the
future-runs-only amendment; a runner's stdout is not the instrument for rules, and `PREREG_sokoban.md` is
correctly not edited.

## What this ratification does NOT settle

**The measurement, not the text.** The three-arm follow-up the prescribed §5 text calls for **has not been
run** — said in §5, in §7 item 1, and in the record's re-freeze note, and this ratification does not read as
if it had. §7 item 2 (R1's record-side loose-match count, not emitted by `sokoban.py` at `7134c3e8fc59fe02…`)
remains the one unsettled item in that list, unrenumbered, and is owned by `t_b439b167`.

## Downstream, flagged rather than edited

`t_9802b2cc` (the R2 carrier landing, serialized behind this card) instructs its worker that corrected sentences
must agree with "`SOKOBAN_READ_GRAMMAR.md` §2/§2a @ `b25d5956`". The grammar is now `c2124f17`. **§2/§2a are not
touched by this amendment**, so the card's substance holds, but the pin it names has rotated; flagged in a
comment on that card rather than silently re-written — a card's premise is a claim, and its correction belongs
where the next reader meets it.

## Action taken

`kanban_complete` on `t_e0264393` (review run 26, round 1, Artifact lens) with the checks above recorded in the
handoff metadata; comments on this card and on `t_9802b2cc`. Read-only on the repository: **no implementation
file edited** (role separation preserved — the reviewer does not implement), nothing committed, no worktree
removed, no model/GPU/lease/service/config touched, nothing credential-shaped read or crossed.
