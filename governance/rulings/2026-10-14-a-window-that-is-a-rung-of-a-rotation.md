# a window that is a rung of a rotation

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected 2026-10-14T11:43:54-07:00.
**Diff:** `planner_at=planner kev_window=closed->open` — planner token UNCHANGED on both sides; only the window moved.

## What was measured at write (11:44:0x – 11:46:27)

- `nvidia-smi` exit 0, RTX 3060 Ti 8192 MiB: **used 2995 / free 4897** — FIVE identical reads (11:44:0x, 11:46:18, :21, :24, :27) ⇒ **OPEN, +608 MiB over the 4289 MiB Kev-4B admission need.**
- Holder, from `scopes/planner/record.json`: `owner=llama-swap-ocho-planner-smol scope=planner class=batch need_mib=3000 pid=99340 kill -0 ALIVE mode=run acquired_at=1792003228` (= 11:40:28) `headroom_mib=256`; wrapper `gpu-lease.sh run --owner llama-swap-ocho-planner-smol … -- llama-server --port 5808 --model SmolLM3-3B-128K-UD-Q4_K_XL.gguf`, child of llama-swap pid 2390; resident child `llama-server` pid 99420 **2672 MiB** on :5808; `scopes/` = `planner` ONLY, `lease.d/` ABSENT.
- Occupants: planner-smol 2672 + vision pid 2395 134 (CPU-only, `-n-gpu-layers 0`) + gnome-software 31.
- Work certifies as well as the lease: round 11:40:22 → Finished 11:40:31 `Result=success ExecMainStatus=0`; `latest_plan.json` 11:40:31 `model_slot=ocho-planner-smol`; **every round 10:20 → 11:40 exited 0** — no failure anywhere in this interval.
- Arcade holder: **NONE in every read** (no `kev`/`arcade`/`llama-model-test` lease under `gpu-lease/`); `kev_probe.json` / `kev_server.log` / `kev_run_bundle_full.json` all mtime **2026-10-12 22:41**.

## R1 — The window can be produced BY DESIGN; it needs no fault.

Prior filings in this class attributed each open to a non-9B occupant and each *cause* to something going wrong: a failed load (`2026-10-14-a-window-opened-by-a-failed-load`), a post-boot empty-card clock (`2026-10-13-a-post-boot-window-is-a-clock-not-capacity`), a foreign drain (`2026-10-14-a-drain-by-another-tenant-manufactures-the-window`), the ladder's bottom rung (`2026-10-14-a-constant-token-over-a-two-holder-rotation`). **This one needed no fault at all.** `call_ocho_planner.py:428 pick_model_slot()` is a deterministic weighted rotation — `O55_WEIGHTS = {ocho-planner: 6, ocho-planner-4b: 3, ocho-planner-smol: 1}` over `MODEL_SLOTS`, `pos = count % 10` — so **once in every ten rounds (≈ every 100 min) the planner parks the smallest rung (2672 MiB) instead of the 9B (5874 MiB) and the Kev gate is satisfied as a side effect.** Report it as *which rung is resident*, and expect recurrence on the rotation's own period; a window that is a schedule product is not evidence of degraded capacity.

## R2 — The rung is readable from three artifacts, and the counter file is off by one.

The rung is named by the planner's own log line, e.g. `[O55] 🎲 Weighted pick: ocho-planner-smol (10% weight, cycle 58039, pool 3/3)` at the 11:40 round; preceding picks `58034/58035 = ocho-planner` (9B) and `58036/58037/58038 = ocho-planner-4b`. Mapping cycles to rounds 1:1 backwards from `58039 = 11:40` makes 11:10/11:20/11:30 the 4B rounds — which is exactly why the 11:21:54 and 11:32:54 monitor samples read CLOSED at free ≈ 4125 — and makes 10:00 = `58029` pos 9 (smol) and 10:10 = `58030` pos 0 (9B), matching the earlier entries. **Read the cycle from the LOG LINE, not from `model_cycle_counter.txt`:** the file holds the POST-increment value (`58040`, mtime 11:40), so taking the rung from the file puts it one cycle later than the round that ran. Same family as *a count of a growing record is a timestamp*: the artifact's value is the value after the write, not the value the decision used.

## R3 — A prediction filed before the event is the only cheap control on this mechanism.

Recorded here, dated, and checkable against the next entries of the watcher log:

- **This window closes at the 11:50:22 round** — cycle `58040` ⇒ pos 0 ⇒ 9B (5874 MiB) ⇒ free ≈ 1395, i.e. ~2894 MiB under the gate. (Window held ~10 min: 11:40:28 → 11:50:2x.)
- **The next smol rung is cycle `58049`, i.e. the ~13:20 round** — one rotation period ≈ 100 min, absent a change in `pool` (currently 3/3 eligible per `model_brier_report.json`, regenerated 11:00, which would re-weight the ladder if a slot were demoted).

## Actions

No run action; nothing acquired; no model load. **No `@llama` fallback ping** — this is the window's first tick (hold-one-tick), and the window is dated to close ~4 min after the write while this channel's measured latency is ~27 min, so the ping would arrive after the close and be FALSE at receipt (the 2026-10-12 blink class); he self-authorizes under the operator precedence clause. **No `@ocho` DM** — the diff is `kev_window`, not a `planner_at global->planner` flip (`planner` on both sides), and the closure of his item is checked in HIS rows: `profiles/ocho/state.db` newest inbound (`role='user'`) 2026-10-13 20:00:21, newest outbound (`assistant`) 2026-10-13 20:05:46, nothing newer (15th consecutive stand-down of the class).

Untouched, read-only: `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, any model load, the egl marker. Flagged to Mike, unchanged: `~/.config/Hermes/nvidia-egl-fallback.json` = `{"state":"fallback","version":"0.0.0","driverVersion":"615.71.09"}` (relatched 10:06) while the card is healthy (module 615.71.09, zero GPU faults this boot) — fix `{state:ok}` takes effect on the next launch.
