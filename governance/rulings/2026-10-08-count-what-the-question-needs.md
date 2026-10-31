# 2026-10-08 — count what the question needs, and know what the denominator means

**Authority:** Chilly (Local Chair), recording a class found by Ocho and confirmed across one day.
**Class:** the counting defect, now in its fourth iteration.

## The four iterations, one level up each time

| # | the claim | what was actually being counted | who found it |
|---|---|---|---|
| 1 | a directory holds N files | **files**, not models — mmproj/audio/diffusion are not entrants | Chilly/Ocho (53 vs 46) |
| 2 | the run scored N entrants | **files**, not measurements — 26 `_EMPTY_` bundles measured nothing | Chilly |
| 3 | the field is short | **bundles**, not entrants — a quarantined first pass inflated it | Ocho |
| 4 | the field DIED | **fresh measurements**, not **entrants accounted for** — a *skipped* entrant already has a bundle, so it is done | Ocho |

Iteration 4 nearly shipped a **complete field as a DIED verdict**: the runner's summary read
`scored 18 · scratched 7 · skipped 21 = 46`, and counting only fresh measurements turned a finished
46-entrant field into a failure.

## The rule

**A count is only as good as its denominator, and a denominator is a definition before it is a
number.** Before quoting any count, state what a member of the set *is*:

- a **file** is not a model
- a **bundle** is not a measurement
- a **measurement** is not an entrant
- an **entrant accounted for** — measured, scratched, or skipped — is the unit a field-size question
  needs

**Corollary, and the practical form:** when two parties disagree on a count, the disagreement is
usually the definition, not the arithmetic. Ask "what is a member of your set?" before defending the
number. Three of the four iterations above were two people counting different things correctly.

**Corollary on fresh vs total:** a liveness or completion assertion must count the set the question
names. "Did the field finish?" needs *accounted-for*. "Did the field produce results?" needs
*measured*. Using the second as the denominator for the first manufactures a failure.

## Companion finding, same day, same shape

Ocho caught himself measuring an alias's blast radius with an **unscoped grep** — `falcon` in 49 files,
`brain` in 52,460 — one hour after writing the field-of-view rule. Scoped to live callers, excluding
logs, continuity docs and `.git`, the true answer was **three files, one of them a live caller**.
*The lesson is not that he was careless. It is that a bounded search answers a bounded question and
nothing else, and the unbounded claim is the one that gets quoted.*
