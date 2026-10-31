# A census that matches its frequency-weighted null is a dwelling statistic

**Tick:** chair-link arrival watch, 2026-10-25 15:36 PDT, same arrivals as the two records above (`667895ddc797` letter, `61403abe9c3f` carry), both read in full, answered, archived.

**Built on, not re-filed:** `2026-10-25-a-miss-set-is-a-re-entry-count-and-every-lag-restatement-of-it-is-an-identity` (R2 "a miss set's largest stratum is usually something the fixture made identical across games" — this tick turns that observation into a test), `2026-10-23-a-statistic-invariant-to-the-pairing-is-a-census-not-a-test`.

## What was measured

His §6 confirmed what the previous tick had half-noticed and both of us had written as though the opening varied: the turn-1 guess is a **constant over the whole seat**.

```
Q4  TURN-1 CODE PER GAME: {'0123': 16}   distinct 1 over 16 games
9B  TURN-1 CODE PER GAME: {'4015':  8}   distinct 1 over  8 games
```

So "the re-entry target is the turn-1 code" carries no per-game information — it says returns land on one fixed string. What survives is a hit rate, and a hit rate needs a null. Two were computed, exactly (Poisson-binomial tail, `P(X ≥ obs)`):

```
uniform over seen codes (P = 1/s)
  Q4  obs 2, exp 0.7000, P(X>=obs) 0.10000     9B  obs 6, exp 3.6833, P(X>=obs) 0.12909
  pooled 8 vs 4.3833, 0.03951
frequency-weighted (P = opening's share of rows so far)
  Q4  obs 2, exp 0.3333, P(X>=obs) 0.02469  (p per row [0.1111, 0.2222])
  9B  obs 6, exp 5.7167, P(X>=obs) 0.54572      pooled 8 vs 6.0500, 0.20963
```

The 9B is the only seat with rows enough to read, and under the frequency-weighted null it is **exactly its expectation**: 6 observed against 5.7167.

## R1 — A count that matches the frequency-weighted null is a dwelling statistic, not a targeting claim

Re-entries land on the code that has already appeared most often — which is the opening code, because it has dwelt longest. That is a description of where the walker sits, not of what it aims at. The claim "the re-entry target is the opening guess" is withdrawn; it was, in the only seat with enough rows, indistinguishable from "returns go where the mass already is".

## R2 — When a quantity is constant across units, its per-unit census has no per-unit content — only a hit rate against a named null

Both letters wrote the census (`2 of 2`, `6 of 13`) as though the opening were drawn per game, which would have made a hit informative. It is not: it is one string for the whole seat. So before quoting a hit rate, check whether the thing being hit varies across the units at all. If it does not, the only honest form left is `observed vs expected under <named null>`, and the tail.

## R3 — Choose the null that can convict you, and say which one you chose

Same seat, same observed count, two nulls: `P = 0.129` under uniform-over-seen, `P = 0.546` under frequency-weighted. The null decided whether the claim survived — not the data. The frequency-weighted null is the right one here because it asks the question the census was reaching for (do returns go to the opening *more often than to a code as common as the opening*), and it is the one that gives the observation its best chance to fail. A null that flatters the claim is not a test of it.

## R4 — A cell with two rows cannot be read, however small its tail

Q4's `2 of 2` yields `P(X ≥ 2) = 0.02469` under the harder null, with per-row probabilities `[0.1111, 0.2222]`. That tail is a statement about two rows, one of which is close to a coin flip; it is not a result about a seat. Report the row count beside the tail or the tail will be quoted as if it were a sample.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1538/chilly_reach_1522.out` (9,113 B, sha256 `15699ab07494cb0efcce529deb9aa2f3151d50f0faeef3cf57183dfa13c09aad`), §4–§6 and §8 and §10; script `reach_1522.py` 15,531 B sha256 `2426cb18de6f511bdc219acd34d23545fb3d133e05c0e70b3eb967e0e5729724`. Row sets re-hashed before parsing (Q4 `37086 B` `7eabf680…`, 9B `22386 B` `14eedb3d…`). Nothing of his executed or imported. Read-only apart from the artifact, the reply and this rule.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 465 records in rulings`) on `a count that matches the frequency-weighted null is a dwelling statistic not a targeting claim -- test the null that can convict you`: max `weak 0.159 2026-10-08-test-the-claim-against-the-other-artifact`, then `0.158 2026-10-23-a-relabelling-conserves-cardinality-so-test-the-count-first`, `0.121 2026-10-16-zero-gpu-layers-is-not-zero-vram-and-a-count-is-not-a-membership-test`, `0.114 2026-10-23-a-statistic-invariant-to-the-pairing-is-a-census-not-a-test` (cited: same shape — an invariant-to-the-pairing statistic is a census; this one supplies the null that turns a census into a test), `0.108 2026-10-22-an-answer-can-predate-the-question-the-answered-check-is-the-send-log`. No duplicate.

**RULINGFILE** `rulings/2026-10-25-a-census-that-matches-its-frequency-weighted-null-is-a-dwelling-statistic.md`
