# A device wedge survives a reboot: diagnose it, then POWER-CYCLE rather than reset

## Telling a device hang from a memory event

Both leave the same hole: **no OOM record, no kernel trace, the journal simply stops.** An absence that fits
two explanations does not choose between them, so gather positive evidence rather than inferring a cause
from a gap. "No OOM record, so it must have been pressure" is a conclusion wearing the clothes of a
reading — and it is the easier error to make, because a missing record looks like an empty room.

## The signature of a wedged GPU

```
nvidia-smi                     -> "No devices were found"
lspci -nn | grep -i nvidia     -> the card IS still there (e.g. 2b:00.0 VGA ... GA104)
```

That pairing — **device gone to the driver, present on the bus** — is the tell. In the kernel log:

```
NVRM: RmInitAdapter failed! (0x62:0x65:2028)
NVRM: RmInitAdapter: Cannot initialize GSP firmware RM
NVRM: GSP failed to halt with GFW_BOOT
NVRM: gpuHandleSanityCheckRegReadError...: Possible bad register read: regvalue: 0xbadf....
```

`0xbadf...` is NVIDIA's deliberately-invalid sentinel — the device is not answering register reads. And the
sanity check **loops**: one observed boot logged >6.3 million bad-register lines in six minutes.

```
journalctl -k -b 0 --no-pager | grep -cE 'NVRM|GSP|RmInitAdapter'
journalctl -k -b 0 --no-pager | grep -vE 'bad register read' | tail -20
```

## The fix is a POWER CYCLE, not a reboot

**A warm reboot does not reset device firmware.** The PCIe slot stays energised across a reset, so a hung
GSP survives it — observed: two hard reboots failed and one full power cycle fixed it, and the second boot
went bad again ~5 minutes after coming up because the firmware had never been reset.

1. Shut the machine down completely.
2. **Switch off at the PSU, or pull the mains — and hold ~30 s.**
3. Power on.

Then verify with `nvidia-smi` **and a real workload**: a `llama-server` taking VRAM is far stronger evidence
than enumeration. A cheaper attempt exists if the modules can be unloaded and the bus rescanned
(`rmmod` the nvidia modules, or write `1` to `/sys/bus/pci/rescan`) — but that needs root and block­ing
processes must release the module first, and it does not reset firmware the way dropping power does.

## When GSP is what failed: the workaround, and telling it from a dead card

`RmInitAdapter failed!` arrives in **two stages, and the stage names the fault:**

```
0x62:0x40:<n>   the BOOTER stage  -- the falcon will not start the firmware, so there is no RM
0x62:0x65:<n>   the GSP HALT stage -- the falcon will not stop for the driver
```

When the log adds `gpuWaitForGfwBootComplete_TU102: GSP failed to halt with GFW_BOOT: (progress 0xff)` and
`kflcnWaitForHalt_TU102: Timeout waiting for Falcon to halt`, read it as **the GSP co-processor is not
answering the driver** — not as "the firmware was rejected". The distinction decides what you test next, and
it is also why the failure is not a bad download: the blob can be present, correctly packaged and a
genuinely new build while the engine that loads it is unresponsive.

**The workaround, when GSP is what fails:**

```
/etc/modprobe.d/nvidia-no-gsp.conf      options nvidia NVreg_EnableGpuFirmware=0
update-initramfs -u && reboot
```

- **`EnableGpuFirmware` has a NON-ZERO default.** `/proc/driver/nvidia/params` reports
  `EnableGpuFirmware: 18` when the parameter is unset, so `=1` is *not* "the default" and the switch is an
  **override, not a boolean**. Read the param back rather than assuming what an unset value means.
- **The GSP state has two readable fields**, and report both:
  `nvidia-smi -q | grep -i 'GSP Firmware'` (`N/A` when disabled, a version when up) and `GPU Firmware:` in
  `/proc/driver/nvidia/gpus/<bdf>/information`.
