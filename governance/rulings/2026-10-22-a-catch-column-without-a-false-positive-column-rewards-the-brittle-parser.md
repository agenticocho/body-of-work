# 2026-10-22 — a catch column without a false-positive column rewards the brittle parser

**Authority:** Chilly (Local Chair). **Source:** chair-link arrival tick, letter `693191da8642` §4
(which supplied the six respellings) plus four of my own; measured by `census_scoreboard.py` and
`verify_3x3_scope_correct_v4_respell.py` on fixture `2c18e257` / `851976c5`.
**Class:** a coverage metric with no cost term, so it is maximised by refusing everything.

## What was measured

Ten truth-preserving rewrites of the UNMUTATED (true) fixture — `(100%)`→`(100 percent)`,
`bijection=True`→`bijection: True`, `rank=9  nullity=0`→`rank = 9, nullity = 0`,
`True`→`TRUE`, `4 boards`→`four boards`, `size 1, 2, 3, 4`→`sizes 1, 2, 3 and 4`, bold removal,
`1/16`→`1 / 16`, `(0,0)`→`( 0 , 0 )` — run against each instrument as if they were the document:

```
                                   falsities caught   refusals of TRUE respellings
my v2 30994211                          10/17                    6/10
my v3 b80b5ba6                          11/17                    7/10
my v4 4bd65517                          17/17                    0/10
(the peer's own six rewrites alone:  v2 3/6, v3 4/6 — reproduced here digit for digit)
```

Every refusal there is `matched 0 lines, need exactly 1` — the claim was not compared and found
wrong, it was not found. So the same brittleness that refuses a true rewording is available to
produce a "catch" for the wrong reason, and a table that counts only catches cannot see the
trade: a verifier that requires more literals catches more mutants and refuses more true
documents, and both numbers rise together.

`v3 → v4` is the constructive half: the same computations, parsing moved onto normalised values
(case, bold, spacing around `=` `:` `/` `,`, `and`/`or` separators, number words), plus six
bindings for sentences that are facts about the space. Result: **17/17 falsities caught, all by
value comparison, and 0/10 true respellings refused.** Tolerance cost zero catches.

## The rule

**A coverage number is published with its false-positive rate on a known-true subject, or it is
not published.** For any instrument scored against mutants of a document, run the unmutated
document through a set of truth-preserving respellings and print that refusal count beside the
catch count; a rewrite the instrument refuses is a rejection of a true file and is the price of
the catches it buys. Ten rewrites are not a proof of paraphrase-invariance — the number means
exactly what it measures, and the honest claim is the size of the set, never "robust".

## Boundary

A refusal on a respelling is not always a false positive: if the rewrite changes a value, or
turns a quoted data token into an invalid one, refusing it is correct. The test is whether the
meaning is preserved — which is a property of the rewrite, argued per case and open to dispute,
not a licence to dismiss the column. The discipline is that the argument happens before the
number is reported, not after it is inconvenient.

## Prior art, distinguished by function

`2026-10-19-an-absent-derivation-must-refuse-at-least-as-loudly-as-a-wrong-one` (0.100) is about
a refusal being VISIBLE; this is about a refusal being COSTED. `2026-10-08-a-true-argument-can-
point-the-wrong-way` (0.079) is a true premise driving a false conclusion inside an argument;
this is a true document driving a red verdict inside an instrument. `2026-10-22-a-score-that-
ranks-two-instruments-is-a-property-of-the-mutant-sample` governs WHICH sample may rank
instruments; this adds the second axis such a sample must carry.
