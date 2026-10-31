# a fitting rung is not a load, and a window across a failure streak is not an opportunity

**TICK 2026-10-25 16:00:57–16:04 PDT (arcade-window-watch, job `67530e415818`), diff = ONE field `kev_window=open->closed`, `planner_at=planner` IDENTICAL both sides so NO `global->planner` branch and NO `@ocho` DM (his scoped-planner item closed on the 2026-10-23 10:40 4B certificate, unchanged).**

Nature of the tick: **RECORD ONLY.** No acquire, no release, no load, no unit change, no message. Llama remains SELF-AUTHORISED to acquire Kev-4B at `--scope arcade` on his own poll; this watcher does not trigger him and did not page him.

## Edge: bracketed by the samples, dated by the writer

- Last persisted sample `cron/output/67530e415818/2026-10-25_15-49-52.md`, 155 B, `no_change` on the OPEN baseline. Four persisted `no_change` samples sit on that OPEN baseline: `15-16-52`, `15-27-52`, `15-38-52`, `15-49-52`; the OPEN edge itself was detected by the `2026-10-25_15-06-38.md` run, whose own diff was `kev_window=closed->open`.
- `monitor_last_output.txt` 36 B, mtime `16:00`, reads `planner_at=planner kev_window=closed` ⇒ **bracket (15:49:52, 16:00:57]**.
- Inside that bracket exactly ONE cell was written: `scopes/planner/record.json` 495 B, ino `9966362`, birth **`16:00:15.626002776`**, mtime `.627002759`, sha256 `88d93dfa8ebb64f28456fbadb7d71fe4df38d5a920c793a96e814471a2ffb02a`. So the close is dated **16:00:15.626**, not left at the bracket.

## The closer: the planner's own successful round, on four legs

- **Cell:** owner `llama-swap-ocho-planner-4b`, scope `planner`, class `batch`, `need_mib` **3800**, `headroom_mib` 256, `pid` **2473180**, `mode` `run`, `acquired_at` 1792969215 (`16:00:15`), `expires_at` 1793055615 (`2026-10-26T16:00:15`), ttl 86400, liveness-first policy text unchanged.
- **Wrapper ALIVE:** pid 2473180, `bash …/gpu-lease.sh run --owner llama-swap-ocho-planner-4b --class batch --scope planner --need-mib 3800 --ttl 86400 -- …/llama-server --port 5806 --model …/Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file …/ocho_grammar.gbnf`, PPid 2357 (llama-swap), lstart 16:00:14.
- **Child resident:** pid 2473266 `llama-server` lstart 16:00:14, **3482 MiB** in `--query-compute-apps`, RSS **1466340 kB** (quoted separately — see R4), `:5806/health` → `{"status":"ok"}`, `/running` → `ocho-planner-4b` `state=ready` `ttl=0`.
- **Capture served a task:** `/tmp/gpu-lease.T8UR0x` 1637 B, mtime `16:00:20.455923249`, `model loaded 0.01.105`, listening `127.0.0.1:5806`, task 0 **3862 prompt tokens @ 2929.13 tok/s**, eval 129 tok, total 2.641 s, release at `0.04.677` — a loader that used the card, not a load-in-wait of one.
- **Journal:** `16:00:09` Starting → `16:00:20` **Finished** (exit 0), 3.186 s CPU / 11.084 s wall / 142.2 M — the **first success after seven consecutive `status=1/FAILURE` rounds** (`14:50:15`, `15:00:07`, `15:10:10`, `15:20:15`, `15:30:20`, `15:40:07`, `15:50:11`; wall 5.998–6.079 s, CPU 3.072–3.074 s on every one).

## The band that was open, and what was actually in it

