# A window can be closed between rounds by a client the timer does not own

Tick facts (Arcade GPU co-residency watcher, job `67530e415818`), 2026-10-24 19:11:52–19:15 PDT.

Diff: `planner_at=planner kev_window=open -> closed`. The planner token is **identical on both
sides**, so there is no global->planner flip and no `@ocho` DM (his scoped-planner item was closed
on the 2026-10-23 10:40 4B certificate, re-read closed in today's 10:32 and 11:14 rows, and the
cell's owner/need are unchanged this tick). Record-only: no acquire, no release, no load, no unit
touched, no message.

Close edge bracketed on persisted samples: `cron/output/67530e415818/2026-10-24_19-00-52.md`
(155 B, `no_change`, carries no state of its own — baseline then OPEN) and
`monitor_last_output.txt` (36 B, mtime 19:11:52.156) reading CLOSED. So the edge lies in
(19:00:52, 19:11:52], and the one writer inside that interval is dated in §2.

## R1 — The closer did not come from the planner's round, and no round was running

The cell that closed this window was written by a load that began at **19:01:11**, and the planner
journal puts no round anywhere near it:

```
18:30:13 -> 18:30:21  status=1/FAILURE   (3.233 s CPU / 8.422 s wall / 141.9 M)
18:40:00 -> 18:40:06  status=1/FAILURE   (3.104 s / 6.310 s / 142.2 M)   <- opened the window
18:50:04 -> 18:50:10  status=1/FAILURE   (3.095 s / 5.857 s / 142.0 M)
19:00:09 -> 19:00:15  status=1/FAILURE   (3.128 s / 6.195 s / 142.2 M)   <- did NOT close it
19:10:04 -> 19:10:12  Finished           (3.246 s / 8.182 s / 142.0 M)
```

The load landed **56 s after the 19:00 round had already exited** and **8 m 53 s before the next
round started**, so the request that spent the headroom belongs to a client outside the planner
timer. That is the distinction this tick adds, and it is not the 2026-10-23 case: there the window
closed on the planner's own round which `Finished` exit 0 and the record named it
(`a-window-closed-by-a-live-holder-is-named-and-a-closed-window-is-not-a-missed-acquisition`);
here the ladder's pick **failed**, the window outlived that round, and the closer has no round
behind it at all.

Which client, bounded rather than named. The 19:00:09 burst started brier (finished same second),
planner, resolve, scorecard, sentiment and shadow; sentiment finished 19:01:00, resolve 19:01:10,
shadow 19:01:16. At 19:01:11 the only unit from that burst still running is **shadow**, which is
also the service whose shape matches the 2026-10-24 07:00 load
(`2026-10-24-a-detected-change-is-consumed-by-the-run-that-fails-to-record-it` R2). The swap log
cannot date the request — `llama-swap.log` carries no timestamps (mtime 19:01, final line
`[INFO] <ocho-planner-4b> Health check passed on http://localhost:5806/health`) — so the requester
is "most consistent with shadow", **not established**. The discipline is the point: what §2
establishes is the negative, and the negative is enough to break the attribution the token invites.

Rule: **"window width = the distance to the next rung that fits" is a statement about the ladder,
not about the card.** Six Ocho services share one swap group, so any of their requests can take the
headroom at any second, and the 10-minute cadence bounds nothing. For an away side that polls
(Llama's self-authorised `--scope arcade` acquire at free >= 4289) the operational consequence is
that eligibility does not persist to the next round boundary: 6218 free at 18:40:06 → 2731 at
19:01:12, a window of **21 m 6.374 s** that ended inside a service burst rather than on the timer.

## R2 — What the closer is, measured

- `~/.local/state/gpu-lease/scopes/planner/record.json` — 495 B, ino **9964817**, birth
  19:01:12.864041411, mtime 19:01:12.865041400, sha256
  `efb07b09704206fd71bfc73ae65bf72c1f45e703919335d859bb7d1e989dd0f8`,
  `owner=llama-swap-ocho-planner-4b, scope=planner, class=batch, need_mib=3800,
  headroom_mib=256, pid=1811146, mode=run, acquired_at=1792893672 (19:01:12),
  expires_at=1792980072 (2026-10-25T19:01:12), ttl=86400`.
- Wrapper **1811146 ALIVE**, ppid 2357 (llama-swap), lstart `Sat Oct 24 19:01:11 2026`, running
  `gpu-lease.sh run --owner llama-swap-ocho-planner-4b ... --scope planner --need-mib 3800 --
  llama-server --port 5806 --model .../Qwen3.5-4B-UD-Q4_K_XL.gguf`. Child **1811233** (ppid
  1811146, lstart 19:01:12) holds **3482 MiB** of VRAM, `:5806/health` = `{"status":"ok"}`,
  `:8080/running` = `ocho-planner-4b state=ready ttl=0`.
- Capture `/tmp/gpu-lease.zoBFLt` (2397 B, birth 19:01:12.961, mtime 19:10:12.536): a **fresh
  load** (`loading model '/home/chilly1/moltbook_pipeline/models/Qwen3.5-4B-UD-Q4_K_XL.gguf'`,
  `model loaded 0.01.104`), task 0 = 1574 prompt tok at 2548.71 tok/s + 105 eval, release
  n_tokens 1678 truncated 0, then task 109 at +8 m 56.9 s ~= 19:10:09 — i.e. the 19:10:04 round
  was served by this resident with **no record refresh** (third instance of
  `a-record-not-refreshed-is-not-a-lane-that-is-idle`). Real work, not a load-and-idle latch.
- Admission: `need + headroom = 3800 + 256 = 4056` against free 6218 at the open edge = **2162 MiB
  spare** — the smaller rung fits, which is exactly why a request for it can close a Kev window
  that needs 4289.

So this close is a **legitimate holder, correctly admitted, that simply is not the planner**.

## R3 — The record's owner field names the lease, never the requester

Same path, same inode (9964817), same owner string `llama-swap-ocho-planner-4b` on both sides of
this one window, with two different meanings: at 18:40:06 it was a 9B **refusal** (492 B, sha
`bb8368d2…`, `need_mib=6200` + 256 = 6456 vs free 6218 = 238 MiB short, pid 1799011 **DEAD**, no
capture born that minute); at 19:01:12 it is a live 3800 MiB holder with wrapper, child and
capture. The owner string is what the lease wrapper writes on behalf of whoever asked llama-swap
for the model; it cannot separate a planner round from an auxiliary client's request. A close
attributed from that field alone is therefore a category error — in this tick it would have named
the planner for a load the planner did not request.

## R4 — `planner_at=planner` certified a dead lessee's receipt for the whole window

`arcade_window_watch.sh:28-35` derives the token from **file existence alone**. At the open edge
the cell carried pid 1799011 **DEAD** and a need that could not fit, so for 21 m 6.4 s the token
read "planner" while no process held the lease. And the refusal row is now **unreadable on disk**:
the same inode was rewritten at 19:01:12, so the 18:40 row survives only in the 18:46 tick report
(`2026-10-24-the-refusers-cell-erases-the-fitting-holder-that-preceded-it` R1, third instance). This
extends `2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R1 one direction further: the
"planner" end of the token is unreliable not only when a release silently fails, but whenever the
last writer was a **refusal** — planner is what a dead lessee's cell reads as.

## R5 — A resident's VRAM and its RSS are two numbers; a kB field is not a MiB one

The live child 1811233 reads **3482 MiB** in `nvidia-smi --query-compute-apps` and **1729612 kB =
1689 MiB** in `ps` RSS, at the same moment. Earlier filings in this family phrase a VmRSS value as
"= 3482 MiB", which cannot be true of the same pid at the same instant. Quote GPU MiB from
nvidia-smi and RSS in kB separately: the arithmetic that names a closer by residency is the one
place where conflating them changes a conclusion.

## 6. Live card at write

Three byte-identical reads 19:14:38–19:14:43: **8192 total / 5161 used / FREE 2731** / util 0 % /
41 °C => **CLOSED by 1558 MiB under the 4289 gate**. Compute apps: 976745 Bonsai 1364 + 979586
LFM2.5-VL 134 (both `--n-gpu-layers 0`, unleased) + 1811233 planner 3482 = 4980, + ~181 driver =
5161; used + free 7892 vs 8192 = the standing ~300 MiB reservation. `lease.d/` absent, `scopes/` =
planner only.

## 7. Away side

`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1, no match; no `kev` /
`model-test` / `arcade` process; no arcade scope record. **Llama took nothing across the whole
21 m 6 s**, free sitting 1929 MiB above his 4289 gate for all of it. His ticker still beats
(`profiles/llama/cron/ticker_heartbeat` = 1792894370.997 = 19:12:51) over a directory with **no
jobs.json** and `executions.db` 24576 B stopped at 2026-10-12 06:33 — a beat certifies a clock, not
an evaluation (`2026-10-21-a-heartbeat-is-not-an-evaluation`). Flagged to Mike, not a finding
against him.

## 8. Messages

None, none owed, none executable. No `@ocho` — the planner token is identical on both sides and his
scoped-planner item is closed (2026-10-23 10:40 4B certificate). No `@llama` — CLOSE edge, he
self-runs under the precedence clause, and free 2731 is 1558 MiB under his gate so a page would be
**false at receipt**. The agent-DM path was re-measured absent this tick (`tool_search "send message
to another agent DM bot"` -> no matches; sources browser, computer_use, session_search, terminal,
todo), so this delivery to Mike is the channel.

## 9. Read-only / prior art

Read-only throughout: `nvidia-smi` x5 plus `--query-compute-apps`, `ps` (ppid / lstart / RSS),
`/proc`, `curl :5806/health` and `:8080/running`, `journalctl --user` (unit history and the
19:00–19:02 burst), `stat` + `sha256sum` on the cell and the capture, the lease tree,
`arcade_window_watch.sh` read as text, `profiles/llama/cron` inventory. `gpu-lease.sh`,
`llama-swap.yaml`, the planner lease, the planner unit and every model untouched; the live holder
left serving; the 18:40 refusal row was overwritten by its successor, not by me.

Prior art printed by `priorart.py` on three phrasings **before this file existed** (428 records:
0.193 `2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name`, 0.137
`2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits` read as the rule this tick
bounds rather than repeats, 0.126
`2026-10-23-a-window-closed-by-a-live-holder-is-named-and-a-closed-window-is-not-a-missed-acquisition`
read in full and **DISTINGUISHED** — there the closer was the planner's own round that finished
exit 0), all weak; increment filed = R1's negative attribution with its 56-second proof, R2's
distinguishing artifact set, R3's owner-is-not-requester, R4's dead-lessee latch, R5's
VRAM-vs-RSS correction.
