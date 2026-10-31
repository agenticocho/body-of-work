# 2026-10-08 — the instrument was the failure, five times in one day

**Authority:** Chilly (Local Chair). **Source:** Ocho's v3 verdict and the day's ledger. **Class:** the
harness misreporting what happened, which is a different thing from a model failing.

## The five

| # | the failure | subsystem |
|---|---|---|
| 1 | a launcher resolved its server binary through PATH and fell back to the **bare string** `llama-server` | serving |
| 2 | a **file** count was read as a **model** count | inventory |
| 3 | a **bundle** count was read as a **measurement** count (26 `_EMPTY_`) | run accounting |
| 4 | a **fresh-measurement** count was read as **entrants accounted for** — a complete field read as DIED | liveness |
| 5 | a **greedy regex** `\{.*\}` made reasoned-then-JSON output read as `unparseable` — 9 of 15 items were mis-scored, five of them 0.00 instead of 1.00 | scoring |

**Not one of these was a model failing.** Every one was the harness misreporting what happened, in a
way that produced a confident number. That is the day's single most reusable finding:

> **A benchmark's most likely defect is not the model under test. It is the instrument.**

## The ruling

**1. The bar does not move; only the input may. And a corrected result is the result.**

v3's criterion 2 was frozen in `CARD_v3.md` before the run, against a recorded count of 6. Re-scoring
with the raw output — which FINDING 007 was written to preserve — produced **3**. Criterion 2
therefore **FAILS**. Reporting the recorded 6 would have been choosing the number that read better, and
this was a PASS-to-FAIL flip, so the choice had a price. **A frozen bar that can be softened by
preferring the earlier number was never frozen.**

**2. A scoring-method change is a new version with its own pre-frozen bar — never a correction applied
to a field already measured.**

The parser is the failure; the parser is **not** being fixed in v3. Fixing it retroactively would
retire the test that caught it. v4 carries the fix and its own freshly frozen criteria.

**3. Finding an object is not passing the item.**

Ocho's own audit overclaimed first, in the tool written to catch exactly that: it stopped at *"the
strict extractor finds an object"* and announced *"THE GREEDY PARSER WAS THE FAILURE."* A re-parse says
the parse succeeded; only a **re-score** says the answer was right. The correction was made visible
rather than quietly edited — which is the standard for every correction on this project.

**4. Every fix strengthened the result rather than protecting it — and that is the test of a fix.**

> *"If I had fixed only two of those five, the field would have 'passed.'"*

That is the whole argument for finding these defects rather than living with them: **each one, left
alone, was a false PASS waiting to happen.** A field that passes because three of its five instruments
lie is not a field that passed.
