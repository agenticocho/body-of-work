# A constant token over a two-holder rotation

**Date:** 2026-10-14 · **Instrument:** the Arcade GPU co-residency watcher (`arcade-window-watch`, cron `67530e415818`), monitor sample `2026-10-14T10:07:55.27-07:00`
**Trigger:** a tick whose diff is `planner_at=planner` + `kev_window closed->open` — the planner token **unchanged** while the thing under it changed twice.

## What was measured (read from disk, no remembered numbers)

| read | value |
|---|---|
| monitor sample 10:07:55 | `planner_at=planner kev_window=open` (used 3352 / **free 4539 MiB** of 8192) |
| live reads 10:08:05 / :07 / :09 | **4539 / 4539 / 4539 MiB free** (three identical) ⇒ open AND held, ≈8 min into the window |
| lease time of the open read | `scopes/planner/record.json` mtime 10:00:36.346 — `owner=llama-swap-ocho-planner-smol`, `scope=planner`, `class=batch`, `need_mib=3000`, `mode=run`, `pid=53204`, `acquired_at=1791997236` (10:00:36) |
| holder liveness + resident app | `pid 53204` ALIVE (`bash gpu-lease.sh run … --scope planner --need-mib 3000 -- llama-server --port 5808 --model SmolLM3-3B-128K-UD-Q4_K_XL.gguf`); resident child `pid 53299` **2672 MiB** on `:5808`; `llama-swap /running` = `ocho-planner-smol`, `state=ready` |
| the round that slot served | `plans/latest_plan.json` mtime **10:00:41.867**, `"model_slot": "ocho-planner-smol"`; `ocho-planner-polymarket.service` 10:00:22 → Finished 10:00:41 (6.8 s CPU / 19.3 s wall) |
| occupants at the open read | planner-smol 2672 + MiMo-eval `llama-server` pid 52427 **352 MiB** (`--n-gpu-layers 0`, api-key `injtest`, started ≈09:58:28, **no lease record**) + vision pid 2395 134 + gnome-shell 91 + gnome-software 31 + Xwayland 3 + Hermes 3 |
| **write** 10:10:56 | used **6554** / **free 1337 MiB** (three identical) ⇒ **window CLOSED, 2952 MiB under the 4289 gate** |
| what closed it | `record.json` mtime 10:10:31.363 — `owner=llama-swap-ocho-planner`, `need_mib=6200`, `pid=58729` ALIVE; resident child `pid 58828` **5874 MiB** on `:5805` (Qwen3.5-9B-UD-Q4_K_XL); `/running` = `ocho-planner` ready; plan `model_slot=ocho-planner` 10:10:40; round 10:10:22 → Finished 10:10:40 |
| other leases | `scopes/` = `planner` ONLY (two successive owners); `lease.d/` ABSENT; **no `arcade` / `kev` / `llama-model-test` lease in any scope at any read** |
| Kev | `kev_probe.json` 2026-10-12 22:41:02, `kev_server.log` 22:41:18, `kev_run_bundle_full.json` 22:41:44/49 ⇒ no Kev run in this window |
| target (Ocho) | newest inbound row `profiles/ocho/state.db` = 2026-10-13 20:05:46; closure row 10-13 17:49:44, his reply 17:54:07; newest outbound delivery 2026-10-13 18:08:37 ⇒ nothing owed |
| interval | opened ≈**10:00:27** (4B stopped, smol started) → closed ≈**10:10:22–31** (9B started) = **≈10 min** |

## Rulings

**R1 — a constant token can sit over two complete holder changes.** `planner_at=planner` read identically at both ends of this tick while the thing it names changed owner, need, footprint and pid: `…-planner-smol / need 3000 / pid 53204 / 2672 MiB` → `…-planner / need 6200 / pid 58729 / 5874 MiB`. The token carried **opposite truth** at its two ends — free 4539 (open) then free 1337 (closed) — so this is the sharpest instance yet of *diff the measured quantity, never the token* (extends `2026-10-13-an-instrument-recovery-is-not-a-subject-transition`). A lease-**location** test has no field for which holder is sitting on that location.

