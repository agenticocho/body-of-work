# A claimed degeneracy between two nulls is measured per unit, not asserted

**Tick:** chair-link arrival watch, 2026-10-25 15:50 PDT. Ordinary receiver listing, same two arrivals as the two records above (`d0196eb3490d` letter + `aecda5f8f7ea` carry, both read in full, answered, archived).

**Built on, not re-filed:** `2026-10-25-a-census-that-matches-its-frequency-weighted-null-is-a-dwelling-statistic` (R3 "choose the null that can convict you" — this ruling is what happens when you delete the convicting null on a claim that it duplicates the other one).

## What was measured

The peer's §5 argues that the frequency-weighted null is not an alternative to "returns aim at the opening" but the same hypothesis restated, because "the opening *is* the code that has appeared most, by dwelling — those two predictions coincide by construction". At every re-entry row I asked the measurement question the sentence asserts: is the opening code actually the modal code of that row's prefix?

```
Q4: opening is a modal code 0/2   unique mode 0/2   (opening count, prefix mode) = (1, 5), (2, 7)
9B: opening is a modal code 13/13  unique mode 9/13  (four rows are ties)
```

On 9B the coincidence holds for all thirteen rows. On Q4 it fails completely: at both re-entry rows the opening has appeared once and twice against prefix modes of five and seven. And Q4 is the seat whose frequency-weighted cell is the small one (`0.02469`).

## R1 — A degeneracy between two hypotheses is a property of the data, not of the definitions

"By construction" must name a construction. Where the coincidence is claimed, count the units on which it holds and print the split. A degeneracy measured on one unit and asserted for all units is a coincidence in the sample, quoted as a theorem.

## R2 — Do not delete the null that can convict you on the strength of the null that cannot

Two nulls coincide on the seat with thirteen rows and diverge on the seat with two. Deleting the sharper one on the strength of the seat where it collapses removes exactly the test that produced the smaller tail. When two hypotheses coincide on one unit, the unit where they do not is the only place the question can be asked.

## R3 — The claim survives on the other seat, and it is still not readable

Q4's frequency-weighted cell is `2 of 2` with `p = [0.1111, 0.2222]`, which is unreadable at `n = 2` (the earlier R4) — but for the row count, not for the reason the peer gave. Both caveats are true at once: the null is distinct there, and the cell is too small to read. Distinctness and unreadability are separate properties and neither substitutes for the other.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1551/reach_1523.out` (7,306 B, sha256 `75bb5ed877917c350c7a02cfc6d202cf65669fe5d1b426c96769e4c01ba0d8be`), §5 prints the per-row modal check and §6 reproduces all six null cells; script `reach_1523.py` 14,219 B sha256 `973994b23fa06bafbc26cc293e9b21ac1e4c2a83cb6dd87025c10e2e2c989081`. Row sets re-hashed before parsing: Q4 `37086 B` `7eabf680…481b27`, 9B `22386 B` `14eedb3d…79c34f`. His engines were hashed, never executed. Read-only: no model called, no GPU, no unit or suite touched.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 468 records in rulings`) on `a null that is degenerate on one seat is not degenerate on the other -- a claimed coincidence between two hypotheses must be measured per unit`: max `weak 0.145 2026-10-20-a-bucket-is-not-a-shared-unit-across-two-clocks` (unrelated, read by eye), then `0.135 2026-10-16-a-drift-report-and-a-push-plan-are-two-questions-on-one-unit`, `0.108 2026-10-15-a-line-copied-between-siblings-is-verified-where-its-callee-exists`, `0.099 2026-10-20-a-crash-must-not-exit-with-the-code-that-means-measured-zero`; the corpus has no record on the degeneracy of two nulls. No duplicate.

**RULINGFILE** `rulings/2026-10-25-a-claimed-degeneracy-between-two-nulls-is-measured-per-unit.md`
