# The close edge is a burst — and the closed line outlives the card by nine minutes

**Tick:** cron job `67530e415818` (Arcade GPU co-residency watcher), write **2026-10-27 13:07–13:12 PDT**.
**Diff:** `planner_at=planner` identical both sides (no flip, no Ocho branch); `kev_window open -> closed`.
Chain: `cron/output/67530e415818/2026-10-27_12-56-16.md` 155 B mtime `12:56:16.431224999` sha256
`93ad7ed432dbe9c5…0ed12e` `Status: no_change (agent run suppressed)` (still reading the 34 B open line) ->
`monitor_last_output.txt` 36 B mtime `13:07:16.363162285` sha256 `b391e197e2dd93bd…145820b1`
`planner_at=planner kev_window=closed`. Bracket `(12:56:16, 13:07:16.363]`; the mechanism dates the edge to
**13:01:17.688**, four and a half minutes inside the bracket.

## Live at write, four reads 13:07:20 - 13:11:27

| read | used | free | util | °C |
|---|---|---|---|---|
| 13:07:20 | 4447 | **3445** | — | — |
| 13:08:5x | 4451 | **3441** | 4 % | 40 |
| 13:09:1x | 4451 | **3441** | 8 % | 40 |
| 13:11:12 | 1774 | **6118** | 5 % | 40 |
| 13:11:27 | 1770 | **6122** | — | — |

The first three reads say **CLOSED** by 848 MiB (`3441 - 4289`; gate = 4033 + 256, `arcade_window_watch.sh:12,:47`).
**The last two say the card is empty and the gate is OPEN again by +1829/+1833** — see R2. Tenants across the
whole write: pid `2408` Bonsai 1364 + pid `2409` vision 134 = 1498 (both `--n-gpu-layers 0`, unleased);
`used + free 7888-7892` vs 8192 leaves ~300-304 MiB in neither column.

## The close edge is two fitting draws 9.158 s apart, not one

- `/tmp/gpu-lease.1ZonOp` 3257 B birth `13:01:16.563213575` mtime `13:01:25.382113795` body
  `Qwen3.5-4B-UD-Q4_K_XL.gguf`, `model loaded` at **+1.125132 s = 13:01:17.688**, `listening on
  http://127.0.0.1:5806` — the **close instant**.
- `/tmp/gpu-lease.M8ZesH` 1642 B birth `13:01:26.085105856` mtime `13:01:28.264081264` body
  `SmolLM3-3B-128K-UD-Q4_K_XL.gguf`, `model loaded` at **+0.760771 s = 13:01:26.846**, `listening on
  http://127.0.0.1:5808` — the **resident that survived**.
- The 4B lease lived **8.8 s** and was stopped by its own group sibling (`planners: swap: true`,
  `llama-swap.yaml:114-116`; members `ocho-planner` 6200 / `-4b` 3800 / `-smol` 3000 / `-ornith35` 3200).
- Lane output prices the burst exactly: `ocho_predictions.jsonl` rows `20:01:20.634218Z` slot
  `ocho-planner-4b`, `20:01:23.239155Z` slot `ocho-planner-4b`, `20:01:28.375129Z` slot
  `ocho-planner-smol` → two predictions on the 4B, **7.741 s** from the burst's first row to its last, the
  third served by the smol. The single most recent row before the burst is `19:20:14.847798Z` (12:20:14
  local, smol): **zero predictions for the whole window** (12:30:16.720 → 13:01:17.688, 1860.968 s), and
  zero from 12:20:14.848 until 13:01:20.634 — a **2465.786 s** gap priced at nothing.
- Rotation, checkable against the scalar: `model_cycle_counter.txt` `60070` mtime `13:01:25.725752945`
  (post-increment for pick `60069`); weights `6/3/1` (`call_ocho_planner.py:428-432`, total 10) →
  `60069 % 10 = 9` = smol, `60068 / 60067 % 10 = 8 / 7` = 4b, matching the three rows. All three slots
  `eligible: true` in `model_brier_report.json` (n 197 / 116 / 16), so the weights are the O55 defaults.
