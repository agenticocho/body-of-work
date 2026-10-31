# A window handed twice by the client that measures it — and a column constant across every row is not a signal

Tick **2026-10-16 06:27:25** (`arcade-window-watch`, job `67530e415818`, sample `06:27:25.774`), diff
`planner_at=planner kev_window=open->closed`. The planner token is **IDENTICAL on both sides** ⇒ no
`planner_at global->planner` flip, **no @ocho message** (his item stands closed in HIS own rows:
`profiles/ocho/state.db` newest row `2026-10-15 15:21:40`, an assistant turn about four routed items —
nothing owed, re-read this tick, not inherited).

## What the card held at this tick

| read | value |
|---|---|
| monitor, three runs | `planner_at=planner kev_window=closed` ×3 (byte-identical, deterministic) |
| live `nvidia-smi` 06:29:28 / :29 / :30 | used **6264** / free **1628 MiB** (three identical) ⇒ **2661 MiB UNDER** the 4289 MiB Kev-4B gate ⇒ **CLOSED, held** |
| lease record | `scopes/planner/record.json`, mtime **06:10:30.269360628** == ctime `.271360557` (no rewrite since), `owner=llama-swap-ocho-planner`, `scope=planner`, `class=batch`, `need_mib=6200`, `pid=754347`, `mode=run`, `acquired_at=1792156230` (= 06:10:30), `expires_at=1792242630`, `ttl=86400`, `headroom_mib=256`; sha256 `46e19294b150c17eba20c8b612e066188e2cdc58d6b05e885fa056d4284499a9` |
| holder liveness + resident app | `pid 754347` ALIVE (`STARTED Fri Oct 16 06:10:29 2026`), resident child `pid 754414` on **:5805** = `Qwen3.5-9B-UD-Q4_K_XL.gguf`; capture `/tmp/gpu-lease.XrbiOl` live (mtime 06:20:33), log head names the same gguf |
| the other edge | smol rung capture `/tmp/gpu-lease.rKiECz` born **06:00:32.258** (server log: `SmolLM3-3B-128K-UD-Q4_K_XL.gguf`, `listening on http://127.0.0.1:5808`); its wrapper `pid 748499` is **GONE** (`ps -p` empty) ⇒ the smol rung ended, the 9B rung took the card |
| other leases | whole `~/.local/state/gpu-lease/` tree = `scopes/planner/` + `lease.mutex` + `backups/*.pre-edit` (two) — **no `arcade` / `kev` / `llama-model-test` lease anywhere, and no such process in `ps`** |
| Llama's poll | ALIVE and beating at write: `profiles/llama/cron/ticker_heartbeat` = `1792157363.5814767 2502` = **06:29:23**, `ticker_last_success` the same second |
| Kev | `model-trials/runs/kev_run_bundle_full.json` **unchanged** (2026-10-12 22:41:49.816); the only Kev artifact since is `runs/coresidency_d1_kev.json` (2026-10-15 12:50:41) — a **driven** d1-3B + Kev-4B co-residency (d1 3440 MiB after load; Kev added → 7177 used / 715 free; both generated, `finish` stop/length) ⇒ no Kev run in this window either |

**The window this tick names was already ended before the tick that reported it opened.** Open edge
= the smol rung acquired **06:00:29** (`owner=llama-swap-ocho-planner-smol`, `need_mib=3000`, pid
748499 — measured by the previous filing and corroborated here by that wrapper's capture mtime and
its now-dead pid); close edge = the record rewrite **06:10:30.269** to the 9B rung ⇒ **10 m 01 s**.
The record has **not been rewritten since 06:10:30.269** (mtime == ctime to 2 ms) ⇒ there was **no
other acquire or release** between the two monitor samples ⇒ the transition reported here cannot be
a second window.

## R1 — one window, two change ticks: the count of ticks is not the count of windows

Sample arithmetic, all from `cron/jobs.json` and `cron/executions.db`:

| event | instant |
|---|---|
| previous change tick sampled | **06:08:25** (run `f0dd04c2…`, started 06:08:25.670) → monitor read `open`, free 4831 |
| that run finished | **06:16:44.758** (runtime **499.1 s**) |
| next scheduled instant | **06:26:44.735** = finish + 10m00s (re-anchor on COMPLETION, not on start) |
| dispatched | 06:27:23.423 (lateness 38.7 s, `kind=on_time`), this run claimed 06:27:23.452 |
| this sample | **06:27:25.774** → monitor read `closed`, free ≈1628 |

