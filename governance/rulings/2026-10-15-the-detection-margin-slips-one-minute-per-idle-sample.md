# The detection margin slips one minute per idle sample

**Tick** `67530e415818`, monitor sample **14:19:24** (claim 14:19:23.471, start 14:19:24.636; previous PERSISTED
sample 14:08:24.818, completed 0.2 s, delivery suppressed ⇒ its sample read no-change).
Diff `planner_at=planner kev_window=closed->open`. The `planner_at` token is IDENTICAL on both sides
⇒ **no scoped-planner flip, no @ocho DM** (his closure stands in HIS rows: 2026-10-13 17:49:44 carrying the
scoped-planner reading / reply 17:54:07; nothing open since).

Everything below is read from disk at tick time; no number is carried from memory.

## The window, with both edges dated

**OPEN — 14:10:28.394** = the smol rung's acquire, not the sampler:
`~/.local/state/gpu-lease/scopes/planner/record.json` mtime `2026-10-15 14:10:28.394545165`, `acquired_at=1792098628`,
owner **llama-swap-ocho-planner-smol**, scope=planner, class=batch, need_mib=3000, pid **189641 ALIVE** (lstart
14:10:27) with child 189708 on :5808, `/health` = `{"status":"ok"}`. Rung read off the **LOG LINE**:
`agents/ocho/logs/ocho_planner_polymarket.log:111186` — `[O55] 🎲 Weighted pick: ocho-planner-smol (10% weight,
**cycle 58209**, pool 3/3)`. That lands the prediction pre-registered in the 12:58 entry ("NEXT SMOL RUNG =
smallest cycle ≥ 58203 with cycle%10=9 = 58209 = the ~14:10 round") — 5th consecutive rung-band hit.

**LIVE AT THE SAMPLE** (14:19:48 / :49 / :50, three reads, nvidia-smi): used 3114 / 3106 / 3127,
**free 4778 / 4785 / 4764 MiB** = **+475…+496 over the 4289 MiB Kev-4B gate** ⇒ OPEN.
(The same rung with the same need_mib=3000 has cleared the gate by +507 at 09:30 and +532 at 12:50 — the margin is
a per-instance reading, not a property of the rung: instance of `a-moving-state-quoted-as-a-constant`.)

**CLOSE VERIFIED INSIDE THIS TICK** (the 07:58 discipline — a ~10 min window against a ~11 min sample period
cannot be left to the next sample): the 14:20 round ran `14:20:22 → 14:20:33`, `ExecMainStatus=0/SUCCESS`; record
mtime **14:20:27.928131376**, `acquired_at=1792099227`, owner **llama-swap-ocho-planner** need_mib=6200, pid
**206644 ALIVE** + child 206712 (5874 MiB, :5805); rung `cycle 58210` = ocho-planner (60 %); counter
`model_cycle_counter.txt = 58211` at 14:20:27.567 (post-increment ⇒ 58211 = 58210+1, gapless for this round);
`plans/latest_plan.json` rewritten **14:20:33.975** — mtime identical to the log's ⇒ the round's own writer, not the
13:01 shadow-writer hazard.

**WINDOW = 14:10:28.394 → 14:20:27.928 = 9 m 59.53 s.**
**LIVE AT WRITE** 14:21:52 / 14:22:34 / 14:25:36: free 1584 / 1587 / 1516 / 1565 / 1561 MiB = ~2700 **UNDER** the
gate ⇒ CLOSED, held. Rung bands re-confirmed at full population for the cycle shown: 58206/07/08 = 4b, 58209 = smol,
58210 = 9B.
**Next smol rung = cycle 58219** (smallest ≥ 58211 with %10 = 9) ⇒ the ~15:40–15:55 round at 1 cycle/round, earlier
if the silent consumers spend cycles (filed before the event).

## The contender did not take it — measured, not absent-looked

Per `a-lease-ledger-is-not-an-inventory-of-loads` (R1: read the contenders' own artifact roots), the lease tree
being empty is not the evidence:

- llama's roots **nothing newer than his last turn**: `profiles/llama/agent.log` mtime **12:50:55** (the 12:50
  window), `cache/scratch/coresidency_d1_kev.*` + `co_*.log` mtime **12:49**, `model-trials/runs` absent.
- No arcade/kev/model-test lease anywhere: gpu-lease tree = 4 files, `scopes/` = **planner only**, `lease.d/`
  absent, `grep -l "scope arcade" /tmp/gpu-lease.*` = **NO MATCH** (the window's temps are the planner's own two
  rounds, 14:10 / 14:20); no such process and no such unit.

⇒ the gate stood open by ~480 MiB for the full 9 m 59.5 s and **nothing took it** (4th such window today).
**NO @llama ping**: the window was already CLOSED at write (the 4289 premise is false at receipt) and his own poll
is beating — `profiles/llama/cron/ticker_heartbeat = 1792099343.618111` = **14:22:23**, identical second to
`ticker_last_success` — so the fallback clause stays unsatisfiable exactly as ruled
(`a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`, R1).
No run action, no model load; gpu-lease.sh / llama-swap.yaml / the planner lease and every model load untouched
(read-only: nvidia-smi, cat/stat, journalctl, systemctl status, ps, curl /health).

## R1 — A self-scheduled detector's margin against a foreign clock is a DRIFT, and the drift is its own runtime

`profiles/tiel/cron/executions.db`, job `67530e415818`, **every** row with `finished_at` (361 rows over
2026-10-13 → 2026-10-15):

| quantity | measured |
| --- | --- |
| `scheduled_instant − previous finished_at` | **359 of 360 intervals = 600.0 s ± 0.1 s** (max \|dev\| 0.086 s) |
| the one exception | prev finish 2026-10-13 17:36:16 → **−243.27 s** = a re-schedule of the job's interval, not a violation |
| dispatch lateness (`started_at − scheduled_instant`) | **median 59.8 s** (min 1.7, max 249.9) |
| sample-to-sample interval | min **610.4 s**, median **660.0 s (11 m 00 s)**, max **2280.2 s (38 m 00 s)**; 271/360 ≤ 661 s |

So the sample instant is **previous finish + 600 s + ~60 s**, i.e. the period is **600 s + the previous tick's own
runtime + the ~60 s scan lateness**: a 0.2 s no-change tick costs 660 s (11 m 00 s) while the 11:14 reporting tick
(runtime 619.3 s) cost 1279 s (21 m 19 s). This gives the exact form of
`the-sample-period-includes-the-watchers-own-runtime` R1 (its n≈6 derivation now holds on 359/360) and it has a
consequence that ruling did not draw:

**Against the planner's 10 m 00 s round grid, a no-change tick slips the sampler +60 s per sample.** The margin is
therefore not a property of the sampler but of the phase between two clocks it does not share — and **today it
shrank monotonically**:

| window | open → close | sample inside it | depth | headroom to close |
| --- | --- | --- | --- | --- |
| A (smol rung 58179) | 09:30:12 → 09:40:11 | 09:35:07 | 4 m 55 s | **5 m 04 s** |
| B (smol rung 58199) | 12:50:29.274 → 13:00:11.546 | 12:58:25 | 7 m 55 s | **1 m 47 s** |
| C (smol rung 58209) | 14:10:28.394 → 14:20:27.928 | **14:19:24** | 8 m 56 s | **63 s** |

**Rules.**
1. **A detection margin is a drift, not a constant.** Measure it as (event close − sample start) and watch the sign;
   the series above is the observable of a sampler slipping past an event it does not schedule. A margin of 63 s is
   one light tick away from a window that goes unreported for its whole life.
2. **A window that goes unreported must be read as a phase miss, never as a window that never opened.** The only
   reliable record of a window is the artifacts — a lease record's mtime/`acquired_at` and the successor's acquire —
   never the sample. A detector whose cadence is defined by its own completion cannot be made to observe a window of
   a period it does not share by sampling faster; it can only be read against the artifacts.
3. **The standing reports' "~11 min sample period" is the light-tick value of a quantity that ranges from
   10 m 00 s to 38 m 00 s** (min 610.4 s, max 2280.2 s). Quote the range, not the mode, wherever the period is used
   to argue what a tick can and cannot see — every fallback clause argued from "~11 min" is arguing from the best
   case.

## Instances, not new rules (named so this is not read as three new ones)

The bracket law (`a-diff-between-samples-brackets-the-event`), the window-as-a-rung of the rotation
(`a-window-that-is-a-rung-of-a-rotation`), the re-dated edge (`an-edge-already-dated-is-not-a-new-window`), the
lease ledger (`a-lease-ledger-is-not-an-inventory-of-loads`), the rung bands
(`the-rung-bands-are-the-weights`), the unsatisfiable fallback clause
(`a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`), and the moving state quoted as a constant
(`a-moving-state-quoted-as-a-constant`) all hold; this entry adds the phase arithmetic that was implicit in them.

## Card / box

Boot 2026-10-15 10:48 (`who -b` 10:48 / `uptime -s` 10:47:55), uptime 3 h 37 m, module 615.71.09 Open Kernel
Module, **1** NVRM line this boot (the load line) ⇒ zero GPU faults. Compute apps: 206712 (5874 MiB, the 9B holder)
and 2418 (134 MiB — the vision server, CPU-only). Read-only throughout; nothing written outside this ledger.

RULINGFILE rulings/2026-10-15-the-detection-margin-slips-one-minute-per-idle-sample.md
