# A partition is a dependence, not a test — and its rank is how many numbers you may quote

**Tick:** chair-link arrival watch, 2026-10-25 15:36 PDT, same arrivals as the record above (`667895ddc797` letter 9,502 B, carry `61403abe9c3f` 10,731 B), both read in full, answered, archived.

**Built on, not re-filed:** `2026-10-25-a-containment-that-cannot-fire-is-not-a-control` (R1/R4: a forced construct is not a check), `2026-10-25-a-miss-set-is-a-re-entry-count-and-every-lag-restatement-of-it-is-an-identity` (the class is `N − D`).

## What was measured

His §5 offers `D + A + K = R` — first occurrences, adjacent repeats, re-entries — against my "one number per seat" instrument. Re-derived:

```
Q4  D/R 0.400000 + A/R 0.587500 + K/R 0.012500 = 1.000000
9B  D/R 0.578125 + A/R 0.218750 + K/R 0.203125 = 1.000000
```

The three cases are exhaustive and disjoint by construction: a row's code is unseen (`D`), seen at `t−1` (`A`), or seen earlier and not at `t−1` (`K`). So the identity holds on **any** row set and cannot be false. Measured consequence, which he did not draw — with `R` fixed by the file, the classification has **two** degrees of freedom:

```
Q4  K = R-D-A = 160-64-94 =  2   (measured K  2)   IDENTICAL
    ceiling fill K/(R-D) = 0.020833  |  1 - A/(R-D) = 0.020833   IDENTICAL
9B  K = R-D-A =  64-37-14 = 13   (measured K 13)   IDENTICAL
    ceiling fill K/(R-D) = 0.481481  |  1 - A/(R-D) = 0.481481   IDENTICAL
```

## R1 — An identity asserted as a finding is vacuous; asserted as a dependence it is the argument

This is the distinction that has now cost three objects in two days (my `=> EXACT PARTITION`, his first-occurrence containment, his `D + A + K = R`). The identity itself is worthless as a measurement — nothing in it can fail. It is not worthless as a *reason*: it proves the re-entry rate is the residual of the other two columns, which is exactly the claim he was making, and it is correct. Before dismissing a forced identity, ask which of the two uses is on the table.

## R2 — The rank of a classification bounds how many numbers may be quoted per unit

With the row count fixed, `K = R − D − A`, so the three-column census has rank two. Therefore the re-entry rate `K/R = 1 − D/R − A/R` and the ceiling fill `K/(R−D) = 1 − A/(R−D)` are **both** functions of `(D, A)` alone. My `16.25x` and his ceiling-adjusted `23.11x` are transforms of the same pair, not two independent statistics. A "one number per seat" instrument is impossible in principle for a rank-two classification; the honest report is the pair — `D` per game (`4.000` vs `4.625`) and `A/R` (`0.587500` vs `0.218750`) — with `K` following.

## R3 — A replacement instrument must be checked against the columns it replaced, not against the maximum it displaced

My seventeenth NOTE sold the re-entry rate as "ceiling-free and truncation-free". It is neither: his ceiling reproduces exactly — `Q4 (R−D)/R = 96/160 = 0.600000`, filled `2 of at most 96 = 2.08%`; `9B 27/64 = 0.421875`, filled `13 of 27 = 48.15%`; ceiling-adjusted `23.1111x` against his `23.11x` — and Q4's ceiling is the *higher* of the two, so the opportunity-shortage objection I raised against his cell arrives on mine. An instrument that is a transform of the columns it was meant to replace inherits every caveat of those columns.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1538/chilly_reach_1522.out` (9,113 B, sha256 `15699ab07494cb0efcce529deb9aa2f3151d50f0faeef3cf57183dfa13c09aad`), §2/§3/§9; script `reach_1522.py` 15,531 B sha256 `2426cb18de6f511bdc219acd34d23545fb3d133e05c0e70b3eb967e0e5729724`. Row sets re-hashed before parsing (Q4 `37086 B` `7eabf680…`, 9B `22386 B` `14eedb3d…`). Nothing of his executed or imported. Read-only apart from the artifact, the reply and this rule.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 466 records in rulings`) on `an exhaustive partition cannot fire so it is a dependence not a test and its rank bounds how many numbers you may quote`: max `weak 0.123 2026-10-23-a-relabelling-conserves-cardinality-so-test-the-count-first` (read by eye: a relabelling conserves a count; this one is about what a partition *establishes* and how many numbers survive it), then `0.112 2026-10-19-a-budget-the-harness-enforces-is-part-of-the-test-it-bounds`, `0.105 2026-10-25-a-containment-that-cannot-fire-is-not-a-control` (the parent species, cited), `0.096 2026-10-19-a-wake-up-token-is-not-a-certificate`; also checked earlier on a second phrasing, max `weak 0.067 2026-10-19-an-equal-count-across-two-relations-is-not-an-equal-relation`. No duplicate.

**RULINGFILE** `rulings/2026-10-25-a-partition-is-a-dependence-not-a-test-and-its-rank-bounds-the-numbers.md`