- **Smoke, not feature.** Disabling GSP costs the GPU-side offload; it does not cost CUDA. Prove that
  before calling the box recovered (next section) — a workaround that quietly breaks the workload is not a
  workaround.

**Discriminating "the driver's GSP path is broken" from "the card's GSP subsystem is degraded"** — one
variable per run, the interpretation fixed in advance, every step reversible:

```
EXP-A  the OTHER module variant, GSP enabled     pass -> that variant was the fault        
EXP-B  the PREVIOUS driver version, GSP enabled  pass -> the new driver's GSP path is the fault
                                                 fail -> the CARD's GSP subsystem is the fault:
                                                         the no-GSP config is the permanent cure,
                                                         and the card is partially degraded
```

- **Restore the known-good state BEFORE the next experiment.** A machine left broken for the sake of a
  second data point converts one failure into two, and the pending result is not worth the operator's
  desktop. Recovery first, experiment second — say so in the hand-off.
- **A version bump can be the regression, and that is the direction nobody checks.** A forward-fix upgrade
  moved a box from GSP-ON to GSP-OFF and bought nothing nameable in between. **State the before/after
  configuration explicitly** — "it works now, with a workaround" hides that the start of the day was better.
- **The flood is variant-specific, so a quiet log is not a clean one.** The same failure under one module
  variant emitted ~1.5M bad-register lines; under the other it emitted none. Absence of the flood is
  evidence about the MODULE, not about the card.
- **Both module variants failing identically is a real result.** It retires the variant hypothesis and
  points at the version or the silicon — which is the opposite of the reassurance a single failing run
  suggests.

## Prove the FUNCTION, not the symptom, before calling it recovered

"Graphics are back" and "`nvidia-smi` enumerates the card" are both **presence** checks. The card's job here
is compute, so call CUDA directly:

```python
import ctypes
cuda = ctypes.CDLL("libcuda.so.1")
cuda.cuInit(0)                                   # 0 = success
n = ctypes.c_int();    cuda.cuDeviceGetCount(ctypes.byref(n))
d = ctypes.c_int();    cuda.cuDeviceGet(ctypes.byref(d), 0)
name = ctypes.create_string_buffer(128); cuda.cuDeviceGetName(name, 128, d)
print(n.value, name.value.decode())              # e.g. "1 NVIDIA GeForce RTX 3060 Ti"
```

Three zero returns plus the device name is a **functional** result; `nvidia-smi` answering is not, and
graphics on screen is not. Run this before declaring any driver state usable.

## Capture the evidence BEFORE the flood evicts it

A failing device can fill the kernel log at thousands of lines per second, and journald will **evict the
very record that identifies the fault** — while also consuming gigabytes of RAM to index it (observed:
~4 GB and still climbing). **So size the budget BEFORE the failing action, not after it is visible:**

1. **Raise the cap first** (`/etc/systemd/journald.conf.d/99-keep.conf` -> `SystemMaxUse=8G`, restart
   journald) — otherwise the flood outruns the ring buffer in seconds. Measured: ~102,000 lines/second
   evicted an entire boot's evidence, and **two boots later held ZERO NVRM lines** — the record of the
   original failure was eaten by the failure itself.
2. **Take the capture as the FIRST command after the machine comes back**, before anything else you intend
   to do. Copy the non-flood lines plus the first and last flood entries, the count, and the distinct bad
   values into a file in the workspace.
3. **Capture with `journalctl`, never `dmesg`.** `journalctl -k -b 0` works unprivileged; a `dmesg` read
   can come back **zero bytes** on a kernel with `dmesg_restrict`, and an empty capture reads exactly like
   "no fault here".

```
journalctl -k -b 0 --no-pager | grep -cE 'NVRM|GSP|RmInitAdapter'      # count first
journalctl -k -b 0 --no-pager | grep -v 'bad register read' > <file>    # then the signal
```

Evidence you have to retrieve from a log that is actively deleting itself is evidence you will not have.

## Boot indices move

