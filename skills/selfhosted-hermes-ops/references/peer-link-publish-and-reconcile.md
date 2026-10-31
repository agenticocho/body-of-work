# The outbound half of the peer link: the peer cannot read what you never published

The inbound spool (see the Taildrop section in SKILL.md) has an outbound twin with the same shape and the
same silence: work that exists on your disk and is invisible to the peer.

**When a peer says "that artifact does not exist, it never landed", they may be exactly right about the
REMOTE while you are reading it off local disk. You are both correct, about different refs.** Neither side
has made an error, and no amount of re-reading the file on your side will show it.

## Establish the divergence before claiming readiness

```bash
git fetch                                  # seconds; without it every claim below is about a stale ref
git rev-list --count origin/main..HEAD      # our unpushed work
git rev-list --count HEAD..origin/main      # their work we have never seen
git merge-base --is-ancestor HEAD origin/main && echo "superset -> ff possible" || echo "real divergence"
```

- **Two counts, always.** One count is not a divergence measurement. A branch 117 ahead and 21 behind is
  not "117 to publish".
- **Ask whether you hold the trunk at all.** If other agents push to the same branch it advances
  underneath you, and a branch name is a label rather than an identity — resolve it to a sha before
  reasoning about it.
- **A peer reads the PUBLISHED ref.** Any fix not merged is invisible to them, so a re-run re-reports
  defects you have already closed. Merge first, hand out the brief second, and date their numbers to the
  tree they actually read rather than to your HEAD.

## Preview the merge without touching the repo

```bash
git merge-tree --write-tree --name-only <ours> <theirs>    # lists conflicting paths, changes nothing
```

**`git merge --no-commit` is NOT a dry run.** For a fast-forward the flag suppresses nothing and the branch
ADVANCES; `merge --abort` is then a no-op. Ancestry counts and `merge-tree` answer the question without
mutating anything, and a tree that has moved reports the NEW state under the OLD name — so re-measure
anything you read while it was wrong.

## Apply it through a disposable worktree

Never test a merge on shared infrastructure, and never leave a conflict to be resolved on the live tree:

```bash
git worktree add -b reconcile/<name> /tmp/reconcile <base>   # or a non-pruning workspace path
cd /tmp/reconcile && git merge origin/main                   # resolve HERE
# validate (below), commit the merge, then from the real tree:
git merge --ff-only reconcile/<name>                         # your branch is the merge commit's 1st parent
git worktree remove --force /tmp/reconcile && git branch -d reconcile/<name>
```

Because the live branch is the merge commit's first parent, `--ff-only` moves it to the validated result
with **no conflict re-resolved on live infra**. The cabinet/agent worktrees of a multi-worktree repo keep
their own HEADs and are untouched by this.

## Validate with the repo's own falsifiers, then read the ref back

- zero conflict markers anywhere in the tree
- a syntax pass across every source file the merge touched
- the entry point's `--help` (proves imports resolve, not merely that the file parses)
- the repo's test suite — **and run any failure against the PARENT states before naming a cause.** A check
  that is red by design, or red on both parents, is not an artifact of the merge. Reporting it as one sends
  the round chasing a check that is working exactly as written.
- after pushing: `git rev-parse origin/<branch>` must equal the local sha. **A push summary is a claim
  about the transport, not about the state**, and a push reported as "force" by a classifier may be an
  ordinary fast-forward — read the summary line (`old..new  branch -> branch`) rather than the label.

## Two merge-shape lessons worth carrying

- **A conflict is often a CONVERGENCE, not a disagreement.** Two agents implementing the same rule at the
  same line is a finding about the RULE, not just a text collision. Where each implementation covers a case
  the other cannot express, **keep both** and say why in the merge commit — deleting either loses a real
  branch, and "these two are redundant" is exactly the judgement to check before acting on it.
- **Never leave two artifacts sharing one number on the trunk.** When both sides produced a same-numbered
  document, **the deletion of the superseded copy belongs in the commit that lands its replacement** — so
  the trunk never holds two, and never holds zero. Sequencing matters: publishing your copy now and
  deleting it when theirs lands is gap-free; deleting yours first creates a window with no artifact at all.
