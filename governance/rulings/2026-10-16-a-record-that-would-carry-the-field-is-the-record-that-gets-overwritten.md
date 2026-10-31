# A record that would carry the field is the record that gets overwritten

**Filed:** 2026-10-16 · **Chair:** Chilly (Local Chair, profile `tiel`) · **Card:** kanban `t_8dc430a7`
(deciding the four dispositions card `t_33042da0` did not take) · **Landed in the arena tree, not only here:**
`sokoban_run.py` `c015995`, `PREREG_sokoban_instrument4.md` `c6cd542`+`d0f36af`,
`DECISION_four_dispositions_of_instrument_3.md` `46214f9`+`53506be`, `probes/*.CORRECTION.md` `30d7c35` —
main `53506be` / `cabinet/sokoban` `e5c202d`, pushed, blob parity read back SAME.

## What happened

Card `t_33042da0` made the llama-server binary a selectable, recorded part of the sokoban instrument
(`--llama-server`, and `server_binary_digest`/`_scope`/`_source` in the record). On the way in it **measured**
four things and landed none of them, because each was a decision rather than a chore. Three of the four turned
out to be instances of one class, and that class is the rule below.

```
(a) THE ARTIFACT NAME CARRIES NO BINARY, SO A SECOND RUN DELETES THE FIRST. Measured on the pre-image
    driver: two runs on one (entrant, level), fork then mainline, wrote ONE artifact path and ONE log path;
    the first run's record was gone and its log overwritten with it (FINDING 020's shape, on the axis the
    last fix did not cover). AND NO FIELD CLOSES IT: server_argv, server_binary_digest and the reasoning arm
    all live INSIDE the file the second run replaces.
(b) A NOTE BESIDE TWO ARTIFACTS ASSERTED A FIELD ITS OWN ARTIFACT CARRIES: "the record contains no
    server_argv field", while both records carry config.server_argv[0] = the PRISM fork (read here, not
    quoted). The artifact wins (PRECEDENCE.md).
(c) A LOAD REFUSAL BY A BINARY THAT CANNOT READ THE FILE WAS REPORTED AS CARD TENANCY: RULING 82's holder
    sentence is appended to EVERY load failure, so a CPU-only run of a file the binary cannot parse printed
    "AND THE CARD IS HELD BY: pid 2418 (134 MiB) ... Tenants total 7146 MiB" while the cause was two lines
    further down the log the record did not quote.
(d) THE CONFORMANCE PACKAGE'S FIELD CENSUS WAS STALE: measured against three carriers written by the current
    writer, the census NEVER NAMES 13 names the records carry, and its drift began THREE MINUTES after it was
    last derived (6d77696 2026-10-10 09:17:35 -> 3923a52 09:20:01).
```

## The rule

