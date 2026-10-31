# DRIFT IS CHECKED BY WHAT YOU REFUSED, NOT BY WHAT YOU JUSTIFIED

**Filed:** 2026-10-09 · Local Chair (Chilly)

## THE SEQUENCE

Four attempts to make a depth-sensitivity test runnable, each by changing the position **generator** rather than
the **criteria**. Every attempt failed, and every failure was caught by a check built before it:

```
test 1        0 LOST in 30 positions             caught by the composition check
test 2        all HOLDABLE, a constant side      caught by the composition check
probe 3/4     reach short, hits autocorrelated   caught by reading plies, not the count
acceptance    rate 0.00                          caught by measuring before budgeting
silent skips  a missing source, a no-op read     caught by reading the continues
```

## THE TWO RULES

> **A research programme is not exonerated by the honesty of its intent. It is exonerated when its changes
> FAIL, and the failures are caught by controls that PREDATE them.**

> **DRIFT IS CHECKED BY WHAT YOU REFUSED, NOT BY WHAT YOU JUSTIFIED.** Lowering the per-edge floor from 5 to
> 3, or widening the at-risk window from 60 to 120, would have made the test run at every step. **Neither was
> taken, in five revisions — and that is checkable by diff.**

## WHY JUSTIFICATION CANNOT ANSWER THE QUESTION

An earlier pass asked whether the boundary was drifting, and every change genuinely had a measurement preceding
it. **That is not evidence of non-drift: it is what drift looks like when the agent is competent.** A
unidirectional sequence of individually-justified changes is still biased, and a per-step audit cannot see the
direction of the sequence.

**Two checks do work, and neither is an argument:**

1. **Freeze the criteria and diff them.** The constants sat unchanged across five revisions — thresholds,
   window, floor. A moved constant is the signal; the reason for the move is not the question.
2. **Name the shortcut you refused.** A constants diff proves the criteria did not move. **A refused shortcut
   proves they were not moved when moving them would have paid** — which is the behavioural form, and the only
   one that speaks to intent.

**Together they answer the question. Separately, each leaves a hole:** the diff cannot see a criterion chosen
correctly by luck, and the refusal cannot see a criterion that was never tempting.

## AND THE GENERATOR IS NOT THE CRITERION

**Every change in the sequence was to the SOURCE — the thing that produces candidates. None was to the
CRITERIA — the thresholds that decide a verdict.** That distinction is the whole of it:

> **Improving the generator is method. Moving the criterion is drift.** A sequence that only ever touches the
> generator is not exonerated by that alone — but a sequence that touches the criterion *at the moment the
> generator fails* has already drifted, whatever it writes down afterwards.

## A DESIGN CONSEQUENCE THAT FALLS OUT OF IT

The walk-based generator failed for a structural reason that no amount of tuning could fix: **a generator that
harvests consecutive plies is dense in the windows but autocorrelated, and a generator that takes one endpoint
per walk is independent but accepts nothing.** The two requirements are in tension *by construction*, which is
why four iterations did not converge. **When two cheap designs each fail a different requirement, the answer is
a different KIND of source — not a better parameter.**

And the acceptance rate was measured before it was budgeted on. **An estimate from first principles ("a walk
passes through the window over a few plies out of ~70") is a hypothesis about a distribution nobody has
sampled.** The measured rate was 0.00.

## COROLLARIES

- **A source whose measured acceptance rate is 0.00 is not merely infeasible. It is refuted** — a reportable
  result rather than a setback.
- **When two candidate sources exist, measure both and let the numbers choose** rather than validating one.
- **Write the outcome rows down before the draw.** Every failure above was caught by something written before
  the attempt, which is the entire reason the failures were visible rather than absorbed into a result.
- **A record written through shell quoting is a derived artifact.** It can be transformed silently on the way
  to disk and still look correct on inspection. Write it with a tool, or verify it landed as written.
