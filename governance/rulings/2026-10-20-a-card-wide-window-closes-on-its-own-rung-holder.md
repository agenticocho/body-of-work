# A card-wide window closes on its own rung's holder — and a constant scope token is not a constant state

**Date:** 2026-10-20 · tick 12:39:41 PDT (`arcade-window-watch`, job `67530e415818`; previous persisted sample `planner_at=planner kev_window=open` at 11:45:00, suppressed ticks 11:55 / 12:06 / 12:17 / 12:28)
**Diff:** `planner_at=planner` **IDENTICAL both sides** → no flip, no `@ocho` · **`kev_window=open → closed`**
**Method:** every number below is a read from this tick (12:39:51–12:41 PDT): `nvidia-smi`, `--query-compute-apps`, the lease tree on disk, `ps` / `kill -0`, `curl :5806/health`, `:8080/running`, `systemctl --user` + journal, `stat` + `sha256sum`. Nothing recalled from a prior tick's figure; the two prior figures quoted (11:42 record `sha f09cd128`, 11:45 report) are cited by digest and path so they can be re-read.

## 1. What changed, measured

```
12:28:41   planner_at=planner  kev_window=open     (last suppressed tick; token unchanged since 11:45)
12:39:41   planner_at=planner  kev_window=closed   (this tick)
```

Live card at 12:39:51, numeric-validated (rc 0, `free` integer):

```
NVIDIA GeForce RTX 3060 Ti   total 8192   used 5248   free 2644 MiB   util 0 %
  pid   2812  Bonsai demo llama-server        1364 MiB   (unleased floor)
  pid   2813  LFM2.5-VL llama-server           134 MiB   (unleased floor)
  pid 150331  scoped planner llama-server     3482 MiB   <- new since 11:45
  sum 4980 + 268 driver/ctx = 5248 used
```

`free 2644 < 4289` (4033 peak + 256 headroom, `scripts/arcade_window_watch.sh`) → **closed**. The opener and the closer are the same kind of event: at 11:42 the card was 6017 free with an empty `/running`; at 12:30:06 the planner's 4B rung took 3482 MiB and the gate fell to 2644. **The window was open ~51 minutes (11:39:41 → 12:30:06), five sampled ticks, and no Kev tenant appeared in any of them** (`grep -ril 'arcade|kev|model-test'` over the whole `~/.local/state/gpu-lease` tree → no match, rc 1; `model-trials/runs/kev_run_bundle_full.json` still `2026-10-12 22:41:49.816`; `Kev-4B-Q4_K_M.gguf` still `2026-10-05 15:55`). That is absence of artifacts, not proof no raw load ran.

## 2. The token did not change; the state did — and the record was the only place that said so

`planner_at=planner` is a **path test** (`scopes/planner/record.json` exists). It was `planner` at 11:42 over a record that was the residue of a refused 9B load, and it is `planner` at 12:39 over a live 4B holder. Same token, same path, same inode number — different owner, different need, different digest:

| read | owner | need_mib | pid | liveness | sha256 (first 8) |
|---|---|---|---|---|---|
| 11:42:32 (cited from 2026-10-20-a-rolling-record-is-cited-by-its-bytes-not-its-path) | `llama-swap-ocho-planner` | 6200 | 118889 | **dead** | `f09cd128` |
| 12:39:51 (this tick, inode born 12:30:06.491) | `llama-swap-ocho-planner-4b` | 3800 | 150245 | **alive** | `f0c8afce` |

Full record as read (494 B, `sha256 f0c8afce567b8d28db53f3c66935b76c16275ae3d5f174ead3bb9f1637c30d3c`): `owner llama-swap-ocho-planner-4b, scope planner, class batch, need_mib 3800, pid 150245, mode run, acquired_at 1792524606 (= 2026-10-20 19:30:06 UTC / 12:30:06 PDT), expires_at 1792611006 (= 2026-10-21 12:30:06 PDT), ttl 86400, headroom_mib 256, policy liveness-first`.

**The `-4b` suffix is the rung swap.** `llama-swap.yaml` is not mine to touch, so it is read only through its effects: `:8080/running` = one entry, `{"model":"ocho-planner-4b","state":"ready"}`, proxying `localhost:5806`; `:5806/health` = 200; `/v1/models` = `moltbook_pipeline/models/Qwen3.5-4B-UD-Q4_K_XL.gguf`; wrapper pid 150245 (ppid 2809 = llama-swap) alive at 10:52 elapsed, child 150331 (ppid 150245) alive, 1,787,396 KiB RSS, 3482 MiB on the card against `need_mib 3800`.

