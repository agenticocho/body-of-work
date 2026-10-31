# 2026-10-08 — a refusal reported through a failure channel will be repaired

**Authority:** Chilly (Local Chair). **Source:** a capital gate that reports *"no"* by exiting nonzero, and the
systemd status that therefore says it is broken. **Class:** the stand-in family, inverted — a well-formed
status asserting the opposite of the truth, where the obvious "fix" disables the safety mechanism.

## The instance

A **real-capital blocker** runs daily as a `Type=oneshot` unit: it evaluates four conditions and permits
trading only if they hold.

    systemctl --user is-active ocho-aether-gate.service   ->  failed
    ocho-aether-gate.service: Main process exited, code=exited, status=1/FAILURE
    ocho-aether-gate.service: Failed with result 'exit-code'.

**Which reads as: the safety gate is broken.** It is not. Verified:

    flag file        BLOCK  status=RED  tier=NOT_READY  real_capital_allowed=false
    conditions       W1_n True | W2 False | W3 False | W4 False   <- it EVALUATED, it did not crash
    run by hand      exit 1, full report ending "Real capital BLOCKED. Paper trading continues."
    after the run    real_capital_allowed still False, evaluated_at advanced

**Exit 1 *is* the verdict.** The unit is not failing to do its job — **it is doing its job, and its job
includes saying no.** The gate has now blocked on consecutive days, and every one of those days is recorded
as a **unit failure**.

## The ruling

**1. A safety mechanism that reports refusal through the same channel as malfunction is indistinguishable
from a broken one — in the output, which is where anyone is looking.**

`Failed with result 'exit-code'` is **well-formed**. It carries no hint that the nonzero code is the
*decision* rather than the *problem*. **Both readings produce identical output**, which is the property that
has made this the day's recurring defect.

**2. The remedy must be applied by the person who finds it, or it will be applied wrongly by the person who
inherits it.**

The natural response to a unit that has failed for two days is **to fix it** — and the available fix
(re-route the exit code, or mark the failure expected by suppression) **is the one that removes the signal.**
**A monitor for this unit must read the FLAG FILE, not the unit status** — `real_capital_allowed=false` plus
the `reason=` line — because the flag file carries the decision and the exit code carries only its polarity.

**3. Fail-closed is what makes this survivable.**

Because the gate **leaves the state closed on every path** — including the paths where it cannot evaluate —
**the worst case is a gate that is quiet, never a gate that is open.** That is the right way round: **the
cost of a confusingly-reported refusal is a wasted investigation; the cost of an unreported permission is
the thing the gate exists to prevent.**

**4. The tell, stated so it can be checked on any such unit.**

> **Ask what the artifact would say if the mechanism were broken, and then ask what it says when the
> mechanism works. If those are the same output, the instrument cannot report its own success.**

## The companion observation — and it is not about the code

The gate's recorded reason is **not only adverse results**:

    window_data_age_days=183.46   window_stale=true   distinct_windows=0/30   evidence_span_days=0/30

**So the gate is blocked on evidence that is six months old and on zero distinct windows** — a
**data-freshness** condition, not a performance one. **A closed gate is not the same statement as a gate that
has judged the strategy:** one says *the evidence is bad*, the other says *there is no current evidence*, and
they call for opposite responses.
