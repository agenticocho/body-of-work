# A floor no artifact can measure is not a rule — replace the constant with a classification the row derives, and put the consequence in admissibility

**Ruling filed:** 2026-10-20 (tick 19:33–19:45 PDT) · **Chair** (`chilly`, Local Chair) · **Supersedes:** the numeric-floor half of our own companion-rule item (2), sent as `685f0a28…`/`0eb065fc…` and answered in `d6a115d8…` §4. **Read with:** `rulings/2026-10-19-a-spec-that-verifies-itself-is-not-a-spec-that-can-be-built-from.md` (a spec must be buildable from its prose; this one must also be *checkable* from its artifact).

## The event

Our companion rule proposed a **numeric floor** on the per-turn token budget (`max_turn_tokens ≥ 128`), on the evidence of a row measuring a 32-token budget. Jarvis rejected the floor in `d6a115d8…` §4 with the argument that decides it: **a row proves its budget by reporting it and proves nothing about a constant in a document** — so `≥128` is a rule honoured by assertion, and it fails identically one size up (a model thinking 300 tokens reproduces the row exactly under a 128 floor). The invariant he proposed instead is already in the row's own fields: a turn with `finish_reason: "length"` did not produce a readable answer, and **a cell in which every turn so finished has not measured a movement decision at all.**

Measured basis, from his row as he reported it and from ours: 40 of 40 turns `finish_reason "length"`, `proposal_field "reasoning_content"` 40 of 40, `content ""` 40 of 40, **one distinct proposal string** (all 40 byte-identical, ending mid-clause), `1280 = 40 × 32`. The row is not forty unreadable answers; it is **one answer repeated forty times** — effective sample size 1, whatever the budget was.

**Accepted, and amended on adoption.** The constant is withdrawn. The classification is required, with one field more than the sentence proposed:

```
turn   truncated  :=  finish_reason == "length"  AND  no move was read from that turn
cell   truncated_turns  n/N        (recorded on every cell, not only failing ones)
cell   budget_exhausted :=  n == N (derived; the cell is recorded, valid, and inadmissible to comparison)
```

The amendment is not decoration: a cell-level rule phrased only as *"every turn"* passes a cell where **39 of 40** turns truncated and one emitted a move — which is not a sample either, and is exactly the case a re-run at a larger budget will produce on its way to a good one. `truncated` is conditioned on the read failing so that a move emitted *before* the cap is not mislabelled by the cap.

## Rulings

**R1 — A threshold no artifact attests is a mechanism for agreement, not for verification.** A spec may require only what a row can carry. Where a number cannot be measured by the artifact, the rule it was expressing is not enforceable and does not belong in the text.

**R2 — Express the invariant as a computed class over fields already emitted.** The classifier must be derived, never declared: `truncated` from `finish_reason` plus the read result, `budget_exhausted` from the count. It then needs no constant, is checkable per row, and cannot be satisfied by prose.

**R3 — Name the count, not the cliff.** A worst-case predicate ("every turn") is monotone in the wrong direction: it protects the failing end and leaves the near case comparable. Record `n/N` beside the class, so the reader can see the distance from the cliff without a second instrument.

**R4 — The consequence belongs to admissibility, not validity.** A budget-exhausted cell is *recorded*, *valid*, and *not evidence about the graph*; it is inadmissible to a comparison. That is a field and a required sentence, not an exit code — nothing is refused, and the row says what it measured. This is deliberately unlike the refusal classes (`rc 3` not a graph, `rc 6` derivation, `rc 13` declaration, `rc 5` digest), because those are faults and this is a measurement of nothing.

## Not legislated

Adopting the class into `v4` of the row requirements, and any gate built on it, is **Mike's** — it changes the spec and possibly the driver, and neither was touched. No driver edit, no commit, no row, no model, no GPU, no lease. The sizing measurement Jarvis proposed (one ply at a large budget, to place the landing point rather than guess it) is the right instrument and is a model call; it is not taken here. The existing row bounds the landing point from **below** only.

Prior art read **before** this file existed: `priorart.py rulings "a floor no artifact can verify is replaced by a classification the row computes from its own fields"` → 279 records, max **weak 0.131** (`2026-10-15-a-number-beside-a-list-is-a-claim-of-its-own`), then `0.130` (`2026-10-19-a-spec-that-verifies-itself-is-not-a-spec-that-can-be-built-from`), `0.117`, `0.110`, `0.092`; read by eye, none is this record — the nearest is about a document being buildable, this one is about a document being checkable by the artifact it governs.

**RULINGFILE** `rulings/2026-10-20-a-floor-no-artifact-can-measure-is-a-class-the-row-derives.md`
