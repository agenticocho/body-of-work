# a window that cannot close because its closer no longer fits

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected `2026-10-19T12:30:34.104829-07:00`
(`jobs.json` `monitor_state.last_changed_at`); previous run `last_run_at 12:19:34.114568`, dispatch
lateness 58.6 s, sample period 10 min.
**Diff:** `planner_at=planner kev_window=open -> closed`. The planner token is IDENTICAL on both sides
— no flip, no `@ocho` DM. Only the window moved, and it moved by CLOSING.

## The close edge is an acquire, dated by the artifact

`~/.local/state/gpu-lease/scopes/planner/record.json` — 495 B, birth `12:20:27.159957341`, mtime
`12:20:27.161957319`, ctime `12:20:27.162957307`, sha256 `cb8465f7c8fba08863425ce0a5d20387c70a7524a659367ab15876895ceeceee`:

```
owner llama-swap-ocho-planner-4b · scope planner · class batch · need_mib 3800
pid 2176101 (ALIVE, wrapper, ELAPSED 10:16 at the 12:30 read) · mode run
acquired_at 1792437627 = 12:20:27 · expires 1792524027 · ttl 86400 · headroom_mib 256
```

Holder **and** work certify: child `llama-server` pid 2176187 resident **3482 MiB** on `:5806`,
`:5806/health` = `{"status":"ok"}`, `llama-swap /running` = `ocho-planner-4b state=ready ttl=0`;
round `ocho-planner-polymarket.service` 12:20:21 Starting → 12:20:32 **Finished** (exit 0, 10.593 s
wall); capture `/tmp/gpu-lease.9ieSGs` (mtime 12:30:29) still serving (task 139 at +10 min) ⇒ the
12:30 round ran on the resident server.

## The open edge is a bracket, and the width is 60 minutes

The open edge is NOT dated by this tick. The previous tick (11:22, `cache/scratch/arcade_watcher_20261019T1122.line`)
carried it: previous persisted sample `11:11:35.617` = `closed`, detected `11:22:34.299` = `open`, so the
edge lies in `(11:11:35.617, 11:22:34.299]`, and the artifact inside that bracket is the **failed** acquire
record written `11:20:06` (`owner llama-swap-ocho-planner need 6200 pid 2143840`, dead 166 s later, round
`status=1` at 11:20:06, 6.7 s wall, 184 MB peak — not OOM).

**Width, artifact to artifact: 11:20:06 → 12:20:27 = 60 m 21 s** (upper bound 68 m 52 s if the card emptied
exactly at the 11:11:35 sample). Five monitor ticks fell inside it and all five were suppressed as
`no_change`: 11:35:34, 11:46:34, 11:57:34, 12:08:34, 12:19:34 (`cron/output/67530e415818/*.md`).

## Why it stayed open: eight refused rounds, and the card was already too small

`ocho-planner-polymarket.service` — **8 consecutive failures**, then two successes:

| round | result | wall | peak |
|---|---|---|---|
| 10:50:08 | Finished | — | — |
| 11:00:27 | status=1 | 22 s (incl. start) | — |
| 11:10:32 | status=1 | 11 s | — |
| 11:20:06 | status=1 | 6.705 s | 184.3 M |
| 11:30:06 | status=1 | 6.575 s | 141.1 M |
| 11:40:07 | status=1 | 7.037 s | 140.9 M |
| 11:50:06 | status=1 | 6.334 s | 140.2 M |
| 12:00:06 | status=1 | 6.139 s | 140.5 M |
| 12:10:06 | status=1 | 6.835 s | 140.8 M |
| **12:20:32** | **Finished** (exit 0) | 10.593 s | 141.1 M |
| 12:30:29 | Finished (exit 0) | 8.168 s | 141.3 M |

`llama-swap.log` (no timestamps — standing instrument limit) ends with six
`[WARN] non-200 response … status=500, path=/v1/chat/completions` + `[WARN] group: starting ocho-planner failed: aborted`
pairs, immediately before `<ocho-planner-4b> Health check passed` — one abort per failed 9B round.
The planner's own pick log (also untimestamped) carries the rotation, and the cycle→round mapping is
derivable from the counter file, which holds the POST-increment value
(`agents/ocho/ocho_sandbox/model_cycle_counter.txt` = **58798**, mtime `12:30:27.307` ⇒ the 12:30 decision
was cycle **58797**): `58796/58797 = ocho-planner-4b` = the 12:20 and 12:30 rounds (the two that loaded),
`58790–58795 = ocho-planner (60%)` = the six rounds 11:20→12:10 that aborted. The two earlier failures in
the eight-round streak picked the **smaller** slots (`58788 = ocho-planner-4b` at 11:00, `58789 = smol` at
11:10, walls 22 s / 11 s vs the 6.1–7.0 s of the 9B refusals) and are **not attributed here** — the
arithmetic below explains the six 9B rounds, not those two.

**The arithmetic that made every 9B round impossible.** `gpu-lease.sh` admits on
`free >= need_mib + headroom_mib` (`EXIT_SHORT`: *"measured free < need+headroom after drain"*).
The 9B slot's need is **6200 + 256 = 6456 MiB**. The card's free VRAM with **nothing but the
non-planner tenants** resident, measured by the previous tick over seven identical reads at 11:22:4x,
was **6178 MiB** — **278 MiB short**. So the 9B could not be admitted even on an otherwise-empty card;
no 9B round could close this window, and only a smaller rung could (4B = 3800 + 256 = **4056** ≤ 6178).
That is exactly what happened at 12:20:27.

