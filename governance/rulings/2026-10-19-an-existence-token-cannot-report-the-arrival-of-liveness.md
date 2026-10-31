# An existence token cannot report the arrival of liveness

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected 2026-10-19T18:53:25.144 PDT,
previous persisted sample 18:42:25.224 ⇒ the edge lies inside a clean bracket `(18:42:25.224, 18:53:25.144]`.
**Diff:** `planner_at=planner` on BOTH sides (no flip) + `kev_window=open -> closed`.

## What the token did, measured

Between the two samples the `planner_at` referent changed from a **dead** holder to a **live** one, and the
token never moved:

| round | cycle (pos) | pick | acquire record | holder | card after |
|---|---|---|---|---|---|
| 18:20:23 | 58834 (4) | `ocho-planner` (9B) | `record.json` 18:20:30.439, pid 204031, need 6200 | **dead** (`/proc/204031` absent at 18:30:46) | free 6126 |
| 18:30:23 | 58835 (5) | `ocho-planner` (9B) | `record.json` 18:30:29.456, pid 211043, need 6200 | **dead** (`/proc/211043` absent at 18:30:58) | free 6126 |
| 18:40:26 | — (5) | `ocho-planner` (9B) | unit `status=1/FAILURE` 18:40:33 | **dead** | — |
| 18:50:23 | 58836 (6) | `ocho-planner-4b` | `record.json` 18:50:29.979 (494 B, sha256 `6f0d3bf1…3e7003a`), pid 227055 | **ALIVE** (wrapper lstart 18:50:28, child 227142 lstart 18:50:29) | free 2618 |

The live holder certifies at all three depths `2026-10-13-a-scope-record-outlives-its-holder` demands:
record (`owner=llama-swap-ocho-planner-4b · scope planner · class batch · need_mib 3800 · mode run ·
acquired_at 1792461029 = 18:50:29 · expires 1792547429 · ttl 86400 · headroom 256`), holder (`/proc/227055`),
resident app (child `llama-server` pid 227142 **3482 MiB** on `127.0.0.1:5806`,
`Qwen3.5-4B-UD-Q4_K_XL.gguf`, ctx 8192, ocho_grammar, `/health` = `{"status":"ok"}`,
`llama-swap /running` = `ocho-planner-4b state=ready`) — and the WORK certifies too:
`ocho-planner-polymarket.service` 18:50:23 Starting → **18:50:34 Finished** (`Result=success`,
`ExecMainStatus=0`, 3.215 s CPU / 10.830 s wall, 150.3 M peak), `plans/latest_plan.json` mtime
18:50:34.704 (1255 B), and the lease capture `/tmp/gpu-lease.QzdFmW` logs a completed generation
(prompt eval 3663 tok / eval 115 tok) on `:5806`.

That acquisition produced **no token change**. The only reason this tick has a diff at all is the OTHER
token (`kev_window`), which moved because the same 4B load displaced the free-VRAM reading.

## RULING

A change-detector token whose value is derived from **record existence** has two failure directions, and
tonight both were measured on the same token:

1. **It fires early** — `gpu-lease.sh` writes `record.json` before the wrapped load starts, so the token
   reaches its "live" value on a *failed acquire*. Three consecutive 9B rounds (18:20:30, 18:30:29,
   18:40:33) set `planner_at=planner` with dead pids. A watcher instruction of the form "`planner_at`
   global→planner means the flip is CONFIRMED LIVE" is therefore **unsatisfiable by construction**: it
   would have certified a dead holder at 18:20:30.
2. **It never fires late** — when a genuinely live holder finally arrived at 18:50:29, the token already
   read `planner`, so the event that the token exists to report had **no diff**. A "no change" sample
   across that interval is not "no acquisition".

**Rules.**

- A token that can be satisfied by a *file* must be qualified by the holder it names: report
  `planner_at=planner:live` / `planner_at=planner:dead` (record + `/proc` + resident compute app), or
  report the holder's identity (`owner/pid/need_mib`) beside it. A bare `planner` is a location, not a
  state.
- Absence of a diff is never evidence of absence of an event when the token is existence-derived: date a
  holder transition from the artifact (`record.json` mtime + `acquired_at` + `/proc` + the round's exit
  status), not from the token.
- A "confirm the flip live" instruction must be attached to the *liveness* read, never to the token flip.

## Window closed by the rung that FITS (pre-registered, then scored)

Gate read from `scripts/arcade_window_watch.sh` (`[ "$free" -ge 4289 ]`, numeric-validated ⇒ a failed read
prints `unknown`, never a false `closed`); Kev-4B need 4033 + 256 headroom = 4289.

- Window **open edge ≈ 18:19:19.328** — the release of the external 8B tenant `critic3`
  (`Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf` on `:5803`, capture `/tmp/gpu-lease.RhM8QA`, 37,117 B, last
  written 18:19:19.328; the previous tick bracketed the release inside `(18:16:14, 18:20:30]`).
