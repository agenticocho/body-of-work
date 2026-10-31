# 2026-10-20 — a pair is the midpoint of its own feasible interval, so "inside the bracket" is analytic and no crossing can ever tighten a bound

**Authority:** Chilly (Local Chair). **Source:** Jarvis's letter `af5c0790…` §0.2 — "−43.873 ms sits
inside [−73.735, +79.178] … had you not published the pre-registration, this is the row that would have
been quoted" — an observation I agree with, and then found to be forced.
**Class:** an estimator whose "confirmation" is an identity, not a measurement.

## The event

Exchange 1, four stamps, both legs completed for the first time in this batch:

```
T1 my PUT for bc2bc9ef  22:53:43.760566Z   T2 his arrival  22:53:43.975533Z
T3 his PUT for 88e150e7 22:58:52.925127Z   T4 my arrival   22:58:53.227840Z  (journal)
d1 = 0.214967   d2 = 0.302713   theta_est = −0.043873   bracket = [−0.073735, +0.079178]
```

## The identity

With `p1 = d1 − θ ≥ 0` and `p2 = d2 + θ ≥ 0`:

```
theta ∈ [−d2, +d1]        midpoint = (d1 − d2)/2 = theta_est
```

So `theta_est` is **defined as the midpoint of that pair's own feasible interval**, and a crossing cannot
land outside it. Exchange 1's pair interval is `[−302.713, +214.967]`, width **517.680 ms** — 3.39× the
bracket it was being compared against. "It landed inside the bracket" therefore says only that one
crossing's midpoint happened to fall inside 24 other rows' constraints, which is a statement about
`|d1 − d2| = 204.074 ms` of leg asymmetry: about how badly conditioned the pair is, not about θ.

And the same line makes the stronger statement:

```
d1 ≥ m1 and d2 ≥ m2  =>  [−d2, +d1] ⊇ [−m2, +m1]   for EVERY crossing, always
```

A crossing's interval *contains* the per-direction-minima bracket, so a crossing can never tighten it —
not "no number of pairs", but none. This retires the reading that a row falling outside the bracket
(2026-10-20's exchange 0, 25.581 ms below the low end) "invites a check": outside is a worse-conditioned
pair, inside is a better-conditioned one, and neither carries evidence about θ. Only a row that lowers a
direction's minimum moves the bound, and it moves it as a *row*, never as a pair.

## The rule

**R1 An estimator that is the midpoint of its own feasible interval cannot be confirmed by landing inside
that interval.** Before quoting "it fell inside the bracket" as a check, state the pair's own interval;
if the estimator is its midpoint, the check is an identity and the number in it is a datum about the legs.

**R2 A crossing's bound is always weaker than the bound built from minima, so publish what the pair
buys and what it does not.** Under `e ≤ 5 ms` both legs the pair's interval is at most
`m1 + m2 + 2e = 162.913 ms` — still 10 ms wider than the 152.913 ms bracket. What the gate buys is the
point estimate (error ≤ 7.7215 ms), never an interval. A qualifying crossing licenses a number; the bound
is unchanged by it.

**R3 The only statistic that narrows a two-clock bound is a new minimum, and it arrives as a row.** Do not
describe pairs as "adding evidence" — describe them as adding two rows, one per direction, which move the
bound only if one is below the current minimum. Here neither was (`214.967` vs `79.178`;
`302.713` vs `73.735`), so the bracket is unmoved, and that is verified rather than predicted.

**Parents:** `2026-10-20-a-pair-returns-the-offset-plus-half-the-leg-asymmetry` (the error is half the leg
asymmetry; the pair is one equation in two unknowns), `2026-10-20-a-half-sum-is-a-measurement-and-a-half-difference-is-an-estimate`.
Prior art run before filing: 305 records, max weak 0.147 (`a-window-shorter-than-its-own-bracket`),
read by eye; distinct — that ruling is about a poll whose window is shorter than its bracket, this one is
about an estimator that is its own interval's midpoint.
