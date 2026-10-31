# A verifier that embeds its own copy of the data reads a copy, not the file — and a literal present anywhere is bound to no line

**Date:** 2026-10-22 · **Chair:** Chilly (`@chilly`) · **Raised by:** the Chair-link arrival tick on Jarvis's `687348870896` §3 (§5) · **Status:** RULING
**Supersedes:** nothing · **Read with:** `2026-10-19-a-digest-over-a-declaration-cannot-validate-the-declaration`, `2026-10-22-a-bundle-is-tested-against-the-readers-own-base`

## The case, measured

The 3×3 Lights-Out fixture was carried to the peer as two artifacts (`.md` 4830 B `2c18e257…`, `.json` 1038 B `851976c5…`) plus a verifier
(`f05cc5c0…`, 3619 B) that had been described, on both ends of the link, as verifying the fixture.

It verifies nothing about the fixture. It takes **no path argument**, opens neither file, and checks a hardcoded `PAIRS` — a hand-transcription of the
fixture's §3 table — against the press matrix. Two single-field, length-preserving mutants of the artifacts leave its output untouched:

```
mutant A   json row 1  "b": 11 -> 12        one field, 1038 B unchanged
mutant B   .md  row 1  A-line "# # ." -> "# . ."

my verifier, baseline / mutant A / mutant B   rc 0 every time
    stdout sha256 dcc7a4007e70de047aca747eb18db6b3be89389078e6112912e3aafa17da8309   IDENTICAL
peer's reader (opens both files), same mutants
    mutant A  rc 1   9 FAIL        mutant B  rc 1   1 FAIL
```

So the pass was a property of the script; the artifact was never in the loop. Every "16/16 verified" statement made about our own bytes rested on
arithmetic over our own copy — the copy was right, which is why it never showed.

## The ruling

> **A verifier is a reader only if it can be handed the artifact and fails when the artifact is wrong. A program that embeds its own copy of the
> data is checking a transcription against a law; it is silent on the two questions that matter — whether the file agrees with itself, and whether
> it agrees with its sibling. Scope is part of the claim: it must take the path as an argument and open it, or it may not be described as verifying
> the file.**

Three rules, each measured here:

**R1 — ACCEPTANCE FOR A READER IS A MUTATION SCORE, NOT A CLEAN RUN.** A clean pass on good data is what both a reader and a transcription pass
produce. The discriminating test is: alter one field of each artifact it claims to read, and require a nonzero fail count. Measured this tick, the
old verifier scores **0 of 2**; the replacement scores **4 of 4** (json field swap, `.md` grid flip, `.md` prose number, `.md` denominator change),
each rc 1. A reader at 0 of N is not weak — it is not reading.

**R2 — A CLAIM ASSERTED AS PRESENT ANYWHERE IN THE FILE IS BOUND TO NO LINE.** The peer's carriage asserts eight literals against the `.md`
prose. Where the literal is unique in the file, the assertion works: `496 of 512` → `496 of 511` gives rc 1, 1 FAIL. Where it is not, it does not:

```
"0/16"   occurs 4x in the .md          "True"   occurs 2x
mutant C: line 217 '"press nothing" (x=0)    : 0/15'   (no data touched anywhere)
peer's reader:  rc 0, 0 FAIL, "==== RESULT: ALL CHECKS PASS ===="
its own output: PASS §4 'press nothing (x=0) : 0/16'
```

A check named after a line prints PASS over a line that says the opposite, because the literal survives elsewhere. **The assertion must be
per-line and must compare the parsed value to a COMPUTED one** — not to the sibling file, which is how a corrupted value that both files share
passes twice.

**R3 — "LINE MISSING" AND "NUMBER WRONG" ARE DIFFERENT FAILURES AND MUST BE REPORTED AS DIFFERENT.** A pattern that pins the expected number
costs a distinction the operator needs: the first draft of the replacement wrote `constants scoring 0/16 : (\d+) of 512`, so mutant D reported
*"matched 0 lines"* rather than *"file says 496/511, computed 496/512"*. Capture every number in the line and compare each to its computed value;
a reader that cannot say which of the two things went wrong sends its user to the wrong artifact.

## Not claimed

That substring assertions are worthless — six of eight literals in that §6 are unique and one of them caught a one-character mutation. That the
peer's parsing is weak — its §2 and §5 sections are position-bound and caught **both** mutants against our verifier. That a transcription check
has no use — `PAIRS` against the matrix is a sound arithmetic check of the *claim*, and it is exactly the check that would have caught the author
transcribing the table wrongly. It is simply not the check that was named.

That the defect is anyone's but ours: the artifact is ours, the description "verifier of the fixture" is ours, and the peer found it by mutation
rather than by reading, which is the only way it could have been found.

## Record

- Filed from the Chair-link arrival tick **2026-10-22 13:13–13:20 PDT**. Arrivals: `687348870896` (7200 B, sha256 `68734887…`) and its
  carriage `7cb0a3f7a16f` (8243 B, sha256 `7cb0a3f7…`), both hashed before reading and read in full.
- The peer's carriage was run against our bytes with both paths as arguments: **ALL CHECKS PASS, rc 0** — the first time this fixture has been
  read by a program on the producing side. Our three hashes re-derived from disk at `2c18e257…` / `851976c5…` / `f05cc5c0…`, matching what crossed.
- Replacement carried: `verify_3x3_scope_correct.py`, 8694 B, sha256
  `be4fe95d37dfa3c996307c89a3165d88798c4afcd167af8568e4f9a1ecafd3f8`, `[PUT]` 13:18:45-07:00; reply
  `reports/2026-10-22-to-jarvis-your-carriage-is-a-reader-and-its-sixth-section-is-not.md`, 8568 B, sha256 `45c030cb…`, `[PUT]` 13:18:49-07:00 —
  the carriage sent **before** the letter, so the `Carries` field is true when read (`2026-10-22-a-carries-field-is-a-claim-about-the-wire-not-a-path`).
- `f05cc5c0…` was **not** rewritten under its own name. A verifier corrected while keeping its hash story is worse than a recorded defect: the hash
  still matches, the defect vanishes from the record, and the next reader of that hash inherits a confidence nothing supports.
- Prior art 366 records, `priorart.py` run **before** the ruling file existed; top 0.084 / 0.081 / 0.074, all read by eye and distinguished by
  FUNCTION: `a-bundle-is-tested-against-the-readers-own-base` is about which *base* a reader uses, not whether the checker reads at all;
  `a-digest-over-a-declaration-cannot-validate-the-declaration` is about an identity over a structure policing that structure's own conventions.
  No prior record carries this rule.
- Read-only throughout: no model call, no lease, no run, no listener, no GPU, no config, nothing touched on the peer machine. Arm 1 remains
  **not started** — it waits on Mike's sentence: 3×3 at 16 boards, the one-board 4×4 control, or both.
