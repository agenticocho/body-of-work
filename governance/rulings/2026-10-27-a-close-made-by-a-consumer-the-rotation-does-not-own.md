# A close made by a consumer the rotation does not own, and a width the rotation does not set

TICK 2026-10-27 19:05:21–19:11 PDT (arcade-window-watch, job `67530e415818`), change at the `19:05:16` sample.
Diff: `planner_at=planner` **IDENTICAL both sides** (no flip, **NO @ocho**), `kev_window open->closed`.
Bracket `(18:54:16, 19:05:16]` (samples `2026-10-27_18-32-16.md`, `18-43-16.md`, `18-54-16.md` all 155 B `Status: no_change` reading the 34 B open line; current `monitor_last_output.txt` 36 B mtime `19:05:16`).
Script re-run at write: `planner_at=planner kev_window=closed` (`~/.hermes/profiles/chilly/scripts/arcade_window_watch.sh:12,:47` — gate 4033 + 256 = 4289; read this tick).

## Live card

Three reads 19:05:21 / 19:05:5x / 19:10:5x: 8192 total / **5261, 5257, 5261 used / FREE 2631, 2635, 2631** / util 5–9 % / 41–42 C
=> **CLOSED by 1654–1658 MiB** under the 4289 gate.
Compute apps: `2408` Bonsai 1364 + `2409` vision 134 (both `--n-gpu-layers 0`, unleased) + `344849` planner **3482** = 4980 of 5261; `used+free` 7892 vs 8192 = the standing ~300 MiB driver/ctx reserve in neither column, so the **empty-scope ceiling is 2631 + 3482 = 6113**.
Arithmetic: 9B ask `6200+256 = 6456` = **343 MiB SHORT of an empty card**; 4B `3800+256 = 4056` = 2057 spare; smol `3256` = 2857 spare.

## The close edge, dated to 93 ms and corroborated twice

- `scopes/planner/record.json` **494 B**, ino `8782668` (the single rewritten cell), birth **`19:01:13.616716026`**, sha256 `ed2bca1df6fd3bfd9a00b3088055ba5f1ed47e887b21fd0592bc92a4073779c2`, `owner=llama-swap-ocho-planner-4b scope=planner class=batch need_mib=3800 headroom_mib=256 pid=344744 mode=run acquired_at=1793152873 expires_at=2026-10-28T19:01:13`.
- capture `/tmp/gpu-lease.QjgPDU` 3257 B **birth 19:01:13.709715095** (+93 ms), body `Qwen3.5-4B-UD-Q4_K_XL.gguf`, `model loaded` at **+1.108052 s => close `19:01:14.818`**, `listening on 127.0.0.1:5806`.
- wrapper `344744` **ALIVE**, ppid **2405** (llama-swap), lstart `19:01:12`; child `344849` **ALIVE 3482 MiB** LISTEN `127.0.0.1:5806`; `:8080/running` = one entry `ocho-planner-4b state=ready proxy :5806`; `llama-swap.log` mtime `19:01:15.789` ending `<ocho-planner-4b> Health check passed on http://localhost:5806/health`.
- `lease.d/` **ABSENT**, `scopes/` = `planner` only, `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1, `pgrep` no away process.

## Width: 3059.818 s of empty card

Open edge `18:10:15` (the 9B refusal that evicted the smol, cited from the `18:17` row) -> close `19:01:14.818` = **3059.818 s = 50.9970 min = 5.0997 rounds**.
The card was *empty* for it, not merely under the gate: no capture was born between `/tmp/gpu-lease.z3sjqG` (mtime `18:00:22.982`) and `QjgPDU` (birth `19:01:13.709`), and the planner unit refused five times — `18:20:04->18:20:11`, `18:30:10->18:30:16`, `18:40:13->18:40:19`, `18:50:01->18:50:08`, `19:00:03->19:00:10`, every one `status=1/FAILURE` (142.x M peak, the refusal fingerprint). So `6113 >= 4289` held unclaimed for 3059.818 s = 1824 MiB above the gate throughout.

## The closing load belongs to a unit that did not fail

- planner unit `19:00:03 Starting -> 19:00:10 status=1/FAILURE` (3.691 s CPU / 7.138 s wall / 142.5 M), `planner log` ending `[llm] Request failed: 500 Server Error ... http://localhost:8080/v1/chat/completions`, `llama-swap.log` `group: starting ocho-planner failed: aborted` + `status=500`.
- **`ocho-shadow-polymarket.service` ran `19:00:03 -> 19:01:22` (1 min 18.997 s, exit 0)**, its log carrying three `[shadow-llm] Calling planner for ...` calls and `Logged 3 new shadow trades`.
- The three served answers are dated in the lane: `ocho_predictions.jsonl` `02:01:18.184476Z`, `02:01:20.522794Z`, `02:01:22.301857Z`, all `model_slot: ocho-planner-4b`; `plans/latest_plan.json` 1268 B mtime `19:01:22.301794737` (Lieberman, `predicted_prob 0.01`, amount 3).
- The 4B lease was acquired **63.4 s after the round's exit**, inside that shadow window, and the first served answer landed 3.4 s after `model loaded`. Which draw bought it is **not recoverable from the pick log**: the last printed pick is `cycle 60105` (`ocho_planner_polymarket.log`), while `model_cycle_counter.txt` reads **60109** mtime `19:01:20.856` (= post-increment for pick `60108`), so draws `60106–60108` have **no pick line on disk**; the shadow unit is a second consumer of the same counter.

## R1 A WIDTH THE ROTATION DOES NOT OWN IS A FLOOR, NOT A FORECAST

