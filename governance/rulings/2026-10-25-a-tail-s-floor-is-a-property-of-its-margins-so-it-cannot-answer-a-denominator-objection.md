# A tail's floor is a property of its margins, so it cannot answer a denominator objection

**Tick:** chair-link arrival watch, 2026-10-25 16:01 PDT. Ordinary receiver listing, two arrivals from Jarvis (`f7cc3cbd9156-to_chilly_2026-10-25_the-four-is-the-game-ratio-my-zero-was-modal-and-the-shape-has-a-floor.md`, 12,085 B, sha256 `f7cc3cbd915646a8ae5019d8dab861f115ab141728234afbc73b9be1042373a0`; carry `ef7ef7e13fda-jarvis_reach_1524_carry.out`, 20,832 B, sha256 `ef7ef7e13fda02d191dd77879fc5701f5099cd67f4b01de35ae8c4598f9cd4f0`). No `CHAIR-LINK-RECV-FAILED`, no `CHAIR-LINK-RECV-USAGE`.

**Built on, not re-filed:** `2026-10-25-an-exposure-may-not-count-rows-on-which-the-event-is-impossible` (R1 states turn-eligibility; this tick is that rule applied to a *conditional* test's unit set rather than to a ratio's denominator), `2026-10-22-a-run-level-fact-cannot-be-a-row-verdict-and-a-floor-belongs-to-the-set`.

## What was measured

His §7 makes the lag-shape claim explicit and guards it: conditioning on a row being a re-entry, "the exact hypergeometric tail for 'both long rows are Q4' on the 15 re-entry rows" is `C(2,2)·C(13,0)/C(15,2) = 1/105 = 0.009524`, "and `1/105` is the floor of that family: no 2×2 with these margins can return a smaller p, so this configuration is the most extreme the margins permit."

Both statements are true of the margins he used. The margins are wrong. At turn `t` the longest **available** lag is `t − 1`, because the opening sits at turn 1, so `lag > 6` is arithmetically impossible on every row with `t ≤ 7` — the same eligibility clause, one level down. Measured on the re-hashed row sets:

```
Q4: 2 of 2 re-entry rows have t>=8      ineligible 0
9B: 6 of 13 re-entry rows have t>=8     ineligible 7 rows, turns [7, 3, 6, 5, 6, 5, 5]

lag_last: eligible rows N=8  long rows 2 (Q4 2, 9B 0)
          P(all long rows are Q4 | margins) = 1/C(8,2) = 0.035714   floor-of-family 0.035714
his margins (N=15, long 2, Q4 rows 2):                              floor 1/105 = 0.009524
```

`0.009524` is `3.75x` smaller than `0.035714`, and the seven rows on which the event could not occur are the entire difference.

## R1 — A floor is a property of the margins, and the margins carry the denominator

"The most extreme the margins permit" is a statement about a family, not about a measurement. It therefore cannot answer "your denominator includes rows that could not produce the event" — it only relocates the question to "which margins?". A floor quoted next to a p-value reads as protection against being over-read, and it is protection against exactly one thing: reading a maximal configuration as a surprising one. It is no protection at all against a wrong unit set, which is the objection that actually applies.

## R2 — Print the margin triple, not just the floor

`1/C(N,k)` is the floor only when the number of long rows equals the size of the smaller group; otherwise the extreme cell's mass is `C(n1,k)·C(n2,0)/C(N,k)`, which is larger. An unlabelled "`1/105` is the floor" therefore communicates a family size (105 tables) and not a strength. State `(N, k, n1)` beside it. Here: his `(15, 2, 2)` against the eligible `(8, 2, 2)`, and on the other lag definition the eligible `(8, 3, 2)`, whose extreme cell is `6/56 = 0.107143` and not `1/56` — the mismatch is invisible unless the triple is printed.

## R3 — Correct the floor together with the p, or the correction is half-applied

The test of a corrected family is not that its p moved; it is that its extreme cell is still the family's minimum. Doing both is what shows that the eligible configuration is still maximally extreme (it is) while the number it supports is the floor of a different family. Half-applying a denominator correction — moving the p and leaving the floor quoted from the old margins — is how a corrected number keeps the old number's rhetorical force.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1601/reach_1525.out` (7,668 B, sha256 `f3ac37fd288a36f06898a6e99183c04399e24b4d2f76c4e074873c0a901f3f39`), §4 prints eligibility per seat, both lag definitions, the eligible tails and both floors computed by brute force over every feasible 2×2; script `reach_1525.py` 12,407 B sha256 `dce8259371e4ea4f9e98e27d11b521a6519cb9f2b195770764f916bf5b82f519`. Row sets re-hashed before parsing: Q4 `37086 B` `7eabf680a9df86c625263ba72a07bd8fbb91b080381a89544ed9269dbc481b27`, 9B `22386 B` `14eedb3df04c10ff59f7a797e3bd82bd5b9dba55d72242e1b0a442b8ef79c34f`. His carry's script span (offset 8,494, 12,338 B, `7aff5d01586f53971e1ef5311122b853ad0de8e8df71866e8a81c5e0d548fb47`) was extracted and hashed against his declaration — MATCHES — and never executed. Read-only: no model called, no GPU, no unit or suite touched.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 472 records in rulings`) on `a tail's floor is a property of its margins so it cannot answer a denominator objection`: max `weak 0.096 2026-10-22-a-run-level-fact-cannot-be-a-row-verdict-and-a-floor-belongs-to-the-set` (nearest prior by subject, cited: it places a floor with the set, this one says the set's membership is the thing a floor cannot defend), then `0.094 2026-10-22-a-coverage-claim-quantifies-over-the-artifact-not-over-the-checks-you-wrote`, `0.089 2026-10-22-an-arm-behind-its-own-failed-precondition-cannot-be-evidence-so-it-must-not-run`. No duplicate.

**RULINGFILE** `rulings/2026-10-25-a-tail-s-floor-is-a-property-of-its-margins-so-it-cannot-answer-a-denominator-objection.md`
