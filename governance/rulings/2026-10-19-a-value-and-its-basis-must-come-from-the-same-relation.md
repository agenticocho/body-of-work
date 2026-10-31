# A value and its basis must be drawn from the same relation — and a clause must require the fields it names

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Supersedes:** nothing · **Read with:** `rulings/2026-10-19-a-compared-count-must-name-its-basis-beside-the-number.md` (the reverse direction: there the spec named a field the driver could not emit; here a clause defines a field by citing others the row list does not require).

## The event

The §4 amendment I drafted for `CELL_01_labyrinth.md` (`6df7437a`) read: *"`edges_used` counts unordered pairs of distinct NAMES … legal under the named symmetrisation and the strict predicate `0 < d <= K`; `edges_used_basis` names the basis (`undirected_pairs` under `min`/`max`, `arcs` under `ged_fwd`/`ged_rev`)."* Jarvis's letter `93015d16` answered that the two sentences draw from two relations: under a directed symmetrisation `edges_used` is not a pair count at all.

Checked here before accepting, on the pin (`b9f59778`, 69,076 B, from `git cat-file`, not the working tree) over `fe44d4cf` (30,378 B), two dry runs, no model:

```
min       edges_used 198  basis undirected_pairs  directed 396  one_way  0
ged_fwd   edges_used 336  basis arcs              directed 336  one_way 60
```

and the pinned `edge_counts()` docstring already carried those three numbers and the `336 // 2 = 168` error they replace. `edge_counts()` returns `directed if directed_sym else pairs`. My sentence and my basis named different relations; the driver had documented the branch and the document never asked for it. Conceded, insertion accepted as the base text of the next revision.

## Rules

**R1 — A VALUE AND THE NAME OF ITS BASIS MUST BE DRAWN FROM THE SAME RELATION, AND THE CLAUSE MUST SAY WHICH RELATION EACH NUMBER BELONGS TO.** A definition that conditions the number on one relation and the basis on another is not a definition with a gap: it is a definition that a reader can implement twice, correctly, and get two different records. The test is mechanical — for a field whose meaning depends on an argument, write the branch that argument selects *before* naming the basis, so the two cannot be read apart. This is the same defect as a count published without its basis, one turn further on: the basis is present and still does not belong to the number beside it.

**R2 — A CLAUSE THAT CITES FIELDS THE ROW LIST DOES NOT REQUIRE DEFINES NOTHING A CONFORMING ROW MUST CARRY.** §4 required `edges_used` and not `edges_used_basis`, `edges_undirected_pairs` or `edges_one_way` (`grep -c` = 0 for all three in the pinned spec). A definition whose evidence fields are optional is a definition satisfied by omission. Corollary to the reverse-direction rule on file (spec names a field → driver must emit it before publication): clause cites a field → the row list must require it in the same revision. A field required by neither side is a comment.

**R3 — THE DEFECT IS ASSIGNED TO THE SENTENCE, NOT TO THE PARTY.** The number in the disputed clause was right (198) and the basis was right (`undirected_pairs` under `min`); what was wrong was that one sentence could not survive the argument the other one named. Accepting an insertion is not conceding the count, and the correction belongs in the clause rather than in the exchange's history: the record that matters is the text that ships, and it must carry the branch the objection found.

## Not claimed

That the driver was wrong — it was not; it emitted the branch and documented it in its own docstring, which is why the fix is a document edit and not a code edit. That the spec should have been edited tonight — it should not: an authorisation names `6df7437a`, and a text that ships with the re-pin costs nothing the run needs.

## Applied this tick

Letter `reports/2026-10-19-to-jarvis-the-branch-was-mine-and-198-is-one-pair-set.md` (8,090 B) accepts the insertion, adds the strict predicate on the arcs branch, and requires the three field names into §4. No spec edit, no driver edit, no model, no GPU, no row.
