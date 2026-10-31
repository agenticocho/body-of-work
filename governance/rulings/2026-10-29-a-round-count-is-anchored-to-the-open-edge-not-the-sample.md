# A round count is anchored to the open edge, not to the sample

**Date:** 2026-10-29
**Watcher:** ARCADE WINDOW TICK `67530e415818`, monitor sample `17:37:20.061607258` (this run read disk `17:37:24` – `17:41`)
**Diff:** `kev_window open -> closed`. `planner_at=planner` **IDENTICAL both sides** ⇒ no `global->planner` flip, no `@ocho` DM.
**Line:** `cron/output/67530e415818/monitor_last_output.txt`, 36 B, mtime `17:37:20.061607258`, sha256 `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`, body `planner_at=planner kev_window=closed` — byte-identical to every earlier closed sample by construction (the script emits no timestamp; a hash certifies the string, never the referent, `2026-10-21-a-window-opened-by-refusals-is-the-planner-lanes-outage` applied).

## The open edge this close closes

The open sample was the `16:40:20` one (`2026-10-29_16-43-09.md`), and its 16:43 tick issued a forecast this tick scores. The open edge it never dated is the **16:30 round's refusal**: journal `16:30:07 Starting` → `16:30:14 status=1/FAILURE` on the 60 % 9B pick `60400`, the standing swap-stop that took the resident 16:20 smol and put nothing back. The previous closed sample was `16:29:20`, so the edge is bracketed `(16:29:20, 16:40:15.373]` and the refusal dates it to the second `[16:30:07, 16:30:15]`.

## The close edge, dated to 1.2 s

- **Pick:** `logs/ocho_planner_polymarket.log:245012` — `🎲 Weighted pick: ocho-planner-4b (30% weight, cycle 60406, pool 3/3)`; the five lines before it are `ocho-planner (60% weight, cycle 60401..60405)`.
- **Counter:** `ocho_sandbox/model_cycle_counter.txt` = `60407`, mtime `17:30:11.620330445` (read-then-incremented, so the round drew `60406`), 89 ms **before** the record birth — the same draw→lease ordering measured all day.
- **Record:** `scopes/planner/record.json`, **494 B**, ino `10272179` (recycled — `2026-10-23-an-inode-number-recycled-by-a-rename-replace-writer-is-not-continuity`), birth `17:30:11.710041530`, sha256 `36d88c88ea0fadac8bc8a68da5e3d7bc897120900b3bd5b0aa01c1e27f7e329b`, owner `llama-swap-ocho-planner-4b`, scope `planner`, `class batch`, `need_mib 3800`, headroom 256, `mode run`, pid `442901`, ttl 86400.
- **Triple read POSITIVE:** wrapper `442901` ppid `2345` (llama-swap) **ALIVE**, `lstart Thu Oct 29 17:30:10`; child `443000` **ALIVE 3482 MiB** in `--query-compute-apps`; `/running` → `ocho-planner-4b state=ready` proxy `:5806`.
- **Load:** capture `/tmp/gpu-lease.sHUKsE` 1637 B, birth `17:30:11.821041255`, mtime `17:30:16.303988745`, `model loaded` at `+1.126949 s` ⇒ **close `17:30:12.948`**; the same capture served the round: 3653-token prompt at 2855.68 tok/s, 108-token eval at 94.27 tok/s, `n_tokens 3760`.
- **Productive, not a slab:** journal `17:30:05 Starting` → `17:30:16 Finished`, 3.222 s CPU / 10.837 s wall / **143.4 M** peak; `plans/latest_plan.json` 1332 B mtime `17:30:16.402492797`; prediction row `ts 2026-10-30T00:30:16.402564Z`, `model_slot: ocho-planner-4b`, `predicted_prob 0.88`.
- **Width:** `17:30:12.948 − [16:30:07, 16:30:15]` = **3597.95 – 3605.95 s = 5.997 – 6.010 × 600 s**. The six-round count is robust across the whole bracket; only the second is uncertain, by ±4 s.

## The forecast, scored

The 16:43 row wrote, verbatim: *"Forecast keyed to the counter (`60402`, written 89 ms before the record): `60402–60405` stay 9B refusals → window holds; `60406` (pos 6) is a 4B → close ~17:40, ≈6 rounds / ~3600 s."*

| arm | predicted | measured this tick |
|---|---|---|
| `60402–60405` are 9B and refuse | 4 refusals | 4 refusals: journal FAILURE `16:50:12→16:50:18`, `17:00:00→17:00:06`, `17:10:13→17:10:20`, `17:20:01→17:20:07`; all four pick lines `ocho-planner (60% weight)` |
| `60406` (pos 6) is 4B and closes | cycle `60406` | `Weighted pick: ocho-planner-4b … cycle 60406`; record birth `17:30:11.710`, load `17:30:12.948` |
| close ≈ 6 rounds / ~3600 s | 3600 s | **3597.95–3605.95 s** — TRUE |
| close ~17:40 | 17:40 | **17:30:12.948 — FALSE, one round long** |

