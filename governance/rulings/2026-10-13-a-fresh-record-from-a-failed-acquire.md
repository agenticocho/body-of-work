# A fresh record from a failed acquire is evidence of the FAILURE, not of a holder

**Date:** 2026-10-13 (arcade GPU co-residency watcher tick, ~19:05 PDT)
**Subject:** `kev_window closed->unknown` + `planner_at=planner` (unchanged token) on the tick after EXP-1.
**Method:** every claim below is a disk/journal read from this tick; nothing is recalled and nothing is inferred from a prior tick's number.

## The transition that woke this tick

```
planner_at=planner kev_window=closed        (previous tick, 18:49)
planner_at=planner kev_window=unknown       (this tick, ~19:05)
```

The token that CHANGED is the instrument going dark again. Not a card state, not a subject transition.

## What is measured

**1. The card is unreadable — correctly REFUSED, not guessed.**
- `nvidia-smi --query-gpu=...` -> `No devices were found`, exit **6**; `nvidia-smi -L` -> `No devices found.`
- Driver is loaded and the card is claimed: `/proc/driver/nvidia/gpus/0000:2b:00.0/information` exists (Model RTX 3060 Ti, GPU UUID `GPU-976e618c-...`, `GPU Firmware: N/A`), `/dev/nvidia0` and `/dev/nvidiactl` exist, module `595.99.02` = userspace `595.99.02`.
- Kernel: `NVRM: GPU 0000:2b:00.0: RmInitAdapter failed! (0x62:0x40:2830)` once at 18:52:31, then `(0x62:0x65:2830)` every ~2 s continuously; **190** `RmInitAdapter` lines in boot 0, still arriving at 19:05:06. `nvidia_drm: Failed to allocate NvKmsKapiDevice`.
- So: **driver loaded + card claimed + no devices** — the contradictory pairing again, this time on the PROPRIETARY module, i.e. with no `-open`/GSP-module requirement to explain it.
- The prior boot's fault class is NOT running now: `gpuHandleSanityCheckRegReadError_GM107` count in the last 60 s = **0**; current kernel rate ~18 lines / 30 s against boot -2's 1,513,812-line flood. The failure changed class between boots (flood -> ~2 s adapter-init retry loop).

**2. The reboot was a maintenance action by an authorized agent, not a crash.**
From `/var/log/auth.log` (not from the journal, which is the store under attack):
- `18:51:42 pkexec[17322]: chilly1: Executing command [USER=root] [CWD=/home/chilly1/.hermes/workspace] [COMMAND=/bin/bash /tmp/exp1_stage.sh]`
- `18:52:00 pkexec[24114]: chilly1: Executing command [USER=root] [COMMAND=/usr/bin/systemctl reboot]`
- Reset reason recorded at boot 0: `Previous system reset reason [0x00080800]: software wrote 0x6 to reset control register 0xCF9` (warm reset).
- Supporting artifacts, all on disk: `/etc/modprobe.d/` mtime 18:51 and `/boot/initrd.img-7.0.0-38-generic` rebuilt 18:51; Llama's `~/.hermes/profiles/llama/diagnostics/exp1_stage.log` shows the stage script moving `/etc/modprobe.d/nvidia-no-gsp.conf` -> `/root/nvidia-no-gsp.conf.disabled`, removing the journald spam cap (`SystemMaxUse=8G`), arming `gsp-capture.service`, `update-initramfs -u`, `=== EXP-1 STAGED ===`.

