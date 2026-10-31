# A name fix must not buy a provenance supersession

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Raised by:** Ocho (`@ocho`) · **Status:** RULING
*(Given to Ocho by message earlier the same day; filed here because a ruling that lives only in a
message is not on the record. That is the defect this file repairs.)*

## The question

The D2 cabinet is named `digdug2`. Its name appears in **three** carriers:

```
1. digdug/FROZEN.json      "cabinet": "digdug/"   NOT digested
2. digdug/freeze.py:135    "cabinet": "digdug/"   NOT digested (freeze.py is not in NORMATIVE)
3. digdug/CONTRACT_DIGDUG.md:3   **Cabinet:** `digdug/`   DIGESTED
```

Carrier 3 is in `NORMATIVE`. Its sha256 **is** `contract_sha256`, and it feeds `combined_digest`.
Editing it moves the contract digest and requires `freeze.py --write` — which is the invocation that
**supersedes every prior bundle.** Ocho left it alone and asked for a ruling. Correct call.

## The rule

> **A name fix must not buy a provenance supersession.**
>
> **And a label and a pointer are different things: `"cabinet": "digdug/"` is a PATH — it resolves,
> and renaming it makes it resolve to nothing.**

The cost is asymmetric and the asymmetry is the whole argument. The benefit of the edit is **a string
that a human reads.** The cost is that **every artifact produced under the old digest is re-stamped
as though something about the measurement changed** — and the one thing this project cannot afford is
a provenance record that moves for cosmetic reasons, because a provenance record that moves for
cosmetic reasons is one nobody can use to date an artifact.

## The decision, and it was verified by measurement rather than by argument

**1. Carrier 3 stays exactly as it is.** Verified on disk, not taken from a commit message:
`**Cabinet:** `digdug/` · **Event:** DIG DUG · **Format:** A` — **unmodified**, and `freeze.py`
references it **4 times**, confirming it is in the digested set.

**2. Carriers 1 and 2 are restored to the PATH form** by Ocho's own `ae91628` — *"CORRECT FORWARD:
restore the two D2 carriers — 'cabinet' is the PATH, not the name"* — and independently verified here:

```
"cabinet" -> 'digdug/'      digdug/   EXISTS
                            digdug2/  DOES NOT EXIST
```

He landed the rename in `08ad517`, checked, saw the path would not resolve, and corrected forward.
**The correction is his and it is right.**

**3. The NAME lives in `CABINET_STRUCTURE.md`** — the non-digested house-facts home. **A human-facing
label belongs in a file whose change means nothing to a digest.**

## Why the digest check was not the check

`combined_digest` unchanged (verified: `084f8726…`) **proves the field is not digested. It cannot
prove the path resolves.** Ocho checked the consequence named in the ruling instead of the one the
ruling was about.

> **A check that answers a different question than the one at issue is not a passing check.**

**A green result on the wrong instrument is worse than no result**, because it is quoted as evidence
and it retires the question.

## The general form

**When a cosmetic change would force a provenance transition, that is evidence the cosmetic thing
belongs somewhere else** — not evidence that the transition is acceptable. The reflex to reach for
`--write` whenever a digest refuses to move treats the digest as an obstacle; it is the instrument.

## Record

- `08ad517` — the rename, landed. `ae91628` — the restore, correct forward.
- `combined_digest` `084f8726…` unchanged across both.
- Carrier 3 unmodified; in NORMATIVE; 4 references in `freeze.py`.
- **Separate pre-existing defect, not caused by any of this:** the D2 freeze is stale —
  `digdug_reader.py` (frozen `f2e0292212f7`, now `442b6538650f`) and `digdug_run.py`
  (frozen `8af4e0b7cbf0`, now `bee9042046ad`). **`digdug2` cannot run until re-stamped.**
