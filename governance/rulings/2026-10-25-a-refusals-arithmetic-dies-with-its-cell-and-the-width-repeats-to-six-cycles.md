# a refusal's arithmetic dies with its cell, and a width in whole round periods reproduces

**TICK 2026-10-25 12:05:52–12:07 PDT (arcade-window-watch, job `67530e415818`), diff = ONE field `kev_window=open->closed`, `planner_at=planner` IDENTICAL both sides so NO `global->planner` branch and NO `@ocho` DM (his scoped-planner item closed on the 2026-10-23 10:40 4B certificate, unchanged).**

Nature of the tick: **RECORD ONLY.** No acquire, no release, no load, no unit change, no message. Llama remains SELF-AUTHORISED to acquire Kev-4B at `--scope arcade` on his own poll; this watcher does not trigger him and did not page him.

## Edge: bracketed by the samples, dated by the writer

- Last persisted sample `cron/output/67530e415818/2026-10-25_11-54-52.md`, 155 B, mtime `11:54:52.061408458`, `no_change` on the OPEN baseline (11:21:52 / 11:32:52 / 11:43:52 / 11:54:52 all 155 B `no_change`).
- `monitor_last_output.txt` 36 B, mtime `12:05:52.023382055`, reads `planner_at=planner kev_window=closed` ⇒ **bracket (11:54:52.061, 12:05:52.023]**.
- Inside that bracket only ONE load attempt was made and it left a capture: `/tmp/gpu-lease.EGjJyQ` birth `12:00:12.469070374` (previous capture birth, `/tmp/gpu-lease.fMngKx` `10:50:10.584950245`, 69 min earlier). So the close is dated **12:00:12.469 → 12:00:17.022** (birth → last task release), not left at the bracket.

## The closer, named on four legs

`~/.local/state/gpu-lease/scopes/planner/record.json` — 495 B, ino 9964817, birth `12:00:12.374070405`, mtime `.375070405`, sha256 `ad8485e2cb761ed6134054c2de41fb30010b378f77d45d002af5ed32062b4d66`:

```
owner llama-swap-ocho-planner-4b · scope planner · class batch · need_mib 3800 · headroom 256
pid 2294401 · mode run · acquired_at 1792954812 · expires_at 1793041212 · ttl 86400
```

1. **Wrapper alive**: pid 2294401, `bash …/gpu-lease.sh run --owner llama-swap-ocho-planner-4b --class batch --scope planner --need-mib …`.
2. **Resident child**: pid 2294487 **3482 MiB** in `--query-compute-apps`, `--port 5806 --model …/Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192`.
3. **Capture** `/tmp/gpu-lease.EGjJyQ` 1637 B, birth `12:00:12.469070374`, mtime `12:00:17.022068687`, sha256 `b205613e528f101a0ff6bf9dbb1adcb059a43db36e92ccd3a1ac23d1b993e5c6`: `model loaded` at `0.01.108.982`, `listening on http://127.0.0.1:5806`, ONE task — 3320 prompt tok @ 2873.11 tok/s + 128 eval @ 96.77, `n_tokens = 3447, truncated = 0`.
4. **`/running`**: one entry, `ocho-planner-4b state=ready ttl=0`; `gpu-lease.sh status` agrees (`pid 2294487 3482 MiB llama-server owner=llama-swap`, `lease.d/ none held`, scopes = planner only).

Journal `ocho-planner-polymarket.service`: **12:00:06 Starting → 12:00:17 Finished**, `Consumed 3.225s CPU time over 10.660s wall clock time, 142.4M memory peak` — the only **exit-0** round in the open band.

## Live card (two identical reads, 12:05:5x / 12:06:0x)

| total | used | free | util | temp | gate 4289 (4033+256) |
|---|---|---|---|---|---|
| 8192 | 5180 | **2711** | 1 % | 39 C | **CLOSED by 1578** |

Apps: 976745 Bonsai 1364 (unleased, `--n-gpu-layers 0`) + 979586 LFM2.5-VL 134 (same) + 2294487 planner 3482 = 4980, + ~200 driver = 5180. `used+free 7891 vs 8192` = the standing ~301 MiB reservation (instrument note, unchanged).

