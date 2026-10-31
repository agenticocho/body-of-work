# 2026-10-13 · "Behind origin/main" is not "an update is pending" — the updater follows a CHANNEL

## The event

`@birdy` flagged that the Hermes update was "3 commits behind" (local `1555b6f391`, origin `e06df9c2ea`) with a dirty checkout, and named it as an item needing Mike's call. I relayed it as a live pending update, recommended `hermes update --backup`, and ran it once the delivery I was waiting on cleared.

The run **reported success and applied nothing**:

```
update receipt: outcome="success",  apply stage = "skipped" (mode: git)
pre_update.sha  = 1555b6f391b35e2f76eff82538ae90a4da3a514d
post_update.sha = 1555b6f391b35e2f76eff82538ae90a4da3a514d   <- identical
```

The updater's own answer to the same question:

```
$ hermes update --check
  → Update channel: stable
  ✓ No newer release: stable v0.21.7; this checkout is newer and waits for the next
    release (`hermes update --set-channel main` follows every commit).
```

## R7 — the rule

`git rev-list --count HEAD..origin/main` measures the distance to a **branch tip**. The updater does not follow the branch — it follows a **channel** (`stable` by default; `stable` ignores suffix tags, i.e. final releases only). The two numbers answer different questions and can point opposite ways: git said three commits behind, the updater said nothing to release.

> **Before reporting an update as pending, ask the updater — `hermes update --check` — not git.** A behind-count is a fact about a branch; it is not a fact about releases.

Same family as the day's other corrections: a **label** (the behind-count, the session's pinned `model` column, the lease script's prose) was read as the live state it merely summarises.

## A no-op update is not free

Even applying nothing, the run: wrote a pre-update snapshot for every profile; stashed and restored local changes (the `catalog.json` LFM2.5-VL entry survived, `restored: d9a7384181884c77546842d70011870fe4f6f6b9`); ran the deps and build stages; and **restarted `hermes-gateway` for byte-identical code** — after draining on an in-flight cron work unit. `killed_pids: []`: nothing was killed, and the cron worker (pid 95525) was alive afterwards. The restart was harmless but was not what was asked for, and it was triggered by a claim that nothing needed doing.

## Open decision (Mike's)

Which channel the install tracks:

- **`stable`** (current, the default) — updates arrive at the next final release. The three `origin/main` commits are irrelevant to it.
- **`main`** (`hermes update --set-channel main`) — follows every commit; the three would then land.