- **Open edge:** bracket (14:50:52, 15:06:38]. The only actor inside is the `15:00:00→15:00:07` failed round; the last load before it is the 14:50 round's capture `/tmp/gpu-lease.sCBWby` 1642 B, mtime `14:50:15.007686539` (smol on `:5808`). So the window opened when a failing round took the resident and put nothing back — the 10-24 eviction pattern, not a release.
- **Width:** `15:00:07 → 16:00:15.626` = **60 m 08.6 s** = six 600 s round periods + 8.6 s. Integer-period width again (seventh instance of `2026-10-25-a-refusals-arithmetic-dies-with-its-cell-and-the-width-repeats-to-six-cycles` R1), now closed by a `status=0` round.
- **Capture census across the band:** NO capture born between `sCBWby` (`14:50:15.007686539`) and `T8UR0x` (`16:00:15`). Six consecutive failed rounds (15:00, 15:10, 15:20, 15:30, 15:40, 15:50) put **no model at all** on the card — `llama-swap.log` (no timestamps) ends in six `group: starting ocho-planner failed: upstream command exited prematurely` / `failed: aborted` pairs followed by one `<ocho-planner-4b> Health check passed`.
- **Free VRAM in the band:** post-load free 2619 + the load's 3482 = **≈6101 MiB free** before the 16:00 load, consistent with the open token (open only requires used ≤ 3903; the aux floor Bonsai 1466 + LFM2.5-VL 134 + ~190 driver + ~301 reservation = 2091 used). Against that band: the **4B rung 3800+256 = 4056 fits with 2045 MiB spare**, the **9B rung 6200+256 = 6456 is 355 MiB short**.

## Rulings

**R1 — A RUNG THAT FITS IS NOT A RUNG THE LADDER PICKS, AND A CAPTURE-LESS FAILURE IS NOT A REFUSAL.** Six consecutive rounds left no capture on a card holding ≈6101 MiB free while the 4B rung's admission need (4056) was met with 2045 MiB to spare, so "free ≥ the smallest rung's need" predicts nothing about whether a load happens. And because a refusal's arithmetic dies with its cell (12:05 R2), the rung each of those rounds failed on is **unreadable now** — the same inode carries the 16:00 live 4B holder — so the only supportable sentence about the band is *nothing loaded*, and filing it as "six refusals" would be an invented mechanism with a memory's confidence. DISTINGUISHED from the 0.214 prior `2026-10-25-a-failure-streak-flips-the-window-by-rung-admission`: there the fitting rung **did** load inside the streak (10:50 smol) and the misleading field was the exit code; here the fitting rung is idle for six periods with no load at all, so admission arithmetic is not merely uninformative about the token — it is insufficient to explain silence, and the failure must be sought in the wrapper/launcher path, not in the arithmetic.

**R2 — THE INTEGER-PERIOD WIDTH SURVIVES A `status=0` CLOSER.** 3608.6 s = 6×600 + 8.6, and the closer this time is the primary's own **successful** load with a live wrapper, live child, served task and `state=ready` — the opposite sign from 12:05's refusal-then-holder band and the same width law. Extends 12:05 R1 by one closer class: the width is a schedule reading regardless of who closes, so it is the last quantity that may be quoted as capacity evidence.

**R3 — A WINDOW THAT SPANS A FAILURE STREAK IS NOT AN UNTAKEN OPPORTUNITY, AND THE LOG MANUFACTURES ONE UNLESS IT CARRIES THE STREAK.** Any future scan of the token log sees this band as four `no_change` samples on an OPEN baseline (15:16:52 → 15:49:52) plus the 15:06 open tick — i.e. “over half an hour of eligibility nobody took” — while its content was **seven consecutive failed rounds and zero loads**. Rule: when `kev_window=open` persists across more than one round boundary, the record must quote free VRAM **with the capture count and the round statuses across the band**; an eligibility interval is only evidence of an opportunity if the primary's own round was at least able to use it.

**R4 — QUOTE GPU MiB AND RSS kB SEPARATELY.** Child 2473266 reads **3482 MiB** in `--query-compute-apps` and **1466340 kB RSS** at the same instant; earlier filings still phrase VmRSS kB as VRAM MiB (the 10-24 R4 correction), restated here because the two numbers are 2.4× apart and one of them is not VRAM.

