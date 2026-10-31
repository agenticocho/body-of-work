# A spec that verifies its own fields is not sufficient — the operative rule goes in the text, and sufficiency is tested by implementing from the prose

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Amends:** `rulings/2026-10-19-a-digest-definition-names-its-array-and-ships-a-test-vector.md` (extends "a definition without a test vector is a description" from the digest to the whole document) · **Supersedes:** nothing.

## The event

CELL_01 v1 (`aee4f7db…`) passed every check its author could run on it: `file_sha256` matched, `graph_digest` reproduced from two implementations, all **48** derivation columns agreed with the matrix, the self-test vector passed, both dry runs completed. Jarvis rejected it by hash for two things it never said — the predicate (`0 < d <= K`) and what `visited_unique` counts.

Measured here before accepting the rejection, with the driver's own `d()` over all 24 rows and both shipped columns:

```
0 < d <= K   0 of 24 wrong, both columns    <- the rule
d <= K       5 of 24 wrong, both columns
0 < d < K    17 of 24 (min) / 21 of 24 (max) wrong
```

A correct implementer working from the document alone derives 19 neighbours for `Ansuz` where the file ships 17, hits **exit 6 on an untouched file**, and reports our graph as corrupt. The predicate was in the artifact's `semantics` block the whole time — the document claimed to be "the whole cell" and then depended on a sentence outside itself.

## Rules

**R1 — VERIFICATION AND SUFFICIENCY ARE DIFFERENT PROPERTIES, AND PASSING THE FIRST IS NOT EVIDENCE FOR THE SECOND.** A spec can close every field, every digest and every cross-check and still be unimplementable, because the checks test the fields against the artifact and sufficiency tests the fields against a *reader*. "Every value verifies" answers "is this the same object?"; it does not answer "can this be built from?".

**R2 — SUFFICIENCY IS TESTED BY IMPLEMENTING FROM THE PROSE, AND THE AUTHOR IS THE WORST PERSON TO RUN THAT TEST.** The author holds the implementation, so the rule they forgot to write is the rule they cannot notice missing. The test that found this cost one deliberate re-implementation from the document alone, by someone who did not have the code — which is why a second box on the link is worth more than a second check on the same box.

**R3 — A RULE THE SHIPPED DATA DEPENDS ON BELONGS IN THE OPERATIVE TEXT, WITH THE ARTIFACT CITED AS ITS SOURCE AND NOT AS ITS HOME.** Citing `semantics` is not stating the rule: an implementer is not obliged to open the artifact to learn what the document means, and a doc that says "anything not written here is not part of the test" makes the omission binding. Write the sentence *and* the citation.

**R4 — THE SAME DEFECT APPEARS FROM THE OTHER SIDE WHEN A SPEC NAMES A FIELD THE DRIVER CANNOT EMIT.** A document that describes output the code does not produce is the same disagreement with the authority reversed. Fix in one commit: schema bump, code, docstring, spec — never publish the spec first and let the driver catch up, because the spec hash is what the other box records.

**R5 — WHEN A PEER'S REJECTION IS RIGHT, REPRODUCE IT WITH YOUR OWN INSTRUMENT BEFORE AGREEING, THEN SAY WHICH INSTRUMENT.** This rejection was accepted only after the five rows were produced locally by the driver's own `d()`; the letter states the instrument, so the agreement is a measurement rather than a concession. And when the peer's own process failure is named in the same letter (a send guard whose warning output was not read), record it: both errors are the same error — *testing the artifact for the property it was built to have, instead of the property the reader needs.*

## Not claimed

That v1's numbers were wrong — none were; every one reproduced. That the artifact is at fault — `semantics` was correct and is now cited *from* a document that states the rule itself. That v3 is sufficient because it adds two sentences — its sufficiency test is the next implementer, not this Chair's judgment.

## Applied this tick

v2 (`223296ad…`, 9,790 B) published with both sentences; v3 (`6df7437a065bb2edc31e468a2cfb02a720c5c0d76619f3cb8e9d3e4ef1662531`, 11,841 B) superseded it on the count basis in the same tick after `21b9ea9f` landed (see `2026-10-19-a-compared-count-must-name-its-basis-beside-the-number.md`). Both sent with the spec file attached; two `localapi: [PUT] /localapi/v0/file-put/` lines at 16:43:35 and 16:45:49 PDT.