**R2 — the monitor cannot see the planner's SLOT LADDER, and the ladder is what moves the window.** The ladder walk is datable only from the per-round artifact `latest_plan.json.model_slot` plus the lease records: 09:30 / 09:40 / 09:50 rounds served by `ocho-planner-4b` (filed 09:36, 09:53), **10:00 by `ocho-planner-smol`**, **10:10 by `ocho-planner` (9B)**. So inside 40 min the planner walked 4B → smol → 9B while `planner_at=planner` throughout, and `kev_window` moved for a reason entirely inside that ladder: **the window IS the ladder's bottom rung.** Report a window with the rung named, never as a bare free number.

**R3 — the smol rung's margin is thinner than one ordinary tenant.** Measured: smol 2672 resident ⇒ **free 4539 = +250 MiB over the 4289 gate**; and on the same card at the same instant sit occupants the lease ledger does not cover — MiMo-eval `llama-server` pid 52427 **352 MiB** with no record (its own command line says `--n-gpu-layers 0`, i.e. a "CPU-only" harness that is on the card), gnome-shell 91, vision 134, gnome-software 31. A single extra tenant of >250 MiB closes the window **even against the smallest rung**, and 164 MiB above it the 4B rung already fails (4125 free, filed 07:58). The gate is satisfied by exactly one configuration on this 8192 MiB card: the planner on its smallest slot, on an otherwise quiet card. (Extends `2026-10-14-a-certified-lease-is-not-certified-work` R2 and the 2026-10-13 finding that the ledger's coverage is not the card's coverage.)

**R4 — a window open at the sample *and* at live reads minutes later can still be closed at the write; the terminus is the ladder's next move up, not a duration.** This window was open for ≈10 min, sampled open at 10:07:55, and confirmed open by three live reads at 10:08:05/07/09 — then closed by 10:10:56 when the 9B re-acquired at 10:10:22–31. So it was **not** a sub-tick blink, and the fallback ping's premise was *true for ten minutes* and *false at read*. The discipline that follows is scale-free: the @llama fallback clause must be evaluated against the live reading at write (hold-one-tick), and the record must carry the **interval**, not the endpoints — otherwise a ten-minute window and a 70-second gap read the same in the log.

**R5 — instrument limits and one anomaly, both measured (record-only).** (a) `chilly_containment/logs/llama-swap.log` carries **no timestamps**, so the group's fallback attempts (`group: starting ocho-planner failed: aborted`, `non-200 … status=500`) cannot be dated from that artifact at all; the ladder walk is datable only from `latest_plan.json` (one file, per round) and the lease records. An undatable log cannot tell a stalled fallback from an old one. (b) In **both** holders this tick the ledger's acquisition stamp is ≈9 s *later* than the observable process start — smol: wrapper/model processes at 10:00:27/28 (`ps -o etime`) vs `acquired_at` 10:00:36.346; 9B: processes at 10:10:22 vs `acquired_at` 10:10:31 — so the ledger's clock for a grant is not the grant's effect clock. Date a window's open from the **process**, and do not read this ~9 s lag as a failed acquire.

## Disposition

- **No run action** — nothing acquired, no model load; `gpu-lease.sh`, `llama-swap.yaml` and the planner lease untouched (read-only).
- **No `@llama` ping.** Premise false at read: free 1337 MiB, 2952 under the gate. He self-authorizes under the operator precedence clause and polls continuously.
- **No `@ocho` DM.** The diff is `kev_window`, not a `planner_at global->planner` flip, and his item was closed to him on 2026-10-13 (inbound row 17:49:44, his reply 17:54:07); no outbound delivery newer than 2026-10-13 18:08:37. 13th consecutive stand-down of the class.
- **Kev absence, dated:** no `arcade`/`kev`/`llama-model-test` lease in any scope at any read; all Kev artifacts mtime 2026-10-12 22:41 ⇒ the gate was met (4539 ≥ 4289) with the ledger empty — recorded as *poll not firing*, not acted past.
- **Flagged to Mike (not applied):** the planner's ladder is walking down to the smol rung and back up across rounds (4B→smol→9B in 40 min); the ~10-minute Kev window exists **only** because the planner was degraded to its smallest slot, and even then the margin is +250 MiB — under the footprint of the unledgered eval tenant sharing the card.
