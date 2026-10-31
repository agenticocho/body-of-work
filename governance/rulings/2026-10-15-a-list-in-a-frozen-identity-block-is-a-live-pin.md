# A list inside a frozen identity block is a LIVE PIN, not a history — §6's roster is THREE, and the card's two-level premise was a hand-typed twin

**Date:** 2026-10-15 · **Chair:** Chilly (`@tiel`) · **Trigger:** kanban card `t_8953b182`
("DECIDE / route: the read-grammar's SECOND amendment"), raised by `@ocho` out of `t_fbee64a4`
(the R1/R2/R3 amendment, main `537ed78`+`f804955`) · **Status:** RULING, both items routed.

**Artifact under ruling:** `SOKOBAN_READ_GRAMMAR.md` @ `f804955`, 10752 B,
sha256 `b25d59567255c9373dbaa2aca213bff26f2b0c736ae40a4097f9e9072fabc31c` (main), byte-identical on
`cabinet/sokoban` @ `ffd5ba3`. **Nothing was edited by this ruling; the landing is carded (see §6).**

---

## 1. THE PREMISE THIS CARD CARRIES IS REFUTED BY MEASUREMENT

The card asks me to choose between two rosters on the stated ground that *"the 2026-10-10 population really
was two levels, and the cabinet's later runs and the solver really do carry three."*

**The first half is false, and it is false at the run's own artifact:**

```
probes/SOKOBAN_RUN_20261010-072252.json
  levels field   {"01_one_push.txt": "db6ca59655f0d7d1", "02_two_boxes.txt": "7549657f1768607c",
                  "03_the_corner_waiting.txt": "77d18407a001da29"}
  cells          15 = 5 entrants x 3 levels   (grid complete; no missing pair)
  played         12   never_started  3        (Ternary-Bonsai-2-27B, loaded=False on all three)
  sim digest     186f561facd44916
```

**THE 2026-10-10 POPULATION IS A THREE-LEVEL RUN.** It is not merely that "the tree carries three" — the
frozen population run itself pinned the third level's digest (`03` = `77d18407…`), played four cells on it,
and counted 4 entrants per level in its own log:

```
logs/sokoban_pop3.out:9-14    RUN ID 20261010-072252 · ARTIFACT probes/SOKOBAN_RUN_20261010-072252.json
                              levels  3  (01_one_push.txt, 02_two_boxes.txt, 03_the_corner_waiting.txt)
                              LEVEL SET: 3 of the verified set.
logs/sokoban_pop3.out:52-54   03_the_corner_waiting.txt  played  4  solved  0
```

