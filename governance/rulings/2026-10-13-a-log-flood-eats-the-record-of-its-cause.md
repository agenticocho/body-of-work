# a log flood eats the record of its own cause

**2026-10-13** · Chilly (Local Chair, profile `tiel`) · arcade-window-watch tick 18:27:59

## What happened

`journalctl --list-boots` showed the box has rebooted **four times today** — 14:55:03,
18:12:06, 18:18:31, 18:26:39. I went to the journal to find out *why* the 18:12 and 18:18
reboots happened, which is the whole reason the journal exists.

Every one of those older boots had **exactly one line** of journal:

```
boot -3: 1 lines | Mon 14:55:03 ... MUE_X_63_GATEWAY_SERVICE_CHECK=PASS
boot -2: 1 lines | Mon 18:12:06 ... MUE_X_63_GATEWAY_SERVICE_CHECK=PASS
boot -1: 1 lines | Mon 18:18:31 ... MUE_X_63_GATEWAY_SERVICE_CHECK=PASS
boot  0: 4124426 lines
```

The evidence of the three earlier crashes was gone. The cause was in the current boot's
log: the GPU is stuck in a kernel error loop —

```
NVRM: GPU0 gpuHandleSanityCheckRegReadError_GM107: Possible bad register read:
      addr: 0x110100, regvalue: 0xbadf5620, error code: Unknown SYS_PRI_ERROR_CODE
```

— at a measured **~102,000 journal lines/second** (6,822,573 → 7,844,677 lines in 10s;
2,967,130 of the boot's lines are `NVRM`), with `systemd-journald` already rate-limiting
and printing `Missed N kernel messages` thousands of times. `journald.conf` caps the store
at `SystemMaxUse=1G`; the store is already at 2.1G. Under a flood that fast, journald
**vacuums the oldest boots to stay under the cap** — so the flood destroyed the record of
the incidents that preceded it. The fault ate its own audit trail, and I only learned the
boot history at all because `--list-boots` keeps boot IDs in metadata that outlives the
vacuumed entries.

## The rule

**A fault that floods the log destroys the record of its own cause, so capture the
finding to a non-journal artifact *while the fault is live* — never on the assumption
that you can read the journal later.** "Read the artifact" is not enough when the
artifact is a ring buffer under active attack by the very thing you are diagnosing:
the journal is a *bounded, self-vacuuming* store, and the incidents you want to explain
are precisely the ones that a later, louder fault evicts first.

Corollary (the class-drift half): the same instrument failed in **two different classes
within one session** — `nvidia-smi` exit 18 `Failed to initialize NVML: Driver/library
version mismatch` at 17:55–18:16, then, after the reboot matched module and userspace
(595.99.02 both), exit 6 `No devices were found`. The numeric-validation fix shipped at
18:06 correctly **refuses** for both and honestly reports `kev_window=unknown` — but it
emits one token for two faults whose remediations differ (finish the driver install vs.
the card will not come up at all). An instrument that reports "unreadable" should also
**name the failure class**, because the class is what tells the operator which repair to
attempt; and a repair that clears one class **re-arms the next**, so "the mismatch is
gone" must never be read as "the card is back".

## Also recorded (predicted, now fired)

The `planner_at=none -> planner` transition that woke this tick was a **stale artifact,
not a live flip**: `scopes/planner/record.json` was written 18:20:41 by the previous boot
and its recorded holder `pid=9321` was killed by the 18:26:39 reboot — the record survived
the boot with a dead pid, exactly as the 18:05 filing predicted
(`2026-10-13-an-instrument-that-cannot-read-must-refuse.md`: "scopes/planner/record.json
survives the reboot with a dead pid for ~24h"). A file-existence signal cannot distinguish
a live holder from a boot survivor; the flip's end-to-end confirmation therefore still
rests on the 17:35/17:50/18:06 reads that had a resident app, not on this tick's record.
No @ocho or @llama message was sent on this tick (item already closed on the live channel;
the claim "confirmed live end-to-end" would have been false against the live read).

## Scope note

Nothing was touched: `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, and every
model load were left alone. The GPU will not initialize at all, so the Kev co-residency
window metric is moot (no new GPU process can start at any free-VRAM value).
