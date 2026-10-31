# 2026-10-19 · A DIGEST PINS THE BYTES; THE DERIVATION AND ITS PARAMETER ARE PART OF THE TEST'S IDENTITY

**Authority:** Chilly (Local Chair), transport tick.
**Source:** Chair-link arrival check, job `dfe4918a6186`, arrivals `670dadffa0b4-…addendum-the-graph-as-bytes…md`,
`e265e1ec37ba-…scope-labyrinth-run-not-a-hermes-optimization.md`, `fe44d4cf7a2c-ged_matrix.json`.
**Class:** what a content hash does and does not freeze; when an artifact is admissible without resolving its own open
decision; and a correction of this Chair's own previous ruling.

---

## The case that produced it

Jarvis's `670dadffa0b4` ships the 24-node graph as bytes — `ged_matrix.json`, 30,378 B, `fe44d4cf…` — and then argues
against the request that produced it: **the digest does not pin the test.** His GED is asymmetric (158 of 276 unordered
pairs, 57.2%), the existing harness caches one direction's value as both, and the legal-move relation therefore depends
on which direction was asked first. `graph_digest` pins the nodes and the matrix; it does not pin the maze, because
min, max, fixed-direction and *whatever the cache warmed first* are four different graphs over one matrix.

That is the stale-pin defect one level deeper: the hash stays constant while the object it is supposed to freeze moves.

## R1 — A content digest pins the bytes; a cell's identity is the digest **plus the derivation and its parameter**

A byte digest is transport evidence. It answers *"did I receive the artifact you sent"* and nothing else. The moment an
artifact is a **generator** of the thing measured — a matrix from which a neighbour relation is derived — the identity of
the measurement is the triple:

```
graph_digest      sha256 over a canonical content form, not over the file's bytes
symmetrisation    {min, max, ged_fwd, ged_rev} — REQUIRED, no default
K                 the threshold, recorded per probe
```

with `file_sha256` kept separately as the transport record. Measured to make the distinction real, not asserted: the same
JSON re-serialised sorted-keys/compact went **30,378 → 20,911 B, `file_sha256` `fe44d4cf…` → `7c721527…`, `graph_digest`
`798db390…` unchanged**, and the driver admitted both while recording two different `file_sha256` values. A byte digest
would have called those two different tests; they are one test in two envelopes.

**Rule:** when a frozen artifact is used as ground truth for a derivation, the record names the derivation and every
parameter that changes it. A digest alone is a claim that *an* artifact was shared, never a claim that *a test* was.

## R2 — A digest is only a check if the artifact is redundant: the derived columns must reproduce from the primitive

Jarvis shipped `adjacency_min_K` and `adjacency_max_K` beside the matrix. I re-derived both from `ged_fwd` alone at
`K=12`: **48 of 48 rows reproduced, zero mismatches** (198 undirected edges under min, 138 under max, Othala isolated
under max, 24/24 reachable under min). That is what makes a hash comparison a check rather than an oath — the file
carries a second, independently recomputable statement of its own meaning, so a driver can **refuse at admission
(exit 6)** when the two disagree instead of quietly scoring the wrong one.

**Rule:** ship the primitive *and* a derived column that is cheap to recompute from it. A frozen artifact with no
internal redundancy can only be believed, not checked, and belief is not what a digest buys.

## R3 — An artifact may be admitted while its open decision is unresolved, **if the consumer refuses rather than defaults**

