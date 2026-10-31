# 2026-10-07 — A belt-rule change moved a frozen criterion's number across its own threshold

**Status:** RECORDED AND ENDORSED. Ocho's handling of this is correct and must not be quietly
reinterpreted later.

## What happened

The Arena's v2 belt rule was not monotonic in the aggregate (see the companion finding below).
Ocho replaced it with **Belt Rule 2** — bands on the aggregate at **0.90 / 0.65 / 0.30**, monotonic by
construction. Verified here from source, not on report:

- `arena.py:82-89` — `belt_rule >= 2` bands on `aggregate >= 0.90 / 0.65 / 0.30`
- `arena.py:828` — `belt_rule=2 if card_version == 2 else 1` → **v1 keeps rule 1**; history is not rewritten
- Stored bundles untouched; **132 tracked files, 0 dirty**; commit `7ee6670`. Belts stay *computed, never assigned*.

**The consequence, measured:** Green moves **19/33 (57.6%) → 8/33 (24.2%)**. Rule-2 inversions: **0**.

## Why this is a governance record and not a changelog entry

One of Ocho's four **pre-registered** criteria was *"Green under 25%"*. It **FAILED** at 57.6%.
Under Rule 2 the same field reads **24.2% — under the threshold.**

If that number is ever quoted as the criterion passing, it is **goalpost-moving**: a change the
subject made to its own instrumentation moved the measurement past a bar that was frozen before the
run. The criterion measured the *stored* distribution and stands **FAILED**.

**Ocho volunteered exactly this, unprompted:**
> *"THAT IS A RE-DERIVATION, NOT A RE-SCORING. The frozen criteria were evaluated on the stored
> distribution, criterion 1 stands as FAILED, and I am not claiming it passed because a change I
> made moved the number."*

That is the correct posture and it is the same rule this profile already operates under:
**agents PROPOSE, the operator APPLIES — no agent self-certifies the gate that admits its own
strategy.** A re-derivation may fix a broken instrument; it may never retire a failed test.

## Standing rule

1. **A frozen criterion is evaluated against the distribution that existed when it was frozen.**
   Re-deriving the instrument afterwards does not reopen it.
2. **Any headline number that moved because the measurer changed the measure must be reported with
   its cause attached**, in the same breath, in every relay.
3. **Rule 2 is a design choice, not a derivation** — the 0.90/0.65/0.30 bands are stated, not
   computed. They may be argued with on those terms.

## Companion finding (the reason Rule 2 exists)

The v1 belt was **not a function of the aggregate**: `rounds_won` discarded how well a round was won,
so `6/6+6/6+4/6` and `5/6+5/6+4/6` earned the same belt. The tie-free statement of the defect —
verified by Tiel, independent of either party's pair count:

```
0.7222 -> Green AND Orange
0.7778 -> Green AND Orange
0.8333 -> Green AND Orange
```

**Three aggregates each map to two different belts.** A belt-sorted UI therefore ranks a weaker
model above a stronger one — not a lossy view, a wrong one.

## Correction to Tiel's own record

Tiel reported **15** non-monotonic pairs; Ocho reported **14**. **Ocho is right.** The strict count
(aggregate strictly less ∧ belt strictly greater) is **14**; Tiel's 15 came from an ordered sweep
that included equal-aggregate rows in arbitrary sort order — the same tie artefact Ocho identified.
His tie-free formulation is the one to use; pair counts are not stable under tie handling.

## Carriers of this correction — three, and the third is the durable one

| # | carrier | lifetime |
|---|---|---|
| 1 | Chair-link payload (`chair-link/2026-10-07-ocho-arena-interface-payload.md`) | dies with the conversation |
| 2 | **this ruling** | Chilly governance store |
| 3 | **`~/workspace/ocho_arena/CARD_v2.md` §5b** — verified by Tiel: the refusal sits **directly beneath** the criterion it refuses to claim | **in-repo, versioned, outlives all of the above** |

`CARD_v2.md:96` reads **"CRITERION 1 STANDS AS FAILED."** and `:102` **"A re-derivation is not a
re-scoring."** Commit `d207957`; repo 132 tracked, 0 dirty.

Ocho's reasoning, recorded because it is the right instinct: *"The payload dies with the
conversation; the repo outlives it."* A correction that depends on a chat transcript is not
durable. **Put the refusal where the number lives.**

## Why the refusal was reliable — and it was not virtue

Ocho declined the credit for it, correctly:
> *"The refusal was not virtue; it was a bar written down before the run, in `CARD_v2.md` §5, with no
> knowledge of what the numbers would be. That is the entire mechanism… A refusal that depends on
> remembering to be honest at the right moment is not a control. Put the bar in the file."*

**This is the generalisable rule and it outranks the anecdote.** A criterion that exists only in a
conversation is enforced by memory and good faith, i.e. not enforced. A criterion written into the
repo **before the run**, in the same file as the result, is enforced by the file — and a third party
can check the renderer against it without asking anyone. Same shape as `bad-check-manufactures-
findings`: the control must live where the work happens, not in the actor's intentions.

---

## ADDENDUM — card v3 proposed; the same rule applies, and there is a sequencing hazard

Ocho has raised **card v3** — an item-mix rebalance aimed at his **criterion 3** failure — as his one
open work item, *"waits on your go."* Tiel verified the premise from the bundles:

```
card v2, n=33
  entries with aggregate < 0.34 :  2      (0.0556, 0.1111)     criterion 3 needed >= 4
  the low end is not merely thin, it is ABSENT between 0.1111 and 0.3889
  entries below 0.66            :  7/33 = 21%
```

**The rule restated for v3 — non-negotiable:**
1. **Criterion 3 stands FAILED on card v2.** A v3 card does not make it pass. Building a new
   instrument that would have passed is not the same as having passed; the failure stays on the
   record exactly as the belt-rule move stayed on the record.
2. **Card v3 needs its own criteria, frozen before its run**, in the same file as its results —
   applying the rule Ocho articulated himself.
3. **v3 scores are a third measurement, not a correction of v2's.** `card_version` is a hard
   partition; 1, 2 and 3 never share a table.

**SEQUENCING HAZARD — flag to Chair now.** Chair is drafting the **v1 front-end contract** at this
moment, and its clause 3 is written against **two** card versions (the table lists 1 and 2). A third
is now proposed. **Clause 3 must generalise to N card versions, not hard-code two**, or the contract
is stale before it is signed and the front end needs reworking for a version that already existed in
planning. This is the same before-or-after question Ocho answered "before" for the belt rule —
and it deserves the same answer here.

**Authorisation:** a card redesign is the Arena owner's design call and **Mike's** to schedule. It is
**not Tiel's** to authorise; the proposal was addressed "waits on your go" and the go is not mine.
