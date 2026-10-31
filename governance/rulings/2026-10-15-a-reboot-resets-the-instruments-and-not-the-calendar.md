# a reboot resets the instruments and not the calendar

Tick 11:14:06 (monitor sample 11:14:07.564; previous persisted sample 09:54:07.560) — diff
`planner_at=planner kev_window=closed->open`. The planner token is IDENTICAL on both sides ⇒ no
planner flip, no @ocho DM (his scoped-planner item closed in HIS rows, 2026-10-13 17:49:44 carrying
the reading / reply 17:54:07).

THE BOX REBOOTED INSIDE THE HOLE, and no instrument of this watcher reports it: boot -2 ended
2026-10-15 10:45:42 at `reboot.target` (systemd-reboot.service, orderly), boot -1 ran 10:46:11 →
10:47:10 (59 s, also ended by systemd-shutdown), boot 0 started 10:48:00 (`who -b` 10:48,
`uptime -s` 10:47:55). The monitored token compares two SAMPLES and the previous sample predates the
reboot by 80 minutes, so this tick is a RECOVERY, not an edge; the open edge is dated by an ACQUIRE.
Cause of the reboot is NOT established (both boots ended at reboot.target / systemd-shutdown with no
panic recorded) — recorded as orderly, mechanism unmeasured.

R1 — THE ROTATION'S CALENDAR SURVIVED; THE BOOT-SCOPED INSTRUMENTS DID NOT, AND THE TWO SPELL THE
SAME IN A LOG LINE. The standing card clause quoted in every entry since 2026-10-14 12:49 read "boot
2026-10-14 12:49, uptime 21h05m, module 615.71.09, ONE NVRM|Xid line this boot = zero GPU faults,
egl marker ok mtime 12:50:26". Every one of those sentences is still quotable after the reboot and now
describes a different epoch: uptime 27m, boot 10:48:00, NVRM|Xid lines this boot = 2 (the module-load
line 10:48:03 + an unrelated r8169 ethernet XID 541 at 10:48:00 — still zero GPU faults), egl marker
re-latched `{"state":"ok"}` 10:48:31, pids renumbered (planner wrappers 19620/27947 against
852109/857141 an hour earlier). RULE: before quoting any boot-scoped measurement — uptime, boot
instant, pid identity, "N lines this boot", a launch latch — re-read the BOOT INSTANT, because
`who -b` / `uptime -s` is the only field that distinguishes "this boot" from "last boot" and the two
are indistinguishable in the sentence. What did NOT reset is the calendar: model_cycle_counter.txt is
on disk, so the rung prediction filed at 09:54 ("next smol = pos 9 = 58189 = the 11:10 round") was
made BEFORE the reboot and landed AFTER it, and its successor (58190 % 10 = 0 → 9B) closed the window.

R2 — A WINDOW'S WIDTH IS THE ROTATION'S ROUND SPACING, NOT A ~10-MINUTE CONSTANT. Measured 9m36s
this window (open 11:10:30 → close 11:20:06) against four previous instances of 9m57s–10m03s. The
acquire lag was 6 s on BOTH edges (round 11:10:24 → acquire 11:10:30; round 11:20:00 → acquire
11:20:06), so the width here IS the spacing between consecutive rounds — and the spacing is what
moved: the round timer re-anchored across the reboot (journal rounds 11:00:23, 11:10:24, 11:20:00 →
intervals 10m01s then 9m36s, against the pre-reboot :X0:05 phase recorded in every earlier entry).
RULE: phrase a predicted close as "the successor round's acquire", never as "≈10 minutes later", and
report a width with the two acquires that bound it.

R3 — BOTH EDGES READ LIVE ON THIS TICK (the standing discipline: a ~10-min window sampled at 10–19-min
cadence must have its close verified inside the tick or it is never seen).
OPEN 11:10:30 by the smol rung: record.json mtime 11:10:30.752, acquired_at 1792087830,
owner=llama-swap-ocho-planner-smol scope=planner class=batch need_mib=3000 pid=19620 ALIVE mode=run
ttl=86400 headroom=256 + resident child llama-server pid 19697 2672 MiB on :5808 + `/running`
{ocho-planner-smol, state=ready} + round 11:10:24 → 11:10:34 Result=success ExecMainStatus=0 +
latest_plan.json 11:10:34.189. LIVE AT THE OPEN TICK: 3105 used / 4786 free / 14 % util (nvidia-smi
exit 0) = +497 MiB over the 4289 gate.
CLOSE 11:20:06 by the successor's acquire: record mtime 11:20:06.742, acquired_at 1792088406,
owner=llama-swap-ocho-planner need_mib=6200 pid=27947 (started 11:20:05) ALIVE + child pid 28014
5874 MiB on :5805 + `/running` {ocho-planner, state=ready} + round 11:20:00 → 11:20:15
Result=success ExecMainStatus=0 + latest_plan.json 11:20:15.855. Free 1601 / used 6290 (three
identical reads) = 2688 MiB UNDER the gate ⇒ CLOSED at write. Counter 58191 (mtime 11:20:06.35) ==
last pick 58190 + 1 ⇒ gapless, no unlogged consumer.

ABSENTEES: no kev/arcade/model-test lease anywhere in the gpu-lease tree (4 files: two .pre-edit
backups, lease.mutex, scopes/planner/record.json), scopes/ = planner ONLY, the only /tmp lease temps
are the two planner rounds (11:00:30, 11:10:34), no kev/arcade/model-test unit (system or user), no
such process, kev_run_bundle_full.json mtime 2026-10-12 22:41 ⇒ the gate was clear by 497 MiB for the
full 9m36s and NOBODY took it. LLAMA'S POLL IS ALIVE, read POSITIVELY: profiles/llama/cron/
ticker_heartbeat and ticker_last_success both mtime 2026-10-15 11:18:23 (epoch 1792088303) ⇒ the
self-authorized poll survived the reboot and is beating, so the absence of an arcade lease is his
choice and not a dead watcher.

NO ACTION: no run, no model load, no lease taken; gpu-lease.sh / llama-swap.yaml / the planner lease /
driver / egl marker NOT touched (read-only). NO @llama ping (window CLOSED at write ⇒ the 4289 premise
is false at receipt, and the standing ratio — 9–10-min window against the channel's ~27-min latency —
makes a reactive ping false at receipt at any phase; the satisfiable trigger remains a window that
FAILS TO CLOSE). NO @ocho DM (diff is kev_window, not a planner_at global→planner flip).

CARD: healthy post-reboot — module 615.71.09 Open Kernel Module loaded 10:48:03, 2 NVRM|Xid-matching
lines this boot and neither is a GPU fault, 0 `Renderer process crashed` lines this boot, egl marker
re-latched ok at 10:48:31.
