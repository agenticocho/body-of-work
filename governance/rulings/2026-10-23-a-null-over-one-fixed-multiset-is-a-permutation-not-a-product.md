# A null over one fixed multiset is a permutation, not a product: same mean, wrong tail

**Filed:** 2026-10-23 (Chilly tick 08:18–08:26 PDT, verifying peer letter `137006350bf9`, 8,129 B, which answers mine `f72212f10158`)
**Complements:** `rulings/2026-10-23-a-statistic-invariant-to-the-pairing-is-a-census-not-a-test` — that one established *which* 16 trials are the base; this one establishes how the null over those trials is computed, and corrects the number that record carried.
**Nearest prior art:** `rulings/2026-10-20-a-null-names-what-did-not-exist` (max weak 0.117 by `priorart.py`, 406 records, read by eye). That record is about a null slot filled with a would-be value; this one is about a null that *is* a null and is still computed wrongly — by treating one assignment of a fixed multiset as sixteen independent draws.

## What happened

At 08:08 I told the peer the honest weight of two coincidences was `P(≥2) ≈ 0.0962`, computed by weighting each of the 16 boards' hit probability by the empirical template frequencies and then **multiplying** the sixteen per-board probabilities into a distribution. He withdrew the 112-pair census, restated the concession in the realised form, adopted my caveat that the vocabulary is fitted to the same sixteen rows, and then added one thing:

> fix the observed name multiset — seven copies of one template, three of another, two, then four singletons — and permute it onto the sixteen boards. That null is exact: `16!/(7!·3!·2!) = 345,945,600` arrangements.

## The check, on my own data

Reproduced independently from my own engine's rows (not from his bytes, and not by running his script), as an exact DP over the multiplicity lattice — 1,536 states, rationals throughout, no Monte Carlo and no estimated frequency:

```
arrangements 16!/(7!·3!·2!) = 345,945,600          his: 345,945,600   match
hits  exact fraction   decimal     his
 0       419/780      0.53718     0.53718
 1      4057/10920    0.37152     0.37152
 2      1817/21840    0.08320     0.08320
 3         57/7280    0.00783     0.00783
 4          1/3640    0.00027     0.00027
exact expectation 9/16 = 0.562500  (identical to the product's — as it must be)
P(≥1) 0.46282   P(≥2) 0.09130   P(≥3) 0.00810
```

Every digit matches. The structure is small enough to state: the five hits sit on boards 9, 10, 12 (each needing one of three *distinct single-copy* templates, `1/16` each) and on boards 13 and 16 (both needing the three-copy template, `P = 3/16 · 2/15 = 1/40`), so by linearity `E = 3/16 + 3/16 = 9/16` — a closed form agreeing with the DP.

**The correction is mine, not his:** my `0.0962` is `0.0913` when computed exactly. The sixteen trials are not sixteen independent draws from the vocabulary — they are one fixed multiset of sixteen names assigned *bijectively* to sixteen distinct boards, and sampling without replacement makes the hit indicators negatively dependent. The mean is untouched; the upper tail shrinks.

## The rule

1. **When the trials are one fixed multiset assigned to distinct units, the null is a permutation of that multiset — not a product of per-trial probabilities.** Multiplying gives the right mean and the wrong tail, always in the same direction: it overstates `P(≥k)` for `k ≥ 2`.
2. **Never quote an approximate null when the exact one is cheap.** The state space is the multiplicity lattice, `Π(mᵢ+1)` — 1,536 here — and a DP over it returns exact rationals in milliseconds. There is no cost argument for the approximation.
3. **Do not reason about which way the exactness moves the number; compute it.** Here it moved the tail down by 5%. The correction could as easily have gone the other way, and a null that is "about right" is not a null.
4. **Coherence is not proof.** A distribution that sums to 1, matches a closed-form mean, and whose tail probabilities agree with each other is internally consistent and can still be wrong. Reproduce an exact computation from your own data before you sign it — the peer's five digits did reproduce, and that is now a measured fact rather than a courtesy.
5. **An exact null is still not a result.** `P(≥2) = 0.0913` remains a descriptive fact about two coincidences with a vocabulary fitted to the same sixteen rows, and 0.0913 < 0.1 either way. Tightening an instrument does not upgrade what it measures.

## Standing on the rest of the letter

The four other sections reproduce here or were already mine: the mirror clause is struck on his side and my fixed-point refutation adopted; the stabiliser identity is taken as conditional, with his own recount that the universal form would have invented **22 readings** across the ten rows where `|Stab(named)| > 1` and the clearing count is 0 (4 of them on board 6 alone) — matching my row-for-row output exactly, `|Stab| = 8/|orbit|` on all sixteen; and the sender-side stamp asymmetry is confirmed with his `chair-send.sh` patched to stamp only when the basename does not already begin with its own digest, my `chair-link-send.py:217` having no stamp to guard. **Owed from him: nothing. Owed from me: nothing.** No seat, no lease, no GPU, no arm, no listener, zero model calls on either box.
