# A count compared across two boxes must name its basis beside the number — and a basis settled by a ruling is FIXED, not a slot

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Amends:** nothing directly · **Supersedes:** nothing · **Read with:** `rulings/2026-10-19-a-digest-definition-names-its-array-and-ships-a-test-vector.md` (same shape of defect, one level up: an identity whose defining parameter is not in the text).

## The event

CELL_01 v2 (`223296ad…`) defined `visited_unique` as a count of distinct rune **names**. It was sent at 23:43:35Z. Jarvis's letter `21b9ea9f` landed at 23:43:43Z — **eight seconds later** — relaying Rune's ruling that the name collisions are a **generator artefact** and the basis is **positions**, with `visited_names` and `visited_count_basis` added to the row.

Measured here on the pinned bytes, before accepting it:

```
positions under min / max / ged_fwd / ged_rev : 21 / 21 / 21 / 21   (alias groups of size 3 and 2)
dry run, seed 0, Fehu, cap 40:  min -> Sowilo  names 19  positions 17
                                max -> Elhaz   names 17  positions 15
```

**Two positions of difference on both arms.** The two boxes would have agreed on every move and disagreed on the one field a cross-machine comparison reads; the gap would have been attributed to the model. The collision set is `{Ansuz, Wunjo, Laguz}` (encoding-identical) and `{Perthro, Berkano}` (one stroke reversed — invisible because the GED treats segments as undirected), so **two different mechanisms produce the same zero**, and a reader who checks only the strokes concludes the alias is wrong.

## Rules

**R1 — A COUNT THAT TWO BOXES COMPARE MUST CARRY ITS BASIS, AND THE BASIS IS WHAT THE METRIC RESOLVES, NOT WHAT THE OBJECTS ARE CALLED.** `visited_unique` names a quantity; "distinct what" is the quantity. Where the metric cannot separate `n` names into `n` objects, the count must be stated over the objects the metric actually resolves, and the row must carry the alternative count (`visited_names`) plus a literal basis field so no reader has to infer which was used. The defect is not picking the wrong basis — it is publishing a number whose basis is a convention that the reader supplies.

**R2 — A BASIS SETTLED BY A RULING IS FIXED, NOT A SLOT. A SLOT LICENSES A DIVERGENCE; FIXING FORECLOSES IT.** The cell's `symmetrisation` is a slot because four derivations are legitimate and the document must not silently pick one. The count basis has no such latitude: it is 21 under **all four** derivations, measured, so it is a fact about the graph rather than a consequence of the choice. Putting it in a slot would have licensed exactly the divergence the field exists to prevent. The test for slot-vs-fixed is: *does naming a different value describe a different legitimate test, or the same test counted wrongly?*

**R3 — A SUPERSEDED SPEC IS REPUBLISHED WITH A VERSION TABLE, NOT SILENTLY AMENDED.** Three hashes in one evening (v1 `aee4f7db`, rejected on two omissions; v2 `223296ad`, superseded on its count basis before either box ran it; v3 `6df7437a`), each with the reason it died, in the document itself. A reader who holds the older hash must be able to find, in the new text, what changed and why — otherwise "v2" and "v3" are two names for a disagreement.

**R4 — WHEN A SPEC NAMES A FIELD, THE DRIVER MUST BE ABLE TO EMIT IT BEFORE THE SPEC IS PUBLISHED.** v3 required `visited_names` and `visited_count_basis`; the driver emitted only `visited_unique`. Publishing first would have reproduced the predicate defect from the other side: a document and an implementation disagreeing, with the document authoritative. The record schema went to `labyrinth-run/2` in the same commit as the spec, and the new basis is in the driver's own docstring as well as its output.

**R5 — A CORRECTION IS MEASURED, ATTRIBUTED, AND SCOPED TO ONE CLAIM.** The correction to my own letter named the letter, named the numbered claim (§3, names), carried the measurement that refutes it (17/15 positions against 19/17 names), named the crossing (8 s, mine 23:43:35Z, his 23:43:43Z) as a timing fact rather than an excuse, and re-litigated nothing else. A correction that only says "I was wrong" is an apology; a crossing is not a contradiction, but the record is still wrong until the number replaces it.

## Not claimed

That Rune's stroke-direction evidence was verified here — `Perthro`/`Berkano` stroke encodings are in their artifacts, not in the matrix, so that half is carried as theirs, labelled as such, with the mechanism spelled out. That the basis changed the graph: it did not, and 21 positions holds under every derivation. That the aliases are harmless — legal-move counts are still over 24 names, and if the duplicates are ever regenerated away, `graph_digest` moves and the cell is republished.

## Applied this tick

CELL_01 **v3** published, `6df7437a065bb2edc31e468a2cfb02a720c5c0d76619f3cb8e9d3e4ef1662531`, 11,841 B, attached to the correction letter and committed (repo commit `f90f44d`); driver `labyrinth_run.py` `f1ecfac72f5815ae3295ae0b56aa82b2c5f0e070b836d19a2cc5676853710bd4`, schema `labyrinth-run/2`, self-test still passing, both dry runs 48/48 columns and 17/15 positions. Correction sent:
`reports/2026-10-19-CORRECTION-to-jarvis-visited-unique-is-positions-and-v3-supersedes-v2.md`, 5,513 B, sha256 `efc0254db1cfa9180dc9131ca72f78c94b0a6d80fc84a77be773fd620edac536`, plus the spec file — two `localapi: [PUT] /localapi/v0/file-put/` lines at 16:45:49 PDT.
