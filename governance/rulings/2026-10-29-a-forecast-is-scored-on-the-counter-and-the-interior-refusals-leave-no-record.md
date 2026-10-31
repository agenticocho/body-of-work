# A forecast is scored on the counter, and the interior refusals leave no record

**Date:** 2026-10-29
**Watcher:** ARCADE WINDOW TICK `67530e415818`, sample `15:52:20.201691074`
**Bracket:** `(14:55:19.951, 15:52:20.201]`
**Diff:** `kev_window open->closed`. `planner_at=planner` **IDENTICAL both sides** (no flip, no `@ocho`).
**Source of the line:** `cron/output/67530e415818/monitor_last_output.txt`, 36 B, mtime `15:52:20.201691074`, sha256 `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`, body `planner_at=planner kev_window=closed` — byte-identical to the 12:11 and 14:19 closed samples by construction (the script emits no timestamp, on purpose).

## The close edge, dated three ways

- **Pick:** `logs/ocho_planner_polymarket.log:244411` — `🎲 Weighted pick: ocho-planner-4b (30% weight, cycle 60396, pool 3/3)`; the five lines before it are `ocho-planner (60% weight, cycle 60391..60395)`.
- **Counter:** `ocho_sandbox/model_cycle_counter.txt` = `60397`, mtime `15:50:17.089392392` (post-increment), so the round drew `60396`.
- **Record:** `scopes/planner/record.json`, 494 B, ino `10272179` (recycled — `2026-10-23-an-inode-number-recycled-by-a-rename-replace-writer-is-not-continuity`), birth `15:50:17.179763838`, sha256 `f383661f4b2529257b50b4fe709148e43ff60da61422c9196d338e8cfb95699a`, owner `llama-swap-ocho-planner-4b`, need 3800, headroom 256, pid `372764`, mode `run`, ttl 86400, expires 2026-10-30T15:50:17.
- **Triple read POSITIVE** (the only positive flip evidence there is): wrapper `372764` ppid 2345 **ALIVE**; child `372863` **3482 MiB** in `--query-compute-apps`; `LISTEN 127.0.0.1:5806`; `/running` → `ocho-planner-4b state=ready`.
- **Journal:** `15:50:11 Starting` → `15:50:21 Finished`, `Result=success`, `ExecMainStatus=0`, 3.257 s CPU / 10.168 s wall / 143 M peak (against `status=1/FAILURE` for every round from 14:50 through 15:40).
- **Load:** capture `/tmp/gpu-lease.JJIwSr` 1637 B, birth `15:50:17.288762377`, mtime `15:50:21.634704149`, `model loaded` at `+1.126 s` ⇒ close ≈ **`15:50:18.415`**; the same capture served the round: 3657-token prompt at 2859.67 tok/s, 95-token eval at 94.44 tok/s, `n_tokens 3751`.

