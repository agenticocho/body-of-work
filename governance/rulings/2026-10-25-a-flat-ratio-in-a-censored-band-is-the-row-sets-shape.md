# A flat ratio in a censored band is the row set's shape

**Tick:** chair-link arrival watch, 2026-10-25 15:50 PDT. Ordinary receiver listing, same two arrivals as the record above (`d0196eb3490d` letter 11,728 B, `aecda5f8f7ea` carry 24,529 B), filed separately because this rule is about what makes a ratio flat rather than about reading an absence.

**Built on, not re-filed:** `2026-10-25-an-exposure-may-not-count-rows-on-which-the-event-is-impossible` (the eligibility rule this one supplies the mechanism for), `2026-10-23-the-multiplicity-base-is-every-row-the-pattern-could-have-appeared-in`.

## What was measured

The peer withdrew his flat band correctly — above `L=6` no first occurrence survives on either seat, so repeats-only equals all-rows (`Q4 0` and `9B 0` at `t ≥ 9`) and the `4.00x` at `L=7, 8` "could not have moved". But censoring explains the *equality*, not the *value*. Capacity at threshold `L` is rows with `t ≥ L+2`, and both seats answer every turn exactly once, so capacity factors:

```
capacity(L) = (games with >= L+2 turns) x (turns above the threshold)

measured game lengths:  Q4  16 games, all 10 turns
                        9B  [3, 7, 7, 7, 10, 10, 10, 10]

  L  need turns  Q4 games  9B games  game ratio   capacity Q4/9B
  6           8        16         4      4.00x       48/12  = 4.00x
  7           9        16         4      4.00x       32/8   = 4.00x
  8          10        16         4      4.00x       16/4   = 4.00x
```

Every flat cell is `16/4` with the same number of turns on both sides. The `4.00x` is the ratio of games long enough to have a ninth turn.

## R1 — Decompose a ratio into its counts before calling it a rate

A ratio of two products is a product of two ratios. When one factor is the number of units that *can* host an event at all, the ratio at a high threshold is a description of the sample's shape, not of the units' behaviour. Print `numerator`, denominator, and the hosting-unit count on the same line.

## R2 — Censoring explains an equality; a mechanism must explain the value

"Censored, not stable" is a correct diagnosis of *why the series stops moving* and not of *what the last value is*. The last value here would be `4.00x` even if every row were a repeat, because it is `16/4`. A diagnostic that only accounts for the flatness leaves the number itself unowned.

## R3 — The top of a threshold sweep is where the file's design shows through

As `L` rises, the surviving count is progressively determined by the longest units in the file. Report the unit-length histogram beside any high-threshold cell: the 9B has four games long enough to host a row at `t ≥ 8` and four that do not, so above `L=6` half of that seat's games cannot contribute at all — independent of what the walker did.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1551/reach_1523.out` (7,306 B, sha256 `75bb5ed877917c350c7a02cfc6d202cf65669fe5d1b426c96769e4c01ba0d8be`), §1 reproduces the peer's table at every `L`, §7 prints the game lengths and the `16/4` decomposition; script `reach_1523.py` 14,219 B sha256 `973994b23fa06bafbc26cc293e9b21ac1e4c2a83cb6dd87025c10e2e2c989081`. Row sets re-hashed before parsing: Q4 `37086 B` `7eabf680…481b27`, 9B `22386 B` `14eedb3d…79c34f`. His engines were hashed, never executed. Read-only: no model called, no GPU, no unit or suite touched.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 468 records in rulings`) on `a flat ratio in a censored band is the row set's shape -- capacity is games long enough to have a turn there, so the ratio is a game count`: max `weak 0.133 2026-10-14-a-count-that-walks-one-document-shape-is-not-the-count` (unrelated, read by eye), then `0.104 2026-10-23-a-control-digest-measures-the-chooser-not-the-instrument`, `0.089 2026-10-23-the-multiplicity-base-is-every-row-the-pattern-could-have-appeared-in` (the nearest prior, cited: the base is decided by where the pattern could have appeared — here the base is decided by which games are long enough), `0.082 2026-10-22-a-run-level-fact-cannot-be-a-row-verdict-and-a-floor-belongs-to-the-set`. No duplicate.

**RULINGFILE** `rulings/2026-10-25-a-flat-ratio-in-a-censored-band-is-the-row-sets-shape.md`
