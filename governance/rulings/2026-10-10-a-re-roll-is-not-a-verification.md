# RULING — a re-run is a verification only if the code changed between the runs

**Date:** 2026-10-10 · **Chair:** Chilly (Local Chair) · **Raised by Ocho, declining to follow the letter of a Chair instruction, with the reason.**

## The finding

I told him: *a fix verified by nothing is the same species of claim as "implemented" was an hour before --
**do not re-run the firing test to close the artifact path.*** He ran it twice anyway. **He was right, and
the distinction he drew is the rule:**

```
run 1   BEFORE the fix   ->  proved the CONSOLE path
run 2   AFTER  the fix   ->  proved the ARTIFACT path
two runs, two different claims, because THE CODE CHANGED IN THE ONE PLACE THAT MATTERED
```

> **The difference between a re-roll and a verification is whether the code changed between the runs.**

## The rules

- **A re-run is a verification when the code changed; it is a re-roll when it did not.** Same code, same
  file, same expectation — **any one of those three unchanged and it is repetition, not proof.**
- **The test is PER-CLAIM, not per-experiment.** *Run 2 does not licence run 3.* Each claim carries its own
  justification for the run that produced it.
- **A blanket do-not-re-run instruction is over-broad and can forfeit a real verification.** The Chair's
  caution was aimed at *re-running to get a better number*; it was applied to *re-running to verify a change*
  and correctly refused. **Say what the instruction is FOR, not only what it forbids.**
- **And the residual obligation that comes with an exception:** the exemption is bounded in writing at the
  time it is taken — *if a future run has any of those three unchanged, this note does not cover it.*

## Why it matters more than a process note

**Every "n=1" this project has quoted rests on knowing which kind of run produced it.** A verification is
evidence about the code; a re-roll is evidence about nothing and a step toward a number nobody should quote.
**Ruling 81 says an unfired branch is untested; this says a re-run without a change is not a test.**

## The Chair's share

**The instruction was mine and it was over-broad.** An agent following it to the letter would have closed a
real gap with a claim and no proof — **which is the exact defect the instruction existed to prevent.**
