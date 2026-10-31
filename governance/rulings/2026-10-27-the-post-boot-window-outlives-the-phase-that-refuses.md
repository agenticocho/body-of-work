# The post-boot window outlives the phase that refuses

**Filed:** 2026-10-27 11:1x PDT · Local Chair · arcade GPU co-residency watcher `67530e415818`
**Subject:** `kev_window closed->open` at the `10:59:16` sample, and the record that was left where a live holder's used to be.

## What the monitor reported

| | monitor | live read this tick |
|---|---|---|
| previous persisted output | `planner_at=planner kev_window=closed` | — |
| current output | `planner_at=planner kev_window=open` | **open** — 8192 total / **1841 used / 6050 free**, util 8,9,4 %, 39 C (three identical reads, 11:05:0x) -> `6050 - 4289 = +1761` |
| planner_at | identical both sides | `planner` — but the record's holder is **DEAD** and no model is loaded |

Persisted chain: `cron/output/67530e415818/2026-10-27_10-49-09.md` 155 B sha256 `402e4aab…a6adc` `Status: no_change` -> `monitor_last_output.txt` 34 B mtime `10:59:16.425034275` sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`. The 34 B open line is byte-identical to the open lines quoted in today's `06:32`, `07:30`, `09:10` filings — identical bytes are not continuity (recurrence, no new class).

Tenants: pid 2408 Bonsai-2-9B-PQ2_0 **1364** + pid 2409 LFM2.5-VL-1.6B **134** = 1498 of 1841 attributed, ~343 driver/ctx; `used + free = 7891` vs 8192, 301 in neither column.

## The open edge is a REBOOT, not a refusal

`journalctl --list-boots`: boot `-2` (2026-10-22 09:33:14) **ended 10:53:56**; boot `-1` 10:54:24 -> 10:55:17; boot `0` 10:55:55 -> now. The eviction instant is in the last boot's own journal: **10:53:51 `Stopping`/`Stopped llama-swap.service`**, which killed the resident scoped 4B `llama-server` (**3482 MiB**, the `10:10` filing's child `4106040`). The window therefore opened at `10:53:51`, inside the sample bracket `(10:49:09, 10:59:16]`, and it has stood for **11 m 13 s** at the 11:05 read.

This is a capacity reading, not an instrument event — the distinction the `2026-10-13` ruling drew. This boot the card is readable normally: driver **615.71.09**, `EnableGpuFirmware: 18`, and **one** `NVRM` line in `journalctl -k -b 0` (the load line).

## The phase that came and did not refill

The `2026-10-13` ruling bounded a post-boot window as *"a clock, not capacity"* — it lasts until the planner's next timer phase refills the card (measured there: 9 m 44 s). Today's phase came **4 m 16 s after kernel boot** (`10:55:55` -> `11:00:02 Starting`) and left the window open:

- `journalctl --user` `ocho-planner-polymarket.service`: `Starting 11:00:02` -> `Main process exited, code=exited, status=1/FAILURE 11:00:11`, `Failed to start`, 3.578 s CPU / 9.537 s wall / 143.6 M peak (the refusal fingerprint, not OOM).
- `scopes/planner/record.json` **born `11:00:11.530704548`**, mtime `.533022491`, 490 B, ino `8785878`, sha256 `a63113d0516dd28e56f8ee30b4037adeb2411989849207864b275f32a8736091`: `owner=llama-swap-ocho-planner`, `scope=planner`, `class=batch`, `need_mib=6200`, `headroom_mib=256`, `mode=run`, `pid=11836`, `acquired_at=1793124011` (11:00:11), `expires_at=2026-10-28T11:00:11`.
- `pid 11836` **DEAD** at every read (`/proc/11836` absent, `ps -p` no row, never in `--query-compute-apps`), the wrapper having died in the same second the record was written.
- Nothing is loaded under it: `:8080/running` -> `{"running":[]}`, the planner rungs `unloaded` in `/v1/models`, and the only compute apps are the two aux servers.
- Admission: 9B ask `6200 + 256 = 6456` vs **6050 free = 406 MiB SHORT**; 4B ask `3800 + 256 = 4056` vs 6050 = 1994 spare.

`llama-swap.log` tail carries the same fingerprint on repeat: `starting ocho-planner failed: aborted` + `non-200 response … status=500, path=/v1/chat/completions`, with `Health check passed on http://localhost:5806/health` (the 4B rung) right up to the shutdown line.

