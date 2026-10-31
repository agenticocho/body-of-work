# A record born dying, and thirteen edges no record carries

**Tick:** `67530e415818` (arcade-window-watch), change detected at the 05:40 sample.
Bracket from the persisted samples: previous `2026-10-26 05:29:52.157` → current
`cron/output/67530e415818/monitor_last_output.txt` `2026-10-26 05:40:52.045` (34 B, sha256
`8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`, content
`planner_at=planner kev_window=open`), so the `kev_window` edge lies in `(05:29:52.157, 05:40:52.045]`.

**Diff:** `planner_at=planner` on BOTH sides (no flip) + `kev_window=closed -> open`.

## Live at write (three identical reads, then a fourth)

`05:43:09.152`, `05:43:11.188`, `05:43:13.223` and `05:44:40`: **8192 total / 1732 used / 6159 free /
util 0 % / 39 °C** — `nvidia-smi` rc 0, numeric-validated by the watcher's own `[!0-9]` guard so this is a
reading and not a silent `closed`. The gate in `scripts/arcade_window_watch.sh` is `free >= 4289`
(Kev-4B 4033 + 256 headroom) ⇒ **1870 MiB OVER** ⇒ OPEN, held.

Occupants (compute apps): pid `976745` `prism-bonsai-9b` **1466 MiB** (`--n-gpu-layers 0`) + pid `979586`
`lfm25-vl` **134 MiB** (`--n-gpu-layers 0`) = 1600 MiB; `used 1732` leaves 132 MiB of driver/context over
that, and `used + free = 7891` against `total 8192` puts the standing ~301 MiB in neither column.

## The token did not change, and its positive is a failure

`planner_at=planner` is existence-derived (`arcade_window_watch.sh` lines 28–35: `[ -f
"$STATE/scopes/planner/record.json" ]` ⇒ `planner`). The record it is reading now:

`scopes/planner/record.json` 492 B, ino `9966346`, sha256
`575dc162f989ce1666d850d2f1844697fc69f6a3258661a01e1fd732b139add9`, birth `05:40:09.362101172`,
`owner=llama-swap-ocho-planner · scope planner · class batch · need_mib 6200 · pid 2863066 · mode run ·
acquired_at 1793018409 (05:40:09) · expires 1793104809 (2026-10-27 05:40:09) · ttl 86400 · headroom 256`.

- **Holder `2863066` is DEAD** — `ps -o pid,etime,cmd -p 2863066` returns no row at 05:41 and again at 05:44,
  no `gpu-lease.sh` process exists, and under the record's own quoted policy *"a mode=run holder whose pid
  is dead is reclaimable"*.
- **The record's birth second IS the acquiring unit's exit second.** `journalctl --user -u
  ocho-planner-polymarket.service`: `Starting` **05:40:03** → `Main process exited, code=exited,
  status=1/FAILURE` **05:40:09** (3.074 s CPU / 6.179 s wall, 142.1 M peak). `.362` falls inside the
  exit second — the record was **born dying**, and nothing released it because the EXIT trap is not run on
  a hard failure path.
- **The failure is a load refusal, from the planner's own log**:
  `[O55] 🎲 Weighted pick: ocho-planner (60% weight, cycle 59850, pool 3/3)` → `[llm] ❌ Request failed:
  500 Server Error: Internal Server Error for url: http://localhost:8080/v1/chat/completions`.
- **Arithmetic says it could not have fit**: ask `6200 + 256 = 6456` against **6159** free = **297 MiB
  short**, and the 1466 MiB `prism-bonsai-9b` is not under `llama-swap`'s management, so the swap has
  nothing to evict.

Contrast, same unit, same hour: `05:00:17`, `05:10:18`, `05:20:06`, `05:30:08` all **Finished** (rc 0), and
their picks were the small rungs — cycles `59846/59847/59848 = ocho-planner-4b` (need 3800), `59849 =
ocho-planner-smol`. Those rounds released the scoped record; the 9B round died holding it. So in this
stretch the token's positive is **anti-correlated with planner health**: present after a crash, absent
after a success.

## The window is the small rung's swap, again

