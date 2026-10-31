---
name: github
description: "GitHub via gh CLI: PRs, issues, reviews, repos, auth."
version: 2.0.0
author: Ben Barclay (benbarclay), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [github, gh, git, pull-requests, issues, code-review, repos, auth, ci]
    category: software-development
    related_skills: [codebase-inspection, requesting-code-review]
---

# GitHub

Work GitHub end to end with the `gh` CLI (REST fallback where noted): auth,
issues, the PR lifecycle, issue-to-PR delivery, code review, and repo
management. This skill consolidates six former skills; each workflow lives
complete in its reference file — ALWAYS read the matching reference before
starting that workflow, the body below only routes.

## Routing

| Task | Read first |
|---|---|
| Auth broken / new machine / token or SSH setup / gh login | `references/auth.md` |
| Create, triage, label, assign, close issues | `references/issues.md` |
| Branch, commit, open PR, watch CI, merge | `references/pr-workflow.md` |
| Carry an ISSUE to a verified PR (full delivery loop) | `references/issue-to-pr.md` |
| Review someone's PR: diffs, inline comments, verdict | `references/code-review.md` |
| Clone/create/fork repos, remotes, releases | `references/repo-management.md` |

Supporting assets: `scripts/gh-env.sh` + `scripts/git-credential-token.py`
(auth helpers), `templates/` (PR bodies, bug report, feature request),
`references/ci-troubleshooting.md`, `references/conventional-commits.md`,
`references/github-api-cheatsheet.md`, `references/review-output-template.md`.

## Core discipline (applies to every workflow)

- Preflight once per session: `gh auth status` — if it fails, go to
  `references/auth.md` before anything else.
- Prefer `gh` over raw REST; drop to `gh api` only for endpoints the
  porcelain lacks (the cheatsheet lists them).
- Never report CI green without checking `gh pr checks` yourself; never
  claim merged without verifying `state,mergedAt`.
- Read full context before writing: `gh issue view --comments` /
  `gh pr view --comments` — decisions live in threads, not titles.
- Sweep for duplicates before creating anything:
  `gh pr list --search` / `gh issue list --search`.

## Committing into a repo you do not own alone

- **Commit BEFORE you open the PR, and read `Warning: N uncommitted changes` as a failure.**
  `gh pr create` opens against whatever the branch holds at that moment, so the warning means the PR does
  not contain the work you just did — it is not cosmetic. A PR tracks its branch, so committing and
  pushing afterwards updates it with no further call; reporting the PR as carrying the change before
  those two steps is reporting a change that is not in it.
- **A rejected push is never answered with a force.** Non-fast-forward means two lines diverged, so
  establish which commits each side holds (`git log --oneline HEAD..origin/main` and
  `origin/main..HEAD`) before touching anything. A rebase that conflicts leaves HEAD mid-flight: run
  `git rebase --abort`, then **verify HEAD is restored and the tree is clean** before continuing.
- **Land the change on a branch off the REMOTE's head, not off your own.**
  `git worktree add <dir> -b <branch> origin/main` gives a clean base and a single-purpose diff, and it
  leaves the default branch untouched. Do not push the default branch to reconcile a divergence.
- **Never switch branches in a tree another agent is working in.** A checkout rewrites the entire working
  tree. `git worktree add <dir> …` into a scratch directory is the isolation — one directory, instead of
  someone else's half-finished edits.
- **Stage explicit paths, never `git add -A`.** In a shared tree it sweeps up a collaborator's
  uncommitted work into your commit, and the loser is a real commit nobody can find afterwards.
- **Write the commit-message file in a separate call BEFORE the commit that reads it.** `git commit -F
  <file>` on a file that does not exist fails, and the next `git push` then prints **`Everything
  up-to-date`** — which reads like success and means *nothing was committed*. Treat that string as a
  failed commit, not a no-op.
- **Read the commit back out of HEAD rather than trusting the commit's own output**:
  `git show HEAD:<path> | grep <marker>`. The commit reporting success says the object was written, not
  that it holds what you meant.
- **Before assuming anyone can see your work, compare local and remote heads.** A long-lived local repo
  and a remote developed separately will both look healthy while sharing almost no history, and they
  surface only when a push is refused. Same rule as reading state back from the target: a commit that was
  accepted is not a commit that is reachable by the reader.

## Verification

- The workflow's own reference file defines done for that task.
- Cross-cutting: every claim about remote state (CI, merge, release,
  issue state) is backed by a fresh `gh` read, never memory.
