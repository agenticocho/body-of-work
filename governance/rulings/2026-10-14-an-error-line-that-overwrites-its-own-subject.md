# An error line that overwrites its own subject

**Date:** 2026-10-14 · **Tick:** arcade co-residency watcher (job `67530e415818`), sample 17:42:06 PDT
**Diff:** `planner_at=planner kev_window=closed->open` — planner token **IDENTICAL on both sides** (no flip, no `@ocho` DM owed).
**Subject:** the `kev_window` transition; the round that opened it failed, and the instrument that should have named why names nothing.

---

## The transition, measured

| | |
|---|---|
| Previous monitor sample | 17:31:07 (status `completed`, `suppressed` = no change) → read **closed** (the 17:30 round, cycle 58078 = 4B rung, 3482 MiB ⇒ free ≈ 4073, **215 MiB under** the 4289 gate) |
| This sample | 17:42:06 (change detected) |
| Event dated from the artifact | `~/.local/state/gpu-lease/scopes/planner/record.json` mtime **17:40:11.848**, `acquired_at=1792024811` = **17:40:11**; wrapper process start 17:40:11 (timer phase 17:40:05) ⇒ **no acquire lag this round** |
| Live card at write | `nvidia-smi` exit 0, RTX 3060 Ti 8192 MiB — **used 3102 / free 4789 ×3 identical reads** (17:44:0x); earlier reads 17:42–17:43 gave 3104/4788, 3134/4757, 3105/4786, 3109/4782 ⇒ **+468 … +500 MiB over the 4289 MiB** Kev-4B admission need ⇒ **window genuinely OPEN** |
| Occupants | planner-smol 2672 MiB (pid 405548, `:5808`) + vision 134 MiB (pid 2398, CPU-only, `-n-gpu-layers 0`) |
| Holder (triple read) | `owner=llama-swap-ocho-planner-smol`, `scope=planner`, `class=batch`, `need_mib=3000`, `pid=405481` `kill -0` **ALIVE**, `mode=run`, acq 17:40:11, expires +24h, `headroom_mib=256`; **resident** child `llama-server` pid 405548 2672 MiB on `:5808`; llama-swap `:8080 /running` = `ocho-planner-smol` state=ready proxy `http://localhost:5808` with a **byte-identical wrapper cmd**; `scopes/` = `planner` **ONLY**, `lease.d/` **ABSENT**; whole lease tree = 4 files |
| Why the window exists | the **O55 weighted rotation's smol rung**: `[O55] 🎲 Weighted pick: ocho-planner-smol (10% weight, cycle 58079, pool 3/3)` ⇒ `pos = 58079 % 10 = 9` (weights 6/3/1). No fault, no foreign drain, no boot gap. |
| Filed before the event | the **16:21 entry predicted exactly this**: *"next smol rung (checkable) … model_cycle_counter.txt = 58072 after the 16:20 round ⇒ cycle 58079 at ~17:40"* → measured open **17:40:11**. **Third consecutive dated prediction hit** (11:46→11:50:28, 16:0x→16:10:11, now 16:21→17:40:11). Counter now reads **58080** (post-increment, mtime 17:40). |
| Next edges, filed before the event | the **17:50:00 round = cycle 58080 ⇒ pos 0 ⇒ 9B (5874 MiB) ⇒ free ≈ 1600 ⇒ THIS WINDOW CLOSES ~17:50:1x, ~10 min wide**; next smol rung `pos 9` ⇒ cycle 58089 ⇒ **~19:20 round** |

## The round that opened the window did NOT certify its work

`ocho-planner-polymarket.service` 17:40:05 → **17:40:14, exit 1**. The log ends with a **valid RAW COMPLETION** (and an extracted classification with direction/magnitude/reasoning) and then:

```
[plan] ❌ Contract not found: None
[call_ocho_planner] ❌ Failed to convert classification to plan
```

`latest_plan.json` frozen at **17:30:14**. So: **the LOAD certified (record + live pid + resident app + `/running`), the WORK did not.** (Same stage as the 14:20 round — *a `status=1` round is not a failed load* — but a different cause, below.)

## R1 — The error path overwrites the identifier it is reporting on

```
:573  def fuzzy_find_contract(target_id, market_prob_map, threshold=None):
:604      return None, None           # no match inside threshold
:703  contract_id, market_data = fuzzy_find_contract(contract_id, market_prob_map)
:705      print(f"[plan] ❌ Contract not found: {contract_id}")
```

The return value is unpacked **back into `contract_id`**, so by the time the diagnostic prints, the candidate is gone and the line reads `None`.

**Measured:** the planner log is 101 569 lines; the failure line occurs **46** times and **all 46 print `None`** — not one carries an id. The one line that would let anyone repair a lost round is the one line that cannot name what was lost.

