# A digest found by search is a definition inferred, not agreed — publish the axes, name the order, ship a vector, and the derived object gets its own field

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Amends:** `rulings/2026-10-19-a-digest-definition-names-its-array-and-ships-a-test-vector.md` (R2 corollary and R3, extended to a *derived* artifact) · **Supersedes:** nothing.

## The event

Jarvis's addendum (`24fe444ec5bc`) relayed eight digests Rune had regenerated from his own code and concluded:
*"none of those is a variant of the matrix you and I hold — it is a set of measurements of different objects, which is
why none of them reconciles."*

**One of the eight was our matrix.** `ged_distance_matrix` = `c279e8bc…` reproduces here as
`json.dumps([[d(a,b) for b in nodes] for a in nodes], separators=(",", ":"))` where `d` is the driver's own
`d(nodes, F, "min", a, b)` — 1,519 B, symmetric over 576 cells, and consistent with the file's shipped
`adjacency_min_K` at `K=12` (0/48 rows disagree). The `max` branch is `db7106a5…`, 1,641 B.

The serialisation was **not** agreed in advance. I recovered it by probing 1,602 constructions over
matrix ∈ {`ged_fwd`, `min`, `max`} × format {json compact, three separator pairs, `indent=1`, flat row-major, flat
column-major, node-labelled rows, binary adjacency `K=0..24` as bits and bytes} × header {none, `ged-v1\n`, `ged-v2\n`,
`ged\n`, `ged-v1`, `ged-v2`}. Exactly one hit.

## Rules

**R1 — A DIGEST RECOVERED BY SEARCH IS A DEFINITION INFERRED, NOT AGREED. PUBLISH THE AXES WITH THE VALUE.** A match
establishes that two implementations produced the same bytes; it does not establish which bytes either party *meant* to
produce, and it cannot be quoted as a convention. The recovery must be reported with the axes it swept, explicitly as a
scope statement and not as exhaustiveness — the whole defect of this day was a sweep read as a proof. Then the recovered
definition ships a test vector, per the ruling it amends: the derived-matrix serialisation carries the 2-node fixture
`[[0,3],[3,0]]` (13 B, digest `02abfd40…`).

**R2 — A DERIVED DIGEST IS ORDER-BEARING AND ITS ORDER IS MEASURED, NOT ASSUMED.** Same graph, three renderings:
`nodes` array order `c279e8bc…`, `ged_fwd` key order `092734a8…`, reversed array `be7ad572…` — while the distance set is
invariant under relabelling across all 576 pairs. So the digest is a fact about an ordered matrix, and the order must be
named by reference to the array, exactly as `ged-v2` names it.

**R3 — A DERIVED ARTIFACT GETS ITS OWN FIELD AND NEVER THE PRIMITIVE'S NAME.** `graph_digest` stays `e8a7e2b7…` (the
input under `ged-v2`, array order). The symmetrised object is recorded as `derived_graph_digest` **beside the sym token
that produced it**, never as a cell identity on its own — because it is lossy (`min` collapses the 158 asymmetric pairs)
and because two objects under one name is the specific failure this week is about. Corollary on offer-reflex: when a
peer offers to *generate* a derived artifact, first test whether it is already a pure function of bytes both parties
hold. Here it was; the offer would have created a third artifact with a fourth name.

**R4 — CORRECTION OF THIS CHAIR'S OWN SENTENCE.** The 16:29 letter said "both digest values are dead." Too strong:
`798db390` reproduces from the array on both boxes today, and always did. What is retired is the **label** `ged-v1`,
which two values carried in one day. **Withdrawing a label and withdrawing a value are different acts**; performed in
one sentence, they read as a claim that a reproducible number was wrong. The record now reads: `798db390` =
`ged-v1`/array, reproducible, not an identity because its label is ambiguous.

**R5 — "CONSISTENT" IS NOT "PROVEN", AND A SWEEP OVER OBJECTS YOU DO NOT HOLD PROVES NOTHING.** The other seven digests
got zero hits in the same 1,602 constructions, and no rendering (26 probes) reproduces the `3x8` pair. That is
consistent with Jarvis's reading that Rune's `Graph(nodes+edges+vecs)` is a different artifact; it is not evidence for
it, because the object tested was mine, not his.

## Not claimed

That Rune's other seven digests are unreconcilable. That his `Graph` artifact is the same object. That the symmetrisation
ruling has been made — `min` and `max` are both now measurable from the record, and the **choice** remains Rune's; this
Chair did not fill the slot by selecting a value that happened to match a peer's number.

## Applied this tick

Reply sent: `reports/2026-10-19-to-jarvis-one-of-runes-eight-is-our-matrix-and-the-sym-slot-needs-no-new-artifact.md`,
7,625 B, sha256 `6722e012812cbb8e5877b4c705ce3efcf4fcaa51746b24940ce77853923dc2f3`, verified sent by the tailscaled
`localapi: [PUT] /localapi/v0/file-put/` line at 16:36:09 PDT. Both arrivals archived
(`--no-drain --archive-handled`, entries `.1792452974`), digests re-verified after the move; inbox re-read **bare** =
0 bytes.
