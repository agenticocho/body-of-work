# The window's opener is the workload's own refusal, and nothing acquires it

ARCADE WINDOW TICK `67530e415818`, change at the `07:32:08` sample. Bracket from the persisted
chain: previous sample `cron/output/67530e415818/2026-10-27_07-21-08.md` (155 B,
mtime `07:21:08.840589723`, `Status: no_change`, chain reading `closed`) -> current
`monitor_last_output.txt` (34 B, mtime `07:32:08.836653198`, sha256
`8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`,
`planner_at=planner kev_window=open`). DIFF: `planner_at` IDENTICAL both sides (no flip, no
Ocho branch), `kev_window closed -> open`.

## The edge, dated on both sides

* LOWER bound *taken from a negative*: at `07:21:08.840` the chain read `closed`, i.e. free
  `< 4289`; a released 4B rung would have put free at `5986`, so **the 3482 MiB planner 4B rung
  was still resident at 07:21:08.840**. `ps -o pid= -p 3972294,3972396` at `07:32` -> no row,
  `/proc/3972294` and `/proc/3972396` both `No such file or directory` (those are the wrapper and
  child the `07:07` ruling named as the window's closer).
* UPPER bound: `stat` -> `scopes` dir ino `8782138` mtime `07:30:08.430641363`, `scopes/planner`
  **dir born** `07:30:08.430641363` (ino `10354823`), record **born** `07:30:08.434641369`.
  A directory birth means the previous `scopes/planner` was unlinked, i.e. the 4B's scoped cell
  was deleted before `07:30:08.430` — a release deletes its own bid and its scope dir.
* So the window opened inside `(07:21:08.840, 07:30:08.430]` — 8 m 59.6 s wide.

## R1 THE OPENER IS THE SAME WORKLOAD'S NEXT ROUND, AND IT OPENS BY EVICTING THEN REFUSING

`ocho-planner-polymarket.timer` fired `07:30:01` (`journalctl --user`:
`Starting ocho-planner-polymarket.service` -> `Main process exited, code=exited, status=1/FAILURE`
`07:30:08`, `Consumed 3.405s CPU time over 7.249s wall clock time, 142.1M memory peak` — the
refusal fingerprint, not OOM). That round's acquire wrote a cell at `07:30:08.434` (4 ms after the
new dir) which is DEAD at every read: `/proc/3992847` absent at `07:32`, `07:33`, `07:34`;
`ps -p 3992847` no row; never in `--query-compute-apps`; `/v1/models` -> `ocho-planner` and
`ocho-planner-4b` both `status.value = unloaded`; `:8080/running` -> `{"running":[]}`;
`llama-swap.log` tail still `[WARN] group: starting ocho-planner failed: aborted` +
`status=500, path=/v1/chat/completions`. The record reads `owner=llama-swap-ocho-planner`
(the 6200 MiB 9B rung, no `-4b` suffix), `need_mib=6200`, `headroom_mib=256`, `mode=run`,
`pid=3992847`, `acquired_at=1793111408` (`07:30:08`), `expires_at=1793197808`, 492 B,
sha256 `551cd3abea68537d3798a53158d1e825b7d7a3614419618e3a223da2dd5ae170`.

ADMISSION AT THE SAME READ: `6200 + 256 = 6456` vs **5986 free** = **470 MiB short**. So one round
of the same workload (a) evicted the 4B rung that was holding the scoped cell and thereby deleted
the cell, (b) failed its own admission by 470 MiB and exited, leaving the card with **nothing under
the scoped lease and nothing on the global lease** (`ls -A lease.d` -> no such directory;
`scopes` -> `planner` only; `gpu-lease.sh status` -> `global lease: none held`).

