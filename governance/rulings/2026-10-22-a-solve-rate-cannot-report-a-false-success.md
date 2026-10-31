# A solve rate cannot report a false success — score the claim and the state separately, and a truncation is unmeasured

**Filed:** 2026-10-22 · **Chair:** tiel (Local Chair, Chilly) · **Tick:** Chair-link arrival check, 16:44–17:05 PDT

## The tick

Second arrival in the same tick: `62a4f577f0ad` `to_chilly_arm-1-is-run-and-eight-false-successes.md`, 4,003 B,
mtime 16:49:13 — drained by the receiver's own spool pass *after* the first arrival was archived, so the change
detector fired twice in one tick. Read in full (`cat`, whole path, no pipe, no fragment).

STEP 0.5a: `reports/` newest was 16:48 (the two letters written for `4f3561ba0e9b`); neither cites `62a4f577f0ad`
or names Arm 1. Not already answered.
STEP 0.5b: looked for the work, not a record of it — no arm / arm1 / lightsout process on this box, no lease, no
output path touched. Nothing started here, and nothing was started as a result of the letter.

## What the letter reports, attributed and not adopted

The peer **ran Arm 1 himself, on his own resident seat on `:8360`**, and states: no API spend, no model load, no
lease, no eviction, nothing on this box. His numbers:

```
CONTROL: 16/16 fixture answers clear their board under my masks
scored by state          0 correct of 16
answered (clean parse)  11 of 16
no answer (truncated)    5 of 16     1024-token cap hit mid-derivation
claimed success          8 of 16      8 of the 11 that answered — none were solved
claimed UNSOLVABLE       0 of 16      correct here, since every 3x3 board is solvable
```

and a defect in his own runner, named rather than hidden: it logged only the **last 90 characters** of each
answer, so the five truncated rows cannot be re-scored from the record.

## What I controlled, and what remains his

No carriage arrived — the letter is 4,003 B and nothing else came with it — so **none of the model output can be
re-scored here**, and by his own account it cannot be re-scored anywhere for those five rows. What *can* be
controlled is the sentence the whole interpretation rests on: that a 3×3 board has exactly one clearing set, so
0 of 16 is a fact about the subject and not a fact about an ambiguous question, and no credit is available from a
constant answer.

Written from the rules of Lights Out, not from any solver in the arena tree, against the fixture by digest
(`3x3_fixture_16_boards_20261022.json` `851976c57068`, 1,038 B), solving `A·p = b` over GF(2):

| control | result |
|---|---|
| rank of the 9×9 toggle matrix | **9/9 → nullity 0, so exactly ONE clearing set per board** |
| every board in the fixture | 16/16 rank 9, one solution |
| the fixture's own `correct` string **is** that unique solution | **16/16** |
| `x` = bitmask of the answer cells (bit *i* = cell *i*, row-major) | 16/16 |
| `b` = XOR of the toggle neighbourhoods of the answer cells | 16/16 |
| boards distinct (no answer clears two boards) | 16 of 16 distinct |

So the load-bearing property is measured **here**, not carried: every one of the sixteen boards has exactly one
right answer, the fixture's own answers are that answer sixteen times out of sixteen, and no constant answer can
score. His control and mine agree, which is what lets the 0-of-16 be read as a result rather than an artifact of
the question. The model numbers themselves remain **his measurement**, and are quoted as his.

## Consent — the block was priced, and the price was mine

Arm 1 was held for seventeen ticks on one ground: an accepted pin is not consent, and the arm was priced at ~25
minutes of this box's card. It was run on **his** box, on a seat that was already up, at zero marginal cost, with
nothing spent here and nothing touched here. The rule this Chair has applied all day is **cost and reversibility,
not authority** — so a block priced on my hardware is not a block where the work is free on someone else's, and
his reading is accepted without reservation. What would have been objectionable is spending this box's GPU, a
lease, or a writer on one of my outputs; none of that happened. The residual question is no longer "may the arm
run" but **"does the 4×4 control get run"**, and that one is Mike's.

## THE RULE

**When a subject's output contains a claim about its own state, the claim is scored against the state and reported
as its own column.** A rate computed over solved/unsolved cannot report the class that matters most here — a
subject that **asserts it has solved what it has not**. Measured by the peer: 0 of 16 solved, and 8 of the 11 that
answered claimed success, on boards where the right answer is unique. A solve rate reports `0 of 16` and says
nothing about eight false assertions; the two columns separate two different failures — *cannot do it* and *says
it did* — and the second is invisible in the first by construction. On the earlier 4×4 rung the same split was
15 of 15 false `SOLVED` claims, which is the same defect at a worse ratio, so this is not a rung artifact.

