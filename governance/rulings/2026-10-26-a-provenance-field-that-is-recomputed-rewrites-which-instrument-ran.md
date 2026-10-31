# A provenance field that is recomputed at write time rewrites which instrument produced the number

**Date:** 2026-10-26
**Occasion:** peer letter `fec0d367b120` (Jarvis, 22:13:46Z) asked which `zork.py` produced our `62/62`,
expecting the recorded rows to settle it. On this box they cannot, and the reason is a defect of ours.
**Instrument:** `ocho_arena/probes/ZORK_*.json` (eight rows), commit `13b161a`.

## The finding

Every one of the eight recorded ZORK rows carries `simulator_digest`. Between `5558f13` (10-25) and
`13b161a` (10-26 14:36:31) that value was **rewritten**, on all eight:

    git diff 5558f13 HEAD -- probes/ZORK_Ornith-1.5-9B-Q4_K_M_zork_01_the_floor.json
    - "simulator_digest": "ff35ec83b340fbf0",
    + "simulator_digest": "b9701007d6e186d5",
    (24 changed lines across `probes/ZORK_*` naming `simulator_digest`; `git log -S` pins the change to 13b161a)

The rows' own `mtime` field is preserved (`2026-10-25T20:46:37Z`) and their runs date from 2026-10-17
and 2026-10-25, while `b9701007d6e186d5` is the digest of a `zork.py` that was written today at 13:11.
**The field now names a file that did not exist when the run happened.**

The field's own scope text, sitting beside it in the same row, is explicit about what it means:

> `simulator_digest_scope`: "sha256 of the SIMULATOR FILE, first 16 hex. THE SIMULATOR IS THE INSTRUMENT
> THIS EVENT IS MEASURED WITH, and it is pre-registered: a record that cannot say which simulator scored
> it cannot be placed against the frozen criteria."

And our own `ZORK_INSTRUMENT_REPORT_2026-10-26.md:290` cites these very rows as carrying
`ff35ec83b340fbf0` in BOTH sittings, as its evidence that one simulator file produced both — the claim
the restamp falsifies in the archive at HEAD.

## Why it is the same defect whichever way it happened

- If a backfill **recomputed** the field (`simulator_digest()` reads `HERE/zork.py` at write time), then
  re-emitting a record under a new instrument silently re-attributes the old run to the new file.
- If a hand **edited** it, the record was corrected into a falsehood for a true one.

Either way the archive stopped being able to answer "which instrument produced this number", which is
the only question the field exists to answer.

## The rule

> **R1 — A field that names the instrument which produced a number must be CARRIED from the run, never
> recomputed at write or backfill time.** A record re-emitted by a later instrument is a different
> record; if its identity fields are recomputed rather than preserved, it is a forged provenance with
> no author.

> **R2 — A backfill that adds fields must copy the identity fields VERBATIM and assert them against the
> pre-backfill bytes.** Anything else is an unmeasured rewrite of the very thing the record is for.

> **R3 — When a derived field and a carried field disagree, the CARRIED one is the record and the derived
> one is a claim about now.** Derive into a differently named field (`simulator_digest_now`,
> `replayed_with`) rather than overwriting the field that dates the run.

## Consequences, and what was NOT done

- The archive at HEAD cannot be used by either box to establish driver/simulator pairing. The peer was
  told exactly that, with the diff, so he would not cite our rows as pairing evidence.
- **Not repaired here.** Restoring `ff35ec83b340fbf0` in eight committed rows is a change to record
  contents and belongs to whoever owns `FORMAT.md` and the board, not to a transport tick. Surfaced to
  Mike with the diff.
- The same commit rewrites SNAKE and SOKOBAN rows in larger blocks (6,093 / 6,334 / 756 lines). **Those
  were not audited this tick** — the ZORK rows were read because they were the subject of the peer's
  question. No claim is made about them.

## Prior art

`priorart · 492 records in rulings`, two phrasings, max score 0.099
(`2026-10-09-a-frozen-taxonomy-encodes-the-instrument-that-produced-it`, read — a scorer cannot record
the failure its method forbids; not this). Others below 0.10: `2026-10-16-a-duplicate-key-is-an-entry-not-an-identity`
(a backfill creating a false gap), `2026-10-20-a-bucketed-field-cannot-join-two-records`,
`2026-10-25-a-total-that-reproduces-does-not-certify-the-walk`. None states that a provenance field must
be carried rather than recomputed, or that a backfill may not re-stamp the instrument that scored a run.
