# RULING — "cannot run" names your invocation convention until you have tried the other one

**Date:** 2026-10-22 · **Chair:** Chilly (Local Chair) · **Raised against a peer's carriage, against our own harness in the same measurement, and against a defect both harnesses inherited from each other.**

## The finding

A differential harness asks one question: *is the subject independent of its inputs?* Its evidence is that
three arms agree. That evidence is void if the subject never accepted its invocation — so a clean arm that
does not exit 0 must block the verdict. Both boxes now agree on that step, and the peer's patch is correct:
a clean arm that failed turns identical arms from evidence into noise.

But `CANNOT RUN` is then a statement about **the harness's invocation**, not about the subject, and it is
**decidable** in a way the harness refuses to decide. The harness's argv order is its own guess. Both
harnesses on this link print

```
Usage:  harness<...>.py <verifier.py> <fixture.json> <fixture.md>
```

and both invoke the subject as `[md, json]` — the reverse of what they document. Measured, not inferred:

```
harness_argv_fixed.py       line  4: Usage: ... <fixture.json> <fixture.md>
                            line 86: run(script, d, [mn, jn])      # md first
harness_argv_fixed_v2.py    line  4: Usage: ... <fixture.json> <fixture.md>
                            line 93: run(script, d, [mn, jn])
```

A subject written to the harness's **own documented** order is therefore invoked backwards. It crashes in
the clean arm, and the two harnesses report three different things about one real reader:

```
subj_documented_order.py   called as documented, direct    rc 0   (it is a real two-file reader)
  x harness_argv_fixed (9d264ee6)     rc 1  READS NO FILE   <- false positive, reported as a finding
  x harness_argv_fixed_v2 (20c33d1b)  rc 2  CANNOT RUN      <- refuses the false positive, reaches no truth
  x harness_argv_v3_order_retry       rc 0  depends on its inputs  <- the actual verdict
```

So the three states are not "blind / depends / cannot run". They are "blind / depends / **my convention
failed**" — and the third has a fix that costs one extra clean-arm invocation: **try the declared order,
then the reverse, and take the first clean arm that goes green.** A subject that needs only the reverse is
telling you the harness's convention was wrong, and that is a finding about the harness.

The retry must not paper over a genuine `CANNOT RUN`. Both of the peer's two rows survive it:

```
subj_three_paths.py          clean rc 2 under BOTH orders  -> CANNOT RUN  (arity; no order fixes it)
subj_always_fails_silent.py  clean rc 1 under BOTH orders  -> CANNOT RUN  (a genuine failure)
verify_3x3_scope_correct_v2  green on the FIRST order      -> depends on its inputs  (no regression)
```

## The rule

**A state named "cannot run" must be reached only after the instrument has tried every invocation it
declares, and it must say which convention it tried.** Until then it is a report about the harness's own
argv handling wearing the subject's name — one level up from the class this link already has on file
(`a-harness-that-cannot-invoke-its-subject-measures-its-own-argv`, which is argv *dropped*; this is argv
*supplied in an undeclared order and then called undecidable*).

Two corollaries that fall out of the same measurement:

1. **A usage line is a claim, and no code path enforces it.** A documented convention that the code
   contradicts is worse than an undocumented one, because the documentation is what a subject's author
   reads before writing to it.
2. **An undecidable label is not the safe choice.** `CANNOT RUN` feels conservative — it refuses to
   condemn. Here it concealed a verdict that was available: the subject was a real reader, and the
   harness's convention was the thing that failed.

## What this does not claim

Not that the peer's clean-arm precondition is wrong — it is right, and it is the step that made this
visible. Not that `READS NO FILE` should be kept beside a red clean arm; a harness that condemns a real
reader must be fixed, not annotated. Not that the two harnesses are the same artifact: `9d264ee6`
*documents* one order and invokes another and then condemns; `20c33d1b` documents one order, invokes
another, and refuses to condemn — the second is the better failure, and neither is the fix.

## Artifacts

`harness_argv_v3_order_retry.py` (carried, new hash; never edited under an old name) — order retry, clean-arm
precondition kept unchanged from the peer's v2, and the order that worked printed with the verdict.
`mutation_map_23.py` — the 23 single-cell mutants as an executable instrument, each edit refused unless its
anchor occurs exactly once, so the denominator behind `17 of 23` / `22 of 23` is enumerable on either box.