- **The refusal was not the close.** Journal: `13:00:00 Starting` -> `status=1/FAILURE 13:00:07`
  (3.380 s CPU / 6.841 s wall / 142.0 M peak) — the 9B pick refused at the lease layer and left the card
  **empty for another 69.688 s**; the drawer that ended the open gate arrived off-cadence at `13:01:16.563`,
  after the unit had already exited (`ocho-shadow-polymarket.service` was still running 13:00:00 ->
  13:01:28, contemporaneous, not proven as the caller). Also in-window: `12:50:01 -> FAILURE 12:50:07`.

## The record at write of the close, and the record now

- **At 13:07** the cell held `scopes/planner/record.json` 495 B ino `8782668` birth `13:01:26.001106805`
  sha256 `0b29f9425315f62c51b374ff376ad5c38821435d97f4c83d61855e696e375b6f`
  `owner=llama-swap-ocho-planner-smol` `scope=planner` `class=batch` **`need_mib=3000`** `pid=98370`
  `mode=run` `acquired_at=1793131286` `expires_at=1793217686` `ttl=86400` `headroom_mib=256`; dir
  `scopes/planner` ino `8782623` birth `13:01:25.997106850`; wrapper `98370` ALIVE + child `98450` ALIVE
  **2672 MiB** LISTEN `127.0.0.1:5808`, `:8080/running` = `ocho-planner-smol state=ready proxy :5808`,
  `:5808/health` `{"status":"ok"}`.
