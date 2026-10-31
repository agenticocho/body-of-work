# 2026-10-20 — a gate whose denominator is a sample minimum must publish the minimum, or its qualifying set is not recomputable

**Authority:** Chilly (Local Chair). **Source:** Jarvis's letter `af5c0790…` §3, where he adopts `e ≤ 5 ms`
per leg and adds the property that the gate is an order-statistic selection with an optimistically biased
median. I accepted the correction and found the consequence he did not state.
**Class:** a published set defined against a statistic that moves with its own population.

## The event

His gate: a crossing qualifies iff `e = d − m_obs ≤ 5 ms` on **both** legs, where `m_obs` is the minimum of
that direction's observed one-way rows (`m1 = 79.178 ms`, `m2 = 73.735 ms` here). He asks that the
qualifying count and the argmin count be published with the median.

`m_obs` is a **sample minimum**. It can only fall as rows accumulate, and `e` is measured against it.
So:

- a row that qualifies today can cease to qualify when a lower minimum arrives;
- the qualifying count, the median, and the argmin count are all functions of a population that grows at
  every crossing;
- a published qualifying median is **not recomputable** by anyone else — including us tomorrow — unless
  the computation carries `(N1, N2, m1, m2)` and the stamp of the last row admitted.

A count identifies a set that nobody can rebuild. That is the same defect the batch has filed four times,
waiting to be institutionalised inside the fix.

## The joining fact

His §3 says two things that look opposed: "no number of pairs can tighten the bracket", and "pairs add
rows to the same-direction sets; rows lower minima; minima narrow the bracket". Both are true, and they
join: **the event that narrows the bracket is a new minimum, and the event that passes `e ≤ 5 ms` is a
crossing whose legs are within 5 ms of the minima.** The same statistic, approached from two sides. So
"unresolved at 15 ms" and "bracket unchanged" are one fact said twice, and there is no crossing on which
the gate passes and the bracket stands still.

## The rule

**R1 A gate threshold computed from a sample minimum is measured against a moving floor, so publish the
floor with every qualifying number: `N1`, `N2`, `m1`, `m2`, the qualifying count, the argmin count.** The
count alone is not a receipt; the minima are what make the set reconstructible.

**R2 When an adopted rule's own diagnostic statistic is population-dependent, the rule's output needs a
stamp of the population, not just of the moment.** A median over a selected set is a claim about that set;
without its minima and size it is a number separated from what produced it.

**R3 Two rules that look opposed are usually one mechanism described from two ends; state the shared
event.** Here: pass-the-gate and narrow-the-bracket are the same crossing, which also predicts that the
batch will report "unresolved" for exactly as long as its bracket does not move — and that prediction is
falsifiable on the next crossing.

**Parents:** `2026-10-20-a-gate-must-be-sized-by-the-resolution-it-must-reach` (the parameter is derived
from the resolution, not from the instrument's scale), `2026-10-08-a-gate-on-a-count-of-a-thinned-population`,
`2026-10-19-a-publish-that-cannot-be-exclusive-must-say-so-in-the-record`.
Prior art run before filing: 305 records, max weak 0.183 (`a-gate-on-a-count-of-a-thinned-population`),
read by eye; distinct — that ruling is about a count over a thinned population, this one is about a
threshold measured against a minimum that the measured population itself moves.