Pre-load free **derived, not remembered**: `2711 + 3482 = 6193`. Against that, 9B `6200+256=6456` was **263 SHORT**, 4B `3800+256=4056` **2137 SPARE**, Kev `4033+256=4289` **1904 SPARE**. So at the closing pick the card was wide open for the acquirer and one rung short for the ladder's primary — `closed` here reports the absence of the fitting rung, not scarcity.

## The open band's five refusals, and what happened to them

Journal, all `status=1/FAILURE`, none with a capture born in its minute:

| round | wall | CPU | peak |
|---|---|---|---|
| 11:10:06→11:10:12 | 6.037 s | 3.117 s | 141.7 M |
| 11:20:08→11:20:14 | 5.845 s | 3.118 s | 141.9 M |
| 11:30:13→11:30:20 | 6.683 s | 3.094 s | 141.4 M |
| 11:40:00→11:40:06 | 6.379 s | 3.102 s | 142.1 M |
| 11:50:01→11:50:07 | 6.134 s | 3.104 s | 142.1 M |
| **12:00:06→12:00:17** | **10.660 s** | **3.225 s** | **142.4 M** (exit 0, capture) |

Every one of the five refusals rewrote the single record cell, and the sixth (the holder) rewrote it again. The cell that stood at the open edge — `6200` need, pid 2263887 DEAD, `6456 vs 6198 free = 258 short`, born `11:00:08.091455053`, sha256 `3bca77bb…` — is **gone from disk**; its numbers survive only because the 11:07 tick copied them into `INDEX.md`. Nothing on disk now says what rungs 11:10–11:50 bid.

## Rulings

**R1 — A width that lands on an integer number of round periods is a schedule reading, and it reproduces.** Open edge at the refusal cell's birth `11:00:08.091455053`, close at the holder's capture birth `12:00:12.469070374`:

```
3604.3776 s = 6 × 600 s + 4.3776 s
```

The residual is not slack in the rule, it is the within-round offset of the two writers: the closing cell was born `6.374 s` and the capture `6.469 s` after `Starting 12:00:06`, while the opening cell was born `8.091 s` after `Starting 11:00:00`. Six rounds, ten minutes each, one fitting rung. This **reproduces** `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits` R1 — filed there as a single measurement, six cycles / **59 m 47 s (3587 s)** — to **17.4 s** on an independent window, and it reproduces the mechanism of `2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits` R1 (for free in [4056, 6456) the 9B must fail and the 4B fits; the exit is a discrete pick, not a capacity event). **Stated so it can be falsified**: the six-cycle count is conditional on the live free band staying in [4056, 6456) — measured here at 6193–6198, i.e. 263–258 under the 9B's 6456 and 2137 over the 4B's 4056. Move free above 6456 and the width collapses toward one cycle; move it below 4056 and the window cannot close at all. The reproducible part is `k × 600 s + within-round offsets`, never a duration in minutes.

**R2 — A refusal's arithmetic dies with its cell; only its count survives.** `2026-10-23-a-scope-record-is-one-cell-written-only-by-attempts-that-reached-the-wrapper` established last-writer-wins in the **holder-over-refusal** direction; this band demonstrates the **refusal-over-refusal** direction, and the consequence is stronger than bookkeeping: five refusals in sixty minutes left *no* need, *no* pid and *no* capture behind, because a refusal by construction loads nothing and so writes no capture, and the next minute's refusal overwrites its only other cell. What is recoverable after the fact is the **count** of attempts (journal) and their wall/CPU/peak — never the rung or the deficit. Therefore the OPERATIONAL rule for this watcher: **a tick that reads a refusal cell must copy the cell's need, headroom and pid into its own report**, because the next round deletes them; a report that says only "refused" throws away the one fact the next round will destroy. Corollary for reading the token: `kev_window` is a live reading and is reconstructible, but *"why was this window this wide"* is reconstructible only from the tick reports and the journal, never from the lease tree.

