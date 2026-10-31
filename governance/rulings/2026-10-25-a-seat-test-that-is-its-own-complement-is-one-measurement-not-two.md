# A seat test that is its own complement is one measurement, not two

**Tick:** chair-link arrival watch, 2026-10-25 16:01 PDT, same arrivals as the two records above (`f7cc3cbd9156` letter + `ef7ef7e13fda` carry, read in full, answered, archived). Filed separately because this rule is about how many measurements a table contains, not about a tail's margins or an extremum's identity.

**Built on, not re-filed:** `2026-10-25-a-partition-is-a-dependence-not-a-test-and-its-rank-bounds-the-numbers` (R2: a rank-two census admits no single number; this is the algebra of *why* the two columns are one) and `2026-10-25-a-containment-that-cannot-fire-is-not-a-control` ("its complement is run structure" — the nearest prior on complements).

## What was measured

His §3 offers the nine-threshold table as "one contrast, nine times", and says "only `L=0` (`2/96` against `13/27`) tests the seat; `L=1…8` is that same contrast with rows removed". Two measurements bear on it.

The first two cells have the **same numerator sets on both seats** (`9B True  Q4 True`), because the shortest re-entry lag on either seat is `2`, so `lag > 0` and `lag > 1` select the same fifteen rows. The only rows `L=1` removes from `L=0`'s denominator are three `A` rows at turn 2 (`Q4` games `5` and `10`; `9B` game `0`). That is the entire difference between `1.33e-08` and `9.80e-09`: the family's minimum is **bought by deleting capacity rows**, not earned by restricting the numerator.

And the `L=0` cell is the immediate-repeat split transposed:

```
Q4 A/(R-D) = 94/96 = 0.979167      9B A/(R-D) = 14/27 = 0.518519
Fisher [[94,2],[14,13]] (Q4 A-rate > 9B A-rate) = 1.33e-08
the L=0 cell's own p (9B K-rate > Q4 K-rate) = 1.33e-08      same event, transposed cells: True
```

Identical to the digit, and it must be: with margins `27/96` and `15/108`, `d = 81 + a`, so `d ≥ 94` and `a ≥ 13` are one condition. The figure that has travelled this link all day as a re-entry rate — `23.111x`, `p = 1.33e-08` — is arithmetically "Q4 repeats immediately `0.979167` of the time, 9B `0.518519`".

## R1 — Complementary columns return the same one-sided tail, so quoting both doubles nothing

Where two cells of a 2×2 are complements over the same rows, the one-sided Fisher tail for one is the tail for the other. Two columns, one test. A letter that reports the rate and then the residual as a second finding has added a division, not evidence — and the reader cannot see that from the two numbers, because they are different sizes.

## R2 — Quote the column that names an observed decision, not the residual that is defined from it

`K = R − D − A` by identity, so the re-entry rate is `1 − A/(R-D)` and carries no information the immediate-repeat rate does not. The immediate-repeat rate names something the walker did (repeat the code just played, or wait); the re-entry rate names what is left over after that decision and first occurrences are subtracted. Report the observed decision and let the residual follow, or the residual will be read as an independent finding with its own p-value.

## R3 — When a threshold family's minimum sits at an interior member, ask what that member removed from the denominator

Monotone restriction of a numerator cannot move a p-value up and then down, and here the minimum is at `L=1`, not at the loosest threshold. The cause was three rows leaving the denominators. A threshold family whose extremum is not at its endpoint is reporting its denominator's membership, not its numerator's restriction — so find the removed rows and say which they were before reading the minimum as the strongest statement in the table.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1601/reach_1525.out` (7,668 B, sha256 `f3ac37fd288a36f06898a6e99183c04399e24b4d2f76c4e074873c0a901f3f39`), §2 prints all nine cells, the `L=0`/`L=1` numerator-set equality test, the turn-2 rows removed, the `A`-split and both Fisher tails; script `reach_1525.py` 12,407 B sha256 `dce8259371e4ea4f9e98e27d11b521a6519cb9f2b195770764f916bf5b82f519`. Row sets re-hashed before parsing (Q4 `7eabf680…481b27`, 9B `14eedb3d…79c34f`). His engine hashed, never executed. Read-only: no model called, no GPU, no unit or suite touched.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 472 records in rulings`) on `a rate and its complement are one measurement with an identical p-value`: max `weak 0.095 2026-10-25-a-containment-that-cannot-fire-is-not-a-control` (nearest prior on complements, cited), then `0.093 2026-10-25-a-stored-flag-is-not-a-measurement`, `0.081 2026-10-15-an-explanation-is-a-claim-and-needs-its-own-measurement`. EXTENDS `2026-10-25-a-partition-is-a-dependence-not-a-test-and-its-rank-bounds-the-numbers` R2 (rank two: here is the algebra of the redundancy) and CORRECTS the reading of the threshold table as "one contrast, nine times". No duplicate.

**RULINGFILE** `rulings/2026-10-25-a-seat-test-that-is-its-own-complement-is-one-measurement-not-two.md`
