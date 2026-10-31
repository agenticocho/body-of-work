# The rotation is a deterministic wheel, so a window has a width before it opens — and the refusal "fingerprint" is falsified by a success inside its band

**Tick:** `2026-10-29 12:11:28 – 12:15 PDT` (`arcade-window-watch`, job `67530e415818`).
**Diff:** `planner_at=planner` **IDENTICAL on both sides** (no flip ⇒ **no @ocho**) · **`kev_window=open → closed`**.
**Bracket:** `(2026-10-29 12:00:20, 12:11:19.929]` — samples `11:27:20`, `11:38:20`, `11:49:20`, `12:00:20` all `no_change` (155 B, open); `monitor_last_output.txt` 36 B mtime **12:11:19.929380230** sha256 `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`, body `planner_at=planner kev_window=closed`.
**Nature:** RECORD ONLY. No acquire, release, load, reservation, unit or config touched. No message. Llama is self-authorized at `--scope arcade` when free ≥ 4289 and self-polls; this tick does not preempt him.
**Method:** every figure below is a read from this tick — `nvidia-smi` (three reads) + `--query-compute-apps`, `ps`, `ss -ltnp`, `curl :8080/running`, `stat` + `sha256sum`, `journalctl --user`, `/tmp/gpu-lease.*` captures, `model_cycle_counter.txt`, the planner log's pick lines, `gpu-lease.sh status` class reads, `call_ocho_planner.py:422-478` read-only. Nothing recalled from a prior tick.

## 1. The live card

| read | total | used | free | util | temp |
|---|---|---|---|---|---|
| three reads 12:11:28–12:11:31 (identical) | 8192 | 5485 | **2406** | 9–12 % | 41 C |

Gate = **4289** (`4033 + 256`; `scripts/arcade_window_watch.sh` read this tick, `free -ge 4289`) ⇒ **CLOSED by 1883 MiB**.

Compute apps: `2347` Bonsai **1364** + `2349` vision **134** + `87744` bge-small **226** + `216333` planner-4b **3482** = **5206** (rung included). `used+free = 7891` vs 8192 ⇒ driver/ctx **301**. Empty-scope ceiling = `2406 + 3482` = **5888** ⇒ 9B `6456` = **568 SHORT**; 4B `4056` = **1832 spare**.

## 2. The close edge is a LOAD on a live holder, dated three ways

| read | value |
|---|---|
| record | `scopes/planner/record.json` **494 B** ino `10272179` **birth 12:10:20.340495320**, mtime `.342495304`, sha256 `e66672c1b6dae1de119b97b4cfc5fddd1c387e86fad77d741856cb756a102119`, `owner=llama-swap-ocho-planner-4b`, `scope=planner`, `class=batch`, `need_mib=3800`, `headroom_mib=256`, `pid=216193`, `mode=run`, `acquired=12:10:20`, `expires=2026-10-30T12:10:20`, ttl 86400 |
| holder | `216193` **ALIVE** (`bash gpu-lease.sh run --owner llama-swap-ocho-planner-4b … --port 5806 --model Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file ocho_grammar.gbnf`), child `216333` **ALIVE 3482 MiB**, `LISTEN 127.0.0.1:5806`, `:8080/running` = `ocho-planner-4b` **state=ready** |
| load capture | `/tmp/gpu-lease.8zKFpW` 1637 B mtime **12:10:24.868457647**, `model loaded` at internal **+1.123 s** ⇒ close ≈ **12:10:21.46**; bracket hard-bounded `(12:10:20.340, 12:10:24.868]` |
| round | `ocho-planner-polymarket.service` `12:10:14 Starting → 12:10:25 Finished` — **exit 0**, 3.278 s CPU / 10.421 s wall / **142.6 M** peak |
| deciding draw | pick line `cycle 60366 = ocho-planner-4b (30 %)`, counter `60367` mtime `12:10:20.243926930` (post-increment), round clock `OnCalendar=*:0/10` |

**Window width: `11:10:18.716 → ≈12:10:21.46` = 3601.6 – 3606.2 s = 6.0027 – 6.0103 × 600 s rounds**, closed on the **seventh** pick: opener 9B `60360` (`11:10:19`, `status=1/FAILURE`, 142.6 M), interior `60361–60365` (11:20 / 11:30 / 11:40 / 11:50 / 12:00, all `ocho-planner` 9B, all `status=1/FAILURE`, 142.6–143.7 M), closer 4B `60366`. The preceding window was `09:30:16.402 → 10:30:15.042` = **3598.640 s = 5.9977 rounds** on the same five-interior-refusal shape, and the closed span between them was `10:30:15.042 → 11:10:18.716` = **2403.674 s = 4.0061 rounds**.

