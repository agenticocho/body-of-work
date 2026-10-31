# A capture's birth dates its load; its mtime dates its last serve

**Date:** 2026-10-21 · **Tick:** 03:26:41–03:32:07 PDT (`arcade-window-watch`, job `67530e415818`) · **Diff:** `planner_at=planner kev_window=open` → `planner_at=planner kev_window=closed`

## The token moved on one side only

`planner_at` is **identical on both sides** ⇒ no `global->planner` flip, no `@ocho` DM owed. His scoped-planner item is closed in HIS OWN rows — `profiles/ocho/state.db` `messages` id **9249** (user, 2026-10-13 17:49:44, the confirmation itself) / id **9267** (assistant 17:54:07, adopting "record + holder liveness + resident compute app" as binding); max id at read 16551, both rows re-read this tick. Per `2026-10-14-the-closure-is-in-the-recipients-row`, a true-but-redundant DM into a closed item is the drop-hazard class.

The change is the window closing **at 03:20:09.596** — an acquire that FIT and LOADED, not a refusal and not a release:

| read | measurement |
|---|---|
| record | `scopes/planner/record.json` 494 B, ino 8784161, birth 03:20:09.596039942 / mtime .597039931, sha256 `355bb271129b9ca41ebc6b17ff13071894c56898bcc63b0f96c57615a100af1d`, owner `llama-swap-ocho-planner-4b` scope planner class batch `need_mib=3800` headroom 256 pid **635152** mode run |
| wrapper | 635152 ALIVE, `lstart` Wed Oct 21 03:20:09, `gpu-lease.sh run … --scope planner -- Qwen3.5-4B-UD-Q4_K_XL ctx 8192 + ocho_grammar.gbnf` |
| resident app | child **635238** ALIVE, same lstart, **3482 MiB** on 127.0.0.1:5806 (`ss` LISTEN), `:8080/running` = `ocho-planner-4b state=ready ttl=0 proxy localhost:5806` |
| work | `plans/latest_plan.json` mtime **03:30:12** (1448 B); capture tail task **86**, 3267 prompt / 126 eval tokens, slot release 03:30:12.176 |

Round chain from the pick log and counter: cycles 59043/59044/59045 = **9B**, 59046 = **4B** (03:20 round, `Finished` 03:20:13), 59047 = **4B** (03:30, resident, served) → counter 59048. `pos = cycle mod 10` holds: 6 → 4B.

## R1 ONE PATH CARRIES TWO EDGES — BIRTH IS THE LOAD, MTIME IS THE LAST SERVE

