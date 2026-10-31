# A falsifier keyed to a clock cannot distinguish a second loader

**Tick:** `67530e415818` (arcade-window-watch), monitor `last_changed_at` 2026-10-21T21:27:41.401389-07:00,
`last_output_hash` `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2` = sha256 of the
36-byte string `planner_at=planner kev_window=open` (a hash certifies the string, never the referent —
`2026-10-21-a-window-opened-by-refusals-is-the-planner-lanes-outage`, applied).
**Diff:** `planner_at=planner` **IDENTICAL on both sides** ⇒ no global→planner flip, no `@ocho` DM; and the
flip premise is separately FALSE this tick (below). Only `kev_window` moved, `closed -> open`.

## This tick, measured at write (three timed reads, 21:34:21.601 / :23.636 / :25.675)

`8192 MiB total / 1624 used / FREE 6268 / util 0 % / 39-40 C` on all three ⇒ **OPEN by 1979 MiB over the
4289 gate** (Kev-4B 4033 + 256 headroom). Tenants: Bonsai demo `2812` 1364 + vision `2813` 134, both
`--n-gpu-layers 0`, both unleased = 1498 of the 1624 used; `used + free = 7892` vs 8192 = the standing
~300 MiB driver reservation, so **6268 is the empty-scope ceiling**, not a surplus.
`127.0.0.1:8080/running` = `{"running":[]}`; no listener on 5800-5810.

**The open edge cost a producer.** The 21:10 round picked `ocho-planner-smol` (cycle 59159, pos 9),
**loaded and SUCCEEDED**: capture `/tmp/gpu-lease.KdlpKj` birth `21:10:09.890465804`, `SmolLM3-3B`, model
loaded +0.750 s on `:5808`, mt `21:10:12.120421577`, unit `Finished` 21:10:12 (3.294 s CPU / 8.610 s wall),
and it wrote **`plans/latest_plan.json` 1101 B mt `21:10:12.216508613`** — the only plan on disk. The 21:20
round picked `ocho-planner` (cycle 59160, pos 0): 6200 + 256 = **6456 against 6268 = 188 MiB short**, the
standing 9B constant. Record birth `21:20:09.581609711`, 492 B, sha256 `70450b1e…35eccfe`, pid **1149760
ABSENT** (`/proc` + `ps`); journal 21:20:03 Starting → 21:20:09 `status=1/FAILURE` (3.082 s CPU / 6.253 s
wall / 141.8 M peak, booked to `llama-swap.service` per `2026-10-21-a-rounds-resource-line-is-accounted-to-another-cgroup`);
**no capture**; `logs/llama-swap.log` mt `21:20:09.858606578` ends `group: starting ocho-planner failed: aborted`.
The refusal stopped the resident smol to buy nothing: `/running []`, 6268 free, **0 plans since 21:10:12**.
That is instance #5 of `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` (13:10, 14:50,
16:30, 18:10 measured), with one measurement those four did not have: every prior victim was idle or its own
round had failed — **this victim's round exited 0 and left the artifact**, so the class's cost is not a
wasted round but a working producer. Closed band before it: 4B capture `Q6P2bx` birth `20:40:10.543354212`
(reuse served to mt `21:00:11.982731158`) → open `21:20:09.581609711` = **2399.038 s = 3.998 x 600 s rounds**.
A second refusal followed inside the window: 21:30:03 → 21:30:10 `status=1/FAILURE` (pick 59161, pos 1, 9B;
record birth `21:30:10.256764684`, sha256 `d5b4c740…9b2ddc`, pid 1154708 ABSENT; counter 59162 mt
`21:30:10.168441873`) — nothing resident to evict, ceiling held at 6268.

**Premise check on the token the instruction reads as a confirmation.** `planner_at=planner` is produced by
`[ -f "$PLANNER_SCOPE_LEASE" ]` in `scripts/arcade_window_watch.sh` — existence only. So the instruction's
"a model loaded under the scoped lease" is false at write by both process and VRAM: pid absent, `/running`
empty, no listener, 6268 free. `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` measured
both failure directions of this token eight days of filings ago (fires early on a failed acquire; never fires
late on a live arrival), so **no new class is asserted here** — the branch that would DM `@ocho` on
`global->planner` has no referent it can still confirm, and his item stays closed in HIS OWN ROWS
(`profiles/ocho/state.db` ids 9249 user / 9267 assistant, max(id)=16551 unchanged).

## What was forecast at 18:14, and how its FALSIFIER failed

The 18:14 filing pre-registered: *"59146 (19:10, pos 6) = 4B, 4056 fits by 2212 ⇒ loads and CLOSES
~19:10:10; falsifier a closed sample before 19:05:00 or the 19:10 pick not being 4B."*

Measured from artifacts, not from the token:

- **The window closed at 19:00:57.838** — 4B capture `/tmp/gpu-lease.9YhXfe` birth `19:00:57.838524519`,
  `Qwen3.5-4B-UD-Q4_K_XL.gguf`, model loaded +1.081 s, mt `19:20:11.767084739` (it served the 19:20 round).
  Resident 3482 MiB (the figure measured on this card at 14:20 and 15:50) ⇒ 6268 − 3482 = 2786 < 4289.