This is the mechanism behind `2026-10-14-a-window-opened-by-a-failed-load` ("a window opened by a
failed load is a symptom, not capacity") — that ruling owns the SYMPTOM reading, and today supplies
the producer: the failed load is the **10-minute successor of the rung it displaces**, so a
chronically refusing 9B round manufactures a Kev window **every round it runs while a 4B rung is
resident**, on the timer, not on chance. The 06:32 open (`06:32:08.760 -> 07:01:18`, 29 m 10 s)
and this open are the same producer twice in 58 minutes. Corollary worth holding: the gate being
open is now less informative than *why* it is open — an open read on this box means the planner
round just failed, not that the card is idle capacity.

## R2 THE TOKEN STILL READS `planner` BECAUSE THE REFUSAL WROTE THE CELL — 4 ms AFTER THE EVICTION

`planner_at` is file existence (`scripts/arcade_window_watch.sh:31-35`), and the same acquire that
refused admission had already written the cell. So the line at write — `planner_at=planner
kev_window=open` — says "a scoped planner lease exists beside a clear card", which is true only in
the sense that the file exists; the holder is dead and the intended load is 470 MiB out of reach.
Recurrence of `2026-10-27-the-window-reopens-under-a-record-born-dying-and-the-log-is-the-recurrence`
R1, with one addition: **birth ordering separates eviction from refusal** — dir birth
`07:30:08.430641363`, record birth `07:30:08.434641369`, i.e. the same round deleted the old cell
and created the new one inside 4 ms, and `%w` birth proves the record inode number
(`10354824`, the same number the 4B cell carried at `07:01:18.855`) was recycled again. Path, inode
number and token are all constant across a live-4B -> dead-9B swap; only birth, size, digest,
`owner`, `need_mib` and pid distinguish them (`2026-10-27-the-window-closes-on-a-live-rung-under-an-unchanged-token`).
Identical bytes are not continuity either: today's 34 B line has the same sha256 as the `06:32`
open sample, a different record and a different inode generation
(`2026-10-27` R2 of the reopens ruling).

## R3 THE UNTAKEN WINDOW IS NOW AN EXECUTION FACT, NOT A HYPOTHESIS

Two windows in 58 minutes, both with nothing acquiring them: `grep -rliE
'arcade|kev|model-test' ~/.local/state/gpu-lease` -> rc 1, no match; `scopes/` holds `planner`
only, no `llama-model-test`, no `arcade`; `pgrep -af 'kev_run|arcade_|model-test'` -> the shell's
own self-match only; `ss -ltnp` -> `127.0.0.1:8080` llama-swap (pid 2357) and nothing on 5800-5829.
The self-authorised poll that the operator's precedence clause assumes is measured ABSENT on this
box, three ways: `~/.hermes/profiles/llama/cron/` holds **no `jobs.json`** (only `.jobs.lock`,
`.tick.lock`, `executions.db`, an `output/` dir empty since `2026-10-12 06:32`), `executions.db`
is frozen at `2026-10-12 06:33:07.322361061` while `ticker_heartbeat` / `ticker_last_success` beat
at `07:32:07.84`, and no unit, timer or crontab runs it (`systemctl --user list-units` ->
`llama-swap.service` only; `crontab -l | grep -iE 'llama|kev|arcade'` -> rc 1; the only
`jobs.json` on the box mentioning `llama` is this watcher's own in
`profiles/chilly/cron/jobs.json`). The beat carries pid `2957785` = the long-lived
`hermes … gateway run` process that hosts this cron session, so it certifies a gateway clock, not
an evaluation — the same reading as `2026-10-26-an-identifier-states-its-class-and-a-location-…`
era flags, now with the pid named. Consequence: the standing "Llama self-runs" premise is true as
authorisation and false as execution; until a job exists in `profiles/llama/cron/jobs.json`, a Kev
window will open and close unclaimed. That is Mike's to fix, not this watcher's, and this watcher
does not create jobs (RECURSION rule).

## ACTION: RECORD ONLY

No acquire, no release, no model load, no reservation, no unit or config touched;
`gpu-lease.sh` (read-only `status`), `llama-swap.yaml`, `scopes/planner/` and every unit untouched.
**No `@ocho`** — the diff's planner side did not move, and his scoped-planner item is closed in his
own rows (`profiles/ocho/state.db` 9249 / 9267 / 16736); a DM would carry a "confirmed live" about a
dead pid. **No `@llama`** — `kev_window` opened and his own poll is authorised to act; a fallback
page is for a window that survives several ticks untaken, and the executable fact above is that no
poller exists to receive it. Independently, the DM path is re-measured ABSENT in this cron toolset
(`tool_search "send message to another agent profile dm"` and `"agent to agent message chilly ocho
llama"` -> 0 matches; deferred catalog = browser, computer_use, session_search, terminal, todo).

## ONE SIGNAL FOR MIKE, MEASURED NOT CARRIED

`ocho-planner-polymarket.service` has now failed **five** rounds today (`06:30:09`, `06:40:10`,
`06:50:14`, `07:00:18`, `07:30:08`, each `status=1/FAILURE` after 7.2-8.7 s wall / ~3.4 s CPU /
~142 M peak) interleaved with three `Finished` rounds (`07:10:17`, `07:20:16`, and the 4B-served
interval), and `llama-swap.log` carries `starting ocho-planner failed: aborted` on repeat while
`ocho-planner-4b`/`ocho-planner-smol` health checks pass. The unit's own stderr is not in the
`--user` journal, so the cause is not readable from here; both the admission arithmetic (470 MiB
short) and the group abort are visible. Untouched.

Prior art printed BEFORE this file existed (`priorart.py rulings`, `priorart · 502 records in
rulings`): max `weak 0.125 2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name`,
`0.082 2026-10-14-a-window-opened-by-a-failed-load` (read in full; the symptom principle is its,
the producing mechanism is this ruling's increment), `0.079 2026-10-14-a-window-that-is-a-rung-of-a-rotation`,
`0.079 2026-10-27-the-window-reopens-under-a-record-born-dying-and-the-log-is-the-recurrence`
(read; R2 extended by the 4 ms eviction ordering), plus the parents
`2026-10-27-the-window-closes-on-a-live-rung-under-an-unchanged-token` (the closer this ruling
pairs with) and `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`. No record
states that the window's opener is the same workload's own evict-then-refuse round, or that the
unclaimed window is an execution fact three ways.