- **At 13:11** both pids are gone, `:8080/running` = `{"running":[]}`, no listener 5800-5809, and the same
  cell holds 491 B birth **`13:10:14.718589938`** `owner=llama-swap-ocho-planner` **`need_mib=6200`**
  `pid=104999` — **DEAD** (`/proc` absent, `ps -p` no row, never in `--query-compute-apps`) — against
  journal `13:10:08 Starting -> status=1/FAILURE 13:10:15`. `lease.d/` ABSENT throughout, `scopes/` =
  `planner` only, `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1, `pgrep -af
  'kev_run|arcade_|model-test|llama-model-test'` self-match only.

## Arithmetic (all reads, no carried numbers)

- Gate `4033 + 256 = 4289` vs free `3441` -> **closed by 848**; vs free `6118-6122` at 13:11 -> **open by 1829-1833**.
- Empty-card ceiling `3441 + 2672 = 6113` (4B tenant gone, so this is the scope-empty card): 9B ask
  `6200 + 256 = 6456` -> **343 MiB SHORT**; 4B ask `4056` -> 2057 spare; smol ask `3256` -> 2857 spare.
- Width `13:01:17.688 - 12:30:16.720 = 1860.968 s = 31.0161 min = 3.10161 x 600 s`.
- The closed band lasted `13:01:17.688 -> 13:10:14.718 = 537.030 s = 8.950 min` — **shorter than one sample interval**.
- Today, journal census of `ocho-planner-polymarket.service`: **79 rounds, 32 `Finished`, 47 `status=1/FAILURE`**.
  Five dated windows total **14192.726 s of 23348.928 s** from `06:32:08.760` to the close = **60.79 %**.

## R1 — The close edge is a burst: the first fitting draw ends the open gate, the last one keeps the card

Two fitting draws 9.158 s apart (4B `13:01:17.688`, smol `13:01:26.846`) closed the gate between them, and
only the **survivor** is named by the record — the 4B's lease was already unlinked when the sample was taken.
So "who closed the window" answered from the record alone answers with the rung that *holds*, and the rung
that *ended the gate* can be gone inside ten seconds having served two predictions. Read the captures' births
in order, and name both: a single owner+need in the cell is a photograph of the last 9 s of the edge, not a
description of it.

## R2 — `closed` is a sample, not a state: this one outlived the card by 8.95 min, less than one tick

The persisted line (`13:07:16.363`, 3441 free, closed by 848) was true when written and false by 13:11: the
next 9B pick at 13:10:08 spent the resident smol, wrote a born-dying `need_mib=6200` record (pid 104999 dead),
and failed at 6456 vs **6113 = 343 short** — the same sentence the 12:39 filing wrote for the previous
resident, now confirmed on the smol: the 9B cannot fit in *any* state of this card, and it holds 60 % of the
weight, so a `mode=run` holder's liveness protects it from expiry and not from the rotation. Two consequences
for readers of this log: (1) `closed` is a maximum, never "has been closed since" — the true closed band here
was 537.030 s, and a 10-minute cadence can straddle a whole close; (2) the reopened gate (6118 free, empty
card, `planner_at=planner` naming a dead 9B) is live at write and **unsampled**, so the next tick will report
`closed -> open` for an edge that happened at 13:10:14.718, not at the sample that notices it.

## R3 — A window that produced no plans is priced at zero, and its close bought three rows

The lane is empty from `19:20:14.847798Z` to `20:01:20.634218Z` (2465.786 s), covering the entire
1860.968 s window; the burst that closed it produced three rows in 7.741 s, two of them on a rung that lived
8.8 s. Whatever a 31-minute open gate was worth to the Kev side, it cost the planner card one 4B load and one
smol load to buy three predictions — quote the lane rows with the width, or the width is only a number.

## Action and messages

RECORD ONLY. No acquire, release, load, reservation, unit or config touched; `gpu-lease.sh` read-only,
`llama-swap.yaml`, `scopes/planner/`, the planner unit, the smol/4B residents, the Bonsai and vision tenants
and the driver untouched — the 13:01:16 4B, the 13:01:26 smol and the 13:10:14 dead 9B record were the
timer's and llama-swap's own requests.

**MESSAGES NONE.** No `@ocho`: the token never moved in this diff, and his item is closed in his own rows
(`profiles/ocho/state.db` 9249 / 9267 / 16736, `max(id)=17405`, nothing later on the subject). No `@llama`:
this is a **close** edge with 3441 free — 848 MiB the wrong way — and the reopened card is the next tick's
business; he self-authorises at `--scope arcade` and this watcher does not preempt his poll. The DM path is
re-measured ABSENT from this cron toolset (`tool_search` two phrasings -> only `process_manage`).

**STANDING FLAG FOR MIKE, re-measured:** the self-authorised poll still has no executor —
`profiles/llama/cron/` has **no `jobs.json`** (only `.jobs.lock`, `.tick.lock`, `executions.db` 24576 B
frozen `2026-10-12 06:33:07.322361061`, `output/` untouched since 10-12) while `ticker_heartbeat` 23 B is
rewritten `13:09:15.301437519` (`1793131755.3008604 2484`) = a live clock over an empty job set. Six open
windows today, nothing acquired in any of them. This watcher creates no jobs.

## Prior art

`priorart.py rulings` printed **before** this file existed: 509 records, two phrasings; max
`weak 0.128` `2026-10-27-the-post-boot-window-closes-on-the-first-fitting-draw` (own parent class — a close
edge on a fitting draw), `0.102` `2026-10-21-a-sample-that-lags-the-card-is-not-a-witness`,
`0.102` `2026-10-08-a-render-must-not-draw-what-the-record-cannot-support`,
`0.093` `2026-10-25-a-fitting-rung-is-not-a-load-and-a-window-across-a-failure-streak-is-not-an-opportunity`,
`0.090` `2026-10-24-the-refusers-cell-erases-the-fitting-holder-that-preceded-it`. Class cited by path, not
restated; the increments are the two-rung burst inside one close edge (R1), the 537.030 s close measured
shorter than one sample interval (R2), and the zero-plan price of the window (R3).

Every number above is a disk read this tick: `nvidia-smi` x6 + `--query-compute-apps`, `stat %w/%i`,
`sha256sum`, `record.json`, `ps -p`/`/proc`, `curl :8080/running` + `:5808/health`, `ss -ltnp`,
`journalctl --user` (unit + full-day census), capture bodies, `ocho_predictions.jsonl`,
`model_cycle_counter.txt`, `model_brier_report.json`, `call_ocho_planner.py:425-478`, `llama-swap.yaml:78-116`,
`grep -rliE`, `pgrep -af`, `sqlite3 -readonly`, `priorart.py`, `tool_search`.

**RULINGFILE** `rulings/2026-10-27-the-close-edge-is-a-burst-and-closed-outlives-the-card.md`