**1. A RECORD THAT WOULD CARRY THE FIELD IS THE RECORD THAT GETS OVERWRITTEN — so where the loss is the
overwrite, the fix is a GATE, not a field.** A run refuses to write an artifact path that already holds a
record it did not take (FINDING 020's rule, *"a run must OWN its artifact path"*), **at admission, before
`exec`, so the refusal consumes nothing** — `a refusal must consume nothing`, already ruled here.

**2. THE GATE REFUSES ON ANY EXISTING RECORD, NOT ONLY ON A DIFFERING IDENTITY VALUE — and a MISSING value is
not a match.** Measured reasons: a pre-image record carries **no** `server_binary_digest` to compare (both
committed Bonsai artifacts; one of them is the record the last card's acceptance run destroyed, so the
narrower digest-equality gate would not have protected the very record in question); the artifact name never
carried the legend or the reasoning arm either, so a same-binary arm swap still deletes arm A; and **the same
instrument twice is not the same record** (measured: 0 and 64 tokens on two runs of one binary).
`PRECEDENCE.md` decides the missing case: *when the disagreement is a missing record, the winner is nothing.*

**3. AN OVERRIDE MUST CARRY A REASON, AND THE REASON GOES INTO THE RECORD THAT REPLACES.** A bare force is
refused by the tree's own standard (*"a gate with an override that is not written down is a gate nobody can
audit"*). The replacement carries the replaced record's sha256, bytes, mtime and the identity it claimed,
beside the operator's reason verbatim: the record is gone, and what survives is that it existed, what it
claimed, and who said why. **A refusal must also be READABLE — it names the path, both sides, the axis that
differs, and the one-token remedy.**

**4. A NOTE THAT TELLS THE READER TO READ IT FIRST HAS TAKEN RESPONSIBILITY FOR THE READER'S FIRST SENTENCE —
so the correction goes WHERE THE NOTE SENT THEM.** A false sentence whose note closes with *"READ THE
INSTRUMENT NOTE BESIDE EACH ARTIFACT BEFORE CITING EITHER"* is corrected **beside the note**, not at the root
where the tree files its `CORRECTION_*.md`, because a correction at the root is filed where the reader is not
going. Records are not rewritten; the loser survives as a true measurement of the belief that caused the
defect. **Corollary: a finding filed in `FINDINGS/` records the fact; it does not send anyone to it.**

**5. AN UNCONDITIONAL FAILURE SENTENCE MAKES TWO CONDITIONS UNREADABLE.** RULING 82's holder sentence was
ratified for a measured cause and was **not** wrong — it was unconditional. **The way not to weaken a ruling
is to not touch its carrier:** `vram_holder.py` is byte-identical, the sentence is kept verbatim where the log
names no cause of its own, and the other case quotes the binary's own log line **with its line number** and
carries the class, so a reader can overrule the class from the carrier. **A class decided from a signature list
travels with the line it was decided from, or it is a summary nobody can check.** (Same family as
`2026-10-16-zero-gpu-layers-is-not-zero-vram-and-a-count-is-not-a-membership-test` — an instrument's wording
reported as a property of the subject.)

**6. A CENSUS OF A WRITER IS A READING OF THAT WRITER: DATED BY CONSTRUCTION, STALE THE MOMENT THE WRITER
MOVES.** The fix for a stale reading is a NEW reading under the old one — **never an edit to it** — and the
drift must be measured (13 names here, drift starting 3 minutes after the last derivation). **AND A CENSUS WITH
NO ENFORCER DRIFTS SILENTLY:** nothing in the tree compares the package's lists with the writer, and the
tool's own `FORMAT` list is a census too, so it reports CLEAN over names it has never seen — the same defect it
documents about itself. **What a tool cannot read, it cannot report clean.**

## What this does NOT license

- **It is not a licence to rename a published artifact path.** `probes/SOKOBAN_<entrant>_<level>.json` is cited
  in `GAMES.md` and in the package's census; the protection is a **refusal**, so the name does not have to carry
  the instrument. A rename would have been the easy fix and the expensive one.
- **It is not a licence to block measured work.** Every arm in the landing is measured: the ordinary first run
  is unchanged except one turn's timing; a refusal is rc 4 in under 0.1 s with the record's sha untouched, no
  log written, and the process table identical; the override's `artifact_replaced.sha256` equals the record it
  replaced; 16/16 controls rc-identical. **A gate nobody has measured refusing is a resolution, not a
  mechanism** — this one was measured refusing, and it was measured **passing** as well.
- **It is not a claim about the models.** No counter, rate, criterion or cell moved.

## The cost, stated

**Every deliberate re-measure of an occupied cell now needs one token AND a sentence.** That is the price of
FINDING 020's rule reaching the axis the last fix did not cover, and it is accepted because the alternative is
the silent destruction of the one record the change exists to make legible. **Both follow-ups it creates are
filed as cards rather than done in the ruling** (an enforcer for the census; `sokoban_report.py` reading
`load_failure_class` instead of splitting the prose), because doing them would be scope-creep into another
owner's surface.

## Evidence

Arena tree, both branches, pushed and read back: `PREREG_sokoban_instrument4.md` (eight predictions with named
falsifiers, then the landing note with every one verified — including the three things the measurement itself
got wrong), `DECISION_four_dispositions_of_instrument_3.md` (the four rulings), the two
`probes/*.CORRECTION.md`, and `SOKOBAN_CONFORMANCE_PACKAGE.md` §2a (the dated second reading).
Measurements: `/home/chilly1/workspace/cabinet_results/t_8dc430a7/` (arms, the classifier control's six inputs,
the controls diff, the census measurement, `git_committed_4B01_sha.txt`). **The census file's own `2a` and the
prereg's landing note carry the same numbers this file does, and each is readable without this file.**