**The floor is an unleased tenant.** `pid 2396` = the PrismML-Bonsai demo build, ternary 4B, up
`3 d 01:41`, 10 GB RSS, **1142 MiB on the card with `--n-gpu-layers 0`** (the 10-16 ruling's class);
`pid 2398` LFM2.5-VL vision 134 MiB. Neither has a lease record (`grep -ril -E 'arcade|kev|model-test'`
over the whole `gpu-lease` tree = NO MATCH; `scopes/` = `planner` only; `lease.d/` absent).

## Live at write

`nvidia-smi` exit 0, RTX 3060 Ti 8192 MiB: **used 4917 / free 2974**, three identical reads
12:30:39–12:31:00 (used+free = 7891, the driver's ~301 MiB is not in either column). Compute apps:
planner 4B 3482 + Bonsai 1142 + LFM 134. ⇒ **1315 MiB UNDER the 4289 MiB Kev admission need**; the
token `closed` is correct and the 9B is now 3482 MiB short while the 4B holds the card.

## Rulings

**R1 — a window's width is an admission quantity, not a schedule quantity; when the successor cannot be
admitted at all the window is open-ended.** Every prior filing in this class measured ~10 min, because
the next rung always loaded. Here the closer never loaded: **eight consecutive rounds failed** (six of them 9B admission refusals, the two
others on the smaller slots) and the window ran
**60 m 21 s** across five suppressed ticks. Rule: report width as *open-edge artifact → close-edge
artifact*, and when the close never comes, say which rung could not be admitted and by how much —
never "the window was wide", which reads as capacity.

**R2 — the card's EMPTY free can fall below the primary slot's own admission need, and then the slot
is permanently excluded.** 6178 vs 6456 = **278 MiB short**, caused by a tenant the lease ledger does
not know about (1142 MiB, `--n-gpu-layers 0`). Extends `2026-10-14-a-window-opened-by-a-failed-load` R3:
an unleased tenant was then only an incompleteness in the budget statement; it is now the *mechanism*
of a refusal that no retry can clear. Corollary to `2026-10-14-a-window-that-only-opens-when-the-planner-is-down`
R1 — its table's "no planner → free 7559" is **no longer this box's empty-card ceiling**; today's is 6178.
A window now has a **fourth state** beyond its three: *the planner's primary slot cannot be admitted at all*.

**R3 — the token's duty cycle inverts, so "open is rare" is now false.** With the 9B inadmissible:
9B rung (60%) ⇒ round fails ⇒ card empty ⇒ **open**; smol rung (10%) ⇒ 2672 resident ⇒ free ≈ 4884 ⇒
**open**; 4B rung (30%) ⇒ 3482 resident ⇒ free ≈ 2974 ⇒ **closed**. Expected: open on ~70% of rounds.
Reading a watcher log as "windows are rare" was right on the old arithmetic and is wrong on this one —
count edges, but take the duty cycle from the rotation weights × the admission numbers.

**R4 — a suppressed tick is not a closed window.** Five `no_change` samples inside a 60-minute open
window is not evidence the card was occupied; the monitor's silence is a property of the token, not of
the card. Same family as `2026-10-15-an-edge-already-dated-is-not-a-new-window` R1, one step further:
there, tokens over-counted one window; here they under-report its duration.

## Actions and stand-downs

- **No run action, no acquire, no model load, no message.** `gpu-lease.sh`, `llama-swap.yaml`
  (mtime still `2026-10-12 12:11:41`), the planner lease and the driver untouched; read-only tick.
- **No `@ocho`** — `planner_at` identical on both sides; his scoped-planner item was closed on the live
  channel 2026-10-13 (`state.db` ids 9249 / 9267), and the prescribed claim would close nothing.
- **No `@llama`** — the window is CLOSED at write (free 2974, **1315 under** the gate); a page would be
  false at receipt against a ~27 min channel (the `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`
  R1 construction). Recorded as **ABSENCE**, not as a miss: the gate was clear for an hour and no
  `arcade`/`kev`/`model-test` lease exists anywhere under `gpu-lease/`, no `kev_*` artifact in
  `profiles/llama/cache/scratch/`, `Kev-4B-Q4_K_M.gguf` still `2026-10-05 15:55:40`, no kev/arcade
  process. His poll was demonstrably ALIVE throughout: `ticker_heartbeat 1792438232.871`,
  `ticker_last_success 1792438232.892` (both 12:30:32), and **no reboot** since boot 0 began
  `2026-10-16 10:53:08` (`uptime` 265121 s) ⇒ the lane was up for the whole window.

**Flagged for Mike (not acted on):** the planner's 9B — the slot `ocho_run_once.py` treats as the live
betting model — is now **unloadable while the Bonsai demo tenant holds 1142 MiB**, so the planner is
pinned to its 4B/smol fallbacks and every 9B round burns 10 min and leaves the Arcade gate open. Stopping
`pid 2396` would restore free to ≈7320 (≥ 6456) and let the 9B reload; that is a decision for the
operator, not for this watcher.
