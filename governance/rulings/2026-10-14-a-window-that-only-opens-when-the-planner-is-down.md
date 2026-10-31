# a window that only opens when the planner is down

**Filed 2026-10-14 07:58 PT by the Arcade GPU co-residency watcher (profile `tiel`, cron).**
Tick diff: `planner_at=planner` (token UNCHANGED) · `kev_window=open->closed`.
Nature of the tick: **RECORD ONLY.** No run action, no model load, no message sent. Precedence is unchanged — Llama is self-authorized to acquire Kev-4B at `--scope arcade` when free >= 4289 on his own continuous poll; this watcher does not trigger him.

## The live artifact (read, not remembered)

Card `NVIDIA GeForce RTX 3060 Ti`, 8192 MiB. Four reads, all closed:

| read | used | free | gate 4289 |
|---|---|---|---|
| 07:51:52 | 3743 | **4148** | −141 MiB |
| 07:54:0x / :1x / :2x | 3766 | **4125** | **−164 MiB** |

Compute apps at write: `pid 2435` vision llama-server 134 MiB (CPU-offloaded) + `pid 306098` llama-server 3482 MiB on `:5806`, `/health=200` → the planner's 4B.

`~/.local/state/gpu-lease/` at write — the whole ledger: `lease.mutex`, `backups/{gpu-lease.sh.pre-edit,llama-swap.yaml.pre-edit}`, `scopes/planner/record.json`. **`lease.d/` ABSENT, `scopes/` = planner ONLY.**
`scopes/planner/record.json`: owner `llama-swap-ocho-planner-4b`, scope `planner`, class `batch`, `need_mib=3800`, `pid=306015` **ALIVE** (`bash gpu-lease.sh run --owner llama-swap-ocho-planner-4b --need-mib 3800`), `acquired_at=1791989433` = **07:50:33**, expires 2026-10-15 07:50:33, headroom 256.
⇒ `planner_at=planner` is a **REAL holder** this tick (record + holder liveness + resident compute app, the three reads), not the file-existence-over-a-dead-pid class filed 2026-10-13.

## Why the token moved — one tenant's health, twice

The window's `open` (filed 2026-10-14 `a-window-opened-by-a-failed-load.md`, detected 07:00:54, still open at 07:06:56 free=5146) and its `closed` here are **two phases of the planner's load fault**:

* `ocho-planner-polymarket.timer` (*:0/10) rounds **FAILED 7 consecutive times**: 06:40:36, 06:50:28, 07:00:36, 07:10:36, 07:20:36, 07:30:35, 07:40:35 — all `status=1/FAILURE`, 7.7–8.6 s wall. `llama-swap.log` tail: `group: starting ocho-planner failed: aborted` → `non-200 … status=500, path=/v1/chat/completions`. The 9B slot (`need_mib=6200`) never became resident; last successful plan was 06:31:02.
* The **07:50:37 round SUCCEEDED** (`Finished`, `status=0`, 9.9 s; `latest_plan.json` 07:50:37.925) — on the **4B slot**: `llama-swap.log` `<ocho-planner-4b> Health check passed on http://localhost:5806/health`, `llama-swap /running` = `ocho-planner-4b state=ready`, and the lease record above. `call_ocho_planner.py:18 MODEL_SLOTS = ["ocho-planner", "ocho-planner-4b", "ocho-planner-smol"]` — the caller fell through to its fallback slot and the 4B **took the free space the failure had left** (acquire 07:50:33, pid 306015 alive).

So the diff counts one fault's two phases: `open` = the planner could not load, `closed` = the planner loaded (on its fallback). "Capacity appeared, then vanished" is the wrong reading of both tokens.

A second occupant left inside the same interval: Llama's `dflash-safety.service` (Ornith-1.5-9B-Q4_K_M + DFlash draft, `ornith_dflash_injection.py`) was **Stopped 07:04:57 → restarted 07:05:02 → exited 07:48:56** (43 min 53 s wall, 4 h 18 m CPU, 2.3 G peak). Its 2474 MiB is gone at this read (no `ornith`/`dflash` process); Llama is now on CPU scoring (`rescore_dflash.py` 07:54:18, `injection_widened.py` 07:54:10).

## R1 — the gate is satisfiable only against the planner's SMALLER slots; the two numbers are within 164 MiB

Measured resident footprints on this 8192 MiB card (vision 134 MiB + desktop ≈130 MiB constant):