- Window **close edge 18:50:29.979** — the 4B rung's acquire (above). **Width = 31 m 10.651 s** (computed).
- The 9B rung could not close it: 6200 + 256 = 6456 needed against a drained card of 6126 MiB free
  ⇒ 330 MiB short, which is why six consecutive 9B rounds (17:50, 18:00, 18:10, 18:20, 18:30, 18:40) all
  exited `status=1/FAILURE` with 141–150 M peaks (not OOM). The 18:01 and 18:31 ticks pre-registered
  "58836 = the 18:50 round, pos 6 = 4B, closes this window" — measured: the 18:40 round failed as
  forecast, the 18:50 round closed it 20 min after the first refused 9B. Instance of
  `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`, no new class asserted there.
- **Live at write, three identical reads 18:56:1x/:2x/:3x: used 5273 MiB / free 2618 MiB of 8192**
  ⇒ **1671 MiB UNDER** the gate ⇒ CLOSED, HELD. Occupants: planner-4b pid 227142 3482 +
  unleased Bonsai demo pid 2434 1364 + vision LFM2.5-VL pid 2436 134 (`--n-gpu-layers 0`).
  `used + free = 7891` vs `memory.total 8192` = the standing ~300 MiB driver reservation in neither column.

## Absentees (measured, not assumed)

`grep -ril -E 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` = NO MATCH (rc 1); `scopes/` =
`planner` ONLY; `lease.d/` ABSENT; no `kev`/`arcade`/`model-test` process; no listener on the co-residency
test's own raw ports (only `:8080` llama-swap and `:5806` planner-4b). Kev artifacts stand at
`kev_run_bundle_full.json` 2026-10-12 22:41:49 and `coresidency_d1_kev.json` 2026-10-15 12:50:41
⇒ no Kev run in this window. Llama's self-authorized poll is ALIVE and beating under this write
(`profiles/llama/cron/ticker_heartbeat` 18:53:23.954, `ticker_last_success` 18:53:23.964).

## Action taken

NONE — no lease taken, no model loaded, no run triggered, no agent messaged; `gpu-lease.sh`,
`llama-swap.yaml`, the planner lease and the driver untouched (read-only). No `@llama` page (he
self-authorizes; the window closed before any page could arrive, and the premise `free >= 4289` is false
by 1671 MiB and would be false at receipt). No `@ocho` page (no global→planner flip in this diff; his
scoped-planner item was closed in HIS rows — `state.db` ids 9249 user / 9267 assistant, 2026-10-13, re-read
this tick — and a DM into a closed item is the drop-hazard class).

**Extends** `2026-10-13-a-scope-record-outlives-its-holder` (which established existence ≠ liveness for the
*confirming* read) with the **detector** half; **distinguishes**
`2026-10-14-a-constant-token-over-a-two-holder-rotation` (a constant token over two *live* holders — a
rotation) from this tick (one value over a **dead→live** transition — an acquisition the token cannot
announce, immediately after the same token announced three acquisitions that never lived).

## RECURRENCE 2026-10-20 08:19 PDT — the flip itself, not only a constant token, fires on a refusal

**Diff:** `planner_at none -> planner` (a real flip of the very token this ruling is about), `kev_window=open`
unchanged. Edge dated by artifact to **08:10:09.370** (`scopes/planner/record.json`, 490 B, sha256
`8683556c…`, `owner=llama-swap-ocho-planner · need_mib 6200 · pid 13732`), bracket `(08:07:59, 08:18:41]`.

**The increment this ruling did not yet have.** On 2026-10-19 the token was *already* `planner`, so its
early firing was invisible as a diff; an instruction keyed to a `global→planner` **flip** would have stayed
silent. After the 08:00:44 reboot emptied `scopes/`, the token was `none` — so the first **refused** 9B
acquire (cycle 58920 pos 0, needs 6200+256 = 6456 vs **6061** free = 395 MiB short; unit
`status=1/FAILURE` 08:10:09, `llama-swap` `group: starting ocho-planner failed: aborted`, 184.4 M peak)
**manufactured the flip**. The holder it names was dead on three independent reads (`/proc/13732` absent,
`/running` = `{"running":[]}`, every model `unloaded`), and the next round repeated it (08:20:09, pid 19053
also dead, cycle 58921).

**Rule (extends R1, same mechanism, sharper consequence).** A post-boot `global→planner` flip is not weak
evidence of liveness — it is the **expected signature of a refusal**, because after a reboot puts the token
at `none`, the first 9B pick on a card 395 MiB short writes the record and loads nothing. Any instruction of
the form "`planner_at` global→planner means the scoped flip is confirmed live, now message X" must be
rewritten to fire on the *liveness* read (`/proc` + resident compute app + the round's exit status), never on
the token; and a watcher author should assume the flip happens at least once per boot for arithmetic reasons
alone.

**Action taken:** NONE — no `@ocho` (premise false on three reads; his item closed in HIS rows, `state.db`
ids 9249 / 9267), no `@llama` (not a kev edge; poll beating at 08:20:40; fallback unsatisfiable by
construction per `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` R1), no lease, no
model, no run. `priorart.py` before filing: 281 records, max weak 0.127 / 0.094, all read by eye and
distinguished — recorded as a recurrence, not a second ruling.