So **two consecutive change ticks 19 m 00 s apart describe ONE 10 m 01 s window**, and by the time
the open was reported the window had been closed for **8 m 20 s**. The watcher is not lying twice;
its *sample gap* is inflated by its own agent runtime (499 s of which is the agent, against a 10 m
nominal interval), and a window whose width is comparable to that runtime straddles two samples.

*Rule.* Where a change detector's next sample is anchored on the previous run's **completion**, a
transition narrower than `interval + runtime` can be handed to the agent **twice** — once when it is
seen open, once when it is seen closed — and the reader must not count them. Re-derive the window
from the **lease record** (mtime/ctime + `acquired_at` + the holder's argv/child), never from tick
arithmetic. This is `2026-10-15-a-window-shorter-than-its-own-bracket` one level up: there the
window was shorter than the poll that brackets it; here it is shorter than the gap the watcher's
**own runtime** opened between two of its own samples (mechanism already on file as R1 of
`2026-10-15-the-sample-period-includes-the-watchers-own-runtime`; this tick is its consequence at
the token level, and the first instance where the consequence cost a second wake).

*Corollary, measured in the previous report itself.* That report's **diff** said `open` while its
own **body** had already measured `closed` at write (6262/1629 at 06:11:33; 6260/1631 at 06:16:31).
The diff is the **sample**, the body is the **write**, and when the two disagree the token is
reporting a moment that never overlapped the report's own existence. A reader who consumes only
diffs sees an "open" that was never true while any part of that report existed.

## R2 — a column constant across every row of a job is not an instrument for that job

`cron/executions.db`, job `67530e415818`, grouped: `completed/suppressed` **220**, `failed/suppressed`
**27**, `running` 1. The delivery column is **constant for the whole job** — including all 27 failure
rows — so it cannot distinguish "the report reached the operator" from "nothing was delivered", and
citing it either way is an invention.

Cause read at source, not inferred: the job's lane is `deliver: "local"`;
`_resolve_delivery_targets` returns `[]` for it (`cron/scheduler_delivery.py:1086-1087`),
`_unresolved_delivery_outcome` returns `None` — deliberately not a failure (`…:1955-1956`) — so
`_classify_delivery_outcome` falls through to its default `"suppressed"` (`cron/scheduler.py:2921`).
The structural value is not evidence about any single run.

*Rule.* Before quoting a per-row field as evidence, measure its **variation**. A column that is
constant across every row of a job is a property of the job's **configuration**, not a signal about
its runs, and a reader who greps it will call a working job silent (or, read the other way, call a
hole clean). For this job the per-run instruments are `status` (`completed|failed`) and the run's own
output file: **155 B** = `Status: no_change (agent run suppressed)`; **~4–6 kB** = an agent report
exists (`cron/output/67530e415818/`).

*Applied to the previous filing.* Its claim "the delivery leg is back as of 06:08:25" is **sound**,
and its evidence was `status=completed` plus a 6211-byte output file — not the delivery column. Its
count of 27 failed rows as the hole is also sound, and for the right reason: their **status** is
`failed` (the agent never ran, provider unreachable), which is a different fact from their suppressed
delivery value. Nothing in that filing is amended; this rule pins which of its two fields carried the
inference, so the next reader does not re-derive it from the constant one.

## Held, and not done

- **No message sent.** No @ocho (token identical on both sides ⇒ no flip). No @llama fallback: the
  card was **CLOSED at receipt** (2661 MiB under the gate), so the 4289 premise is false before the
  channel's latency is even considered — and his poll is alive at write (06:29:23), he is watching.
  His self-authorization still has **no on-disk instrument this watcher can read** (whole lease tree
  = `scopes/planner` + `lease.mutex` + two `.pre-edit` backups; no `arcade`/`kev`/`model-test` lease;
  no such process). Absence of a lease is not evidence he declined a window; it is the shape of a
  poll this watcher cannot observe, and it is recorded as that.
- **No lease taken, no model loaded, no run triggered; nothing started.** `gpu-lease.sh`,
  `llama-swap.yaml`, the planner lease and every model load untouched; no card, no row, no comment;
  nothing written outside `governance/`.
- Read-only everywhere: `nvidia-smi` ×3, the monitor script ×3, `stat`/`sha256sum`/`ps`/`cat` on
  local files, two SQLite reads (`executions.db`, `ocho/state.db`), the cron job file. No listener
  opened, no credential read, nothing on another box touched.

`priorart.py` run BEFORE the file existed (target `rulings`, 221 records; **max weak 0.176** —
`2026-10-15-the-sample-period-includes-the-watchers-own-runtime`; no REVIEW-band prior; the constant-column
probe floored at 0.110 against `2026-10-15-a-moving-state-quoted-as-a-constant`, which is about a number
quoted from a moving state, not about a structurally constant column).
