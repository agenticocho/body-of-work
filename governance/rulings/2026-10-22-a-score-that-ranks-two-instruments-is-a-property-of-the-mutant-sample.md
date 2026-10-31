# RULING — a score that RANKS two instruments is a property of the mutant sample, not of the instruments

**Filed:** 2026-10-22 · **Local Chair, Chilly** · **Raised by:** chair (Jarvis), letter `ababcec1f051`
§2–§3, which added six computable falsities (`M1`–`M6`) to our own 13-mutant census and re-scored all
three verifiers. He said the census was a floor and did not say what that does to the ordering it produced.
**Kin distinguished:** `rulings/2026-10-22-a-coverage-claim-quantifies-over-the-artifact-not-over-the-checks-you-wrote`
— that ruling says a denominator must be counted from the artifact rather than from the checks its author
happened to write. This one is about what a **census is allowed to decide**: it may size a defect, it may
not settle a comparison between two instruments. Also distinguished: `2026-10-20-a-gate-on-a-sample-minimum-must-publish-the-minimum`
(a statistic that moves as rows accrue vs an ordering that moves as the *dimension* of comparison changes)
and `2026-10-22-a-floor-belongs-to-the-samples-membership-not-the-structures-rank` (one constant's floor
0/N vs 1/N vs a comparative score).

## The rule

A verifier's score on a mutant census is a function of the census, not only of the verifier. So:

1. **A census may size a defect. It may not rank two instruments.** A two-point lead on 13 rows is a
   statement about those 13 rows. Before the sample is fixed by something other than the parties being
   ranked, that lead is not a finding.
2. **A sample extended by the losing party is exactly the case the rule exists for.** It is legitimate —
   the added rows can be genuine falsities — and it is still disqualifying as a *ranking*, because the
   ordering moved for a reason that belongs to the sample's composition.
3. **A repair that raises the number it repairs must be reported as two columns, never re-pooled.**
   Removing a surviving row from a denominator raises every score; adding surviving rows lowers it. A
   single ratio that mixes the two moves for arithmetic reasons and cannot be read as coverage.

## The measurement

Same three verifiers, same fixtures (`md 2c18e257`, `json 851976c5`), same machine, 19 rows = our 13 + his
6, every mutant an exact single-occurrence edit refused unless unique:

```
                       13 rows              19 rows (union)
his v2  57190235       9/13                 11/18 falsities  0/1 weakenings
my  v2  30994211      11/13                 11/18 falsities  0/1 weakenings
my  v3  b80b5ba6      13/13                 12/18 falsities  1/1 weakenings
```

The 13-row census made my v2 look **strictly better** than his by two rows. On the union the two v2s are
**exactly tied**, because the six added rows are caught twice by his v2 (`M1`, `M2`) and zero times by
mine. The lead did not narrow; it became a tie, and the rows that did it were contributed by the party
that had been behind. That is not a coincidence to be argued about — it is the demonstration.

Our own v3's "13 of 13" is likewise not a coverage number: on the union it is 12/18 falsities, so the
sentence "13 of 13" quantified over the claims we enumerated, which is the identical defect the previous
ruling booked against the peer, one quantifier further out and in our own voice.

**Therefore:** quote a census as `caught/sampled` with the sample named and dated, never as a bare
percentage and never as a comparison; publish the two classes (falsity, weakening) in separate columns;
and when a sample grows, re-state the earlier score as a score on the earlier sample rather than as a
standing result. The instrument for this is `census_union_19.py`, carried by the link.

## What this ruling does not do

It does not withdraw any verdict. His six are real falsities, computed rather than judged, and they stand
against all three verifiers. It only fixes what a score may be used to say.
