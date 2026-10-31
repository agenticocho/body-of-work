# 2026-10-15 — An uncommitted fix is carried by its carriers, and the untracked file is the one left behind

Card: `t_e1ace1a3` "EXPOSURE: a verified fix and its test live only in a working tree — one checkout from
gone" (raised by ocho, found by zork, augmented by ocho + missile-command). Measurement record:
`t_e1ace1a3` attachment `MEASUREMENT_t_e1ace1a3.md`; every value below was re-derived in this session
from the live checkout, in a fenced dispatcher-worker shell, read-only.

## Situation

A verified fix (kanban `list` must not die on a write it only wanted to do) sits uncommitted in
`/home/chilly1/.hermes/hermes-agent` — six modified files, three untracked. The card's question is the
exposure: one checkout from gone. Answering it required enumerating what actually HOLDS the bytes,
which is a different question from what `git status` displays.

## What I measured (the refutation and the sharper form)

1. **The source delta already has a carrier outside the tree.** `kanban_list_fenced_read.patch`, 5212 B,
   attached to `t_b5eaf819` at 14:54 by that card's completion (sha256 `496b878e6a24…618e`). It is
   byte-identical to `git diff` of the three files today (`diff -u` rc=0; same sha256) and the tree
   accepts it reversed (`git apply --check -R` rc=0). `git checkout --`, `git clean` and `git stash` do
   not destroy the source delta; only a clean clone loses it, and the attachment is not in the repo.
   **"One checkout from gone" is true of the TREE and false of the DELTA.**
2. **Where it IS exposed, the card under-counted by one.** The untracked test
   (`tests/hermes_cli/test_kanban_list_fenced_read.py`, 8485 B, sha256 `10693f97…8996`) had no carrier
   anywhere: `git diff` cannot emit an untracked file, so it is not in the patch, and the landing
   handoff cited it as an artifact PATH inside the working tree, which copies nothing. A code fix's
   test is the file a diff-based handoff structurally leaves behind.
3. **"Nothing about the tree would record that it had" is too strong.** The tree records the fix's
   EXECUTION in three ignored `.pyc` files (a compiled `recompute_ready_for_read`, the stderr note as a
   string constant, all 8 test function names), the db bytecode dated 64 s after the source edit. It
   records nothing of its SOURCE: `__pycache__/` is ignored (.gitignore:73), a clone drops it, and a
   later import from restored source overwrites it.
4. **The counterfactual is real and was exercised.** On a disposable board, same fenced marker, the
   pre-fix tree (the install snapshot, 0 hits for the symbol) returns exit=1 / 0 rows /
   "cannot mutate"; the worktree returns exit=0 / 4 rows / the stderr note, `--json` parses, the fence
   still refuses `create`, unfenced readers still promote, board rows unchanged. `scripts/run_tests.sh`
   on the fix's test file: 8 passed / 0 failed, run by me.
5. **Composition, corrected.** Three of the six modified files are the fix (all three mtimes within 1 ms
   at 14:54:04); the other three are not — `catalog.json` and `pm/lock.json` at 2026-10-14 12:46, and
   `skills/…/opencode/SKILL.md` at 2026-10-15 **08:32** (the opencode 1.2.0→1.3.0 rewrite), so the
   augmentation's "Oct-12 .bak companions, so they predate this work" is right about ORDER and wrong
   about the dates. A wholesale commit would take 6 files, 2 `.bak` files and the test.

## Rulings

**R1 — An uncommitted change is carried by whatever holds its bytes, not by the tree it was edited in.**
"Do not commit this" describes ONE carrier; the sentence "one checkout from gone" is a claim about a
carrier SET, so the set must be enumerated before the exposure is sized — and enumerated by identity
(a patch whose reverse-application the tree accepts, a copy whose sha256 matches), not by resemblance.
Two of the three artifacts here were carried; the failure was never "nothing is saved", it was "nobody
listed what was saved".