**Width:** open edge `14:50:14.026514366` (the orphan token of the 14:50 9B refusal, dated in `2026-10-29-a-failed-round-still-moves-the-card-and-the-forecast-guard-is-a-timer`) → close `15:50:18.415` = **3604.39 s = 6.007 × 600 s** (to the holder's own birth, 3603.15 s = 6.005). Interior picks: `60390` 9B refusal, `60391–60395` 9B refusals, `60396` 4B load ⇒ five interior refusals + one closing draw.

## Live reading (artifact, not memory)

Three identical `nvidia-smi` reads `15:52:28–31`: **8192 MiB total / 5485 used / 2406 FREE** / util 8, 13, 6 % / 42, 42, 41 °C ⇒ **CLOSED by 1883 MiB** under the 4289 gate (`4033 + 256`, constant read this tick from `scripts/arcade_window_watch.sh`). Compute apps: 1364 Bonsai + 134 vision + 226 bge-small + **3482 planner-4b** = 5206; `used + free = 7891` ⇒ driver 301; empty-scope ceiling **5893** ⇒ 9B `6456` **563 short**, 4B `4056` **1837 spare**.

## Rulings

**R1 — A WHEEL FORECAST IS ISSUED AND SCORED AS A COUNTER VALUE; THE MINUTES ARE DERIVED.** The 14:55 filing named `60396` (`pos 6`, 4B) as the round that closes, ~6 × 600 s. Measured at this sample: the close landed on **exactly `60396`** — `pos = count % 10` over `MODEL_SLOTS [9B,4B,smol]` weights `6,3,1` — and every elapsed interval is an integer round count (open widths `3598.640 / 3601.6 / 3604.39 s`, closed spans `2395.71 / 2396.8 s`). The one forecast that missed (`2026-10-29-the-shadow-run-advances-the-wheel-by-its-own-call-count` R2: 20 min / 2 rounds late) missed **because it was projected in wall-clock rounds** after the phase had moved nine. So: name the counter value, then the round count, and score at the sample against `model_cycle_counter.txt` — a wall-clock forecast cannot be scored, only argued with.

**R2 — THE GUARD MUST BE READ AT ISSUE AND RE-READ AT THE SCORE, AND BOTH ARE ONE-LINE.** At issue (`14:55`) the guard was `ocho-shadow-polymarket.timer` = `OnCalendar=*-*-* 1/6:00:00` (last `13:00:15`, next `19:00`), so no shadow call could sit inside the horizon and the counter advances exactly +1 per round. At the score the guard held: one pick line per round, no gap (`60390…60396`, consecutive), `pool 3/3` on every line so no slot demotion re-phased the wheel. A forecast whose guard is asserted only at issue is not falsifiable; a guard re-checked at the score makes the prediction binary.

**R3 — THE LEASE RECORD IS A SINGLE SLOT, SO AN INTERIOR REFUSAL LEAVES NO RECORD BEHIND.** `scopes/planner/record.json` is one path that every round's `take_lease` overwrites in place (same ino, fresh birth). The five interior refusals at `15:00:15 / 15:10:12 / 15:20:00 / 15:30:04 / 15:40:07` each wrote a `6200 + 256` lease and each one is **gone** — the only surviving census is the pick log line plus the journal's `status=1/FAILURE`. Consequence: `scopes/` answers "who holds the card now", never "what was refused"; a refusal census is assembled from pick lines + journal exit status, and an interior span cannot be reconstructed from the lease directory at all.

**R4 — THE PEAK-MEMORY BAND STILL DOES NOT DISCRIMINATE.** This window: five refusals at 142.4 / 142.9 / 143.0 / 143.3 / 143.5 M and one **success at 143 M** — the success sits inside the refusal range, a third independent confirmation of `2026-10-29-the-rotation-is-a-deterministic-wheel-…` R2. The durable discriminator remains exit status + a `/tmp/gpu-lease.*` capture + the resident process.

**R5 — A POSITIVE FLIP READING AT A CLOSE EDGE IS FILED HERE, NOT DM'd INTO A CLOSED ITEM.** This tick carries the strongest flip evidence the watcher has ever read (live `llama-swap-ocho-planner-4b` holder, pid alive, 3482 MiB resident, `state=ready`), and it still gets no `@ocho`: his item is closed in **his own rows** (`profiles/ocho/state.db` 152,150,016 B, mtime `07:42:24.538` untouched since boot, `max(id) = 17405`, closing ids 9249 / 9267 / 16736), and a DM would re-open a closed item into a channel that drops on `target_busy` with no receipt. The flip sentence's evidence belongs in the ruling; a transport channel is not an archive.

## Messages

**None. Both premises measured.** No `@ocho` — `planner_at` identical across the diff, and R5. No `@llama` — close edge, 2406 MiB is 1883 MiB the wrong way, the window is gone, and he self-authorises at `--scope arcade`; away side ABSENT (`scopes/` planner only, `lease.d/` does not exist, `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1).

## Standing flag for Mike (re-measured 15:55)

`profiles/llama/cron/` has **NO `jobs.json`**; `executions.db` 24576 B frozen `2026-10-12 06:33:07`, `output/` untouched since 10-12, while `ticker_heartbeat` (23 B) and `ticker_last_success` (18 B) were rewritten `15:55` — a live clock over an EMPTY JOB SET. This window stood **open 60.1 min at +1604 MiB** and closed on schedule with nothing executing the operator-approved precedence clause (execution fact, not a Kev decision; this watcher creates no jobs and starts no run). The one lever is unchanged and unleased: the `-ngl 0` tenant set 1364 + 134 + 226 = 1724 MiB, which holds 563 MiB of 9B admission — a fact about the card, **not** an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6).

**Read-only throughout:** `gpu-lease.sh` (status/read only), `llama-swap.yaml`, `scopes/planner/`, the planner unit and timer, all four compute processes, the driver, `call_ocho_planner.py` and `model_cycle_counter.txt` untouched; no acquire, release, load, reservation, config edit or job. The 15:50 load and the 15:00–15:40 refusals were the timer's own `*:0/10` requests through llama-swap.

**Prior art printed BEFORE this file existed** (`priorart.py rulings`, 523 records, two phrasings): weak `0.162 2026-10-27-the-close-edge-is-a-burst-and-closed-outlives-the-card`, `0.129 2026-10-29-a-failed-round-still-moves-the-card-and-the-forecast-guard-is-a-timer` (read; owns the failed-round interior and demands the guard, does not score an instance), `0.083 2026-10-20-a-forecast-scores-its-mechanism-not-its-outcome`, `0.118 2026-10-15-an-edge-already-dated-is-not-a-new-window`; none states that a forecast is issued and scored as a counter value, and none states that the single-slot lease record destroys an interior refusal's token.
