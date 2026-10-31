# The refusal that reopens the window — and the empty card it leaves behind

**Date:** 2026-10-27 09:19 PDT (America/Los_Angeles, UTC-07:00)
**Instrument:** cron job `67530e415818`, `arcade_window_watch.sh` (every 10 m)
**Diff:** `planner_at` IDENTICAL both sides (`planner` -> `planner`), `kev_window` **closed -> open**
**Class:** dated instance of `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`
and of today's `the-window-opener-is-the-workloads-own-refusal-and-nothing-acquires`
(priorart max weak 0.179; no new rule owed)

## What moved, dated both ends from disk

The persisted chain's last no-change sample is
`cron/output/67530e415818/2026-10-27_09-06-09.md` (155 B, `Status: no_change`), i.e. at
**09:06:09** the line still read `closed`. The current line is
`cron/output/67530e415818/monitor_last_output.txt`, 34 B, mtime **09:17:08.828136814**,
sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`,
content `planner_at=planner kev_window=open`.

That digest is **byte-identical to the 06:32 open line and the 07:30 open line** quoted in
earlier filings while the record behind it was a different inode generation each time.
Identical bytes are not a continuous state (2026-10-27 recurrence): the line carries the
shape of the state, never its continuity.

The opener is inside a **659.8 s band**, and the artifact names the second:

| artifact | reading |
|---|---|
| `scopes/planner/` dir | ino `10354823`, **birth 09:10:20.071933730** |
| `scopes/planner/record.json` | ino `10354824`, **birth 09:10:20.075933472**, mtime `.077933343`, 492 B, sha256 `7341e1d114db76f8f5bbb785c4a77591a71ab62b011d1719c5991e6f9ba1ca6b` |
| inside the record | `owner=llama-swap-ocho-planner`, `need_mib=6200`, `headroom_mib=256`, `mode=run`, `pid=4063053`, `acquired_at=1793117420` (09:10:20), `expires_at=1793203820` (2026-10-28T09:10:20) |
| `journalctl --user -u ocho-planner-polymarket.service` | `Starting 09:10:07` -> `Main process exited, code=exited, status=1/FAILURE 09:10:20`, `Failed to start`, 3.574 s CPU / 12.908 s wall / 142.4 M peak |
| `ps -p 4063053` | no row |

So the window's open instant is **09:10:20.076**, the record's birth — 4 ms after its own
directory, the same ordering (dir then record) the 07:30 filing measured. The
`ocho-planner-polymarket.timer` round tries the 6200 MiB 9B rung, fails admission, and the
record it leaves behind is a **refusal receipt** that the monitor reads as `planner_at=planner`
because that token is file existence (`arcade_window_watch.sh:29-35`).

## The card at write (three identical reads, 09:17-09:19)

`nvidia-smi`: 8192 total / **1905 used** / **5986 free** / util 6 %.
Gate (`arcade_window_watch.sh:12,47`): 4033 + 256 = **4289** => `5986 - 4289 = +1697`, OPEN.
Tenants: pid 976745 1466 + pid 979586 134 = 1600, leaving ~305 MiB in neither column
(`used + free = 7891` vs 8192).

**Nothing is loaded under the scoped lease.** `/v1/models` -> `brain` (alias `planner`)
`unloaded`; `/running` -> `{"running":[]}`; `ss -ltnp` -> `127.0.0.1:8080` llama-swap only,
nothing on 5800-5809; `scopes/` holds `planner` alone; `lease.d/` does not exist
(`gpu-lease.sh status`: `global lease: none held`).

The 08:30 4B cell's wrapper `4035148` and child `4035235` (the pair the 08:40 filing named as
that window's closer) are **both gone** (`ps` no row), and the newest capture is
`/tmp/gpu-lease.yLfRve`, 1642 B, mtime 09:00, whose body is a **SmolLM3-3B** load
(`load_model: ...SmolLM3-3B-128K-UD-Q4_K_XL.gguf`, `model loaded`, 2827 prompt tok at
4907.75 tok/s). No capture exists after 09:00 — the 09:10 round refused before it loaded
anything, so it produced no capture at all.

Reconstructed: the smol rung was resident at 09:06 (that is why the sample read `closed`,
free < 4289, i.e. >= 3903 MiB held over the 1600 baseline), the 09:10 9B round evicted it,
then failed its own admission — `6200 + 256 = 6456` against **5986 free on the now-empty
card = 470 MiB short**, the sixth measured shortfall of this size today (470 at 07:30,
475 at 08:40). The card therefore stands idle with a live gate and a dead scoped holder.

## Why this is filed as an instance, not a rule

- The mechanism is already owned: `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`
  (a refusal evicts the tenant it found), extended today by
  `rulings/2026-10-27-the-window-opener-is-the-workloads-own-refusal-and-nothing-acquires.md`
  (the opener is the same workload's next round) and
  `.../2026-10-27-the-hour-wide-window-closed-on-the-first-draw-that-fits.md` (the closer is
  the first draw that fits).
- What today adds is a **third** pass of the same 10-minute producer inside 2 h 40 m
  (06:32, 07:30, 09:10), each evicting a resident planner-lane rung and refusing its own 9B
  ask while the emptied card sat +1692..+1697 over the Kev gate.
- `planner_at=planner` beside a `pid` that is not alive is the existence-token defect already
  ruled on (`2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`); the
  inode number `10354824` has now been recycled for at least five distinct record generations
  today, so inode number is not identity either (extends the 07:07 filing).

## Action

**RECORD ONLY.** No acquire, release, load, reservation, unit or config touched;
`gpu-lease.sh` (read-only `status`), `llama-swap.yaml`, `scopes/planner/` and the planner unit
untouched.

- **No `@ocho`.** The planner token did not move this tick (identical both sides), his
  scoped-planner item is closed in his own rows, and no agent-messaging tool exists in this
  cron toolset.
- **No `@llama`.** The open edge is ~8 minutes old; the fallback page is for a window that
  survives several ticks untaken. His self-authorisation stands and this watcher does not
  trigger runs. Independently re-measured absent again this tick:
  `profiles/llama/cron/` has **no `jobs.json`** (only locks, `executions.db` frozen
  2026-10-12 06:33, an empty `output/`), while `ticker_heartbeat` beats at
  `1793117887.75 pid 2957785` — a live clock over an empty job set. Standing flag for Mike;
  this watcher does not create jobs.

## On disk beside this, not this watcher's to fix

`ocho-planner-polymarket.service` today: FAILURE at 06:30, 06:40, 06:50, 07:00, 07:30,
08:00, 08:10, 08:20, 09:10; `Finished` at 05:50-06:20, 08:30, 08:40, 08:50, 09:00. The unit's
stderr is not in the `--user` journal, so the refusal's cause is not readable from here.
Untouched, flagged for Mike.

**Prior art run before this file existed:** `priorart.py rulings` -> 504 records, max
`weak 0.179 2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`,
`0.125 2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`,
`0.119 2026-10-21-a-failed-swap-evicts-before-it-refuses`.
