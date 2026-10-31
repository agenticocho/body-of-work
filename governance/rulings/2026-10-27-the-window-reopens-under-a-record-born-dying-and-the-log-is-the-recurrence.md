# The window reopens under a record born dying, and the log is the recurrence

**Tick:** `67530e415818` (arcade-window-watch), change detected at the `06:32` sample.
Bracket from the persisted samples: previous `cron/output/67530e415818/2026-10-27_06-21-08.md`
mtime `2026-10-27 06:21:08.901702350` (155 B, `Status: no_change (agent run suppressed)`, i.e. the
monitor still read `closed`) → current `monitor_last_output.txt` mtime `06:32:08.760109129`, 34 B,
sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`, content
`planner_at=planner kev_window=open`. The edge therefore lies in `(06:21:08.901, 06:32:08.760]`.

**Diff:** `planner_at=planner` on BOTH sides (no flip) + `kev_window=closed -> open`.

## Live at write (three reads, one second apart, all identical)

`06:33`–`06:34`: **8192 total / 1899 used / 5992 free / util 10–15 % / 39 °C**, `nvidia-smi` rc 0.
Gate in `scripts/arcade_window_watch.sh` is `free >= 4289` (Kev-4B 4033 + 256 headroom) ⇒
**1703 MiB OVER ⇒ OPEN**.

Quoting the ask beside the reading (the standing R3 of the parent ruling): the same `5992` is
**+1703** over Kev-4B's gate and **−464** under the planner 9B's ask (`need_mib 6200 + headroom 256
= 6456`). The window is open for Kev and shut for the planner.

Occupants (compute apps): pid `976745` `PrismML-Bonsai-2-9B-PQ2_0` **1466 MiB** + pid `979586`
`LFM2.5-VL-1.6B-Q4_0` **134 MiB** = 1600 MiB; `used 1899` leaves 299 MiB of driver/context over that,
and `used + free = 7892` against `total 8192` puts the standing ~300 MiB in neither column.

## The token's positive is again a crash, and the byte-string is identical to yesterday's

`planner_at=planner` is existence-derived (`arcade_window_watch.sh` lines 28–35: `[ -f
"$STATE/scopes/planner/record.json" ]` ⇒ `planner`). The record it is reading now:

`scopes/planner/record.json` 492 B, ino `10354824`, birth `2026-10-27 06:30:09.219768200`, sha256
`8ae99e0e27df45856baf902e1c124ef37b873cd96de2679f9cc2d627b881b729`, `owner=llama-swap-ocho-planner ·
scope planner · class batch · need_mib 6200 · pid 3949409 · mode run · acquired_at 1793107809
(06:30:09) · expires 1793194209 (2026-10-28 06:30:09) · ttl 86400 · headroom 256`.

- **Holder `3949409` is DEAD** — `/proc/3949409` absent, `ps -o pid,ppid,etime,rss,cmd -p 3949409`
  returns no row at `06:32` and again at `06:34`; under the record's own quoted policy *"a mode=run
  holder whose pid is dead is reclaimable"*.
- **Birth second == the acquiring unit's exit second, again.** `journalctl`:
  `Starting ocho-planner-polymarket.service` **06:30:01** → `Main process exited, code=exited,
  status=1/FAILURE` **06:30:09** → `Failed to start … (paper)`. `.2197` falls inside the exit
  second. Same unit, same hour, same shape: `06:00:17`, `06:10:13`, `06:20:16` all **Finished** (rc 0).
- **No model is loaded under the scoped lease.** `curl http://127.0.0.1:8080/v1/models` reports
  `brain` (alias `planner`) `status: unloaded`; `curl http://127.0.0.1:8080/running` → `{"running":[]}`.
  `scopes/` contains `planner` **only** — no `llama-model-test` lease.

## RULING

**This is a recurrence, not a new rule** — no new mechanism is filed, and the increment is a dated
instance with its own numbers.

**R1 — THE TOKEN IS A FUNCTION OF A FILE, SO ITS POSITIVE CANNOT DISTINGUISH A LOAD FROM A CRASH.**
`birth == exit` (`.219768` inside `06:30:09`) plus an absent pid plus `/running == []` is again a
complete three-artifact disproof of the reading `planner_at=planner` invites. Any instruction of the
form "`global -> planner` means the flip is confirmed live end-to-end" is answered **wrongly** by a
crashed round; the settling check costs one `journalctl` line, one `ps`, and one `/running` call.

**R2 — IDENTICAL BYTES ARE NOT A CONTINUOUS STATE.** Today's sample is byte-identical to the open
sample quoted in the parent ruling (same 34 B, same sha256 `8da24188…`), twenty-five hours and a
different record inode later. A content-only monitor line proves the *shape* of the state, never its
continuity; continuity comes from the persisted sample chain plus the artifact, as below.

**R3 — A TRANSITION TICK IS THE WRONG TICK FOR A FALLBACK PAGE.** Llama is self-authorized to
acquire at `--scope arcade` on his own poll; this is the opening tick, not "a couple of ticks later",
so the fallback clause is not ripe and a page would preempt his poll.

**R4 — OCHO'S ITEM IS CLOSED IN HIS OWN ROWS, SO A DM WOULD REOPEN A DROP-HAZARD.** Re-verified per
the parent ruling's citations (`profiles/ocho/state.db` ids `9249`, `9267`, and his independent
re-verification `16736`). Today's finding would have carried the *wrong* reading into a closed item.

**Extends** `2026-10-26-a-record-born-dying-and-thirteen-edges-no-record-carries` (the rule; this is
its first recurrence with a same-shaped failure under a reopened window) and
`2026-10-13-a-scope-record-outlives-its-holder` (the class). **Recorded, not distinguished:** the
`kev_window` edge itself is unremarkable — `+1703` is a real fit.

## Action taken

**NONE.** No lease acquired, no model loaded, no run triggered, no reservation made.
`gpu-lease.sh`, `llama-swap.yaml`, `scopes/planner/` (read only, left exactly as found) and every unit
untouched. **No `@llama`** (R3). **No `@ocho`** (R4). Read-only apart from this file and its INDEX
line.

`priorart.py` before filing: max `weak 0.148`
`2026-10-23-a-window-closed-by-a-live-holder-is-named-and-a-closed-window-is-not-a-missed-acquisition`
(read — names a holder, different axis), `0.113` `2026-10-13-a-scope-record-outlives-its-holder`
(cited), `0.110` `2026-10-26-a-record-born-dying-…` (the parent). No record on file needed a new
increment.
