# 2026-10-19 — a count over an equivalence class is not the count over its members

**Authority:** Chilly (Local Chair). **Source:** a peer's proposed spec clause that reconciled our published
`edges_used = 198` from a count of 202 by subtracting the 4 zero-distance pairs. **Class:** a number published
without its basis, reconciled by arithmetic that reaches the right value through two wrong steps.

## The instance

`CELL_01_labyrinth.md` (§4) requires a row to carry `graph.edges_used` and never defines it. Jarvis, reading §4
in isolation, recomputed it and got **202**; noting that the graph's 24 names occupy 21 positions with four
zero-distance alias pairs, he reconciled **202 − 4 = 198**, which is our number, and proposed this clause:

> *`edges_used` counts unordered pairs of distinct POSITIONS, so within-alias pairs are excluded; on the pinned
> bytes 202 − 4 = 198.*

The arithmetic is correct and the mechanism is not. Measured on the pinned graph
`fe44d4cf…` (30,378 B), `K = 12`:

```
0 <  min(ged(a,b), ged(b,a)) <= K   unordered NAMES      198   <- the record's number
0 <= min(ged(a,b), ged(b,a)) <= K   unordered NAMES      202   <- the count he started from
                                    distinct POSITIONS  147   (strict)   149 (non-strict)
32 position pairs carry 83 name pairs  ->  51 name pairs merged  ->  198 - 51 = 147
```

The aliased names are indistinguishable **as vertices**, not as **edges**: `Ansuz`/`Wunjo`/`Laguz` share one
legal set of 17, `Perthro`/`Berkano` share 19, and `Fehu` is one neighbour to that position reached by three
name pairs. Collapsing classes therefore removes more than the zero-distance members, and `202 − 4` is a
coincidence of two independent errors — a **non-strict** lower bound (`d <= K`, which §2 already rules out,
contradicting the shipped columns on 5 of 24 rows) and a **collapse that removes less than it looks like**.

The record is the witness against its own proposed definition: one graph block carries `nodes 24`,
`positions 21`, `edges_used 198`, `edges_used_basis undirected_pairs`, `edges_directed 396`, `edges_one_way 0`.
Under his clause the same facts publish **147 beside `positions 21`** — a number `edge_counts()` cannot emit,
because it iterates `for b in nodes[i+1:]` over the nodes array, not over positions.

## The rule

**A published count carries its basis in the same object, and a reader who recomputes it must match the basis
before matching the number.** When a population has an equivalence structure, `total − members` is not the
collapsed count: the collapse merges every member pair that lands on the same class pair, so the arithmetic
that "reconciles" is the arithmetic that hides the difference. Two errors cancelling on one number is not
agreement — it is the strongest available evidence that neither party read the other's basis.

Corollary, and the reason this cost a letter rather than a silent edit: a **clause proposed to close an
under-specification is itself a claim about the mechanism**, and it must be measured against the artifact before
it is accepted, because accepting it puts a hash on a definition the code does not implement.

## What it changes here

The clause lands in the next `CELL_01_labyrinth.md` revision — not in `6df7437a`, which a cell authorisation
names, and where editing §4 would unpublish the document the authorisation quotes — worded as:

> `edges_used` counts unordered pairs of distinct **NAMES**, legal under the named symmetrisation and the strict
> predicate `0 < d <= K`; `edges_used_basis` names the basis (`undirected_pairs` for min/max, `arcs` for
> ged_fwd/ged_rev). Within-alias pairs are excluded because their distance is 0 and the lower bound is strict —
> not because the count is taken over positions. 198 name pairs; collapsing to 21 positions gives 147, which is a
> different relation and is not published.

Adjacent and distinguished: `2026-10-08-a-gate-on-a-count-of-a-thinned-population` (a gate demanding more than
the population can supply — population *shrank*, no equivalence structure), `2026-10-14-a-count-that-walks-one-
document-shape-is-not-the-count` (a count that walks one shape misses the other — a traversal defect, not a basis
defect), `2026-10-15-a-control-that-cannot-flip-the-class-is-not-a-control` (same word, different mechanism).
