# 2026-10-24 — an eviction inside an unsampled band opens the window, and its only receipt names the later refusal

## TICK

`arcade-window-watch`, job `67530e415818`, 2026-10-24 19:50:59–19:54 PDT (America/Los_Angeles).

Diff = ONE field: **`kev_window=closed -> open`**. `planner_at=planner` on BOTH sides, so no
`global->planner` branch and **no @ocho DM** (his scoped-planner item was closed on the 2026-10-23
10:40 4B certificate and is re-read closed below in his own rows).

**NATURE: RECORD ONLY.** No acquire, no release, no load, no unit touched, no model touched, no
message sent.

## THE EDGE, AND WHAT DATED IT

- Last persisted sample: `cron/output/67530e415818/2026-10-24_19-39-52.md`, 155 B, `no_change`,
  baseline **CLOSED**. (Previous, `_19-28-52.md`, 155 B `no_change`, also CLOSED.)
- `monitor_last_output.txt` 34 B, **mtime 19:50:52.034087360**, reads `planner_at=planner
  kev_window=open`.
- Therefore the edge lies in **(19:39:52.068, 19:50:52.034]** — an unsampled band of 11 m 0 s.

Two planner rounds fall inside that band, and **both are 9B refusals that loaded nothing**:

| round | journal | wall | CPU | peak | capture born that minute |
|---|---|---|---|---|---|
| A | 19:40:13 → **19:40:19 `status=1/FAILURE`** | 6.035 s | 3.086 s | 142 M | **none** |
| B | 19:50:01 → **19:50:07 `status=1/FAILURE`** | 5.908 s | 3.101 s | 142.6 M | **none** |

(For scale, the earlier rounds in the same stretch: 19:30:10 → 19:30:18 FAILURE, 8.491 s / 3.191 s /
141.6 M, and it *did* leave a capture — see R2.)

The only lease artifact on disk is the **later** one:

```
scopes/planner/record.json   492 B   ino 9964817   birth 19:50:07.075599451   mtime 19:50:07.077599422
sha256 cca2868ccc79cf29016a9b146d1af3ba12aa9d612f46a55069c4f3abce4ec281     (two reads, identical)
owner=llama-swap-ocho-planner  scope=planner  class=batch  need_mib=6200  headroom_mib=256
pid=1836285  mode=run  acquired_at=1792896607 (19:50:07)  expires_at=1792983007  ttl=86400
pid DEAD (ps rc 1, absent from --query-compute-apps)
```

**It is a refusal receipt, and it refuses itself by arithmetic:** 6200 + 256 = **6456** vs free
**6218** = **238 MiB SHORT**. Nothing was loaded by the round that wrote it, so the cell cannot be
the thing that opened the window — yet the window is open, which means **something that had been
resident was unloaded inside that band and nothing replaced it.**

The resident is in the ledger, and the closed sample proves it was there at 19:39:52:

- `closed` requires `free < 4289`, i.e. **used > 3903**; the unleased aux floor is only
  1 498 MiB (976745 Bonsai 1 364 + 979586 LFM2.5-VL 134) + ~175 driver = **1 673**, so **at least
  2 230 MiB of leased/resident tenant** was on the card at 19:39:52.
- Candidate 1 — the 4B retainer: capture `/tmp/gpu-lease.zoBFLt`, 3 214 B, ino 18684, **birth
  19:01:12.961040324, mtime 19:20:08.630903224** = Qwen3.5-4B-UD-Q4_K_XL, tasks 0 / 109 / 239, last
  task released **19:20:08.63**. No capture activity after that, and wrapper 1811146 / child 1811233
  are now **gone from `ps`**.
- Candidate 2 — the 19:30 smol: capture `/tmp/gpu-lease.iMUH9l`, 1 642 B, ino 18687, **birth
  19:30:16.483846639, mtime 19:30:18.848792334** = SmolLM3-3B-128K-UD-Q4_K_XL, `model loaded`,
  listening on **:5808**, **task 0** 3 139 prompt tok @ 5 044.13 tok/s + 90 eval, released
  n_tokens 3 228 truncated 0.
- Both are consistent with a single closed sample; neither survives today. **Which one held the card
  at 19:39:52 is not established by any artifact on disk and is not asserted here.**

What *is* established: **the first of the two refusals is the only one that had anything to evict**
(a card already empty at 19:40:13 leaves round B nothing to free), so the earliest possible opener
is **19:40:19** and the cell dates only the **latest** writer, 19:50:07. The window is therefore
**bracketed, not dated**, and the one artifact that would have dated it was overwritten by the second
refusal on the same inode.

