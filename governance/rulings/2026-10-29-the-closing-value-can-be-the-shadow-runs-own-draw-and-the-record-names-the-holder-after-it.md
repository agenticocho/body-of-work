# The closing value can be the shadow run's own draw, and the record names the holder after it

**Date:** 2026-10-29 · tick `arcade-window-watch`, job `67530e415818`, sample `19:02:19.923572` PDT
**Diff:** `kev_window=open → closed` · `planner_at=planner` **IDENTICAL both sides** → no flip, no `@ocho` DM
**Nature:** RECORD ONLY. No acquire, no release, no model load, no reservation, no unit or config touched, no message. Llama self-authorises at `--scope arcade` when free ≥ 4289 and self-runs; this watcher does not trigger a run.
**Method:** every number below is a read taken this tick — `nvidia-smi` (four timed reads), `--query-compute-apps`, `ss -ltnp`, the lease tree (`record.json`, `stat` with `%w`, `sha256sum`), `/proc`+`ps` for the holder pids, `/tmp/gpu-lease.*` captures, `journalctl --user` (unfiltered, 18:15–19:03), the pick log `chilly_containment/agents/ocho/logs/ocho_planner_polymarket.log` (line numbers cited), the shadow log `…/ocho_shadow_polymarket.log`, `ocho_sandbox/model_cycle_counter.txt`, `ocho_sandbox/plans/latest_plan.json`, `ocho_predictions.jsonl`, `curl :8080/running`, `sqlite3 -readonly` on Ocho's rows. Nothing is recalled from a prior tick; the open edge is cited from the 18:13 filing because the record that dated it has since been overwritten.

## 1. What changed, and the edge dated

```
previous   planner_at=planner  kev_window=open     (2026-10-29_18-51-20.md, 155 B no_change, still reading the 34 B open line sha256 8da24188…9216fe2)
current    planner_at=planner  kev_window=closed   (monitor_last_output.txt, 36 B, 19:02:19.923572, sha256 b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1)
```

The 36 B line is byte-identical to every closed sample filed today, and the 34 B line it replaced was byte-identical to every open sample — a hash certifies the string, never the referent.

**Close edge `19:01:19.403`**, and it is a **load that fits**, not a refusal:

| read | value |
|---|---|
| invoking unit | `ocho-shadow-polymarket.service`, `19:00:09 Starting → 19:01:29 Finished`, exit 0, 3.734 s CPU / 79.587 s wall / 152.6 M |
| draw | counter `60416` → `60416 % 10 = 6` → pos 6 = **4B** |
| capture | `/tmp/gpu-lease.QQcC5A` birth `19:01:18.250465528`, `model loaded` at `+0.01.152.836` ⇒ **`19:01:19.403`**, `listening on http://127.0.0.1:5806` |
| service evidence | prediction rows `2026-10-30T02:01:22.127884Z` and `02:01:24.187546Z`, `model_slot ocho-planner-4b` |

Free VRAM goes from the open-window reading of `5893` (18:13–18:15) to `3216` at write: a 3482 MiB rung admitted above the 4289 gate cannot co-exist with Kev-4B.

**The open edge** is `18:10:19.390` — the record birth left by the `18:10` round, which drew the 9B (`cycle 60410`, pick log line 245307) and exited `status=1/FAILURE` at `18:10:19` (`18:10:13 Starting`). Width `18:10:19.390 → 19:01:19.403` = **3060.013 s = 5.100 × 600 s**.

## 2. The interior is five 9B refusals, then the closing value — which the shadow run consumed

