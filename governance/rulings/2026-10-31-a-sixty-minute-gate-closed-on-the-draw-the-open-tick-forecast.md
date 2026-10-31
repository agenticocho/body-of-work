# 2026-10-31 · A 60-minute gate closed on the first fitting draw — six refusals, nothing acquired, and the open tick's forecast landed on its own terms

**Tick:** `arcade-window-watch`, job `67530e415818`. Sample `cron/output/67530e415818/monitor_last_output.txt` **36 B**, mtime `14:17:23.885538808`, sha256 `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`, body `planner_at=planner kev_window=closed`. Previous sample `2026-10-31_14-06-23.md` **155 B** `no_change` mtime `14:06:23.742398575`, still carrying the **34 B** open line sha256 `8da24188…9216fe2`. ⇒ **bracket `(14:06:23.742, 14:17:23.886]`**.
**Diff:** `kev_window open → closed` · `planner_at=planner` **IDENTICAL both sides** → no `global→planner` flip branch, **no `@ocho` DM**.
**Nature:** **RECORD ONLY.** No acquire, no release, no reservation, no model load, no unit, timer or config edit, no agent message. Llama is self-authorised at `--scope arcade` when free ≥ 4289 and self-runs; this tick does not preempt his poll.
**Filed as a dated instance, not a new class.** `priorart.py rulings` (**533 records**, run before this file existed): top hits `REVIEW 0.207 2026-10-27-the-hour-wide-window-closed-on-the-first-draw-that-fits` and `weak 0.185 2026-10-25-a-refusals-arithmetic-dies-with-its-cell-and-the-width-repeats-to-six-cycles`; the class is also owned by `2026-10-27-the-post-boot-window-closes-on-the-first-fitting-draw` (*"six refusals, 56.5 min, nothing acquired"*), `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` R1, `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` and `2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`. **No new mechanism is claimed.** The increment is the numbers (§1–§3), the away-side measurement (§4) and a forecast scored (§3).
**Method:** every figure is a read taken this tick (14:17–14:20 PDT): `nvidia-smi` (4 reads) and `--query-compute-apps`, `ps -o pid,ppid,etime,args`, `curl :8080/running`, the lease tree (`cat`, `stat -c %s/%i/%w/%y`, `sha256sum`), `/tmp/gpu-lease.*` births and bodies, `journalctl --user -u ocho-planner-polymarket.service`, the planner's own append log and prediction JSONL, `profiles/llama/cron/`, and the job's own output directory counted by report class. Nothing recalled from a prior tick.

## 1. Live card at write

```
14:17:27  8192 MiB total / 5363 used / 2528 free
14:18:0x  8192 MiB total / 5519 used / 2372 free
14:18:0x  8192 MiB total / 5526 used / 2365 free
14:18:0x  8192 MiB total / 5521 used / 2371 free
```

**CLOSED by ~1918 MiB** under the 4289 gate (`4033 + 256`): `4289 − 2371 = 1918`. Compute apps: `119173` llama-server **3482** (planner 4B, `:5806`) + `2424` PrismML-Bonsai **1402** + `2419` PrismML-Bonsai **206** + `2426` llama-server **134** = **5224**; `used − apps = 297 MiB` is driver/context, and `used + free = 7892` against the 8192 total leaves **300 MiB** held outside both counters (reserved). The three unleased tenants are the same processes as at 12:21 (all `-ngl 0`, `etime 01:56` at 14:18 ⇒ start `12:21:3x`); the only thing that moved is the planner's own 4B, now resident.

## 2. The close edge, dated to the second from the load capture — not left at the bracket

| stamp (PDT) | artifact | reading |
|---|---|---|
| 14:06:23.742 | `2026-10-31_14-06-23.md` 155 B `no_change` | last sample reading the window **open** |
| 14:10:10 | journal `ocho-planner-polymarket.service` `Starting` | round 14:10 begins |
| **14:10:18.787** | `scopes/planner/record.json` **birth** (494 B, ino **9233518**, sha256 **`578d13e3ec5cfc814516e8b3a06f9f4ef084c3401ad7e14314e599a46349fba6`**) | `owner=llama-swap-ocho-planner-4b`, `scope=planner`, `class=batch`, `need_mib=3800`, `pid=119056`, `mode=run`, `acquired_at=1793481018` (=14:10:18), `expires_at=1793567418`, `ttl=86400`, `headroom_mib=256` |
| 14:10:18.930 | `/tmp/gpu-lease.0ocAr5` **birth** (1637 B; mtime 14:10:24.434) | capture opens |
| 14:10:18.958 | capture `+0.028.572` | `loading model '…/Qwen3.5-4B-UD-Q4_K_XL.gguf'` |
| **14:10:21.016** | capture `+0.02.086.340` | **`model loaded`** → listening `127.0.0.1:5806` — **the close edge** |
| 14:10:24.560 | `ocho_sandbox/plans/latest_plan.json` 1204 B; prediction row `ts 2026-10-31T21:10:24.560583+00:00 model_slot=ocho-planner-4b` | **work certifies** |
| 14:10:24 | journal `Finished` (exit 0, 5.905 s CPU, 14.257 s wall) | round **succeeded** |
| 14:17:23.886 | `monitor_last_output.txt` | **closed** sampled |

So the edge is `14:10:21.016`, inside the sampler bracket and 2.086 s after the capture was born. Pre-load free is derived, not remembered: `free_now + resident = 2371 + 3482 = 5853` → the card stood **1564 MiB above the gate** at the instant the 4B took it.

## 3. Width = the refusal streak, and the open tick had already forecast this exact draw

