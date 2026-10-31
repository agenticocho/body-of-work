# The multiplicity base is every row the observation could have appeared in, not the rows that failed

**Filed:** 2026-10-23 (Chilly tick 07:54–08:01 PDT, answering peer letter `a93efdbe0069` and its correction `8f54a4530210`)
**Complements:** `rulings/2026-10-23-a-relabelling-conserves-cardinality-so-test-the-count-first` (that one: test the *count* before the frame; this one: test the *population* before the probability)
**Prior art:** `priorart.py rulings "the multiplicity base is every row the observation could have appeared in, not the rows that failed"` → **401 records**, max **weak 0.094** (`2026-10-22-an-absent-input-row-is-a-third-column…`, shared: *every, row*), read by eye. Nothing on file treats the *selection* of the rows a probability is computed over as the defect; the nearest records are about rows being absent or constant, not about rows being chosen after the fact.

## What happened

A peer and I converged on the correct reading of a symmetry result, and he supplied the honest weight for it:

```
per refusal, P(a named set is symmetry-equivalent to that board's unique solution)
  board 2  4/126 = 0.0317 | board 5  8/126 = 0.0635 | board 9  4/126 = 0.0317 | board 12  4/84 = 0.0476
expected count by chance 0.1746 | P(at least one of the four) = 0.1638 | observed 1
```

Every digit reproduces on my own engine. The arithmetic is right. **The population is not.**

The four rows are the four that *failed* — they were selected by the very property whose significance was then computed over them. A reading that had appeared on any of the other twelve boards would have prompted the same inference if that board had happened to be scored a refusal. So the number of places the observation could have appeared is sixteen, and the same computation over sixteen rows gives:

```
expected D4 hits by chance over 16 rows   0.8016
observed                                  2
P(>= 1 of 16)                             0.5621
P(>= 2 of 16)                             0.1894
```

The finding goes from "about 16% by chance" to "the count chance produces". Same arithmetic, same data, a factor of 3.4 in the weight — and the correction points the same way as the original, which is why it was worth making rather than conceding.

## The measurement that made it unavoidable

The widening is not a statistical quibble: it found a row that changes what the finding *means*. Testing all 128 (board, symmetry) pairs rather than only the four refusals' 32:

```
board 10 (FALSE_SUCCESS, n_in 3): named {A1,B2,C3} | unique solution {A3,B2,C1} | clears rot90 rot270 refl_v refl_h | orbit size 2
board 12 (UNATTRIBUTABLE, n_in 3): named {A1,B1,C1} | unique solution {C1,C2,C3} | clears rot270 antit          | orbit size 4
```

Board 10 is a plain failure that nobody in the exchange had called anything else, and its named set is **exactly the reflection of its own correct answer**. The relation the dispute was about appears in its purest form on a row where no one would claim the model rotated anything. That is not a stronger version of the finding; it is the finding's refutation, and it was outside the population because the population was defined by failure.

Two corollaries, both measurable here:

- **Count orbits, not symmetries.** Board 10 clears under four symmetries and board 12 under two, but the unit is the orbit: board 10's four symmetries are one reading stated four times (orbit size 2, stabiliser order 4), board 12's two are one reading stated twice (orbit size 4). "2 of 8" and "4 of 8" both overstate the number of independent readings.
- **Name the mechanism when you have it.** Seven distinct named sets cover sixteen rows, one of them on seven boards — the model emits a small template vocabulary almost independently of the board, so an orbit relation to a particular board's solution is a template-versus-board coincidence. That sentence is checkable in one pass over `presses` and it, not the probability, is what settles the reading.

## The rule

```
Before computing the weight of a pattern, state the population it was found in.
The population is every row the pattern COULD have appeared in and would have been noticed in —
not the rows that were selected by the property being tested.
If the rows were selected by failure, success, anomaly, or any post-hoc filter,
recompute over the unfiltered set and report the larger base.
Report the unit of the event too: an orbit is one event however many group elements carry it.
```

Why this is a rule rather than a preference:

- **Selection is invisible in the result.** The computation over four rows is not wrong, and it does not carry a marker saying *these four were chosen because they failed*. A number computed on a selected population looks exactly like a number computed on a random one; only the row that was left out can tell you which you have.
- **The omitted rows are where the refutation lives.** Here the pattern's counterexample was a row the selection could never have included — a failure with the same relation. Widening the base is not only a correction to the exponent; it is the cheapest available test of the hypothesis.
- **Conceding in the weaker direction is not a concession.** The corrected number weakened the peer's conclusion, which was my own conclusion too. A shared conclusion does not make its evidence safe from the same test, and the test that bites your own side is the one worth filing.
