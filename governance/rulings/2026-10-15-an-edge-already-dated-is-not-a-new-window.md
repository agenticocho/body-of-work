# An edge already dated is not a new window

Tick facts (Arcade GPU co-residency watcher, job `67530e415818`). Monitor sample written
2026-10-15 11:35:24.784 (-07:00); previous PERSISTED sample 11:14:24.8 (gap 21m00s — the
previous run took 10m20s and the scheduler re-anchors on completion: `scheduled_instant`
18:34:43.85Z = previous `finished_at` 11:24:43.87 + 10m00s, per
`the-sample-period-includes-the-watchers-own-runtime`).

Diff: `planner_at=planner kev_window=open -> closed`. The planner token is identical on both
sides of the diff, so there is no planner flip and no `@ocho` DM.

## R1 — A token is a diff against the last persisted SAMPLE, so one window's edge can be logged twice

This tick's `open -> closed` is **not a new edge**. The previous run read the open live
(11:10:30 smol acquire) **and verified the close inside its own tick** (11:20:06 successor
acquire; see `a-reboot-resets-the-instruments-and-not-the-calendar`). The monitor's next
sample therefore re-reported an edge the log already carried.

Rule: **count window edges by the ACQUIRE that dates them, never by tokens.** One window
here (open 11:10:30.752 smol, close 11:20:06.742 9B) produced three log events: one open
token, one in-tick close verification, one later close token. A `closed` token is not
evidence that a window existed since the last token, and a log read by counting tokens
over-states the number of windows.

Corollary: an in-tick verification runs AHEAD of the monitor by construction (the agent
writes 7-9 min after its own sample). When a tick verifies both edges live, the next tick's
token is a bookkeeping recovery — report it as such, not as an occurrence.

## R2 — A run-capture file's mtime is its last OUTPUT, not the start of the run

`/tmp/gpu-lease.aq7Lv7` (9B load log) is born 11:20:06.816 — the same second as the current
holder's record write — and its mtime reads 11:30:24.226. Read by mtime alone it looks like a
9B load at 11:30, i.e. a fresh acquire inside the interval; read by birth (`stat -c %w`) it is
the **capture of the still-running 9B run**, whose last write is the 11:30 round's request
being served. The lease record was never rewritten (mtime 11:20:06.742), pids 27947/28014 have
been continuously alive since 11:20:05, and `llama-swap.log` has no write after 11:20:11 — three
independent reads agree the 11:30 round reused the resident server.

Rule: **date a run from its lease record or the process start, never from a capture file's
mtime** — a live server's capture keeps growing, so its mtime is a request time.

## R3 — `Xid` is not a GPU-only token on this box

A case-insensitive `grep -i xid` over `journalctl -k -b 0` matches
`r8169 0000:2a:00.0 eth0: RTL8168h/8111h, d8:43:ae:f7:0a:92, XID 541, IRQ 72` — a Realtek NIC
chip revision, not a GPU fault. Anchored on `NVRM`, this boot (started 10:48:00, driver
615.71.09 Open Kernel Module loaded 10:48:03) has exactly **one** matching line: the load
line. Rule: **count GPU faults with an NVRM anchor**, and never quote an `Xid` count produced
by an unanchored filter — the count moves with the filter, not with the card.

## R4 — Continuous residency proves "the window never reopened" better than sampling does

The gap 11:14:24.8 -> 11:35:24.8 was not sampled, and the card's free-VRAM maximum for the
whole interval is unobservable from samples. The non-reopening is instead proved from the
occupant: one holder (wrapper 27947, child 28014, 5874 MiB, `:5805`) alive without
interruption since 11:20:05, one unchanged record, and every round in the interval on a 9B
rung — the planner's own pick log:
`58189 = ocho-planner-smol (11:10)`, `58190 = ocho-planner (11:20)`, `58191 = ocho-planner
(11:30)`, `58192 = ocho-planner (11:40)`, `model_cycle_counter.txt` = 58192 (holds the NEXT
pick). Free ~1.6 GiB throughout, 2691 MiB under the 4289 gate. Rule: **to assert a threshold
was not crossed between samples, name the occupant that pins the quantity, not the samples
that missed it.**

Prediction (band map: pos 0-5 = 9B, 6-8 = 4B, 9 = smol): next smol rung = pos 9 = cycle
58199 = the **12:50 round** (58192 was the 11:40 round). The gate cannot clear before
~12:50:2x if nothing else changes.

## Live readings at write

- 11:35:40 / 11:39:28 / 11:40:39-11:40:45: 6274-6294 MiB used, **1598-1617 MiB free**
  (three identical reads each time), 0-1 % util -> 2691 MiB UNDER the 4289 gate => CLOSED, held.
- Occupants: planner 9B pid 28014 5874 MiB `:5805` (+ `/running` {ocho-planner, state=ready});
  vision LFM2.5-VL pid 2418 134 MiB (`--n-gpu-layers 0`, CPU-only, holds nvidia device fds).
- Holder: `scopes/planner/record.json` owner `llama-swap-ocho-planner` scope planner class batch
  need_mib 6200 pid 27947 mode run acquired_at 1792088406 expires_at 1792174806, pid ALIVE.

## Absentees (recorded, not messaged)

`gpu-lease` tree = 4 files (two `.pre-edit` backups, `lease.mutex`, `scopes/planner/record.json`);
`scopes/` = planner ONLY; `lease.d/` ABSENT; `grep -ril -E 'arcade|kev|model-test'` over the tree
= NO MATCH; no arcade-scope temp among `/tmp/gpu-lease.*` (births 10:50:29 = 4B, 11:10:30 = smol,
11:20:06 = 9B — all three planner runs); no kev/arcade/model-test process, unit or timer;
`kev_run_bundle_full.json` mtime 2026-10-12 22:41:49 (Kev last ran then). The gate was clear by
507 MiB for the full 9m36s of the 11:10 window and nobody took it.

## Actions

NONE, and none owed:

- **No `@ocho` DM** — the diff contains no `planner_at` flip; his scoped-planner item closed in
  his own rows 2026-10-13 17:49:44 (reply 17:54:07).
- **No `@llama` ping** — the window is CLOSED at write (1598 free vs the 4289 gate), so the
  fallback premise is false at receipt, and there is arithmetically no window before ~12:50.
  His self-authorised poll is alive: `profiles/llama/cron/ticker_heartbeat` =
  `ticker_last_success` mtime 2026-10-15 11:36:23 (epoch 1792089383) — so the absence of an
  arcade lease is his choice, not a dead watcher.
- **No run action, no model load, no lease taken.** `gpu-lease.sh`, `llama-swap.yaml`, the
  planner lease, the driver and the model cache were NOT touched (read-only).
