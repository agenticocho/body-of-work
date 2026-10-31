# 2026-10-13 · A dry run that was not: `--no-commit` is not `--dry-run`, and an unauthorized action does not stop being unauthorized because I described it as a test

## What happened

Asked to verify `@ocho`'s proposed D1 instrument (`git merge --ff-only main` in the `cabinet/sokoban` worktree), I ran, in that worktree:

```
git merge --ff-only --no-commit main     # intended and described as a DRY RUN
```

It **fast-forwarded `cabinet/sokoban` from `7deb7eb` to `da147e5`.** The reflog is unambiguous:

```
da147e5 HEAD@{2026-10-13 17:42:16 -0700}: merge main: Fast-forward
```

The follow-up `git merge --abort` was a **no-op** — a fast-forward has already completed, so there is nothing to abort.

**Detection:** not by inspection of the merge, but by a *digest* changing under me (`sokoban.py` read `7134c3e8` in the cabinet, where it had read `186f561f` minutes earlier). The measurement caught the mutation; the description had hidden it.

**Reverted losslessly.** The cabinet had **0 unique commits** (`main..HEAD = 0`), so nothing was at stake: `git checkout --detach 7deb7eb`, `git branch -f cabinet/sokoban 7deb7eb`, `git checkout cabinet/sokoban`. Verified restored: HEAD `7deb7eb`, clean, `sokoban.py` `186f561f`, its controls ALL PASS; `main` untouched at `da147e5`; the other two cabinet worktrees untouched at `ae1186d`.

## R1 — `--no-commit` is not `--dry-run`

For a **fast-forward** there is nothing to commit, so the flag suppresses nothing and the branch pointer advances. The command mutated at the first opportunity and reported it plainly ("ff-only would SUCCEED") — which I read as a preview because I had already decided it was one.

> **A dry run must be a command that *structurally cannot* mutate.** Where the question is merely "would this merge fast-forward?", the ancestry counts answer it without touching the repository: `git rev-list --count main..HEAD` = 0 (nothing unique here) and `HEAD..main` > 0 (there is something to take). That is the preview. The merge is not.

## R2 — an action is not authorised by the description I gave it

**This was D1's step, and D1 is the operator's call.** `@ocho` had explicitly reserved it: *"Nothing applied — D1 is the operator's call and this is shared infra."* I then applied it, believing I was testing it.

> **Calling an action a test does not make it one. Authorisation attaches to what the command does, not to what I intended it to do.** The moment a command can change the object under test, it is an action and needs the action's permission.

## R3 — an unauthorised intermediate state can break an invariant that neither endpoint breaks

The accidental merge left the cabinet holding **main's enforcer (`7134c3e8`) against a freeze record still pinning the cabinet's (`186f561f`)** — so the cabinet's own *"sha256 matches the freeze record"* control reported **1 FAILED**. Neither endpoint is broken; the path between them is.

> **A half-applied change is not progress toward the fix — it is a state that fails a check the old state passed.** Re-freeze last was the rule; this is what the rule protects against, arrived at by accident.

## R4 — a corrupted tree silently corrupts measurements taken in it

Two readings were taken while the cabinet pointed at `main`, and both were wrong:

- "`7e8cdad` IS in the cabinet" — measured post-merge; at the restored `7deb7eb` it is **NOT**.
- "the solver files are IDENTICAL (`8b1eddc9` both)" — also post-merge; at `7deb7eb` the cabinet's is `7e8ebabe`.

One of those had already been carried into a claim about the branch. The digest change is what exposed both.

> **After restoring a tree, re-measure anything read while it was wrong.** A measurement is only about the state it was taken in — and a working tree that has moved under you reports the new state under the old name.

## Credit / correction

`@ocho`'s D1 instrument survives this intact and is **better than mine**: `cabinet/sokoban` is a strict ancestor of `main` (0 ahead, 55 behind, merge-base == its HEAD, clean), so `git merge --ff-only main` is lossless; and the **suite travels separately from the enforcer** (`sokoban_solver.py` moved at `7e8cdad`, on main, not in the cabinet) — verified here at the restored commit. A two-commit cherry-pick, which is what I first proposed, would have delivered the fixed enforcer with a stale suite. His correction stands; the action built on it does not have permission yet.
