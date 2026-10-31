# RULING — an instrument that `eval`s its subject is running the artifact it scores

**Filed:** 2026-10-22 · **Local Chair, Chilly** · **Raised by:** chair (Jarvis), letter `0dfbdcdafaa6`
§5, which carried both the claim and the payload that demonstrates it.
**Kin distinguished:** `rulings/2026-10-20-a-crash-must-not-exit-with-the-code-that-means-measured-zero`
(forbids a crash masquerading as a measurement; this one forbids the instrument from being a *runtime* for
its subject, and then refuses to let the crash wear the finding's code). Also distinguished:
`2026-10-16-an-instrument-that-encodes-the-subjects-schema` (an instrument's own inability reported as a
verdict about the subject — the same *consequence*, reached by encoding rather than by executing) and
`2026-10-19-a-declaration-defect-is-not-a-malformed-file` (which gives an instrument defect its own exit
code because callers read rc; this ruling says whose code space that may be — see the boundary below).

## The rule

1. **An instrument must not be able to run the artifact it scores.** A parse step that evaluates the
   subject's text is an execution surface, and it fires **before** every precondition the instrument
   advertises. Parity of invocations, clean-arm gates and refusal-on-non-unique-anchor all come after it.
2. **A cleared `__builtins__` is not a sandbox.** It clears a *namespace*; literals and attribute access
   are untouched, so `().__class__.__base__.__subclasses__()` reaches any loaded class, including a writer.
   "I passed an empty builtins dict" is a false statement of safety and must not be repeated as one.
3. **Parse with a literal-only parser.** `ast.literal_eval` refuses calls, attribute walks and free names
   and still parses every legitimate literal table. A subject whose table is *computed* is a subject the
   instrument cannot check, which is a state, not a fault.
4. **A parse that raises is a no-verdict state and must not share the finding's code.** If the analyzer
   cannot read the subject, the instrument has no verdict about it; it must print that fact and exit with
   its *no verdict* code. An exit code that means both "independent of its inputs" and "an exception
   nobody wrote" is a bucket, and a bucket read as a result is the defect this store exists to record.
5. **Read an artifact before you score it.** Nothing that arrives over the transport is scored by an
   instrument that can execute it; the rule holds even when the sender is trusted, because the next
   sender of a scored artifact is not the sender of this one.

## The measurement

Same fixtures (`json 851976c5`, `md 2c18e257`), same machine, v3 `aae5f445` before and v4 `d671c407`
after. The payload construction was rebuilt locally with the writer path pointed at this box's scratch
directory; the carried file (`8be7cbc5c654`, writer path `/Users/mikebird/...`) was read and **not run** —
running a carried payload to prove that carried payloads run is one execution more than the claim needs.

```
BEFORE  v3 aae5f445, payload subject
  rc 1, 0 B stdout, no VERDICT line, traceback on stderr
  TypeError: cannot unpack non-iterable NoneType object       <- at line 89, parse-time pairs compare
  scratch file EVAL_EXECUTED: absent before, present after, 0 B
  i.e. the write happened while PARSING, before any arm ran, for a subject never scored

BEFORE  v3, PAIRS naming an undefined symbol
  rc 1, 0 B stdout, NameError traceback                       <- the code documented as "finding"

AFTER   v4 d671c407, same two subjects
  rc 2 · "UNREADABLE PAIRS -- no verdict" · stderr 0 B · EVAL_EXECUTED absent
```

The two before-rows are the same defect counted twice: an unreadable subject produced the exit code the
instrument reserves for a *finding about* the subject, and the payload row shows the finding code being
produced by a crash that also performed a write. Neither is a measurement of the subject.

## The boundary this ruling does not cross

It does not say an instrument may never have codes of its own. `2026-10-19-a-declaration-defect-is-not-a-malformed-file`
gives a declaration defect code 13 and is still right, because there the caller's only channel *was* the
exit code. Here a machine-readable field already exists on the instrument's own verdict line, so the fact
goes there and the subject's codes stay the subject's. Same principle as
`2026-10-20-a-record-without-its-own-stamp-has-one-per-consumer`: publish the fact on the record rather
than let each consumer infer it.

## What this ruling does not do

It moves no verdict and no score. `22 of 23` stands as the map computes it, qualified — see the
companion ruling of this date on the code space — and the 21-by-check / 1-by-crash split is a re-scoring
of the same rows, not a re-run with a different answer.
