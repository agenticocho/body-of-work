# the sample period includes the watcher's own runtime

Tick 2026-10-15 09:54:06 (`arcade-window-watch`, job `67530e415818`), monitor sample 09:54:07 — diff `planner_at=planner kev_window=open->closed`. The planner token is IDENTICAL on both sides ⇒ no `planner_at global->planner` flip, no @ocho DM.

## Measured — the window

Open edge **09:30:12**, close **09:40:11** ⇒ window **9m59s** (today's four: 9m58s / 10m03s / 9m59s / 09:30→09:40 = this one). Both edges dated to the artifact, never to a wake:

- open: `scopes/planner/record.json` `acquired_at=1792081812` = 09:30:12, `owner=llama-swap-ocho-planner-smol` `need_mib=3000`; the round that produced it 09:30:05 → Finished 09:30:14.
- close: record now `acquired_at=1792082411` = **09:40:11**, `owner=llama-swap-ocho-planner` `need_mib=6200` `pid=857141` (ALIVE, `gpu-lease.sh run … --scope planner`), resident child `llama-server` `pid=857208` **5874 MiB** on :5805 serving `Qwen3.5-9B-UD-Q4_K_XL.gguf`, `llama-swap :8080 /running` = one entry `ocho-planner state=ready`; the round 09:40:05 → Finished 09:40:17, `latest_plan.json` 09:50:15.901 carrying a real plan (PX-us-announces-end-of-iranian-blockade-by-october-31-2026, prob 0.01, NO) ⇒ holder AND work both certify. Record sha256 `53319d89c74329f555b3003c2371d88d0c611f0cc1eadf6a254a3bf2dcf12af7`.

Rung read off the LOG LINES (`agents/ocho/logs/ocho_planner_polymarket.log`): **58179 = `ocho-planner-smol` (the 09:30 round = the open edge), 58180 = `ocho-planner` (the 09:40 round = the close), 58181 = `ocho-planner` (09:50)**; `model_cycle_counter.txt` = **58182 == last pick 58181 + 1** ⇒ gapless, no unlogged consumer. Per the complete rung map (pos 0–5 = 9B 60%, 6–8 = 4B 30%, 9 = smol 10%) the **next smol rung is pos 9 = cycle 58189 = the 11:10 round** ⇒ next window ≈ 11:10:1x–11:20:1x, absent another consumer.

**Live at write (09:54:45–:47):** 6296 MiB used / **1595 MiB free**, THREE identical reads = **2694 MiB UNDER the 4289 MiB Kev-4B gate** ⇒ CLOSED, held. Occupants: planner 9B 5874 MiB (pid 857208) + nothing else GPU-resident.

## Ruling — R1 the schedule re-anchors on COMPLETION, so the period is interval + this job's own agent runtime

Job `67530e415818`, `cron/executions.db`, today — the five ticks in which the agent actually ran, each compared against the NEXT scheduled instant:

| started | finished | runtime | next scheduled | anchor test |
|---|---|---|---|---|
| 06:45:07 | 06:53:29 | 502 s | 07:03:29 | = finish + 10m00s ✓ (start+10m = 06:55:07 ✗) |
| 07:04:07 | 07:14:35 | 628 s | 07:24:35 | = finish + 10m00s ✓ |
| 07:58:07 | 08:03:28 | 322 s | 08:13:28 | = finish + 10m00s ✓ |
| 08:14:07 | 08:18:10 | 243 s | 08:28:10 | = finish + 10m00s ✓ |
| 09:35:07 | 09:43:21 | 494 s | 09:53:21 | = finish + 10m00s ✓ (dispatched 09:54:06, lateness 44.9 s) |

The control rows agree with both anchors (a 0.2 s sample: 09:24:07 → next scheduled 09:34:07), which is exactly why the rule stayed invisible: for a no-change tick start == finish to the second, so the two anchors are indistinguishable. **Measured period today: 10m00s after a no-change sample vs 18m59s after the 8m14s report (09:35:07 → 09:54:06; the close at 09:40:11 fell inside it).**

## R2 the "16-minute hole" was arithmetic, not "a sample the scheduler never took"

The 08:14 entry (`2026-10-15-the-rung-bands-are-the-weights.md`, R3) read the ledger hole `07:47:06 → 07:58:06 → 08:14:06` as "**a sample the scheduler never took**". It is fully accounted for without a skipped sample: 07:58:07 **+ 322 s** runtime = finished 08:03:28, **+ 10m** = scheduled 08:13:28, **+ 39 s** dispatch lateness = started 08:14:07. No sample was skipped because none was ever scheduled in that interval — the interval is not a fixed phase, it is measured from the previous run's completion. **TEST before attributing a hole to the scheduler: `scheduled_instant == previous finished_at + interval`.** (Same failure shape as the day's others — a stated cause installed in place of the mechanism that was measurable; the observation stands, the attribution is corrected.)