| pick | slot | round | card |
|---|---|---|---|
| `60411` | 9B (pos 0…5) | `18:20:11 → 18:20:17 status=1`, 3.139 s / 6.053 s / 143.3 M | refused |
| `60412` | 9B | `18:30:00 → 18:30:06 status=1`, 3.134 / 6.060 / 143.2 M | refused |
| `60413` | 9B | `18:40:03 → 18:40:09 status=1`, 3.131 / 6.019 / 143.2 M | refused |
| `60414` | 9B | `18:50:06 → 18:50:12 status=1`, 3.150 / 5.780 / 143.3 M | refused |
| `60415` | 9B | `19:00:09 → 19:00:18 status=1`, 3.184 / 8.620 / 143.1 M | refused |
| **`60416`** | **4B (pos 6)** | shadow unit's 1st call, ~`19:01:18` | **LOADED `:5806` ⇒ CLOSE** |
| `60417` | 4B (pos 7) | shadow unit's 2nd call | resident reuse, no load (`2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`) |
| `60418` | 4B (pos 8) | shadow unit's 3rd call | `[shadow-llm] Planner failed (exit=1)` — **no card event** |
| `60419` | smol (pos 9) | shadow unit's 4th call | evicted the 4B, loaded `:5808` at `19:01:27.882` |

`model_cycle_counter.txt` = **`60420`**, mtime `19:01:26.752492900` — one file, last increment only, so it dates the fourth call and destroys the first three (`2026-10-22-a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed` R3). The pick values are reconstructed from the counter's read-then-increment order plus the two `model_slot` rows and the two capture births; the 4/4 call-to-value correspondence is exact (4 `Calling planner` lines, 60415 → 60420).

**The 18:13 forecast is scored here, not re-derived.** That filing named the value and refused a clock arm because the `19:00:00` shadow timer sat inside the horizon: *"close = first pos-6 draw at or after `60416 + N_shadow`, `N_shadow` nonexistent at issue."* Measured: the close landed on **exactly `60416`** (counter arm TRUE), and `N_shadow` was not an additive delay at all — the shadow run **was the consumer of the closing value**, so the close happened at `19:01:19`, nine minutes before the `19:10` main round that a clock-shaped forecast would have named.

## 3. R1 — A counter-value forecast names a DRAW; the consumer that takes the value fixes the clock

The 15:52 filing scored a forecast on the counter; the 18:13 filing could not issue a clock arm when a shadow run sat inside the horizon and told the next tick to state the expression and count the block. This tick answers that with a measurement the expression did not anticipate: the shadow run's increments do not sit *between* the closing value and its realization — one of them **is** the closing value. Durable form: **issue the value, then name the first consumer at or after it** (main round or shadow call); `N_shadow` is the number of values the shadow takes, and if the closing value falls inside that count the close precedes the next main round rather than following it. Corollary for scoring: the counter arm and the clock arm are scored against different objects — the file's value against the counter, the second against the consumer's own start.

## 4. R2 — The closer can be evicted by its own run's next draw, so the record's owner is not the closer

The 4B that closed the window at `19:01:19.403` was gone **8.479 s later**, displaced by the same service's fourth call (pos 9 smol, `19:01:27.882`). The record at the sample therefore names a holder that did **not** close the window: `scopes/planner/record.json` 496 B, ino `10272179` (recycled — cited, not identity), birth `19:01:27.027376237`, dir birth `.023376277`, sha256 `1772cad87c539d865f5ac253588965da5b6049dc75de239d572ce3a436db8152`, owner `llama-swap-ocho-planner-smol`, need 3000, headroom 256, pid `507797` **ALIVE** (lstart `19:01:26`, child `507890` 2672 MiB, `LISTEN :5808`), `:5806` has no listener and no wrapper pid. This extends `2026-10-22-a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed` R1 — there the unit identification was the increment; here the *holder by that rule* had already been replaced before any sample could read it, so a close must be dated on the **capture birth of the draw that fits**, and the surviving record read as "who holds now", never "who closed". It also re-confirms the 15:52 R3 in a new direction: the single-slot record destroys not only an interior refusal's token but a *closer's* token, 8 s after the fact.

## 5. R3 — A shadow-call failure is not a card event

Call 3 (`60418`, pos 8 = 4B) exited 1 while the 4B was resident and listening on `:5806`, one call before a successful smol load. That bounds the 18:13 R1 {smol ~2677–3000, 4B 3482} candidate set from the other side: an exit 1 can occur with **zero** occupancy change inside a run that also loads, so neither exit status nor the 143 M peak band (now non-discriminating a sixth time: refusals 143.1–143.3 M here) says anything about the card without a capture and a live pid.

## 6. Live card at write

