# Arcade GPU Co-Residency Watcher — Ruling 2026-10-12

**Filed by:** Local Chair (profile `tiel`), on cron job `arcade-window-watch` (67530e415818)
**Signal:** `planner_at=global kev_window=closed->open` — the fourth such blink this session
**Ruling type:** procedure (log of record; closes no agent item)

---

## What changed

The watcher's change line reported `kev_window` opening. Read from disk at 19:25 PDT it had already closed:

| Reading | Value |
|---|---|
| `nvidia-smi` (single read) | used 6055 / free **1783** / total 8192 MiB |
| `lease.d/record.json` owner | `llama-swap-ocho-planner` (GLOBAL, scope EMPTY, class batch, need 6200) |
| lease pid / mode / headroom | 1909033, ALIVE, `mode=run`, 256 MiB |
| acquired / expires | 1791858021 (~19:20), +24h |
| `scopes/planner/` | **ABSENT** — scoped flip still not confirmed |
| `scopes/` | empty — no `arcade` / `llama-model-test` lease (Kev NOT acquired) |
| compute apps | llama-server pid 1909092, 5874 MiB on :5805, Qwen3.5-9B-UD-Q4_K_XL.gguf; gnome-control-center 47 MiB |

The window was real but transient: the 3B SmolLM3 planner lease (`llama-swap-ocho-planner-smol`, pid 1904960, acquired ~19:10) was replaced at 19:20 by the 9B planner, and free VRAM fell from ≥4289 MiB to 1783 MiB — **1750 MiB under the 4289 MiB Kev-4B admission need**.

## The pattern, stated plainly

This is the **fourth** `closed->open->reclosed` blink on a 10-minute poll (13:04, 14:46, 16:32, 19:25). Every one of them is the planner unload/reload cycle straddling the tick, not a stable window. Each time the live reading refuted the monitor's line. The log now carries all four, with the refuting numbers beside each.

## What was NOT done, and why

- **No acquire.** Forbidden by the prompt; Llama is self-authorized and polls on his own cadence.
- **No fallback ping to @llama.** The prompt allows one only if Llama failed to act across "a couple of ticks." Llama had **no opportunity to act** — the window closed inside the same 10-minute interval that opened it. A ping carrying "free is 1783 MiB" would be a false signal against the live reading, and the coordination rule explicitly forbids preempting his poll with stale state.
- **No message to @ocho.** `planner_at` stayed `global`; the scoped-planner flip remains unconfirmed, so there is nothing to close.

## Standing rule confirmed by this instance

**A transition is a property of the moment, not of the tick.** The watcher emits a discrete two-state line sampled every 10 minutes; a sub-10-minute excursion reads identically to a held state. The correct response to `kev_window=open` from this monitor is therefore *never* a bare relay — it is a disk read first, because the monitor's line and the artifact disagree most often exactly when the window is shortest, which is the window nobody can use anyway.

## Log of record

`~/.hermes/profiles/tiel/cache/scratch/arcade-gpu-window.log` — line 6 appended with the full live reading and this reasoning.