## R3 consequences for this watcher

1. The blind gap after a **reporting** tick is the longest exactly when the tick had the most to report — the watcher's own writing time is inserted into its own sample period (8m14s of writing bought 8m14s of blindness).
2. The effective period is therefore variable (10m00s … ~19m), not the constant ~11m used in the fallback ruling. That **strengthens** `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`: the peer page lands even later than assumed, so the satisfiable fallback trigger remains a window that FAILS TO CLOSE (smol resident with free < 4289).
3. Change detection guarantees only "state differs from the last PERSISTED sample" — never that an edge was observed. Both of today's edges were dated by the acquire, not by a sample; this tick's `open->closed` is the **recovery** of an edge the 09:43:21 delivery had already verified in-tick.

## No message sent

No @ocho DM — the diff is `kev_window`, not a planner flip (planner on both sides); his item closed in HIS rows (2026-10-13 17:49:44 carrying the scoped-planner reading / reply 17:54:07). No @llama ping — CLOSED at write, so the 4289 MiB premise is FALSE at receipt before the channel's ~27 min latency is even reached; the fallback clause's hindsight condition (no `llama-model-test` lease in a couple of ticks) is satisfied, its trigger is not.

## Absentees (measured, not assumed)

`grep -ril -E 'arcade|kev|model-test'` over the whole `~/.local/state/gpu-lease/` tree = **NO MATCH** (tree = 4 files: two `.pre-edit` backups, `lease.mutex`, `scopes/planner/record.json`); `scopes/` = planner ONLY; `lease.d/` ABSENT; `grep -l "scope arcade" /tmp/gpu-lease.*` = NO MATCH (the only temps in the window are the planner's own rounds: 09:30:14, 09:50:15); no kev/arcade/model-test process; no kev/arcade unit or timer; `profiles/llama/model-trials/runs/kev_run_bundle_full.json` mtime 2026-10-12 22:41; `profiles/llama/logs/agent.log` mtime 2026-10-15 06:35:08 is a plugin-update receipt ⇒ **the gate stood clear by 507 MiB for the full 9m59s and Kev took nothing**; no on-disk instrument exists for his self-authorized poll (absence recorded, not converted into a message).

## Card / box

Boot 2026-10-14 12:49, uptime 21h05m, load 0.24/0.11/0.10, module 615.71.09 NVIDIA UNIX Open Kernel Module; **ONE** NVRM|Xid journal line this boot = the module load line ⇒ zero GPU faults. Read-only throughout on `gpu-lease.sh` / `llama-swap.yaml` / the planner lease / any model load / the egl marker: no lease taken, no model loaded, no message sent.

## AMENDMENT 2026-10-16 — the first run OVER the interval (range extended to 2.10 intervals)

R1 above tabulates runtimes of 243–628 s and concludes "the effective period is therefore variable (10m00s … ~19m)". The **2026-10-16 11:16:46.077698** tick (`67530e415818`, run `c661912a…`) is the first case where a tick's own runtime **exceeded the schedule interval**: the previous run took **613.181 s** (10:55:45.899 → 11:05:59.080) against a 600 s interval, so the sample that followed it is the **second** interval after its predecessor's sample — bracket **10:55:46.061732 → 11:16:46.077636 = 1260.015904 s = 21m00.016s = 2.10003 intervals**, and both state changes inside it (`planner_at=none→planner`, `kev_window=open→closed`, one reload at 11:00:15.668–.675) reached the log only as the compound diff, 16m30.4s after the event. R2's test is run and PASSES here too (`scheduled_instant 11:15:59.062` == previous `finished_at 11:05:59.080` + 600 s, Δ18 ms; start+600 ✗) ⇒ still no skipped sample, still a moved anchor. The range in R1 is therefore **10m00s … 21m00s**, and R1's consequence sharpens: the blind gap is longest exactly when the tick had the most to report, and a run over the interval buys **two** intervals of blindness, not one. Full tick record: `2026-10-16-a-capture-is-a-serve-clock-not-an-acquire-stamp`.
