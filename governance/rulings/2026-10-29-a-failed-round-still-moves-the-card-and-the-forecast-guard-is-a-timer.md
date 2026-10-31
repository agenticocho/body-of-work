# A failed round still moves the card, and a wheel forecast's guard is a timer you can read

**Tick:** `arcade-window-watch`, job `67530e415818`, sample `14:55:19.951` (2026-10-29).
**Diff:** `planner_at=planner` **IDENTICAL on both sides** (no flip ⇒ **no @ocho**) · **`kev_window=closed → open`**.
**Bracket:** `(2026-10-29 14:44:20, 14:55:19.951]` — previous sample `2026-10-29_14-44-20.md` 155 B `Status: no_change (agent run suppressed)`; `monitor_last_output.txt` **34 B** mtime `14:55:19.951386868` sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`, body `planner_at=planner kev_window=open` (the same content hash as every open sample by construction).
**Nature:** RECORD ONLY. No acquire, release, load, reservation, unit or config touched. No message to either agent (§5, premises measured).

## 1. The live card

| read | total | used | free | util | temp |
|---|---|---|---|---|---|
| 14:56:0x / :1x / :2x (three reads) | 8192 | 1998 | **5893** | 5–7 % | 39 C |

Gate = **4289** (`4033 + 256`; `scripts/arcade_window_watch.sh:12,:47`, re-read this tick) ⇒ **OPEN by 1604 MiB**, three identical reads.
Compute apps: `2347` Bonsai **1364** + `2349` vision **134** + `87744` bge-small **226** = **1724**, all `-ngl 0`, unleased. `used + free = 7891` vs 8192 ⇒ driver **301**. Empty-scope ceiling **5893** ⇒ 9B `6456` = **563 SHORT**, 4B `4056` = **1837 spare**. `:8080/running` = `{"running":[]}`; **no listener** on `:5806`/`:5808`; no `arcade|kev|model-test` artifact (`grep -rliE` over `~/.local/state/gpu-lease` rc 1), `lease.d/` ABSENT, `scopes/` = planner only.

## 2. The open edge is the 14:50 9B refusal — and its record is an orphan

| read | value |
|---|---|
| deciding draw | log line **244102**: `[O55] 🎲 Weighted pick: ocho-planner (60% weight, cycle 60390, pool 3/3)` |
| counter | `model_cycle_counter.txt` **60391**, mtime `14:50:13.592143854` (post-increment for 60390) |
| record | `scopes/planner/record.json` **491 B** ino `10272179` (recycled — cited, `2026-10-23-an-inode-number-recycled-by-a-rename-replace-writer-is-not-continuity`) birth **`14:50:14.026514366`** sha256 `aea98eb3…5deab` owner `llama-swap-ocho-planner` need **6200** headroom **256** pid **330228** mode run |
| pid | **DEAD** — `kill -0` "No such process", `/proc/330228` absent at 14:56 |
| round | journal `14:50:07 Starting -> 14:50:14 status=1/FAILURE`, 3.201 s CPU / 6.806 s wall / 143.2 M |
| capture | **none after** `/tmp/gpu-lease.TSssx6` (14:40) ⇒ no 9B load |

The same draw stopped the resident smol via the `planners` swap group and was then refused at `6200+256 = 6456` against a `5893` ceiling, leaving a record with a dead pid and an empty card in one instant — the event class is `2026-10-29-an-open-edge-and-its-orphan-token-are-one-event` R2, **cited, not re-argued**. Consequence for this tick: `planner_at=planner` here has **no live referent**; the "scoped-planner flip confirmed live" sentence is false at this sample and the @ocho branch does not apply.

## 3. R1 — the closed span was the wheel's closing block, and one round in it exited `status=1` after loading

Closed `14:10:18.32 -> 14:50:14.03` = **2395.71 s = 3.9929 x 600 s rounds** over picks `60387…60390`:

| pick | slot | card |
|---|---|---|
| `60387` (14:20) | 4B, **resident from 14:10** | no load, no lease (cited `2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`) |
| `60388` (14:30) | 4B | resident again; lane row `21:30:14.103Z` slot `ocho-planner-4b` |
| `60389` (14:40) | smol | **loaded**: capture `/tmp/gpu-lease.TSssx6` birth `14:40:14.735071708`, `model loaded` +0.799 s ⇒ **14:40:15.534**, served `n_tokens = 3249`; and the service **still exited `status=1/FAILURE`** at `14:40:17`, 143.1 M, **no prediction row** |
| `60390` (14:50) | 9B | refused ⇒ OPEN |

**Increment:** the 14:40 round is simultaneously a consumer-visible failure (`Result=exit-code`, no plan) and a card transition (it displaced the 4B and held the card, which is why the 14:44 sample read `closed`). The mechanism — a round that fails at a stage *after* a clean load — is owned by `2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly` R1 (read in full); what this tick adds is that such a round **also advances the wheel by one pick line** and therefore belongs in the interior enumeration of a closed span. Read the pick line and the capture together; never infer the card from the round's exit code.

## 4. R2 — the forecast, with its guard evaluated instead of assumed

Counter **60391**. Slots are `pos = count % 10`, `MODEL_SLOTS [9B,4B,smol]`, weights `6,3,1` (cited `2026-10-29-the-rotation-is-a-deterministic-wheel-…` R1): `60391–60395` = pos 1–5 = **9B refusals ⇒ stays open**; **`60396` = pos 6 = 4B ⇒ CLOSES on the 15:50 round**, width ≈ `6 x 600 s` ≈ 60 min barring a re-phase.

The guard required by `2026-10-29-the-shadow-run-advances-the-wheel-by-its-own-call-count` R2 is the intervening shadow call count — and it is **readable here**: `ocho-shadow-polymarket.timer` is `OnCalendar=*-*-* 1/6:00:00` (last `13:00:15`, next **`19:00`**), so **no shadow run falls between this sample and 15:50**, and the only call-count edge inside the forecast horizon is absent. That makes this the first forecast in the sequence whose guard is verified at issue rather than discovered broken afterwards. It is falsified only by a `pool 2/3` pick line (every line this tick reads `pool 3/3`) or a 9B that fits (563 MiB short in every state of this card forbids it).

## 5. R3 — the ceiling is stable at 5893 on an unchanged census

`5893` at three separate windows today (`11:15:58`, `12:59`, `14:56`) against the identical tenant set `1364 + 134 + 226` ⇒ the ±5 MiB band of `2026-10-29-the-ceiling-returns-with-its-census-…` R1 holds a third time. Quote this ceiling with its census and the census' dates; the drift correction stands.

## 6. Messages — none, both premises measured

**No `@ocho`.** The token is identical on both sides (no flip), and this tick's record is an **orphan** (need 6200, dead pid) — so the positive flip claim would be false at write, not merely redundant. His open item stays closed in **his own rows** (ids `9249` / `9267` / `16736`, `max(id)=17405`). A DM would re-open a closed item into a channel that drops on `target_busy` with no receipt.

**No `@llama`.** This is the **first sample** of the window (previous sample 14:44:20 read `closed`; edge ~5 min old, less than one round inside it). The fallback clause is for a window that survives several ticks untaken; he self-authorises at `--scope arcade` and this watcher does not preempt his own poll. Away side re-measured ABSENT (no lease artifact, no `model-test` process; `pgrep` self-match only).

**Standing flag for Mike, re-measured 14:56:** `profiles/llama/cron/` has **no `jobs.json`** — `executions.db` 24576 B frozen `2026-10-12 06:33:07.322361061` and `output/` untouched since 10-12, while `ticker_heartbeat` (23 B, pid 2451) and `ticker_last_success` were rewritten `14:55:19` = **a live clock over an empty job set**. ~60 min of open gate is scheduled to run from now to the 15:50 round with nothing executing the operator-approved clause. This is an execution fact, not a Kev decision; this watcher creates no jobs. The one lever remains the unleased `-ngl 0` tenant set (`1724` MiB holding `563` MiB of 9B admission) — a fact about the card, **not** an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6).

## Files touched
`governance/rulings/2026-10-29-a-failed-round-still-moves-the-card-and-the-forecast-guard-is-a-timer.md`, one line appended to `governance/INDEX.md`.
**Read-only throughout:** `gpu-lease.sh` (status only), `llama-swap.yaml`, `scopes/planner/`, the planner unit and timer, all three compute processes, the driver, `call_ocho_planner.py`, `model_cycle_counter.txt` — no acquire, release, load, reservation, config edit or cron job. The 14:40 smol load and the 14:50 9B refusal were the timer's own `*:0/10` requests through llama-swap.

## Prior art (printed BEFORE this file existed, `priorart.py rulings`, 522 records)
`0.147 2026-10-29-an-open-edge-and-its-orphan-token-are-one-event` (read in full; owns §2) · `0.091 2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly` (read in full; owns §3's mechanism) · `0.121 2026-10-21-a-counter-read-at-a-rounds-end-names-the-next-round` · `0.136 2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load` (owns the 4B resident rows) · `0.096 2026-10-21-a-failed-swap-evicts-before-it-refuses`. None states that a `status=1` round belongs in a closed span's interior enumeration, and none evaluates the shadow-call guard at the moment a forecast is issued.
