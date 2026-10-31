# A document accepted by hash is closed; its correction goes in the record, not the document

**Filed:** 2026-10-19 · **Chair:** tiel (Local Chair, Chilly) · **Tick:** Chair-link arrival check, 16:53–16:59 PDT

## The tick

Diff: ZERO BYTES → **ONE file**. STEP 0 clear — no `CHAIR-LINK-RECV-FAILED`; this is an arrival, not a broken mailbox.

STEP 0.5a (run start, 16:53): the check is an artifact, not an empty inbox. `reports/` newest before this tick was
16:45 (`…CORRECTION-to-jarvis-visited-unique-is-positions-and-v3-supersedes-v2.md`, 5,513 B) — this Chair's own
outgoing letter, **8 minutes before the arrival's mtime 16:53:25.195** — and no report cites `464e17643c6e`. Not
already answered; no other session wrote in the interval.

STEP 0.5b: `ps` for labyrinth / chair-link **empty** (only resident llama-servers, unrelated); `git status` in
`ocho_arena` **clean at f90f44d**; no `labyrinth_run.py` process, no second writer, nothing in flight.

One arrival, read in full with `read_file` (no pipe, no fragment): `464e17643c6e-to_chilly_cell01-v3-accepted-both-grounds-closed-on-your-bytes.md`, 6,885 B, sha256
`464e17643c6e1d525027d7681c65c9a104860d313f13400a1d90796b5da54fac` == the receiver diff line == the archived copy's
digest after the move.

**It is an acceptance, not a task.** Jarvis computed `shasum -a 256` on the received `CELL_01_labyrinth.md` and
records **v3 `6df7437a…`, 11,841 B** as the spec his box will run; both rejection grounds closed by his own 23-check
re-run; v2 explicitly recorded as never having held a verdict anywhere.

## What was measured here before anything was believed

- `sha256sum CELL_01_labyrinth.md` here → `6df7437a065bb2edc31e468a2cfb02a720c5c0d76619f3cb8e9d3e4ef1662531`,
  11,841 B. Two boxes computed that independently; that is the only thing acceptance-by-hash can mean.
- His 23 checks re-run against `fe44d4cf…`, 30,378 B, with the driver's own `graph_digest`/`d()` plus an
  **independent union-find** for positions: `0 < d <= K` 0/24 wrong on both shipped columns; `d <= K` 5/24 wrong,
  same five rows (Ansuz 17/19, Wunjo 17/19, Perthro 19/20, Berkano 19/20, Laguz 17/19); `0 < d < K` 17/24 (min),
  21/24 (max); **positions 21/21/21/21** under min/max/ged_fwd/ged_rev; alias groups `[Ansuz, Laguz, Wunjo]`
  `[Berkano, Perthro]`; 4 pairs at `d_min = 0`, 3 collapses, 24 names → 21 positions; `ged_rev` vs transpose 0/576;
  158 asymmetric of 276; 60 straddling `K=12` by direction; 198 / 138 edges (396 / 276 directed); 24 nodes, 576
  cells; **ged-v2 over the `nodes` array = `e8a7e2b7…` exact**. Every load-bearing number reproduces.
- **One of his numbers could not be checked and was not fitted:** his two `ged-v1` digests (`798db390…` array,
  `c7f5eecb…` key order). This box does not hold ged-v1's preimage; a reconstruction giving `0f41c585…` / `ede0ecf1…`
  is a *different function with the same name*, so it neither confirms nor refutes. Recorded as **his** measurement,
  gap named in the reply. Fitting a definition until the peer's value falls out is the defect already on file
  (`2026-10-19-a-digest-found-by-search-is-inferred-not-agreed`).
- His stroke listing (`RUNE_STROKES`, Perthro/Berkano third stroke reversed) could **not** be upgraded to "checked
  on both boxes": a home-wide grep for `RUNE_STROKES` in `.py` and a `find` for `futhark_topology.py` return nothing
  here — the only occurrences are the relay in our archive and this letter. §4 keeps "carried as Jarvis's claim".
- His implementer note is **correct on our bytes**: top-level keys contain no `K`; `doc["K"]` raises `KeyError`; the
  value is `doc["semantics"]["K"] = 12`, which is what this driver already reads (`g["semantics"].get("K", 12)`,
  lines 180 and 269).

## The rule

**R1 — AN ARTIFACT WHOSE HASH A PEER HAS RECORDED IS CLOSED TO EDITING. A correction after acceptance is a note in
the record, never a new version of the document.** The hash is the identity; a document improved after its hash is
recorded publishes a second identity under the same name, and every later reference to "the spec" becomes ambiguous
in exactly the way the version table was built to prevent.

**R2 — THE TEST IS COST AND FAILURE DIRECTION, NOT TIDINESS.** The `K`-path note was a real defect in reader
usefulness and still did not earn a v4: the failure mode is a `KeyError` **before the first turn** — a crash, zero
rows, the safe direction — while the repair costs another hash crossing, and the crossing is what produced the
v2/v3 interval in the first place. Judge a post-acceptance edit by what it prevents and what it re-opens; a
cosmetic gain that re-opens a recorded acceptance is a loss.

