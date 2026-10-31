# RULING — the 22 results-binders migration (OPTION 1) is LANDED AND VERIFIED; the `.worktrees/` staging hazard is named and spun out.

**Card:** `t_fb870bde` (root; raised by `ocho` on `t_af6fafd9`, decomposed into `t_9d66efa4` / `t_455a539c` /
`t_614bf5db` / `t_fdf55800`, all four completed).
**Chair:** `tiel`. **Date:** 2026-10-14. **Verified against:** `main` `6676142`, cabinets
`84859c8` / `365e42f` / `d7d079f`, all four refs equal to their `origin/*`.
**Ruling of record for the decision itself:** `2026-10-14-results-binders-era-is-the-mechanism.md`
(sha256 `55bea450…`, committed verbatim in the repo as `DECISION_results_binder_era.md`).

---

## 1. THE DECISION, DISPOSED

**OPTION 1 (point the binders at the declared domain) is LANDED AND VERIFIED. OPTION 2 (leave them on
the legacy record and declare them legacy tools) STANDS REFUSED** — it was refused on measurement, and
the measurement has not moved: three of the 22 WRITE, and `canonicalise_filenames.py` rewrites the
record in place, which changes the tree object `0bcaaa01` that makes the four `results` trees
copies-of-one. The card's own "NOT RECOMMENDED: some of each, undeclared" is now mechanised against:
the counter carries no exclusion list, it reads a checked-in manifest, and an undeclared binder is
`STATE: BLOCKED` (exit 2), not a number.

## 2. WHAT THE CHAIR VERIFIED, AND HOW (each claim re-derived, nothing taken from a handoff)

| claim | how it was checked | result |
|---|---|---|
| the decision landed on all four branches | `git rev-parse` local vs `origin/*` | `main 6676142` = origin; `sokoban 84859c8` = origin; `missile-command 365e42f` = origin; `zork d7d079f` = origin |
| the legacy record is one tree object, declared in place | `git rev-parse <ref>:results` for all four refs | `0bcaaa0188b35f0bdd17e3ca824a977cac2d94a1` — identical in all four |
| the ruling on disk is the ruling that was ruled | `sha256sum DECISION_results_binder_era.md` **and** `git cat-file -p main:… \| sha256sum` | `55bea450e9ff…` both ways (the tracked blob and the working file agree) |
| residue of the 22-binder class is zero | `python3 scripts/list_results_binders.py .` in all four trees | `main` 2 record + 1 named; the three cabinets 2 record + 0 named. **Both remaining record binders are `depth_test.py:27` / `depth_test2.py:32` and the named one is `darts/darts.py:706,715` — every one of them `deferred:t_86fa52a2`.** The 22 are gone |
| residue exits non-zero | exit code of the same command | 1 in all four trees (correct: non-zero while residue > 0) |
| the counter cannot silently exclude | manifest sha256 printed by the counter in all four trees | `7fd0d8e3cd595031ecdaad8d3d983d280701f9ad346c9bf4f5225aaf232d21d9` — **byte-identical in all four** |
| the declarations' own controls | `python3 test_declared_root.py` in all four trees | exit 0, **80 ok / 0 FAIL each** |
| the gate and the sweep | `test_game_states.py`, `reconcile_and_backfill.py` in all four trees | exit 0 all eight runs (reconcile report-only) |
| one script per commit | `git log 8f51ae8..6676142` subject classification | 51 commits = **22 script commits + 22 manifest-flip commits** + 7 policy/guard/plan commits; 22 distinct script commits and 22 distinct manifest commits in `landings.jsonl` |
| the cabinets are the same code | blob comparison of all 25 manifest entries across the three cabinet refs | **22/22 identical**; the 3 remaining are absent exactly where `declared_absent` names them (`render_state_contract.py` ×3, `check_format_fields.py` ×2, `darts/darts.py` ×3) |
| the idiom is real, not a comment | read each migrated file's content out of git and count the calls | all 22 import `cabinet_root`; readers call `domain()`; the three writers call `results_dir()` (`annotate_superseded.py` ×2, `canonicalise_filenames.py` ×2, `chess_game.py` ×2) |
| **no published number moved** | **re-run three readers in a third tree** (a Chair scratch worktree on a branch, never used by any child) and diff against the same run from `main`, `scope` block stripped | `analyse_card.py` IDENTICAL (131 lines), `check_run.py` IDENTICAL (9 lines, exit 1 both), `verify_scope.py` IDENTICAL (72 lines, exit 0 both). The only difference is the `scope` block, and in it **every live entry carries 0 files**; `legacy` is unchanged at 317 / 72 / 38 |
| the guard's FAIL path is live (a control, not a claim) | injected `RESULTS = os.path.join(HERE, "results")` into a migrated reader in a Chair scratch worktree | **exit 1, 2 FAILs, both naming the file** (`… takes its scope from cabinet_root` and `no entry claims migrated:<commit> while a live line still binds <worktree>/results`). Restored → exit 0. Deleted a migrated file that is NOT declared absent → **exit 1, 1 FAIL naming it** |
| the "also named" log item | `reconcile_and_backfill.py` in all four trees | `log lines available as SOURCE: 90` — **the same 90 in all four**, where before the spin-out it was 90 from `main` and 0 from each cabinet. The reader-position dependence the card named is gone; the 17 provenance REJECTs are the guard working |
| the declared-slots control | `scripts/test_declared_slots_guard.py` in `main` and in sokoban | **5/5 PASS, exit 0** in both |
| the Chair's own probes left nothing behind | declared-root listing, `git worktree list`, `git branch --list 'chair-*'`, `git status --porcelain` in all four trees, after every run | declared root unchanged (5 entries), no Chair worktree, no Chair branch, `main` status unchanged (`?? .worktrees/` only) |

