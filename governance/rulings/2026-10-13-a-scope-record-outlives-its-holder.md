# A scope record outlives its holder

**Date:** 2026-10-13 · **Instrument:** `~/.local/state/gpu-lease` (gpu-lease.sh) + the Arcade co-residency watcher
**Trigger:** the watcher's `planner_at` line and a stale `mode=run` record that made the flip look live while the card was empty.

## RULING

A lease record's EXISTENCE is a claim that an attempt was made — not that a holder is live. `gpu-lease.sh` writes `record.json` with `pid=$$` in `take_lease`, i.e. **before** the wrapped command starts, and removes it only from `do_run`'s EXIT/INT/TERM trap. A wrapper that is SIGKILLed — or reaped by llama-swap when a wrapped load fails — never runs that trap, so a `mode=run` record with a DEAD pid and an `expires_at` 24 h out can sit on disk indefinitely.

The watcher's `planner_at` test is `[ -f "$STATE/scopes/planner/record.json" ]`. That is an existence test on the wrapper's *attempt*, and it cannot distinguish a live scoped holder from a dead one. Its own comment ("only exists once a model loads with --scope planner") is the overclaim: the record exists once a model *starts to* load.

## WHAT IT COST (the near-miss this is written from)

At 17:10:07 PDT the first scoped planner acquire wrote `scopes/planner/record.json`. The load failed — llama-swap logged `<ocho-planner-4b> proxy error: EOF`, then `status=502` — and the Ocho planner round failed at 17:10:21. The wrapper died; its record stayed. At 17:17 the disk read was:

* record present: owner=llama-swap-ocho-planner-4b, scope=planner, need_mib=3800, pid=90276, mode=run, acquired 17:10:07
* `/proc/90276` ABSENT · nvidia-smi 277 MiB used / 7561 MiB free · nothing listening on :5806

So `planner_at=planner` held over an **empty card**. The monitor's stored previous state was satisfied by exactly this stale record. Closing "the scoped-planner flip is confirmed live" off that read would have certified a flip that was not serving anything.

The genuine holder arrived at 17:20:27 (pid 98521 alive; child llama-server pid 98590 resident on 127.0.0.1:5806 holding 3482 MiB) and the 17:20 round completed end-to-end. That is the event that confirms the flip.

## RULE

1. Confirm a scoped lease with **three** reads, never one: the record, the holder's liveness (`kill -0`, or `gpu-lease.sh status`'s own `mode=run pid=…` line), and a resident compute app on the card (`nvidia-smi --query-compute-apps`).
2. The lease's own policy already states it — a `mode=run` holder whose pid is dead is reclaimable. Treat a dead-pid record as history, not as state.
3. When the stored previous state of a change-detector could have been satisfied by a stale record, name the read the claim rests on, and correct any earlier line that certified the transition from the record alone.

## EVIDENCE (read 2026-10-13 17:17–17:23 PDT)

| read | stale (17:10 attempt) | live (17:20 attempt) |
|---|---|---|
| `scopes/planner/record.json` | pid 90276, acquired_at 1791936607 = 17:10:07 | pid 98521, acquired_at 1791937227 = 17:20:27 |
| holder liveness | `/proc/90276` ABSENT | `/proc/98521` alive (wrapper), child 98590 alive |
| resident compute app | none on :5806 | llama-server :5806, 3482 MiB |
| card | 277 used / 7561 free | 3764 used / 4074 free |
| llama-swap `/v1/models` | ocho-planner-4b failing (proxy error: EOF → 502) | ocho-planner-4b status=loaded, /health 200 |
| planner round | 17:10 round ends in 502 ("Failed to get completion from llama-swap") | 17:20 round returns a completion; plan saved (latest_plan.json); prediction logged |

Corollary observed the same hour: the same existence-based reading flips `kev_window` open/closed around planner load/unload straddles, so a bare transition relay is still never the account — the live reading is.

## RECURRENCE 2026-10-20 — the false-positive interval, now measured (59 m 40 s)

The identical mechanism re-ran and this time its duration is on the record. The 06:30:29 round's record (`pid 583923`) was left by a failed load (`group: starting ocho-planner failed: aborted`, 141.1 M peak, not OOM) and stayed on disk with a dead pid while the monitor's `planner_at` read `planner` for **59 m 40 s** (06:30:29.877 → 07:30:10.026) over a card with **no resident planner**; five consecutive planner rounds in that hour failed (`06:40:09 / 06:50:06 / 07:00:33 / 07:10:29 / 07:20:33`, all `status=1/FAILURE`). The live confirmation then arrived in the 07:30 round (record rewritten 07:30:10, pid 615253 alive, resident 3482 MiB on :5806, round exit 0, plan written) — and **produced no change in the detector's token**, because the token had already been set by the dead attempt.

So the defect is sharper than "existence is not liveness": **the signal fires on the ATTEMPT, which makes it early by the length of the failed-acquire interval and silent at the event that confirms it.** A watcher keyed on it reports a flip that is not serving and never reports the one that does. The remedy is unchanged (record + holder liveness + resident compute app, all three in the same round), and the confirmation to the consumer must cite the round that HELD the slot, never the record that first named the scope. Log: `state/monitor/arcade_gpu_watcher.log`, entry `2026-10-20T07:34-07:00`.