## LIVE CARD (three byte-identical reads 19:50:59 / 19:51:0x / 19:53:57, re-read at write)

```
8192 total / 1673 used / FREE 6218 / 0–1 % / 39 °C    => OPEN by +1929 over the 4289 gate (4033+256)
apps: 976745 Bonsai 1364 + 979586 LFM2.5-VL 134 = 1498 (both unleased, n-gpu-layers 0) + ~175 driver
used+free = 7891 vs 8192 = the standing ~301 MiB reservation
/running {"running":[]}   listeners: 127.0.0.1:8080 llama-swap pid 2357, 127.0.0.1:58595 Bonsai 976745
NOTHING on 5800–5829  =>  the planner ladder's retainer is gone and the card is EMPTY
```

Two gates, one reading: **238 MiB short** for the planner's 9B rung, **1 929 MiB spare** for Kev-4B
(3800 + 256 = 4056 vs 6218 = **2 162 spare**). `kev_window=open` carries no information about
scarcity — this card is simultaneously too small for the planner's own pick and far too large for
that refusal to matter to Kev.

## RULES

**R1 — A WINDOW EDGE INSIDE A BAND WITH TWO REFUSALS IS A BRACKET, NOT A RECEIPT.**
`planner_at`/`kev_window` are sampled about every 11 minutes; the planner's timer fires every 10. In
this band two refusals landed (19:40:19 and 19:50:07), the cell is written latest-wins on **one
inode**, and the surviving cell is the *second* one — whose own admission test (6456 vs 6218) proves
it loaded nothing and therefore could not have opened the window. Two rules follow, and they are the
same rule seen from both ends:

1. **Quote the bracket the samples give, not the timestamp the cell carries.** A refusal receipt's
   `acquired_at` is the time of the attempt that *failed*, and a failed attempt with nothing left to
   evict cannot move the card.
2. **Order the candidates by what they could have done, not by when they were written.** The 19:39:52
   `closed` reading proves a resident at that instant, so only the FIRST refusal in the band had an
   eviction available to it; the second is a repeat on an empty card. That is the whole dating
   argument, and it survives the absence of any card sample between 19:39:52 and 19:50:52.

This EXTENDS `2026-10-24-a-cell-rewritten-inside-the-tick-names-the-wrong-refuser` (R1) from "the
cell was rewritten *inside the tick*" to "**the cell was rewritten inside the band**": there the
watcher's own runtime was 14 s wide and the rewrite was visible; here the sample period is 11 minutes
wide, the rewrite is invisible, and the only discriminator left is the admission arithmetic plus the
journal. It also bounds `2026-10-24-a-failed-rounds-duration-does-not-say-whether-it-evicted-a-resident`
(R1) from the other side: wall/CPU still cannot say who evicted (6.035 s vs 5.908 s, 3.086 s vs
3.101 s are the same round twice), but the *bracket* can say **who could have**.

**R2 — A FAILED ROUND CAN LEAVE A RESIDENT BEHIND, AND THE RESIDENT THAT KEEPS THE GATE SHUT MAY BE
IDLE.** The 19:30 round exited `status=1/FAILURE` at **19:30:18** while the smol it had just loaded
was serving **task 0 in the same second** (capture mtime 19:30:18.848 vs journal FAILURE 19:30:18) and
then served nothing else. So a round that *fails* can still install the occupancy that closes the
gate, and an *idle* resident holds it closed exactly as well as a working one: the card was closed for
the whole stretch from window M's close (19:01:12.864) to the edge — 38 m 39 s — by **two different
retainers in succession** (4B last task 19:20:08, smol loaded 19:30:16) with **no sample showing the
handover**. Corollary: an exit code dates the round, never the residency; the capture dates the last
task, never the exit; and "the model is serving" and "the round failed" can be true in the same
second.

