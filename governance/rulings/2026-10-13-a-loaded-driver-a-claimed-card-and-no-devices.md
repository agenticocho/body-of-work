# 2026-10-13 · A loaded driver, a claimed card, and "No devices were found" — the `-open` module's GSP trap

## Event

Chilly's GPU stopped initialising after a driver upgrade (580.178.04 → 595.99.02). The upgrade **succeeded**; the card does not come up. The visible symptom was "graphics are not what they should be", because GNOME fell back to software rendering off `simple-framebuffer`.

## The escalation ladder, and what each remedy actually did

| remedy | result |
|---|---|
| warm reboot | `RmInitAdapter failed (0x62:0x40)` · `Booter failed with non-zero error code: 0xb` |
| **full power cycle** | **identical** — the wedge is not volatile state |
| **PCI function-level reset** (`echo 1 > .../reset`) | device re-probed cleanly, then failed **deeper**: `kflcnWaitForHalt_TU102: Timeout waiting for Falcon to halt` · `GSP failed to halt with GFW_BOOT: (progress 0xff)` · `RmInitAdapter failed (0x62:0x65)` |

Escalation is informative *because* it narrows: warm reboot rules out transient driver state, a cold boot rules out volatile GPU state, and a bus reset rules out a stuck PCI function. What survives all three is the engine itself.

## R1 — the structural fact that decides the test

**The `-open` kernel module REQUIRES GSP. There is no legacy fallback.** So a failure inside the GSP/Falcon engine is fatal for it — which is why the diagnosis *looks* contradictory: the driver loads cleanly, DKMS is built, `/proc/driver/nvidia/gpus/<bdf>` exists, `lspci -k` says `Kernel driver in use: nvidia` — **and `nvidia-smi` says "No devices were found."** A claimed card that cannot be enumerated is the open module's GSP signature, not a missing-device problem.

> **Read the pairing, not the symptom.** "Driver loaded + card claimed + no devices" is one specific failure mode, and naming it reroutes the whole investigation away from drivers-and-packages toward the GSP engine.

The test that can distinguish them: **the proprietary module with `NVreg_EnableGpuFirmware=0`**, which uses the legacy RM path and never touches Falcon/GSP. A rollback to 580 is a *weaker* test for this reason — 580 is also an `-open` module and therefore also needs GSP.

## R2 — agree the interpretation BEFORE running the decisive test

Written down in advance, so the result cannot be read two ways afterwards:

- **card comes up** → the GPU is fine and the GSP path is at fault: a driver/firmware issue to route around.
- **still fails** → the card is the answer, and no driver will change it.

> **A decisive test is only decisive if its branches were fixed beforehand.** Otherwise the same output gets read as support for whichever answer was wanted.

## R3 — a failure that predates a change is a candidate FIRST SYMPTOM, not a separate event

The driver upgrade was undertaken to fix "a GPU-process crash in the desktop." That crash **predates** the upgrade, and the upgrade completed cleanly. The booter failure, the engine refusing to halt, and their survival of a cold boot and a bus reset are all consistent with the card being the fault — with the earlier crash as its first appearance rather than a coincidence.

> **When a change is made to fix something, check whether the thing being fixed is already the symptom of a larger fault.** Otherwise the change takes the blame for a failure it did not cause, and the real fault keeps its head down.

## Ruled out by measurement (do not re-spend)

GSP firmware present and version-matched (`gsp_ga10x.bin`, 72 MB; `nvidia-firmware-595-595.99.02` installed); no firmware load errors; packages and DKMS for 595.99.02 complete across four kernels; device bound to `nvidia`. The `module verification failed: signature … missing - tainting kernel` line is normal for an out-of-tree module and is not the cause.

## Carried forward

**Journal risk:** 5,457,710 lines of `bad register read` spam in one boot, recurring on every failed init — on the order of half a gigabyte per boot. Cap the journal before it fills the disk.

**Ownership:** the driver operation is `@llama`'s, on Mike's authorisation. No privileged command was run by the Chair and no driver, module, or config was changed in the course of this diagnosis. `D1-D4` remain frozen while `nvidia-smi` cannot enumerate a device — and no card state may be quoted from any reading taken before the card returns.

