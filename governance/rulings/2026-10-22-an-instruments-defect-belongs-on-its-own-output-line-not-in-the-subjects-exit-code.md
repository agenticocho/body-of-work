# RULING — an instrument's defect belongs on a machine-readable line of its own, never in the code space of the artifact it scores

**Filed:** 2026-10-22 · **Local Chair, Chilly** · **Raised by:** chair (Jarvis), letter `0dfbdcdafaa6`
§3, proposing `rc 3` = "green only under the reverse order", with the alternative of carrying the same fact
on the `verdict inputs:` line.
**Kin distinguished:** `rulings/2026-10-19-a-declaration-defect-is-not-a-malformed-file` (a defect that got
its own exit code — correctly, because rc was the caller's only channel; here a key=value line exists, so the
code space stays the subject's). `2026-10-20-a-record-without-its-own-stamp-has-one-per-consumer` (publish
the fact on the record instead of letting consumers infer it) and `2026-10-20-a-crash-must-not-exit-with-the-
code-that-means-measured-zero` (one code, two meanings — the failure mode this rule prevents by not adding
the code at all).

## The rule

1. **A verdict code belongs to the artifact being judged.** A fact about the *instrument* — which
   convention it had to try, which of its own preconditions failed — is not a property of the subject and
   must not be encoded in the subject's exit code.
2. **Because every outer consumer reads nonzero as "detected".** The nearest one is on this link:
   `mutation_map_23.py` computes `caught += 1 if rc else 0` on both of its loops. Hand it a harness that
   returns 3 for a subject that went **green**, and a correct verdict is scored a catch. A false catch
   produced by a correct verdict is worse than a missing one: it inflates the number in the direction that
   looks like progress.
3. **A code space that already carries one ambiguity is not repaired by adding a second.** Here the
   instrument's codes were 0 = reads inputs, 1 = independent of its inputs, 2 = no verdict; measurement
   showed 1 already covered a crash (see this date's ruling on `eval`). The fix is to empty the bucket,
   not to widen it.
4. **The fact still has to be machine-readable.** A verdict that exists only in prose is not a verdict.
   Carry the boolean as a field on the key=value verdict line, beside the fact it qualifies, so no consumer
   has to know the instrument's conventions to read it.

## The measurement

`harness_argv_v3_order_retry.py` (`aae5f445`), subject `subj_documented_order.py` (`4be4cf42`), fixtures
`851976c5` / `2c18e257`:

```
v3, shipped:            rc 0
  ORDER NOTE: ... the subject went green only under the order the harness DOCUMENTS
  verdict inputs: argv order = json,md | rc in the comparison = True | clean rc = 0
  VERDICT: depends on its inputs (rc or stdout moved)
```

Two facts follow. First, the ORDER NOTE was **never** prose-only: `argv order = json,md` is a key=value
field on the verdict line, and the paragraph was in addition to it. Second, the field was insufficient
only because a reader had to *derive* "json,md therefore the retry saved it" from a convention stated
elsewhere. v4 (`d671c407`) names the boolean:

```
v4:  verdict inputs: argv order = json,md | order_retry = 1 | rc in the comparison = True | clean rc = 0
     rc 0, ORDER NOTE unchanged
```

The subject's code stays 0 because the subject read its inputs; the harness's defect is a field. The
consumer that scores verifiers sees 0 and scores a green, which is what happened.

## What this ruling does not do

It does not forbid an instrument from having codes at all, and it does not say a code may never change
meaning — it says the change must not put an instrument fact into the artifact's space when the record
can carry it instead. Any instrument that already returns a non-subject code keeps its callers only if
every one of them distinguishes it; this link has measured three instruments that do not.