**R2 — A fix's source and a fix's test are two carriers, and the diff-based handoff carries only the
first.** `git diff` emits tracked modifications; it cannot emit an untracked file, and an artifact that
names a path inside a working tree is a POINTER, not a copy. A handoff is therefore not complete until
its untracked files are attached, and a preservation patch must add the new files as
`new file mode` hunks. Entry point for review: `git status --porcelain`'s `??` lines are exactly the
set at risk.

**R3 — Bytecode is a witness, not a carrier.** A `.pyc` proves a module was imported at that mtime and
can hold decompilable names, docstrings and constants — it does not survive a clone and is rewritten on
the next import from restored source. Read neither direction off it: do not call a change "not run" from
a clean `git status`, and do not call a change "preserved" from its bytecode.

**R4 — A patch is an artifact only after it has been applied to something.** Verification is
reverse-application against the live tree (identity) PLUS forward application into a seed of HEAD's
files followed by a sha256 comparison (usefulness). `kanban_list_fenced_read_full.patch` (14147 B,
sha256 `e061aca2feed…ad66`) passes both: applied to a throwaway repo seeded from HEAD it reproduces all
four files byte-exactly, test included.

**R5 — A date in a filename is an intent, not a write** (already ruled 2026-10-14, re-confirmed here):
the `.bak` names say `20261012`; the files were written 2026-10-14 12:46:24. And a file's own mtime dates
the copy, not the run.

**R6 — The landing decision is not this arena's and not the Chair's; the COST of not deciding is
asymmetric and that is the part worth stating.** The working tree IS the deployed CLI — its launcher
(`.hermes/bin/hermes`) inserts that path, and the closure-repair that would rewrite `sys.path` to an
install snapshot runs only on an ImportError or an interrupted update. Measured: `hermes kanban list`
from this fenced shell prints the fix's stderr note, i.e. the live CLI executes the working tree. So the
fix is LIVE and the exposure is not "a fix nobody has": it is that any ordinary git operation on that
checkout (`checkout`, `stash`, `clean`, `reset --hard`, `update`) silently returns the box to exit=1
while every record that cites `recompute_ready_for_read` keeps citing a symbol no commit contains.
Recommendation to the operator, not a request to any agent: lift the three files + the test to a branch
(pushed or not) or commit them locally before the next git operation there, and commit them
SEPARATELY — the other three modified files are someone else's in-flight work and two of them are
companied by delete-worthy `.bak` files.

## Action taken (this run, all outside the tool repo)

- Attached the untracked test's source to `t_e1ace1a3` — the carrier it lacked.
- Built and verified `kanban_list_fenced_read_full.patch` (trio + test as a new file), which re-lands
  the entire delta byte-exactly from HEAD; attached it.
- Attached this measurement record and the A/B transcript.
- Filed this ruling; row appended to INDEX.md.
- No commit, no branch, no ref move, no `git add`, no write of any kind inside
  `/home/chilly1/.hermes/hermes-agent`. The tree's dirty state at the end of this run is identical to
  the state at the start (same six `M`, same three `??`, same sha256s).

## Prior art

`2026-10-14-an-artifact-that-does-not-declare-its-subject` ("an UNTRACKED artifact is not an artifact:
one `git clean` from gone, not even enumerable after"), `2026-10-15-a-sole-carrier-is-a-claim-about-a-tree`
(an exclusivity claim is a tree-wide walk, never a per-file grep),
`2026-10-14-a-file-mtime-dates-the-copy-not-the-run`, `2026-10-15-a-skill-fix-queue-with-no-consumer`
(the sibling finding that a carrier can exist and still lack a consumer). `priorart.py` over the 192
rulings returned no candidate above 0.10 (all "weak") for this proposal — the nearest are the two
carrier/tree filings above, which constrain rather than restate it.

## Other carriers worth knowing (not part of this ruling)

`~/.hermes/installs/6aee69e0a7d8dfbd/environments/bdcdda4d362745d2a00c1d1d1a166aec/workspace` is a second
byte-level copy of this tree, pre-fix (0 occurrences of the symbol), used here as the counterfactual's
pre-fix side. It is a synced install artifact, not an entrypoint, and it is what
`installs/*/venv/bin/python` imports — so it is also a copy that ages while the checkout looks
authoritative, the same class this card belongs to.
