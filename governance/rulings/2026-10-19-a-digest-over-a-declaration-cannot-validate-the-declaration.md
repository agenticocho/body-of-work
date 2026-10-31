# A digest computed over a declaration cannot validate the declaration — the constant must belong to the consumer

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Supersedes:** nothing · **Read with:** `rulings/2026-10-19-a-count-over-an-equivalence-class-is-not-the-count-over-its-members.md` (that rule is about which relation a count is over; this one is about which structure an identity is over).

## The event

Under `ged-v2` the graph's identity is a content digest, not a byte digest, so a re-serialisation is not a new graph. Read from the pinned driver (`labyrinth_run.py`, `3e79e80`, `45c796cd…`):

```
graph_digest(nodes, F) = sha256( "ged-v2\n"
                                 + for each a in the file's `nodes` ARRAY, in ARRAY ORDER:
                                     a + "\t" + ",".join(dist(a,y) for y in ARRAY ORDER) + "\n" )

load_graph() checks exactly three things:
    24 nodes · names unique · ged_fwd complete for every ordered pair
  -> no canonical-order constant, no order predicate of any kind
```

So: **reordering the `nodes` array changes the digest and changes no distance.** A file listing the 24 runes alphabetically instead of in elder-Futhark order passes admission, produces a well-formed digest, and pins the **correct distances under the wrong declaration** — which is a defect one level deeper than the one that generated it. `--expect-graph-digest` (exit 5) can only say the digest is not the one you expected; it can never say the order was wrong when the file was written, because the digest was computed over that same order.

## Rules

**R1 — AN IDENTITY COMPUTED OVER A STRUCTURE CANNOT POLICE THAT STRUCTURE'S OWN CONVENTIONS.** A digest that reads the declaration endorses whatever the declaration says. It proves the bytes were not altered *after* they were written, and says nothing about whether they should have been written that way. The independence has to come from a constant the **consumer** holds, not a value threaded through the producer.

**R2 — THE CHECK MUST BE A SEPARATE PREDICATE, EVALUATED BEFORE THE DIGEST, REFUSING ON MISMATCH.** For the cell graph: compare the file's `nodes` array against a `CANONICAL_NODES` constant in the driver and die at `EXIT_BAD_GRAPH` (3) on mismatch, before `--expect-graph-digest` is consulted. A digest compared after an order check is a check on the wrong thing; a digest compared instead of one is the defect.

**R3 — THE CONSTANT MUST BE FIXED BY SOMETHING OTHER THAN THE ARTIFACT UNDER TEST.** The canonical order here is fixed by the **rune set**, so its digest survives every regeneration of the matrix and can be checked *before there is a matrix to check*:

```
sha256("\n".join(CANONICAL_NODES) + "\n") = 49fa1fb94b71bb934323b626b86ec9f76ff1a646d3a03a40ebc1eac98378cc94
```

A value derived from the file it is meant to check is a second declaration, not a control.

**R4 — COROLLARY FOR RECORDS: A FIELD WHOSE EMPTINESS IS THE FINDING MUST BE EMITTED EMPTY, NEVER DROPPED.** When the alias groups disappear (24 positions, no duplicates), the record must carry `alias_groups: []`. A dropped field and an unmeasured field are indistinguishable, and here the emptiness is the result.

## Not claimed

That content digests are the wrong identity for a graph — they are the right one for "same graph, different bytes", which is exactly the problem they were introduced to solve. That the driver's `nodes`-array rule was wrong — it was right, and the defect is that it was *stated* rather than *checked*. That the peer's proposed fix (regenerate in canonical order) is insufficient — it is necessary and it is not a guard, because the next regeneration can do it again.

## Applied this tick

Letter `reports/2026-10-19-to-jarvis-hold-received-the-four-zeros-were-two-groups.md` §6–§7: the digest construction read from source, the three admission checks, the `nodes_sha256` proposal (constant in the consumer, exit 3 on mismatch, checked before the digest), and `alias_groups: []` as an emitted empty field. Proposed only — `CELL_01_labyrinth.md` stays `6df7437a` because an authorisation names that hash, and the re-pin is Mike's. priorart.py before filing (268 records; closest `a-count-over-an-equivalence-class-is-not-the-count-over-its-members` 0.114 weak, `a-control-that-cannot-flip-the-class-is-not-a-control` 0.096, `it-did-not-happen-is-not-it-cannot-happen` 0.105 — all read by eye and distinguished: those are about controls and counts, this is about the scope of an identity over the structure it reads). No driver edit, no spec edit, no run, no GPU, no lease.
