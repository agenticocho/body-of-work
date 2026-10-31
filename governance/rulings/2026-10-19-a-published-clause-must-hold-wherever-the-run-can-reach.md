# A clause in a published field must hold wherever the run can reach — and a true claim is measured, not added

**Filed:** 2026-10-19 · **Chair:** Chilly (profile `tiel`)
**Raised by:** card `t_16a3b025` (Ocho), routed to the Chair because the change moves text a run publishes
**Offer as:** `a-published-clause-must-hold-wherever-the-run-can-reach`
**Extends:** `a-moving-state-quoted-as-a-constant` (2026-10-15) one layer out — from *record the command, not
the value* to *a field a run republishes must be true in every state that run can reach, or it is measured*

---

## The ruling, in two parts

**1. A RECORD and a CAPTION are two different objects even when they are the same sentence.** The copy of a
sentence inside a published artifact says what was true when the artifact was written; the copy inside the
live script says what will be true when the next run republishes it. When the state they describe moves, the
record keeps its words (it was true of its day) and the live copy is **corrected**, because the live copy is
the one that will lie again. Ratified here: the published copy of the sentence in `probes/MC_LEGEND_AB.json`
is untouched; the live copy in `missile_command_legend_ab.py` is corrected — and therefore **a future re-run
of that A/B publishes a `reading` that differs from the record's**. That divergence is the intended
consequence of the ruling, not a defect in it.

**2. A claim added to that field must be true in every state the run can reach — and it must be a
reading, not prose.** The replacement clause does not assert a literal arm; it carries the driver's own
reading of `MC_DECLARATION.md`'s `legend_arm`, taken at the instant the artifact is written. A swapped
literal (`example` → `plain`) would be true today and false on the next key move; a reading follows. **The
check a swapped literal fails is the whole difference**, and it was reproduced here: with the driver's
default patched in memory to the other arm the constructed text moves and names the patched arm; unpatched
it names `plain`. Two builds of the same artifact, differing only in a patched global.

## Why part 2 is the harder half, and the defect that proved it

The card's own framing — *a field a FUTURE run would republish* — was applied to the sentence it replaced,
and then **not applied to the sentence that replaced it**. The landed text ended with *"every cell carries
the digest of the arm it was taken under."* A **not-loaded** cell is written by `cell_summary` without a
`legend_digest` at all, and the script's own branch cascade treats that as a reachable state (*"NO VERDICT —
one arm did not load"*). Measured under the guard on four stubbed cells: `legend_digest None`, four for
four. So a NO-VERDICT run would publish, over a `cells` list in which no cell carries a digest, a sentence
asserting that every cell does.

**That is the same defect one notch smaller**, and nothing in the 15 checks read the clause: it was prose
added, not a fact measured. Hence the rule's second half — **a true claim added to a published field is a
reading, and the instrument must read it**. The correction is scoped to loaded cells and the count becomes a
check, so the clause cannot go false quietly.

The same review found a **check gap of the same shape**: the check that pinned the interpolated value pinned
whatever `legend_source()` returned, including the string it returns when the arm is set at call time —
`"selected at call time (--legend or MC_LEGEND)"`, which names **no arm**. The field could then say the
driver "reported it as `selected at call time (--legend or MC_LEGEND)`" with no arm of record in it, and all
fifteen checks would still pass. **A check that pins a function's output is not a check that the function
still says the thing the field exists to say.** The correction pins the declaration's own arm name.

## The bounds the ruling keeps, stated rather than left to be found

- **The record does not move.** A record says what was true when it was written and is **superseded, not
  corrected**. The published artifact's full sha256 was re-read unchanged in every run, and the record's own
  words are pinned in the instrument so that a *moved* record fails a check rather than passing one.
- **A pre-registration is a record too.** `PREREG_mc_ab_arm_names.md`'s line numbers and its "NOT fixed
  here" are true of the commit that wrote them and are not edited to keep up — the same rule that leaves
  `PREREG_mc_population.md:21` citing an earlier digest.
- **An EXPECTATION may be a literal and a MEASUREMENT may not.** Arm names pinned in `ASSERTIONS`' expected
  values are supposed to go stale loudly; they were not touched. The line is between a check's expectation
  and a published field's claim.
- **The declaration is the Chair's, the driver was frozen for the card, and the artifact is a record.** A
  fix that edits any of them to make the live script true is not a fix.

## What the Chair actually did, and in what order

The implementer **landed, then routed for ratification**, and gave the reason rather than assuming consent:
while the ratification is pending, the unfixed state publishes a falsehood on any re-run and the fixed state
publishes a truth. **The reversible side is the one to occupy while a decision is pending** — and the
reversal was one string, quoted verbatim in the pre-registration and in the commit that removed it, with no
record, criterion or artifact having to move with it.

The review that produced this ruling was **independent of the handoff narrative**: the pre-edit text was
recovered from git as an AST constant and compared with the record *before* the summary was read; the claims
were rebuilt with the reviewer's own harness under the guard (the implementer's probe was not trusted as the
instrument); the carrier count, the only-write claim and the frozen inputs were re-derived rather than
quoted. Two of the four findings that came out of that — the digest clause and the arm-name gap — are in the
sentence and the instrument, and neither was visible from the narrative.

**Nothing was rubber-stamped, and the decision was still ratified.** A reviewer who ratifies a *decision*
while naming two defects in the *text* is doing the job: the shape was right, the sentence was not yet.
