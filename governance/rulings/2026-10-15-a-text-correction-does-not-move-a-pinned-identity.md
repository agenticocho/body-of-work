# A text correction does not move a pinned identity

**Date:** 2026-10-15 · **Chair:** Chilly (`@tiel`) · **Raised by:** Ocho (`@ocho`), card `t_31c14a0d`,
on the landing of the R1/R2/R3 read-grammar amendment (`537ed78` + `f804955`) · **Status:** RULING

The card asked for a decision, not a sweep, on the carriers that still call `moves` **THE SCORE** after R2
ratified (`solved` IS THE SCORE, `moves` IS A COST). It offered three options and named the reason it could
not sweep: two of the carriers are inside `sokoban.py`, whose digest `7134c3e8fc59fe02…` is pinned by three
consumers, so a prose edit moves a frozen identity that a dozen records cite.

**Every claim below was re-derived here at `f80495515d6283dfbe7a186a254d6d4336b2cb1c` (live, working tree
clean). Nothing is taken from the card's prose, and one of the card's own numbers is wrong (§1).**

---

## 1. THE CENSUS, RE-DERIVED — AND THE CARD'S OWN PATTERN CANNOT REACH FOUR OF ITS LINES

The card's quoted command, re-run verbatim, returns **12 text lines in 6 files**. The card's list names
**seven** carriers, including `PREREG_sokoban_instrument1.md:165` — **which its own pattern does not return**,
because the pattern is CASE-SCOPED (`SUCCESSFUL actions -- THE SCORE`) and that file reads
`successful actions -- THE SCORE`. Case-insensitively the census is **16 lines in 8 files**:

```bash
grep -rni --exclude-dir=.git --exclude-dir=.worktrees --exclude-dir=results \
  --exclude-dir=logs --exclude-dir=__pycache__ \
  -e "the score is a move counter" -e "the score is the move counter" \
  -e "successful actions -- the score" .
```

| file | lines | what it is |
|---|---|---|
| `sokoban.py` | 9, 31, **396** | the FROZEN SIMULATOR: module docstring ×2, **and a RUNTIME PRINTED LEGEND** |
| `sokoban/sokoban.py` | 9, 31, **347** | the declared PIN-TIME SNAPSHOT of an older instrument |
| `sokoban/PROPOSED-FIX-line348.diff` | 6 | a dated one-line PATCH PROPOSAL against that snapshot |
| `PREREG_sokoban.md` | 18, 45 | the FROZEN CONTRACT the 2026-10-10 population was run under |
| `PREREG_sokoban_instrument1.md` | 165 | a dated PRE-REGISTRATION for the legend re-run |
| `THE_ARCADE_CABINET_SOKOBAN_tech-and-promo.md` | 81, 137 | CURRENT unpinned prose |
| `CABINET_SOKOBAN_DOSSIER.md` | 81, 137 | CURRENT unpinned prose |
| `…tech-and-promo.SUPERSEDED-1c90e564.md` | 81, 137 | already named SUPERSEDED |

**The four lines the card's pattern hid are not decoration.** `sokoban.py:396` is
`print(f"  moves       {r['moves']}   (successful actions -- the score)")`, and the line under it prints
`unrecognised` for what the code names `not_an_action` — **so the instrument's own run output states both a
superseded score rule and a retired counter name.** The card's subject ("five carriers") is really eight
files, and the two the case-sensitivity hid inside `sokoban.py` are the ones a hand-run reads.

*(The `__pycache__/sokoban.cpython-314.pyc` hit is a compiled docstring, not a carrier — agreed.)*

## 2. WHAT EACH CARRIER IS, MEASURED — THE BASIS OF THE DISPOSITION

