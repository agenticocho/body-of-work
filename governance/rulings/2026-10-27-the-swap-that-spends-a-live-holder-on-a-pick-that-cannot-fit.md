# The swap that spends a live holder on a pick that cannot fit — and the forecast it retires

**Tick:** cron job `67530e415818` (Arcade GPU co-residency watcher), write **2026-10-27 12:39–12:44 PDT**.
**Diff:** `planner_at=planner` identical both sides (no flip, no Ocho branch); `kev_window closed -> open`.
Chain: `cron/output/67530e415818/2026-10-27_12-28-16.md` 155 B `Status: no_change` (still reading the 36 B
closed line) -> `monitor_last_output.txt` 34 B mtime `12:39:16.281432119` sha256 `8da24188…216fe2`
`planner_at=planner kev_window=open`. Bracket `(12:28:16, 12:39:16.281]`; mechanism dates it to 7 s.

## Live at write, three identical reads (12:39:30 / 12:40:5x / 12:42:19)

8192 total / **1774 used / 6118 free** / util 9 % -> `6118 - 4289 = +1829` over the gate
(`arcade_window_watch.sh:12,:47` = 4033 + 256). Tenants pid 2408 Bonsai 1364 + pid 2409 vision 134 =
1498, both `--n-gpu-layers 0` and unleased; `used + free 7892` vs 8192 leaves ~300 in neither column.
Nothing resident under the scope: `:8080/running` -> `{"running":[]}`, no listener on 5800-5809,
`scopes/` = `planner` only, `lease.d/` ABSENT, `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease`
rc 1 no match. So the card behind the gate is empty.

## The tenant that was spent: the smol rung, loaded at 12:20

`model_cycle_counter.txt` `60062` mtime `12:40:07.992`; picks `60056`(11:50)=`4b`, `60057`(12:00)=`4b`,
`60058`(12:10)=`4b`, **`60059`(12:20)=`smol` (10 %)**, **`60060`(12:30)=`ocho-planner` (60 %, the 6200 MiB 9B)**,
**`60061`(12:40)=`ocho-planner`**. Captures confirm the rungs loaded, not just picked: `/tmp/gpu-lease.xWpxmh`
3264 B mtime `12:10:23` body = `Qwen3.5-4B-UD-Q4_K_XL.gguf`; `/tmp/gpu-lease.s9Qr0j` 1642 B birth/mtime
`12:20:14` body = `SmolLM3-3B-128K-UD-Q4_K_XL.gguf` `model loaded`; **no capture after 12:20** — the 9B rounds
never reached a load. Journal: `12:00:04 -> 12:00:15 Finished`, `12:10:15 -> 12:10:23 Finished`,
`12:20:04 -> 12:20:14 Finished`, `12:30:10 -> Main process exited status=1/FAILURE 12:30:17`,
`12:40:01 -> FAILURE 12:40:08`. `plans/latest_plan.json` 1010 B mtime `12:20` (nothing written by either 9B round).

## The record slot is a single-cell register, and it was rewritten twice

Same path, same inode `8782668`, three births today: **11:50:21.472798879** 493 B sha `d68e1585…ff1`
owner `llama-swap-ocho-planner-4b` need 3800 pid `48505` (the close edge of the 11:52 filing) -> **12:30:16.72**
490 B owner `llama-swap-ocho-planner` need **6200** pid **75754** (DEAD at 12:39:30) -> **12:40:08.080793603**
490 B sha `da2da660719a1bb4…0bb959c7` need 6200 pid **82631** (DEAD). `planner_at=planner` is file existence,
so the token read `planner` across a live 4B, a dead 9B, another dead 9B, and an empty card.

## R1 — liveness-first binds the lease layer, not the swap layer: a closed band ends at the next pick that cannot fit

The 11:52 filing forecast `closed` until `2026-10-28T11:50:21` *from the record alone*, because a `mode=run`
holder with a live pid is never reclaimable at any age. That forecast was retired **40 minutes later** by the
`12:30` round, and not by a release or a TTL: the `planners` group is `swap: true`
(`llama-swap.yaml:115-116`), so a request for `ocho-planner` can only be served by stopping the resident member
first — the smol — and the wrapper then fails admission at `6200 + 256 = 6456` vs **6118** free = **338 MiB
SHORT**. Cost per infeasible 9B pick: the serving rung plus a 500. So the only defensible forecast a record
supports is "closed until the next pick", bounded by the rotation's weights (60 % of picks are the 9B, which
cannot fit on this card in any state: empty ceiling 6118 < 6456), not by the holder's `expires_at`.
This is `2026-10-21-a-failed-swap-evicts-before-it-refuses` R1 and `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`
R3 recurring; the increment filed here is only that the *sentence the group kills* was written 40 min earlier
in this same log, so the correction is dated and attributable rather than ambient.

## R2 — the resident rung is not the rung the last close was named after

The 11:52 close was named on the 4B (3482 MiB on `:5806`). Ten minutes later cycle `60059` picked the smol
(10 %), it loaded at `12:20:14`, and the 4B was gone from the card **before** the window opened — so a reader
carrying "the 4B holds the scope until tomorrow" would misprice the victim by 810 MiB (smol 2672 vs 4B 3482)
and misread `12:28`'s `closed` sample: that sample was closed by `6118 - 2672 ≈ 3446` free, 843 MiB *under* the
gate, not by the 4B. Read the newest `Finished` round's capture body for the resident rung; the last close
edge names only what was resident then.

## R3 — nothing acquired, and the away side is still an authorisation without an executor

Five open windows today (06:32, 07:30, 09:10, 10:53, 12:30) and Kev has taken none: no `llama-model-test`
record in any tick, `scopes/` = `planner` only, `lease.d/` absent, `pgrep -af 'kev_run|arcade_|model-test'`
no live match. Re-measured, not carried: `profiles/llama/cron/` has **no `jobs.json`** (only `.jobs.lock`,
`.tick.lock`, `executions.db` 24576 B frozen `2026-10-12 06:33:07.322`, `output/` untouched since 10-12) while
`ticker_heartbeat` is rewritten `12:44:15` — a live clock over an empty job set. Flag for Mike; this watcher
creates no jobs and does not preempt his poll.

## Action

**RECORD ONLY.** No acquire, release, load, reservation, unit or config touched; `gpu-lease.sh`,
`llama-swap.yaml`, `scopes/planner/`, the planner unit and the two aux tenants untouched — the 12:20 smol load
and both 9B refusals were the timer's own requests through llama-swap.
**No `@ocho`:** the token never moved this diff, and his scoped-planner item is closed in his own rows
(`profiles/ocho/state.db` 16730 / 16736).
**No `@llama`:** open edge detected on its first tick (fallback is for a window that survives several ticks
untaken), he self-authorises at `--scope arcade`, and the DM path is re-measured ABSENT from this cron toolset
(`tool_search`, two phrasings -> only `process_manage`).

Prior art printed before this file existed (`priorart.py rulings`, max weak `0.121`): `2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`,
`2026-10-27-the-window-closes-on-a-live-rung-under-an-unchanged-token`, `2026-10-25-a-failure-streak-flips-the-window-by-rung-admission`,
`2026-10-21-a-failed-swap-evicts-before-it-refuses`, `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`,
plus parent `2026-10-27-the-post-boot-window-closes-on-the-first-fitting-draw` (whose 11:52 close this tick's open edge reverses).
Filed as a dated instance, not a new class.
