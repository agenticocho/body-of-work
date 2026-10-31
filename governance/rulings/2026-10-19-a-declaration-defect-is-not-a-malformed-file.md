# A declaration defect is not a malformed file — the order check takes its own exit code, the audit path becomes the admission call, and the arm travels with the count

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Supersedes:** one clause of
`rulings/2026-10-19-a-digest-over-a-declaration-cannot-validate-the-declaration.md` (its R2 put the
order mismatch at `EXIT_BAD_GRAPH` = 3; this record moves it to 13 and says why) · **Read with:**
`rulings/2026-10-19-a-digest-certifies-bytes-not-admissibility.md` (its R1/R2 are the doctrine this
record IMPLEMENTS: one command, or both paths exercised) and
`rulings/2026-10-19-a-count-over-an-equivalence-class-is-not-the-count-over-its-members.md` (which
relation a count is over; this record is about which *derivation* a count is under).

## The event

Both prior rulings were filed against a driver that could not enforce them. Implemented this tick on
`ocho_arena/labyrinth_run.py`, before → after (`3e79e80`, 89,038 B, `45c796cd…` → `54e0425`,
120,032 B, `a34d975a…`), measured on the arrived graph `ea33eedc…` (23,682 B):

```
                                  BEFORE                     AFTER
--print-graph-digest              rc 0, graph_digest 596255d9…   rc 3  (semantics is str)
a dry dispatch (--symmetrisation min --rune Fehu --cap 2)
                                  rc 1, AttributeError          rc 3, no out-dir created
same 24 runes + same distances, nodes array SORTED
                                  -- (no check existed)         rc 13 on BOTH paths,
                                                                out-dir not created
--expect-nodes-sha256 naming a different declaration
                                  -- (flag did not exist)       rc 13 on BOTH paths
repair: semantics string -> object with K:12, re-serialised
                                  graph_digest 596255d9… UNCHANGED, file_sha256 ea33eedc… -> 18da0316…
pre-correction graph (fe44d4cf…)  rc 0                         rc 0, derivation_columns_checked 48
```

The order check had to be written before the digest to be worth anything, because `graph_digest()`
hashes the array it is handed: the arrived distances hash to `596255d9…` in elder-Futhark order and
to `fa26e89e…` with the array sorted — **two well-formed digests of the same matrix, one of them about
a test nobody declared.** Exit 5 compares a number computed after the order is already lost.

## Rules

**R1 — A DECLARATION DEFECT IS NOT A MALFORMED FILE. IT GETS ITS OWN CODE, AND THE CODE NAMES THE
REMEDY.** `3` says *this cannot be read as a graph* → regenerate the bytes. `13` says *this reads
perfectly and declares itself under the wrong order* → reorder the array, do not regenerate the
distances. They are different instructions to the peer, and a second box keys on the number, not on
our prose. This **amends** R2 of `a-digest-over-a-declaration-cannot-validate-the-declaration`, which
put the mismatch at 3, and it declines the peer's written request for 3 for the same reason: at 3 a
re-ordering file and an unparseable file arrive at the far box looking identical. 2–10 and 11–12 were
taken, so the declaration check takes 13 — the next free code, not a reuse of a code whose meaning
would then have to be split by context.

**R2 — A PREDICATE MUST BE THE SAME CALL AS ADMISSION, AND THE TEST MUST RUN BOTH PATHS ON ONE
FIXTURE.** Not "the audit path also runs the checks" — two call sites drift, and that drift is exactly
what certified `ea33eedc…`. One function (`validate_graph`), called by `--print-graph-digest` and by
the dispatch, with the order fixed in one place: structural (3) → declaration (13) → start rune (2) →
derivation (6) → digest (5). The self-test asserts `audit_exit == dispatch_exit == declared_exit` for
every malformed fixture, that the refusal is a numbered `labyrinth_run: exit N:` line and not a
traceback, and that no out-dir was created. A guard whose passing case is the only case run is
decoration; the sorted-nodes fixture is the failing case, and it is refused at 13 while its ged-v2
digest is a well-formed 64-hex number.

**R3 — THE ARM TRAVELS WITH THE COUNT, AND A COUNT THAT DOES NOT REPRODUCE IS PUBLISHED WITH ITS
BASIS, NEVER REPEATED.** `edges_used` is arm-dependent — measured at `K=12` on the arrived bytes:
`min` 196, `max` 139, `ged_fwd`/`ged_rev` 335 arcs (pre-correction graph 198 / 138 / 336) — so every
row now carries `edges_used_arm` beside `edges_used`, all three §4-count fields
(`edges_used_basis`, `edges_undirected_pairs`, `edges_one_way`), and a quotable
`edges_used_statement`: `edges_used=196 (basis=undirected_pairs, arm=min)`. The card that ordered this
work quoted `min 147 / max 110`; on the arrived bytes at no `K` in 8…15 does `min` read 147
(95, 107, 142, 175, 196, 213, 234, 248) and 110 is the `K=11` value of `max`, not `K=12`'s 139. The
number did not reproduce; the instruction did, and the fix that survives is the one that makes a
count unquotable without its arm.

**R4 — A ZERO IN A "CHECKED" FIELD IS A READING, NOT A PASS.** `derivation_columns_checked = 0` means
the file carries no `adjacency_*_K` column — not that the columns agreed. The row and the audit both
now carry `derivation_basis` saying so, because the arrived file really does have zero columns while
the spec (`6df7437a` line 111) demands exactly `(=48)`. Stated here, not legislated: the spec's `(=48)`
against a regenerated file that ships none is a v4 question and the v4 is Mike's.

## Not claimed

That `596255d9…` is wrong — it is the correct ged-v2 digest of the canonical declaration, and it stays
the pinned identity across the `semantics` repair (that is R3 of
`a-digest-certifies-bytes-not-admissibility`, now implemented as `pinned_identity` in every row).
That `3` is the wrong code for a file that is not a graph — it is the right code for that fact. That
the 147/110 pair was invented rather than measured — it is unreproducible from these bytes by this
instrument, which is a statement about the reading, not about the reader.

## Applied this tick

Commit `54e0425` (`HEAD == origin/main`, verified after push). Self-test: the seven original flags
green plus `node_order`, `graph_audit`, `pin_rule`. Not touched: `CELL_01_labyrinth.md` (stays
`6df7437a`) and the committed row at `probes/labyrinth/` (orphaned pre-correction baseline, labelled,
never averaged). No model, no GPU, no lease, no cell run. `priorart.py` before filing: 276 records, max
weak 0.157 / 0.156 / 0.110 / 0.094 / 0.070 — the four digest/schema records read by eye and distinguished
above, the other two cited as different subjects.

## What would falsify this

A file whose `nodes` array is exactly `CANONICAL_NODES` and is still refused at 13 (the guard is keyed
on something other than the declaration); or a malformed fixture on which `--print-graph-digest` and a
dispatch return different exits (R2 false, and the drift is back); or a row carrying `edges_used`
without `edges_used_arm` (R3 false); or a `<slug>.<pid>.tmp`-shaped survivor in an out-dir after a
refused dispatch (the refusal did work it was not supposed to reach).