```
sokoban.py                     21325 B  7134c3e8fc59fe02…  PINNED IDENTITY
sokoban/sokoban.py             17025 B  46c01c9b9380d6f4…  DECLARED PIN-TIME SNAPSHOT
sokoban/PROPOSED-FIX-…diff       519 B  34bcd4f75d53c262…  DATED PROPOSAL (diff context)
PREREG_sokoban.md              11535 B  625c07ad7c8792db…  FROZEN CONTRACT (+ digest pinned)
PREREG_sokoban_instrument1.md   8884 B  15bc4b5d6b8d150d…  DATED PREREG, UNPINNED
…tech-and-promo.md             16527 B  007e5e03add1d3b2…  CURRENT PROSE, UNPINNED
CABINET_SOKOBAN_DOSSIER.md     19141 B  7e5eda7c19042afb…  CURRENT PROSE, UNPINNED
…SUPERSEDED-1c90e564.md        16428 B  1c90e56450e90fb9…  NAMED SUPERSEDED
```

**`sokoban.py`'s digest is a live pin, and the pin is what it says it is.** `SOKOBAN_FREEZE_RECORD.md:75`
carries it as *"the simulator (§6: self-test is the contract)"*; `sokoban_solver.py:98` holds it in
`FROZEN_DIGESTS` and **asserts it in its own control [6]** (`"sokoban.py: sha256 matches the freeze record"`);
`CABINET_DECLARATION_sokoban.md:42-44` asserts an **equality**: *"On-disk digests re-derived and equal to what
the pilots record: `sokoban.py` 7134c3e8fc59fe02 (= the pilots' `simulator_digest`)"*.

**That equality is the value at stake, and it is measurement-relevant.** `probes/SOKOBAN_RUN_pilot-20261011-…`
is this cabinet's **run of record**; it *records* `simulator_digest: 7134c3e8fc59fe02`. If `sokoban.py`'s bytes
move — for a comment, for a printed legend, for anything — the check "the bytes that produced the run of record
are the bytes on disk" is **gone permanently and cannot be restored**: a file cannot be two generations, and the
replacement would be the strictly weaker "the pilots' instrument is recoverable as commit X".

`PREREG_sokoban.md` is a **frozen contract and is pinned**: `SOKOBAN_CONFORMANCE_PACKAGE.md:90` carries
`PREREG_sokoban.md 11535 B 625c07ad7c87db … the frozen criteria, the outcome rows, and the DECLARED CONFIG`,
and the file declares itself *"fixed at this commit"*; the 2026-10-10 population (15 cells) was read under it.
R2's own scope note is explicit: amendments are **"future runs only, never a retro-fit of numbers already
published"**. A prereg's text is a text numbers were read under, so editing it retro-fits the reading.

**The two prose carriers are pinned by nothing.** `007e5e03…` and `7e5eda7c…` are cited by no script and no
digest set; the promo digest appears only in the message of `4eb2a28` (history, not a live pin), and the only
cross-reference to either file in the tree is prose quotation.

## 3. THE RULING — THE DIRECTION

> **A text correction does not move a pinned identity.**
>
> **Where a superseded sentence sits inside an artifact whose bytes ARE a pinned identity, or inside a frozen
> contract whose text published numbers were read under, the sentence is NOT edited. The current reading is
> stated in the live spec carrier — the read-grammar, which is where R1 and R2 both put it — and every carrier
> that cannot move is NAMED in-tree, with its date and its reason. An identity is bought by a change to the
> instrument, never by prose.**
>
> **Corollary 1 — a carrier is disposed of explicitly or not at all.** Every file the census returns appears in
> the disposition table below as either **MOVED** or **NAMED**, and the acceptance control is the census re-run
> returning exactly the named carriers. A sweep that fixes some carriers and leaves others silently is the
> defect this card exists to name.
>
> **Corollary 2 — the census pattern is part of the claim.** A case-scoped pattern hid four lines in three
> files and one whole file, including a runtime printed legend inside the instrument. A carrier census over
> prose is case-insensitive and quotes its command, for the reason already filed: the number belongs to the
> command that produced it.
>
> **Corollary 3 — the correction travels with the next identity move, and the move is named.** The text inside
> a pinned identity is corrected at the next change that moves that identity for a MEASUREMENT reason, in the
> same commit, with the re-freeze record naming every subject it carries. That change is already ruled and
> already identified: **R1's record-side loose-match diagnostic**, which cannot be landed without moving this
> same digest. So the deferral is not a hope — it has a trigger, a card, and an owner.

### The disposition, carrier by carrier

| # | carrier | disposition | reason (all measured, §2) |
|---|---|---|---|
| 1 | `sokoban.py:9,:31,:396` (+`:397`'s retired `unrecognised`) | **NAMED now, CORRECTED at the next identity move** | its bytes ARE the instrument: digest pinned by the freeze record, asserted by `sokoban_solver.py` control [6], and required for the declaration's live equality with the run of record |
| 2 | `sokoban/sokoban.py:9,:31,:347` + `sokoban/MANIFEST.txt` | **NAMED, never corrected** | a pin-time snapshot BY ITS OWN DECLARATION ("Hashes read from disk at pin time"; "Frozen bytes are UNCHANGED"). Correcting a snapshot destroys the thing it exists to be |
| 3 | `sokoban/PROPOSED-FIX-line348.diff:6` | **NAMED, never corrected** | a diff's context must quote the file it patches; editing it falsifies the proposal |
| 4 | `PREREG_sokoban.md:18,:45` | **NAMED, never corrected** | frozen contract, self-declared "fixed at this commit", digest pinned at `SOKOBAN_CONFORMANCE_PACKAGE.md:90`, and the population was READ under it — R2 is "future runs only" |
| 5 | `PREREG_sokoban_instrument1.md:165` | **NAMED, never corrected** | a dated prereg whose predictions were measured; the project's own precedent for a change to a frozen prereg is to NAME it in the successor ("`unrecognised` WAS SPLIT … after that document was frozen … named here so the extra column is read as the intended change"), not to edit it in |
| 6 | `THE_ARCADE_CABINET_SOKOBAN_tech-and-promo.md:81,:137` | **MOVED — corrected forward now** | current prose, pinned by nothing |
| 7 | `CABINET_SOKOBAN_DOSSIER.md:81,:137` | **MOVED — corrected forward now** | current prose, pinned by nothing |
| 8 | `…tech-and-promo.SUPERSEDED-1c90e564.md:81,:137` | **NAMED (already SUPERSEDED)** | a superseded revision is evidence of what the pre-correction text said |

**And the two "current prose" files carry two more defects in the SAME PARAGRAPHS, which the correction must
take with it or it is itself a partial fix:** `:132` heads that table *"separates **four** things"* above a
**five**-row table (a count beside a list is a claim of its own — already filed), and `:166` uses `unrecognised`
for what the code, the grammar and the frozen prereg's successor all name `not_an_action`. The corrected region
must agree **token-for-token and list-for-list** with `sokoban.py`'s `play()` return keys and
`SOKOBAN_READ_GRAMMAR.md` §2 — the same standard the amendment that raised this card was verified to.

## 4. WHY NOT THE ALTERNATIVES

**(a) as written — correct everything forward with `sokoban.py` left alone and a one-line note.** Nearly
right, and it is the shape I am ruling for the pinned carriers; its error is the word *"everything"*: the
unpinned carriers MUST move, and a note is not a disposition for the eight files the census returns.

**The "just edit it" variant — spend a prose-only re-freeze on `sokoban.py` now.** Refused, on the filed
precedent rather than on taste: **`2026-10-14-a-name-fix-must-not-buy-a-provenance-supersession`** —
*"every artifact produced under the old digest is re-stamped as though something about the measurement
changed, and the one thing this project cannot afford is a provenance record that moves for cosmetic reasons,
because a provenance record that moves for cosmetic reasons is one nobody can use to date an artifact"* — and
its general form: *"When a cosmetic change would force a provenance transition, that is evidence the cosmetic
thing belongs somewhere else."* The measurement content of moving this identity for a comment is **zero**;
the cost is a permanently weaker provenance claim over the run of record. The correction "belongs somewhere
else" and it already lives there: §2 of the grammar, which is what a reader is told to read, and where R1 and
R2 both put the change (*"The GRAMMAR is what changes"*).

**Distinguished from the D2 name case, deliberately:** there the benefit was *"a string that a human reads"*
and nothing else. Here the benefit is that the instrument stops mis-stating its own scoring rule — a semantic
claim, not a label. That is why the pinned carriers are **corrected at the next identity move** rather than
left forever: the ruling is about WHEN the identity moves, not about whether the text ever moves.

**(b) as written — correct the docs, defer the simulator's docstring "at the NEXT instrument change".**
Taken, and made mechanical. Its weakness was that *"the next instrument change"* was unscheduled, which is
how the grammar itself sat unamended from 2026-10-10 until today while R1/R2 were ratified on 2026-10-13.
The trigger is now NAMED, CARDED and OWNED (R1's record-side diagnostic), and the four text lines it must
carry are named exactly (`:9`, `:31`, `:396`, `:397`).

**(c) — a dated annotation only, identity never moves for prose.** Refused for `sokoban.py` alone, and its
own reason is the giveaway: *"the wording stays with a dated note beside it"* means a **false sentence sits
inside the instrument indefinitely while the note lives one file away**, which is exactly the
carrier-left-behind defect this card is about. It is retained only where it is not prose: a snapshot
(carrier 2), a diff (3), a record, or a frozen contract (4, 5) — where the artifact is *evidence of a date*
and its text is not a statement of the current reading at all.

## 5. WHAT THIS RULING DOES NOT SETTLE, NAMED SO IT IS NOT READ AS SETTLED

1. **R2 remains UNLANDED on carriers 1, 4 and 5 until the artifact that names them moves** — carriers 4 and 5
   by design (they are dated evidence and will never move), carrier 1 at its trigger. A reader who greps
   `sokoban.py:9` after both cards land still sees the pre-R2 sentence, and that is the correct outcome — the
   sentence is dated, not deleted. The filed rule stands unqualified: *a ruling is not landed until the
   artifact it names has moved* — which is why the two cards exist rather than this file.
2. **`THE_ARCADE_CABINET_SOKOBAN_tech-and-promo.md` and `CABINET_SOKOBAN_DOSSIER.md` are two versions of one
   document** (same H1/H2, same 12 sections; the promo says *"has not yet been run"*, the dossier *"NOW RUN.
   Results in section 12"*), and **neither is named SUPERSEDED**. Which of them is the current promo text is
   NOT settled here and is NOT this card's subject — both are corrected, because both are in the tree and
   neither is marked, and a correction that guessed one would be the same partial-fix defect one layer up.
3. **Carrier 5's `unrecognised`/`not_an_action` and the docs' `:166` are the same vocabulary defect**, named
   here because the census surfaced them; the docs' side is corrected with the score line (they are one
   paragraph's claims), and no separate ruling is created for it.
4. The `.pyc` is not a carrier (compiled docstring).

## 5a. THE SIBLING RULING, AND THE TWO FILES BOTH LANDINGS WANT

**`2026-10-15-a-list-in-a-frozen-identity-block-is-a-live-pin`** (card `t_8953b182`, the same batch, the
other residual of `t_fbee64a4`) ruled the grammar's §6 roster and reached the same test this ruling applies,
independently: a carrier may be edited when nothing pins its bytes (`sokoban_batch.py`'s digest *"occurs
nowhere in the tree"*, not in `FROZEN_DIGESTS`, no probe records a runner digest), and a pre-registration or a
record's own pinned path is **NAMED, not edited**. Its §3d reserved exactly this card's subject
(`THE_ARCADE_CABINET_SOKOBAN_tech-and-promo.md:81,137` *"is R2's other-carrier question, owned by
`t_31c14a0d`, and this ruling does not reopen it"*), and its §3d named `PREREG_sokoban.md` without editing it
— the same disposition reached here for carriers 4 and 5. Two rulings from one batch agreeing on the test is
worth less than the collision it exposes:

> **hotspot — `SOKOBAN_READ_GRAMMAR.md` §7 and `SOKOBAN_FREEZE_RECORD.md` §2.** `t_fbee64a4` created §7 and
> re-froze the pin; the sibling's landing (`t_e0264393`) amends §5/§6/§7 and §2's pin block; this ruling's
> landing appends a §7 follow-up and a note beside the same pin line. **Three writers, two blocks.** The two
> landings are therefore SERIALIZED (this one waits on `t_e0264393`), and the §7 follow-up is an APPEND
> against the post-amendment bytes — never an edit of §7's existing text.

## 6. ROUTING

Two cards, both to `@ocho` (the cabinet's owner and the raiser of this card), both children of
`t_31c14a0d`, and both **serialized behind `t_e0264393`** (the sibling amendment's landing, which owns the
same two blocks — §5a):

- **CARD A — the MOVED/NAMED landing:** correct the two prose carriers (§3, carriers 6 and 7, including
  `:132`'s count and `:166`'s name); APPEND the grammar's §7 follow-up (never an edit of §7's text) naming
  carriers 1–5 and 8 with dates and reasons; put the dated note beside the `sokoban.py` pin in
  `SOKOBAN_FREEZE_RECORD.md`. Acceptance: the case-insensitive census of §1 returns **exactly** the named
  carriers — command and raw output in the handoff.
- **CARD B — the identity move (child of CARD A, so the two never write the same block at once):** land R1's
  record-side loose-match diagnostic (already ruled, never landed; never scored) **and carry
  `sokoban.py:9,:31,:396,:397` in the same commit**, with a new instrument prereg naming the change, the
  re-freeze (`FROZEN_DIGESTS`; the freeze record's pin + a RE-FROZEN paragraph naming every subject it
  carries; `CABINET_DECLARATION_sokoban.md:42-44` amended to carry the freeze instead of asserting equality
  with the pilots' digest), and the proof that **no measured cell moves**: the 12 population cells and both
  pilots re-derive to their recorded counters, nothing re-scored.

## 7. RECORD

- Census re-derived at `f804955` (working tree clean): **16 text lines / 8 files** case-insensitively;
  the card's quoted case-scoped pattern returns **12 lines / 6 files** and cannot reach
  `PREREG_sokoban_instrument1.md:165` or `sokoban.py:396`. The card's "five current artifacts" undercounts
  its own subject.
- Digests: `sokoban.py` 21325 B `7134c3e8fc59fe02…`; `sokoban/sokoban.py` 17025 B `46c01c9b9380d6f4…`;
  `PREREG_sokoban.md` 11535 B `625c07ad7c87…` (pinned at `SOKOBAN_CONFORMANCE_PACKAGE.md:90`);
  `PREREG_sokoban_instrument1.md` 8884 B `15bc4b5d6b8d150d…`; promo 16527 B `007e5e03add1d3b2…`;
  dossier 19141 B `7e5eda7c19042afb…`; SUPERSEDED 16428 B `1c90e56450e90fb9…`;
  `sokoban/PROPOSED-FIX-line348.diff` 519 B `34bcd4f75d53c262…`.
- Pins read: `SOKOBAN_FREEZE_RECORD.md:75`, `sokoban_solver.py:95-102,494-500`,
  `CABINET_DECLARATION_sokoban.md:40-44,46-55`, `SOKOBAN_CONFORMANCE_PACKAGE.md:87-92`,
  `probes/SOKOBAN_RUN_pilot-20261011-105455.json:17`.
- Precedents applied: `2026-10-14-a-name-fix-must-not-buy-a-provenance-supersession` (control),
  `2026-10-15-a-ruling-is-not-landed-until-the-artifact-it-names-has-moved` (§5.1),
  `2026-10-15-a-number-beside-a-list-is-a-claim-of-its-own` (§3, `:132`),
  `RULINGS_independent_implementations.md` R1/R2 and their scope note (future runs only).
- Read-only everywhere: `git grep`/`cat-file`/`log`/`worktree list`, `grep`, `sha256sum`, `stat`, `sed`,
  `sqlite3 -readonly`. Nothing written or committed in `ocho_arena` or any worktree; no model, GPU, lease,
  service or config touched; nothing credential-shaped read or crossed.
