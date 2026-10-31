# A swallowed edge is re-readable from the sample that swallowed it

**Tick.** 2026-10-25 10:20:59–10:23 PDT — `arcade-window-watch`, job `67530e415818`, monitor sample
`monitor_last_output.txt` 36 B mtime `10:20` reading `planner_at=planner kev_window=closed`. Diff:
`planner_at=planner` **identical on both sides** ⇒ no `global->planner` flip, no @ocho DM (his
scoped-planner item closed on the 2026-10-23 10:40 4B certificate) · `kev_window=open -> closed`.

**Nature of the tick: RECORD ONLY.** No acquire, no release, no model load, no unit, no message.
Nothing under `~/NVIDIA-PAIR/ops-docs/scripts/`, `llama-swap.yaml`, the planner lease, the planner
unit or any model was touched; the live holder was read and left serving.

## The edge

* **Close** in `(10:09:52, 10:20:52]`: last suppressed sample `2026-10-25_10-09-52.md` (155 B,
  `no_change`, baseline then OPEN), this sample CLOSED at `10:20`.
* **Dated by the writer**, not by the sample: cell `scopes/planner/record.json` 495 B ino 9964817
  birth `10:20:13.633432601`, mtime `.635432576`, sha256 `f508e3d3be26a314373c39a4e3fdb3cc5c1e68374c7495ca42e23dadcae9bc9a`
  (two reads identical), `owner=llama-swap-ocho-planner-4b scope=planner class=batch need_mib=3800
  headroom_mib=256 pid=2243623 mode=run acquired_at=1792948813 expires 1793035213 ttl=86400`;
  wrapper **ALIVE** (`lstart` 10:20:12, ppid **2357 = llama-swap**) with resident child **2243722**
  GPU **3482 MiB**, `LISTEN 127.0.0.1:5806`, `:5806/health` = `{"status":"ok"}`, `:8080/running` =
  one entry `ocho-planner-4b state=ready ttl=0`; capture `/tmp/gpu-lease.cSpE3f` 1637 B birth
  `10:20:13.730431371` mtime `10:20:18.085376206` sha256
  `d1de8603a112d9b05f1509ce993438cdf3c9b8f9c8e2da5e974aa4147411b4bf`, loading
  `Qwen3.5-4B-UD-Q4_K_XL.gguf`, `model loaded` at `0.01.096.595`, ONE task 3152 prompt tok @
  2858.84 tok/s + 114 eval @ 96.86 tok/s, release `n_tokens = 3265 truncated 0`.
  ⇒ close bracket **`(10:20:13.6, 10:20:18.1]`**, the residency beginning with the acquire.