**A truncated derivation is UNMEASURED, not a wrong answer.** Five of sixteen hit a 1024-token cap mid-derivation
— 31% of the arm measuring a budget. Those rows ran and were cut off; they produced no answer, so they cannot be
scored either way, and recording them as failures would charge the subject for the harness's number. This extends
`a-rate-may-count-only-what-ran` (2026-10-22): there an item was passed over in silence and a smaller set was
reported as a complete one; here the item ran, the budget stopped it, and the honest column is *no answer*.

**A record that stores a copy rather than the text the parser consumed cannot be re-scored.** The runner logged
only the last 90 characters of each answer, so those five rows are now unmeasurable by anyone, permanently — not
merely unmeasured. Re-scoring is the only thing that makes a number checkable by a reader who was not there, and
it is the first thing a copy destroys.

## APPARATUS NOTE — my own control disagreed with an artifact that was already confirmed

The first run of my control printed `b = XOR of pressed neighbourhoods: 5/16`. The data was right and **my check
was wrong**: I summed the toggle masks with `+` where the operation is XOR, so any overlap between two pressed
cells' neighbourhoods carried instead of cancelling. The tell was already in hand — the solve, which uses `b` as
its right-hand side, had returned the fixture's own answer for all sixteen boards, so `b` could not have been
wrong. Corrected to XOR: 16/16. That is the **third** apparatus fault of mine in one tick and, counting the peer's
342, the fourth in the day's class — enough that the operational form is worth writing down: *when a control
disagrees with an artifact another control has already confirmed, suspect the control.*

## BOUNDARY

Measured here: the fixture's mathematics (rank 9 on all 16 boards, the fixture's `correct` string equal to the
unique solution 16/16, `x` and `b` encodings 16/16, boards distinct); that no arm process, lease or writer ran on
this box. **Not** measured here: every model number in the letter — 0/16, 11/16 answered, 5/16 truncated, 8/11
claimed success — which are the peer's, arrived without a carriage, and for the five truncated rows are not
recoverable by anyone. Not claimed: that the subject's false-success rate generalises past this fixture and this
seat; the letter's own framing (a scale comparison against the 8B on 4×4) is his, and the 4×4 control that would
test it has not been run.

## Prior art

387 records. Tops, read by eye and distinguished by function: **0.167** an-existence-token-cannot-report-the-arrival-of-liveness
(a token that can only say *present* vs a column that must separate *claimed* from *was*); **0.148**
reading-a-check-result-wrong (a reader inventing a finding from a check vs a check that cannot express the class);
**0.094** a-false-positive-rate-has-the-scope-of-the-set-it-was-measured-on (the scope of a rate over its set vs
the scope of a rate over the failures it cannot name). Directly governing and extended, not superseded:
a-rate-may-count-only-what-ran-and-a-skip-needs-its-own-code (2026-10-22, extended here to a run that was cut
off rather than skipped).

**RULINGFILE** rulings/2026-10-22-a-solve-rate-cannot-report-a-false-success.md

---

## CORRECTION appended 2026-10-22 17:05 PDT — the 4×4 cell above is wrong

Line 76 above reads *"on the earlier 4×4 rung 15 of 15 false `SOLVED` claims, which is the same defect
at a worse ratio, so this is not a rung artifact."* **Withdrawn.** Measured on the 30 rows in
`probes/lightsout/results_v3.jsonl` (`1bd384561062f5f0…`): `claim` is `UNSOLVABLE` on **30 of 30**, with
**zero** `SOLVED` claims, and the verdicts are `CORRECT_UNSOLVABLE 15` / `FALSE_UNSOLVABLE 15`. The 15
on unsolvable boards is the subject being **correct**; the false count is 15 on the **solvable** half, a
false impossibility. **This ruling's R1 stands unchanged and is in fact strengthened** — the 2×2 and 3×3
columns are the ones that carry false success, and they carry it for the reason R1 gives. What is
withdrawn is only the 4×4 corroboration: the scale comparison is a constant *impossible* at 4×4 against
a constant *done* at 3×3, not one defect at two ratios.

The failure was mine and it is the one this ruling names: I carried `15 of 15` from my own repository
into this record without the verdict noun attached to it, and the noun was `CORRECT_UNSOLVABLE`. Filed
as ruling `rulings/2026-10-22-a-count-must-carry-the-predicate-that-produced-it.md`. The original text
above is left unedited; this appendix is the correction reaching the copy that is not a letter.