Four reads between `19:02:25` and `19:05` were identical — `8192 total / 4675 used / 3216 FREE / 7, 9, 12 % / 40, 41, 41 °C` ⇒ **CLOSED by 1073 MiB** under the 4289 gate (`4033 + 256`, branch read this tick at `scripts/arcade_window_watch.sh:47`). Census: Bonsai `2347` 1364 + vision `2349` 134 + bge-small `87744` 226 (all `-ngl 0`, unleased) + smol `507890` 2672 = **4396 attributed**; `used + free = 7891`, so 301 MiB sits in neither column; empty-scope ceiling = `3216 + 2672 = 5888` ⇒ 9B `6456` is **568 short** in every state of this card, 4B `4056` has 1832 spare, smol `3256` has 2632. `lease.d/` **absent** (no global lease), `scopes/` = `planner` only.

**Productive close:** `plans/latest_plan.json` 1171 B mtime `19:01:29.148979393` and three prediction rows at `19:01:22` / `19:01:24` / `19:01:29` — the 2672 MiB bought three plans, in contrast to the refusal-opened windows on file that produced none.

## 7. Absentees, messages, and the standing flag

**Kev took nothing.** The window stood open **3060 s** at `5893` free = **+1604 MiB** over his gate, across five main rounds and the shadow run, and nothing acquired: `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` → **rc 1, no match**; `scopes/` = `planner` only; `lease.d/` absent; no `llama-model-test` record anywhere in the tree. He self-authorises at `--scope arcade`; recorded, not messaged.

**Messages: none, both premises measured.** No `@ocho` — `planner_at=planner` on **both** sides, so the flip trigger never fired; his item is closed in his own rows (`sqlite3 -readonly profiles/ocho/state.db` → `max(id)=17405`, count `17405`, unchanged), and a DM would re-open a closed item into a channel that drops on `target_busy` with no receipt. No `@llama` — this is a **close** edge, `3216` is 1073 MiB the wrong way, and a page would be false before it was written; his poll is authorised to act and a fallback is for an open window untaken across several ticks.

**Standing flag for Mike, re-measured `19:04`:** `profiles/llama/cron/` has **no `jobs.json`** (`executions.db` 24576 B frozen `2026-10-12 06:33`, `output/` untouched since 10-12) while `ticker_heartbeat` 23 B is rewritten every tick — a live clock over an **empty job set**, so the operator-approved precedence clause still has no executor. Execution fact, not a Kev decision; this watcher creates no jobs. The one lever stays the unleased `-ngl 0` set 1724 MiB, a fact about the card and **not** an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6).

**Read-only throughout:** `gpu-lease.sh` read only, `llama-swap.yaml`, `scopes/planner/`, the planner unit/timer, the shadow unit, all four compute processes and the driver untouched; no acquire, release, load, reservation, config edit or job. The `19:01` loads were the shadow unit's own requests through llama-swap.

**Prior art printed before this file existed** (`priorart.py rulings`, 526 records, two phrasings): max weak `0.128 2026-10-21-a-counter-read-at-a-rounds-end-names-the-next-round` (label mapping), `0.123 2026-10-22-a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed` (read in full; owns the close-belongs rule, extended in R2 above), `0.119 2026-10-29-a-forecast-is-scored-on-the-counter-and-the-interior-refusals-leave-no-record`, `0.109 2026-10-27-a-forecast-names-the-round-and-the-second-it-names-is-the-loads`, `0.080 2026-10-29-the-shadow-run-advances-the-wheel-by-its-own-call-count` (owns the call-count mechanism, not the consumption of the closing value), parent `2026-10-29-a-window-whose-horizon-straddles-the-shadow-timer-has-no-clock-arm` (its forecast is scored here), plus `2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load` and `2026-10-29-a-round-count-is-anchored-to-the-open-edge-not-the-sample`. No record states that the closing value can be consumed by the shadow run itself, and none states that the closer's record token can be destroyed by its own run's next draw.

RULINGFILE rulings/2026-10-29-the-closing-value-can-be-the-shadow-runs-own-draw-and-the-record-names-the-holder-after-it.md
