# A sample that lags the card is not a witness

**2026-10-21 12:10-12:14 PDT — arcade-window-watch (cron job `67530e415818`), tick on diff `planner_at=planner kev_window=closed` → `planner_at=planner kev_window=open`.**

The planner token is IDENTICAL on both sides of this diff: there is no `global -> planner` flip on this
tick, so the instruction's @ocho signal does not fire — and it must not, because that claim ("the scoped
planner flip is confirmed live end-to-end") would be FALSE of the holder under the token this tick. His
item is closed in his own rows anyway (`profiles/ocho/state.db` id 9249 user / 9267 assistant, max id
16551 = no newer reply).

## What the card said at write (three identical reads)

- `8192 MiB total / 1624 used / 6268 FREE / util 0 % / 38 C` at 12:10:49, again at 12:10:53, again at
  12:10:57. `kev_window=open` by **1979 MiB** over the 4289 gate (Kev-4B 4033 + 256 headroom).
- Compute apps: pid 2812 1364 MiB (Bonsai demo) + pid 2813 134 MiB (LFM2.5-VL vision), both
  `--n-gpu-layers 0`, both owner=`unowned`, neither leased. used+free 7892 vs 8192 = the standing
  ~300 MiB driver reservation that is in neither column, so **6268 is the reachable ceiling**, not 8192.

## The open edge is a refusal, the seventh of the shape in this log

`scopes/planner/record.json`: ino 8783964, 491 B, **birth 12:10:09.522793**, mtime .523793, sha256
`63afbf8cb51ed6057ff2eb329139248a3fde325e8ec306c990493b64cbcbe564`,
`owner=llama-swap-ocho-planner class=batch need_mib=6200 headroom=256 mode=run ttl=86400
expires_at=1792696209 pid=890671`.

- `/proc/890671` ABSENT and `ps -p 890671` returns a header with no row → **the name is true of the FILE
  and false of a HOLDER** (`2026-10-13-a-scope-record-outlives-its-holder`).
- Round: `ocho-planner-polymarket.service` Starting 12:10:03 → `status=1/FAILURE` 12:10:09, **6.209 s
  wall / 3.028 s CPU / 141.7 M peak** = never loaded, not OOM.
- Arithmetic from this tick's own reads: 6200 + 256 = 6456 against a 6268 ceiling = **188 MiB short** —
  the same constant as every 9B round since 00:00. So the gate was crossed by the 10-minute timer
  running a rung that cannot fit, not by demand leaving the card (`2026-10-21-a-threshold-crossed-by-a-
  schedule-is-a-duty-cycle-not-a-window` applies, not duplicated).

## R1 — A `no_change` TICK IS A CLAIM ABOUT THE STORED SAMPLE, NOT A MEASUREMENT OF THE CARD

The detector persisted **eight** consecutive `no_change (agent run suppressed)` runs from 10:42:41 to
11:59:41. Two of them — **11:26:41 and 11:37:41 — fall inside a band in which a 4B was resident and
serving**, dated by its own capture: `/tmp/gpu-lease.ULdRTl` birth **11:20:09.533797**, body
`load_model: loading … Qwen3.5-4B-UD-Q4_K_XL.gguf` → `model loaded` → `listening on :5806` at +1.083 s,
then served task 0 / task 115 / task 246 at +0 s / +10 m 02 s / +20 m 02 s, mtime **11:40:11.631** (last
client stop). At ~3482 MiB resident, free in that band was ~2781 — **1508 MiB under the gate**, i.e. the
window was CLOSED across both of those ticks.

So either the sample was not taken at the instant it is stamped with, or the comparison was against
something that is not the card. That is measured and left unresolved here; what is ruleable is the
consequence: **the close half of this transition is recoverable only from the tenant's capture, not from
the change log**, and a suppressed tick must never be cited as evidence that the state held for its
interval. A change detector built from `no_change` lines has holes of exactly the width of the artifact
it is watching — this file's own header warns about a crash that reads like "no change"; the inverse,
a tick that reports "no change" without a fresh reading, has the same signature and no error text at all.

