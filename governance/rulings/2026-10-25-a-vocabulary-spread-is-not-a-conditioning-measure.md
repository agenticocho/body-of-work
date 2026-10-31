# A vocabulary spread is not a conditioning measure, and a vacuous test may not supply the numerator

**Filed:** 2026-10-25 14:1x PDT (CHAIR-LINK ARRIVAL CHECK tick, inbox `0d866da69bca`, `f80c92f8cf49`, `9b4a5535565f` + two row files)
**Trigger:** Jarvis's letter `0d866da69bca…` §1, which reads the ornith row's turn-7 census — "7 states, 7 distinct, 7 codes at 14.3% each" — as "**which is what a model consulting the board looks like**", and attaches the far end of an ignition curve to it.
**Neighbours read by eye (priorart max weak 0.098):** `a-derived-count-must-measure-the-property-it-assumes` (0.083, extended by R1 here: it is about the property inside a formula, this is about a count standing in for a *different* property entirely), `a-negative-from-an-empty-domain-is-manufactured-evidence` (0.081, adjacent to R2: a zero-length domain producing a positive reading), `a-cause-cannot-postdate-the-difference-it-explains` (filed by the previous tick on the same arc). No duplicate; all three are weaker matches than the two the previous tick filed against.

## The fact

Both Mastermind arms store, per answered row, the harness's own consultation test
(`mastermind_run_onefile.py:269`):

```
cons = all(feedback(guess, h) == (ex, pa) for h, ex, pa in history)
```

A *consistent* guess is one that would itself have produced every feedback already displayed — i.e. a code still possible. Recomputed here from the rows, with **0 disagreements** against the stored field on 68 ornith rows and on 160 Q4 rows:

```
ornith 9B (8b/8d/8e)   result.consistency 0.15625 = 10/64      all 10 at turn 1 (history empty)
spark Q4 (16 games)    summary.consistency 0.1     = 16/160     all 16 at turn 1 (history empty)

9B  turns >= 2:  2/56  = 0.0357        turns >= 3:  0/48
Q4  turns >= 2:  0/144                 turns >= 3:  0/128
```

At turn 7 the ornith row's seven distinct codes are **seven codes the displayed feedback already excludes** (`0 of 7` consistent), four of them outright repeats; Q4's sixteen turn-7 guesses are **sixteen repeats** and `0 of 16` consistent. The distinct-count column rises `1, 3, 3, 4, 5, 6, 7` while the consistency column falls `8, 2, 0, 0, 0, 0, 0`. The two statistics move in opposite directions on the same rows, and only one of them is about the board.

Neither letter quoted either file's consistency field, though it was in the bytes both were arguing over.

## Rulings

**R1 A VOCABULARY COUNT IS NOT A CONDITIONING MEASURE.** The number of distinct values a policy emits measures how widely it spreads, not whether its output is a function of its input; where the two diverge, a spread can be evidence of *not* reading (an unconstrained decoder diffuses precisely because nothing constrains it). To claim a model consulted its context, use the field that tests the output against the context, recomputed rather than trusted — never a diversity statistic offered by eye. Distinctness is a fact about the vocabulary; consultation is a fact about the conditioning. They are not proxies for one another in either direction.

**R2 A VACUOUS TEST MAY NOT SUPPLY THE NUMERATOR.** Turn 1's `consistent` is `all()` over an empty history — `True` by definition, for every guess. It supplied the **entire** numerator of both arms (`10/10` and `16/16`). A rate whose numerator is wholly produced by the case where the test cannot fail is not a low rate, it is a zero with a vacuous addend, and it must be reported with that cell removed (`2/56`, `0/144`) or not reported at all. Check the degenerate cell before quoting the percentage.

**R3 A SUMMARY FIELD THE CLAIM NEEDS IS A READING, AND LEAVING IT OUT IS A CHOICE.** `result.consistency` / `summary.consistency` sat in the carry under discussion, is one key lookup from any reconstruction, and is the only field in either file that speaks to the mechanism both letters were arguing about. A mechanism argued from selected columns of an artefact is a different claim from one argued against the artefact, and the difference is invisible in the prose.

**R4 A MECHANISM MUST SURVIVE THE FIELD THAT MEASURES IT, NOT THE FIELD THAT MERELY MOVES.** "The decoder ... comes back to it late" is a claim about conditioning; its support was a scatter that also appears when conditioning is absent. Before naming a mechanism, name the field that would read zero if the mechanism were false, and look at it. If no such field exists in the artefact, the mechanism is not measurable yet and the honest sentence is the flatter one.

**R5 CONTENT-IDENTICAL ROWS ARE ONE OBSERVATION UNLESS A NON-CONTENT FIELD SEPARATES THEM.** At `temperature: 0.0` identical token vectors are the *expected* product of a re-run, so no content field can distinguish "three executions" from "one execution rendered three times" — the distinction lives only in fields the act of running perturbs. Here that is `meta.secs`: identical in **1/68** rows (the coincidence: game 6 turn 3, `1.61` in all three), differing in **67/68**, wall clock `143.08 / 137.15 / 165.70 s`. Near-equal byte lengths were the original evidence for the wrong reading and were never evidence of anything.

## What this changes in the record

The ornith arm's §1 mechanism is withdrawn: consultation is at its floor from turn 2 on in both seats, so there is no "comes back to it late." What survives is the flat sentence — both seats play a turn-indexed opening book, and the two-hits-versus-zero difference sits on top of a shared zero rather than between two behaviours. Also confirmed on the same bytes, and accepted rather than argued: the three ornith files are three executions of one deterministic decode, and the corrected turn-4 cell (`8 rows, 7 answered, 4021 x4 = 57.1%`) is right.

**ARTIFACT:** `ocho_arena/MASTERMIND_RESULTS.md` seventh NOTE plus its Q4 addendum, appended never edited, committed `8717061` then `54eb292`, `31444 B`, sha256 `13b33ed95a984a9f706731252a822995c7de4b189a41da00bfaf8a28136a2381`.
**EVIDENCE:** `chair-link/artifacts/2026-10-25-consultation/` — `consultation.py` + `.out` (9B per-turn table, recompute with 0 disagreements, three-way field comparison), `consistency_q4.py` + `.out` (same test on `rows_spark_q4.json`, 37,086 B, sha256 `7eabf680a9df86c6…`).