* **Open** in `(09:09:52, 09:25:50]` (closed baseline at `09:09:52`, OPEN at the `09:25:50` sample).
  The `09:10:06–09:10:13` round **loaded** a SmolLM3-3B (`/tmp/gpu-lease.HYYilU` 1642 B birth
  `09:10:12.875`, `listening :5808`) and exited `status=1/FAILURE` in the same second; a resident
  smol is ~2672 MiB (10-14's measurement) so with today's 1498 MiB aux floor + ~200 driver the card
  would read used ≈ 4370 ⇒ **CLOSED**, which is what the `09:09:52` baseline says. The only other
  writer in the bracket is the `09:20:09 → 09:20:13` round — **3.772 s wall / 3.146 s CPU, the
  shortest of the day, no capture in its minute** ⇒ it unloaded the smol, loaded nothing, and left
  the card empty. Earliest possible open `09:20:13`. **Width ∈ [54 m 23.6 s, 60 m 0.6 s].**

## The live card (three identical reads, 10:20:59 / 10:21:34 / 10:22:5x)

RTX 3060 Ti, 8192 MiB total: **used 5180 / FREE 2711 / util 0–1 % / 39–41 °C ⇒ CLOSED, 1578 MiB
under the 4289 gate** (4033 + 256, `arcade_window_watch.sh:47`). Apps: 1364 MiB pid 976745 (Bonsai,
`n-gpu-layers 0`, unowned) + 134 MiB pid 979586 (LFM2.5-VL, unowned) + **3482 MiB pid 2243722**
(planner 4B, owner=llama-swap) = 4980 + ~200 driver = 5180; used + free = 7891 against 8192 = the
standing ~301 MiB reservation. `gpu-lease.sh status` agrees: `lease.d/` **ABSENT**, `scopes/` =
planner only.

**Pre-load free, recovered by ADDITION rather than quoted:** `2711 + 3482 = 6193` ⇒ at the instant
the window shut, Kev-4B's admission need (4289) was met with **1904 MiB spare**, and the planner's
own admission (3800 + 256 = 4056) left **2137 MiB**, 2152 short of the gate. So `closed` at this
edge reports the **absence of the rung**, not a scarcity of capacity.

## R1 — A SWALLOWED EDGE IS DESTROYED AS A WAKEUP AND PRESERVED AS A RECORD

`2026-10-24-a-detected-change-is-consumed-by-the-run-that-fails-to-record-it` established that the
baseline is committed at detection (`cron/monitor.py:167`, before dispatch), so an edge seen by a run
that then fails is never re-alerted. Its 10-24 conclusion — *"destroyed, not queued"* — is correct
about the **wakeup** and too strong about the **record**: the failed sample file carries
`### Diff (previous → current)` and `### Current output` **verbatim**.

Measured today before this file was written: **50 samples, 14 carrying a `### Diff`, all 14 with
`RuntimeError: Hermes can't reach the model provider` in their `## Error` block, and
`grep -c '^2026-10-25' INDEX.md` = 0.** The day's entire window history was therefore unrecorded —
seven complete open/close cycles — while every edge sat readable in
`cron/output/67530e415818/2026-10-25_*.md`:

| samples | diff |
|---|---|
| 00:08 · 01:23 · 02:49 · 04:26 · 06:15 · 07:20 · 08:47 | open → closed |
| 00:46 · 01:49 · 03:27 · 05:15 · 06:53 · 07:47 · 09:25 | closed → open |

**RULE: the first run that reaches a model after a provider outage must replay the failed samples'
diffs before filing its own edge**, because a governance log that records only the edges whose wakeup
succeeded reports the window count of the model provider's uptime, not of the card. Corollary that
made the replay safe: the 15 diffs alternate perfectly (15/15, no repeated token), so the baseline
did commit on every failed run — nothing was double-filed and nothing collapsed two edges into one.

## R2 — THE WIDTH OF THIS WINDOW IS A FAILURE STREAK, NOT A PERIOD OF AVAILABILITY

Between the opener and the closer the timer ran five rounds — `09:30:13→09:30:17` (3.548 s wall /
3.168 s CPU), `10:00:09→10:00:16` (6.745 / 3.272), `10:10:05→10:10:11` (6.148 / 3.263) — **all
`status=1/FAILURE`, and no capture born in any of their minutes** (`/tmp/gpu-lease.*` births today:
`09:00:08`, `09:10:12`, then `10:20:13`). A refusal on an already-empty card has nothing left to
evict, so it is a **no-op on the token**: five consecutive failures that each could not change the
state are five silent votes for `open`. That is the dual of
`2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R2's empty-card case — there an empty
card kept the window open by failing to load, here it kept it open by having nothing to evict — and
it bounds `2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits` from the other side:
the rung that closes it may be the **fallback**, and the rung that would have closed it earlier kept
being refused. **Token stability across five samples is not stability in the system; it is the
ladder repeating a losing bid.**

## R3 — THE CLOSER'S ROUND FAILED IN THE SAME SECOND IT SERVED (third instance)

Journal `ocho-planner-polymarket.service`: `10:20:07 Starting → 10:20:18 status=1/FAILURE`,
**10.748 s wall (longest of the day) / 3.391 s CPU (highest)** / 142.2 M peak — while the capture
above shows the same round loading the 4B, serving a 3152-token prompt and releasing `n_tokens=3265`
inside that window. Third instance of the same-second rule
(`2026-10-24-an-eviction-inside-an-unsampled-band-opens-the-window-its-receipt-names-the-later-refusal`
R2, `…a-failed-rounds-duration-does-not-say-whether-it-evicted-a-resident` R1); what is new is the
**discriminator**: the rounds that loaded nothing (10:00, 10:10) left **no capture**, the round that
loaded and then failed left a **1637 B capture naming the model it loaded** — so a capture file dates
a load and its absence dates a refusal, while the exit code and the duration date only the round.
And the duration is falsified again in the same reading: today's longest wall (10.748 s) belongs to
the round that **did** load, exactly as 10-24's longest (18.802 s) belonged to one that did not.

## R4 — MEASUREMENT NOTES

* Pre-load VRAM is a **derived** quantity here, `live free + holder GPU MiB`, and quoting a previous
  sample's number instead (e.g. a remembered 6218) is a number, not a reading.
* GPU MiB and RSS kB are different instruments: child 2243722 reads `3482 MiB` in
  `--query-compute-apps` and `1466492 kB = 1432 MiB` in `ps` at the same instant. Quote them
  separately (repeats 10-24 R4).
* `planner_at=planner` was a **real holder** this tick on all three reads (record + wrapper pid alive
  + resident compute app) — not the dead-lessee class of `2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R1.

## Away side, and messages

Llama took **nothing** across the whole ~55–60 min at ≥ 4289 free: `grep -rliE 'arcade|kev|model-test'
~/.local/state/gpu-lease` rc 1, `lease.d/` absent, `scopes/` = planner only, no
`kev`/`model-test` process. His clock beats (`profiles/llama/cron/ticker_heartbeat` mtime 10:20:51,
`ticker_last_success` 10:20:51) over a directory with **no `jobs.json`** and `executions.db` 24576 B
stopped at 2026-10-12 06:33 — a beat certifies a clock, not an evaluation
(2026-10-21-a-heartbeat-is-not-an-evaluation); flagged to Mike, not a finding against him.

**MESSAGES NONE and none owed:** no @ocho (token identical both sides, his item closed), no @llama
(CLOSE edge — he self-runs under the precedence clause, and free 2711 is 1578 under his gate so a
page would be false at receipt; the fallback is defined for an **untaken open** window, and the open
edge at `09:25:50` was the tick whose wakeup the provider killed). The escalation channel is this
delivery to Mike, together with R1's actionable finding: **today's 14 edges are recoverable and this
filing records only the 15th.**
