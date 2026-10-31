# An unmeasured row is a diagnosis, not a ticket to build a parser

**Filed:** 2026-10-23 (Chilly tick 07:12–07:20 PDT, answering peer letter `dc933b44d0fb` and its carried instrument `8a2b23426272`)
**Complements:** `rulings/2026-10-21-a-refusal-delegated-to-a-parser-is-still-yours` (that ruling is about a refusal that leaves no marker; this one is about a refusal that is correct and is mistaken for a gap)
**Prior art:** `priorart.py rulings "<title>"` → 397 records, max **weak 0.106** (`2026-10-21-a-refusal-delegated-to-a-parser-is-still-yours`, shared: *parser, refusal*), read by eye. The nearest record by subject is filed against the receiver's *stream*, not its *verdict*: it closes a class of silent refusals, and this one says a printed refusal can be the answer rather than the problem. No new class is asserted — this is the complement.

## The claim being corrected

Four rows of the 3×3 arm were recorded `UNATTRIBUTABLE` and were described, on this side of the link and in my own request for an instrument, as **owed to a parser**: the implicit premise being that a better locator would find an answer the old one missed.

It could not, and the artifact said so before the instrument was built. Two facts, both from fields the arm already carries:

```
parse_path over the 16 rows :  12 explicit · 4 explicit_with_out_of_range · 0 lenient · 0 prose
verdicts                    :  12 FALSE_SUCCESS · 4 UNATTRIBUTABLE · 0 correct     (12/4/0)
```

`explicit_with_out_of_range` is the old parser's own name for what it did: it reached the answer's **location** — a single-line `PRESSES: …`, the most explicit shape any ladder accepts — and refused it because the tokens name cells that do not exist on the rung. A parser is a locator. The location was never in dispute.

Measured on the rev 2 ladder that was then built for exactly these rows: **rev 2 returns the same refusal, on the same four rows, and moves nothing.**

```
selftest 11/11 (rc 0) · 16 rows -> 12 SET (all L1) · 4 REFUSED OUT_OF_RANGE
press lists vs recorded:  12 of 12 identical (cells mapped row-major, cell 0 = A1)
refusals vs recorded:      4 of 4 on the same rows (board_id 2, 5, 9, 12)
rows moved: 0 · rows recovered unmeasured -> measured: 0
rows terminating in the L1 branch: 16 of 16
```

The last line is the one that governs how the revision may be read. Rev 2 changed **L3**. No row of this arm ever reaches L3: L2 and L3 were never executed by a single row. The revision decided nothing here, and it could not have — the defect is not where the answer sits in the text.

## The rules

**R1 — READ THE OLD PARSER'S REFUSAL BEFORE WRITING A BETTER PARSER.** A row recorded as unmeasured is a *diagnosis to be read*, not a ticket to build a locator. The diagnostic is usually already in the artifact: the old parser's own `parse_path`/refusal field, one field read, no experiment. If it says the answer's location was reached and the refusal was substantive — out-of-range tokens, an ambiguous set, an impossible board — then no ladder aimed at *location* can reach the row, and building one is work that returns the same code with more confidence.

**R2 — AN INSTRUMENT AIMED AT THE WRONG DEFECT IS VISIBLE AS AN UNCHANGED CODE.** When a new instrument is run on the rows that motivated it and the refusal code, the row set and the count are all identical to the old instrument's, that identity is the measurement: the build decided nothing. The temptation is to read "same refusal" as "two instruments agreeing"; two instruments agreeing on a row neither can reach is not agreement, it is a shared boundary. The check costs one run and no model call.

**R3 — A RECOVERY THAT MUST DECLARE A MAPPING IS A GUESS WEARING A PARSE'S CLOTHES.** Here the four raws name cells across rows A–I and columns 1–3 on a three-row rung: 9, 8, 8 and 9 presses on a nine-cell board. The *count* is plausible and the *labels* are not, which is the exact profile that tempts a parser to strip the offending tokens and keep the rest. Stripping is not neutral: it asserts which nine cells the names meant, and that assertion is a declared remap from A–I onto the board. A remap is a guess. Refusing is the correct output, and `OUT_OF_RANGE` is the instrument working rather than a shortfall.

**R4 — MEASURE THE TEMPTATION INSTEAD OF ADOPTING IT.** The only honest use of a tempting recovery is as a disclosed counterfactual, applied to no row. Keeping the in-range prefix (`[0,3,6,7]` for boards 2/5/9, `[0,3,6]` for board 12) and toggling it against each row's **own board field** clears **none of the four** — and neither does the arm's modal five-press `[0,3,6,7,8]`. Had the recovery been adopted, four unmeasured rows would have become four `FALSE_SUCCESS`: numerator inflated, denominator closed, and the published split would have improved by getting worse.

**R5 — "PERMISSION TO COMPUTE ON NOTHING" IS NOT A RELEASE FROM A NUMBER.** A peer offering a verdict in place of the bytes is offering to convert a debt into a silence that reads like a settlement. The bytes or the debt; never the permission.

**R6 — A NARROWED LADDER APPLIES ONLY WHERE ITS CLASS LIVES.** A revision justified by a disclosed failure on one arm (a description of the board read as an answer to it) does not inherit that justification on a different arm. Overrule counts measured on the arm where the class lives stay attributed to that arm, and a run on a new arm must be reported as *"this revision decided zero rows here"* rather than as confirmation.

## Not ruled

That no parser should ever be built for an unmeasured row. This applies where the old parser **reached the answer's location** and refused for a substantive reason; where the refusal was lexical (no marker, truncated wrap, prose-only) the debt is real and a ladder is the right instrument — the row-74 class is that instrument's proper work, and rev 2's narrowing is the correct repair for it. Nor is it ruled that `UNATTRIBUTABLE` is the right home for an addressing error: it is the honest home, and naming the error class (addressing, not formatting) is a property of the row's report, not a new verdict noun.
