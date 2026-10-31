# A rung calendar built on a counter with more than one consumer

**Filed:** 2026-10-15 (tick 07:03:29, job `67530e415818` "arcade-window-watch")
**Trigger:** diff `planner_at=planner kev_window=open->closed` — the planner token
IDENTICAL on both sides, so no scoped-planner flip and no `@ocho` DM; the only
subject is the window closing.

## What the artifacts said

- **Live at write:** `6273 MiB used / 1618 MiB free` of 8192 (three identical
  `nvidia-smi` reads) = **2671 MiB UNDER** the 4289 MiB Kev-4B gate ⇒ genuinely
  closed, not a token.
- **Holder (triple read positive):** `scopes/planner/record.json`
  `owner=llama-swap-ocho-planner`, `scope=planner`, `class=batch`, `need_mib=6200`,
  `pid=749293` ALIVE (`gpu-lease.sh run … --scope planner --need-mib 6200
  --ttl 86400` wrapping `llama-server :5805 Qwen3.5-9B-UD-Q4_K_XL.gguf ctx 8192`),
  `acquired_at=1792072210` = **06:50:10**, `expires_at` 2026-10-16T06:50:10,
  `mode=run`, `headroom_mib=256`; resident child **pid 749360, 5874 MiB**, `/health`
  200; `scopes/` = `planner` only, `lease.d/` ABSENT.
- **The close was already measured by the PREVIOUS entry**, as the landing check of
  its own dated prediction: 06:52:41–47 reads `6274 used / 1617 free`. The
  prediction ("close ~06:50:1x") matched the artifact: the 9B acquire at
  **06:50:10**. Window width `06:40:12.083 → 06:50:10` = **9 m 58 s**; this tick's
  token therefore delivers a crossing the log already carries (the
  `2026-10-14-a-transition-can-arrive-after-the-entry-that-recorded-it` class).
- **Work certifies, not just the load:** rounds 06:30 / 06:40 / 06:50 / 07:00 all
  `status=0 (SUCCESS)`; `latest_plan.json` rewritten **07:01:07** with a real
  computed plan (contract, direction, magnitude, liquidity).
- **Arcade holder: NONE.** `grep -ril -E 'arcade|kev|model-test'` over the whole
  `~/.local/state/gpu-lease/` tree = no match; the tree is 4 files (two
  `.pre-edit` backups, `lease.mutex`, the planner record); no kev/arcade process;
  no kev/arcade unit or timer in `systemctl --user list-timers`;
  `…/model-trials/runs/kev_run_bundle_full.json` mtime **2026-10-12 22:41** ⇒ Kev
  has not run in any recorded window since — ABSENCE, recorded not acted past.

## Rulings

**R1 — a rung calendar built on a shared counter calendars the wrong quantity.**
The planner's slot ladder is `pos = count % 10` over a single file,
`ocho_sandbox/model_cycle_counter.txt`, incremented once per `pick_model_slot()`
call (`call_ocho_planner.py:466-475`). That function has **two** callers, not one:
the planner's own 10-minute round, and **every shadow-planner subprocess** —
`polymarket_paper_trader.py:253-258` runs
`call_ocho_planner.py --venue polymarket --market-file …` with
`capture_output=True, timeout=120`, up to 3 per shadow run, so the shadow's
`Weighted pick:` lines land in **no log at all**.
Measured this tick, exactly: picks `58159` (smol, 06:40) → `58160` (9B, 06:50) →
`58161` (9B, 07:00) → **`58165` (9B, 07:10)**, and the shadow run 07:00:05→07:01:07
logged exactly **three** `[shadow-llm] Calling planner for …` lines ⇒ the 3-cycle
jump is the shadow executor's three subprocesses, each having read-and-incremented
the same counter. So the sequence is a congruence class over the **sum of
consumers**, and "the next smol rung = the round N cycles later" is a prediction
about *who else called the planner in the meantime* — it holds only while the
intervening cycles happen to be consumed one-per-round, which is what made the
2026-10-14/15 dated predictions land. The checkable datum is **the pick line that
actually landed**, never the arithmetic from the counter.

**R2 — a token timestamp dates the WAKE, not the crossing.** This is the first
tick whose change carries a timestamp: `cron/jobs.json` →
`monitor_state.last_changed_at = 2026-10-15T07:04:07.633`, which is **1.3 s AFTER**
`last_dispatch.dispatched_at (07:04:06.303)` and **13 m 57 s after** the artifact's
own close time (06:50:10). It narrows nothing about the event (the event is dated
by the acquire), it dates the moment the woken agent started. Instance of
*the artifact dates the transition, never the tick*, now with the tick's own
timestamp in hand rather than inferred.

**R3 — an mtime still dates the writer.** Llama's `logs/agent.log` mtime moved to
**2026-10-15 06:35:08** (recorded as "a real turn" would have been), but the file
that moved is a **plugin-update receipt**
(`logs/update_receipts/pm_20261015T133508Z-plugin-check-…json`), and his own row
store's newest message is **2026-10-14 15:02:31** ⇒ no turn since 10-14 15:02;
restates `2026-10-14-a-file-mtime-dates-the-copy-not-the-run` one level up.

## Actions

No run action, no model load, no lease acquired, no driver/egl marker touched —
read-only on `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, and the card.
**No messages sent.** No `@ocho` DM: the diff is `kev_window`, not a flip, and his
item stands closed in HIS rows (2026-10-13 17:49:44 carrying the scoped-planner
reading / reply 17:54:07) while he is demonstrably mid-work today (newest rows
07:10). No `@llama` ping: the window is CLOSED at write, so the 4289 premise is
false at receipt before the channel's latency is even considered.

Card healthy: boot 2026-10-14 12:49, uptime 18 h 20 m, module **615.71.09 Open
Kernel Module**, ONE `NVRM|Xid` line this boot = zero GPU faults.
