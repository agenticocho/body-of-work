# A window opened by a failed load is a symptom, not capacity

**Date:** 2026-10-14 · **Scope:** Arcade GPU co-residency watcher (`profiles/tiel/scripts/arcade_window_watch.sh`)

## Rulings

**R1 — a free-VRAM window is reported with its occupants and its absentees, never as a bare number.**
`free=5133MiB` is a true measurement and, on its own, an actionable-looking one. Its *meaning* depends on who is missing from the card. Here the card was free because the tenant that belongs there — Ocho's planner 9B, need 6200 MiB — could not load. A window must be filed as *"free N, held by X, and Y is absent (why)"*. The actionable quantity is not *is it open* but *why is it open*.

**R2 — one fault can emit two tokens in apparent opposition; a diff counts events, it does not date or classify them.**
The same load failure produced both halves of this tick's diff: the failed round *wrote* `scopes/planner/record.json` at 07:00:36 (so `planner_at=planner`, which the watcher tests by file existence, `[ -f "$PLANNER_SCOPE_LEASE" ]`) and it *left the card empty* (so `kev_window=closed->open`). Read as a pair, the diff says "the scoped planner is present and the card is free" — i.e. opportunity. It was one fault counted twice. Liveness is not existence; a record written by a failing acquire is evidence of a repeatedly failing acquirer.

**R3 — the lease ledger's coverage is not the card's coverage.**
A `llama-server` holding 2474 MiB of the card had **no lease record anywhere** under `gpu-lease/` (`scopes/` = planner only, `lease.d/` absent): it was spawned directly by a test harness, not through a gpu-lease wrapper, and that harness's own docstring declares it "CPU-only, no card needed". So "no arcade/kev lease exists" and "the card is N MiB free" can both be true while an unleased tenant sits on the card. Any budget statement sourced from the lease ledger, or from `nvidia-smi` alone, is incomplete without the other.

## Evidence (all read from disk this tick)

- Card: `nvidia-smi` exit 0 — 2758 MiB used / **5133 MiB free** / 8192 total; three reads 07:00:54, 07:02:04, 07:04:56 **identical** ⇒ window open at write, 844 MiB over the 4289 MiB Kev-4B admission need (4033 peak + 256 headroom).
- Compute apps: pid 2435 vision server 134 MiB; pid 281251 `llama-server` **2474 MiB** (Ornith-1.5-9B-Q4_K_M + DFlash draft, `--n-gpu-layers 0`, `:42620`, started 06:56:13 via `systemd-run` unit `dflash-safety.service`, parent `profiles/llama/cache/scratch/ornith_dflash_injection.py`).
- `llama-swap` `/running` = `[]` — **no planner model resident**. Log: `group: starting ocho-planner failed: upstream command exited prematurely`, then `group: starting ocho-planner failed: aborted` ⇒ HTTP 500 on `/v1/chat/completions`.
- `ocho-planner-polymarket.service`: failed 06:40:36, 06:50:28, 07:00:36 — three consecutive `status=1/FAILURE`. Last successful round and `latest_plan.json` = **06:31:02.699**. The 9B has been off the card since ≈06:31–06:40.
- `scopes/planner/record.json` mtime 07:00:36.404, `acquired_at` 1791986436 = 07:00:36, owner `llama-swap-ocho-planner`, need 6200, pid **283162** — `kill -0` = *No such process*, `/proc/283162` absent 18 s after the write.
- Bracket: previous sample (05:16:45→05:22:02) read `closed`; this sample reads `open`. The transition lies in 05:22–07:00 and is pinned by the 06:31:02 last plan and the 06:40:36 first failure.
- Entitlements: no kev / arcade / llama-model-test lease anywhere under `gpu-lease/`; `Kev-4B-Q4_K_M.gguf` mtime 2026-10-05 15:55:40; newest arena Kev artifact 2026-10-09 17:11 ⇒ no Kev run in this window.

## Actions

- **No run action**; `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and any model load untouched (read-only tick).
- **No @llama fallback ping** — first open tick, and Llama is demonstrably mid-work on this same card (his `dflash-safety` unit started 06:56:10; `profiles/llama/logs/agent.log` writing 06:57); he self-authorizes on his own continuous poll under the operator precedence clause.
- **No @ocho DM.** His one open item (the `--scope planner` flip) was closed on the live channel 2026-10-13 17:25:42 / 17:28:53 and the flip invariant was certified there; this tick's diff is a window transition, not a flip. The *new* fact — his planner rounds failing three times — is his own service, is visible in his own logs, and is reported to Mike instead of being routed into an inbox spool nobody drains. Stand-down logged so silence cannot read as an omission.
- **Flagged for Mike (not corrected out of band):** (a) the planner model group cannot start, so there has been no successful planner round since 06:31:02; (b) an unleased 2474 MiB tenant is on the card, invisible to the lease ledger.
