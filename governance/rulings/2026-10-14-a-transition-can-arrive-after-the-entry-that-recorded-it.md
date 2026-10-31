# 2026-10-14 · A transition can arrive after the entry that already recorded it

**Tick:** `arcade-window-watch` (job `67530e415818`), diff
`planner_at=planner kev_window=open` → `planner_at=planner kev_window=closed`.
Monitor samples: previous run claimed 10:13:25.945 (scheduled 10:13:00, lateness 26.8s);
this run dispatched 10:23:52.769; `monitor_state.last_changed_at` = **10:23:55.315**.
Only the `kev_window` token moved; `planner_at` read identically at both ends.

## Live reading (artifact, not memory)

Three identical reads 10:24:0x–10:24:1x PDT, `nvidia-smi` exit 0, RTX 3060 Ti 8192 MiB:

- card: **6496 MiB used / free 1395 MiB** ⇒ 2894 MiB **under** the 4289 MiB Kev admission
  need (4033 peak + 256 headroom) ⇒ `kev_window=closed`, CONFIRMED.
- occupants at write: planner `llama-server` pid **58828** 5874 MiB (`Qwen3.5-9B-UD-Q4_K_XL`,
  ctx 8192, `ocho_grammar.gbnf`, `:5805`); vision `llama-server` pid 2395 134 MiB (`-n-gpu-layers 0`);
  `llama-server` pid 60804 294 MiB (`Tiel-Inspired-Coder-9B`, api-key `injtest`, `-n-gpu-layers 0`);
  `gnome-software` pid 5612 31 MiB.
- ledger: `scopes/planner/record.json` owner `llama-swap-ocho-planner` scope `planner` class
  `batch` need_mib 6200 pid **58729** `kill -0` ALIVE acquired_at 1791997831 = **10:10:31**
  (+24h, headroom 256) + resident child pid 58828 5874 MiB; `lease.d/` ABSENT; `scopes/` = planner
  ONLY; `grep -rl llama-model-test` under `gpu-lease/` = NONE.
- work certifies too (not only the lease): round `ocho-planner-polymarket.service` Result=success
  ExecMainStatus=0, exit 10:20:35; `ocho_sandbox/plans/latest_plan.json` 10:20:35;
  llama-swap `/running` = `ocho-planner state=ready proxy=:5805`.
- Kev absence, dated on the real paths (this log has been citing the wrong ones): `kev_probe.json`
  2026-10-12 22:41:02, `kev_server.log` 22:41:18, `kev_run_bundle_full.json` 22:41:44/49 — all under
  `profiles/llama/cache/scratch/` and `profiles/llama/model-trials/runs/`, **not** `moltbook_pipeline`
  (that dir holds only the gguf, mtime 2026-10-05 15:55:40). No `arcade` / `kev` / `llama-model-test`
  line in the user journal since 10:00.

## What dated the transition

The **close** is dated by the artifact to **10:10:31** — the 9B wrapper's record `acquired_at`
(1791997831) and its child's process start (ps ELAPSED 812s at 10:24:03 ⇒ 10:10:31) — with free
already 1337 MiB at 10:10:56. The **open** is bracketed by the previous entry's own measurement:
10:00:27/28 (4B stopped → smol started) → 10:10:22/31, ~10 min held, free 4539 at the open read,
**+250 MiB over the 4289 gate**. Both were filed in the previous tick's entry
(`2026-10-14-a-constant-token-over-a-two-holder-rotation.md`), which measured the closure directly
at 10:10:56 — *before* the monitor sample that this tick is reporting it from.

## R1 — A monitor token is sampled on the monitor's clock, so it can report an event the previous entry already dated

The monitor emits one thresholded token per sample; the agent entry writes when it is woken. Those
are two different clocks, and here they crossed: the previous entry had already read the artifact,
dated the close and filed it, while the monitor's stored token was still `open` from the sample that
had woken it — so **the same physical event surfaced in two consecutive ticks and the second one is a
re-report, not news**. Rule: before writing a transition as news, check the previous entry's live
reads for that same transition already dated; if it is there, record the token's arrival as the
token catching up and name the artifact time, do not restate the event as a fresh change.
This is narrower than, and must not be confused with, *a diff between two samples brackets the event*
(2026-10-13): there the two samples bracketed an event the tick had **not** seen; here the event was
already measured inside the prior tick and only the token lagged.

## R2 — The measured margins of today's "windows"

Both rungs are now measured rather than inferred: the ladder's **bottom** rung (smol 3B) leaves
**+250 MiB** over the gate (free 4539, 10:00–10:10) and the **top** rung (9B, 5874 MiB) leaves
**1395 MiB free = 2894 under** it. The tolerant margin is smaller than one ordinary tenant's
footprint — measured on this card: an unledgered eval `llama-server` (pid 60804, `-n-gpu-layers 0`,
no lease record) holds **294 MiB** of it. So a `kev_window=open` on this box has been, all day,
either the footprint of a failed load or a sub-tenant-sized margin; the gate is arithmetically
satisfiable only against a sub-smol slot or an empty card.

## Actions taken

- **No run action, no model load, no `gpu-lease.sh` / `llama-swap.yaml` / planner lease / egl marker
  touched** (read-only).
- **No `@llama` fallback ping.** The clause's premise is "a window open at the recipient's read": free
  is **1395 MiB, 2894 under** the gate ⇒ a ping now would be false (2026-10-12 blink class). Across
  the whole 10:00–10:10 window no `arcade` / `kev` / `llama-model-test` lease existed and no Kev
  artifact was written (Kev last ran **2026-10-12 22:41**), recorded as **ABSENCE**, not acted past;
  he is self-authorized under the operator precedence clause and polls.
- **No `@ocho` DM.** The diff is `kev_window`, not a `planner_at global->planner` flip; his one open
  item was closed by an inbound row in **his own** log at 2026-10-13 17:49:44, answered by his reply
  17:54:07; newest inbound row 2026-10-13 20:00:21 and newest outbound delivery artifact 2026-10-13
  18:08:37 ⇒ nothing of mine in flight, nothing open to close. **14th stand-down of this class**,
  logged with the pointer so silence reads as an omission only if it is unrecorded.
- Flagged to Mike, unchanged: with the planner 9B resident (need 6200, 5874 MiB actual) the 4289 gate
  is unsatisfiable by construction; Kev has not run since 2026-10-12 22:41 across every window this
  watcher has recorded.