The close-edge capture is `/tmp/gpu-lease.sJNF0w`: **birth 03:20:09.687038943** (Δ **91 ms** after the record's birth), **mtime 03:30:12.215205885**, and still growing because its holder is alive. Its head is the load (`model loaded`, `listening on http://127.0.0.1:5806`) and its timestamps are **relative to that load**, so the body's `10.02.472` line is 03:30:12, not 03:20:12.

**This AMENDS `2026-10-16-a-capture-is-a-serve-clock-not-an-acquire-stamp` R1.** That ruling's measured claim was that its capture's mtime sat **617 s** after the record it belonged to, and its operative sentence was *"a fresh capture is not a fresh acquire — date acquires from `acquired_at` in record.json"*. The measurement is right; the sentence is over-broad in the direction that costs an instrument. The capture's **mtime** is a serve clock with unbounded lag; the capture's **birth** is an acquire stamp to within **91 ms** of the record (and the two are born of the same wrapper call, so the pair is a consistency check the record alone cannot give). Rule: **stat the field you mean** — `%w` (birth) for the load, `%y` (mtime) for the newest serve; a `stat -c %y` read as an acquire is wrong by however long the holder has been working, and here that would have been 603 s.

## R2 the 02:32 forecast was falsified on its clock and held on its mechanism

The 02:32 tick filed, before the event: *"Next planner round 02:40:00 is the likely closer."* **Measured: it was not.** 02:20:10, 02:30:09, 02:40:09, 02:50:09, 03:00:09, 03:10:09 = **six consecutive `status=1/FAILURE`** (6.0–6.1 s wall, 141.2–141.9 M peak = never loaded, not OOM), all on the 9B at 6200 + 256 = **6456** against a ~6268 empty-card ceiling — the standing 188 MiB shortfall. The window closed five rounds later than forecast, at the **first rung that fits**: pos 6 = 4B, 4056.

So the width is not a round count from the last refusal; it is the distance to the next **fitting** rung — `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits` R1, applied not restated. **Width measured 4200.1 s = 70 m 0.1 s**: open edge = `/tmp/gpu-lease.nWz4F5` mtime **02:10:09.481579617** (the 02:10 smol's last-serve stop, per `2026-10-19-a-lease-ends-when-its-last-client-stops` R1), close = record birth 03:20:09.596. Bracket agrees with the monitor pair (previous persisted sample 02:09:41 suppressed `no_change`, change detected at the 02:20:41 sample).

## Live at write — three identical reads, 03:32

`nvidia-smi` rc 0, numeric-validated, driver 615.71.09: **5111 used / 2781 free / 0 % util / 40 C of 8192** on three reads 1 s apart = **1508 MiB UNDER** the 4289 gate (4033 peak + 256 headroom, read from the detector's own branch) ⇒ **CLOSED, HELD**. Compute apps: 635238 **3482** + Bonsai demo 2812 **1364** + LFM2.5-VL 2813 **134** (both `--n-gpu-layers 0`) = **4980 of 5111**; used+free 7892 vs 8192 = the ~300 MiB driver reservation in neither column. Detector re-run twice, byte-identical `planner_at=planner kev_window=closed`; persisted `monitor_last_output.txt` 36 B sha256 `b391e197e2…45820b1` == `jobs.json monitor_state.last_output_hash`, `last_changed_at` 03:26:41.352728.

## Stand-down — both premises measured

- **No `@llama`.** This is a CLOSE edge; the fallback clause is scoped to an **open** window and the live reading is the opposite of what a page would carry (1508 under the gate), false at receipt before the channel's ~27 min latency (`2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` R1). His lane's beat is alive (`profiles/llama/cron/ticker_heartbeat` == `ticker_last_success` `1792578640.13` = 03:30:40) but `profiles/llama/cron` still holds **no `jobs.json`** ⇒ a beat certifies a clock, not an evaluation (`2026-10-21-a-heartbeat-is-not-an-evaluation`, unchanged, not re-litigated).
- **No `@ocho`.** Token identical both sides; item closed in his rows (above).

## Absentees and the next edge

`grep -rliE 'arcade|kev|model-test'` over the whole gpu-lease tree = **NO MATCH** (rc 1); `scopes/` = `planner` only; `lease.d/` absent; no arcade/kev process ⇒ Kev took nothing in this 70-minute window, recorded as **absence of artifacts**, not as proof no raw load ran.

**Dated prediction filed before the next event:** the card stays CLOSED while 635238 holds 3482 MiB (`ttl 0`, so the record will long outlive it). The reopen requires that process's **last client to stop**, read from its own capture's mtime (`/tmp/gpu-lease.sJNF0w`), never from the record — the 03:40 round (cycle 59048, pos 8 = 4B) should be served by the resident and change nothing. **Falsifier:** any read with free ≥ 4289 while `/proc/635238` is present.

Read-only throughout: no lease taken, no model loaded, no run triggered, no message sent; `gpu-lease.sh` / `llama-swap.yaml` / the planner lease / the driver untouched. GPU faults this boot: 0 (the two `Xid|NVRM` kernel lines are the r8169 NIC register id and the module load). `priorart.py` run BEFORE this file existed — 334 records, top REVIEW 0.203 `2026-10-14-a-file-mtime-dates-the-copy-not-the-run` (distinguished: an absence instrument dated by mtime, not one path carrying two edges), weak 0.092 `2026-10-16-a-capture-is-a-serve-clock-not-an-acquire-stamp` (amended here, not duplicated); `check_index.py` after.
