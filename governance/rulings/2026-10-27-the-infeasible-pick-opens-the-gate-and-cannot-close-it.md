# The infeasible pick opens the gate and cannot close it

**Date:** 2026-10-27 · tick `arcade-window-watch`, job `67530e415818`, change at the `18:17:16` sample (reads 18:17:21 – 18:20:18 PDT)
**Diff:** `planner_at=planner` **IDENTICAL both sides** → no `global->planner` flip, **no `@ocho` DM** · **`kev_window=closed → open`**
**Chain:** `cron/output/67530e415818/2026-10-27_18-06-16.md` 155 B `Status: no_change (agent run suppressed)` (17:55 the same), i.e. the last sample still read `planner_at=planner kev_window=closed` → `monitor_last_output.txt` 34 B, mtime `18:17:16.325555599`, sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2` `planner_at=planner kev_window=open`. Bracket **`(18:06:16, 18:17:16]`**.
**Method:** every number below is a read taken this tick — `nvidia-smi` (three timed reads) + `--query-compute-apps`, `stat %w/%i`, `sha256sum`, `gpu-lease.sh status` (read-only), `ps`/`/proc`, `curl :8080/running`, `ss -ltnp`, `journalctl --user`, the ledger capture bodies, the `[O55] Weighted pick:` lines, `priorart.py`. Nothing recalled from a prior tick.

## 1. Live card at write — three reads, stable to the MiB

| read | total | used | free | util | temp |
|---|---|---|---|---|---|
| 18:20:14 | 8192 MiB | 1774 | **6118** | 4 % | 40 C |
| 18:20:16 | 8192 MiB | 1774 | **6118** | 9 % | 40 C |
| 18:20:18 | 8192 MiB | 1770 | **6122** | 9 % | 40 C |

Gate `4289` (`arcade_window_watch.sh:12,:47` = 4033 + 256) → **OPEN by 1829–1833 MiB**.
Compute apps: pid 2408 Bonsai-2-9B 1364 + pid 2409 LFM2.5-VL 134 = **1498, both `--n-gpu-layers 0`, both unleased**; `used + free = 7892` vs 8192 leaves ~300 MiB driver/ctx. **Empty behind the gate:** `:8080/running` → `{"running":[]}`, only listener on the swap ports is `llama-swap` pid 2405 on `:8080`, no 5800-5809 server, `scopes/` = `planner` only, `lease.d/` absent, `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease` → rc 1 no match.

## 2. The opener is the 9B pick's own swap-stop, and the same pick proves it cannot close

`ocho-planner-polymarket.timer` fires on the 10-minute phase; picks this hour from the unit's own stdout: **60099 = `ocho-planner-smol` (10 %)** at 18:00, **60100 = `ocho-planner` (60 %, the 6200 MiB 9B)** at 18:10, **60101 = `ocho-planner`** at 18:20.

- **18:00:20.619** capture `/tmp/gpu-lease.z3sjqG` (1642 B) `loading SmolLM3-3B-128K-UD-Q4_K_XL.gguf` → `model loaded` at +0.775 s = **18:00:21.394**; journal `18:00:14 Starting → 18:00:23 Finished` (exit 0, 3.678 s CPU / 8.791 s wall / 142.3 M). The smol is 2672 MiB, and it is what the `18:06` sample read as `closed`: `6118 - 2672 = 3446` free = **843 MiB under the gate**, arithmetic that closes to the MiB on the same card read seven minutes later.
- **18:10:08 Starting → 18:10:15 `Main process exited, code=exited, status=1/FAILURE`** (`Failed to start`, 3.637 s CPU / 6.880 s wall / 142.5 M). The planners group is `swap: true`, so a 9B request stops the resident member first; `llama-swap.log` (mtime `18:10:15.183`) ends on `Health check passed on :5806` / `:5808` then `starting ocho-planner failed: aborted` + `status=500`, and **no capture exists after 18:00** — the 9B round never reached a load. The 2672 MiB it took with it is the whole difference between `closed` at 18:06 and **6118 free** at write (`4446 - 2672 = 1774` used).
- **Admission on an EMPTY card: `6200 + 256 = 6456` vs 6118 free = 338 MiB SHORT.** The 9B cannot fit in any state this card can reach (the 4B asks 4056 = 2062 spare, the smol 3256 = 2862). So on a 60 %-weighted pick the only possible effects are (a) subtract a serving rung and (b) leave the gate open — the open edge is a function of the rotation, not of the card.
- **18:20:04 Starting → 18:20:11 FAILURE** (3.670 s CPU / 7.118 s wall / 142.7 M) repeated the same 9B pick and the gate stood open across it (`1770/6122` at 18:20:18).

## 3. Rulings

**R1 A REFUSAL DOES NOT CLOSE THE GATE IT OPENED; ONLY THE NEXT FITTING DRAW DOES.** The `18:20` round tested `6456` against free VRAM a refusal leaves untouched and changed nothing but the record. This refines the 12:39 row's "closed until the next pick" to **"closed until the next FITTING pick"**, and since the rotation's weights are fixed (9B 60 % / 4B 30 % / smol 10 %) it makes the width of every window opened this way **the distance to the next 4B or smol pick** — a rotation quantity, forecastable in advance, not a card quantity.
**R2 THE EVICTION IS PRICED TO THE MiB BY THE SAMPLE ON THE OTHER SIDE.** `6118` (open, empty) `+ 2672` (the smol the round stopped) `= 8790`; the `18:06` `closed` sample's residual free is `6118 - 2672 = 3446`, i.e. **843 under the gate**, and that number is reproduced from the open reading alone. An open edge that follows a closed sample by one 10-minute interval is therefore attributable without any per-round instrumentation: subtract the standing tenants (1498 + ~300 driver here) from free and what is left is the rung the last round spent.
**R3 `planner_at=planner` BESIDE A CLEAR CARD IS A FILE THAT CHURNS EVERY ROUND.** The single cell ino `8782668` was rewritten at **`18:10:14.887`** (`owner=llama-swap-ocho-planner`, `need_mib=6200`, `headroom_mib=256`, `mode=run`, `pid=309308`) and again at **`18:20:11.107`** (491 B, sha256 `e451d172e7a533b5d9a05e45b10dca8e9b3bd5574ec5f1e4b8106970fdb0970d`, `pid=316879`). **Both holders are DEAD** (`/proc` absent, no `ps` row, never in `--query-compute-apps`), both born inside their round's exit second. The token is existence-derived (`arcade_window_watch.sh:29-35`), so a chronic 10-minute refusal reads as continuous scoped occupancy while the card holds nothing under the lease — one record per round, each 491 B, none naming a live loader.

**Class, cited not re-argued:** `2026-10-23-a-refused-pick-evicts-a-tenant-that-could-not-have-remedied-its-refusal` (the mechanism), `2026-10-27-the-swap-that-spends-a-live-holder-on-a-pick-that-cannot-fit` (same day, same 338 MiB shortfall), `2026-10-13-a-scope-record-outlives-its-holder` (R3), `2026-10-27-the-window-reopens-under-a-record-born-dying-and-the-log-is-the-recurrence` (R3's shape). The increment filed here is R1's substitution of "next fitting pick" for "next pick", plus R2's subtraction rule that lets an open edge be attributed from the two samples alone.

## 4. Action

**RECORD ONLY.** No acquire, release, load, reservation, unit or config touched; `gpu-lease.sh` read-only, `llama-swap.yaml`, `scopes/planner/`, the planner unit, both aux tenants and the driver untouched — the 18:00 load and the 18:10 / 18:20 refusals were the timer's own requests through llama-swap.

**MESSAGES: NONE, both premises measured.** No `@ocho` — the token never moved this diff, and his scoped-planner item is closed in his own rows (`profiles/ocho/state.db` 9249 / 9267 / 16736, `max(id)=17405`), so a DM would reopen a drop-hazard with a record that names a dead pid. No `@llama` — this is the **first sample of the window** (edge ~18:10:15, seven minutes old), the fallback clause is for a window that survives several ticks untaken, and he self-authorises at `--scope arcade`; this watcher does not preempt his poll.

**STANDING FLAG FOR MIKE, re-measured `18:19`:** `profiles/llama/cron/` has **NO `jobs.json`** (only `.jobs.lock`, `.tick.lock`, `executions.db` 24576 B frozen `2026-10-12 06:33:07`, `output/` untouched since 10-12) while `ticker_heartbeat` is rewritten every tick — a live clock over an empty job set. Seven open edges were logged through the 17:44 row and this is another; nothing is executing the standing authorisation. This watcher creates no jobs.

**ON DISK BESIDE THIS, NOT THIS WATCHER'S TO FIX:** `ocho-planner-polymarket.service` refused on both `18:10` and `18:20` after `Finished` at `17:50` and `18:00`; its stderr carries a Python-level `AttributeError: 'Manager' object has no attribute 'loggerDict'` (python3.14 / urllib3 import path) from an earlier run, not from today's — untouched, recorded.
