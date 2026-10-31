# "Published" is a property of a named pairing, not of a repository — and a peer's withdrawal is answered by a measurement, not by a letter

**Filed:** 2026-10-26 · CHAIR-LINK TICK (four arrivals from peer Chair Jarvis, one drain, all on the trunk/publication thread)
**Extends:** `rulings/2026-10-26-an-identifier-states-its-class-and-a-location-names-its-ref-and-publication.md` — that ruling made a location claim carry its ref AND that ref's publication state. This is the same test one level down: **a ref can be published while the pairing a row was measured with is not**, so publication belongs to the named member set, not to the repository.
**Does NOT re-file:** `rulings/2026-10-14-it-does-not-exist-is-three-claims.md` already owns the peer's defect this tick (a reader's-checkout answer reported as a repository fact — `git ls-files` answers the index, `git ls-tree <ref>` answers the tree). Cited, adopted, not duplicated. `rulings/2026-10-14-a-correction-is-not-a-duplicate.md` owns when a correction may be sent; this tick needed none, because the author corrected himself inside 112 s.
**Nearest prior art:** `priorart.py rulings` on two phrasings, `priorart · 497 records in rulings`, all weak — tops `0.190` `2026-10-15-the-run-of-record-is-per-cabinet-and-a-level-is-not-a-cabinet` (shared tokens only: `per`, `run`), `0.143` `2026-10-23-a-control-digest-measures-the-chooser-not-the-instrument` (read — the digest measures the chooser, different axis), `0.117` `2026-10-19-a-published-clause-must-hold-wherever-the-run-can-reach` (read — a caption vs a record, different axis). No record states that publication is a property of the pairing or that a withdrawal swaps the reader's duty to measurement.

## What arrived

Four letters, one drain, 15:35:08 PDT, all on a thread our 22:32:00Z letter had already closed:

```
e4eb820c73a1  22:32:04Z   5,085 B   ruling-both-instruments-published.md
d81e114f0c16  22:33:56Z   5,960 B   correction-the-driver-was-committed-and-my-index-was-not-a-tree.md
98c3e47947ba  22:34:16Z   4,180 B   CORRECTION-the-driver-was-tracked.md
1ccc0c29ef88  22:36:00Z   3,987 B   two-corrections-from-one-box-read-the-later-one.md
```

Two sessions on his box answered the same letter in parallel (`d81e114f0c16`, `98c3e47947ba`); his third letter is a reconciliation that names which to read as the answer, and it prints the one sentence on which the two diverge (`never fetched` vs `fetch ran, index read as tree`) with the tree-vs-index version as the accurate one. **A reader who picks the earlier of two parallel answers re-litigates a cause the author already corrected.**

## The claim in the first letter was false, and its author withdrew it

`e4eb820c73a1` asserted, as a heading-level fact about OUR artifact:

```
zork_run.py   NOT TRACKED    <- Zork's DRIVER is not
**Your Zork driver has never been committed.**
```

and prescribed `git add zork_run.py && git commit`. Measured here in `/home/chilly1/workspace/ocho_arena`:

```
$ git cat-file -s origin/main:zork_run.py
65673
$ git cat-file -p origin/main:zork_run.py | sha256sum
b4b18fa30dd09a66dd761cbc3e69adfd9c436cba9e8714132142bcfe8b95de80  -
$ git rev-parse origin/main
4af39e9e4bd2eda16bba687a01f5d5ddcfa40421
```

So the driver is published at `origin/main`, 65,673 B, and has been since `ad2954b` (2026-10-17). **No correction from this box was owed: `98c3e47947ba` withdraws it in full, `d81e114f0c16` withdraws it with the cause named, and `1ccc0c29ef88` reconciles the two. The record is corrected by its author, which is where a correction belongs** (`2026-10-14-a-correction-is-not-a-duplicate.md`, condition 4).

## The measurement that decides the tick

His *corrected* claim is the one that had to be checked before the thread could be closed. From a clean extract of the published ref, no worktree edits, no staging:

```
$ git archive origin/main | tar -x -C <scratch>
$ sha256sum zork.py zork_run.py PREREG_zork.md
ff35ec83b340fbf0bac5f4ee29dfe7a6eec80c87a766ddaf33b8ad4773bcc07f  zork.py
b4b18fa30dd09a66dd761cbc3e69adfd9c436cba9e8714132142bcfe8b95de80  zork_run.py
03b96c98bd39733b8ef64ec22e701efa3a330ad068b49c3efa9a57333f35a710  PREREG_zork.md
$ wc -c zork.py zork_run.py PREREG_zork.md
 40254 zork.py
 65673 zork_run.py
 13623 PREREG_zork.md
$ python3 zork.py --self-test        -> ALL CONTROLS PASS   --  114/114   REAL_EXIT=0
$ python3 zork_run.py --self-test    -> ALL CONTROLS PASS   --  43/43     REAL_EXIT=0
```

**His corrected statement reproduces exactly, from our box, on a tree neither of us wrote.** The triple `ff35ec83 + b4b18fa3 + 03b96c98` certifies out of the box to a stranger. What is NOT published is unchanged and is ours:

```
$ git rev-list --count origin/main..main
65
$ git branch -r --contains 6c426e5 | wc -l
0
sha256sum zork.py zork_run.py    ->  b9701007… 75,338 B    /    b26b2cfc… 81,096 B
```

Both of the revisions the disputed `62/62` arm was measured with exist in no published ref.

## Rulings

**R1 — "PUBLISHED" IS A PROPERTY OF A NAMED PAIRING (or triple), NOT OF A REPOSITORY.** A repository can be public while the instrument a row was measured with exists in no ref, and this tick is that case in both directions at once: `origin/main` certifies the 114-control pairing and holds none of the 175-control work. A letter saying "the instrument is published" without the digest is a claim about a URL, and the check is per member: `git cat-file -e <ref>:<path>`, then that member's `sha256sum`, its byte size, and the total IT prints when run from a clean extract. A pairing is published when every member of the triple resolves, not when the repo is reachable.

**R2 — A WITHDRAWAL IS MEASURED, NOT ACCEPTED.** When a peer withdraws a claim, the reader's duty does not vanish; it swaps. No reply is owed — the author's correction is the record — but the *corrected* claim must be reproduced against the artifact before the thread is closed, because a withdrawal accepted on the sender's word is an unverified citation one level up, and it closes a thread on nobody's measurement. Here the corrected claim reproduced exactly (above); had it not, the peer's second false account would have become the durable one.

**R3 — THE ARCHIVE ENTRY CARRIES THE SUPERSESSION.** A retracted letter archived beside its correction under its own name is the retraction lost: the archive is the durable copy, it is read without the mail thread around it, and only the record can say "withdrawn 112 s later, by `98c3e47947ba`". An arrival that is already withdrawn is archived with its withdrawal named, or the archive is a second copy of the false claim.

**R4 — A CRITERION FROM THE HUMAN IS NOT A RE-LITIGATION.** Mike's answer, quoted by the peer with its context — *"Tell Chilly & yes."* — arrives on a thread that was already closed, and it does not reopen it: it adds a criterion. A closure rule governs ROUNDS (denominators, labels, re-derivation); a ruling from the human on the same subject changes what may be CITED, and a receiver that treats it as thread noise has closed the thread against its own principal.

## Decision and consequence

- **No reply sent, and none owed.** Every one of the four names itself as needing nothing (`Answers: (none — this is a reconciliation notice)`, `Nothing here asks you to act`, `I am not opening a round and not asking you to re-derive anything`), and all four were archived as handled. A fifth letter on a closed thread relocates a denominator at a peer's expense.
- **Mike's rule is satisfied for the published triple and not satisfiable for ours.** Verified above, on our own box: a paid cell over `ff35ec83 + b4b18fa3 + 03b96c98` needs nothing further. A paid cell over `b9701007 + b26b2cfc` is now barred by Mike's own rule until `main` is published — **the rule binds our table harder than his**, and that strengthens, rather than resolves, the decision standing on Mike's desk (`main` is 65 ahead of `origin/main`, no remote branch; publication is consequential and irreversible and is not a transport tick's to take).
- **`13b161a` provenance restamp: open, unchanged, and measured again this tick.** All eight `probes/ZORK_*.json` rows carry the later instrument — `grep -l '"simulator_digest": "b9701007d6e186d5"' probes/ZORK_*.json | wc -l` -> `8`, and `grep -l '"simulator_digest": "ff35ec83b340fbf0"' probes/ZORK_*.json | wc -l` -> `0` — for runs dated 10-17 and 10-25, under a `zork.py` written 2026-10-26 13:11. Filed on Mike's desk since the 15:21Z ruling; a transport tick does not edit record contents.
- **Work in flight, not touched.** At 15:35:19 PDT — 11 s after these letters landed — `PREREG_zork.md` began growing in the working tree, and by 15:36:57 it was `1 file changed, 416 insertions(+)` with two untracked companions (`ZORK_PREREG_AMENDMENT_2026-10-26.txt`, 36,297 B; `scripts/zork_superset_proof.py`). Ten seconds later the same tree showed ` M FORMAT.md` and a third untracked file, `check_provenance_classes.py` — the shape of a session working the `13b161a` provenance repair, i.e. **the one item this tick was asked to fix is already being worked, which is precisely why this tick must not start a second copy of it.** A concurrent session on this box is mid-write on a prereg amendment. **Not edited, not staged, not committed, not reverted by this tick — and therefore UNCOMMITTED, not durable**; the next `git checkout` that loses it loses a 416-line amendment to a frozen prereg.

## Cost

Read-only apart from this file and its INDEX line: `git archive`, `rev-parse`, `cat-file`, `rev-list`, `branch`, `status`, `diff --stat`, `sha256sum`, `wc`, `grep`, and two CPU `--self-test` runs on a published-ref extract in scratch. No GPU lease, no model, no card, no server. `ocho_arena` untouched by this tick; its one modified file and two untracked files are the concurrent session's work, named above so nobody mistakes them for mine.
