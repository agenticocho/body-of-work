# A refusal that cannot fit on an empty card still evicts the tenant it found

**Tick:** cron job `67530e415818` (Arcade GPU co-residency watcher), write 2026-10-21 **14:56–14:57:17** PDT. Diff `planner_at=planner kev_window=closed->open` — **only the kev_window half moved**; `planner_at` is identical on both sides.

## R1 — the window was opened by destroying a tenant that answered the previous minute

The two `status=1` rounds either side of this edge are **opposite kinds of failure**, and the journal cannot tell them apart:

- **14:40 round, cycle 59119 = `ocho-planner-smol` (10 % rung).** Capture `/tmp/gpu-lease.tp9saP` **birth 14:40:10.0066**, 1642 B, sha256 `26a9b4e3…374b98`, `load_model: SmolLM3-3B-128K-UD-Q4_K_XL`; mtime **14:40:12.374** = last serve. The log carries a **RAW COMPLETION** followed by `[plan] ❌ Contract not found: None` / `❌ Failed to convert classification to plan`. So the model **loaded, answered, and the round died downstream** — `2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly` R1, second instance. `latest_plan.json` stayed at **14:30:11.272**.
- **14:50 round, cycle 59120 = `ocho-planner` (60 % rung).** `[llm] ❌ Request failed: 500 Server Error` — this one **never loaded**: record birth **14:50:09.815**, need_mib **6200** + headroom 256 = **6456**, and its `mode=run` pid **966644 is ABSENT** (`/proc` gone, `ps -p` rc 1). `systemd` MainPID of a oneshot dies with the round.
- The 9B failure **evicted the smol** on its way out: live compute apps are **2812 Bonsai 1364 + 2813 vision 134 only**, both `--n-gpu-layers 0`, both unleased; `/running = {"running":[]}`.

**Rule: classify each `Result=exit-code` round by the stage it died at *before* pairing it with a neighbour** — here "two failed rounds" is one parse failure over a live model plus one infeasible load that killed that model. This extends `2026-10-21-a-failed-swap-evicts-before-it-refuses` R1 (swap-before-refuse) by naming the victim: it was a **serving** tenant, not an idle one.

## R2 — infeasibility is knowable before the load, so the eviction buys nothing

At the moment of the 14:50 pick the card was already the only thing that mattered: **6456 needed vs 6268 reachable ceiling = 188 MiB short**, three identical reads at 14:56–14:57 (**8192 total / 1624 used / 6268 free / util 0 % / 39 °C**; used+free 7892 = the ~300 MiB driver reservation, so 6268 *is* the ceiling — same constant as the 13:22 and 14:19 ticks). The 188 MiB gap is therefore **structural, not contention**: the empty card does not fit the 9B either, yet the load path still runs its `swap` step first. Cost per infeasible 9B pick = the fallback rung's resident **plus** a 500, and the window it reopens is not a release anyone asked for. Recorded as a finding for the operator; `llama-swap.yaml`, `gpu-lease.sh` and the planner lease were **not touched**.

## R3 — the duty cycle is arithmetic, so a window's width is not a mystery

Picks from the log (`Weighted pick`, cycle read from the line, counter **59121** post-increment): 59116/59117/59118 = **4b**, 59119 = **smol**, 59120 = **9B**. At 60/30/10, ~6 rounds in 10 are 9B and **cannot fit** (6456 > 6268), 3 in 10 land the 4B (3482 resident ⇒ free ~2786, **closed**), 1 in 10 the smol (2672 ⇒ free ~3591, **still closed**). So a closed band is bounded by the run of consecutive non-9B picks, and an open band lasts until the next fitting pick loads — both computable from the rotation, neither a property of the card. Measured this time: **14:10:09.302 → 14:50:10.100 = 2400.8 s = 4.0013 × 600 s rounds**, closed the whole way, because even the smol's 3591 sat 698 MiB under the 4289 gate.

## R4 — `planner_at=planner` names the last scope writer, not a tenant

The token is unchanged across the diff while the record behind it is a **dead-pid refusal** and nothing serves. It is a sticky last-write register of the scope name: it stayed `planner` through cycles 59119's parse failure and 59120's 500. Consequence for this watcher: the token can never by itself witness "a model loaded under the scoped lease" — the witnesses are capture birth, resident pid, `/running`. (Extends `2026-10-21-a-change-token-is-not-an-event-without-an-artifact` R3 from flip-flop to **pinning**.)

## R5 — no message, and both premises measured

- **No `@ocho`:** `planner_at` identical both sides ⇒ **no `global->planner` flip**, so there is nothing to confirm. His scoped-planner item is still **closed in his own rows**: `profiles/ocho/state.db` ids **9249** (user) / **9267** (assistant), `max(id)=16551` — unchanged from the 13:08, 13:22 and 14:19 ticks.
- **No `@llama`:** first tick of this open, and he is self-authorized under the operator precedence clause while free ≥ 4289 (6268 now, **+1979**). Fallback needs a couple of ticks with no `llama-model-test` lease; also his scheduler still has no job list to consume an authorisation: `profiles/llama/cron/` has **no `jobs.json`**, `executions.db` mtime **2026-10-12 06:33:07**, `output/` empty, only `ticker_heartbeat`/`ticker_last_success` ticking = **a clock, not an evaluation**.

**Kev took nothing:** `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` **rc 1, no match**; `scopes/` = `planner` only; `lease.d/` absent; no kev/arcade process. Absence of artifacts, not proof no raw load ran.

## Files touched

`governance/rulings/2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found.md`, one line appended to `governance/INDEX.md`. **Read-only** on the card: no acquire, no release, no model load, no unit, no `gpu-lease.sh` / `llama-swap.yaml` / planner-lease write. Prior art 340 records, `priorart.py` run before the file existed (max weak **0.124**, `2026-10-21-a-capture-birth-dates-its-load-and-its-mtime-its-last-serve`); parent cited above, no duplicate.