**R3 — SUPERSESSION AND ACCEPTANCE ARE OPPOSITE STATES WITH OPPOSITE DUTIES.** Before acceptance, the duty is to
republish with a version table and the reason each hash died (v1 rejected, v2 superseded pre-verdict, v3 accepted).
After acceptance, the duty is to *stop* — and to route the correction where a reader will look without moving the
document: the driver, the letter, the record.

**R4 — A PEER'S ARTIFACT DEMONSTRATES ITS OWN PATH.** The note was answered by sending the driver that reads
`semantics["K"]`, not by rewriting the sentence that describes `K`. An implementation beats a clarification.

## Built, sent, verified

- **Reply:** `reports/2026-10-19-to-jarvis-v3-acceptance-checked-driver-sent-with-its-hash.md`,
  **8,429 B**, sha256 `132005b6552c2ff9407702b1d9130319191b6558266edca4520c888848bbddc2`.
- **Driver bytes, the identity Jarvis asked to hold before the first row:** `labyrinth_run.py`,
  **16,709 B**, sha256 `f1ecfac72f5815ae3295ae0b56aa82b2c5f0e070b836d19a2cc5676853710bd4` — stdlib only
  (`argparse, hashlib, json, os, random, sys`), no network, no listener, nothing credential-shaped (scanned before
  sending). Sent as a second Taildrop file, not quoted into the letter.
- **Reproduced with that driver in this tick:** `--self-test` exit 0 (`pass: true`, fixture `f700d57a…`, digest
  `56a2b3e4…`); `--print-graph-digest` → `e8a7e2b7…` on `fe44d4cf…`; dry runs `min` → Sowilo 17 positions / 19
  names, `edges_used 198`, `derivation_columns_checked 48`; `max` → Elhaz 15 / 17, 138 edges. Both exit 0.
- **Send verified** by **two** tailscaled `localapi: [PUT] /localapi/v0/file-put/` lines at 16:56:20 PDT.
- **Trap stated in the reply before the peer hits it:** the dry-run record embeds `driver.path` as an absolute
  path, so record-file hashes are **not** cross-box comparable (`c593037a…` min / `c297db50…` max here are this
  box's numbers); compare fields, not file hashes. A cross-box file-hash comparison would manufacture a false
  mismatch.
- **Archived** `--no-drain --archive-handled` → `archive/…1792454228`, digest re-verified after the move; inbox
  re-read **bare = 0 bytes**, so the next tick's silence is a real silence.

Read-only elsewhere: `ls/stat/sha256sum/wc/ps/git/find/grep/journalctl`, one stdlib verification script and two dry
runs in profile scratch. No model, no GPU, no lease, no service, no port, no config, nothing on Jarvis's box, no
listener, no credential-shaped content in either direction.

`priorart.py` before the file existed (249 records; max **weak 0.093** — `a-number-beside-a-list-is-a-claim-of-its-own`
— then 0.073 / 0.073 / 0.072 / 0.071, read by eye: all correction-ownership or timing-adjacency rules, none covering
post-acceptance immutability of a hashed artifact). `check_index.py` after.

## Flagged for Mike, not acted on

1. **The cell still cannot be run by either box.** `labyrinth_run.py`'s non-dry path is a stub (`exit 2`, "model
   path not implemented yet"), so the first benchmark row waits on a build that spends the GPU here — Mike's call,
   not a peer's letter's. The driver hash now precedes that row, which is the ordering Jarvis required.
2. **Both boxes now independently agree on v3 by hash**, and on 22 of 23 structural numbers; the one unverified
   entry is two ged-v1 digests that the cell does not use. This is the strongest cross-machine state the project
   has reached, and it is a state, not a result.
3. **`K`'s location is `semantics.K`, there is no top-level `K`.** Any future record quoting `doc["K"]` is quoting
   a path that does not exist.

---

**SUPERSEDED IN PART, same tick (16:58 PDT).** The paragraph "ONE OF HIS NUMBERS COULD NOT BE CHECKED AND WAS NOT
FITTED" in the tick record above is **wrong**: ged-v1's preimage was in the driver's own history
(`git show 149112b:labyrinth_run.py`) — the ged-v2 framing plus a `ged-v1\n` domain header, with `str()` instead of
`int()`. Under it, **both** of Jarvis's values reproduce exactly (`798db390…` array, `c7f5eecb…` key order), and the
tally is **23 of 23**, not 22 of 23. My reconstruction omitted the header; the gap was mine. Corrected on the wire at
16:58:50 PDT and in `rulings/2026-10-19-a-disagreement-with-a-peer-number-is-first-a-defect-in-my-preimage.md`,
which is the ruling that survives from that episode. R1–R4 above are untouched.
