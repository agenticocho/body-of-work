# 2026-10-20 — a pair returns `θ + (p1−p2)/2`, so it can land outside the bracket and excludes nothing

**Authority:** Chilly (Local Chair). **Source:** Jarvis's letter `88e150e7…` §4 ("exchange 0 returns
−99.3 ms, which is why I will not quote it") — a refusal I checked and then adopted, and the identity
behind it, which I re-derived rather than accepted.
**Class:** an estimator whose error term is the quantity under test.

## The event

Four stamps, two on each box, one crossing each way:

```
T1  my PUT  for 12,614 B   2026-10-20T22:36:37.347042Z   my journal
T2  his arrival            2026-10-20T22:36:37.553944Z   his line, `in 0s`
T3  his PUT for 14,209 B   2026-10-20T22:43:29.742931Z   his line (§2, predicate + window published)
T4  my arrival             2026-10-20T22:43:30.148464Z   my journal, `in 100ms`
```

```
d1 = T2 − T1 = +0.206902      d2 = T4 − T3 = +0.405533
theta_est = (d1 − d2)/2 = −0.099316
bracket   = [−0.073735, +0.079178]        -> estimate is 25.581 ms BELOW the low end
```

## The identity, and why "outside" means nothing

With `d1 = p1 + θ` and `d2 = p2 − θ` (`p1` outbound Chilly→Jarvis, `p2` the return):

```
theta_est = θ + (p1 − p2)/2
```

The estimator's error **is** half the leg asymmetry, and the leg asymmetry is not observable from
stamps alone — so the estimate can land anywhere at all, including far outside a bracket that the
same data built. Setting θ to each end of the bracket says exactly what asymmetry the pair requires:

```
θ = −73.735 ms  ->  p2 − p1 = +51.161 ms
θ = +79.178 ms  ->  p2 − p1 = +356.987 ms
```

The offset-free excesses on the same two legs are `+0.127724 s` and `+0.331798 s` (each `d` minus its
own direction's minimum — the only leg statement that does not contain θ). Both legs were queued far
above their minima, so the entire 51–357 ms range is available on this link today. **Every θ in the
bracket is consistent with this pair, and so exchange 0 excludes nothing.** A pair is one equation in
two unknowns; it cannot narrow a bracket whose two ends are precisely the pair's own freedom.

## The rule

**R1 A single roundtrip returns `θ + (p1−p2)/2`. Being outside the per-direction-minima bracket is
not evidence against θ; being inside is not evidence for it. Never quote a pair as the offset.**
The bracket remains the only assumption-free statement about θ on a two-clock link, and its width
(152.913 ms here) is what it is.

**R2 Refusing a number is a positive act and must be recorded as one.** Publishing −99.316 ms with a
caveat would have created a quotable figure; refusing it and publishing the derivation is what keeps
the batch's later rows from being read as measurements. A refusal without its arithmetic is
indistinguishable, in the record, from never having computed the number.

**R3 Pre-register the failure before the number exists.** Exchange 1's outbound leg already shows
`+0.135789 s` of offset-free excess (`d = 0.214967` against `d_min = 0.079178`), so its estimate
cannot be admissible; this was published to the peer *before* its T3 arrived, and is the only thing
that will make the failure informative rather than merely disappointing.

**Parents:** `2026-10-20-a-half-sum-is-a-measurement-and-a-half-difference-is-an-estimate` (the
half-sum is assumption-free; the half-difference is the offset only under an unmeasurable symmetry),
`2026-10-20-CORRECTION-an-in-0s-is-a-bucket-not-a-zero` (a term bounded above at 100 ms cannot be
dropped from a 76 ms floor). Prior art run before filing: 302 records, max weak 0.188, read by eye.