**R3 — The close edge's `planner_at=planner` was a live holder on all four legs, and the sign of the closure is the planner's while its width is not.** Unlike the refusal-class latch (`2026-10-24-a-silent-release-failure-keeps-the-planner-latch`, five prior instances), the token here was supported by a live wrapper, a live resident, a served task and `state=ready` — a residency that outlived its own round (`ttl 86400`, round finished 12:00:17, holder still serving at 12:05). Removing only the planner holder returns 6193 free = **1904 spare**; removing only the unleased Bonsai tenant (1364) returns 4075 = **still 214 short** of the gate. So the SIGN belongs to the planner's 4B holder and an unleased tenant 1364 MiB wide could not have opened the gate on its own — the decomposition of `2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits` R2 (**188** short there, **214** here) reconfirmed, not re-filed.

## Away side: eighth window today, still zero acquisitions

`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` → **rc 1, no match**; `scopes/` = planner only; `lease.d/` absent; no `arcade`/`kev`/`model-test` process (`ps` rc 1). Llama's clock beats (`ticker_heartbeat` 24 B, `ticker_last_success` 18 B, both `12:05:51`) over a directory with **no `jobs.json`** and `executions.db` 24576 B stopped at 2026-10-12 06:33 — a beat certifies a clock, not an evaluation (flagged to Mike previously; not a finding against him). His gate was met with 1904 MiB spare for the whole 60 m 4 s and he took nothing; recorded as ABSENCE.

## Messages: none, and none owed

- **@ocho — withheld.** The diff carries no `planner_at global->planner` transition (identical token both sides) and his scoped-planner item closed on the 2026-10-23 10:40 4B certificate. A true-but-redundant DM into a closed item is the drop hazard.
- **@llama — withheld.** This is the `open->closed` edge; the fallback clause is defined for an untaken OPEN window and he self-runs under the precedence clause. Free is now 2711, i.e. **1578 MiB under his gate**, so an "open" page would be FALSE at receipt.
- Mechanically the DM path is also absent in this cron toolset (deferred catalog: browser, computer_use, session_search, process_manage, todo_list — no agent-messaging tool), the same absence recorded on 09:09, 11:33, 12:34, 13:09, 13:58, 14:36, 15:32, 16:18, 19:54 and 11:09. The escalation channel is this delivery to Mike.

## Observation outside the band (no token movement)

`ocho-field.service` **12:01:33 Starting → 12:03:33 `status=1/FAILURE`** — after the close, loaded nothing, and the card read the same 2711 free at 12:05:52, so it changed neither the token nor the residency. Noted for the operator only.

## Touch log

READ-ONLY throughout: `nvidia-smi` (memory/util/temp ×3) + `--query-compute-apps`, `date`, `ps` (pid/ppid/cmdline), `/proc` liveness checks, `curl :8080/running`, `journalctl --user` for `ocho-planner-polymarket.service` and the 11:00–12:06 Ocho burst, `stat`/`sha256sum` on the cell and the capture, `ls -l --time-style=full-iso /tmp/gpu-lease.*`, the lease tree, `gpu-lease.sh status`, the cron output dir and `monitor_last_output.txt`, `arcade_window_watch.sh` read as text, `profiles/llama/cron` inventory. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner unit and every model **untouched**; nothing acquired, released or loaded; the live holder left serving.

Prior art printed by `priorart.py` on three phrasings BEFORE this file existed (432 records: 0.482 REVIEW `2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits` read in full and its R1 cited as the RULE this tick reproduces, R2's decomposition reused with today's numbers; 0.291 REVIEW `2026-10-14-a-window-that-is-a-rung-of-a-rotation` read, superseded on width by 10-19; 0.205 REVIEW `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits` read in full — R1 is the rule being REPRODUCED to 17.4 s, not re-filed; 0.221 `a-window-that-is-a-rung-of-a-rotation`; 0.176 `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`; 0.150 `2026-10-19-a-refusal-inside-the-loop-is-not-an-admission-check`; 0.125 `2026-10-23-a-scope-record-is-one-cell-written-only-by-attempts-that-reached-the-wrapper` read as R2's parent and EXTENDED to the refusal-over-refusal direction with the copy-it-out consequence) and read by eye. Increment filed = R1's quantisation-with-residual reading plus the falsifier band, R2's refusal-over-refusal erasure with the operational copy rule; R3 is a positive control against the dead-lessee class.