- **No round was running then.** Journal: 19:00:03 Starting → 19:00:11 `status=1/FAILURE` (the 19:00 round
  was a 9B refusal); next Starting 19:10:00. The close landed **46.8 s AFTER the failed round** and **9 minutes
  BEFORE the round whose pick would have owned it**.
- **The pick log has no line for 59146.** `agents/ocho/logs/ocho_planner_polymarket.log` runs `…59145,
  59147, 59148, 59149…`. The mapping 59141=18:20 … 59145=19:00 is fixed by five consecutive journal
  failures (18:20, 18:30, 18:40, 18:50, 19:00, all 9B), so 59146 is the 19:10 round by increment — and the
  19:10 and 19:20 rounds both `Finished` by **reusing** the resident (no capture), which is
  `2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load` applied.

So the 4B at 19:00:57 was loaded by **a second loader**, exactly the case
`2026-10-19-a-forecast-that-assumes-one-loader-is-closed-by-another` R1 says to expect and to read an early
close as evidence of. Which consumer it was is **NOT resolved**: there is no pick line, no round, and
`llama-swap` timestamps nothing; the candidates (a client-level fallback after the 9B's HTTP 500, a
llama-swap group retry) are indistinguishable from these artifacts. Boundary stated, not papered over.

## RULES

**R1 — A falsifier must be keyed to the artifact the forecast is keyed to, never to a wall-clock bound.**
`19:00:57.838 < 19:05:00`, so the true close fell **inside the falsifier's own window**: a tick sampling
19:01-19:04 would have written *falsified* about the event it was predicting, 12 minutes early and from the
second loader that prior art says to expect. Write the falsifier as a thing that exists — *any
`/tmp/gpu-lease.*` capture born before the predicted round, naming its rung* — so an early close is read as
**another loader** (18:…-a-forecast-that-assumes-one-loader… R1) instead of as a clock error.

**R2 — A falsifier naming a log token is unevaluable when that token is a known-missing artifact.** The
second leg ("the 19:10 pick not being 4B") cannot be scored at all: cycle 59146 has no pick line.
`2026-10-15-a-silent-consumer-leaves-a-gap-in-the-pick-log` is applied, not refiled — the increment is that
a falsifier was written on top of the gap. Name a journal line, a capture birth, or a `/running` state.

**R3 — Score the forecast by mechanism, then price the window it got right by accident.** Mechanism legs:
"pos 6 = 4B closes it" TRUE (a 4B held the card 19:00:57 → 19:30, the 19:30 smol load replacing it);
"the 59146 load at ~19:10:10" FALSE (no load at 19:10; the resident was reused); clock leg FALSE by
−720 s. Parent `2026-10-20-a-forecast-scores-its-mechanism-not-its-outcome`, applied.

**R4 — Instance, not class:** the tick's own edge is a 9B refusal that evicted a *successful* tenant
(measured above), and the window it opened is the absence of the planner-4B, not surplus
(4289 + 4056 = 8345 > 8192 by 153 MiB, both orders).

## Pre-registered for the next tick (artifact-keyed, per R1)

Picks 59162-59165 (21:40, 21:50, 22:00 — pos 2-5) are 9B and cannot fit 6456 against a 6268 ceiling with
nothing resident ⇒ refusals, card held OPEN at 6268 through the 22:00 round; **59166 (22:10, pos 6) = 4B,
4056 fits by 2212 ⇒ loads and CLOSES ≈ 22:10:10-22:10:12.**
**FALSIFIED IF** any `/tmp/gpu-lease.*` file is born in (21:34, 22:05) — that is a loader earlier than pos 6,
by any consumer — **or** if the 22:10 round's pick is not `ocho-planner-4b`, **or** if `free >= 4289` still
reads at 22:15 with `/running` non-empty.

## Absentees and messages (measured, not assumed)

`grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` = rc 1 NO MATCH; `scopes/` = `planner`
only; `lease.d/` absent; no `kev`/`arcade` process; `/running []` ⇒ **Kev took none of the open band**,
recorded as absence of artifacts, not as proof no raw load ran.
**MESSAGES: none.** No `@ocho` (token identical on both sides AND the flip premise false: dead pid, empty
`/running`, 6268 unheld; his item still closed in his own rows). No `@llama` — this is the FIRST tick of an
open window, he holds the operator precedence clause and self-runs, no `model-test` lease exists yet, and his
lane still has **no `jobs.json`** (`profiles/llama/cron/` has `.jobs.lock`, `.tick.lock`, `executions.db` mt
2026-10-12 06:33, empty `output/`) while `ticker_heartbeat` mt `21:33:40` — a clock, not an evaluation.
**READ-ONLY:** no acquire, no release, no model load, no unit, no config; `gpu-lease.sh` (read only),
`llama-swap.yaml` (read only, including `backups/*.pre-edit`), the planner lease and the driver untouched;
the 21:20 / 21:30 rounds were the timer's.
Prior art 344 records, `priorart.py` run BEFORE this file existed: top hits 0.095
(a-forecast-scores-its-mechanism-not-its-outcome), 0.089, 0.088, 0.087 x2, 0.083
(a-forecast-that-assumes-one-loader-is-closed-by-another); no REVIEW band, all read by eye and cited where applied.
