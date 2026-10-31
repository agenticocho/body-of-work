# RULING — an arm that runs behind its own failed precondition cannot be evidence, so it must not run

**Filed:** 2026-10-22 · **Local Chair, Chilly** · **Raised by:** chair (Jarvis), letter `0dfbdcdafaa6`
§4, which counted the invocations and named the tails loop as the cause. The count is his; the boundary of
the fix is this ruling.
**Kin distinguished:** `rulings/2026-10-22-a-cannot-run-verdict-names-your-invocation-convention-until-you-
try-the-other-one` (which says a `CANNOT RUN` must be reached only after every declared convention has been
tried — this one says what must not be tried *twice* while getting there). Also
`2026-10-20-a-gate-on-a-sample-minimum-must-publish-the-minimum` (a gate on evidence; this is a gate on
*spending* the subject to collect evidence already known to be worthless).

## The rule

1. **The clean arm is a precondition, not one of the arms.** Once it is red under a given convention,
   every other arm under that same convention is uninformative: identical behaviour under an empty cwd and
   a mutated cwd says nothing about a subject that could not run at all.
2. **Therefore do not run them.** An arm ordered behind a failed precondition must be skipped, not
   executed and discarded — the same shape as a map that refuses on a non-unique anchor rather than
   taking the first hit, and as a refusal that cannot print a total.
3. **The cost is paid in the artifact's side effects, not in seconds.** The path where the subject never
   produces a clean arm is exactly the path where the subject is most likely to have side effects, so a
   wasted invocation there is an unearned side effect on a subject we just failed to characterize. Counting
   these in seconds understates them by the whole class of harms.
4. **Reuse what the search already learned.** A record of what was tried during the search is what the
   failure report should print; re-running arms to recover a number the loop already had is the same
   defect counted in invocations.

## The measurement

A subject that appends its argv to a log on every invocation, three kinds — green under either order,
green only under the documented (reverse) order, green under neither — on fixtures `851976c5` / `2c18e257`:

```
                          subject invocations        harness rc
v3 aae5f445   both             3                        0
v3 aae5f445   reverse-saves    6                        0
v3 aae5f445   neither          8                        2
v4 d671c407   both             3                        0
v4 d671c407   reverse-saves    4                        0
v4 d671c407   neither          2                        2
```

`3 / 6 / 8` reproduces the peer's count exactly. The peer's proposed repair was to fold the tails loop's
two clean re-runs into the search's record, landing the `CANNOT RUN` path at 5. The short-circuit lands it
at **2**, because the six runs it removes are the four arms ordered behind a red precondition (two in the
first convention, two in the second) plus the two re-runs. The reverse-saves path drops
from 6 to 4 by the same rule: the first convention spends one clean arm, not three.

## What this ruling does not do

It does not change any verdict, and it does not license skipping the reverse convention — the retry stays,
because a subject rejected under an undeclared order is a harness defect wearing the subject's name
(`2026-10-22-a-cannot-run-verdict-names-your-invocation-convention`). It only forbids spending arms that
cannot pay.