The open edge falls in `(05:29:52.157, 05:40:52.045]` and the only occupancy event inside it is the
`05:30:00 → 05:30:08` **Smol** round (cycle 59849) swapping the resident 4B (3800 MiB) out for a smaller
one — i.e. the window is manufactured by the planner's own rotation to its smallest rung, the same class
as the 2026-10-15 finding that dated a window to the `O55` rotation's Smol rung. It is capacity for a
rung that fits (Kev-4B 4289), not for the rung that asks most (the planner's 9B at 6456).

## Thirteen edges, zero records — the record did not exist tonight

Every change-triggered agent run of this job between `2026-10-25 19:58:48` and `2026-10-26 05:07:52`
**failed at the same place**: `RuntimeError: Hermes can't reach the model provider` raised in
`cron/scheduler.py::_final_response_from_result`. Those 13 runs are the files in
`cron/output/67530e415818/` that carry no `**Status:**` line, and their diffs are **thirteen
`kev_window` edges** (`closed->open` / `open->closed`, alternating), `planner_at=planner` unchanged on
both sides of every one:

`2026-10-25 19:58:48, 20:36:01, 21:35:40, 22:23:58, 23:23:48` · `2026-10-26 00:00:53, 01:00:42,
01:15:51, 01:53:53, 02:31:48, 03:30:48, 04:07:54, 05:07:52`.

The monitor samples persisted for all of them (37 suppressed `no_change` files in the same directory);
**no ruling file was written for any of them** — `governance/` mtime stopped at `2026-10-25 16:31` and
`check_index.py` read `480 rulings on disk · 480 cited in INDEX` before this file. The instrument kept
measuring while the only writer of the record was down.

## RULING

**R1 — DATE A FILE-POSITIVE AGAINST ITS HOLDER'S EXIT, NOT AGAINST THE FILE.** When `record.json`'s birth
second equals the acquiring unit's `status=1/FAILURE` second, the positive is the fingerprint of a
**refusal** and carries no liveness at all. Here birth `05:40:09.362` against exit `05:40:09` plus a pid
absent from `/proc` is a complete, three-artifact disproof of the reading `planner_at=planner` invites.
Any instruction of the form "`global -> planner` means the flip is confirmed live" is not merely weak —
it is answered *wrongly* by a crashed round, and the check that settles it costs one `journalctl` line and
one `ps`.

**R2 — A MONITOR'S EDGE OUTLIVES AN OUTAGE OF ITS AGENT LEG; ITS RULING DOES NOT.** Thirteen transitions
have persisted samples and no record, because the ruling leg is an LLM turn and the box's provider was
unreachable. Therefore the rulings directory is a **lower bound on transitions, never an inventory of
them**: date an edge from the persisted monitor samples plus the artifact, and never conclude "nothing
happened between 20:00 and 05:00" from the absence of filings. A watcher whose only durable writer is the
model-dependent leg goes blind exactly when the machine is broken — the moment its log matters most.

**R3 — QUOTE THE ASK BESIDE THE READING.** `free 6159` is `+1870` over Kev-4B's gate and `-297` under the
planner 9B's ask; both are the same number read against two rungs. A window statement that omits the ask
it was not measured against will be read as "the next thing will fit", when the event that opened this
window is the larger rung failing to.

**Extends** `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` (recurrence with the
sharper date-stamp: the token's positive is produced by the crash, so `birth == exit` is the test) and
`2026-10-13-a-scope-record-outlives-its-holder`; **distinguishes** `2026-10-15-a-silent-consumer-leaves-a-gap-in-the-pick-log`
(that window was also the Smol rotation — cited as the mechanism, not re-asserted) and
`2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` (why no `@llama` page).

## Action taken

**NONE.** No lease acquired, no model loaded, no run triggered; `gpu-lease.sh`, `llama-swap.yaml`, the
planner lease (`scopes/planner/`, left exactly as found — read only) and every unit untouched.

- **No `@llama`** — he is self-authorized to acquire at `--scope arcade` on his own poll, and his poll is
  beating under this write (`profiles/llama/cron/ticker_heartbeat` `05:43:51.104`,
  `ticker_last_success` `05:43:51.111`). `scopes/` contains `planner` ONLY — no `llama-model-test` lease —
  but this is the transition tick, not a couple of ticks later, so the fallback clause is not yet ripe and
  a page would preempt his poll.
- **No `@ocho`** — his scoped-planner item is closed **in his own rows**, re-read this tick:
  `profiles/ocho/state.db` id `9249` (user, `2026-10-13 17:49:44`, "Your open item is closed … confirmed it
  from disk"), id `9267` (assistant, `17:54:07`), and an independent re-verification by him at id `16736`
  (`2026-10-25 14:27:49`, every number reproduced byte and hash); `max(id) = 16736`. A DM into a closed item
  is the drop-hazard class, and today's record would have carried the *wrong* reading into it.

`priorart.py` before filing: max `weak 0.109 2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`
(extended, cited), then `0.105 2026-10-25-a-lease-mode-claim-is-liveness-blind-by-construction`,
`0.104 2026-10-25-a-recycled-pid-makes-a-dead-holder-read-as-never-reclaimable` — read by eye; the new
increment (birth-instant-equals-exit-instant, and an outage-wide gap of 13 edges) is in no record on file.
