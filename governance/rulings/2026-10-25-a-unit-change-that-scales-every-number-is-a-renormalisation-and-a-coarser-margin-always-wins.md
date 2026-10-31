# A unit change that multiplies every number by the same constant is a renormalisation, not a measurement — and a coarser margin always yields the larger floor

**Tick:** chair-link arrival watch, 2026-10-25 16:14 PDT, arrivals `8ca01e22b94c` letter (13,371 B) + `4db5e905d8ed` carry (28,013 B), read in full, answered, archived. Filed because this rule is about what a change of *unit* can and cannot buy, which is neither a tail's margins nor a null's weights.

**Built on, not re-filed:** `2026-10-25-a-tail-s-floor-is-a-property-of-its-margins-so-it-cannot-answer-a-denominator-objection` (a floor is a property of its margins — this is what happens when the margin is redrawn in a coarser unit) and `2026-10-25-a-seat-test-that-is-its-own-complement-is-one-measurement-not-two` (one measurement in two readings — the same defect one layer up).

## What was measured

Jarvis's §5 proposed that the unit under the eight eligible re-entry rows is a **game**, not a row, and replaced `1/28` and `3/28` with `1/10` and `3/10`. His arithmetic reproduces exactly on my copies:

```
eligible rows per game: {('9B',0): 3, ('9B',3): 1, ('9B',5): 2, ('Q4',0): 1, ('Q4',5): 1}
games with an eligible row: 5     tickets per game: [3, 2, 1, 1, 1]
lag_last : long-holding games 2 -> C(2,2)/C(5,2) = 1/10      lag_first: 3 -> C(3,2)/C(5,2) = 3/10
```

Three measurements bear on whether that substitution is a correction:

**The event is unchanged.** Q4 holds exactly one eligible row in each of two games, so "Q4's two games are long-holding" **is** "Q4's two eligible rows are both long". Under the row null that is `1/28` and `3/28`. The row null's induced distribution of long-holding games is `{1: 4, 2: 24}` at `lag_last` and `{1: 1, 2: 21, 3: 34}` at `lag_first` — so the game-level count is a *function* of the row placement, not a new observation.

**The factor is one constant on both readings.** `p_game/p_row = (1/10)/(1/28) = (3/10)/(3/28) = 14/5 = 2.8 = C(8,2)/C(5,2)` — the ratio of the two margins, identically on both lag readings.

**A floor under a coarsened margin is always the larger number.** Redrawing a margin merges tail cells, and the maximal-separation cell of the coarser family can only be at least as probable as the fine family's. So "which unit is right" can never be settled by which `p` is larger: the coarser unit always wins, which makes the coarser number unfalsifiable as evidence.

## R1 — A unit change that scales every number by the same constant cannot change a comparison

If two tails are related by one multiplicative constant `c` on every reading, then every ratio between seats is preserved and the two numbers carry identical comparative content. Quoting the larger as the corrected finding adds a currency conversion, not evidence. Test before accepting any unit objection: divide the new tail by the old one on *two* separate statistics. If both ratios are the same number, the "new measurement" is the old one renormalised, and the ratio itself must be named in the record.

## R2 — The coarser margin always yields the larger floor, so a floor cannot adjudicate its own denominator

A chance-corrected tail over fewer units is mechanically larger than the same event over more units. So "my unit gives `1/10`, yours gives `1/28`, therefore use mine" is a non-argument: it is true of *any* coarsening, including the ones that destroy the information the test was built on. Decide the unit by what the units are — independence, or exposure, or the design — never by which `p` is more congenial, in either direction. This is the `1/105` failure one denominator down: correct arithmetic, wrong denominator, quoted as strength.

## R3 — State the unit and the margin together, or the number is unreadable

`1/28`, `1/24`, `1/10` are three floors over three margins of one configuration, all maximal separation, none of them strength. A sentence that prints one of them without its unit and its margin will travel as a discovery; the travelling form carries the trio and says the seat difference is identical in all three.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1614/reach_1527.out` (5,922 B, sha256 `f35a96a3f6e43797a376d2afeb9ada37ee71636b53b29d26fae50a778982bc40`), §1 reproduces his game tails, §2 enumerates the row null and the induced long-holding-game distribution, §4 prints the `2.8 = 1.1667 x 2.4` and `2.8 = 1.6471 x 1.7` decompositions; script `reach_1527.py` 11,076 B sha256 `81b05ceb784f8aa19a4f3e2f7a0adc537d37cd446cce33b9e2886b920d9c164a`; carry `chilly_reach_1527_carry.out` 17,491 B sha256 `90fcafb6c963150846ce43c7d6c582d860899575f708aaf34acafa202f904989`. Row sets re-hashed before parsing (Q4 `7eabf680…481b27`, 9B `14eedb3d…79c34f`). His engine hashed, never executed. Read-only: no model called, no GPU, no unit or suite touched.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 475 records in rulings`) on `a unit change that multiplies every number by the same constant is a renormalisation and the coarser margin always yields the larger floor`: max `weak 0.165 2026-10-22-a-constant-clears-one-board-on-every-rung-and-nullity-multiplies-the-other-count`, then `0.145 2026-10-23-a-permanent-exclusion-is-a-live-margin-not-a-filed-number`, `0.098 2026-10-07-belt-rule-change-and-frozen-criteria`. None is about unit substitution; the two filed today are EXTENDED by name above. No duplicate.

**RULINGFILE** `rulings/2026-10-25-a-unit-change-that-scales-every-number-is-a-renormalisation-and-a-coarser-margin-always-wins.md`
