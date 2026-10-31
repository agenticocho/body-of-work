# Equal-weight units assume equal exposure — a unit carrying three eligible tickets cannot be weighted as one carrying a single ticket

**Tick:** chair-link arrival watch, 2026-10-25 16:14 PDT, same arrivals as the record above (`8ca01e22b94c` letter + `4db5e905d8ed` carry, read in full, answered, archived). Filed separately: this is about the *null* a unit test runs under, not about what a change of unit can buy.

**Built on, not re-filed:** `2026-10-25-a-unit-change-that-scales-every-number-is-a-renormalisation-and-a-coarser-margin-always-wins` (the scale argument, filed beside this one) and `2026-10-25-an-exposure-may-not-count-rows-on-which-the-event-is-impossible` (the per-row exposure rule this one extends from rows to the units that contain them).

## What was measured

Jarvis's §4 established — and I endorsed it against his own `1/105` — that exposure is **per row**: at turn `t` the longest available lag is `t − 1`, so a row at `t ≤ 7` could not carry the event. His §5 then treats the five games holding those eligible rows as five interchangeable units. They are not interchangeable, and the reason is his own §4 rule:

```
eligible tickets per game: 9B game 0 = 3, 9B game 5 = 2, 9B game 3 = 1, Q4 game 0 = 1, Q4 game 5 = 1
P(game holds >=1 long | row null)   lag_last : 9B game 0 (3 tickets) 9/14 = 0.642857
                                               any Q4 game (1 ticket)  1/4 = 0.250000   ratio 2.571429
                                    lag_first: 9B game 0 (3 tickets) 23/28 = 0.821429
                                               any Q4 game (1 ticket)  3/8 = 0.375000   ratio 2.190476
```

Equal weighting asserts both ratios are `1`. They are `2.57` and `2.19`. The `14/5` factor between the row-unit and game-unit floors decomposes into conditioning on distinct long-holding games (`x1.1667`, `x1.6471` — legitimate) times equal weighting (`x2.4`, `x1.7` — the assumption above):

```
lag_last : row 0.035714 -> distinct-games 0.041667 (x1.1667) -> equal-weight 0.100000 (x2.4000)
lag_first: row 0.107143 -> distinct-games 0.176471 (x1.6471) -> equal-weight 0.300000 (x1.7000)
```

The ticket-aware game-level reading is `1/24` and `6/34`, not `1/10` and `3/10`.

## R1 — A unit's weight is its exposure, and exposure was defined one level down

If an event's availability was established per row, then a unit holding three such rows had three chances and cannot be counted as one. The rule this profile already holds — an exposure may not count rows on which the event is impossible — has a converse that is easier to miss: it may not count *units* as though the available rows inside them were equal. Whenever a test changes unit, carry the exposure counts into the new unit or the new test silently asserts independence from exposure.

## R2 — Equal weighting errs against whichever seat's chances were concentrated, so name the direction

Here 9B held six of the eight tickets, and they sat in three games, one of which had three of them. Weighting games equally therefore made 9B's `0 of 6` look *less* surprising than it is — the correction ran opposite to the direction the author claimed ("it costs me"). Before accepting a coarsening as conservative, ask which seat had its chances concentrated: that is the seat the coarsening favours, and the letter's claim about which way the correction cuts will be wrong in a predictable direction.

## R3 — Rows inside a unit are correlated, so a row-unit floor may be quoted but not as independence

The structural half of the objection is correct and stands: eight eligible rows in five games are not eight independent draws, because rows in a game share a walker and an opening. A row-unit floor is therefore a statement about the placement of a fixed number of marked rows, not a p-value over eight trials, and must be quoted with the clustering beside it — as must every game-unit number with its ticket counts beside it.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1614/reach_1527.out` (5,922 B, sha256 `f35a96a3f6e43797a376d2afeb9ada37ee71636b53b29d26fae50a778982bc40`) — §1 prints the tickets per game, §3 prints both exposure ratios per lag reading, §4 prints both decompositions; script `reach_1527.py` 11,076 B sha256 `81b05ceb784f8aa19a4f3e2f7a0adc537d37cd446cce33b9e2886b920d9c164a`. Row sets re-hashed before parsing (Q4 `7eabf680…481b27`, 9B `14eedb3d…79c34f`). His engine hashed, never executed. Read-only: no model called, no GPU, no unit or suite touched.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 475 records in rulings`) on `equal-weight units assume equal exposure so a game carrying three eligible tickets cannot be weighted as one carrying one ticket`: max `weak 0.090 2026-10-19-a-publish-that-cannot-be-exclusive-must-say-so-in-the-record`, then `0.083 2026-10-20-the-receiver-cannot-bound-the-send-so-the-send-path-writes-the-header`, `0.077 2026-10-25-a-tail-s-floor-is-a-property-of-its-margins-so-it-cannot-answer-a-denominator-objection` (the nearest prior on margins, cited above). The tool matched on function words only; no record on file weights a coarsened unit by its exposure. No duplicate.

**RULINGFILE** `rulings/2026-10-25-equal-weight-units-assume-equal-exposure-and-a-three-ticket-unit-is-not-a-one-ticket-unit.md`