## RESOLVED — and the fix identifies the fault, and corrects this ruling's own conclusion

`@llama` ran the proprietary/no-GSP test and the card came up on the first reboot:

```
NVRM version: NVIDIA UNIX x86_64 Kernel Module  595.99.02     <- "x86_64", NOT "Open"
nvidia-smi:   NVIDIA GeForce RTX 3060 Ti, 595.99.02, 8192 MiB, 397 MiB used, 7688 MiB free
DRM:          card1 + renderD128 + DP-1/DP-2/DP-3/HDMI-A-1        (was: card0 = simple-framebuffer)
packages:     nvidia-driver-595 / nvidia-dkms-595 / nvidia-kernel-source-595 / nvidia-kernel-common-595
              (the -open variants are gone)
modprobe:     /etc/modprobe.d/nvidia-no-gsp.conf : options nvidia NVreg_EnableGpuFirmware=0
```

**Root cause: the GSP firmware path — not the hardware.** With GSP enabled (the only possibility for the `-open` module, and the default for the proprietary one) the card's GSP/Falcon engine would not boot: `Booter failed 0xb`, then `GSP failed to halt (progress 0xff)`. With `NVreg_EnableGpuFirmware=0` the legacy RM path brings the same card up cleanly, on the same driver version.

> **Correction to R3 of this ruling: I wrote that the odds favoured hardware. That was wrong.** The card is functional; a software path around the engine works, so the engine was stuck, not broken. The reasoning error was mine and it is the day's recurring shape — I inferred a hardware verdict from a *failure sequence* while the decisive test that could distinguish hardware from configuration had not yet been run. **The escalation ladder narrows the space; it does not name the cause. Only the discriminating test does that** — and it was available the whole time.

**This is a WORKAROUND, not a cure.** Consequences to carry: GSP is disabled, and the legacy RM path is deprecated upstream — NVIDIA has been consolidating on GSP, so a future driver may drop `NVreg_EnableGpuFirmware=0` and this card would stop coming up again. The underlying GSP boot failure itself is **undiagnosed**; the workaround steps around it rather than explaining it.

**Two things the incident predicted, now observed:**

- **The stale-record trap fired exactly as filed.** `scopes/planner/record.json` survived the reboots holding `pid: 11786` — **DEAD**. Benign, because the policy makes a dead-pid `mode=run` record reclaimable, but it is the "a scope record outlives its holder" ruling happening on schedule.
- **The instrument is honest again.** `gpu-lease.sh status` now reads `card : 331 MiB used, 7754 MiB free (nvidia-smi)` — a real measurement, no error string parsed as data. The `read_card` defect Ocho filed remains unfixed and still latent; it was masked by the card recovering, not repaired.

**Still outstanding from the cleanup hand-off** (the driver swap only): the `rc` 580 leftovers remain, `nvidia-settings` is still 615 against a 595 driver, and `cuda-nvcc-13-1` remains held.

## EXP-1 FAILED — the `-open` module is NOT the culprit (2026-10-13 18:52)

GSP was re-enabled on the **proprietary** module (`nvidia-no-gsp.conf` moved aside, reboot). It failed with the **same signature**:

```
NVRM: loading NVIDIA UNIX x86_64 Kernel Module  595.99.02      <- proprietary (license 'NVIDIA')
NVRM: GPU 0000:2b:00.0: RmInitAdapter failed! (0x62:0x40:2830)  <- booter stage
NVRM: GPU 0000:2b:00.0: RmInitAdapter failed! (0x62:0x65:2830)  <- GSP halt stage
[drm:nv_drm_dev_load] *ERROR* Failed to allocate NvKmsKapiDevice
nvidia-smi: No devices were found
```

> **Correcting this ruling's own root-cause line: the fault is the GSP 595.99.02 path in general, NOT the `-open` module's implementation of it.** The `-open`-specific hypothesis is now dead — both module variants fail identically at the same two stages.

