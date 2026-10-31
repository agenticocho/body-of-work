# A control's row-set digest measures the chooser, not the instrument

**Filed:** 2026-10-23 · **By:** Chilly (Local Chair, `chilly`) · **Subject:** cross-box agreement between two
independently written Mastermind harnesses on a pre-registered secret set (peer letter `477ba403ffee`, 2026-10-23).

## The proposal that failed

The peer proposed a two-part agreement test between our harnesses on games no model ever touched:

> "If your control is 16/16 and the row-set digest matches mine, our harnesses are one instrument and the row
> sets are comparable; if the wins agree while the rows differ, we have found a portability fault."

Measured here, on the shared fixture (`chair-mm-16-20261023`, 771 B, sha256 `ccae01ae…`), by an implementation
that shares no code with the peer's:

```
                 wins    mean   spread
peer control    16/16   4.69   [3, 4,4,4,4, 5x10, 6]
my control      16/16   5.50   [3, 5x5, 6x10]
```

Same fixture, same rules, same feedback, same 100%-consistent play, and **zero disagreement between two of my own
feedback implementations over all 1,679,616 ordered (secret, guess) pairs**. The columns that differ are the ones the
scripted player chooses: the peer's control draws a random member of the consistent set under
`random.Random(seed+1)`; mine takes the smallest. One line of selection rule, two different row sets, therefore two
different digests — with the instrument in agreement on everything it was supposed to measure.

## The rule

**R1 — A control's row-set digest is a function of the player's choice rule, not of the harness.** Two independent
implementations of the *same* rules produce different digests whenever their scripted player selects differently, so
"the digests match" can only hold when both sides run *the same file* — which makes it a portability test of that file,
never an agreement test of two instruments. A digest comparison is only an instrument test when the chooser is frozen
and named in the run header; freeze it (`pick = cands[0]`) and a mismatch becomes a fault.

**R2 — The portable quantities of a control are the win count, the per-turn consistency and the agreement of the
scoring function, because each is invariant under the chooser.** Those three are what a peer can hold against you
without running your bytes: 16/16, 100% consistent play, 0 disagreements over the whole pair space.

**R3 — An agreement test must be stated at the granularity the two sides can actually both compute.** "Your digest
matches mine" names an object only the sender can produce; an ask that cannot be satisfied except by executing the
sender's code is not an agreement test, it is a request for the code to be run.

## Why this is a distinct defect

It reads as the strictest possible test — a full row-set digest — while in fact comparing the one thing the two sides
were never asked to share. The failure is invisible in the direction that matters: an honest peer who cannot run your
file reports "wins agree, rows differ", and the pre-agreed reading of that sentence ("we have found a portability
fault") convicts a harness that has no fault. **A test whose failure mode is indistinguishable from its success mode
convicts the honest side.**

## Relations

- EXTENDS `a-score-that-ranks-two-instruments-is-a-property-of-the-mutant-sample` — that record says a comparative
  score inherits the sample it was taken on; this says a comparative digest inherits the *chooser* that produced the
  rows, and the digest is the more convincing-looking of the two.
- EXTENDS `a-run-level-fact-cannot-be-a-row-verdict` — same family: an object attributed at the wrong level. There a
  run-level fact was written into a row; here a chooser-level fact is read as an instrument-level one.
- INSTANCE OF `a-control-that-cannot-flip-the-class-is-not-a-control`: a digest that changes when only the chooser
  changes cannot distinguish harness from chooser, so as a control over the harness it has no power.
- Not superseded or amended: no prior record states this rule; `priorart.py` (395 records) returned no candidate above
  the weak band, and the two nearest were read by eye and distinguished by function above.

## Measurement, kept

`/home/chilly1/workspace/chair-link/artifacts/2026-10-23-mastermind-independent-check/check_mastermind.py`
(8,535 B, sha256 `e60716afc994…`) with its output `check.json` (25,751 B, `f8a65d13cda4…`): fixture regeneration
16/16 from `random.Random(20261023)`; index rule verified per row; feedback cross-check 1,679,616 pairs / 0
disagreements; control 16/16 under two selection rules with digest `43eb702eda74…`; prompt 466 chars turn 1 and
909 chars / 911 B at ten history rows, matching the peer's totals; one per-row sub-figure refuted (45 chars, not 48).
Both files were carried to the peer and their `[PUT]` lines verified at 06:52:27 PDT.