**R3 — THE 15th WINDOW TODAY, AND EVERY ONE A PLANNER-LADDER BY-PRODUCT.** M (the 14th) opened
18:40:06.489 and shut 19:01:12.864 (21 m 6.4 s, by an outside requester's 4B load); N opened in
(19:39:52.068, 19:50:52.034], earliest possible 19:40:19, and is **still open at write** (free 6218,
+1929). Each window so far has been produced by the planner's own 10-minute ladder picking a rung
that does not fit and then leaving the card empty — the window is a **by-product of a refusal**, so its
width is the distance between the eviction and the next rung that *does* fit, not a period of
availability anyone chose.

**R4 — `planner_at=planner` IS A DEAD LESSEE'S REFUSAL RECEIPT (fourth instance).**
`arcade_window_watch.sh:28–35` derives the token from **file existence alone**, and the file's pid
1836285 is dead. The token read `planner` for the whole tick on a card with nothing loaded and has no
path back to `none` while the timer keeps rewriting the same inode every ten minutes. No new
mechanism is claimed: this is `2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R1
(the empty end of the token is unreliable too) with a fourth data point.

## AWAY SIDE — LLAMA TOOK NOTHING

`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` → rc 1, no match. `lease.d/` absent.
`scopes/` = `planner` only. No `arcade`/`kev`/`model-test` process (`ps aux | grep -iE ...` rc 1).
His clock is beating — `profiles/llama/cron/ticker_heartbeat`, 24 B, mtime 19:53 — over a directory
with **no `jobs.json`** and `executions.db` 24 576 B stopped at **2026-10-12 06:33**: a beat certifies
a clock, not an evaluation (`2026-10-21-a-heartbeat-is-not-an-evaluation`). **Flagged to Mike, not a
finding against Llama**, who is self-authorized under the precedence clause and runs on his own poll.

## MESSAGES: NONE, AND NONE EXECUTABLE

- **No @ocho.** `planner_at` is identical on both sides of the diff (`planner`), so the
  `global->planner` branch did not fire. His item was already closed on the 2026-10-23 10:40 4B
  certificate and is re-read closed in **his own rows**: `profiles/ocho/state.db` (opened read-only)
  `max(id)` from `messages` = **16551**, unchanged from the 19:17 tick, top rows the ruling post
  `t_c9e6cef3` / comment 97 — no new question pending.
- **No @llama.** This is the **first open tick of window N**; he self-runs under the operator-approved
  precedence clause, the fallback condition (an untaken window across a couple of ticks) is not met,
  and free 6218 is 1 929 above his gate, so a page would be premature rather than false.
- The DM path is **re-measured ABSENT this tick**: `tool_search` for an agent-messaging tool returns
  no matches (sources browser, computer_use, session_search, terminal, todo — the same absence
  recorded on 10-23 at 09:09 / 11:33 / 12:34 / 13:09 / 13:58 / 14:36 / 15:32 / 16:18 / 17:55 and
  10-24 at 07:07 / 07:43 / 08:57 / 11:14 / 19:15). **The escalation channel is this delivery to Mike.**

## READ-ONLY, THROUGHOUT

`nvidia-smi` (queries x6 + compute-apps), `date`, `ps`, `ss -ltnp`, `/proc` absence checks,
`curl :8080/running`, `journalctl --user` for `ocho-planner-polymarket.service` (19:30–19:52) and
`llama-swap.service`, `stat`/`sha256sum` on the cell and both captures, the lease tree, the cron
output directory and `monitor_last_output.txt`, `arcade_window_watch.sh` read as text, and
`profiles/ocho/state.db` opened `-readonly`. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the
planner unit and every model were **not touched**; the dead 19:50:07 cell was left in place per its
own liveness-first reclaim policy.

## PRIOR ART

`priorart.py rulings` run on **five phrasings before this file existed** (429 records): 0.241
**REVIEW** `2026-10-22-an-unadmitted-load-is-not-a-failed-attempt` — read in full and **distinguished**
(that ruling separates a refused request from an attempted one in a *score*; here nothing is being
scored and the refusal is being used as a *clock*, and its defect is the opposite direction: a receipt
that cannot date the event it is cited for); 0.172 `2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name`
— read and **extended** (there the opener was a *load* the record did not name; here the opener is an
*eviction* the record cannot name, because the second refusal overwrote the first's cell); 0.151
`2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load` — read and **confirmed as the parent of
R2's succession case**; 0.150 `2026-10-20-a-header-time-has-a-bracket-and-two-exculpations` and 0.123
`2026-10-15-an-edge-already-dated-is-not-a-new-window` — read, weaker, not duplicates. All read by eye.
**Increment filed:** R1's bracket-over-receipt rule with the eviction-availability ordering argument,
R2's failed-round-installs-occupancy with the same-second proof and the invisible handover, R3's 15th
window, R4's fourth dead-lessee instance.

RULINGFILE `rulings/2026-10-24-an-eviction-inside-an-unsampled-band-opens-the-window-its-receipt-names-the-later-refusal.md`
