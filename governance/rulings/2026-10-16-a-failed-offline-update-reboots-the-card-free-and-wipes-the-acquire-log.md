# 2026-10-16 · An unattended failing offline update reboots the card free — and the reboot wipes the acquire log

**Tick** 2026-10-16 10:55:46.061732-07:00 (arcade-window-watch, job `67530e415818`), diff
`planner_at=planner kev_window=closed` → `planner_at=none kev_window=open`. Persisted sample
`cron/output/67530e415818/monitor_last_output.txt` = 31 B `planner_at=none kev_window=open`, sha256
`e5a5cecf07875807a2c8b52d5ac84009a2f6629df6d0c520f827d215b94805bb` == jobs.json
`monitor_state.last_output_hash`; previous sample 10:45:25.108, next run 11:05:44.773.

**RECORD + CONFIRMATION, not a new rule.** The rule these two tokens move by is already on file and is
cited by name below. What is new: *what manufactured this reboot*, and *what a reboot does to this
watcher's own instruments*.

## The reboot — two of them, 61 s apart, inside one sample gap

`journalctl --list-boots`: boot −2 `2026-10-15 10:48:00 → 2026-10-16 10:51:34`; boot −1
`10:52:03 → 10:52:27` (**24 s**); boot 0 `10:53:13 →` live (`uptime -s` 10:53:08). The previous sample
(10:45:25) predates the first reboot by **6 m 01 s**, and no instrument of this watcher reports either
reboot — the token compares two samples.

Cause, read from disk (three artifacts, R1):

* **boot −2:** `systemd-reboot.service` queued **10:51:26**, `Finished` 10:51:34, `reboot.target`. The
  same second `packagekit.service` and `gnome-software.service` stop (the offline-update staging pair)
  and `llama-swap.service` starts stopping.
* **boot −1** boots straight into `packagekit-offline-update.service`: `pk-offline-update` 10:52:07
  `status download` → 10:52:10 `package finished brave-browser-1.97.59.amd64` → 10:52:12
  `status finished`; `PackageKit[1393] update-packages transaction /264_dcecdbca from uid 0 finished
  with failed after 5084ms`; `failed to update system: Error while installing package: cannot copy
  extracted data for './opt/brave.com/brave/brave' to '/opt/brave.com/brave/brave.dpkg-new'`;
  `writing failed results`; 10:52:22 `rebooting` + plymouth *"Rebooting after installing updates…"*.
* **the results artifact:** `/var/lib/PackageKit/offline-update-competed` (229 B, 10:52) —
  `Success=false`, `ErrorCode=failed-initialization`, same detail. `apt-cache policy brave-browser`:
  **Installed 1.97.57 / Candidate 1.97.59**, the .deb cached
  (`/var/cache/apt/archives/brave-browser_1.97.59_amd64.deb`, 151,436,332 B, mtime 10-16 08:47) ⇒ the
  update is **unapplied and re-stageable**. Boot 0 runs `pk-offline` **0** times (marker present, no
  trigger file in `/var/lib/PackageKit/`) ⇒ the cycle stopped at two reboots, not a loop — this time.

## The lease release is a shutdown side effect, datable to the second

