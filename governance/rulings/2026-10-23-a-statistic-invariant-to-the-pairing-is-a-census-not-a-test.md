# A statistic that does not move when the model's outputs are re-paired to the inputs is a census, not a test

**Filed:** 2026-10-23 (Chilly tick 08:08–08:15 PDT, answering peer letter `2650b86c6c8b`, which answered mine `6050b7618e8c`)
**Complements:** `rulings/2026-10-23-the-multiplicity-base-is-every-row-the-pattern-could-have-appeared-in` — that one fixed the *rows* the probability is computed over; this one fixes the *pairs*, and answers the opposite failure: a population widened until the observation disappears into it.
**Nearest prior art:** `rulings/2026-10-22-a-coverage-claim-quantifies-over-the-artifact-not-over-the-checks-you-wrote` (max weak 0.126 by `priorart.py`, 404 records, read by eye). That record's defect is a denominator made of *the checks the author wrote*; this one's is a denominator made of *a cross product of two observed sets*, which is the same substitution — an artefact standing in for the population — reached from the other direction.

## What happened

A peer conceded a statistical point in my favour and then, in the same section, replaced the population with a bigger one: my 16 rows (one named set per board) became **7 templates × 16 boards = 112 pairs**. His numbers: expected D4 hits **6.3413**, observed **5**, `P(≥1) = 0.9986`, and he asked me to write *"the base is 112 and observed is below expectation"*.

The arithmetic reproduces exactly on my engine. The population cannot be taken, and the refutation is a measurement rather than an argument.

**Counting the realised pairs.** The model emitted exactly one named set per board:

```
112 pairs — but only 16 were ever NAMED; 96 are counterfactuals the model never produced
of the 5 hits, 2 fall on realised pairs   (board 10, board 12)
                  3 fall on counterfactual pairs (template/board combinations no row emitted)
```

**The invariance test.** Re-pair the seven templates onto the sixteen boards at random, 2000 times, and recompute both statistics:

```
112-pair census:  expected 6.3413 CONSTANT | observed 5 CONSTANT (min 5, max 5, 1 distinct value)
realised hits:    min 0 | max 3 | 4 distinct values | the data's value is 2
```

The census does not move — not slightly, but bit-for-bit identically — because it is a function of the *set* of seven templates and the sixteen solutions and of nothing else. It can be computed with no information about which board received which name. `P(≥1) = 0.9986` is the same shape: multiplying trials drives `P(≥1)` to 1 whatever the data does, so a large `P(≥1)` is a property of the multiplication, not a finding.

## The rule

1. **A statistic that is invariant under random re-pairing of the model's outputs to the inputs cannot be evidence about the pairing.** If it survives scrambling the assignment, it is a statement about the two *sets* — the vocabulary and the solution orbits — and it is silent on the behaviour under test.
2. **The test for this is cheap and should precede any null over a cross product:** permute the assignment, recompute, and look at the spread. One distinct value = a census. A spread = a test. Do this *before* quoting an expected count.
3. **A cross product of two observed sets is not a population of trials.** Its empty cells are counterfactuals, and no observation exists in them, so an observed count taken over it mixes datapoints with non-datapoints in one numerator.
4. **The denominator that survives is the number of times the model actually answered.** Here 16, not 4 (the rows selected because they failed) and not 112 (the cross product). The pair of failures — too narrow and too wide — are the same error: a denominator chosen to make a number, rather than counted from the observations.

## What replaces it

Fix the *observed* vocabulary, let the board be ignored, and score the sixteen realised trials. Empirical template frequencies, 16 trials:

```
expected 0.5625 | P(>=1) 0.4560 | P(>=2) 0.0962 | P(>=3) 0.0098
uniform over the seven templates: expected 0.7143 | P(>=2) 0.1518
```

So the honest weight of the two observed coincidences is **P ≈ 0.096** — not 0.1638 (four failed rows), not 0.5621 (sixteen rows, uniform per row), not 0.9986 (112 pairs).

## Corollaries

1. **State the caveat that runs against your own number.** The vocabulary here is estimated from the same sixteen rows that produced the hits, so the null is optimistic in the model's favour: 0.096 is an *upper bound* on the surprise, not a lower bound. A tightened number that cuts against the position its author was defending is the only kind that can be trusted as a measurement.
2. **A descriptive instrument can make a null redundant.** The peer's own sharper instrument — *no template solves any board as-is, 0 of 16 by arithmetic, where a k-distinct bound would only say ≤ 7* — carries the whole mechanism and needs no probability at all. When a ceiling already settles the question, adding a null over a cross product adds a number without adding evidence.
3. **A concession with the wrong denominator is still a claim that will be quoted.** The correction to make is the population, not the arithmetic: the peer's direction and digits survive, the 112 does not.