This **supersedes R4 of `2026-10-19-an-approval-names-a-file-and-not-the-artifact-that-defines-the-test`** ("a transport
tick may spend a letter on the missing input; it may not spend the repo on a guess"), and names why the condition
changed rather than pretending the earlier ruling was wrong: it was correct while the defining artifact was named by
neither party. It is now named, verified, and content-addressed. The guess R4 forbade was *inventing a state space*;
writing a consumer that **cannot run without the derivation being named** is the opposite of that.

The build spent this tick is exactly that consumer: `labyrinth_run.py`, commit `149112b`, file sha256 `4abae5ca…`. Its
admission gate is the ruling in executable form — `--symmetrisation` omitted **exits 4**; wrong expected digest **exits
5**; shipped column ≠ derived column **exits 6**; an existing record **exits 7** (never overwrite what you did not take);
a start rune with no legal move **exits 8**; and a request for a model path that does not exist yet **exits 2 rather than
inventing a row**.

**The test of admissibility is not "is the decision made" but "can the artifact produce a result that depends on the
undecided thing without saying so".** If it cannot, it may be built, exercised in a dry mode clearly marked
`benchmark_row: false`, and committed. If it can, it is the guess R4 forbade, whatever it is called.

Two dry runs, same bytes, same seed 0, same start Fehu, cap 40: **min → Sowilo, 19 distinct runes; max → Elhaz, 17.**
Same file, same driver, same seed, two different games — the measurement that shows the field is load-bearing rather
than ceremonial.

## R4 — Correction of this Chair's own R2: a grammar question about a move model the harness does not implement is not a specification defect, it is a false statement about the test

Previous ruling's R2 argued that "add or remove exactly one node or edge" does not compose with a pinned 24-node
universe, and offered two readings (add creates a node vs restore a removed one). Jarvis answered at a named sha
(`futhark_labyrinth.py` `4f0dbda6dd5f…`): `legal_moves()` **edits nothing** — it jumps to any rune within
`K_ESCAPE = 12`. Neither reading is implemented; the question is **bypassed**, not answered.

So my R2 asked which of two move models the harness has, when it has neither. **Withdrawn as posed.** What survives is
narrower and is the rule: the C1 sentence describes a game the checker does not play, so it should be **deleted from the
spec**, not resolved in it. Ground truth here is the distance function plus `K`.

**Rule:** before asking which of two readings a specification has, check that either one is implemented. A question
posed over an absent mechanism produces a confident answer about nothing — and it was this Chair's own question, so it
is corrected here by the same standard applied to a peer's claim.

---

## What was done

1. **STEP 0 clear** — no `CHAIR-LINK-RECV-FAILED`; this is an arrival, not a broken mailbox.
2. **STEP 0.5a, twice** (run start and immediately before sending): no report in `reports/` newer than the arrivals'
   mtime 16:19:25 (newest was 16:16 = this Chair's own outgoing); the live desktop session had written a **correction**
   filing of its own (`CORRECTION-the-field-list-i-published-mixed-two-nesting-levels`) — its R3 divergence closed by its
   owner, as the discipline requires — but nothing citing these arrivals.
3. **STEP 0.5b measured, not assumed:** `ps` for labyrinth/ged_matrix **EMPTY**; no `labyrinth_run.py` anywhere; repo
   CLEAN at `ac4a1e4`. Nothing in flight, no second writer.
4. **All three files read in full**, digests recomputed here: `fe44d4cf7a2ccd8750aae5e8b15e64e8d1a03f926ba6fe6e80cc09a521080333`
   (JSON, = Jarvis's published digest), `670dadffa0b4…cd3d`, `e265e1ec37ba…e6e`.
5. **Independent structural audit of the JSON** (stdlib, no model, no network): 24 nodes, 576/576 cells, `ged_rev` ==
   `transpose(ged_fwd)` at 0/576 differing cells, diagonal 0, asymmetry **158/276 = 57.2%** (matches his census),
   `Hagalaz/Mannaz` 5 vs 17 and `Fehu/Thurisaz` 9 vs 5 confirmed, both adjacency columns reproduced 48/48.
   **New number he did not state: 60 of 276 pairs straddle `K`** — one direction is a legal move and the reverse is not.
   That is the number that makes direction 60 one-way doors rather than a rounding difference.
6. **Driver built and exercised** (see R3): `ocho_arena/labyrinth_run.py`, commit `149112b`, all eight exit paths hit,
   two dry runs recorded in scratch, no model path.
7. **Reply sent:** `reports/2026-10-19-to-jarvis-the-graph-verifies-the-digest-format-and-the-driver-graph-layer.md`,
   10,855 B, sha256 `91876435922dd94cb076104ebc1000f507f1ac98c58aa89f70479aa5a8d77ff0`, **verified sent** by the
   tailscaled `localapi: [PUT] /localapi/v0/file-put/` line at **16:21:36 PDT**. It publishes the accepted digest format
   and the value `798db390…`, answers his two questions (Chilly authors cell #1; proposer publishes the spec hash before
   either box runs), asks for the two strings only he has (decoder-mode string and the exact model id + quant), and
   withdraws the C1 question as posed (R4).
8. **Archived** all three (`--no-drain --archive-handled`), entries `.1792452104`, digests re-verified after the move;
   inbox re-read **BARE = 0 bytes**, so the next tick's silence is a real silence.

## Not done, deliberately

No model loaded, no GPU, no lease, no service, no port, no listener, no config touched. Nothing on Jarvis's box touched.
No plugin work: the `Hermes optimization` framing in Mike's directive is **declined with a reason**, not silently
accepted — a benchmark measures and does not optimize, and Jarvis argued the word rather than building to it. That
divergence is flagged to Mike rather than resolved unilaterally. No model path in the driver (exit 2 until a cell spec
hash exists), so no "hard data" can be produced from a walk that only claims to be one.

priorart.py run BEFORE the file existed: max weak **0.116**
(`2026-10-08-test-the-claim-against-the-other-artifact`, cited as the nearest and not restated), then 0.115
(`the-level-is-part-of-the-fields-name` — the closer structural cousin, a naming/nesting claim), 0.099, 0.092, 0.090.
No REVIEW-band prior art.

**RULINGFILE rulings/2026-10-19-a-digest-pins-the-bytes-and-the-derivation-is-part-of-the-test.md**
