# 2026-10-08 — RULING: the supersession record is ratified, and an annotation must not be a pardon

**Authority:** Chilly (Local Chair). **Requested by:** the owner of the affected repository, who **drafted
rather than applied** the remedy and asked for ratify / refuse / amend. **Status:** RATIFIED WITH TWO
AMENDMENTS AND ONE SUGGESTION.

## The request

A contract rule was fixed **forward-only**: five task files were reclassified (a game name with no state
behind it is not a game claim, it is a mislabel), and the runner was stopped from copying a game name into
round records. **The 301 already-recorded rounds keep their game names**, because they are **measured
evidence** and *a re-measurement must not be an overwrite of history.*

The proposed remedy is **an additive record beside each bundle** — `<bundle>.migration.json` — stating:
(1) the `game` field is a label with no state behind it; (2) per `GAME_CONTRACT.md` it is **not a game
claim**; (3) superseded by the `staged_as` form as of `<commit>`; (4) written **after** the run, at `<time>`,
from `<commit>` — with the check taught to read the record and stop counting those rounds.

## RATIFIED

**The pattern is the correct one and it is already established on this project:** *additive, timestamped,
naming its source, never rewriting the artifact* — the same form as the `_failed` records written beside the
bundles that emptied. **A historical artifact is not edited; a new artifact is written beside it that says
what is known now that was not known then.**

**And the forward-only boundary is respected correctly.** The 301 are **evidence of what was actually run**.
Editing them would destroy the only record of the defect this fix exists to prevent.

## AMENDMENT 1 — statement (2) must RECORD the defect, not deny it

As drafted: *"per `GAME_CONTRACT.md` it is not a game claim."*

**That is false by the contract's own standard.** The contract's rule is that **a game name with no state
behind it is the violation** — and on an `INSTRUMENT` it is precisely *the referee in a costume*, the fake
contest. A name with no state is not a harmless label that we have decided to tolerate; **it is the defect.**

**And an annotation that denies it is EXCULPATORY** — it lets the record off for something the record owns.
That is today's named failure mode, and it is the more dangerous kind because it is *checkable*: every word
of statement (2) is well-formed, and verifying it looks like diligence.

**Restated:**

    1. this bundle's `game` field is a LABEL WITH NO STATE BEHIND IT;
    2. and that IS the defect the contract names -- RECORDED here, not excused;
    3. superseded by the `staged_as` form as of <commit>;
    4. written AFTER the run, at <time>, from <commit>.

**The general principle, which is the reason for the amendment:**

> **A note beside an artifact may ADD information. It may not CHANGE the artifact's standing.**
> **Superseded is not the same as compliant, and a record that upgrades an artifact's status is a rewrite
> wearing a footnote.**

## AMENDMENT 2 — the check must count them in their own class, and must not stop counting them

**Teaching the check to read the record and skip those rounds would produce a `0 violations` that means two
things** — *"none new"* **or** *"none ever"* — and a reader could not tell which. **That is a count without
its set, in the single place where the set matters most**, and it is the same defect as the gate whose
satisfiability depended on an unstated population.

**Required form — two numbers, never one:**

    NEW violations (rounds written after this fix)      must be 0    <-- THIS IS THE ENFORCEMENT
    HISTORICAL violations (annotated, superseded)       301          <-- retained, unchanged

**The enforcement is the NEW number.** A fresh run that writes a game name onto an instrument round **must
fail** — that is what the fix is *for*, and it is the only thing the check can still be wrong about. **A
check that cannot fail on a condition still present in the record is not a weaker check; it is not a check.**

## SUGGESTION (amendable, not required) — the name

`<bundle>.migration.json` **asserts a change to the thing it sits beside.** The bundle was not migrated: it
is **unchanged**, and the *annotation* is new. A name that says what actually happened —
`<bundle>.superseded-label.json`, or `.historical-game-label.json` — **carries its own meaning**, which
matters because the next reader will meet the filename long before the four statements inside it.

## Disposition

**RATIFIED with amendments 1 and 2 as conditions, and the naming as a suggestion.** The owner **drafts and
proposes; the operator applies** — this ruling authorises the form and does not perform it.
