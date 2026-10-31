# A window whose horizon straddles the shadow timer has no clock arm

**Date:** 2026-10-29 · tick `arcade-window-watch`, job `67530e415818`, sample `18:13:20.037837658` PDT
**Diff:** `kev_window=closed → open` · `planner_at=planner` **IDENTICAL both sides** → no flip, no `@ocho` DM
**Nature:** RECORD ONLY. No acquire, no release, no model load, no unit touched, no message. Llama self-authorises at `--scope arcade` when free ≥ 4289 and self-runs; this tick does not preempt his poll.
**Method:** every number below is a read taken this tick — `nvidia-smi` (six timed reads), `--query-compute-apps`, the lease tree (`record.json`, `stat`, `sha256sum`), `/proc` and `ps` for the holder pids, `journalctl --user -u ocho-planner-polymarket.service` and the unfiltered user journal 17:34–18:14, the pick log `chilly_containment/agents/ocho/logs/ocho_planner_polymarket.log` (line numbers cited), `model_cycle_counter.txt`, `llama-swap.log` as text, `systemctl --user list-timers`, `/dev/tcp` probe of `:5806`, `sqlite3 -readonly` on Ocho's rows. Nothing is recalled from a prior tick.

## 1. What changed, and the edge dated

```
previous   planner_at=planner  kev_window=closed   (2026-10-29_18-02-20.md, 155 B no_change, 18:02:20.080)
current    planner_at=planner  kev_window=open     (monitor_last_output.txt, 34 B, 18:13:20.037838, sha256 8da24188…9216fe2)
```

The open edge is **`18:10:19.390`** — the birth of the planner record left by the `18:10` round, which drew the 9B and exited `status=1/FAILURE` at `18:10:19`:

| read | value |
|---|---|
| pick | log line 245307 `ocho-planner (60% weight, cycle 60410, pool 3/3)` → `60410 % 10 = 0` → pos 0 = 9B |
| counter | `model_cycle_counter.txt` = `60411`, mtime `18:10:18.952794035` (read-then-incremented, 437 ms before the record) |
| service | `18:10:13 Starting → 18:10:19 status=1/FAILURE`, 3.163 s CPU / 6.170 s wall / 143.1 M |
| record | `scopes/planner/record.json` 491 B, ino `10272179` (recycled, cited before), birth `18:10:19.390105513`, sha256 `689a9d3a…b12133`, owner `llama-swap-ocho-planner`, need 6200, headroom 256, pid `470879` **absent from `/proc`** |

So the token that flipped the line is an **orphan**: the admitted need is `6200 + 256 = 6456` against a card whose empty scope reads **5893** — **563 MiB short in every state of this card today** — and its pid is dead. `planner_at=planner` here is evidence that a 9B was *refused*, never that the scoped-planner flip is live (`2026-10-29-an-open-edge-and-its-orphan-token-are-one-event` R2, cited not re-argued).

## 2. The closed span it ends is the wheel's closing block, a third time

`17:30:12.948` (the close recorded by the 17:40 tick) → `18:10:19.390` = **2406.44 s = 4.0119 × 600 s**, over four picks that are one-per-round:

| pick | slot | round | card |
|---|---|---|---|
| `60407` | 4B (pos 7) | `17:40:06 → 17:40:14 Finished`, 3.254 s / 8.148 s / 143.1 M | resident from the 17:30 load — no load, no lease |
| `60408` | 4B (pos 8) | `17:50:07 → 17:50:15 Finished`, 3.274 s / 8.151 s / 143 M | same resident |
| `60409` | smol (pos 9) | `18:00:15 → 18:00:24 status=1/FAILURE`, 3.192 s / 9.029 s / 143.1 M | **the 18:02:20 sample still reads CLOSED** |
| `60410` | 9B (pos 0) | `18:10:13 → 18:10:19 status=1/FAILURE` | card empty at 18:13:20 |

Both prior closed spans today were the same shape — `2396.8 s = 3.995` (12:10→12:50) and `2395.71 s = 3.9929` (14:10→14:50) — so the closing block is `[4B, 4B, smol, 9B]` and measures ~4.00 rounds; the residual 6–10 s is capture/acquire latency, not drift. One pick per round is confirmed for this span by the journal: four service bands, four pick lines, no run drawing twice.

## 3. R1 — The holder the 9B stopped is a CANDIDATE SET on disk, not a fact

The `18:02:20` sample read CLOSED, which is only possible with `used > 3903` MiB; the present census is **1998 used** (1724 tenants + 301 driver). So ~1906 MiB or more was resident at `18:02:20` and gone by `18:13:20`, and the only card-touching event in between is the `18:10` 9B draw. The pick log names the rung drawn one round earlier (pos 9 = **smol**, lease need 3000; the 14:40 smol read 3216 free ⇒ ~2677 MiB in-card) but **cannot decide whether the 9B stopped that smol or the 4B (3482 MiB)**:

- the lease record is a **single slot** — the refusal's own record was written at `18:10:19.390`, destroying the holder's record in the same instant (`2026-10-29-a-forecast-is-scored-on-the-counter-and-the-interior-refusals-leave-no-record` R3);
- `llama-swap.log` carries **no timestamps** (last line `18:10`, `group: starting ocho-planner failed: aborted`), so no unload can be second-dated;
- the memory bands do not discriminate: the failed smol round printed **143.1 M**, the successful 4B load **143.1 M**, the 4B closes **143.4 / 143.2 M** — ranges that contain each other, the fifth time (`2026-10-24-a-failed-rounds-duration-does-not-say-whether-it-evicted-a-resident` R1, still binding).

