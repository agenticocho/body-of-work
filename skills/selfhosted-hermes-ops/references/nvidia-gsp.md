# NVIDIA GSP boot failure on Linux (driver loads, card does not)

Diagnostic and fix-class for a GPU that the driver **claims** but cannot initialize:
the module loads, `/proc/driver/nvidia/gpus/<bdf>` exists, `lspci -nnk` shows
`Kernel driver in use: nvidia`, and yet `nvidia-smi` says **"No devices were
found"** and the desktop falls back to `simple-framebuffer`.

## 1. Read the actual failure, not the symptom

The kernel log names the fault. Grep it for the GSP/Falcon/RmInitAdapter lines:

```bash
journalctl -k -b --no-pager | grep -iE 'NVRM|Booter|WPR2|GSP|GFW|Falcon|RmInitAdapter|nv_drm|KmsKapi'
```

Two distinct signatures, both fatal for the **open** module:

- **GSP never halts / never boots:**
  `kflcnWaitForHalt_TU102: Timeout waiting for Falcon to halt` →
  `gpuWaitForGfwBootComplete_TU102: GSP failed to halt with GFW_BOOT: (progress 0xff)` →
  `RmInitAdapter failed! (0x62:0x65)`.
- **Booter stage fails:** `RmInitAdapter failed! (0x62:0x40)`, sometimes with
  `unexpected WPR2 already up`.

Consequential, not causal: `[drm:nv_drm_dev_load] *ERROR* Failed to allocate
NvKmsKapiDevice`, no `/dev/dri/renderD*`, `GPU Firmware: N/A` and a
`??.??.??.??.??` VBIOS in `/proc/driver/nvidia/gpus/<bdf>/information`.

## 2. The structural fact that decides the whole approach

The **`-open` kernel module REQUIRES GSP and has no legacy fallback.** So a failure
inside the GSP engine is unrecoverable on `-open`: you get a loaded driver, a
claimed card, and "No devices were found" simultaneously. The **proprietary** module
can be pushed onto the legacy (non-GSP) RM path:

```bash
echo 'options nvidia NVreg_EnableGpuFirmware=0' | sudo tee /etc/modprobe.d/nvidia-no-gsp.conf
sudo update-initramfs -u && sudo reboot
```

`NVreg_EnableGpuFirmware` unset reports as `18` (the driver default, GSP on) in
`/proc/driver/nvidia/params`; the explicit `0` forces the legacy path. This is the
**workaround** (and, if the card's GSP is genuinely broken, the permanent cure).

## 3. Isolate driver defect from hardware — the one-variable experiments

Run these cheapest-first; each needs a reboot. **Fix the SET in advance** so the
result cannot be read two ways:

| Test | Change | PASS means | FAIL means |
|---|---|---|---|
| A | latest driver, GSP **on** | recent GSP path is healthy | go to B |
| B | older driver, GSP **on** | that driver's GSP path is the defect | card GSP subsystem is the fault |
| C | modern driver, GSP **off** | the no-GSP escape survives | card cannot run at all on this driver |

Key findings from one such hunt (xferable shape, not fixed versions): a specific
point release of one driver series failed GSP while an **older** series and a
**newer** series both booted GSP fine — so "update the driver" and "downgrade the
driver" are both hypotheses to test, not givens. And the no-GSP switch worked on
both the proprietary module and later open modules.

## 4. The no-GSP escape is only available if CUDA permits it

**DEADLY CONSTRAINT: the CUDA runtime floor can forbid the downgrade that fixes
GSP.** A llama.cpp build bundling CUDA 13.x (`libcudart.so.13`) **requires driver
>= 580** — so downgrading below 580 to dodge a GSP bug would silently break local
inference. Decide the target version against `ldd`/the bundled `.so` *before*
recommending a downgrade:

```bash
ls tools/llamacpp-cuda-*/libcudart.so.*      # which CUDA major the runtime needs
```

## 5. Capture the evidence, or the failure eats it

A failed GSP init can flood `dmesg`/journal at ~100k lines/sec and, under a modest
`SystemMaxUse`, journald vacuums the record away as it goes — **the earlier boots
literally lose their own evidence.** Before any reboot: raise the cap AND remove
rate limiting (`/etc/systemd/journald.conf.d/99-keep.conf`, `SystemMaxUse=8G`,
`RateLimitIntervalSec=0`), then capture as the FIRST command after boot with
`journalctl -k -b 0`, **not `dmesg`** (dmesg is root-restricted on some boxes and a
capture can come back 0 bytes).

## 6. Tooling notes

- **A corrupt package mirror breaks a driver swap mid-install.** `zstd error:
  Restored data doesn't match checksum` during unpack is a **bad download**, not a
  dependency problem — it leaves packages in `iU` (unpacked, unconfigured) and the
  GPU with no userspace libs. Re-download, **verify the SHA512 against the repo**,
  and re-run; `dpkg -i` the verified `.deb` then `apt-get -f install`.
- **`pkexec` is a root path that can go cold.** It may grant `uid=0` while polkit's
  auth is cached and then hang on a prompt that cannot be answered once that cache
  expires. Check `sudo -n -l` for the actual NOPASSWD surface (often `systemctl`
  alone) and use that where it fits; a GUI polkit prompt needs the operator at the
  console.
- **Pre-stage rollback `.deb`s on persistent disk** — `/tmp` is tmpfs and is wiped
  by the very reboot the experiment requires.
