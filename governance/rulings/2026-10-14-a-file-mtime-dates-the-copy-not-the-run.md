# A file mtime dates the copy, not the run

**Date:** 2026-10-14 · **Tick:** 16:21 (monitor `arcade-window-watch`, job `67530e415818`) · **Diff:** `planner_at=planner kev_window=open->closed`

## Setting

`planner_at=planner` is identical on both sides of this diff, so the prescribed
`global->planner` confirmation is not triggered: **no flip, no @ocho DM owed**. The change is
the window, and the mission's instruction for this signal is *record; no action*.

The window measured closed by its **successor's acquire**, not by the tick:

```
open   16:00:14  smol rung  cycle 58069  planner-smol 2672 MiB, free 4787 (+498 over gate)
close  16:10:11  9B  rung   cycle 58070  planner  9B  5874 MiB, free 1585 (-2704 under gate)
                                              duration 9 m 57 s
```

Read live at write (16:21:5x, three identical `nvidia-smi` reads over ~4 s and a re-read at
16:23:11): `used=6307 free=1585` of 8192 MiB = **2704 MiB under** the 4289 MiB Kev-4B need.
Holder triple-read positive — `scopes/planner/record.json` `owner=llama-swap-ocho-planner
scope=planner class=batch need_mib=6200 pid=157026` ALIVE (wrapper, start 16:10:10), resident
child `llama-server` pid 157094 **5874 MiB on :5805** (start 16:10:10), record mtime
16:10:11.737 / `acquired_at=1792019411` / `expires_at` 2026-10-15 16:10:11; `scopes/` = planner
**only**, `lease.d/` ABSENT; llama-swap `/running` = one entry `model=ocho-planner state=ready`,
`:5805/health` = ok; the round certifies (`ocho-planner-polymarket.service` 16:10:05→16:10:17
`Result=success ExecMainStatus=0`, and 16:20:05→16:20:15 likewise).

**The 16:0x entry's dated prediction HIT.** It filed *"the 16:10 round = cycle 58070 → pos 0 = 9B
(5874 MiB) → free ~1600 ⇒ this window closes ~16:10:1x; next smol rung = cycle 58079 ≈ 17:40"*.
Measured close 16:10:11, measured free at close-read 1585 vs predicted ~1600 (delta 15 MiB).
Second consecutive hit of that instrument (the first: 11:46 predicted ~11:50:2x → 11:50:28).

## What broke — the absence instrument moved without an event

The standing vector for *"Kev did not run"* has been the **newest Kev artifact mtime**. This
tick that datum reads **2026-10-14 15:54**, i.e. today, and nothing ran:

```
.worktrees/t_af6fafd9/results/Kev-4B-Q4_K_M_autofit_EMPTY_ctx8192_mt3000.json
  mtime 2026-10-14 15:54   sha256 1459e46c1c7e27994d029aede3646347f879969f21d855120630b8313c169e0e
  git status --porcelain:  CLEAN (tracked)
  HEAD blob == worktree blob == 820b6248e5b28e92a06d0364a42e2be36912c69a
  content: {"harness":"handicap-arena","version":"1.0","generated":"2026-10-07T19:50:30Z","results":[]}

../ocho_arena/results/ (same path, same 109 B, SAME sha256)
  mtime 2026-10-07 12:50
```

Same bytes, two mtimes seven days apart, both tracked and clean. The 15:54 mtime is the
**checkout** that materialised the worktree, not a run: ten `Kev-4B-Q4_K_M_*.json` records under
`t_af6fafd9/results/` all carry mtime 15:54 while each declares its own `"generated": "2026-10-07T19:50:30Z"`,
and identical filenames sit in the main checkout (mtime Oct 6–8) and in each cabinet worktree.

So a *file* instrument answered *today* to a question about a *process*. Had it been read as
"Kev ran at 15:54" it would have been a run reported out of a `git checkout`.

What remains load-bearing for absence, measured whole-tree:

```
~/.local/state/gpu-lease/**  = 4 files total:
  backups/llama-swap.yaml.pre-edit (10-13 17:20) · backups/gpu-lease.sh.pre-edit (10-13 17:20)
  lease.mutex (10-14 16:10) · scopes/planner/record.json (10-14 16:10)
  => NO kev / arcade / llama-model-test lease at any scope, at any time
ps: no kev/arcade process; no arcade cabinet process  ⇒ window UNTAKEN for its whole 9 m 57 s
```

## Rules

1. **A file mtime dates the copy, not the run.** Any absence instrument built on artifact mtimes
   can be reset to *now* by a checkout, a worktree, a copy or a sync, with no run anywhere in it.
   An artifact that declares its own generation instant (`generated`, `ts`, `acquired_at`) is
   dated by that field; the filesystem is the carrier's clock, not the work's.
2. **Absence of a *run* is measured on the run's own surface** — the lease tree and the GPU
   process list — and both are cheap and total. State the instrument with the absence, and prefer
   the one a copy cannot move.
3. **This is the day's one error in its eighth form.** Preceding forms: a rate for a power, a path
   for a subject, a signature for a text, a stored value for a live one, a symptom for a cause, a
   search vocabulary for an artifact's vocabulary, a recency for a named row. Here: **a file's
   clock for a process's history** — and it is SELF-CONFIRMING TOWARD THE READER, because a
   *newer* mtime reads as *activity* while the true statement is *copied*.

## Also recorded, same tick

- **The close edge is the successor's acquire, and the acquire lag is variable.** Round start is
  the timer's phase (`ocho-planner-polymarket.timer`, `:00:05 / :10:05 / :20:05`), wrapper start
  16:10:10, ledger `acquired_at` 16:10:11 ⇒ lag ≈ 5–6 s this round, against ≈ 38 s on the
  14:30 round. A prediction phrased on the timer's phase ("~16:10:1x") is therefore a *phase*
  claim and it happened to land because the lag was small; record the lag with the edge.
- **The window's own edges exist in no ledger.** `scopes/<s>/record.json` is a single-holder
  record: the smol record that opened this window was overwritten by the 9B one (mtime 16:10:11.737).
  The open edge survives only because the 16:0x tick read it live — same as the 14:45 filing's R3.
- **No run action, no model load, no lease touched.** No `@llama` ping: the window is **closed**
  at write (free 1585 ⇒ the 4289 premise is false at receipt), and his self-authorization has
  **still** no on-disk instrument this watcher can read (no kev/arcade unit or timer, `pgrep` =
  NONE; `profiles/llama/cron/executions.db` = 0 rows, mtime 2026-10-12 06:33) — absence recorded,
  not converted into a message; flagged to Mike, unchanged from the 11:46 filing.
- **No `@ocho` DM.** No planner flip, and the closure is named, not by recency: rows
  `9249 | user | 2026-10-13 17:49:44` (carrying the scoped-planner reading) and
  `9267 | assistant | 2026-10-13 17:54:07` (his reply) still stand, three rows back, while he is
  live mid-work on other subjects (newest inbound `kanban task t_614bf5db` 16:15:49, `t_c442023d`
  16:12:48; newest tool rows 16:22:42 on `PLAN_results_binders_migration.md`). Item closed;
  activity is the argument *against* sending (a bot-mode delivery takes his turn-lease for 300 s).
- **Card healthy:** module 615.71.09 Open, boot 12:49, uptime 3 h 33 m, **ONE NVRM line this boot**
  (the load line) = zero faults. EGL marker `{"state":"ok"}` (mtime 12:50:26) — and per the 16:0x
  R3 it is a **launch latch, not a crash counter**, so "ok" is not reported as "no crashes".
