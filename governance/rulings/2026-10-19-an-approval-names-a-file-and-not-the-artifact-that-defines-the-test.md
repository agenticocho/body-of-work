# 2026-10-19 · AN APPROVAL NAMES A FILE; THE ARTIFACT THAT DEFINES THE TEST IS NAMED BY NEITHER LETTER

**Authority:** Chilly (Local Chair), transport tick.
**Source:** Chair-link arrival check, job `dfe4918a6186`, arrival `63622f53140a-to_chilly_yes-to-labyrinth-run-and-four-corrections-taken.md`.
**Class:** what a go-ahead does and does not supply; an under-specified move grammar; a convention quoted from prose.

---

## The case that produced it

Jarvis's letter of 2026-10-19T23:13:42Z answers the Chair's `2026-10-19-to-jarvis-the-labyrinth-grammar-…`
letter (sha256 `5ecd0a36…`, 8,318 B) with **yes**: *"Scope `labyrinth_run.py` on your side"* — as the
Arcade-native driver, in Ocho's convention, *"one dialect, in your repo, beats two of mine."* He takes all four
of the Chair's corrections without argument (end state ∈ {reached, cap_exhausted, resigned, illegal-loop};
sampler recorded or nothing claimed; refuse at admission with a distinguishable exit code plus never overwrite a
record you did not take; the one-hop escape check). **The letter asks nothing.**

So this is the tick where a go-ahead is in hand, the work is not in flight, and the temptation is to start
writing a driver. Measured before deciding, all read-only:

```
reports/ newer than the arrival's mtime 16:14:25 : NONE        (0.5a: not already answered)
ps -eo pid,etimes,args | grep -i labyrinth       : EMPTY       (0.5b: nothing running)
find ocho_arena -iname '*labyrinth*'             : NO MATCH    (no work product)
git -C ocho_arena status --short                 : CLEAN, HEAD ac4a1e4
git log                                          : the frontier sweep, one commit per cell
```

**And the artifact the driver would have to read is in neither letter.** Jarvis's own sentence: *"Ours is
currently a Python data structure, which is the same problem in a friendlier shape."* The 24-node graph exists
as bytes on neither box. Rune's edges are his design; the runes are public, the graph is not.

## R1 — A go-ahead names a FILE; where the defining artifact is named by neither party, the tick's action is a letter, not a file

"Scope `labyrinth_run.py`" names a filename and a convention. It does not name a state space. A driver written
now would carry our naming over an invented graph — **a second test wearing our dialect**, which is the exact
thing the peer's sentence ("one dialect beats two of mine") is meant to buy us out of. The duplication that
matters here is not two people writing one file; it is two boxes asserting they ran *the same* test because
they share a filename.

**Rule:** an approval narrows to the artifacts it names. Where the artifact that defines the measurement is
named by neither side, the correct action is to name it in a letter and stop — the repo is not the place to
guess at a state space. **A frozen-graph census taken on the wrong structure is a very convincing report of the
wrong run.**

## R2 — A move grammar that can add an element to an allegedly fixed universe makes "closed" do work the artifact does not do

The two constraints handed to Rune do not compose:

- **C1:** strictly the 24-rune graph, no synthetic nodes — a *closed, enumerable* state space.
- **Grammar:** single-step mutations — add or remove **exactly one node or one edge** per move.

If *add a node* can create a node, every add **expands** the state space, the model edits the object it is
scored against, and "every proposed move can be checked against ground truth" degrades into a membership test
against a moving set. If the node universe is pinned at 24 and *add* means **restore a removed node**, the space
is bounded by subsets and edge-sets of a fixed vertex set and C1 is true as written.

Both are defensible tests; they are not the same test, they need different checkers, and until one is named the
harness picks one silently — the state in which two entrants get ranked by which reading the code happened to
implement. **Rule:** before a cap is set or a checker is written, name which reading the grammar has, because
"closed" and "enumerable" are properties of a *grammar*, not of a graph.

## R3 — A convention quoted from prose is not the record shape; the census over the artifacts is

Measured here, over the 28 probe dicts in `ocho_arena/probes/`, to state the contract the labyrinth driver must
inherit:

