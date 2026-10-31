# A threshold crossed by a schedule is a duty cycle, not a window

**Tick:** job `67530e415818` (arcade-window-watch), sample `2026-10-21T10:28:41` / write `10:33` PDT,
diff `planner_at=planner kev_window=closed` → `planner_at=planner kev_window=open`.
**The token:** `planner_at` is **identical on both sides** — no global→planner flip, no `@ocho` DM
(his item re-read this tick: `profiles/ocho/state.db` ids **9249** user / **9267** assistant, max id
**16551** = no newer reply). Only the Kev window moved, and it moved by OPENING.
**Built on, not re-filed:** `2026-10-14-a-window-opened-by-a-failed-load` (the open edge's mechanism),
`2026-10-21-a-rung-that-cannot-fit-is-a-scheduled-self-eviction` (why the same round fails every ten
minutes), `2026-10-21-a-heartbeat-is-not-an-evaluation` (the tenant that never consumes — **priced
here**), `2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits`,
`2026-10-13-a-scope-record-outlives-its-holder` (the dead-pid token this tick).

## What was measured

- **The open edge is a refusal that left a record.** `scopes/planner/record.json`: **491 B**, ino
  **8783964**, birth `10:20:09.881724`, mtime `10:20:09.883724`, sha256
  `8538d02855aa51b71218ba7c656758ece5ea814e721e7c4e668cf7be9fc5d7cb`,
  `owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 headroom_mib=256
  pid=839640 mode=run ttl=86400`. **pid 839640 is absent from `/proc`.** No `/tmp/gpu-lease.*`
  capture exists after `03:50:12.107` — the load was never issued.
- **The round:** `ocho-planner-polymarket.service` `Starting 10:20:03` → `10:20:10`
  `Main process exited, code=exited, status=1/FAILURE`, **6.565 s wall / 3.221 s CPU / 141.4 M peak**
  = the never-loaded signature, **not OOM**. `6200 + 256 = 6456` against a **6268** reachable
  ceiling = **188 MiB short**, the same constant as every 9B round since `00:00`.
- **The card at write, three identical reads 2 s apart:** 8192 MiB total, used **1624**, **free
  6268**, util 0 %, **39 C** ⇒ **1979 MiB over the 4289 gate**. Compute apps: `2812` 1364 MiB
  (Bonsai demo) + `2813` 134 MiB (LFM2.5-VL) = **1498**, both `--n-gpu-layers 0`, **both unleased**;
  used + free = 7892 vs 8192, the ~300 MiB driver reservation in neither column. **6268 is the
  reachable ceiling.**
- **There is no holder under the token.** `/running` = `{"running":[]}`, no listener in 5800–5829.
  So `planner_at=planner` is **true of the file and false of a holder**, and there is nothing to
  co-reside with: any tenant of ≤ 6268 fits without an eviction.
- **Instrument note (measured, not assumed):** this record is ino **8783964**, *not* the ino
  **8784161** that the `00:50`, `01:10`, `01:40` and `03:20` records all carried, and birth == mtime
  to **2 ms** ⇒ the file is now **created fresh and renamed into place** rather than overwritten in
  place. Four earlier rulings of mine cited "same inode" as evidence of an in-place rewrite; that was
  true of *those* writes and is **not a rule about the writer** — an inode-equality check carried
  forward would report a replaced record as an mtime-only update. Birth time survives as the acquire
  stamp (here 2 ms from the write, 91 ms at `03:20`); inode identity does not survive as anything.

## The aggregate, from the durable log's own edges

`state/monitor/arcade_gpu_watcher.log`, today's 14 lines, transitions only:

| open edge | close edge | width |
|---|---|---|
| 01:19 | 01:42 | 1 380 s (23.0 min) |
| 02:31 | 05:07 | 9 360 s (156.0 min) |
| 05:47 | 06:49 | 3 720 s (62.0 min) |
| 07:11 | 08:11 | 3 600 s (60.0 min) |
| 08:46 | 09:42 | 3 360 s (56.0 min) |

**21 420 s = 357.0 min** of closed open-window time, plus the window open since `10:20:10`
(≈ 12.8 min at write) against a **573 min** observed span `01:00 → 10:33` = **62 % of the day
without the current window, ≈ 65 % with it**. Tenant artifacts over all of it: **zero** —
`grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` **rc 1, no match**,
`scopes/` = `planner` only, `lease.d/` absent, no `kev`/`arcade` process.

## R1 — When the trigger is a timer whose rung cannot fit, report the duty cycle, not the edge

Every one of today's open edges is a planner round that **failed to load**; the round is a 10-minute
timer and the 9B rung is 188 MiB over the ceiling, so **the gate is crossed by the clock, not by
demand**. A watcher that reports edges (six events in one day) tells its reader to see each opening
as scarce luck, while the measured object is a **rate**: the card offers Kev roughly **two thirds of
the day**. The edge is the right unit for *reacting* and the wrong unit for *deciding* — the
decision input is the width sum. Concretely: what would turn this duty cycle back into an event is
**not** another sample, it is a change in the **ceiling** or in the **pool** (a 4289+ tenant exits,
the 9B leaves `planners`, the two unleased CPU-offload servers are freed). Until one of those moves,
"a Kev window opened" is a **scheduled** statement and should be reported as a duty cycle with its
measurement, not as an event with a timestamp.

## R2 — An edge log is made of samples, so its total is a floor, and it must be said so

Each width is bracketed by the tick that observed it, and the ticks are not gapless: no line exists
between `02:31` and `04:09` (98 min), so a close/open pair inside that gap would be **invisible** to
this instrument — the widths come from my own tick lines in the durable log, not from the detector,
and a tick that never ran leaves no width (`2026-10-21-a-run-that-records-in-scratch-has-not-recorded`
R2, one level up). Hence **357.0 min and 62 % are lower bounds**: the claim travels as
**"at least"**, and a rate computed from edge samples may never be stated to a decimal it was not
measured to. This is the day's own correction of the `01:47` tick, which counted "≥ 5 399.05 s
across two windows" — a floor was read as a total because the sentence had room for it.

## R3 — The price of a standing authorisation is the scheduler that implements it, and it is one directory listing away

The operator authorised Kev to self-acquire at free ≥ 4289 as a **standing** precedence clause.
One day of that authorisation bought **0 acquires against ≥ 369.8 min of qualifying gate**. The
reason is not willingness: `profiles/llama/cron/` **has no `jobs.json`** — `.jobs.lock`,
`executions.db` 24 576 B mtime `2026-10-12 06:33:07`, an empty `output/` — while
`ticker_heartbeat` = `1792603720.213` at `10:28:40`, **7 s before the epoch read**. The beat
certifies **a clock, not an evaluation** (`2026-10-21-a-heartbeat-is-not-an-evaluation`), and this
tick supplies the price of that distinction instead of the restatement: the authorisation is **inert
by construction**, and the audit that shows it is a single `ls` of the tenant's cron directory. A
standing authorisation must be verified at the scheduler that would carry it out, not at the
authority that granted it.

## R4 — Boundaries, so the rule is not over-read

- NOT RULED: that every threshold is a duty cycle — only one whose crossing is produced by a timer
  running a rung that cannot fit at the reachable ceiling.
- UNMEASURED: whether any of those 21 420 s would have produced a **successful** Kev run (none was
  attempted, so there is no evidence either way); and whether Llama has a scheduler outside
  `profiles/llama/cron/` — only that tree was listed, so "no evaluation" is asserted **of that
  tree**.
- The `01:19`/`02:31` widths predate this ruling and are cited from my own earlier tick lines,
  un-remeasured.

## Actions this tick

**MESSAGES: NONE.** No `@ocho` (token identical; his item closed in his own rows). No `@llama`: the
fallback clause requires the absence of an `llama-model-test` lease across **a couple of ticks**, and
this is the **first** tick of this open window; a DM also carries ~27 min of latency, which would put
any reading I send after at least two further 10-minute rounds — a false statement with a timestamp
if the window closes first (`2026-10-21-a-heartbeat-is-not-an-evaluation` R3's reasoning, applied).
If the next tick still shows `kev_window=open` with no tenant lease, the fallback fires and the
message carries the duty cycle and the current free, not just the edge.

**READ-ONLY:** no acquire, no release, no model load, no unit, `gpu-lease.sh` / `llama-swap.yaml` /
the planner lease / the driver untouched. Writes are this ruling, its `INDEX.md` row, one durable
line in `state/monitor/arcade_gpu_watcher.log` (read back after appending), and the tick's scratch
line.

**Prior art** run BEFORE this file existed (335 records, `priorart.py`, read by eye): top for this
title `2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits` 0.118 and
`2026-10-21-a-rung-that-cannot-fit-is-a-scheduled-self-eviction` 0.115 — both named in R1 as the
mechanism, neither states the rate; `2026-10-14-a-window-opened-by-a-failed-load` 0.208 on the
edge's mechanism, applied and not re-filed; `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`
(width of one window, not the day's sum). No duplicate in the ruling band.