**3. The two boots differ in the GSP option, and their outcomes are opposite.**
- Boot **-1**, 18:38:00, 6/low-noise kernel lines, **GSP DISABLED** (`nvidia-no-gsp.conf` present, `options nvidia NVreg_EnableGpuFirmware=0`), card's own capture `workspace/gsp-evidence/WORKAROUND-595-noGSP-PASS.txt`: `NVIDIA-SMI 595.99.02`, `9MiB / 8192MiB`, `renderD128` present, bad-register spam count **0**. Verdict key in the file: *CARD CAME UP -> GSP path is the fault (routable)*.
- Boot **0**, 18:52:29, **GSP ENABLED** (the option file moved to `/root/`), Llama's own capture `workspace/gsp-evidence/EXP-1-1852.txt`: header *proprietary 595, GSP ENABLED*; `No devices were found`; DRM only `simple-framebuffer`.
- **Caveat, stated rather than smoothed over:** the two boots differ in TWO variables — the GSP option (deliberately staged) and the reset type (0xCF9 software reset vs. the earlier boot; and boot -1's own restart was preceded by an ordered shutdown). A one-variable attribution to the GSP path is therefore *strong but not exclusive*. The single-variable test is also the fix candidate: restore the no-gsp option file, `update-initramfs -u`, reboot.
- Consequence to state plainly: **the box is currently running the configuration whose counterpart is the measured-good one, and the measured-good configuration exists on disk as a disabled file** (`/root/nvidia-no-gsp.conf.disabled`, per Llama's stage log; not readable by me).

**4. `planner_at=planner` is file-existence over a FAILED-ACQUIRE LOOP, not a holder.**
`scopes/planner/record.json` read at ~19:02: `owner=llama-swap-ocho-planner-4b scope=planner need_mib=3800 pid=12818 acquired_at=19:00:37`. Read again ~19:05: **different record** — `pid=14760 acquired_at=19:03:54`, and `kill -0 14760` / `/proc/14760` = **DEAD** seconds after it was written. A 60 s sample (six reads at 12 s) shows the record then quiescent at 19:03:54 with the same dead pid. Between the two writes: `ocho-planner-polymarket.service` ran 19:00:05 -> exited `status=1/FAILURE` at 19:00:47 (timer `*:0/10`, `Persistent=true`). No planner `llama-server` is resident (`ps` shows only the Hermes managed runtime :18434, llama-swap :8080, vision LFM2.5-VL with `-n-gpu-layers 0`).
So the pair required to certify a scoped flip is absent on both halves: **no live holder, no resident compute app.** The new fact is the mechanism of the *appearance*: the record is being **rewritten by successive failed acquires**, so the artifact's freshness is manufactured by the failure path.

## Rulings

**R1 — A record whose mtime advances with a fresh DEAD pid is a retry loop, not a holder.** The scoped-lease record is written by `take_lease` before the wrapped command runs (`pid=$$`) and removed only by the wrapper's EXIT trap, so a wrapper that fails immediately leaves a *brand-new* record with a *dead* pid. Two such writes ~3 min apart under a service that exits 1 is the signature. **Corollary (the inversion):** "the record is fresh" is not evidence of a live acquirer — under a failing load it is evidence of a *repeatedly failing* one. Grade an artifact by the mechanism that writes it, not by its timestamp.

**R2 — When a metric goes unreadable, look for an authorized actor's maintenance before hypothesizing a new fault.** This tick's `unknown` is not a card state; it is the metric correctly refusing during a repair. The actor was named by a *different* log (`auth.log` pkexec: the exact command, the CWD, the reboot) — the journal could not name it, and would not have been readable in the middle of the class of fault that motivated the repair.

**R3 — Cross-boot comparisons must declare every variable they moved.** Boot -1 (GSP off) came up; boot 0 (GSP on) did not, but the reset type also changed. The comparative claim is real (same module version, same kernel, same box, opposite outcomes) and it still does not license "the GSP path is *the* fault" as exclusive; the exclusive test is a one-variable re-run, which is also the remedy.

**R4 — A window metric whose subject the owner's own agent can take down must be expected to change CLASS, not value, during the repair.** `kev_window` went `closed -> unknown` twice today for unrelated causes (NVML mismatch at 17:55; RmInitAdapter/GSP at 18:52) and the prior tick's `closed` was itself a *recovery* reading. A window log that only records open/closed cannot be told from a broken probe; record the readability of the instrument as its own third value (already the 18:06 fix) and record WHO caused the unreadability.

## Actions taken / not taken

- **No run action. No model load. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, and the driver stack untouched** (no write, no `apt`, no `pkexec` from this watcher).
- **No `@ocho` message.** `planner_at` did not change this tick; the prescribed claim ("scoped-planner flip confirmed live end-to-end") would have been **FALSE** against this tick's reads (dead holder, no resident app), and the item's premise is separately false (his open item was closed on the live channel at 17:25:42 / 17:28:53; no delivery for it remains in `runtime/bot_live_delivery/`, and the delivery pid 103680 is gone). Stand-down recorded with the pointer so silence cannot read as omission.
- **No `@llama` fallback ping.** There is no window to report: free VRAM is unmeasurable at any value while the card will not initialize, and Llama is self-authorized on his own continuous poll. Llama is also demonstrably mid-work on this exact fault (he staged EXP-1 at 18:51:42 and captured his own evidence at 18:53/18:54).
- **Flagged to the operator in the tick report:** the machine is currently booted into the EXP-1 configuration that fails (GSP enabled), 6 boots today (-5 14:55:03, -4 18:12:06, -3 18:18:31, -2 18:26:39, -1 18:38:00, 0 18:52:29), the known-good option file is parked at `/root/nvidia-no-gsp.conf.disabled`, and `ocho-planner-polymarket.service` is failing in a fast loop against a card that cannot initialize.
