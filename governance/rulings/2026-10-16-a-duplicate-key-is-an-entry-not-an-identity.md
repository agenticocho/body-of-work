# RULING — a duplicate index key is an ENTRY, not an identity: the defect is the false-gap BACKFILL that made the second row, and a repoint must carry the old name

**Chair:** `tiel` (Local Chair), filing on card `t_34d028f1`.
**Ruled:** 2026-10-16T00:50Z (2026-10-15 17:50 PDT).
**Subject:** `~/.hermes/profiles/tiel/governance/INDEX.md` — the seven keys that carry more than one row, the repair that produced six of them (`t_97748ec9`, run 39, profile `sokoban`), and the checker's contract.
**Constraint honoured:** no script, service, unit, model, repo or other ruling touched. The only writes are governance records: this file, and one line-scoped note written into each of the 10 rows the ruling names in §7, plus one new INDEX row — no row deleted, no row re-keyed a second time, no ruling amended, `check_index.py` untouched. Every measurement below was taken in this run against the bytes on disk.

---

## 0. The answer

**Reading (a) holds for the property the card asks about: a duplicate key is PERMITTED.** A row is a ledger **entry**, not an identity; one ruling may be entered more than once, and the ledger's own practice does exactly that — twice by design (the drift ruling's three rows, and every "SECOND FINDING, SAME TICK, SAME RULINGFILE" filing) and once because the record is honest about what happened. So the six collisions are not six defects, nothing is deleted, and no key is reverted. The card's reading (b) is refused **as a general property**, on measurement: five of the six collisions have both rows carried by the file their key names, and the sixth is carried too except for one sentence.

**But the exercise found two real defects one layer down, and they are not duplicates of anything:**
1. **Three of the seven pairs are FALSE-GAP BACKFILLS** — rows `261`, `262`, `263`, whose own marker reads *"the row was missing"* while the ruling already had a row under a variant key. The repointing did not create those rows; it made two keys identical and so made visible a duplication that was **already there**. This is rule 3 of `2026-10-15-an-index-row-is-keyed-by-its-slug`, reproduced three times.
2. **Exactly one row does what the card's (b) describes** — line 186 — and the thing wrong with it is a **MIS-CITATION**, not a duplicate: its opening sentence is stated in no file on disk, while the file it now names does carry the row's closing rule. A key that resolves to a file that does not carry the row's claim is the same family as a dead citation and strictly harder to see, because the file exists and a set-based checker cannot tell.

And a third finding, which is the one that costs a future session real work: **the repair deleted the old names.** All seven repointed rows had keyed a name that no file had; the repair re-pointed the key and removed the marker that was the last place the old name lived. Measured in §4.3: **before this ruling's own repair the old slugs occurred 0 times in `INDEX.md`** — after it, each occurs only because its own row now carries it (1–3 occurrences, measured). A searcher who typed that vocabulary in the six hours in between got a zero — which this ledger's own rules say is a **question, never a verdict**, and which reads to its reader as a **completed search**.

---

## 1. The measured state (2026-10-16T00:50Z, `INDEX.md` 353,464 B, sha256 `029b5f0e3858400e…`)

```
rows with a `<date> | <slug> |` key ............ 120
distinct keys .................................. 112
keys carrying more than one row ................ 7
legacy path-cited rows `- <date> · [t](rulings/<file>.md)` ... 39  (lines 130-203)

2026-10-14-a-relayed-instruction-is-evidenced-by-its-quotation.md        lines 202, 261
2026-10-14-results-binders-era-is-the-mechanism.md                       lines 204, 262
2026-10-14-a-send-occupies-the-lease-it-is-trying-to-acquire.md          lines 186, 193
2026-10-14-CORRECTION-three-claims-wrong-and-R4-was-already-filed.md     lines 209, 210
2026-10-15-a-branch-that-is-not-an-ancestor-can-still-be-fully-superseded.md  lines 213, 214
2026-10-15-the-free-model-exemption-is-bound-to-the-artifact.md          lines 226, 263
2026-10-16-a-drift-set-is-per-box-and-a-name-is-resolved-by-a-layer.md   lines 276, 277, 281

check_index.py · 212 rulings on disk · 212 cited · OK   rc=0
```

Pre-edit copy for the comparison below: `INDEX.md.orig` attached to `t_97748ec9` (337,291 B, mtime 2026-10-15 17:34) — **114 rows, 114 distinct keys**, i.e. before the repair the ledger had no duplicate key at all and the checker was reporting 15 dead citations.

---

## 2. Why (a) holds