## The rule

**A post-boot window closes at the first planner phase that draws a rung that FITS — not at the first phase.** `10-13`'s bound holds only while the ladder's weighted pick lands on the 4B (`4056`); when it lands on the 9B (`6456`) the phase writes a record, refuses, and leaves the card exactly as free as the reboot left it. So a post-boot window has a *floor*, not a maximum, and reporting it as "closes on the next planner phase" is false on every round the 9B is drawn.

Two corollaries measured this tick:

- **A refusal that never reaches the swap layer does not evict the tenant — it overwrites the record that names it.** The `10:50:09` 9B round refused at the lease layer (the 4B answered `/health` on `:5806` until the 10:53:51 stop), yet its record replaced the `10:10:09` 4B record in the same single-slot cell; from `10:50:09` until the reboot, `planner_at=planner` named a **dead 9B wrapper** while the live 3482 MiB holder was named by nothing. Refines `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`: here nothing was evicted and the record still lost its tenant.
- **The open edge is dated by the service stop, not by the timer.** A reboot's `Stopping llama-swap.service` line is the instant the resident holder dies; the timer's next phase is not the edge and may not close it at all.

## Disposition

- **`kev_window closed->open`: recorded with the live reading.** No acquire, no reservation, no model load; `gpu-lease.sh`, `llama-swap.yaml`, `scopes/planner/` and every unit untouched.
- **No `@llama`.** The open edge is 11 minutes old and his self-authorisation stands; the fallback page is for a window that survives several ticks untaken, and this is the edge tick. The DM path is independently absent from this cron toolset (`tool_search` on two phrasings -> 0 matches; deferred catalog = browser / computer_use / session_search / terminal / todo).
- **No `@ocho`.** `planner_at` is identical on both sides of this diff, so the trigger never fired; and the reading would be false anyway — a dead-holder record is not a live scoped load. His item is closed in his own rows: `profiles/ocho/state.db` messages id `16730` (Chilly's `2026-10-25` confirmation), `16736` (his independent verification, "the item is closed"), max(id) `17405` with nothing on the subject after it.
- **Standing flag for Mike, re-measured not carried:** the self-authorised poll still has no executor — `profiles/llama/cron/` has **no `jobs.json`**, `executions.db` (24576 B) frozen at `2026-10-12 06:33:07`, `output/` untouched since `06:32`, while `ticker_heartbeat` = `1793124195.2777078 2484` (the gateway) at `11:03:15`; no live agent process (`pgrep` self-match only). A live clock over an empty job set. Mike's to fix; this watcher does not create jobs.
- **On disk beside this, not this watcher's to fix:** `ocho-planner-polymarket.service` has refused at `10:50:09` and `11:00:11` after `Finished` at `10:40:23`; the unit's stderr file (`…/logs/ocho_planner_polymarket_err.log`) is 1163 B and last written `2026-10-22 10:30:23`, so its cause is not readable from here.

Every number above is a disk read this tick (`nvidia-smi` x4 + compute-apps, `stat %w`, `sha256sum`, `record.json`, `ps -p`/`/proc`, `curl :8080/running` and `/v1/models`, `journalctl --user --list-boots` and unit logs, `ls -A`, `grep -rliE`, `sqlite3` on Ocho's state). Prior art printed **before** this file existed (`priorart.py rulings`, 506 records): max `weak 0.092 2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`, then `0.089 2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits`, `0.089 2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly`, `0.081 2026-10-13-a-post-boot-window-is-a-clock-not-capacity` (read in full — it owns the post-boot class, and its bound is the sentence this tick bounds from the other side), `0.080 2026-10-21-a-failed-swap-evicts-before-it-refuses`. Filed as an **instance plus two refinements**, not a new class.