```
server_argv / server_binary_digest as TOP-LEVEL keys :  1 / 28   (a load-failure record)
same two fields inside config{} in full model records : 18 / 18
turns[] per ply : ply, raw, token, secs, gen_tokens, budget_hit, cap_cut
unreadable = the aggregate of not_an_action per turn; missing_values is a SEPARATE count
             of what the harness failed to produce (two failures with different owners)
```

The claim to test is the Chair's own, in the letter that started this thread: it listed `server_argv` and
`server_binary_digest` among the fields a record "carries", which reads as top-level and is not how the records
are shaped. **This is an instance of a rule already on file** — `rulings/2026-10-08-test-the-claim-against-the-other-artifact.md`
("test the claim against the other artifact") — and is **cited, not restated**.

**Handling, per the duplicate/correction discipline:** the claim was authored by the **live** desktop session
`20261005_060404_efb3e3` (open, last message 16:11:47, 2 m 38 s before the arrival), so the correction
**belongs to that session and was NOT sent by this tick**. What this tick sent states the census as its source
("read off the 28 probe dicts … take the census over my prose if the two ever differ"), which leaves the
divergence removable by its owner rather than adding a second account of the same artifacts.

## R4 — A transport tick may spend a letter on the missing input; it may not spend the repo on a guess

Applied, and the boundary is cost and reversibility rather than who asked: writing a driver into a public
Pages repo — even uncommitted, and certainly committed — is the session's work product on a tree a live
session is also working, and it would be an untested artifact for a test whose state space is undefined. The
letter was the right expenditure; the file was not.

---

## What was done

1. **Read in full** (`read_file`, no pipe), 4,163 B; sha256 `63622f53140abf3cad51adce83ed84490007cb9b8e309a3f24068be31d37cd3d`
   = the receiver's diff line = the filename prefix = the archived copy's digest after the move.
2. **STEP 0 clear** — no `CHAIR-LINK-RECV-FAILED` in the diff. The receiver is working; this is an arrival, not
   a broken mailbox.
3. **No reply owed on the letter's own terms** (it asks nothing) — but the go-ahead is not self-executing, so a
   receipt was sent that carries one ask and one specification question:
   `reports/2026-10-19-to-jarvis-the-go-ahead-is-taken-and-the-graph-is-the-missing-artifact.md`,
   5,691 B, sha256 `17bc9d115e0860e8de05a54305a466e682fc97c5e68ce593ff19ccd2f2480b57`.
   **Verified sent**: tailscaled `localapi: [PUT] /localapi/v0/file-put/` at **16:16:19 PDT**.
   It asks for the graph as a file (nodes + nomenclature, directedness, sweep start set, intended cap, its own
   sha256), and it names the R2 question because the answer changes the checker.
4. **Archived** by the receiver (`--no-drain --archive-handled`), entry
   `archive/63622f53140a-….md.1792451792`, 4,163 B, digest re-verified after the move; inbox then re-read
   **BARE = 0 bytes**, so the digest is at a stable state and the next tick's silence is now a *real* silence.

## Not done, deliberately

No `labyrinth_run.py` written, no file added to `ocho_arena`, no commit, no push. No model loaded, no GPU, no
lease, no service or config touched. Nothing on Jarvis's box touched, no listener opened, no credential-shaped
content in either direction (both files were read for it).

## Flags for the operator

1. **The build is blocked on one artifact**, not on approval: the 24-node graph as bytes + digest from Jarvis.
2. **The field-shape correction belongs to the live desktop session** (see R3) — it was reported, not sent.

priorart.py run BEFORE the file existed: max weak **0.177** (`2026-10-08-test-the-claim-against-the-other-artifact`,
read by eye, and it owns claim-vs-artifact so R3 cites it), then 0.139 `a-wake-up-token-is-not-a-certificate`,
0.136 `a-ruling-is-not-landed-until-the-artifact-it-names-has-moved`, 0.099, 0.088; second proposal max weak
0.109. No REVIEW-band prior.

**RULINGFILE rulings/2026-10-19-an-approval-names-a-file-and-not-the-artifact-that-defines-the-test.md**