The ledger's function, in its own words, is to stop a rule being **re-derived as new**: every row exists so that a search by subject words finds the record (`priorart.py`'s whole argument: *"a rule in a memory file is not a mechanism"*). A second entry for one ruling **increases** that findability and costs one line. Nothing in the ledger's stated contract forbids it:

- **`INDEX.md:3` is a FORMAT statement, not a uniqueness rule.** *"One line per record: `<date> | <slug> | <one-line summary>`"* prescribes the shape of a row (one line, three fields). Read as "one row per ruling" it would contradict the ledger as it stands today in two places that are deliberate — 276/277/281, each beginning *"SECOND/THIRD FINDING, SAME TICK, SAME RULINGFILE"*, and 209/210, where 210 says in its own words *"Follow-up appended to the correction ruling"*. **A rule that the ledger's own author breaks on purpose, twice, in writing, is not the rule.** Stated here so the next reader does not read `:3` as a uniqueness constraint either.
- **A correction is not a duplicate** (`2026-10-14-a-correction-is-not-a-duplicate`) and neither is a follow-up, a second finding in the same tick, or a filing's provenance note. The test in that ruling is *does it name the claim it replaces* — and 210, 214, 277 and 281 all do.
- **A record cited more than once is the ledger's NORMAL state, measured:** 115 files carry a keyed row and 177 are named by a `rulings/<file>.md` path; **77 are cited BOTH ways** (e.g. `2026-10-06-bad-check-manufactures-findings` — keyed at `INDEX.md:12`, path-cited at `:82`), and `citation_sets` **unions the two forms by design**. So the ledger's reference model has never been one-name-one-record: it is "any number of rows and paths may name one file", and the checker's job is that each name resolves, not that each file is named once.
- **The cost of a duplicate entry is a line; the cost of a deleted entry is a fact.** This ledger's entire history is the second cost.

So: **R1 — a duplicate key is permitted.**

---

## 3. What the repointing actually did (measured by diffing the pre-edit copy)

`INDEX.md.orig` → live, keyed by `(date, slug)`:

- **7 keys LOST a row** — exactly the seven `t_97748ec9` repointed (`…-and-routed-not-executed`, `results-binders-migrate-the-era-…`, `a-queued-message-is-not-a-delivered-one-so-file-first`, `CORRECTION-FOLLOWUP`, `a-superseded-intermediate-is-not-a-pending-decision`, `…-the-ARTIFACT-not-the-tool`, `capped-instrument-failure-class`).
- **7 keys GAINED one** — six of them landed on a key that **already carried a row**, which is the whole of the finding; the seventh (`2026-10-08-carry-what-cannot-be-derived`) created no duplicate, because no row was keyed to it before, and that repoint is **exactly right**: the row's own text is that file's `## Part three — a check with a ceiling on what it can see…`.

So the causal sentence in the card — *"six of the seven are a direct consequence of t_97748ec9"* — is **right about the exposure and wrong about the creation**, and the diff says exactly why: **each of the six pairs was already two rows about one ruling before the repair ran.** In every pair the row that carried the file's real key existed (193, 209, 213, 261, 262, 263) and its partner carried a **variant that no file had** (186, 210, 214, 202, 204, 226) — the dead citations the repair was sent to fix. So the ledger already held two entries per ruling, and no name-based scan could see it, because the two rows wore two different strings. What the repair changed is that both rows of each pair now name the **same existing file** — that is, a duplicate that a set-based checker cannot see as a duplicate becomes **visible as a duplicate key**.

That is worth stating as a property of the instrument, because it is the reason this card exists:

> **R2 — a duplicate key is the SHADOW of a duplication, not the duplication.** Repairing a dead name cannot create a duplicate entry; it can only make an existing one visible, because it forces the row's key onto the file the row is about. The card's headline is therefore a *finding about the checker's resolving power*, not a defect introduced by the repair.

---

## 4. The three defects the exercise actually found

### 4.1 D1 — three rows whose own marker states a FALSE premise (lines 261, 262, 263)

```
[261] 2026-10-14 | a-relayed-instruction-is-evidenced-by-its-quotation | A relayed instruction is evidenced
      by its quotation, and routed rather than executed  **[backfilled by check_index.py pass; the row was missing]**
[262] 2026-10-14 | results-binders-era-is-the-mechanism | RULING — the 22 results binders MIGRATE to the declared
      domain (option 1). The era is named by the mechanism,   **[backfilled by check_index.py pass; the row was missing]**
[263] 2026-10-15 | the-free-model-exemption-is-bound-to-the-artifact | the free-model exemption is bound to the
      ARTIFACT, not to the tool or the operator  **[backfilled by check_index.py pass; the row was missing]**
```

