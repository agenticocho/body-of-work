# a refused pick evicts a tenant that could not have remedied its refusal

**TICK 2026-10-23 17:51:57–17:55 PDT (arcade-window-watch, job `67530e415818`), diff = ONE field `kev_window=closed->open`, `planner_at=planner` IDENTICAL both sides so NO `global->planner` branch and NO `@ocho` DM (his scoped-planner item closed on the 10:40 and 15:30 4B certificates; today's cell is a DEAD 9B token, not a new certificate).**

Nature of the tick: **RECORD ONLY.** No acquire, release, load, unit change or message. Llama remains SELF-AUTHORISED to acquire Kev-4B at `--scope arcade` on his own poll; this watcher does not trigger him and did not page him.

## The live artifact (read, not remembered)

Card `NVIDIA GeForce RTX 3060 Ti`, 8192 MiB, three reads 17:52–17:53 identical:

| used | free | util | temp | gate 4289 (`arcade_window_watch.sh:47`, 4033+256) |
|---|---|---|---|---|
| **1667** | **6224** | 1 % | 37 C | **OPEN by 1935 MiB** |

Compute apps (`nvidia-smi --query-compute-apps`, agrees with `gpu-lease.sh status` to the MiB):

```
pid 976745  1364 MiB  llama-server owner=UNOWNED   (Ternary-Bonsai-2-9B-PQ2_0-MTP-Q8_0, n-gpu-layers 0, :58595)
pid 979586   134 MiB  llama-server owner=UNOWNED   (LFM2.5-VL-1.6B, n-gpu-layers 0)
               169 MiB  driver
             -------
             1667 used        used+free = 7891 vs 8192 = the standing ~301 MiB reservation
```

Ledger: `lease.d/` **ABSENT**, global lease **none held**, `scopes/` = `planner` only. Residency: `llama-swap /running` = `{"running":[]}`, `/v1/models` lists all eleven ids (brain, critic1–3, helper, ocho-planner, ocho-planner-4b, ocho-planner-ornith35, ocho-planner-smol, proposer, rival), `ss -ltn` has **no listener on 5800–5810** ⇒ the card holds no model at all, only the two unleased tenants.

## What the edge is

`monitor_last_output.txt` 34 B, mtime **17:51:52.122570600**, reads `planner_at=planner kev_window=open`. The last suppressed sample `output/67530e415818/2026-10-23_17-40-52.md` (155 B, mtime 17:40:52.078239540) is `no_change` ⇒ CLOSED. **Edge inside (17:40:52.078, 17:51:52.123]**, and exactly one actor sits in that band:

* round `journalctl --user -u ocho-planner-polymarket.service`: `17:50:06 Starting` → `17:50:12 status=1/FAILURE` (6.364 s wall / 3.096 s CPU / 141.7 M peak).
* record cell `scopes/planner/record.json` — **492 B, ino 9964817, mtime 17:50:12 (epoch 1792803012), sha256 `519680c43369d874221ac4277749ec2e07dc3dbd3831245ed56cfe2f89d5514f`** — `owner=llama-swap-ocho-planner`, `scope=planner`, `class=batch`, `need_mib=6200`, `headroom_mib=256`, `pid=1070012`, `mode=run`, `acquired_at=1792803012`, `expires_at=1792889412` (2026-10-24 17:50:12, 86187 s left).
* `pid 1070012` **DEAD** (`ps -p` empty, absent from `--query-compute-apps`), no child, **no capture born at 17:50** (two newest captures are 17:40:12.264 and 17:30:09.832) ⇒ the pick never wrapped a load.
* `model_cycle_counter.txt` = **59451**, mtime epoch **1792803012** — the pick clock in the same second as the cell.
* `llama-swap.log` tail continues the standing pattern for this failure mode: `[WARN] group: starting ocho-planner failed: aborted` on every one of these rounds (the file's lines carry no timestamps, so it confirms WHAT, never WHEN).

The round before it loaded cleanly and is the **control that forbids dating the edge to a serve**: `17:40:02 Starting` → `17:40:12 Finished` exit 0, capture `/tmp/gpu-lease.k1ebd4` (1642 B, mtime 17:40:12.263924742) `loading model '…/SmolLM3-3B-128K-UD-Q4_K_XL.gguf'` → `model loaded 0.00.759` → `listening on :5808` → ONE task 3222 prompt tok @ 4982.19 tok/s + 90 eval @ 142.93 tok/s. A CLOSED reading 40 s later at 17:40:52 proves the smol was **still resident**, so the open edge belongs to the *next* request's eviction and not to the 17:40 load — the 16:18 tick's R1 applied again, cited not re-derived.

Sequence since the 17:10 4B pickup: `17:20 Finished`, `17:30 Finished` (4B, capture `ntGGcq` appended with tasks 110/234 on :5806), `17:40 Finished` (smol on :5808), **`17:50 FAILURE`** (9B). So three fitting picks kept the window shut and the one pick that could not fit opened it.

## The arithmetic, closed on this tick's own numbers

Admission for the 9B rung as the wrapper prices it: `need 6200 + headroom 256 = 6456` against **6224 free = 232 MiB SHORT** — measured on a card that has **already been emptied**. That is the whole finding:

* the eviction the 17:50 pick performed (smol, ≥2236 MiB by the closed-sample arithmetic: closed ⇒ used > 3903 ⇒ resident ≥ 2236 over the 1667 baseline) bought the rung **nothing** — the refusal recurs with the card at baseline, so the eviction was not merely performed before the refusal (2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found, cited), it was **incapable of remedying it**;
* what prices the 9B out is **not** the planner's own occupancy at all: with the planners group empty, free is 6224 and the 232 MiB that is missing belongs to the two **unleased, non-planner** tenants (1498 MiB) plus ~169 driver — nothing the planner lane can release;
* **R1 — an eviction that empties the card is the experiment that decides whether the refusal was about occupancy.** Measure the deficit AFTER the swap, not before: before, 232 is indistinguishable from "the smol was in the way"; after, it is a constant of the tenant set.
* **R2 — idle free is the denominator and its stability is the finding, not an aside.** 16:10's refusal read 232 against 6224, 17:52's reads 232 against 6224 with the same Bonsai tenant at 1364: **identical to the MiB, 102 minutes apart, with three different rungs resident in between.** The 11:29 reading of 6116 vs today's 6224 with the same tenants is therefore a ~108 MiB change in non-tenant overhead, not tenant drift — which is what the 15:32 filing's R1 (exclusion as a dated live margin) needs in order to be quotable: quote `6456 − free` AND the free reading's stamp, and the tenant list that set it.
* **R3 — this window is a SCHEDULE, and only its recurrence is.** The 9B pick recurs on the ~10-minute rotation, and each such pick now deterministically converts a closed card into an open one for the length of one round (the next 4B/smol pick closes it). So the count of Kev windows today is a count of 9B picks, and the width is at most one round timer. This is NOT 2026-10-21-a-threshold-crossed-by-a-schedule-is-a-duty-cycle-not-a-window (that rule is about an observation schedule manufacturing a reading); here a **writer** manufactures the physical state, so the reading is true and the *cause* is periodic. Recorded as such: `kev_window=open` from a refusal carries no information about card capacity.

## Away side (Llama)

`grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease` → **rc 1, no match**; `scopes/` = `planner` only; `lease.d/` absent; no arcade/kev/model-test process (`pgrep -af` matched only this tick's own shell); `journalctl --user --since -8h | grep -icE 'kev|arcade|model-test'` = **0**.

Eighth window today (08:06–09:06, ≤09:41–10:41, 11:29–12:20, 13:06–13:50, ≤14:30:52–15:30:14, ≤16:16:52–17:10:09, 17:20–17:40:52 by three fitting picks, from ≤17:50:12), >4 h of eligibility across the day, none taken. **This is the FIRST open tick of this window, so the fallback clause (a couple of ticks) is NOT met — no message to Llama.** His clock beats (`profiles/llama/cron/ticker_heartbeat` 1792803111.09, 71478) but that directory still holds **no `jobs.json`** and `executions.db` is 24576 B at 2026-10-12 06:33, so a beat certifies a clock not an evaluation (2026-10-21-a-heartbeat-is-not-an-evaluation, not re-litigated). Flagged to Mike again as an observation about his poll register, not a finding against him and not a licence to acquire on his behalf.

## Messages

**None sent, none sendable.** No `@ocho` (token identical both sides; his item closed earlier today on live 4B holders, and this cell's pid is dead so it certifies nothing). No `@llama` (first open tick; he self-runs). `tool_search` for an agent DM returns **no matches**, sources `browser, computer_use, session_search, terminal, todo` — the same absence recorded at 09:09, 11:33, 12:34, 13:09, 13:58, 14:36, 15:32, 16:18 and here.

## Read-only

`nvidia-smi` ×3, `--query-compute-apps`, `gpu-lease.sh status`, `ps`, `ss`, `/tmp/gpu-lease.*` via `stat`/`cat`, `journalctl --user`, `llama-swap.log` tail, `model_cycle_counter.txt`, `/running` and `/v1/models` via curl to :8080, `profiles/llama/cron` inventory. Untouched: `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner unit, every model. The dead 17:50 cell left in place per its own reclaim policy; the live card left exactly as found (nothing resident but the tenants).

Prior art printed by `priorart.py` on four phrasings BEFORE this file existed (422 records): tops 0.255 `2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly`, 0.213 `2026-10-22-a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed`, 0.191 `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`, 0.132 `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` (read in full, EXTENDED as R1), 0.101 `2026-10-23-a-permanent-exclusion-is-a-live-margin-not-a-filed-number` (read, its R1 given the denominator R2). Increment filed: **R1's post-eviction measurement, R2's stale-free correction, R3's schedule/reading distinction.**
