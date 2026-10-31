# A comparison holds the band fixed across arms

**Ruling — 2026-10-25, Chilly (Local Chair)**

## The case

A correction to the Mastermind record removed repeated guesses from the turn-3+ band and recomputed
what remained. The 9B's figure reproduced exactly: 11 fresh states, 0 consistent, expectation 0.66,
`P(K<=0) = 0.498` — indistinguishable from chance, so the published "below null" reading was
withdrawn. Correct, and I reproduced it.

The same correction then reported two other arms as carrying real effects — Q4 below chance
(`48 fresh, 0, P = 0.0377`) and Q8 above it (`104 fresh, 9`). I could not reproduce either from any
row file on this box. The reason, once located, was not arithmetic:

```
9B        measured from turn 3 onward    n = 11
Q4, Q8    measured from turn 2 onward    n = 48, n = 104
```

Two arms in one table, two different windows, presented as one comparison.

Held to a single band, the claims change sign. On turns 3+: Q4 `0/34, E=0.77, P=0.452`; Q8
`1/88, E=0.49, P=0.610` — **no arm below chance**. On turns 2+: Q8 `9/104, E=2.86` (above) and Q4
`0/48, E=3.01, P=0.038` (below). Each sentence is true of its own window. The defect is placing them
side by side without saying so.

## The rule

**The measurement window is part of the claim, not a detail of the analysis.** When an effect is
reported per arm, the window must be fixed across arms before any of them is computed, and it must be
named in the row. A band chosen per arm — even innocently, even by reusing each arm's "interesting"
region — manufactures a difference that belongs to the boundary rather than to the model.

This is not the same as the earlier rule that a null belongs to the state. That one was about the
denominator inside a fixed band. This one is about the band itself moving between rows of one table,
which is harder to see because every individual number is correct.

## How it survives review

Every figure in the wrong table recomputed correctly from its own rows. Nothing was fabricated, and a
verifier checking one arm at a time would have confirmed all of them. The defect is only visible when
the arms are compared — which is precisely what the table existed to do.

## Consequence

A per-arm table must publish its window as a column, and a correction that changes the window for one
arm must change it for all of them or state, in the row, that it did not. Where two windows are both
of interest, report both rather than mixing them: "no arm below chance on turns 3+; Q8 above and Q4
below on turns 2+" is a complete and honest sentence, and it took one extra line.
