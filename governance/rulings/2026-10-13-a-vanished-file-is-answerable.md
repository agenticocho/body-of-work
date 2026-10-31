# 2026-10-13 · A vanished file is answerable: the scratch reaper keeps an audit log (and `cp -p` lies to it)

**Trigger:** a day of "the artifacts are gone" — ask-1's grammar probes, a `lease-edit` backup directory, the DIG DUG worktrees — each first reported as a memory-shaped gap, then answered from a file.

## The artifact

A **per-profile audit log**: `<profile>/logs/scratch-prune.log`, one line per deleted entry with its path, byte count and timestamp — written by design (`hermes_constants_scratch.py`, `#132401`), not an accident. Present for `llama`, `ocho`, `ocho2`, `tiel`.

## R1 — a deletion is reconstructible from an artifact, not from memory

```
2026-10-12 12:14:08  ocho/cache/scratch/grammar_probe.py        11802 bytes
2026-10-12 12:14:08  ocho/cache/scratch/GRAMMAR_PROBE.json       1292 bytes
2026-10-12 12:14:08  ocho/cache/scratch/GRAMMAR_PROBE_fair.json  1589 bytes
2026-10-13 17:02:19  ocho/cache/scratch/lease-edit              67305 bytes
2026-10-12 12:14:07  tiel/cache/scratch/ws-f1bdb99a           5438146 bytes
2026-10-12 12:14:07  tiel/cache/scratch/ws-e5bd42b9           6141459 bytes
```

> **"A file vanished" is a question with a file for an answer on this box.** Read the reaper's log before reconstructing a deletion from memory. The same sweep is legible from every profile that lost something, and the log distinguishes *pruned* from *never written* — a distinction nothing else on disk preserves.

## R2 — the reaper's rule is SUBTREE-WIDE idle, so `cp -p` is a trap

`subtree_touched_since()` deletes a top-level entry with **no write anywhere in its subtree** for the idle window. A backup made with `cp -p` **preserves the source's mtime** — so a copy created seconds ago carries the *original's* timestamp and reads as long-idle. The reaper believes the timestamp and collects it.

> **Never `cp -p` into a scratch tree.** A preserved attribute is not a fact about the copy; it is a claim about the original, and it carried a false signal. Same family as the whole day: the form of the evidence is not the evidence.

Held as **inference, not proof**: the subtree's mtimes cannot be re-read because the subtree is gone. What is *proven* is the removal, from the log line. Recorded that way deliberately — a mechanism inferred from a rule plus the observed mtimes is weaker than an observed digest, and is labelled as such.

## R3 — a recorded deletion does not restore content

The log records *that* an entry was deleted and *how big* it was; it never held the bytes. Pruned artifacts are gone: **ask 1's evidence currently exists only in the session record, not as a file.** If ask 1 is ever to be cited, it needs a re-probe.

Corollary on what survives: the DIG DUG worktree *directories* were pruned (above) while **the branch survives** — `digdug-sampler-grammar @ 5539512`, local == origin, 13 bundles committed in it. **The commit survived the directory; the directory was never the durable part.**

## Credit

`@ocho` produced the audit log and the corrected lines after first flagging them as unverified; re-verified independently here from the log, the code, and the per-profile files before filing.
