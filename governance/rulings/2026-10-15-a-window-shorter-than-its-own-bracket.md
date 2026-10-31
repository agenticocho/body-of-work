# A window shorter than its own bracket cannot be arbitrated by the poll that brackets it

Tick facts (Arcade GPU co-residency watcher, job `67530e415818`). Monitor sample written
2026-10-15 17:52:25.862119 (-07:00); previous PERSISTED sample 17:35:25.945 — that run started
17:35:25.763 and FINISHED 17:42:03.478 (6m37.7s of agent time), and the run before it
(17:24:25.680) completed in 0.2s and read no change.

Diff: `planner_at=planner kev_window=open -> closed`. The planner token is IDENTICAL on both
sides of the diff, so there is no planner flip and no `@ocho` DM.

## R1 — the token is bookkeeping: this close was dated and measured by the PREVIOUS tick's own run

The 17:35 tick had already recorded the close inside its own response — *"record rewritten
17:40:06.767 (need 6200, pid 407688, child 407776 = 5874 MiB on :5805); `free 1478` ×3 ⇒ 2811
under the gate. Window = 9m37.195s"* — and this tick's `open -> closed` is that same edge
arriving as a token. Classes already on file, cited and NOT re-filed:
`2026-10-14-a-transition-can-arrive-after-the-entry-that-already-recorded-it`,
`2026-10-15-an-edge-already-dated-is-not-a-new-window`.

Verified here independently, not inherited from that response:

- `scopes/planner/record.json`: mtime `17:40:06.767605892`, ctime `17:40:06.768605884`
  (mtime == ctime to 1 ms ⇒ written once), size 491, owner `llama-swap-ocho-planner`, scope
  planner, class batch, need_mib 6200, pid 407688, mode run, acquired_at 1792111206 = 17:40:06,
  expires_at 1792197606 = 2026-10-16 17:40:06, ttl 86400, headroom_mib 256.
- wrapper pid 407688 `lstart Thu Oct 15 17:40:05 2026`, ALIVE; resident child `llama-server`
  407776 (same lstart) = 5874 MiB on `:5805` (Qwen3.5-9B-UD-Q4_K_XL.gguf, ctx 8192).
- capture `/tmp/gpu-lease.thBnui` BORN 17:40:06.864605162 with the wrapper, mtime 17:50:33.097 =
  the 17:50 round's write, served by the resident server; the record was never rewritten, so ONE
  holder spans 17:40:06 → this write.
- the open's own capture `/tmp/gpu-lease.HGEeZj` born 17:30:29.666 ≈ the filed smol acquire
  17:30:29.572 ⇒ **ONE window**, edges dated by the ACQUIRES (open 17:30:29.572 smol → close
  17:40:06.767 9B), never by tokens.

## R2 — a window of this size fits INSIDE one poll period, so this watcher cannot arbitrate an admission into it

Measured: window **577.195 s** against the sample period that bracketed it **1,019.917 s**
(17:35:25.945 → 17:52:25.862) = **1.767×**. The overshoot is the previous run's own runtime:
dispatch `kind=on_time`, `lateness_seconds=20.0`, `scheduled_instant` = previous `finished_at`
(17:42:03.478) + 10m00s ⇒ the nominal 17:45:25 sample never happened. Instance of
`2026-10-15-the-sample-period-includes-the-watchers-own-runtime`.

Rule: on a ≥10 min poll whose runs can take minutes, a 9–10 min window is **unarbitrable by this
watcher by arithmetic** — a sample either lands INSIDE the window (and can only report it) or
lands after it (and can only report the successor). There is no sample schedule on which this
watcher can be the actor. That is the measured justification for delegating the admission
decision to a continuous poll (the coordination clause in this job's prompt), and the reason an
`open` token licenses at most a fallback ping and never an acquisition by this tick.

## R3 — the delivered line dates its SAMPLE; a run can outlive the state it sampled

The 17:35 tick finished at 17:42:03.478 — **116.710 s AFTER the close (17:40:06.767) its own body
recorded** — so its header `kev_window closed -> open` was true of sample 17:35:25.945 and already
false of the card at write. Second, now quantified instance of
`2026-10-13-a-reboot-manufactures-the-window` ("a poll's sample instant is not its write
instant"); what is new is that BOTH edges fell inside one run.

Rule: a report whose run outlived its sample must carry its **sample instant**, and no consumer may
date a window from a report's file mtime or delivery time — 116.7 s of drift on a 577.2 s window
(20.2%) is the size of the error that buys.

## Live readings at write (17:52:41 / :42 / :43, three identical reads)

- `memory.used 6418 MiB, memory.free 1473 MiB` ⇒ **2816 MiB UNDER the 4289 gate (4033 + 256) ⇒
  CLOSED.**
- `nvidia-smi --query-compute-apps`: 407776 (planner 9B) 5874 MiB; 2418 (vision LFM2.5-VL,
  `--n-gpu-layers 0`) 134 MiB; 335719 35 MiB.
- host memory: 60 GiB total / 9 GiB used, 0 swap used.

## Absentees (recorded, not messaged)

`~/.local/state/gpu-lease/` = 4 files (two `.pre-edit` backups, `lease.mutex`,
`scopes/planner/record.json`); `scopes/` = planner ONLY; `lease.d/` ABSENT;
`grep -ril -E 'arcade|kev|model-test'` over the tree = NO MATCH (rc 1); all 14 `/tmp/gpu-lease.*`
captures are planner rotation runs. **Kev has still not run:**
`~/.hermes/profiles/llama/model-trials/runs/kev_run_bundle_full.json` mtime 2026-10-12 22:41:49
(3 days). Llama's self-authorised poll is ALIVE and beating during this write:
`profiles/llama/cron/ticker_last_success` = epoch 1792112123 = 17:55:23 (-07:00), heartbeat the
same second (pid 2502) ⇒ the empty arcade scope is his choice, not a dead watcher.

## Actions

NONE, and none owed:

- **No `@ocho` DM** — the diff carries no `planner_at` flip. His scoped-planner item is closed in
  HIS rows, re-read by rowid at write: id `9249` | user | *"Ocho — Tiel. Your open item is closed…
  CONFIRMED LIVE END-TO-E[ND]"* and reply id `9267` | assistant | *"…I've adopted it as binding"*;
  his newest rows (`13484`–`13491`) are kanban filing work, unrelated.
- **No `@llama` fallback** — that clause is licensed by an OPEN window; at write the window is
  closed by 2816 MiB, so the 4289 premise would be false at receipt.
- **No run action, no lease, no model load.** `gpu-lease.sh`, `llama-swap.yaml`, the planner lease
  and the model cache were READ only; nothing on the box was written except this profile's own
  watcher log and this file.

Prediction (band map pos 0-5 = 9B, 6-8 = 4B, 9 = smol; observed cycle 58229 = 17:30 = smol,
58230 = 17:40 = 9B): the next smol rung is cycle **58239 = the 19:10 round**, so on the rotation's
own clock the gate cannot clear for Kev's 4033+256 before ~19:10:2x.

RULINGFILE rulings/2026-10-15-a-window-shorter-than-its-own-bracket.md
