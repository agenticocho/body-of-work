# A window open with NO planner holder is the state that actually fits Kev

**Filed 2026-10-20 17:47 PDT by the Arcade GPU co-residency watcher (profile `tiel`, cron).**
**Tick diff:** `planner_at=planner` (token UNCHANGED on both sides) · `kev_window=closed -> open`.
**Nature of the tick: RECORD ONLY.** No run action, no model load, no acquire, no message sent. Llama remains
self-authorized to take Kev-4B at `--scope arcade` when free >= 4289 on his own continuous poll; the precedence
clause is his standing authorization and this watcher does not preempt it.

## The bracket

| sample | value | artifact |
|---|---|---|
| previous | `planner_at=planner kev_window=closed` | `cron/output/67530e415818/2026-10-20_17-31-41.md`, mtime **17:31:41.447** |
| current | `planner_at=planner kev_window=open` | `cron/output/67530e415818/monitor_last_output.txt`, mtime **17:42:41.411** |

Open edge lies inside **(17:31:41.447, 17:42:41.411]**. The gate is `free -ge 4289` (Kev-4B 4033 + 256 headroom),
numerically validated in the watcher, so a failed read prints `unknown` — `closed` at 17:31:41 means free was
genuinely below the gate (used > 3903 MiB), not a dark probe.

## The live artifact (read this tick, never remembered)

Four `nvidia-smi` reads, all the same value to the MiB:

| read | used | free | vs gate 4289 |
|---|---|---|---|
| 17:43:1x / :2x / :3x | 1781 | **6111** | **+1822 open** |
| 17:46:0x | 1801 | **6091** | **+1802 open** |

Compute apps at write: **only** `pid 2812` 1364 MiB (PrismML Bonsai demo, `-n-gpu-layers 0`) + `pid 2813` 134 MiB
(vision LFM2.5-VL, `-n-gpu-layers 0`), both unleased. 1364 + 134 = **1498 MiB held by CPU-offload tenants**; the
`used + free = 7891` residual against `memory.total 8192` is the standing ~300 MiB driver reservation.

`~/.local/state/gpu-lease/` at write — the whole ledger: `lease.mutex`, `backups/{gpu-lease.sh.pre-edit,
llama-swap.yaml.pre-edit}`, `scopes/planner/record.json`. **`lease.d/` ABSENT, `scopes/` = planner ONLY** — no
`kev`, `arcade` or `llama-model-test` lease exists, so Llama has not acted yet in this window (expected: it is
~5 minutes old and he self-polls).

`gpu-lease.sh status` (read-only) at 17:43: `tenants: pid 2812 1364 MiB owner=unowned · pid 2813 134 MiB
owner=unowned`, `global lease: none held`.

## `planner_at=planner` is a FAILED-ACQUIRE record, not a holder — three reads, all negative

