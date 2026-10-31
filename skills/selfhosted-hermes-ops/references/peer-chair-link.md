# The peer-Chair link (tailnet)

How two self-hosted Hermes chairs on one tailnet exchange work, and the three places the channel fails
while looking healthy. Use whenever you are about to report to, or accept a report from, a peer chair.

## Transport

```
send    tailscale file cp <file> <peer>:
drain   tailscale file get --wait=false <target-dir>
```

**Nothing drains the inbound spool automatically.** Arriving files sit in the taildrop spool until
somebody runs `tailscale file get`; until then, *"the peer has not replied"* and *"the peer replied and
nobody read it"* print identically. **Drain the spool as the first act of any check-in**, before
concluding anything about the peer's silence — the same rule as draining a mailbox, and it is the
single highest-yield habit on this link.

**Sending costs a queue acknowledgement, not a delivery.** `tailscale file cp` exits 0 when the file is
enqueued. Verify the effect from the sending side: the `localapi: [PUT] /localapi/v0/file-put/` line in
the tailscaled journal, plus a peer row in `tailscale status` showing `active` with a `tx` byte count of
the right order for the file. A zero exit is not the evidence; the transfer is.

## Committed is not published

**A file that exists in your working copy may be invisible on the far side, and the gap is not obvious
from either end.** Read the ref on the REMOTE before citing an artifact to a peer:

```
git ls-remote <remote> refs/heads/*        # what the peer can actually fetch
git ls-tree -r --name-only origin/<br>     # what is on the published branch
git rev-list --count origin/main..main     # unpushed commits
git push --dry-run origin <branch>         # will it even push?
```

Failure modes that all look like *"the artifact is there"* from your side:
- the commit is local only — N commits ahead of the published branch;
- the branch has DIVERGED (M commits behind as well), so the push is **rejected non-fast-forward** and
  nothing can be published until it is reconciled;
- the file is untracked and untracked in a directory nobody published.

**So: before telling a peer that a finding "is in the repo", resolve the name to the ref the peer can
reach, and say when the branch was last fetched.** If a peer reports that a file does not exist on any
ref, **check the remote before disputing it** — a local commit is not evidence against their reading, and
both parties can be right at once.

## Landing a peer's contribution

- **Check the NUMBER before merging, not just the branch.** Two chairs landing findings independently
  will collide on sequence numbers while using different filenames, so a merge can silently produce two
  documents wearing one number. Look for the number on your own trunk first, and resolve numbering
  before merging rather than after.
- **Read back the ref, never the peer's push output.** Verify the sha they quote against `ls-remote` and
the blob against `ls-tree` at that ref; a re-cut branch should be a correction COMMIT rather than a
force-push, so the original claim and its correction both survive in the record.
- **A peer's claim about a shared artifact is a claim about a ref.** Ask which ref, and treat "it is in
the repo" as shorthand for a specific branch at a specific commit.

## Restarting a supervisor while other agents are running

Updating the install, restarting the gateway, or any operation that cycles a supervisor **kills the
background children of the processes it restarts** — a long evaluation dies mid-run, writes nothing, and
leaves a log that ends in the runtime's teardown message (see the void-run rule in
`measurement-integrity`).

- **Before triggering it, list what is RUNNING and what LEASE is held** — processes and lease records,
  not just "is anything loud". An evaluation holding a resource lease for a bounded TTL is a live subject.
- **Define the trigger as a conjunction and state it**, e.g. *lease released AND the holder process gone
  AND the artifact landed*. A single condition fires while work is still finishing.
- **A gateway restart drops the active session.** Write everything needed to reconcile to disk first, and
  say so to the operator, so a dropped conversation costs nothing.
- **Preserve what the update would clobber, and identify it by WHY it matters.** Local modifications to
  the install fall into two kinds: a live capability (a catalogue entry a running service depends on) and
  measurement provenance (a pinned build id that every artifact's comparability rests on). Back both up
  with hashes and re-verify them after the update.
- **The updater is the authority on whether an update is pending, not `git`.** A behind-count against a
  branch tip says nothing about a release CHANNEL; ask the updater's own `--check`.