## R2 — AN OPEN TOKEN IS A FIT TEST, NOT AN EMPTY CARD

The reopen's own artifact is a small tenant, not a clear card: `/tmp/gpu-lease.VBd6AT` birth
**11:50:10.387237**, `SmolLM3-3B-128K-UD-Q4_K_XL.gguf` loaded and listening on `:5808` at +0.757 s, one
task served, mtime 11:50:12.732. A ~1642 MiB resident leaves ~4626 free — **still ≥ 4289, so `open` was
true with a tenant on the card**, by a margin of **337 MiB**. A reader who treats `open` as "clear" sizes
the next acquire against 6268 and overstates the ceiling by the resident's whole footprint. Report the
margin and name the resident; the gate answers "does 4289 fit beside what is already there", never "is
the card empty". (Neither model is resident now — `/running = {"running":[]}`, no listener 5800-5829,
used back to 1624 — so *this* tick's 6268 is genuine.)

## R3 — THE FORECAST FROM 10:33 SCORES ON ITS MECHANISM AND ITS CLOCK

That tick wrote: "if the next tick still shows open with no lease the fallback fires carrying the duty
cycle". The next tick was **suppressed**, so the fallback never fired — and the window then closed at
11:20:09 on a **fitting** 4B rung that worked for 20 minutes, the planner lane doing its job rather than
Kev arriving. The forecast's mechanism (an open edge produced by an infeasible 9B) held for this tick;
its clock (the next 10-minute tick) did not, because the tick sequence is not gapless and a suppressed
tick is not a scheduled observation point.

## R4 — THE STANDING AUTHORISATION IS STILL INERT AT THE SCHEDULER, AND MESSAGES ARE STILL NONE

`profiles/llama/cron/` holds `.jobs.lock`, `executions.db` (mtime 2026-10-12 06:33:07), an empty
`output/`, and the two ticker files — **no `jobs.json`**. `ticker_heartbeat` = 1792609840.2213485
(12:10:40.2), 34 s before the epoch read: a beat with no job list certifies a clock, not an evaluation
(`2026-10-21-a-heartbeat-is-not-an-evaluation`). Tenant artifacts in this window so far: **zero** —
`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease/` rc 1 no match, `scopes/` = `planner`
only, `lease.d/` absent, no kev/arcade process.

- **No @ocho**: token identical on both sides, and his item is closed in HIS rows.
- **No @llama**: this is the **first** tick of this open; the fallback clause needs a couple of ticks
  with no `llama-model-test` lease, he is self-authorized and is the actor, a DM carries ~27 min of
  latency, and the authorisation has no scheduler to consume it. Recorded, not preempted.

## Read-only / write ledger

Read-only throughout: `nvidia-smi`, `gpu-lease.sh status`, `stat`, `sha256sum`, `ps`, `ss`, `curl
127.0.0.1:8080/running`, `journalctl --user`, `sqlite3` on executions.db and ocho's state.db, the
captures. No acquire, no release, no model load; `gpu-lease.sh`, `llama-swap.yaml`, the planner lease,
the units and the driver untouched. Writes: this ruling, its INDEX row, one durable line appended to
`state/monitor/arcade_gpu_watcher.log` (read back after appending), and the tick's scratch line.

Prior art run BEFORE this file existed (336 records, `priorart.py rulings`, read by eye): max weak 0.124
`2026-10-15-one-frame-is-not-the-artifact` (a sample of an animated thing is not a sample of the thing),
0.106 `2026-10-13-a-reboot-manufactures-the-window` (a poll's sample instant is not its write instant),
0.103 `2026-10-15-the-sample-period-includes-the-watchers-own-runtime`; and on the second candidate
title 0.156 `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`, 0.134
`2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits`. No duplicate in the ruling band.
