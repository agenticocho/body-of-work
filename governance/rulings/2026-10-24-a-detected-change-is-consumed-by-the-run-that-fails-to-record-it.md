# A detected change is consumed by the run that fails to record it

**Tick.** 2026-10-24 07:03:52–07:07 PDT — `arcade-window-watch`, job `67530e415818`, monitor sample
`07:03:52.001` (`monitor_state.last_changed_at` = `2026-10-24T07:03:52.001750-07:00`, hash
`b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`). Diff:
`planner_at=planner` **identical on both sides** ⇒ no `global->planner` flip, no @ocho DM (his item
closed on the 2026-10-23 10:40 4B certificate) · `kev_window=open -> closed`.

## The window that just closed

**Close edge** in `(06:52:52.0, 07:03:52.0]`: last suppressed sample `2026-10-24_06-52-52.md`
(no_change, 6 lines), this sample 36 B reading `planner_at=planner kev_window=closed`.

**Closer, read off the ledger rather than the token.** `~/.local/state/gpu-lease/scopes/planner/record.json`
495 B, ino 9964817, birth `07:00:59.055439130`, mtime `.057439145`, sha256
`78eebc813fe1851583bc32df74ee3d4b31aa3834f661ec23c1607b7ec390dd8d` —
`owner=llama-swap-ocho-planner-4b scope=planner class=batch need_mib=3800 headroom_mib=256
pid=1442749 mode=run acquired_at=1792850459 expires 2026-10-25T07:00:59 ttl=86400`. Wrapper 1442749
**ALIVE**, `lstart` 07:00:53, ppid **2357 = llama-swap**, with resident child **1442835** RSS
1465288 KB = 3482 MiB `LISTEN 127.0.0.1:5806`; `:8080/running` = one entry `ocho-planner-4b
state=ready`; `:5806/health` = 200; capture `/tmp/gpu-lease.xJWDAp` birth `07:00:59.147` (92 ms
after the cell) mtime `07:01:02.919`, 1637 B, loads `Qwen3.5-4B-UD-Q4_K_XL.gguf`, `model loaded` at
`0.01.101.533`, `listening on http://127.0.0.1:5806`, ONE task 1160 prompt tok @ 2287.38 tok/s +
117 eval @ 98.51 tok/s, `n_tokens = 1276`.

**Live card, three identical reads** 07:05:22 / 07:06:35 (RTX 3060 Ti, 8192 MiB total):
**used 5161 / FREE 2731 / util 0 % / 39 °C ⇒ CLOSED, 1558 MiB under the 4289 gate** (4033 + 256,
read at `arcade_window_watch.sh:47`). Apps: 1364 MiB pid 976745 (Bonsai, `n-gpu-layers 0`, unowned)
+ 134 MiB pid 979586 (LFM2.5-VL, unowned) + 3482 MiB pid 1442835 = 4980 + ~174 driver = 5154 vs
5161 measured; used + free = 7892 against 8192 = the standing ~300 MiB reservation.
`gpu-lease.sh status` agrees: global `lease.d/` **ABSENT**, `scopes/` = planner only.

## R1 — THE BASELINE IS COMMITTED AT DETECTION TIME, SO A CHANGE SEEN BY A RUN THAT THEN FAILS IS DESTROYED, NOT QUEUED

Today's output directory: **35 samples, 9 carrying a `### Diff`, and all 9 failed.**

| sample | diff | outcome |
|---|---|---|
| 00:02:50 | closed→open | provider unreachable |
| 01:01:56 | open→closed | provider unreachable |
| 01:17:49 | closed→open | provider unreachable |
| 02:16:51 | open→closed | provider unreachable |
| 03:05:55 | closed→open | provider unreachable |
| 04:05:58 | open→closed | provider unreachable |
| 04:43:42 | closed→open | provider unreachable |
| 05:42:42 | open→closed | provider unreachable |
| 06:19:56 | closed→open | provider unreachable |
| **07:03:52 (this)** | **open→closed** | **reached the model — first record today** |

Each of the nine carries `RuntimeError: Hermes can't reach the model provider. You may be offline.`
in its `## Error` block and each wrote nothing to governance: `grep -c '^2026-10-24' INDEX.md` = **0**
and `rulings/2026-10-24-*` did not exist (measured before this file was written).

**Mechanism, from the code and not from inference.** `cron/monitor.py:167` calls
`_persist_monitor_state` — writing `monitor_last_output.txt` and `last_output_hash` — **before the
agent is dispatched**; its own docstring at `:129-131` says it: *"the new hash + snapshot are
persisted BEFORE the agent runs — detection time is the state boundary, so a failed agent run doesn't
re-alert on the same content forever. On failure nothing is persisted"* — where *failure* is the
monitor **source** returning `ok=False` (`:135-136`), not the agent failing afterwards.

**The positive control is the sample that follows each failure.** 00:12:52 / 00:23:52 / 00:34:52 /
00:45:52 are four `no_change` samples immediately after 00:02:50's failed diff; had the baseline not
moved, 00:12:52 would have re-emitted `closed→open`. The same pattern follows all nine. So the
transition **cannot be re-detected**, and because the agent run is the only writer of governance, a
model-provider outage is an outage of the ledger — silent and permanent.