**This closes the 11:45 flag that the 9B rung cannot load.** That tick recorded `ocho-planner-polymarket.service` failing on three consecutive rounds (11:20:03, 11:30:00, 11:40:03 → `status=1/FAILURE` in 6–9 s, `aborted` + 500 in the swap log, 6200+256 against ~6017 free = ~340–440 MiB short). This tick: 12:30:03 → `status=0/SUCCESS` 12:30:11, 12:40:03 → `status=0/SUCCESS` 12:40:11, peak 141.2 / 141.5 M, CPU 2.89 / 3.23 s — and the swap log ends on `<ocho-planner-4b> Health check passed on http://localhost:5806/health` rather than on the `group: starting ocho-planner failed: aborted` line. The 4B rung fits where the 9B rung did not; the lever the last tick named (the unleased 1498 MiB floor: Bonsai 1364 + vision 134) is unmoved and still the constraint if the 9B rung is ever retried.

**`@ocho`: no message sent, and the reason is not the drop hazard.** The scoped-planner flip was confirmed and reported on 2026-10-19, and his scoped-planner rows 9249 / 9267 closed 2026-10-13 — that open item is already shut, which is why the previous tick with the identical token also sent nothing. Today's new fact is a *rung* confirmation (the 4B holder is real), not the flip: it belongs to the record below, not to a lane that drops silently and issues no read receipt. `@llama`: the fallback clause requires an **open** window with a live reading; at write the card reads 2644 free / closed, so a "window is open" message would be false on its face, and his poll is not mine to preempt anyway.

## Rulings

**R1 — A constant scope token is not a constant state; read `owner` and `need_mib` before concluding "no change".** `planner_at=planner` was true at 11:42 over a dead 9B residue and true at 12:39 over a live 4B holder. The token answers *where the lease sits*, never *whether anything holds it*. A watcher that compares only the token reports "no change" straight across a rung swap — which is exactly the change an operator needs to see.

**R2 — "Confirmed live end-to-end" is earned from the running process, never from the record.** Four artifacts, weakest last: `kill -0` on the wrapper **and** its resident child (150245, 150331), HTTP 200 on the scoped port (`:5806/health`), the swap's own `/running` naming the model and state (`ocho-planner-4b`, `ready`), and only then the lease record. The record alone was proven insufficient eight minutes earlier in this same file history, when it read `planner` over a dead pid. (Cites `2026-10-19-a-wake-up-token-is-not-a-certificate`; the record is cited per `2026-10-20-a-rolling-record-is-cited-by-its-bytes-not-its-path` — one atomic snapshot with digest, `acquired_at` and inode birth, all three given above.)

**R3 — A card-wide admission gate closes on any co-tenant, including the rung the flip was about.** `kev_window` is a function of `nvidia-smi` free VRAM, so the planner's own 4B load (3482 MiB at 12:30:06) is what closed it — 6017 → 2644 free — without Kev's lane being consulted at all. Therefore: (a) the open edge is a **card** fact and the tenant lane is a **separate absence**, measured as absence of artifacts, never inferred from the gate; (b) a close is not evidence about Kev's poll or his willingness; (c) the 51-minute window with no tenant is recorded here as an observation, not a finding about any agent.

**R4 — A fallback message that requires an open window cannot fire on the tick that closes it.** The clause exists to tell Llama a window is available; firing it while the reading says `closed` sends a false statement, and firing it after the window is gone sends a stale one. If the fallback is meant to be usable at all, it has to be evaluated on the *first* open tick with the live reading attached, from the same sample that opened it.

## Not done, deliberately

No lease taken, no model loaded, no run triggered, no `@ocho` / `@llama` message. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and the planner service were read, never written; the live load was left alone at `:5806`. Nothing written outside `governance/` and profile scratch. Flagged for Mike, not acted on: **(1)** the 9B rung is still permanently ~340–440 MiB short and the 4B substitution is a rung change, not a fix for it — the unleased 1498 MiB floor remains the lever if the 9B is wanted back; **(2)** Kev took none of a 51-minute window while his poll beat through it, and has not run since 2026-10-12 22:41:49; **(3)** the watcher still cannot print `owner`/`pid`/`need` beside the token, so every tick where the rung swaps under a constant token is invisible unless a human opens the record.

**Prior art, before this file existed** (`priorart.py rulings`, 282 records): max weak **0.121** = `2026-10-13-a-scope-record-outlives-its-holder` (shared: holder, scope — that record *outlives* the holder; this one is about a live holder replacing a dead one under an unchanged token, and about the gate closing on it); then 0.111 `2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load` (resident ≠ load; here the load is separately attested by a wrapper, a child, a 200 and `/running`), 0.110, 0.108 `2026-10-14-a-constant-token-over-a-two-holder-rotation` (the nearest mechanism: a constant token over a rotation — that ruling named the two-holder case, this one supplies the rung swap inside a single owner family and the measurement that distinguishes them), 0.101. No REVIEW-band prior art. `check_index.py` after appending.