## R1 — THE PICK IS NOT RANDOM; IT IS `count % total_weight`, SO A WINDOW'S WIDTH IS COMPUTABLE BEFORE IT OPENS

`call_ocho_planner.py:466-473` (read this tick):

```
pos = count % total_weight
cumulative = 0
slot = eligible_slots[0]
for s, w in zip(eligible_slots, weights):
    cumulative += w
    if pos < cumulative:
        slot = s
        break
```

`MODEL_SLOTS = ["ocho-planner", "ocho-planner-4b", "ocho-planner-smol"]`, `O55_WEIGHTS = {6, 3, 1}`, `total_weight = 10`. There is **no RNG in the pick at all**: the slot is a pure function of the integer in `model_cycle_counter.txt`. Reproduced offline from the formula alone against every pick line the planner has ever written — **3442 parsed, 3442 matched, 0 mismatches** (scratch `verify_pick_wheel.py`, read-only over `logs/ocho_planner_polymarket.log`). The last fourteen: `60353–60355` 9B, `60356–60358` 4B, `60359` smol, `60360–60365` 9B, `60366` 4B — the wheel is `[9B×6][4B×3][smol×1]` and `60360 % 10 = 0` puts the window's opener at the **first** 9B slot.

CONSEQUENCE: the `0.6^k` / `0.4^k` arithmetic in `2026-10-29-the-ceiling-returns-with-its-census-and-the-closed-span-is-the-0-4-lane` R2 (`P(span≥4) = 2.56 %`) and in `2026-10-29-a-token-is-certified-by-the-gate-beside-it` R2 (`P = 0.6^5 = 7.78 %`, mean wait 1.5 refusals) is **RETRACTED as a mechanism**: those numbers describe what a 6:3:1 weighted draw *would* do if it were drawn, and nothing is drawn. A window opened at `count % 10 == 0` has **exactly six rounds** of width — its interior is the remainder of the 9B block — and the observed 3598.640 s and 3601.6–3606.2 s are not two samples of a tail, they are the same number twice. `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits` R1 remains the correct shape and is now given its exact value: the distance is `(6 - count % 10)` rounds, known at the opener.

R1.1 — the two escape conditions, both checkable in one line: a **demoted slot** (`model_brier_report.json`, 600 B, mtime `12:00:00.81`, is read every round at `:436-451`) changes `total_weight` and re-phases the whole wheel — every pick line prints `pool N/3`, and **all lines this tick and today read `pool 3/3`**, so the demotion branch is inactive and the wheel is a stable 10-slot period; and a **9B that fits** would load and stay resident instead of releasing the card, which the 568 MiB shortfall forbids today.

## R2 — THE "REFUSAL FINGERPRINT" (142.8–143.4 M PEAK) IS FALSIFIED: A SUCCESSFUL LOAD PRINTED 142.6 M, INSIDE THE BAND

Prior ticks this morning discriminated a load from a refusal by the round's `memory peak` — `status=1/FAILURE` + 142.8–143.4 M was read as "refusal", 143.3 M exit 0 as "load". **This tick's load is 142.6 M**, the same tenth of a megabyte as the 11:10 refusal (142.6 M) and inside the refusal band. The band does not discriminate, and it never did: `2026-10-21-a-rounds-resource-line-is-accounted-to-another-cgroup` R1 already measured thirteen rounds in which **loads printed 141.5–141.6 M and refusals spanned 141.1–142.1 M**, i.e. the refusal range *contained* the load values in both directions. That ruling owns the mechanism (the resource line is accounted to a different cgroup than the child that loads the weights); this tick is the counterexample that anyone using the band as an instrument must cite before quoting it. The durable discriminator is three independent reads, none of them the memory line: **exit status** (`status=1/FAILURE` vs `Finished`) + **a load capture** in `/tmp/gpu-lease.*` + **the resident process** (`/proc`, `--query-compute-apps`, `/running`, a `:5806` listener).

## R3 — THE KEV WINDOW IS 60 % OF THE CALENDAR, DETERMINISTICALLY, ON A 100-MINUTE PERIOD

With the wheel named, the card's occupancy is a solved clock at today's shortfall: slots `0–5` are 9B draws whose admission fails and whose `swap: true` group stops the resident rung ⇒ card empty ⇒ **window OPEN for 6 × 10 min**; slots `6–9` are 3× 4B + 1× smol, each resident ⇒ **window CLOSED for 4 × 10 min**. One period = 100 min, of which **60 min is an open Kev window, every period, without a card fluctuation**. Both of today's windows and the 40-minute closed span between them are that period observed twice. Therefore:

- an open window is **not** a rare opportunity that needs an explanation, and "nothing ran in it" is **not** evidence of anything about Llama's willingness — it is the steady-state of this box (`2026-10-27-the-majority-pick-cannot-fit-so-the-open-gate-is-the-steady-state`, cited not re-argued), now with a schedule attached;
- the standing execution flag below is **not** a one-off miss: on this schedule the authorization has had ~60 min of open card per 100 min for as long as the 9B has been infeasible, and nothing on either side has ever executed it;
- the forecast is falsifiable and names rounds, not a file: `60367 % 10 = 7` (12:20) 4B, `60368 = 8` (12:30) 4B, `60369 = 9` (12:40) smol, **`60370 = 0` (12:50) 9B refusal ⇒ window OPENS**, `60371–60375` (13:00–13:40) 9B refusals ⇒ stays open, **`60376 = 6` (13:50) 4B loads ⇒ window CLOSES**, barring a `pool 2/3` demotion or a 9B that fits.

## 4. Messages: NONE, both premises measured

- **No `@ocho`.** The diff has no `planner_at` transition (identical `planner` both sides), so nothing to certify; and his scoped-planner item is closed **in his own rows** — `profiles/ocho/state.db` 152,150,016 B, mtime **07:42:24.538** (untouched since the reboot), `max(id)=17405`, ids `9249` (user: "Your open item is closed…"), `9267` (assistant: "Sent. This turn."), `16736` ("Verified independently, and **the item is closed.**"). A DM would re-open a closed item into a channel that drops on `target_busy` with no read receipt.
- **No `@llama`.** This is a CLOSE edge and `2406` is **1883 MiB the wrong way**; the fallback clause is for an open window that survives several ticks untaken, and he self-authorises at `--scope arcade`. The away side is ABSENT, not contrary: `scopes/` holds `planner` only, `lease.d/` **does not exist**, `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` ⇒ rc 1.

## 5. Standing flag for Mike, re-measured 12:12

`~/.hermes/profiles/llama/cron/` has **NO `jobs.json`**; `executions.db` 24576 B frozen **2026-10-12 06:33:07.322361061**; `output/` untouched since 2026-10-12; while `ticker_heartbeat` (23 B) and `ticker_last_success` (17 B) were rewritten **12:12:18.9** — a **live clock over an EMPTY JOB SET**. R3 now prices this: with the wheel, the card is above the Kev gate for **60 minutes of every 100**, predictably, and nothing executes the operator-approved precedence clause in any of them. That is an **execution fact, not a Kev decision** — this watcher creates no jobs and touches no unit. The one lever actually observed today remains the unleased `-ngl 0` tenant set (1364 + 134 + 226 = **1724 MiB**, all `-ngl 0`, all unowned per `gpu-lease.sh status`), holding **568 MiB of 9B admission** while consuming no GPU compute; read as a fact about the card, **NOT** an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6: price against live free memory, drain never stop).

## 6. Read-only throughout

`gpu-lease.sh`, `llama-swap.yaml`, `scopes/planner/`, the planner unit and timer, all four compute processes and the driver were **read only**; no acquire, release, load, reservation, config edit or job created. `call_ocho_planner.py` was **read** (lines 422–478) and its counter **not written**. The 12:10 load and the five refusals were the timer's own `*:0/10` requests through llama-swap.

## Prior art, printed BEFORE this file existed

`priorart.py rulings` (519 records, two phrasings): **REVIEW `0.221 2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`** (read; owns "a card-wide window closes on its own rung's holder" and the constant-token/constant-state distinction), `0.133 2026-10-23-a-pick-clock-dates-the-cell-when-no-capture-exists` (read; owns dating a refusal cell when no capture exists), `0.126 2026-10-29-a-post-boot-gap-closes-on-a-fitting-draw-not-a-clock`, `0.124 2026-10-27-the-post-boot-window-closes-on-the-first-fitting-draw`, `0.115 2026-10-21-a-rounds-resource-line-is-accounted-to-another-cgroup` (**read in full; owns R2's mechanism**), `0.112 2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits`. **None states that the rotation is a deterministic modulo wheel**, that a window's width is fixed by `(6 - count % 10)` before it opens, or that the refusal peak-memory band is falsified by a successful round inside it.

**RULINGFILE rulings/2026-10-29-the-rotation-is-a-deterministic-wheel-so-a-window-has-a-width-before-it-opens.md**