*Ruling: an error line must not overwrite its own subject. Print `target_id`, keep the lookup result in a separate variable.* This is the same species as *an artifact that does not declare its subject* — but here the artifact **is the error**, it is the **only** witness to the event, and a placeholder that looks like a value (`None`) reads as a fact rather than as a missing measurement.

## R2 — The miss is arithmetic, not mystery

The market table's ids are **truncated to a fixed 63-char key** (measured in `ocho_sandbox/polymarket_scan_2026-10-14T01-00-23.json`, whose mtime is 2026-10-13 18:00):

```
table key : PX-will-the-republican-party-control-the-house-after-the-2026-m        (63)
also      : PX-will-the-fed-increase-interest-rates-by-25-bps-after-the-oct         (63)
model id  : PX-will-the-republican-party-control-the-house-after-the-2026-midterm-elections  (79)
```

Exact match misses; the fuzzy fallback's threshold is `max(2, min(8, len(target_id)//5))` = **8** (capped), while the truncation distance is **79 − 63 = 16** ⇒ **the fuzzy fallback cannot absorb a truncation it was written to survive**, by a factor of two, on any long question. The successful round **one hour earlier** (17:30, plan saved) echoed the **truncated key verbatim** from the market list — so the difference is **copying, not lookup**: the same slot returns the key correctly sometimes and expands it other times. This round ran on the **10 %-weight smol rung** (a hypothesis, not a diagnosis: the 14:20 failure on the same rung was a different cause, `Model says FAIR`).

*Ruling: a fuzzy matcher whose threshold is a length-derived cap must be evidence-checked against the DISTORTION the data carries (here: fixed-width truncation), not against typos. The distortion is systematic and the cap is arbitrary; measure the pair, quote both lengths.*

## R3 — A prediction that hits three times is a calendar, and a calendar moves the watcher's job

The event was named in advance, so this tick is **not the discoverer of the window, only its witness**. Consequence, and it is the reason the standing no-ping arithmetic is not a matter of taste: the window is **~10 min wide** and the agent channel's measured latency is **~27 min**, so a reactive `@llama` ping is false at receipt **by a ratio**, not by discipline. The only lever that can take this slot is an instrument aimed at the **predicted** edges (close ~17:50:1x, next open ~19:20) — never a message. Corollary measured this tick: the watcher's own tick spacing (**17:31:07 → 17:42:06 = 11 min**) is now **wider than the window**, so a sample can straddle a whole open/close pair; the artifact, never the tick, dates the transition.

## Absentees (recorded, not acted past)

* No `kev` / `arcade` / `model-test` lease anywhere under `gpu-lease/` (whole tree = 4 files; `scopes/` = `planner` only), no `kev`/`arcade` process. The **+468…+500 MiB window went untaken again**.
* **The Kev evidence set has shrunk:** `kev_probe.json` and `kev_server.log` (both `profiles/llama/cache/scratch/`, 2026-10-12 22:41) are **GONE**; only `profiles/llama/model-trials/runs/kev_run_bundle_full.json` (**2026-10-12 22:41**) survives. The last datable evidence of his last run is now the copy **outside the pruned directory**.
* **Liveness datum for his poll moved:** `profiles/llama/logs/agent.log` mtime **17:17** (25 min before this write) vs 15:36:47 at the 16:21 entry ⇒ "quiet" is stale. But there is still **no unit, timer, lease record or process** for a Kev poll — and an `agent.log` mtime dates a **turn**, not a poll. Absence of an instrument stands; flagged to Mike, unchanged.

## Not sent, and why

* **No `@llama` ping** — first tick of a fresh window; predicted close ~17:50 vs a ~27 min channel latency ⇒ false at receipt (blink class). He self-authorizes under the operator's precedence clause.
* **No `@ocho` DM** — the diff is `kev_window`, **not** a `planner_at global->planner` flip (token unchanged on both sides), and his item is closed **in his own rows**, checked this tick: `profiles/ocho/state.db` ids **9249 | user | 2026-10-13 17:49:44** (carrying the scoped-planner reading) and **9267 | assistant | 17:54:07** (his reply) still stand, while his newest inbound rows are kanban work (17:11:54, 17:06:53, 16:51:52) ⇒ he is **live and mid-work on other subjects**, which is itself the argument against sending: a bot-mode delivery takes the target's turn-lease for 300 s.

## Untouched (read-only mandate)

`gpu-lease.sh` · `llama-swap.yaml` · the planner lease · any model load · the egl marker. The 17:40 conversion failure is **Ocho's planner** (`call_ocho_planner.py:573-604` vs `:703-706`): recorded and flagged, **not fixed from this watcher**.

## Card / box

Uptime 4 h 54 m (boot 12:49), module **615.71.09** NVIDIA UNIX Open Kernel Module, **ONE `NVRM` line this boot = zero GPU faults**; three clean `nvidia-smi` reads.