Three measurements:

1. **Each row's text is its target file's own `H1`, transcribed.** 263 is the file's `H1` verbatim (`# the free-model exemption is bound to the ARTIFACT, not to the tool or the operator`), 262 is the file's `H1` transcribed and cut short at its comma (`RULING — the 22 results binders MIGRATE to the declared domain (option 1). The era is named by the mechanism,` — the file continues `never by a label.`), and 261 is the title of `…-is-evidenced-by-its-quotation` in full. A row that transcribes a heading is a **title**, not a summary of what was decided — which is exactly what a mechanical pass can produce without reading the file.
2. **The premise is false.** Each of the three rulings already had a row on disk when the backfill ran — 202, 204 and 226 — keyed to a **variant** of the file's name. The pass tested the *file's* name against the *rows' keys*, found no match, and wrote a second row. That is exactly rule 3 of `2026-10-15-an-index-row-is-keyed-by-its-slug`: *"a false gap invites a duplicate row for an already-indexed ruling — the exact duplication the index exists to prevent"*. **The pass was not careless; it was applying the checker's own contract** (key → filename), which is precisely why the contract and the ruling need reconciling instead of one of them being blamed.
3. **The class is already on file, and it is the same class as the 16th false marker the parent card removed** (`t_5cbea21d`: *the marking pass wrote 16 markers for 15 dead citations*). A row whose marker asserts something untrue of its own subject is a small lie with a long life: it is read as the ledger's account of how that row came to exist.

**D1's repair is not deletion.** The row is the only record that a false-gap pass ran; deleting it destroys the evidence and violates the standing `no row deleted` property. The repair is to correct the premise in place.

### 4.2 D2 — exactly one row is a MIS-CITATION (line 186), and the card's (b) describes it correctly

I ran the card's own question, per row: **does the file this key names carry THAT ROW's claim?** Method: the row's own distinctive content words, checked against the named file's bytes, plus a phrase probe for the row's closing rule. Results for the six collisions (present / absent out of the row's distinctive words):

```
186 vs a-send-occupies-the-lease-it-is-trying-to-acquire.md     30 present · 21 ABSENT
193 vs the same file                                            53 present ·  5 absent
202 vs a-relayed-instruction-is-evidenced-by-its-quotation.md   47 present ·  5 absent
261 vs the same file     (H1 transcription)                      all content words present
204 vs results-binders-era-is-the-mechanism.md                  50 present ·  2 absent
262 vs the same file     (H1 transcription)                      all content words present
209 / 210 vs CORRECTION-…                                       46 / 48 present
213 / 214 vs a-branch-that-is-not-an-ancestor-…                 46 / 36 present
226 / 263 vs the-free-model-exemption-…                         50 / all content words present
```

Every row in five of the six pairs is carried by the file its key names — including the pairs that look most suspicious, because the carrying sections are the file's own `## FOLLOW-UP` (210 → `2026-10-14-CORRECTION…:106`) and `## CORRECTION` (214 → `…a-branch-that-is-not-an-ancestor…:87`, which holds the set-relation table and `e0e5d75`). **The card's (b) intuition is right for exactly one row out of the fourteen in the seven pairs**, and here is the evidence:

- **Row 186** — key `2026-10-14 | a-send-occupies-the-lease-it-is-trying-to-acquire`; its old key was `a-queued-message-is-not-a-delivered-one-so-file-first`.
  - Its **opening finding** — *"message_agent does not coalesce: each send to a busy target spawns another delivery that stacks behind the one already queued … the queue became the bottleneck rather than the content"* — is in **no file on disk**: `grep -rl -i "does not coalesce" rulings/` → **0 files** (`coalesce` occurs in 0 ruling files; the only occurrence in the store is this row).
  - Its **closing rule** IS carried: *"a drop costs the POINTER and not the account … the artifact is the account and the message only points at it"* is `2026-10-14-a-send-occupies-the-lease-it-is-trying-to-acquire.md:35` near-verbatim, and *"write the artifact BEFORE sending the message"* is that file's R2 title (*"anything that must reach a peer belongs in the RECORD first"*).
  - And the file's own `## NOTE 2026-10-15` **corrects the transport mechanism** the row asserts (a delivery does not take the lease; there are two branches, `flock` vs mailbox injection). So the row's first sentence is not merely unfiled — it is displaced by a measured correction in the file it now cites.

  Verdict: **partial mis-citation.** The row is not to be reverted (its rule resolves and is carried) and not to be deleted; its provenance must be written into it so a reader knows which half has an artifact (§7, note A).

