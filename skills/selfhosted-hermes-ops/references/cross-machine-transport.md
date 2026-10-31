# Crossing a gap: the drop-link, the agent DM channel, git over ssh

When work moves between two agent boxes, every failure looks the same from the sending side. These are
the rules that make the far side checkable.

## Verify the FAR SIDE, never the send

A send ack is a local receipt. A `tailscale file cp` returning 0 means queued; a DM dispatch ack means
handed to a background process; a `git push` that exits 0 still needs the ref read back.

- taildrop → grep the PUT out of the daemon: `journalctl -u tailscaled --since '2 min ago' | grep -i file-put`
- git → `git ls-remote`, or `git rev-list --left-right --count main...origin/main` for `0 0`
- DM → a far-side EFFECT (a file written, a session created), never a status field

## The drop-link (taildrop)

- Send with `tailscale file cp <file> <peer>:` — the peer is addressed by name, and a transcript crosses;
  **no credential ever crosses the link in either direction** (no keys, no `.env`, no tokens).
- **One hand per arrival.** The side that SENDS must not also drain, and a reader must not race a drain on
  the same inbox — have the send command run a fresh recv itself so one party owns the arrival.
- **Take an incoming name from a DIRECTORY ENUMERATION, never from a rendering or from prose.** A name one
  character's case from the on-disk name is a LOCAL refusal (exit 3, listing near misses) and the input
  stays in the inbox; the "receiver broken / link down" vocabulary is reserved for loss-indicating
  conditions only. A guard placed BEFORE the consuming step costs a suppressed output and never a lost input.
- Sweep the link ROOT for strays: a file dropped at the root is invisible to a manifest keyed on the inbox.
- Confirm arrival three ways: sha256 == the filename prefix == the archive entry's hash.
- Answer a receipt with silence. A receipt answered twice is the duplication the link exists to prevent.

## The agent DM channel

Six failure modes, none of which is "the message was lost": `target_busy` DROPS with no queue; an
undrained spool; lag; a recipient model collapse; **no ordering at all**; and **no read-receipt** — an
in-flight reply looks dropped.

- **Structural work goes on the BOARD; a DM is a pointer.** The kanban board is durable state, a message is
  words — put work, state and status where it is read, not in a transcript.
- A receipt reader may report `unknown` **by construction** (a payload-only state file with no status
  field) for messages that DID land. **Silence is not non-delivery: do not resend.**
- No ordering ⇒ a reply can cross the message it answers. When two hands touch one arrival, a second answer
  is permitted ONLY if it removes a divergence it names.

## git over ssh

- `ssh -T git@github.com` returns **1 on success** — GitHub authenticates, then declines a shell. A
  non-zero exit read as failure reports a working route as broken.
- **A file's ownership reading is a property of the READER.** A uid renders through NSS, so one inode reads
  `root:root` to one process and `nobody:nogroup` to a process inside a user namespace. Diagnose with
  `cat /proc/self/uid_map` and `ls -ln` (raw numbers) — never the named output. Against a namespace fault a
  `chown root:root` is a **no-op** and a `chown 65534` breaks host pushes; both maps live at once.
- Cure for a git tool tripping over a system ssh config: `git config --global core.sshCommand 'ssh -F /dev/null'`
  (git skips the system `Include`, keeps user settings). Revert: `git config --global --unset core.sshCommand`.
- **Never redirect a fetch's stderr.** A silent failure leaves the remote-tracking ref stale, and a stale ref
  is then read as the world.

## Deciding across two boxes

- **A peer's hold is a boundary on ITS box, not on yours.** When a peer declines a call as not theirs to
  take unattended, and your operator is present and has stated the intent, the call is yours — say plainly
  that you are taking it, on what grounds, and that it is reversible.
- **A stated intent is enough for a call that can be undone in one command, and never enough for one that
  cannot.** Sizing the authority to the reversibility is what keeps the rule from being either timid or reckless.
- **Release a hold by measuring, not by arguing.** Name the condition the peer set and report the measurement
  that satisfies it; a hold released by persuasion leaves the condition unmet.
