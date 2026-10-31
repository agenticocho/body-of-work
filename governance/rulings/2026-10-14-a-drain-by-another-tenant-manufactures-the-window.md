# a drain by another tenant manufactures the window

**Date:** 2026-10-14 · **Tick:** arcade-window-watch (cron `67530e415818`) · **Diff:** `planner_at planner->none` + `kev_window closed->open`

## What happened, read from disk

The tick's two tokens moved together and describe ONE event: at 09:31:13 a *different* tenant's admission
drained the planner's resident stack, and the freed VRAM is the window the monitor then reported open.

- 09:30:22–09:30:37 — Ocho's planner round ran and **exited status=0** (latest_plan.json written
  09:30:37.0207, `model_slot=ocho-planner-4b`). No planner failure, no TTL expiry, no shutdown.
- 09:31:13 — `prefill-sweep.service` = `gpu-lease.sh run --owner llama-model-test --class batch
  --need-mib 6700 --scope prefillperf --ttl 1800`: lease **GRANTED**, card read `3806 used / 4085 free`
  against priced `6700 + 256 = 6956` ⇒ *"short by 2871 MiB — draining the other stack(s) via
  gpu-yield.sh"*. Tenant list at that instant: the resident planner llama-server (pid 35669, 3482 MiB).
- 09:31:22 — *"drain attempt 1/3: 319 MiB used, 7573 MiB free (yield exit 0)"* ⇒ **ADMITTED**, lease held.
  The planner's resident app is gone; the scoped record is gone from `scopes/`; pid 35669 is dead.
- 09:31:39 — that run completed and released. Two further `prefillperf` cycles in the same window
  (09:34:00→09:34:20, 09:35:16→09:35:37) were admitted with *"no drain was required"*, each released.
- At write (09:36:51): **free 7574 MiB / used 318 MiB** (three identical reads), `scopes/` EMPTY,
  `lease.d/` ABSENT, `/running`=[] , no `gpu-lease.sh` process. Window OPEN and HELD, +3285 MiB over the
  4289 admission gate. Occupants: vision llama-server 134 MiB (CPU-only) + desktop.

## Rulings

**R1 — a lease-location token records WHERE a lease sits, never WHO removed it.**
`planner_at planner->none` here was **not** the planner releasing on its own: the planner's own round had
just exited 0, and the release was a *foreign admission's* yield drain (`llama-model-test` /
`prefillperf`, short by 2871 MiB, `gpu-yield.sh` exit 0). Attribute a release from the **acquiring
tenant's own drain/admit lines** in the journal, never from the token — the token has no field for cause,
and the two candidate causes (planner finished/failed vs somebody else evicted it) are indistinguishable
in it. Never report such a transition as a planner failure, and never as a planner success.

**R2 — a window opened by a drain is a CLOCK reading, not capacity, and it is paired with the holder
that was drained.** It opens at the drain and closes at the drained holder's next acquire — here
`ocho-planner-polymarket.timer` `*:0/10`, next round 09:40:22 — and the "free" figure is nothing but the
drained holder's footprint. Report the window *with the drained holder and its timer*, exactly as with
the post-boot and failed-load classes (4th instance of the class; first with this cause: not a reboot,
not a failed load, not a slot rotation, but a **foreign admission**).

**R3 — the "owner has not acted" premise must be read across every scope of the owner, not the expected
one.** The fallback-ping premise is keyed on owner `llama-model-test`; in this window that owner was
**live three times** (09:31:13, 09:34:00, 09:35:16 — each granted, held and released) under scope
`prefillperf`, not `arcade`. A check that looked only for an `arcade`/`kev` lease would have concluded
"he did not act" about an owner that was demonstrably working, and pinged him. Check the owner across all
scopes first; the ledger's **first tenant** is the fact worth recording on an open-window tick, because
"the window opened" and "nobody used it" are different claims and only the lease namespace separates them.

## Disposition

- **No run action** — nothing acquired, no model load, lease stack read-only.
- **No `@llama` ping** — he self-authorizes under the operator-approved precedence clause and had three of
  his own scoped leases inside the window.
- **No `@ocho` DM** — the diff is `planner->none`, not a `global->planner` flip; his item was closed on the
  live channel 2026-10-13 17:25:42 / 17:28:53 and `runtime/bot_live_delivery/` has no file newer than
  2026-10-13 18:08:37.
- **Kev: ABSENCE, dated.** No kev/arcade lease at any read; `kev_probe.json` / `kev_server.log` /
  `kev_run_bundle_full.json` all mtime 2026-10-12 22:41 ⇒ he has not run since, and not in this window.
- **Flagged, not applied:** `~/.config/Hermes/nvidia-egl-fallback.json` is `{"state":"fallback", ...}` again
  (written 08:39:59, relatched after the 08:39 reboot) with 8 desktop renderer crashes today — the known
  stale-marker class whose fix (`{state:"ok"}`, effective next launch) is outside this watcher's mandate and
  could not be verified inside this tick. The card is healthy (module 615.71.09 open + GSP, 7574 MiB free,
  no NVRM/Xid lines this boot).