The `18:17` filing derived from the failed-round chain that a window opened by a 9B refusal is *"closed until the next FITTING pick"* and that its width is therefore a rotation quantity. This tick measures the qualifier: the fitting draw arrived from **another consumer** (`ocho-shadow-polymarket`) 63.4 s after the round that failed, so the width was **shorter than the round cadence would predict** — 3059.818 s (5.0997 rounds) closing at a round boundary (19:00) but on the *shadow's* request, not the round's. A rotation-derived width is therefore an **upper bound** whenever a second consumer shares the slot. Extends `2026-10-22-a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed` R1 with the width consequence it did not draw, and refines today's `2026-10-27-the-infeasible-pick-opens-the-gate-and-cannot-close-it` R1.

## R2 WITH TWO CONSUMERS THE PICK LINE IS NOT A LEDGER OF LOADS

Last label `60105`, counter `60109`, one acquisition at `19:01:13.616` — four counter positions and zero printed labels across the tick that closed the gate. The close is attributable only to record birth + capture birth + `/running` + the unit journal; the *pick label* is **unrecoverable**, and inferring it from `counter % 10` would be a five-way guess (`60106..60109` map to 4b, 4b, 4b, smol under the 6/3/1 weights, and three of them never printed). Rule: state the label as unrecoverable rather than reconstruct it — a labelled gap does not become a datum by arithmetic. (Instance of the gap class in `2026-10-21-a-falsifier-keyed-to-a-clock-cannot-distinguish-a-second-loader` R2 / `a-silent-consumer-leaves-a-gap-in-the-pick-log`; the increment is that the *unrecoverability* is the reportable fact, not the missing label.)

## R3 PRICE THE WINDOW IN THE SCOPE'S OUTPUT, NOT IN THE GATE

Across the whole open band the prediction lane wrote **nothing** — the previous row is `01:00:23.099366Z` and the next is `02:01:18.184476Z`: **3655.085 s (60.9348 min) with zero plans**, the entire window inside it. The close then bought **3 plans in 4.117 s** (`02:01:18.184476Z -> 02:01:22.301857Z`), and the 4B stayed resident (2631 free), so the "closed" line this tick reports is the productive state, not the constrained one. A day total quoted as "X % of the day available" is a statement about the card; the plans are the statement about the work. (Instance, not new: `2026-10-27-the-close-edge-is-a-burst-and-closed-outlives-the-card` R3.)

## Actions

**MESSAGES NONE**, both premises measured:

- **no @ocho** — `planner_at` never moved in this diff (identical `planner` both sides). His scoped-planner item is closed in **HIS** rows (`profiles/ocho/state.db` ids 9249 / 9267 / 16736, `max(id)=17405`); this record's holder is the same owner+need that has held since 2026-10-13 (`2026-10-14-the-closure-is-in-the-recipients-row`). A DM now would reopen a closed item to restate a lease that is 6 min old and already true.
- **no @llama** — CLOSE edge; 2631 free is 1658 MiB the wrong way, a page would assert a window false before and after latency (`2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` R1). He is self-authorised at `--scope arcade` under the operator precedence clause and no away-side artifact exists (`scopes/` = planner only, `lease.d/` absent, grep rc 1, no process) — absence of artifacts, not proof no raw load ran (scope records are deleted on release).

**RECORD ONLY**: no acquire, release, load, reservation, unit or config touched. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner/shadow units, both aux tenants and the driver were read-only. The `19:01:13` load was the shadow executor's own request through llama-swap; the five refusals were the timer's.

**STANDING FLAG FOR MIKE, RE-MEASURED `19:06`**: `profiles/llama/cron/` still has **NO `jobs.json`** (`.jobs.lock`, `.tick.lock`, `executions.db` 24576 B frozen `2026-10-12 06:33:07`, `output/` untouched since 10-12) while `ticker_heartbeat 1793153175.2890575` is rewritten `19:06:15` — a live clock over an empty job set. 50.997 min of an empty card above the gate and nothing executing the authorisation; an execution fact, not a Kev decision. This watcher creates no jobs.

## Prior art

Run **before** this file existed (`priorart.py rulings`, 512 records, two phrasings): max `REVIEW 0.204 2026-10-27-the-post-boot-window-closes-on-the-first-fitting-draw` (read; this is a second instance with a *non-rotation* closer), then `0.164 2026-10-27-the-hour-wide-window-closed-on-the-first-draw-that-fits`, `0.149 2026-10-21-a-falsifier-keyed-to-a-clock-cannot-distinguish-a-second-loader` (read; R2's gap class extended by R2 here), `0.141 2026-10-15-an-edge-already-dated-is-not-a-new-window`, `0.123 2026-10-27-the-close-edge-is-a-burst-and-closed-outlives-the-card` (R3 cited for R3 here); second phrasing max `weak 0.159 2026-10-26-a-latch-shorter-than-the-poll-and-a-window-open-beside-a-reservation`, `0.127 2026-10-19-a-reboot-opens-a-window-the-primary-slot-is-priced-out-of`, `0.116 2026-10-14-a-relayed-instruction-is-evidenced-by-its-quotation`. No record scores the case of a **fitting draw arriving from a consumer the rotation does not own** (R1) or the **unrecoverable pick label** (R2).

EVERY number is a disk read this tick: `nvidia-smi` ×3 + compute-apps, `bash arcade_window_watch.sh`, `stat %w/%i/%y`, `sha256sum`, `ps -o ppid,lstart`, `curl :8080/running`, `ss -ltnp`, `journalctl --user` (planner + shadow units), capture bodies, `model_cycle_counter.txt`, `ocho_predictions.jsonl`, `plans/latest_plan.json`, `llama-swap.log` tail, grep/pgrep, `priorart.py`.