Rounds from the journal, unbroken: `13:10:09→16` `status=1/FAILURE`, `13:20:08→15`, `13:30:02→09`, `13:40:05→17`, `13:50:09→18`, `14:00:00→08` — **six consecutive refusals** — then `14:10:10→24` **Finished exit 0**. The rungs, quoted from the planner's own append log (`ocho_planner_polymarket.log`), not inferred:

```
Weighted pick: ocho-planner      (60% weight, cycle 60740 … 60745, pool 3/3)   ×6
Weighted pick: ocho-planner-4b   (30% weight, cycle 60746, pool 3/3)           ×1
```

`60740`–`60745` = the 9B, `need_mib 6200 + 256 = 6456` against an empty-scope ceiling of ~5853 ⇒ **603 short**, hence six refusals and a card left clear each time. `60746` = the 4B, `need 3800 + 256 = 4056` ⇒ **fits by ~1797**, loads, and *is* the close. Window = `13:10:16 → 14:10:21.016` = **60 m 05 s**, observed open at five consecutive samples (13:22, 13:33, 13:44, 13:55, 14:06).

**The forecast landed.** The 13:22 tick wrote, verbatim: *"Next fitting draw forecast: counter 60742, value `60746` (4B) at the 14:10 round."* Cycle `60746` **is** `ocho-planner-4b` and it drew at the 14:10 round. This is the first instance of the class where the **closing rung and its round were named in advance**, so the width is a computed quantity on this ladder — `(next cycle with pos ∈ 6–8) × round period` — and not only a width reproducible after the fact. Note today's six-refusal width (60.1 min) and 2026-10-27's (56.5 min) are the *same* mechanism at different phase alignments, not two widths.

## 4. The away side: nothing was acquired in sixty minutes, measured rather than assumed

- `~/.local/state/gpu-lease/` at write: `lease.mutex` (0 B, mtime 14:10), `backups/`, `scopes/planner/` — **`scopes/` = planner only**, **`lease.d/` ABSENT**, and nothing named `arcade|kev|model-test` anywhere in the tree.
- `/tmp/gpu-lease.*` holds **exactly three** captures: `yVmNGs` (4713 B, 13:02), `3w2bou` (1642 B, 13:02), `0ocAr5` (1637 B, 14:10). A load attempt — whoever makes it — leaves one of these, so **no load was attempted by anyone between `13:02:15` and `14:10:18`**. The hour-wide window was taken by nothing, and the only consumer that entered it was the planner's own 4B at the end of it.
- The reason is measurable, not moral: `profiles/llama/cron/` still has **no `jobs.json`** while `ticker_heartbeat` (22 B) and `ticker_last_success` (18 B) were both rewritten at **14:18** — a live clock over an empty job set. The operator-approved precedence clause has **no executor** on his side, so `free ≥ 4289 for 60 min` was not missed by Llama; it was never polled. Execution fact, not a Kev decision: this watcher creates no jobs and pages nobody for a closed window.
- The 9B's 603-MiB shortfall is **arithmetic about the card**, not an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6).

## 5. The planner lease went from orphan to live holder under a byte-identical token

At the 13:22/13:10 tick the record making `planner_at=planner` true was an **orphan** — `need_mib 6200`, `pid 51885` dead — which is why that tick refused to certify the flip. It is a **live holder** now: wrapper `119056` alive (`ppid 2421` = llama-swap) whose child `119173` is resident **3482 MiB** on `:5806`, `:8080/running` = `ocho-planner-4b state=ready`, and the round it served wrote a plan and a prediction row. `planner_at` read `planner` on **both** sides of a dead→live transition of its own referent, which is exactly the defect `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` owns: the token is filed here, and it is not evidence of anything but a token.

## 6. Messages — none, both premises measured

**No `@ocho`.** `planner_at` is identical on both sides, so the `global→planner` branch never fired; the positive evidence that branch exists to certify (wrapper alive + resident + `/running state=ready` + plan and prediction written by that round) is **filed here instead of DM'd**. A DM into a closed item re-opens it into a channel that **drops on `target_busy` with no receipt** (`2026-10-29-a-forecast-is-scored-on-the-counter-and-the-interior-refusals-leave-no-record` R5). A transport channel is not an archive.
**No `@llama`.** This is a **close** edge: live free 2371 is **1918 MiB the wrong way**, his authorisation is `free ≥ 4289` at `--scope arcade`, and the fallback clause is a condition on an **open** card. The window is gone at write; there is nothing to hand him.

## 7. Standing flag for Mike, re-measured 14:18

- **Coverage, today:** the job's own output directory holds **51 entries** — **50** `.md` reports plus `monitor_last_output.txt` — classified by size and content as **36 `no_change` (155 B)**, **12 `FAILED`** (`Hermes can't reach the model provider`), **2 agent runs**. The 12 failures are the 03:24→11:35 transitions, whose diffs survive only inside their own failure reports and are pruned at the day boundary.
- **Standing flag:** `profiles/llama/cron/` = live heartbeat, **no `jobs.json`** (unchanged across four ticks today). An hour-wide gate above the threshold went to nobody because nothing on that side is scheduled to look.
- **Corrected standing detail, measured here:** `ocho_planner_polymarket_err.log` is **stale** — mtime `2026-10-22 10:30`, 1163 B, a `python3.14`/`urllib3` `loggerDict` `AttributeError` nine days old. Today's refusals are **not** that traceback: they are llama-swap `group: starting ocho-planner failed: aborted` answering HTTP 500, i.e. the admission layer, not the Python layer.

**Read-only throughout:** `gpu-lease.sh`, `llama-swap.yaml`, `scopes/planner/`, the planner and shadow units and timers, the four compute processes and the driver were read and left untouched; no acquire, release, reservation, config edit or cron change. The 14:10 4B load was `ocho-planner-polymarket.service`'s own request through llama-swap.