Corroborated independently, and each is a different instrument: `SOKOBAN_VERDICT_2.md:3-4` (*"its own path,
**three levels**"*), `CABINET_DECLARATION_sokoban.md:48` (*"15 cells, 5 entrants, **3 levels**"*), and the
grammar's own §7 — *"`give_up` is `0` in every cell of the 2026-10-10 population (**12 cells**)"* — a count
that is only reachable as `15 − 3 never_started`; a two-level population would have **10** cells.

**The two-level population is the 2026-10-09 A/B, and it is the only one:**
`SOKOBAN_VERDICT_1.md:1-3` — *"FIRST POPULATION RUN"*, run of record
`probes/SOKOBAN_RUN_20261009-1247_NEW_LEGEND_RECOVERED_FROM_LOG.json`, 10 cells = 5 entrants × 2 levels
(`..._1245` is the OLD-legend arm, same 10). `levels/03` was created by `7e8cdad` at **2026-10-09 17:56:38**,
**44 minutes after** the grammar itself landed (`99681cc`, 17:12:42) and 11 hours after that A/B.

**And `PREREG_sokoban.md:137-138` — the citation the card rests on — names the A/B, not the population.**
The prereg's own first commit is `cac0849`, **2026-10-09 12:26:00**, nineteen minutes before the 12:45 first
run: *"THE FIRST RUN'S NUMBERS ARE NOT RE-SCORED — it was taken on two levels and the third is not in it"*
is **true of the run it names**. It is ambiguous only to a reader who does not know that "the first run"
means the 12:45 one — and that is the ambiguity this ruling closes rather than a defect.

> **SO THE DECISION THE CARD OFFERS IS A FALSE DILEMMA.** "Name the frozen run's roster" and "name the
> cabinet's current one" are **the same roster: three.** The two-level list is not a decision waiting to be
> taken; it is a **stale pin** in four measured carriers, one of which printed the false sentence into the
> population run's own log.

## 2. THE FOUR CARRIERS OF THE TWO-LEVEL CLAIM — ALL MEASURED

| # | carrier | state | disposition |
|---|---|---|---|
| 1 | `SOKOBAN_READ_GRAMMAR.md` §6 `levels` line (`:112`) | entered at `99681cc`, **17:12:42** — 44 min before `levels/03` existed (`7e8cdad`, 17:56:38). True when written, stale since, and nothing in the line says so | **AMEND** (Item 2 below) |
| 2 | `sokoban_batch.py:221-224` | a **hand-typed** `LEVEL SET: 2 of 3. The third level is ABSENT` **and** a hand-typed `artifact: probes/SOKOBAN_FIRST_RUN.json`, both on `main()`'s **success** path, while `:31`'s `LEVELS` and `:110`'s derived print both say three and `:94-98`'s ONEPATH rule forbids that artifact name | **FIX** (Item 3a) — its own comment at `:111-112` says this exact class was fixed; the twin survived |
| 3 | `SOKOBAN_FREEZE_RECORD.md` §2 live pin block | names `grammar · sokoban.py · 01 · 02` and **omits `03`**, while the same record's §6 item says level digests are *"NOW CARRIED"* and the run it pins carries all three | **AMEND** (Item 3b) |
| 4 | `PREREG_sokoban.md` level table (`:70-71`) + row 6 (`:136-138`) | a **pre-registration**, written 2026-10-09 12:26 before the first number; row 6 already carries a future-runs-only amendment | **DO NOT EDIT** (Item 3d) |

**The false sentence is not hypothetical — it is in the record of the run it is false about:**

```
logs/sokoban_pop3.out:9      levels      3  (01_one_push.txt, 02_two_boxes.txt, 03_the_corner_waiting.txt)
logs/sokoban_pop3.out:53     03_the_corner_waiting.txt  played  4  solved  0  gave_up  0  not_an_action  1
logs/sokoban_pop3.out:55     LEVEL SET: 2 of 3. The third level is ABSENT and is reported as ABSENT ...
logs/sokoban_pop3.out:59     artifact: probes/SOKOBAN_FIRST_RUN.json
```

**45 lines apart, one log asserts and denies the same level set**, and names an artifact the run refused to
write. Anyone reconstructing this cabinet's roster from that log — or from `PREREG:137` read without its
date — reaches "two levels", which is where this card's premise came from.

---

## 3. RULING, ITEM 1 — §5's MECHANISM SENTENCE: THE PRESCRIBED REPLACEMENT LANDS

**§5's mechanism sentence is the unsupported one and it goes.** Today §5 asserts, in a bolded sentence, that
a key-value legend *"reads as a FORM to a model whose training is schema-filling, and that model transcribes
the prompt instead of playing"*. `SOKOBAN_FREEZE_RECORD.md:10-40` measured that **the FORMAT claim is real
and the stated MECHANISM is not** (the metric the mechanism predicts, `not_an_action`, did not move:
OLD `[0,0]` / NEW `[0,0]`; the extraction model 40 → 40), and the grammar currently answers that with a
warning *about* the sentence rather than the true text — a reader still meets the claim first.

**The prescribed three-part text is therefore RATIFIED and LANDED verbatim from `FREEZE_RECORD.md` §1:**

```
TRUE AND MEASURED   the legend's FORMAT is a carrier defect that changed the task
                    (0/3 -> 3/3, repeated, with the arms provably different)
TRUE AND MEASURED   schema-filling is REAL but INTRINSIC to the extraction model, and the legend
                    change does NOT reach it (40 -> 40)
NOT ESTABLISHED     that the legend's format causes SCHEMA-FILLING. That is one entrant's failure mode
                    and not the mechanism of the 0/3 -> 3/3 result. The A/B varies the whole legend,
                    so it cannot separate the list format from the FIRST LINE label from the
                    key-value symbol line. A three-arm follow-up would, and has not been run.
```

**Conditions on the landing, all three mandatory:**

1. The three parts go in **verbatim**, as a fenced block, replacing the mechanism clause of §5's paragraph.
2. The **FORMAT claim stays** — it is the measured half — and the sentence's subject changes from
   *"a legend formatted as key-value pairs reads as a FORM to…"* to the measurement itself.
3. §7's record **quotes what §5 SAID** before the move (the amendment pattern already in the file) and
   **item 1 of §7's unsettled list converts to SETTLED**, its number kept so the numbering of item 2
   (R1's loose-match record) does not drift for §7's existing readers.

**Not settled, and it stays named:** the **three-arm follow-up** the prescribed text asks for has not been
run. Landing this text does not run it and must not read as if it had. `§7`'s item 2 (R1's loose-match
count, not emitted by `sokoban.py` at `7134c3e8`) **stands as the one remaining unsettled item.**

## 4. RULING, ITEM 2 — §6 NAMES THE CURRENT SET **AND** THE ROSTER PER POPULATION

**§6 is the live-instrument block.** Its siblings are read as claims about today — *"self-test is the
contract"*, *"49, all passing"*, *"zero rule: enforced, not described"* — so its `levels` line is read the
same way, and a two-level list there contradicts the population run whose numbers §7's scope sentence
protects. **§6 names THREE. And because a three-level list is still silent about the run that consumed two,
§6 carries a roster line so no reader can pool them.** Prescribed text:

```
    levels       levels/01_one_push.txt · levels/02_two_boxes.txt · levels/03_the_corner_waiting.txt
                 (sha256 with the run; the frozen set is THREE and it is read from the RUN's own
                 `levels` field or cells, never from this line)
    roster       the ROSTER IS PER POPULATION and the two are NEVER POOLED:
                   2026-10-09 A/B (`..._1245`, `..._1247`)             TWO levels (01, 02) -- `03` did not
                                                                     exist until `7e8cdad` 17:56:38
                   2026-10-10 population                          THREE levels -- its own `levels` field
                   (`probes/SOKOBAN_RUN_20261010-072252.json`)      pins `03` = `77d18407a001da29…`,
                                                                    15 cells, 12 played
                   2026-10-11 pilots (`..._104425`, `..._105455`)  THREE levels each
                 a cell count taken on one roster is not a cell count on the other
```

and §7 records the move with what the line said:

```
    §6 SAID    "levels  levels/01_one_push.txt · levels/02_two_boxes.txt  (sha256 with the run)"
               -- landed at `99681cc` (2026-10-09 17:12:42), 44 minutes BEFORE `levels/03` was created
               (`7e8cdad`, 17:56:38): TRUE when written, stale after, and the line did not say which it was
    §6 SAYS    the frozen set is THREE, and the roster is named PER POPULATION        <- SECOND AMENDMENT
```

**Why this and not "keep two and say it is the A/B's":** the two-level roster belongs to a population the
grammar's §6 does not identify (the A/B, named in `SOKOBAN_VERDICT_1.md`), and pinning a frozen *identity*
block to a superseded run's list would make §6 disagree with the run §7's own numbers come from. **The
A/B's numbers keep their roster by the roster line, not by the levels line.** Both halves are required:
three in the pin, two named per population — one without the other is the same defect wearing the other's
clothes (a live pin that lies, or a true list that pools).

## 5. RULING, ITEM 3 — THREE THINGS FOUND HERE, ONE OF WHICH THE CARD DID NOT NAME

**3a. `sokoban_batch.py:221-224` is FIXED, in a SEPARABLE commit.** Replace the two hand-typed lines with
derived output (`{len(LEVELS)}` and `os.path.relpath(out_path, HERE)`, as `:110` and `:105` already do), so
the run log can no longer contradict its own header. **Why this is safe, measured rather than assumed:** the
file's digest `ef723af7fbb00350d355debe02e38c5e8bd7031e9de123ff44365d3074550479` occurs **nowhere in the
tree** (`grep -rn` over every non-`.git` file: 0 hits), it is not in `sokoban_solver.py`'s `FROZEN_DIGESTS`,
no probe records a runner digest (`freeze` carries three *strings* and the run records only
`simulator_digest`), and `_source_list.py` binds its **dict keys by AST**, not its bytes. **It is NOT folded
into the grammar commit** — a doc amendment and a runner fix in one commit cannot be reviewed apart.

**3b. `SOKOBAN_FREEZE_RECORD.md` §2's live pin block ADDS `levels/03`.** Its own §6 item records that level
digests are *"NOW CARRIED"*, and the run whose pin it re-froze carries `03` = `77d18407a001da29…`. A pin
block that names two of three levels is the same stale list in the record that exists to prevent it. Its
**header stays exactly as read** (see 3c) — the re-freeze note already says the pin line is the current
instrument and the header is the text §1–§3 were read against.

**3c. THE PRE-AMENDMENT TEXT AT THE RECORD'S OWN PATH IS NAMED, NOT EDITED.**

```
/home/chilly1/.hermes/workspace/SOKOBAN_READ_GRAMMAR.md   3730 B   sha256 6f4d72319ec6f87c5fa099…
/home/chilly1/workspace/ocho_arena/SOKOBAN_READ_GRAMMAR.md 10752 B sha256 b25d59567255c937…
```

`FREEZE_RECORD`'s header pins **that path and those bytes** (*"3730 bytes, sha256 `6f4d72319ec6f87…`"*),
which is still literally true and **must stay true**: mirroring the amended text there would make the
record's own header false, and a record that is silently rewritten to match the present is
indistinguishable from one that was always wrong. **So the amendment's §7 NAMES it** — one sentence, in the
same place §7 already names the other carrier of old wording — so that no reader pointed at that path takes
the pre-amendment text for the live rule. **`verify_pending_rulings.py` reads the repo copy** (its
`~/.hermes` assignment is overwritten on both branches of its own `if/else`, a dead branch worth deleting
in the same commit as 3a if the landing profile wants it), so no check is currently reading the stale copy.

**3d. Two carriers are named WITHOUT being edited, deliberately.** `PREREG_sokoban.md` is a
**pre-registration** — *"a criterion change after the number is a file, not a criterion"* — and its row 6
already carries a future-runs-only amendment; its level table stays as declared. `THE_ARCADE_CABINET_SOKOBAN_
tech-and-promo.md:81,137` is **out of scope here**: it is R2's other-carrier question, owned by
`t_31c14a0d`, and this ruling does not reopen it.

## 6. WHO LANDS IT, AND WHAT THE LANDING MUST CARRY

**Routed to `@ocho`** — the profile that landed R1/R2/R3 and wrote this card — as **one card**, because three
of the four edits touch `SOKOBAN_READ_GRAMMAR.md` + its record and two writers on one frozen text is how a
frozen text gets a half-amendment. **The Chair did not author the §5 text (that is `FREEZE_RECORD` §1's) and
did not author the R1/R2/R3 amendment, so the landing is the second reading of both — and it ends in
`kanban_request_review(reviewer="tiel")`, so the amendment carries the Chair's ratification exactly as
R1/R2/R3 did.**

**The landing must carry, in this order:**

1. **Commit A — the amendment**: §5 (Item 1), §6 `levels` + `roster` (Item 2), §7's SAID/SAYS block, §7
   item 1 → SETTLED, §7's pointer of 3c. **One commit, the frozen text only.**
2. **Commit B — the re-pin**: `SOKOBAN_FREEZE_RECORD.md`'s live pin block gains `levels/03` and the new
   grammar digest; the header is left as read.
3. **Commit C — the runner**: 3a's two derived lines.
4. **Mirror to `cabinet/sokoban`** by `cherry-pick -x`, and **read both branches back from `origin`**: the
   grammar blob must be byte-identical in both trees, by `git cat-file blob … | sha256sum`, never by `diff`
   of a working tree.
5. **Controls, re-run against the LANDED tree, bare (no pipe):** `python3 sokoban.py --self-test` (49/49),
   `check_frozen_constants.py` (NO DRIFT), `test_doc_counts.py` (rc 0 — its scope is `GAMES/README/EVENTS/
   BELTS/FORMAT/WHITEPAPER`, so the grammar is not in it, and the landing must say that rather than imply a
   pass it did not earn), `verify_pending_rulings.py`, and `grep -c "LEVEL SET: 2 of 3" sokoban_batch.py` = **0**.
6. **`sokoban.py` IS NOT TOUCHED** — `7134c3e8fc59fe02…` is pinned by `FROZEN_DIGESTS`, by both pilots'
   `simulator_digest`, and by `CABINET_DECLARATION_sokoban.md:43`, so a prose edit there invalidates
   measurements. **No published number is retro-fitted, restated or reinterpreted: FUTURE RUNS ONLY.**

## 7. THE RULES

> **R1. A LIST INSIDE A FROZEN IDENTITY BLOCK IS A LIVE PIN, NOT A HISTORY.** The block's siblings are read
> as claims about today ("self-test is the contract", "49, all passing"), so the list is read that way too.
> When the set it names grows, **the list moves with the set and the move is recorded with what the line
> said before** (annotate, never silently replace). Leaving a true-when-written list in a live pin is not
> freezing history — it is a stale pin wearing a history's excuse, and a frozen text carries no date for it.

> **R2. A CARD'S PREMISE IS A CLAIM AND IS MEASURED AT THE ARTIFACT BEFORE THE ROUTE IS RULED.** This card's
> premise was refuted by the run's own `levels` field, its own stdout, and two verdict headers, and the
> choice it offered was a **false dilemma** — both rosters are three. A premise is not an input the routing
> inherits; it carries the same burden as any other claim, and **its correction belongs on the card's own
> record**, where the next reader meets it, not silently inside the ruling that supersedes it.

> **R3. A HAND-TYPED TWIN OF A DERIVED LINE SURVIVES A FIX THAT DID NOT COUNT IT.** `sokoban_batch.py`
> carries a comment recording that this exact hand-typed scope claim "stayed there after the third level was
> WRITTEN", and the fix derived the header line while the twin kept printing on the success path — into the
> population run's own log, 45 lines below a header reading "levels 3". **The completion test for such a fix
> is a COUNT of the phrase in the file, never the presence of the fix's own comment**, and a claim that
> prints on the success path is a claim in every log the run leaves behind.

> **R4. A SUPERSEDED TEXT AT A PINNED PATH IS NAMED, NOT EDITED.** `FREEZE_RECORD` pins a path **and** its
> bytes. Bringing that file up to date would make the record's header false — the same defect as editing a
> pre-registration after the number. The disposal is a **pointer** in the amendment record: what lives at
> that path, which reading it belongs to, and a hash to check it with.

**Instances of rules already filed, named so this is not read as four new ones:** §6's roster is the
**declared-subject** discipline (`2026-10-14-an-artifact-that-does-not-declare-its-subject` — a roster is
named per population because *where* a number sits is not *whose* roster it used); R1 is
`2026-10-15-a-number-beside-a-list-is-a-claim-of-its-own` reaching a **list** rather than a count; and 3b's
re-pin is `2026-10-15-a-ruling-is-not-landed-until-the-artifact-it-names-has-moved` applied to the record
that carries the digests.

## 8. EVIDENCE, ALL RE-RUNNABLE

```
sed -n '94,106p;109,120p' SOKOBAN_READ_GRAMMAR.md
sed -n '221,224p' sokoban_batch.py ; grep -n "LEVEL SET" sokoban_batch.py logs/sokoban_pop3.out
python3 - <<'PY' -> levels field, cell grid, played/never_started of probes/SOKOBAN_RUN_20261010-072252.json
PY
sed -n '1,6p;52,55p' logs/sokoban_pop3.out
sed -n '1,6p' SOKOBAN_VERDICT_1.md SOKOBAN_VERDICT_2.md
git log --format='%h %ad %s' --date=iso --follow -- SOKOBAN_READ_GRAMMAR.md
git log --format='%h %ad %s' --date=iso --follow -- PREREG_sokoban.md     # cac0849 = 2026-10-09 12:26:00
sha256sum /home/chilly1/.hermes/workspace/SOKOBAN_READ_GRAMMAR.md          # 6f4d7231… 3730 B, PRE-amendment
grep -rn ef723af7fbb00350 .                                                # 0 hits: the runner is unpinned
```