`scopes/planner/record.json` (490 B class, this tick's write): `owner=llama-swap-ocho-planner`, `scope=planner`,
`class=batch`, **`need_mib=6200`**, **`pid=341301`**, `mode=run`, `acquired_at=1792543209` = **17:40:09**,
`expires_at=1792629609` = 2026-10-21 17:40:09, `ttl=86400`, `headroom_mib=256`.

1. **Holder DEAD.** `/proc/341301` absent; `ps -p 341301` = no rows.
2. **No resident compute app.** `llama-swap` `/running` = `{"running":[]}`, every model in `/v1/models` reads
   `status: unloaded` — including `brain`, whose `llamaswap.aliases` is `["planner"]`.
3. **No model listener.** `ss -ltn` shows nothing on `:5806` (ocho-planner-4b) or `:5808` (ocho-planner-smol);
   the only listener in this stack is `llama-swap` itself on `127.0.0.1:8080`.

The mechanism is on the unit: `ocho-planner-polymarket.timer` (`*:0/10`) rounds measured from the user journal —
16:40 **FAILURE**, 16:50 **FAILURE**, 17:00 Finished, 17:10 Finished, 17:20 Finished, 17:30 Finished,
**17:40:03 Starting -> 17:40:10 `Main process exited, code=exited, status=1/FAILURE`, `Failed with result
'exit-code'`, 2.944 s CPU / 6.438 s wall, 141.2M peak**. `llama-swap.log` (no timestamps) repeats
`group: starting ocho-planner failed: aborted` then `non-200 response ... status=500, path=/v1/chat/completions`.
The 141.2M peak is a refused/aborted load, not an OOM.

**Arithmetic, computed from this tick's own reads:** the 9B rung needs `6200 + 256 headroom = 6456 MiB` against
**6111 MiB free at 17:43 (345 MiB short, 365 at 17:46)** — i.e. this record was manufactured by a refusal, exactly
the class filed as `2026-10-13-a-fresh-record-from-a-failed-acquire` and re-measured here this morning
(`2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`, recurrence 08:19: 6456 vs 6061, 395 short).

**Consequence for the ledger, not for the window:** the stale dead-holder record does **not** block a scoped
arcade acquire. `gpu-lease.sh`'s scoped path (step 3) writes only its own `scopes/<name>/` and lets other scopes
co-reside; admission is on live free VRAM read from `nvidia-smi`, not on the sum of outstanding `need_mib`. So a
reader who summed records (6200 + 4289 = 10489 > 8192) would wrongly call this card over-committed. Read the
card, or read the scope you are taking.

## Why this window is a REAL one, unlike the 4B-resident case

Applying `2026-10-14-a-window-that-only-opens-when-the-planner-is-down` R1 — *report a window with which slot is
absent, never as a bare free number*: **no planner holder is resident at all** this tick (no 9B, no 4B, no smol,
`/running` empty, no model port). That is the empty-card state, the one row of that ruling's table where Kev-4B's
4289 fits with room to spare. For contrast, the two neighbouring states do not fit: the planner's 4B leaves
~4125 free (**164 MiB short**) and its 9B leaves 1682–1869 (**2420 short**).

**But the window is exclusive, and that is the number worth recording:** 4289 loaded takes free to ~1802 MiB, and
the planner's next rung needs `3800 + 256 = 4056` (4B) or 6456 (9B). **Every planner slot is arithmetically
excluded while Kev-4B is resident**, so the 17:50/18:00 planner rounds are expected to fail on admission for as
long as a Kev-4B holder exists — and the standing 4B/9B fault (9B slot failing on `group: starting ... failed:
aborted`) is independent of it. Recorded, not acted on: the planner lease and every model load are outside this
watcher's authority.

## Messages: none, and each withheld for a measured reason

- **@ocho — withheld.** His prescribed message fires on `planner_at global->planner`; **the token did not change
  this tick** (planner on both sides) and the prescribed claim ("the scoped-planner flip is confirmed live
  end-to-end") would be **FALSE against this tick's three reads** — dead holder, no resident app, no listener.
  His open item is also not open anywhere I can read: `profiles/ocho/OPEN_ITEMS.md` (4 queue items, none about
  the scoped-planner flip) and the board's only non-done task is `t_efd6df81` (sokoban frontier, triage). Stand-
  down recorded here so silence cannot be read as omission.
- **@llama — withheld.** He is self-authorized and his poll is demonstrably alive this minute
  (`profiles/llama/cron/ticker_heartbeat` = 1792543420.13 = **17:43:40.13**, `ticker_last_success` 17:43:40.139).
  The window is 5 minutes old; a page would arrive into his own poll's read, which is the preemption the
  coordination clause forbids. The fallback clause ("a couple of ticks with no llama-model-test lease") is not
  yet satisfiable — this is the first tick of the window.

## Touch log

Read-only throughout: `nvidia-smi`, `/proc`, `ps`, `ss`, `curl` on `127.0.0.1:8080`, `systemctl --user status`/
`cat`, `journalctl --user`, `gpu-lease.sh status`, `stat`, `grep`, `tail` on `llama-swap.log`. **No write to
`gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the scheduler units, or any model load. No acquire, no
release, no `systemctl` verb that changes state, no message.**

**Flagged for Mike (in this report, not routed into a spool):** the planner's 9B slot has failed 3 of the last 7
rounds (16:40, 16:50, 17:40) on `starting ocho-planner failed: aborted`, and every success in that window was a
fallback slot — while the Kev window that is open right now is arithmetically exclusive of every planner rung, so
the planner's next failures are expected and are not evidence of a new fault.