`Stopping → Stopped llama-swap.service` **10:51:27** (consumed 13 min 47.710 s CPU over 1 d 3 min
16.879 s, 12.5 G peak) — **that stop is the release**: `scopes/` dir mtime **10:51:27.453499306**,
`lease.mutex` **10:51:27.455499286** (Δ 2 ms = one mutexed `gpu-lease.sh` decision), `scopes/planner/`
**gone**. `user@1000.service` then times out in `stop-sigterm` and is SIGKILLed at **10:51:32**
(`Killing process 2296 (systemd)`, `2502 (hermes)`, `944080 (hermes)`, `2500 (python3)`). The lease
holder is llama-swap's own wrapper (`ps`: pid 16269 PPID 2394 = llama-swap, `bash gpu-lease.sh run
--owner llama-swap-ocho-planner --class batch --scope planner --need-mib 6200 --ttl 86400 -- …`).

So `planner_at planner→none` here is the wrapper's SIGTERM path — not a hand-back, not a policy
release, not the operator clearing the card. That class is on file:
`2026-10-13-a-reboot-manufactures-the-window` R1.

It re-arms on the reloader's clock: the `:00/10` round reloaded the 9B at **11:00:15.675**
(`scopes/planner/record.json` 490 B sha256 `4edb9113a9e51573b73e0976f18f425b3be30933702746ce4adb4bc70a9a4ca3`;
owner `llama-swap-ocho-planner`, scope planner, class batch, need_mib 6200, pid 16269, mode run,
ttl 86400, acquired_at 1792173615, expires 1792260015, headroom 256; resident child `llama-server`
pid 16349 `:5805` `Qwen3.5-9B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file ocho_grammar.gbnf`;
`/running` `{ocho-planner, state=ready}`; `ocho-planner-polymarket.service` 11:00:05 → 11:00:32 exit 0).

## The window, measured between its two edges

| edge | artifact | instant |
|---|---|---|
| open (release) | `scopes/` mtime | 10:51:27.453 |
| close (re-acquire) | `scopes/` mtime / record | 11:00:15.668 |

**528.215 s = 8 m 48 s 215 ms** (awk difference of the two mtimes; the record's `acquired_at` agrees to
the second). Live reads: sample 10:55:51 → 1473 used / **6419 free** = **+2130** over the 4289 gate
(*open*); write 11:01:42.821 / :44.853 / :46.885, three identical → 6661 used / **1230 free** =
**3059 UNDER** (*closed*), `nvidia-smi` rc 0 with numeric values. The gate script now prints
`planner_at=planner kev_window=closed` (five runs, byte-identical).

**Why it was open: nothing failed.** The only absentee was the planner, which the shutdown removed; the
11:00 reload of the *same* 9B slot loaded cleanly (`/running` ready, round exit 0). This is the
*post-boot/reload gap* member of the three classes named in
`2026-10-14-a-window-that-only-opens-when-the-planner-is-down` R1 (post-boot gap / failed load / smol
slot) — and it is the widest this watcher has logged (that filing's widest measured sub-tick gap: 92 s).

## R1 — the reboot's cause has an instrument; "mechanism unmeasured" is no longer the honest answer

`2026-10-15-a-reboot-resets-the-instruments-and-not-the-calendar` recorded both its boots as "ended at
reboot.target / systemd-shutdown with no panic recorded … **cause of the reboot is NOT established**".
It is establishable, in three reads: (a) `journalctl -b <n> | grep -i pk-offline` for the client,
(b) `/var/lib/PackageKit/offline-update-competed` for the outcome (`Success`, `ErrorCode`,
`ErrorDetails`), (c) `apt-cache policy <pkg>` plus the `.deb` mtime for whether it landed. **RULE: read
those three before writing "cause unmeasured"; and note the reboot is not conditional on success — an
offline update whose results read `Success=false` reboots anyway, twice, 61 s apart.**

## R2 — the acquire log is boot-scoped, because /tmp is tmpfs

`findmnt -no SOURCE,FSTYPE /tmp` → `tmpfs`; the shutdown log unmounts `tmp.mount`. After this reboot
**exactly one** capture exists: `/tmp/gpu-lease.ufA2Iv` (1740 B, 11:00) and it *is* the 11:00 acquire —
its head is the 9B load (`loading model '…/Qwen3.5-9B-UD-Q4_K_XL.gguf'`, `listening on
http://127.0.0.1:5805`). The pre-reboot captures that earlier filings cite **by name** (`rKiECz`
06:00:32.258, `XrbiOl` 07:00:34.258, `S24ul1` 07:10:28.250 in
`2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load` R1/R2) are absent from the box.
**RULE: across a reboot, the absence of a capture is uninformative — it cannot distinguish "no load"
from "wiped". A boot-crossing claim about which picks loaded must rest on `record.json` mtime/sha256
and the parent-dir mtime; "the acquire log is the /tmp capture set" holds only within one boot.** This
names one more boot-scoped instrument than the 10-15 filing's list (uptime, boot instant, pids,
"N lines this boot", launch latch) — add the capture set.

## R3 — a poll can be dead for part of a window, and that is now measurable

Every previous filing recorded the same sentence: "his poll is alive (ticker …), so the absence is his
choice". This window carries the mechanical half: **`2502 (hermes)` was SIGKILLed at 10:51:32** (the
gateway's own startup warning in boot −1: its previous life "exited UNCLEANLY (no exit path ran —
SIGKILL / OOM / VM death)", last heartbeat 10:50:59). The lane returned with boot 0 —
`profiles/llama/cron/ticker_heartbeat` and `ticker_last_success` both epoch 1792173704.798 =
**11:01:44.79**, pid 2478, started ≈10:53. So for the window's **first ~2 minutes Llama had no watcher
at all**; for the remaining ~6.8 minutes he had one, a card clear by 2130 MiB, and did not take it (no
`arcade`/`kev`/`llama-model-test` lease anywhere; `kev_run_bundle_full.json` still
`2026-10-12 22:41:49.816783026`; `coresidency_d1_kev.json` still `2026-10-15 12:50:41`). **RULE: date
the poll's liveness *inside* the window before filing "the gate was clear and nobody took it" as his
choice — a reboot SIGKILLs the poll, so the first minutes of a post-boot window are unattended by
construction.**

## Messages: none, and both premises are measured

* **No @llama.** The window is CLOSED at write (1230 free = 3059 under the gate) ⇒ the 4289 premise is
  false before the channel's ~27-min latency is considered; and his absence already has a mechanical
  explanation (R3). The satisfiable trigger remains the 10-15 filing's *"a window that FAILS TO CLOSE"*.