Rule: **at an open edge, report the evicted holder as the set the pick log allows — {smol ~2677–3000, 4B 3482} — and say the mechanism (group stop) is attributed, not measured.** The one thing the samples do establish is that the `18:00` smol round's failure did **not** empty the card (18:02:20 still closed), so "a failed round still moves the card" is true only of the round whose draw needed the card's whole budget, not of every `status=1`.

## 4. R2 — This window's horizon straddles the shadow timer, so its clock arm is not issuable

Forward: the first draw that fits is pos 6 (4B, `4056` vs 5893 = 1837 spare; the 9B's 6456 is 563 short in every state). From the counter's post-18:10 value **60411**, the first pos-6 value is **60416**.

But `ocho-shadow-polymarket.timer` is `OnCalendar=*-*-* 1/6:00:00`, last `13:00:15`, **next `19:00:00`** — 43 minutes away, *inside* this window's ~60-minute nominal width. The shadow service makes per-market planner calls that each read-and-increment the same counter (measured +9 at 13:00: `grep -c 'Calling planner'` on its block), so:

- the close is `first pos-6 draw at or after 60416 + N_shadow`, and **`N_shadow` does not exist at issue time**;
- therefore the clock arm ("~6 rounds ≈ 60 min") is **not issuable for this window** — only the counter expression is, with the value to be read from the 19:00 block;
- this is the first window today whose horizon contains a shadow run (the 15:52 forecast verified the guard *empty*: next shadow 19:00 fell outside a 60-min horizon). `2026-10-29-the-shadow-run-advances-the-wheel-by-its-own-call-count` R2 required the guard be checked at issue; the increment is that when the guard **fails**, the forecast has a different shape rather than a larger constant: state the counter expression and name the block whose `Weighted pick` count fills it.

Falsifiers, both one-line: a `pool 2/3` line (a demoted slot re-phases the wheel; all lines read `pool 3/3`), or a 9B that fits (563 MiB short at this census).

## 5. Live card, three identical reads `18:13:25 / 18:15 / 18:15`

`8192 total / 1998 used / 5893 FREE / 8–12 % / 39–40 °C` ⇒ **OPEN by 1604 MiB** over the 4289 gate (`4033 + 256`, `arcade_window_watch.sh:47`, sha256 `775c4858…6e0e8e`, unmodified since 2026-10-13). Compute apps: Bonsai `2347` 1364 + vision `2349` 134 + bge-small `87744` 226 (**all `-ngl 0`, unleased**) = **1724**; `used + free 7891` ⇒ driver **301**; empty-scope ceiling **5893**, unchanged from 11:15 / 12:59 / 14:56 / 17:39 on the identical census — the ceiling travels with its census, not with the clock. `:5806` refused, `/running` `[]`, both planner pids absent.

## 6. Messages: none, and both premises measured

- **No `@ocho`.** `planner_at` is identical on both sides, so the flip branch never fires; and a positive reading would be false at write — the record's admission need (6456) exceeds the card (5893) by 563 MiB and its pid is dead. His scoped-planner item is closed in **his own rows**: `profiles/ocho/state.db` mtime `07:42:24.538` (untouched since boot), `max(id)=17405`, ids 9249/9267/16736. A DM would re-open a closed item into a channel that drops on `target_busy` with no receipt (`2026-10-29-a-forecast-is-scored-on-the-counter-and-the-interior-refusals-leave-no-record` R5).
- **No `@llama`.** This is the **first sample** of the window (edge 3 minutes old, less than one round inside it); the fallback condition is a window untaken across several ticks. He self-authorises at `--scope arcade`. Away side measured ABSENT: `scopes/` = planner only, `lease.d/` does not exist, `pgrep -af 'kev|model-test|arcade'` matches only this tick's own shell.

## 7. Standing flag for Mike, re-measured `18:14`

`profiles/llama/cron/` still has **no `jobs.json`** (`executions.db` 24576 B frozen `2026-10-12 06:33:07.322361061`, `output/` untouched since 10-12) while `ticker_heartbeat` and `ticker_last_success` were rewritten `18:14:18` — a live clock over an EMPTY JOB SET. The card is now above the Kev gate by 1604 MiB, predictably, and nothing executes the operator-approved precedence clause in it: an execution fact, not a Kev decision, and this watcher creates no jobs. The one lever stays the unleased `-ngl 0` tenant set (1724 MiB), read as a fact about the card and **not** an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6).

## 8. Read-only throughout

`gpu-lease.sh` (status/read only), `llama-swap.yaml`, `scopes/planner/` (read, not written — the dead 18:10:19 record is left in place under its own liveness-first policy), the planner unit and timer, all three tenants, the driver, `call_ocho_planner.py`, `model_cycle_counter.txt` (read only) and every unit untouched. No acquire, release, load, reservation, config edit or job. The `18:00` smol attempt and the `18:10` 9B refusal were the timer's own `*:0/10` requests through llama-swap.

Prior art printed by `priorart.py` **before this file existed** (rulings corpus, two phrasings): max weak `0.172 2026-10-29-a-failed-round-still-moves-the-card-and-the-forecast-guard-is-a-timer` (read; this tick bounds it to the round whose draw needed the whole card), `0.122 2026-10-24-a-failed-rounds-duration-does-not-say-whether-it-evicted-a-resident` (read in full; owns the non-discriminating band and the bracketing rule, extended here to the holder's identity), `0.399 2026-10-29-an-open-edge-and-its-orphan-token-are-one-event` (owns the open-edge class, cited), `0.090 2026-10-29-the-shadow-run-advances-the-wheel-by-its-own-call-count` (guard required at issue; this is the first instance where the guard fails and the forecast changes shape). None states that a failed non-9B draw does not empty the card, that the evicted holder is only a candidate set on disk, or that a strided horizon has no clock arm.
