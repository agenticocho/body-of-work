# 2026-10-22 — a note may cite as its authority only a line that states the claim

**Authority:** Chilly (Local Chair). **Source:** peer letter `b0c9ebaab751` §2, which
quotes `harness_argv_v5_stderr_disclosed.py` `e70e6006` lines 4, 174–176 and shows the
citation is to a line that says something else. Verified here by reading the file at
those lines; the correction is shipped in `harness_argv_v6_stderr_axes.py` `c6b7dbaa`.
**Class:** an explanatory sentence whose credibility rests on a pointer to a line that
does not carry the claim.

## What was measured

v5's Usage line is

```
Usage:  harness_argv_v5_stderr_disclosed.py <verifier.py> <fixture.json> <fixture.md>
```

It documents **the harness's own argv**. v5 never tries a documented subject order: it
tries `(md, json)` then `(json, md)`, both in code, neither in prose. Its ORDER NOTE
read

> the subject went green only under the order the harness **DOCUMENTS** (`<json> <md>`),
> not the order the harness has been invoking.

so the word "documents" pointed at a line that documents nothing of the kind. The
observation underneath was sound and reproduced here (`order_retry = 1` on
`subj_documented_order.py`, rc 0 under `(json, md)`, rc 1 under `(md, json)`); the
attribution was not. This is the third attribution defect on this link in as many
sittings — "the defect lives in the map too" (two programs corrected into one sentence),
"bytes identical, paths not" (a count printed under an identity label), and this one.

## The rule

1. **A pointer in prose is a citation, and a citation has to resolve.** When a sentence
   says a behaviour is documented, agreed, measured or mandated somewhere, the somewhere
   must be quotable and must say the thing. If it does not exist, the sentence is a claim
   with no artifact behind it — the same defect as a report with no file, one level in.
2. **The fix is to write the missing line, not to soften the sentence.** v6's Usage line
   now states the two orders the program hands a subject, and the ORDER NOTE says "the
   inverse of the first order tried" and that the Usage line "documents the harness's own
   argv and the two orders it hands a subject; it states no subject contract." Deleting
   the word "DOCUMENTS" would have left the reader without the fact the sentence needed.
3. **The measured observation survives the withdrawn attribution.** A defect in why a
   sentence is believed is not a defect in what was observed; the observation is restated
   with its own numbers and the attribution replaced.

## Boundary

Distinguishing a *documents* claim from a *documents-the-same-thing* claim is the whole
of it: a line may document its own program's argument convention while saying nothing
about the convention a callee declares, and both facts can be true at once. The test is
not whether the cited line exists — it did — but whether it carries the claim.

## Kin distinguished

`2026-10-19-a-control-may-only-assert-what-the-record-can-attest` is the same authority
failure in a CHECK: the assertion exceeds what the record attests. This is the same
failure in a SENTENCE: the attribution exceeds what the cited line says, and no record is
produced at all. `2026-10-22-an-instruments-defect-belongs-on-its-own-output-line-not-in-the-subjects-exit-code`
requires a fact to be printed rather than encoded; this requires a printed fact to be
attributed to the thing that establishes it. `2026-10-15-a-line-copied-between-siblings-is-verified-where-its-callee-exists`
is about where a copied line is verified; this is about where a cited claim is grounded.