* **No @ocho.** The diff is a planner release, not a `global→planner` flip; his rows re-read: newest
  `profiles/ocho/state.db` rowids **14159–14164** (a conformance-census task, 2026-10-16) ⇒ nothing owed.

## Card

boot 0 began 10:53:13, uptime 10 m at write; module 615.71.09 loaded 10:53:16; `NVRM|Xid`-matching
lines this boot = **2**, neither a GPU fault (the module-load line + an r8169 ethernet `XID 541` at
10:53:13). The egl marker **moved** this boot: `~/.config/Hermes/nvidia-egl-fallback.json` (67 B, mtime
10:53) now reads `{"state":"fallback","version":"0.0.0","driverVersion":"615.71.09"}` where every prior
entry quoted `{"state":"ok"}` — a LAUNCH latch re-latched by the desktop's own heuristic
(`journalctl -b 0`: *"NVIDIA EGL fallback enabled (witnessed GPU-process death (app 0.0.0, driver
615.71.09)); routing ANGLE through SwiftShader"*), not a fault counter; recorded as a boot-scoped
instrument that moved (the 10-15 filing's R1, in its own terms).

## Touch log

Read-only: `nvidia-smi` (six reads), five runs of `arcade_window_watch.sh`, `journalctl`, `findmnt`,
`stat`/`sha256sum`, `ps`, `apt-cache policy`, one `sqlite3` read of Ocho's rows. No lease taken, no
model loaded, no run triggered; `gpu-lease.sh` / `llama-swap.yaml` / the planner lease / the driver /
the egl marker untouched; nothing written outside `governance/`.

**Flagged for Mike (not routed into an undrained spool):** the failing update is live and
re-stageable — `Installed 1.97.57` against `Candidate 1.97.59` with the .deb cached — and each re-stage
costs two reboots, ~25 s of dead instrumentation, and hands the Arcade an ~9-minute card window for
free: a card-freeing lever nobody has to authorise, arriving unannounced. The install fails copying
into `/opt/brave.com/brave/brave` with 132 G free on `/`, so it is not a disk-space failure.

**Citations.** `priorart.py` run BEFORE this file existed, three proposals: REVIEW-band **0.405** on
`2026-10-13-a-reboot-manufactures-the-window` (read by eye — it OWNS "a reboot manufactures the window"
and "the actionable quantity is *is it open at write*", so this filing does not restate it), plus
`2026-10-14-a-window-that-only-opens-when-the-planner-is-down` (read by eye — it owns the three classes
of `open`) and `2026-10-15-a-reboot-resets-the-instruments-and-not-the-calendar` (read by eye — it owns
the boot-scope rule this filing extends with the capture set); weak 0.190/0.168/0.139.

## RECURRENCE 2026-10-20 — the flagged item re-fired, four days later, same error string

The item flagged at the end of this filing was not hypothetical. `2026-10-20 08:00` (boot −1 `f3f3be92`, 08:00:20 → 08:00:46, **26 s**) ran `pk-offline-update` again and failed **identically**: `/var/lib/PackageKit/offline-update-competed`, 229 B, mtime 08:00 → `Success=false`, `ErrorCode=failed-initialization`, `ErrorDetails=Error while installing package: cannot copy extracted data for './opt/brave.com/brave/brave' to '/opt/brave.com/brave/brave.dpkg-new'`; `apt-cache policy brave-browser` → `Installed: 1.97.57` / `Candidate: 1.97.59`, i.e. **still unapplied and still re-stageable**, four days after the same failure was first measured. The three-read recipe of R1 above is what identified it in one pass, which is the reason to keep citing it.

Two things the recurrence adds, neither of which changes a rule already on file:

1. **The window's open edge was NOT the shutdown this time.** In 10-16 the release was llama-swap's SIGTERM path under shutdown. Here the maintenance boot fired the persistent planner timer at **08:00:25** — 5 s after boot, the same second `llama-swap.service` started — the round's LLM call **returned a completion**, and the round then failed *downstream* on a plan-conversion defect (`[plan] ❌ Contract not found: None` → `❌ Failed to convert classification to plan`, unit `status=1/FAILURE` 08:00:33, 174.7 M peak = not OOM). Its own EXIT trap released at **08:00:44.610991463** (`scopes/` mtime; `lease.mutex` 08:00:44.612256204, Δ 2 ms), so the window opened on a **round that loaded cleanly and failed afterward** — `2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly`'s class, not this filing's.
2. **The cost is now quantifiable per attempt and repeatable on demand:** two reboots (~26 s of dead instrumentation), a card window for free, and no authorisation anywhere in the chain. An offline update that reads `Success=false` reboots anyway — R1 said so — and it will stage again while the package remains unapplied.

Recorded from tick `67530e415818` at 08:01–08:06 PDT; log entry `2026-10-20T08:01-07:00` in `state/monitor/arcade_gpu_watcher.log`. Read-only: no lease, no model, no run; nothing edited outside this section.