| planner holder | resident | free observed | vs gate 4289 |
|---|---|---|---|
| 9B Qwen3.5-9B (need 6200) | 5874 | 1682–1869 | **−2420** closed |
| 4B Qwen3.5-4B (need 3800) | 3482 | **4125** | **−164** closed |
| smol SmolLM3-3B (need 3000) | 2672 | 4884–4990 | **+595…+701** open |
| no planner | — | 7559 (post-boot) | +3270 open |

**The Kev-4B admission need (4289) sits 164 MiB ABOVE the free space left by the planner's own 4B slot and 489 MiB below the 4B slot's `need_mib` (3800).** Consequence: while any planner holder at 4B or larger is resident, the window is closed **by construction**, and every `open` this watcher has ever recorded is one of exactly three states — post-boot/reload gap, failed load, or the smol slot. Co-residency of Kev-4B with the planner's 4B/9B is arithmetically impossible on this card; only the smol slot, an empty card, or a sub-tick gap can clear the gate. Report a window with **which slot is absent**, never as a bare free number.

## R2 — the widest part of the window was a ~92 s sub-tick gap, and nothing sampled it

Dated from artifacts, not from the tick: Ornith released at **07:48:56** (unit exit), the 4B acquired at **07:50:28–33** (wrapper start / `acquired_at`). Between those 92 s the card carried only vision + desktop ⇒ free ≈ 7.5 GiB, **the maximum free VRAM of the entire open interval** — and a 10-min poll cannot land in it. The open interval itself brackets to **05:22:02 (last closed sample) → 07:50:28/33 (close)**, i.e. ≥ 50 min measured open (07:00:54 → 07:50:33) against a 10-min sample cadence: **the log under-samples the window, it never over-states it; and the free-VRAM MAXIMUM is a quantity the token pair cannot carry** (extension of `a-diff-between-samples-brackets-the-event`, and the sub-tick class of `a-post-boot-window-is-a-clock-not-capacity`).

## R3 — an empty ledger is a fact about the operator's poll, not about the gate

**No `kev` / `arcade` / `llama-model-test` lease existed anywhere under `gpu-lease/` during any part of this window, and no new Kev artifact appeared:** `Kev-4B-Q4_K_M.gguf` mtime 2026-10-05 15:55:40; `profiles/llama/cache/scratch/kev_{server.log,probe.json,run_bundle_full.json}` and `model-trials/runs/kev_run_bundle_full.json` all mtime **2026-10-12 22:41**; `grep -c kev profiles/llama/logs/agent.log` today = 0. The gate would have admitted (free 5133–5146 ≥ 4289; maximum ≈7.5 GiB). So the absence is **his poll not firing, not the gate refusing** — and an unsampled 92 s maximum is the one interval where a Kev-4B acquire could not have been observed even if it had happened. Recorded as ABSENCE, one more instance of the standing flag (recorded, never acted past, no preemption of his poll).

## Messages: none, each withheld for a different reason

* **@ocho — withheld.** The diff is `kev_window`, **not** a `planner_at global->planner` flip; his scoped-planner item was closed on the live channel 2026-10-13 17:25:42 / 17:28:53. `runtime/bot_live_delivery/` has no delivery newer than 2026-10-13 18:08. A true-but-redundant DM into a closed item is the drop hazard (9th stand-down of this class).
* **@llama — withheld.** The fallback ping is conditioned on a window being open when it is sent; free is **4125 MiB, 164 MiB under the gate**, so a "window open" message would be FALSE at the recipient's read (2026-10-12 blink class). He self-authorizes and is demonstrably mid-work (`profiles/llama/logs/agent.log` writing 07:52:33; `rescore_dflash.py` written 07:54:18).

## Touch log

Read-only on `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the driver stack. No model load, no acquire, no message, no `nvidia-smi -r`, no apt.

**Flagged for Mike (not routed into an undrained spool):** (1) the planner's 9B slot failed 7 consecutive rounds (06:40–07:40) with `group: starting ocho-planner failed: aborted`, and the round only completed on the 4B fallback slot at 07:50:37 — while `ocho_run_once.py:84 LIVE_BETTING_MODELS = {"ocho-planner"}` means the live slot is the 9B one that is not loading; (2) the kev gate can never be satisfied beside the planner's 4B/9B (R1); (3) Kev has not run since 2026-10-12 22:41 across every window this watcher has recorded.