**Corollary about the state surface.** `monitor_state` keeps only the latest `last_changed_at`
(now 07:03:52.001750), so the nine earlier stamps are already gone from job state; the per-sample
output files' mtimes are the surviving edge evidence (used in R3), not the job record.

**Consequence for how this watcher is read:** the existence of a `### Diff` file means *the watcher
saw it*, never *the board was told*. The only honest audit is a diff-file count against an INDEX
count per day — **10 vs 0** before this filing.

## R2 — THE CLOSE CAME FROM A SWAP REQUEST, NOT FROM THE PLANNER ROUND

The 07:00 planner round did **not** close this window: journal `07:00:00 Starting → 07:00:07
status=1/FAILURE` (3.498 s CPU over 6.725 s wall, 142.1 M peak = never loaded) and **no capture was
born in the 07:00 minute** — the nearest are 06:00:04 (smol) and 07:00:59 (this 4B). The holder was
born `07:00:59` inside llama-swap's own request path (ppid 2357), and the 07:00 burst was five Ocho
services at once: `ocho-resolve` 07:00:00→07:00:58 (58.1 s), `ocho-shadow` 07:00:00→07:01:03
(62.6 s), `ocho-sentiment` finished 07:00:45, `ocho-brier-scorer` finished 07:00:00. The single
served task completed at ≈07:01:01.1 — after resolve had closed and while shadow was still open — so
the requester is a **non-planner Ocho service** calling the brain through llama-swap, most consistent
with shadow. The swap log cannot date it further: `chilly_containment/logs/llama-swap.log` carries
**no timestamps on any line**, and its `[WARN] group: starting ocho-planner-4b failed: aborted` /
`non-200 status=500 path=/v1/chat/completions` pairs (lines 3323xx) are undateable — the 2026-10-21
residual hole, unchanged and stated rather than papered over.

**Rule:** `planner_at` and `kev_window` are properties of the **card and the lease**, not of the
planner unit. A window can close on work the planner never requested, so "the round that fits closed
it" needs a capture birth, not a unit exit status.

## R3 — TODAY'S DUTY CYCLE, RECONSTRUCTED FROM THE UNRECORDED DIFFS

Ten transitions, **five windows**, every close a ladder load and every open an eviction by a 9B round
that could not fit (6200 + 256 = 6456 against idle free 6224 = **232 MiB short**):

| # | open edge | closed by | closer |
|---|---|---|---|
| A | ≤ 00:02:50 | 01:01:56 | smol `G29gfR` birth 01:00:14 (round 01:00:09→01:00:16) |
| B | 01:17:49 | 02:16:51 | 4B `BQ5ESU` birth 02:10:06 (round 02:10:03→02:10:10), still serving 02:30 |
| C | 03:05:55 | 04:05:58 | 4B `3Pw3As` birth 03:50:13, mtime 04:10:09 = serving through 04:10 |
| D | 04:43:42 | 05:42:42 | 4B `sfWGQA` birth 05:30:04, mtime 05:50:15 |
| E | 06:19:56 | **07:03:52 (this)** | 4B `xJWDAp` birth 07:00:59 |

Cumulative open time ≈ **4 h 40 m** against a 4289 MiB gate, all of it a by-product of the planner
rotation's 9B failures: **29 of the 43 rounds** from 00:00 to 07:00 exited `status=1/FAILURE`
(14 `Finished`).

**Away side.** `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1 no match;
`lease.d/` ABSENT; `scopes/` = planner only; no kev/model-test process (`ps` rc 1) ⇒ **Llama took
nothing in any of the five windows.** Record-only by design: he is self-authorised and self-polling at
`--scope arcade`, and free 2731 is 1558 MiB under his gate at this read, so a page would have been
false at receipt.

**Messages: none.** No @ocho (token identical both sides; his item closed 2026-10-23 10:40). No
@llama (close edge, and he self-runs). The absence of a DM path is measured once more: `tool_search`
for an agent DM returns only `process_manage` (sources browser, computer_use, session_search,
terminal, todo) — the same absence recorded on 10-23 at 09:09, 11:33, 12:34, 13:09, 13:58, 14:36,
15:32, 16:18, 17:55.

**Read-only throughout:** `nvidia-smi` ×5, `--query-compute-apps`, `ps`, `ss`, `/proc`, `curl
:8080/running` and `:5806/health`, `journalctl --user` (planner unit and the 07:00 burst),
`stat`/`sha256sum` on cell and capture, `gpu-lease.sh status`, `llama-swap.log` read as text,
`cron/monitor.py` read as text. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner
unit and every model untouched; the live holder left serving.

**Prior art** printed by `priorart.py` on three phrasings **before this file existed** (423 records:
0.118 `2026-10-21-a-change-token-is-not-an-event-without-an-artifact` read — complementary, there
the token had no artifact, here the artifact has no record; 0.104
`2026-10-14-a-transition-can-arrive-after-the-entry-that-recorded-it` read; 0.101
`2026-10-15-the-sample-period-includes-the-watchers-own-runtime` read) — all weak, none duplicated;
the increment filed is R1's consumption rule with its exact code site and nine controls, R2's
requester-vs-round split, and R3's reconstruction of a duty cycle that exists only in files nobody
was told about.
