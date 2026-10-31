# `.worktrees/` is declared scratch — approved on four-tree measurement

**Card:** `t_81dae7fc` (raised by the Chair closing `t_fb870bde`, implemented by `ocho`, reviewed by `tiel`)
**Round:** 1, Artifact lens. **Verdict: APPROVED.** Zero prior `changes_requested` attempts.
**Review instant:** 2026-10-14 17:19–17:21 PDT.

## The ruling

The ignore surface must carry what the repository's own tooling already assumed. `.worktrees/` is
**scratch, and it is declared as a DIRECTORY**, not by its contents — because a directory declaration is
the only form `git check-ignore` can resolve, and because a running card puts whatever it likes under it.

The sharpest evidence that the declaration was *missing rather than undecided* is not in the card body:
`scripts/audit_results_binder_forms.py:36` already carries
`SKIP_DIRS = {".git", "results", "logs", "__pycache__", ".worktrees"}`. The repository had already
answered this question in Python while `git check-ignore .worktrees/` exited 1. The defect was one
declaration surface behind the others — the same shape as the `logs/` widening this rule is copied from.

## What the reviewer measured itself (not taken from the handoff)

* **Landed:** `main` `c6edd71`, `.gitignore` only, 13 insertions; cherry-picks `89f66af` (sokoban),
  `00aa0e0` (missile-command), `1fe250a` (zork) with **`patch-id 42b69d02…` identical to `c6edd71`'s**.
* **Four-tree parity:** `.gitignore` blob `f2e198251716a796b9fa7fb5b532b0696c28d0d0` on all **eight** refs
  (four local + four `origin`); all four local heads equal their `origin` heads.
* **Rule works, all four trees:** `git check-ignore -v .worktrees/` → `.gitignore:26:.worktrees/`, exit 0.
  `git add -An`: **0** lines mentioning worktrees, **0** embedded-repo warnings. `git status --porcelain`:
  **0** lines mentioning worktrees (was `?? .worktrees/`).
* **The defect was real, reproduced causally in a sandbox** (never in the shared tree): with the *parent*
  `.gitignore` and a committed nested repo at `.worktrees/t_probe`,
  `git add -An` → `warning: adding embedded git repository: .worktrees/t_probe` + `add '.worktrees/t_probe/'`,
  verbatim as claimed; with the new `.gitignore` → `add '.gitignore'` only. The fix is causal, not
  coincidental.
* **Specificity:** `.worktrees/zz_review_probe` and `.worktrees/zz_review_probe/results` are ignored; a
  root-level stray is **not** ignored — the rule does not swallow the root.
* **No collateral:** `git ls-files -i -c --exclude-standard | grep -c worktrees` = **0** tracked files newly
  ignored. (The nine `logs/*.out` entries listed by that command are pre-existing under the older `logs/`
  rule, not this change.)
* **Controls hold:** `test_declared_root.py` exit **0** in all four trees, **0** strict FAIL lines, and check
  5's stray probe still verdicts `ok` in all four. `list_results_binders.py`: cabinets byte-identical
  `residue 2 = record 2 + named 0` (manifest `7fd0d8e3`); `main` `residue 1 = record 0 + named 1`.
* **The counter cannot have been moved by this change** — decisive, because the card's `3/2/2/2` baseline
  reads `1/2/2/2` today: the counter's detector is `os.walk` with `.worktrees` already in `SKIP_DIRS` and
  **no git or ignore consult anywhere** in `list_results_binders.py` or `audit_results_binder_forms.py`. The
  `3 → 1` movement in `main` is entirely `t_86fa52a2` landing `a0e712f` + `8d42da3` (depth_test.py,
  depth_test2.py, both `deferred:t_86fa52a2`) inside this card's window; cabinets are unmoved at the card's
  own predicted number.
* **Boundary respected:** the stale `.worktrees/t_af6fafd9` worktree is still registered at `125b7e2`,
  untouched, as the card's out-of-scope item requires; commit touched `.gitignore` only; no `git add -A`.

## Bounded caveats (recorded, non-blocking)

1. `.worktrees/` has no leading slash, so a *nested* `<anywhere>/.worktrees/` is also ignored
   (`some/nested/.worktrees/x` → ignored). Identical in shape to the repo's existing `logs/` rule and
   accepted convention here.
2. `test_declared_root.py:333` carries a mechanised `ignored()` assertion for the `logs/` directory but
   none for `.worktrees/`. The card did not ask for one and names `git check-ignore` as its check; a
   follow-up, not a correction.
3. The rule is verified against git's own `check-ignore`, not against any future board behaviour.

## Hotspot

`.gitignore` — `t_86fa52a2` (decision D4, `darts/results/`) edits the same single-owner file; its edit
stacks on `c6edd71`, and the next editor must read `origin/main:.gitignore`.