The two arms disagree because they are anchored at different instants. The counter arm is right: `60406` is a 4B and it closed the window. The clock arm counted **six** rounds forward from the `16:40:20` sample — and that sample was taken 11 s after round `60401` had already been drawn (`16:40:09 Starting`) and 5 s after it had already failed (`16:40:15 FAILURE`). The sample therefore already contained a round; counting from it adds one, and 6 × 600 s from 16:40 lands on 17:40. Measured from the open edge, the six rounds are exactly `60401`(16:40) `60402` `60403` `60404` `60405` `60406` and the close is 17:30.

## Live reading (artifact, not memory)

Three identical `nvidia-smi` reads `17:37:24` / `17:39:5x` / `17:39:5x`: **8192 MiB total / 5485 used / 2406 FREE** / util 10, 13, 14 % / 40 °C ⇒ **CLOSED by 1883 MiB** under the 4289 gate (`4033 + 256`, branch read this tick at `scripts/arcade_window_watch.sh:47`, file sha256 `775c4858…6e0e8e`, unmodified since 2026-10-13). Compute apps: `2347` Bonsai 1364 + `2349` vision 134 + `87744` bge-small 226 (all `-ngl 0`, unleased) + `443000` planner-4b 3482 = **5206**; `used + free = 7891` ⇒ driver/ctx 301; **empty-scope ceiling 5893** ⇒ 9B `6456` is **563 short**, 4B `4056` has **1837 spare**.

## Rulings

**R1 — A ROUND COUNT IS ANCHORED TO THE OPEN EDGE, NOT TO THE SAMPLE THAT READS IT.** A monitor sample is not an instant in the rotation: if it lands after that round's draw, the round it belongs to is already consumed, and a count taken from the sample adds one round. Here the named pick was correct, the count was correct, and the derived clock was still 600 s long — the one error class that is indistinguishable from a wheel error at the next tick, which is exactly how a correctly-scored forecast gets re-derived as a mapping defect. Corollary: quote the count from the edge and the instant as `edge + n × 600 s + load term`; a forecast that can only anchor at a sample should state the round, not the clock.

**R2 — THIS TICK IS WHERE THE TWO PRIOR CORRECTIONS DID NOT REACH.** `2026-10-21-a-counter-read-at-a-rounds-end-names-the-next-round` fixed the counter→round label mapping (there the clock was 599 s *early*), and `2026-10-27-a-forecast-names-the-round-and-the-second-it-names-is-the-loads` fixed the second-level width by naming the load term. Both were honoured here — `60402` → 16:50 was the correct mapping, and the 1.2 s of load was measured — and the residual was still a full round, because the anchor was neither the label nor the load but the sample. Score the counter arm; treat the clock as derived and make it name its anchor.

**R3 — THE 143 M PEAK BAND IS CONFIRMED NON-DISCRIMINATING A FOURTH TIME.** The closing round's 143.4 M peak sits inside the interior refusals' 142.4–143.5 M range. Exit status + a `/tmp/gpu-lease.*` capture + the resident process remain the only discriminators.

## Messages

**None. Both premises measured.** No `@ocho` — `planner_at` identical across the diff, and his item is verifiably closed in **his own rows** (`sqlite3 -readonly profiles/ocho/state.db`, `max(id) = 17405`, ids 9249 / 9267 / 16736); a DM re-opens a closed item into a channel that drops on `target_busy` with no receipt. No `@llama` — close edge, 2406 MiB is 1883 MiB the wrong way, the window is gone at write, and he self-authorises at `--scope arcade`; the away side is ABSENT (`scopes/` = `planner` only, `lease.d/` does not exist, `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1, `pgrep -af 'kev|arcade'` no match).

## Standing flag for Mike (re-measured 17:38)

`profiles/llama/cron/` has **NO `jobs.json`** (only `.jobs.lock`, `.tick.lock`, `executions.db` 24576 B frozen `2026-10-12 06:33:07`, `output/` untouched since 10-12) while `ticker_heartbeat` was rewritten `17:38` — a live clock over an EMPTY JOB SET. This window stood open ~60 min at +1604 MiB and closed on a rung that fits, with nothing executing the operator-approved precedence clause (execution fact, not a Kev decision; this watcher creates no jobs and starts no run). The one lever is unchanged and unleased: the `-ngl 0` set 1364 + 134 + 226 = 1724 MiB, which holds 563 MiB of 9B admission — a fact about the card, **not** an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6).

**Read-only throughout:** `gpu-lease.sh`, `llama-swap.yaml`, `scopes/planner/`, the planner unit/timer, all four compute processes, the driver, `call_ocho_planner.py` and `model_cycle_counter.txt` untouched; no acquire, release, load, reservation, config edit or job. The 17:30 load and the 16:50–17:20 refusals were the timer's own `*:0/10` requests through llama-swap.

**Prior art printed BEFORE this file existed** (`priorart.py rulings`, 524 records): weak `0.150 2026-10-21-a-counter-read-at-a-rounds-end-names-the-next-round` (read; owns the label mapping and is cited as applied, not duplicated), `0.108 2026-10-15-an-edge-already-dated-is-not-a-new-window`, `0.103 2026-10-13-a-reboot-manufactures-the-window` (owns the poll's sample instant, about writes not round counts), `0.103 2026-10-29-an-open-edge-and-its-orphan-token-are-one-event`, `0.100 2026-10-27-a-forecast-names-the-round-and-the-second-it-names-is-the-loads` (read; owns the load term) — none states that a round count must be anchored to the open edge rather than to the sample that reads it.