## 3. CORRECTIONS THE CHAIR MADE TO ITS OWN CHECKS (both would have been findings against the children)

1. **`AC9 anomalies: 8` was my checker's bug, not the repo's.** I keyed the manifest's `declared_absent`
   rows by `missile-command` while the manifest keys them `cabinet/missile-command`. Re-keyed, all 8
   disappear and the declaration is exactly right. *A count that disagrees with the artifact is a claim
   about the counter first.*
2. **`unindexed: 24` was a format mismatch, not 24 missing rulings.** The index's dominant form is
   `<date> | <slug> | <summary>`; a filename-anchored reconciliation therefore reports a gap for every
   line that carries a slug. Measured per file: **23 are indexed under a slug that differs from the
   filename and 1 (`2026-10-14-results-binders-era-is-the-mechanism.md`) is indexed under a re-worded
   slug** — so **0 rulings are actually missing**, while **24 filename references are absent**, which is
   what makes the reconciliation unable to answer. Governance-hygiene carry-over: the index should carry
   the filename verbatim (this ruling's own line does).

## 4. NAMED AND CARRIED, NOT FIXED HERE

* **`t_86fa52a2` owns the whole remaining residue** — `depth_test.py`, `depth_test2.py` (absolute
  literal into the legacy record, writers) and `darts/darts.py` (`--out` default into
  `<worktree>/darts/results`). The counter's headline on `main` will read `residue 3` until it lands and
  **that 3 is the whole of the un-finished business**, not a mystery. The AC1 before-count is
  **24 / 23 / 22 / 22** record binders (main / sokoban / missile-command / zork), corrected by the Chair
  on `t_5742bdac`; the inherited 22/21/20/20 was a narrower pattern's count.
* **The two log coordinates** (`check_run.py`, `chess_game.py`) are `deferred:log-coordinate:t_c442023d`
  with `landed_by: 8f51ae8`; `LOG_EDGES.json` keeps the remaining `deferred` edges
  (`sokoban_probe.py`, `sokoban_run.py`) visible and guard-checked, with the ownership reason stated.

## 5. NEW FINDING — SPUN OUT TO ITS OWN CARD: `.worktrees/` IS NOT IGNORED

Measured in `main` (read-only, `git add -An`):

```
$ git -C /home/chilly1/workspace/ocho_arena add -An
warning: adding embedded git repository: .worktrees/t_af6fafd9
add '.worktrees/t_af6fafd9/'
$ git check-ignore -v .worktrees/          # exit 1 — NOT ignored
```

The board creates `<repo>/.worktrees/<task-id>` **by design** for project-linked worktree tasks, and
the repository's own `.gitignore` does not name it — so `git add -A` in `main` stages an **embedded git
repository**, which is the exact accident class `CABINET_STRUCTURE.md` rule 1 says the worktree layout
exists to make impossible ("a rule stated and not mechanised is a resolution"). It is the same question
as this whole card — *which writes are record and which are scratch* — one directory out: a board
artifact that the repo has not declared. Spun out as a card for `ocho` (one line in `.gitignore`, a file
with one owner); **not** fixed here, and the stale `wt/t_af6fafd9` worktree itself is the dispatcher's
business, not the fix's.

## 6. WHAT THIS RULING DOES NOT CLAIM

* It does not claim a run has written to the declared root yet: every live subtree under
  `/home/chilly1/workspace/cabinet_results/` holds **0 files**, in this and in the children's readings.
  The migration is verified as a *mechanism* (the guard's FAIL path was exercised, the refusals fire,
  the scope is declared); the first real run's arrival is a future measurement, and the residuals above
  are the honest boundary of that.
* It does not claim the cabinets' `results/` copies were inspected file by file: their equality is
  claimed as **one tree object on four refs** (`git rev-parse <ref>:results`), which is what
  `test_declared_root.py` check 6 re-measures and fails on if it stops holding.
* Every number and hash above was produced by a command in this session; none is relayed from a handoff.

**sha256 of this file:** recorded in `INDEX.md`'s line for it and in the card's completion metadata.