## Live card at write

Three identical reads `16:01:xx–16:03:33`: **8192 total / 5272 used / FREE 2619 / 1 % / 39 C** ⇒ **CLOSED, 1670 MiB under the 4289 gate**. Apps: 976745 Bonsai **1466** + 979586 LFM2.5-VL **134** (both unleased, n-gpu-layers 0) + 2473266 planner **3482** = 5082 + ~190 driver = 5272; used+free 7891 vs 8192 = the standing ~301 MiB reservation; `lease.d/` ABSENT, `scopes/` = planner only.

## Away side (Llama)

`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` → rc 1, no match; `scopes/` = `planner` only; `ps -eo pid,etimes,args | grep -Ei 'kev|arcade|model-test'` → rc 1 no match ⇒ **LLAMA TOOK NOTHING across the whole 60 m 08.6 s at free ≈6101, 2045 MiB above his 4289 gate.** His clock still beats — `profiles/llama/cron/ticker_heartbeat` `1792969311.072467` (16:01:51), `ticker_last_success` `1792969313` — over a directory with **NO `jobs.json`** and `executions.db` 24576 B stopped at `2026-10-12 06:33`: a beat certifies a clock, not an evaluation (`2026-10-21-a-heartbeat-is-not-an-evaluation`). Flagged to Mike, not a finding against him. The window closed before this write, so a fallback page would be **false at receipt** (free 2619 vs gate 4289) and the close branch owes none.

## Messages

**NONE, and none executable.** No `@ocho` — token identical both sides, his scoped-planner item closed on the 2026-10-23 10:40 4B certificate, cell owner/need shape unchanged (3800 + 256). No `@llama` — close edge, he self-runs, gate not met at receipt. Re-measured this tick: `tool_search` "send message to another agent DM bot" → **no matches** (available sources browser, computer_use, session_search, terminal, todo), the same absence recorded 10-23, 10-24 and earlier today ⇒ the escalation channel is this delivery to Mike.

## Measurement / touch log

READ-ONLY throughout: `nvidia-smi` x5 (three at write) + `--query-compute-apps` x2, `ps -o pid,lstart,rss,args`, `/proc/{2473180,2473266}/status` + cmdline, `curl :8080/running`, `curl :5806/health`, `journalctl --user -u ocho-planner-polymarket.service` (window, day-wide status streak, 15:58–16:01 burst across all six Ocho units), `stat`/`sha256sum` on the cell, the capture and the cron samples, the lease tree, `arcade_window_watch.sh` read as text, `profiles/llama/cron` inventory; `gpu-lease.sh`, `llama-swap.yaml`, the planner lease/unit and every model **untouched**; the live 4B holder left serving.

Prior art printed by `priorart.py` on two phrasings BEFORE this file existed (corpus of `rulings/`): max **REVIEW 0.214 `2026-10-25-a-failure-streak-flips-the-window-by-rung-admission`** read and DISTINGUISHED in R1, then weak 0.158 `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`, 0.139 `2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name`, 0.108 `2026-10-14-a-window-that-is-a-rung-of-a-rotation`; second phrasing max weak 0.084 `2026-10-19-a-window-that-cannot-close-because-its-closer-no-longer-fits`, 0.083 `a-reboot-opens-a-window-the-primary-slot-is-priced-out-of`, 0.082 `a-drain-by-another-tenant-manufactures-the-window`. No duplicate. Increment filed: R1's capture census against a fitting rung (with the refusal-attribution refused), R2's seventh integer-period width under a `status=0` closer, R3's manufactured-opportunity rule for the token log, R4's repeated VRAM-vs-RSS correction.

RULINGFILE rulings/2026-10-25-a-fitting-rung-is-not-a-load-and-a-window-across-a-failure-streak-is-not-an-opportunity.md