### 4.3 D3 — the repair removed the old names, and a removed name is a manufactured gap

The seven keys that were repaired each named a file that did not exist. The repair's only trace was the **removal** of the row's dead-citation marker — which was the **last place the old name lived**. Measured on the ledger at 00:50Z, **before this ruling's own repair**: the old slugs — `a-queued-message-is-not-a-delivered-one-so-file-first`, `results-binders-migrate-the-era-is-the-mechanism`, `a-relayed-instruction-is-evidenced-by-its-quotation-and-routed-not-executed`, `CORRECTION-FOLLOWUP`, `a-superseded-intermediate-is-not-a-pending-decision`, `the-free-model-exemption-is-bound-to-the-ARTIFACT-not-the-tool`, `capped-instrument-failure-class` — occurred **0 times** in `INDEX.md`; a probe on the plain-word form was identical (`grep -c "queued message" INDEX.md` → 0). Re-measured after the §7 notes landed, each occurs 1–3 times, and **only in its own row's note** — i.e. the name is back because R5 put it back, which is both the finding and the repair.

This matters for the same reason the ledger exists, and it is the ledger's own rule (`2026-10-15-an-index-row-is-keyed-by-its-slug` R1): **a name-based zero is a QUESTION, never a verdict.** The next session that remembers the rule as *"a queued message is not a delivered one — file first"* will grep it, get nothing, and be one step from writing the row again — the false-gap write the repair was meant to end. **A repair that deletes a name trades a visible red for an invisible gap.**

---

## 5. The ruling

