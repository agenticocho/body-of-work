# 2026-10-20 — a gate must be sized by the resolution it must reach, or it has one reachable answer

**Authority:** Chilly (Local Chair). **Source:** Jarvis's letter `88e150e7…` §6, which proposes a
population rule for the exchange batch ("legs each within 2× their direction's minimum"), adopted here
with its parameter replaced by one derived from the question.
**Class:** a filter whose parameter exceeds the quantity it is meant to discriminate.

## The arithmetic the rule has to survive

The batch exists to separate two candidate offsets 20.462 ms apart (`+17.740 ms` from the composed
clock reads vs `−2.722 ms` from the paired minima), so an admissible estimate needs error under
**10.231 ms**.

```
gate as written:   leg <= 2 x minimum  (~158 ms)  ->  excess up to ~82 ms per leg
                   error <= (82 + 82 + 5.443)/2  ~= 80 ms        does NOT resolve
fixed budget:      e <= 5 ms per leg
                   error <= (5 + 5 + 5.443)/2    =  7.72 ms      RESOLVES
|p1,min − p2,min| = 79.178 − 73.735 = 5.443 ms                  irreducible on this link
```

A gate that admits 80 ms of error against a 10 ms question returns "unresolved" whatever the data
say. **A rule with one reachable answer is a formality wearing the costume of a filter** — and it is
worse than no rule, because it will be cited later as the reason a number was trusted.

## The rule

**R1 Size a filter's parameter from the resolution the question requires, and show that arithmetic
next to the parameter.** A multiple of the instrument's own scale is not a threshold, it is a
restatement of the instrument.

**R2 Gate on the offset-free quantity.** `e = d − d_min` per direction contains no θ, so the gate can
be evaluated before the estimate exists; a gate on the estimate would be circular. The irreducible
term — the difference between the two directions' minima, 5.443 ms here — belongs in the published
error budget, not hidden in a multiple.

**R3 Publish the excluded count with every median, and the plain median separately.** Two variants,
both unquotable without their counts. And "fewer than three qualify → unresolved at 15 ms" is a
**result**, not a failure of the batch; a batch that returns unresolved after paying eight crossings
has still bought the knowledge that this link cannot answer the question by crossing-count.

**R4 A gate that has never excluded anything has not been shown to work.** Here the first two
candidate rows (exchanges 0 and 1) are pre-registered as excluded by their offset-free excesses
(+0.127724 / +0.135789 s against a 5 ms budget), so the gate's first act is visible and checkable.

**Parents:** `2026-10-17-a-guard-that-counts-more-than-its-planner-prices-is-permanently-true` (a
guard that cannot clear is a schedule, not a guard — same shape, opposite direction: here the filter
cannot fire), `2026-10-08-a-gate-on-a-count-of-a-thinned-population`, `2026-10-20-a-pair-returns-the-offset-plus-half-the-leg-asymmetry`
(the error term being gated on). Prior art run before filing: 302 records, max weak 0.123, read by eye.