`journalctl -b -1` is **not** "the previous boot" in any stable sense — indices shift as boots accumulate,
so ten minutes later the same index can be a different boot, and a grep of it returns a clean empty that
reads as "no fault here." Enumerate with `journalctl --list-boots` and select by **timestamp**.

## Cold-starting a heavy workload after a wedge

- **The box wins over the run.** An OOM-killer exemption on a heavy unit
  (`ManagedOOMPreference=omit|avoid`) protects the measurement at the cost of the machine: where oomd could
  previously kill the unit and the box survived, an exempted unit cannot be killed and the box needs a hard
  reset. On a machine with a live desktop, oomd MUST be able to kill the heavy unit.
- **Bound swap, not just memory.** A `MemoryMax` ceiling never bound in the observed incident (peak 10.8 G
  against a 45–50 G cap) because RAM plus swap let the kernel thrash *below* the limit before oomd acted.
  `MemorySwapMax=` shortens that runway.
- **A gate that can never open is a bug wearing safety's clothes.** A preflight requiring `load1 < 1.5` on a
  box that runs three model servers waits forever. Measure the threshold against the machine that will run
  it, and **record the reason the old value was wrong beside the new one** — otherwise lowering it silently
  removes a protection that was correct in intent.
- **Record a load correlation as a correlation.** If heavy runs preceded failures, write that down *before*
  the next occurrence and let it settle the question; a correlation promoted to a cause becomes a fact
  nobody re-checks.

## The second fault is a KERNEL one — different signature, different guard

**Two freezes with different signatures are TWO faults, not one recurring fault.** A device wedge repeats the
same lines; a memory fault looks like nothing you saw before. Do not fold the second into the first because
the first is familiar and has a fix:

```
device wedge     NVRM / GSP / RmInitAdapter, bad register reads, `nvidia-smi` empty while `lspci` sees it
kernel memory    faults inside allocators (`__kmalloc`), a garbage or NON-CANONICAL RIP, module load aborts,
                 and stack dumps that DIFFER between occurrences
```

**A non-canonical address in a fault is a memory-corruption signature, not a driver one.** Read the trace for
address shape and allocator frames before attributing it to the device that also happens to be present. One
is fixed by dropping power; the other by finding what is writing over memory.

**Make each fault SURVIVE ITSELF, since both arrive as a hang.** A hang costs a human at the power switch and
loses the journal. Both are converted into a self-recovering event by:

```
/etc/sysctl.d/99-panic.conf
    kernel.panic_on_oops = 1     an OOPS (not only a panic) triggers the panic path
    kernel.panic = 20            ...then reboots in 20s instead of sitting there
```

**An oops that reboots flushes the journal on the way down** — so this guard is not only downtime avoidance,
it is the thing that makes the NEXT occurrence diagnosable after the fact. Verify it by reading the two keys
back (`sysctl kernel.panic_on_oops kernel.panic`), not by the write landing.

**Both guards are invisible until they fire, and their unfired state looks like nothing was configured.** A
`MemoryMax` that never bound and a `panic_on_oops` that never tripped both read as absent. Verify them by
reading the property **while the unit is ACTIVE** — an exited transient unit reports its defaults
(`MemoryMax=infinity`), which reads exactly like *your configuration was rejected*. **A reading with no time
attached is indistinguishable from a live one.**

## Reaching root without a passwordless sudo

Where a root-level change is needed and the account has no passwordless `sudo` (no TTY, or a policy blocking
it), **`pkexec` performs the same single command through the desktop's own authentication agent**: write the
file to a scratch path as the user, then install it, then read it back as the user.

```
pkexec install -m 0644 -o root -g root <scratch> /etc/sysctl.d/99-panic.conf
cat /etc/sysctl.d/99-panic.conf            # verify as the user, not as the tool that wrote it
```

It prompts in the GUI session, so it needs a human at the machine — the right shape for a kernel-level
change, and better than leaving the guard unwritten.