**Two observations worth keeping:**
- `/proc/driver/nvidia/params` reports `EnableGpuFirmware: 18` when the parameter is **unset** — the driver's own default — against `0` when the workaround is in place. So the switch is a two-valued override of a non-zero default, not a boolean flag you set to 1.
- **This boot produced ZERO `bad register read` spam** (75 clean NVRM lines, no flood), where the `-open` boots produced 1.5M lines. The flood appears to be specific to the `-open` module's failure loop — which is why the evidence survives here at all.

**Remaining discriminator: EXP-2** — roll back to 580.178.04 with GSP enabled. PASS ⇒ the 595.99.02 GSP path is the defect (580 is the cure, and it still satisfies CUDA ≥ 580). FAIL ⇒ the card's GSP subsystem is the fault, the no-GSP workaround is the permanent cure, and the card is partially degraded. **The workaround is restored first; the experiment runs second.**

**Protocol that proved itself:** raise the journal cap before rebooting, then capture as the FIRST command after boot with `journalctl -k -b 0 --no-pager | grep -v 'bad register read' > …` — **use journalctl, not `dmesg`, which is restricted to root on this box** (a `dmesg` capture returned 0 bytes).

## RESOLVED — the cure was UPGRADING, not downgrading, and 595.99.02 was the one bad release (2026-10-13 19:52)

Two more experiments to completion. Both passed:

| exp | configuration | result |
|---|---|---|
| **EXP-2** | 580.178.04 (open) · GSP **enabled** | **PASS** — GSP up, `GSP Firmware Version 580.178.04`, CUDA 13.0 |
| **EXP-3** | **615.71.09** (open) · GSP **enabled** | **PASS** — GSP up, `GSP Firmware Version 615.71.09`, **CUDA UMD 13.4** |

**The box now runs 615.71.09 with GSP enabled, no workaround file, CUDA verified (`cuInit(0)=0`, 1 device), zero register-read spam.** That is strictly better than this morning's starting point (580.178.04, CUDA 13.0): **newer driver, newer CUDA, GSP working, and no `EnableGpuFirmware=0` override.**

> **THE FINDING: 595.99.02 was a bad release for this card, not the modern line and not the hardware.**
> We had tested exactly one 59x version and were about to conclude "modern drivers are broken on this card." **One sample is not a series** — the 615 branch immediately above it boots GSP cleanly on the same hardware, minutes later, same box, same session. The correct reading of EXP-1 + EXP-2 was never "GSP is broken" or "the card is broken" but "**this build** is broken", and only a second sample in the same series could tell those apart.

**Consequences for the earlier hypotheses:**
- **"The `-open` module's GSP path is at fault"** — dead (EXP-1: proprietary failed identically).
- **"The card's GSP subsystem is degraded"** — dead (EXP-3: the same card boots GSP on 615). My interim claim that *"the GSP engine is unresponsive to the driver"* was an **overstatement** and is recorded here as one.
- **"The open module cannot run GSP"** — moot: **615-open runs GSP.**
- **The stage-2 question** (does the open module honour `NVreg_EnableGpuFirmware=0`?) was never needed and remains **unmeasured** — do not assert either answer.

**Two failure modes, distinguishable, and this is the operational rule:**
| | driver defect (595) | GSP hang (`FINDINGS/011`, 2026-10-08) |
|---|---|---|
| warm reboots clear it | no | no |
| **full power cycle clears it** | **no** | **yes** |
| what clears it | a driver change | a power cycle |
> **If a power cycle does not clear it, it is not a hang — look at the driver.** `FINDINGS/011`'s rule ("go straight to a power cycle") is about the hang and is now scoped to it.

**And the caveat that survives every pass above:** `FINDINGS/011` documents this card's GSP hanging **on 580** mid-run, with the same `progress 0xff` text. Two clean boots on 615 are **not** a clearance for the card's GSP generally — the correlation with ~19 CUDA context create/teardown cycles per arena run stands as a hypothesis with n=2. Re-test each new branch; the capture protocol is now automated by Llama's `gsp-capture.service`.

**Rollback, should 615 regress:** exact recipe and package list at `~/workspace/gsp-evidence/ROLLBACK-TARGET-before-EXP3.txt` and Llama's staged debs in `~/workspace/gsp-evidence/rollback-debs/`.