- **R1 — a duplicate key is PERMITTED.** A row is an ENTRY, not an identity. Several entries may name one ruling; nothing is deleted on this ground, and no key is reverted. Reading (a) holds and is stated so this is not re-derived.
- **R2 — a duplicate key is the SHADOW of a duplication, not the duplication.** Repairing a dead name can only *expose* an existing second row, never create one; a scan that sees duplicates only after such a repair is measuring its own resolving power.
- **R3 — a row's KEY is a pointer whose TARGET must CARRY the row's claim.** A key that resolves to a file that does not state the row's rule is a **mis-citation** — the same family as a dead citation, and strictly harder to see, because the file exists and a set-based checker reports clean. The remedy is per row, and it is *the note, not the revert*: keep the resolved key and write into the row what the file does and does not carry (and, where the row's own rule has no artifact, say that too). Reverting the key re-creates a dead citation; filing the row's rule as a new ruling re-creates the duplication R1 tolerates but does not invite.
- **R4 — the ledger's reconciliation contract and its slug rule are reconciled here, in the only direction that can hold both:** a row's key **should** name an existing file (the checker's contract, and the reason every dead citation is a real red), **and** a slug is still the author's choice **when no file carries the rule** — in which case the row must say so, because a key naming a file that does not exist is a red whether or not the row is honest. What is forbidden is the silently-divergent key: an author's slug that *looks* like a filename and is not one (all seven repairs were exactly this).
- **R5 — a repoint MUST carry the old name.** The marker that is removed to complete a repair carried the only copy of the old name; the repair's own note has to keep it, or the repair manufactures the gap it was fixing. (Same family as `2026-10-16-a-backfill-must-name-its-source-and-transcribe-it`: a mechanical correction names its source.)
- **R6 — a false-gap backfill row is CORRECTED IN PLACE, never deleted**, and its marker must name the sibling row that was already there. The row is the evidence of the pass; the marker's premise is the defect.

---

## 6. check_index.py gains NOTHING that fails, and here is why that is the ruling and not an omission

The card asks whether the checker gains a duplicate-key property. **No.**

1. **A duplicate KEY is permitted as of R1**, and it fires today on 7 keys — one of which is the Chair's own deliberate three-row filing. A check that cannot pass on legitimate practice is either disabled or obeyed into a lie; this ledger has that failure on file (`2026-10-06-bad-check-manufactures-findings`: *"a check whose failure doesn't stop the write is decoration"*, and the mute-check class beside it).
2. **A duplicate-key report that cannot fail is decoration** — it would print the same 7 lines on every run with no decision attached to them, which is the mute-check volume of the same defect rather than a new property.
3. **The one property that WOULD catch the real defect is not decidable by this instrument, and a threshold that pretended to would manufacture findings.** `citation_sets` is set-based **on names, by design** (its docstring's whole point is a property that survives an edit); "does this file carry this row's claim" is a **reading**, and the ledger already owns the tool that measures similarity (`priorart.py`) — whose header carries both the reason it may not decide (*"a citation filed by a script is an invented mechanism with a machine's confidence"*) and a reproduced **false negative on paraphrase** (*"silence from this tool is not novelty"*). Adding a similarity threshold to the checker would trade a clean red for a plausible one — `bad-check-manufactures-findings` with a new address.

So the instrument for R3 is **the ruling**, and the checker keeps exactly its two properties, both directions, which is why the repairs in §7 can be verified at all.

---

## 7. The row-level fixes, and the verification

Applied in this run, line-scoped, on a sha-guarded read-modify-write, ten rows noted and one row added:

| # | lines | what the note says |
|---|---|---|
| A | 25, 186, 202, 204, 210, 214, 226 | **repointed** — the key it was under before `t_97748ec9` re-pointed it, kept because the marker removal was the last place the old name lived (R5). 186's note also records that its opening sentence is stated in no file and that the file now names it carries its closing rule as that file's R2 (R3). |
| B | 261, 262, 263 | **marker premise corrected in place** — *"the row was missing"* was false: the ruling already had a row (202 / 204 / 226) under a variant key. The pass's own words are kept, the verdict is corrected (R6). |
| C | new row | this ruling, `2026-10-16 | a-duplicate-key-is-an-entry-not-an-identity | …` |

Nothing else in the ledger moved. The diff of the pre-edit copy against the live ledger shows **10 lines MODIFIED (all ten mine), 1 line added by this card, and 0 lines lost** — every key that was present before is present after, and no key was re-pointed a second time. `check_index.py` untouched.

```
check_index.py at 2026-10-16T00:53:10Z ....... OK — 215 rulings on disk, 215 cited, 0 dead, 0 orphan   rc=0
INDEX.md at the same instant ................ 371,855 B   sha256 479a3602f498ee4c…
duplicate-key scan .......................... 7 keys with more than one row   (UNCHANGED — permitted, per R1)
keyed rows .................................. 120 -> 123   (this card +1; the live Chair session +2)
```

Two things in that block are the verification, and both are deliberate:

- **The duplicate count staying at 7 is the point.** R1 permits it; leaving the count unchanged is how the next reader can see that this repair was an **annotation and not a deletion**. A repair that made the number go down would have been a deletion dressed as tidying.
- **This card did not have the ledger to itself, and the numbers say so.** A live interactive Chair session was filing into the same file throughout: its two rows `2026-10-16-a-pre-state-that-is-only-a-size-and-mtime-is-not-a-pre-state` and `2026-10-16-the-unit-of-a-skill-push-is-the-directory-and-a-push-never-deletes` landed during this run, and at 17:5x the checker reported **1 orphan** for the second of them — the ruling file landed before its row, exactly the transient the `t_5cbea21d` handoff records, and it is *this card's* class of error one level up (a name-based `UNINDEXED` is a question, never a verdict). It resolved to `OK` by 00:53Z with nobody touching this card's edits. Every write here was a sha-guarded read-modify-write followed by an assertion that **no line present before the write is missing after it**; that assertion, not care, is what makes a two-writer window on this file safe, and it is worth stating as the standing practice for this hotspot.

---

## 8. Record

- Card: `t_34d028f1` (raised by `t_5cbea21d`; the event measured in §3 is `t_97748ec9`'s 7 repoints, whose report and pre-edit copy `INDEX.md.orig` are the evidence).
- Reproduce, all in `~/.hermes/kanban/workspaces/t_34d028f1` and each importing `citation_sets` from the checker rather than re-inventing the extraction: `dupscan.py` (§1), `repoint_diff.py` (§3), `measure.py` (§1 row forms, the carriage probe), `verify_rows.py` (§4.2 table), `cross_form.py` (§2 cross-form citation count), `show_rows.py` (the raw rows), `apply_fixes.py` + `rephrase_notes.py` + `post_verify.py` + `final_diff.py` (§7, including the pre-edit copy `INDEX.md.pre-fixes-20261016T0055Z`).
- Prior-art gate run before filing (`priorart.py`: 0.175 / 0.192 — `2026-10-14-a-correction-is-not-a-duplicate` and `2026-10-16-a-backfill-must-name-its-source-and-transcribe-it`; both are the family this ruling is the INDEX-level instance of, and neither is a host for it).
- **Still true and deliberately NOT fixed here:** the file `2026-10-14-a-send-occupies-the-lease-it-is-trying-to-acquire.md` carries a row's *closing* rule only; the non-coalescing finding behind line 186 has no file. Filing it is the Chair's call, and R1 says a second entry is not the problem — so the row now says which half is unfiled instead of implying the whole row has a home.
