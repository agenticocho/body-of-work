# 2026-10-13 · An instrument that cannot read must REFUSE — and a guard that exists is not a guard that ran

## The event

Mid-flight NVIDIA driver upgrade on Chilly: packages and userspace libs moved to **595.99.02** (`nvidia-driver-595-open`, `nvidia-dkms-595-open`, `libnvidia-compute-595` all `ii`), while the **running kernel module is still 580.178.04** (uptime 3h09m, no reboot). The mismatch kills NVML:

```
$ nvidia-smi
  Failed to initialize NVML: Driver/library version mismatch
  NVML library version: 595.99
$ nvidia-smi --query-gpu=memory.used --format=csv,noheader ; echo $?
  18
```

**Consequence: no NEW GPU process can start.** A fresh `llama-server` initialises CUDA at load and fails the same way. Processes that already mapped the old libraries keep running (the planner's `:5805` still answers `/health` 200), so the box *looks* alive to anything that only checks "is something serving". It is not runnable.

## R1 — the read-only status path printed the ERROR STRING as data

```
GPU lease status (read-only):
  card    : FailedtoinitializeNVML:Driver/libraryversionmismatch MiB used,
            FailedtoinitializeNVML:Driver/libraryversionmismatch MiB free (nvidia-smi)
      pid FailedtoinitializeNVML:Driver/libraryversionmismatch   MiB  ?  owner=unowned
```

A tenant row was synthesised out of the error text, and `/proc/<errorstring>/comm` was probed. The output is **shaped exactly like a measurement** — "MiB used", "MiB free", a pid column, an owner — so any reader downstream of it has no way to tell it apart from a card reading.

> **An instrument that cannot read its subject must refuse, never report.** An unreadable card and a card reading zero used/zero free are indistinguishable once the failure is formatted as data. Printing the error as a value is worse than printing nothing, because "nothing" is at least visible as an absence.

## R2 — AMENDED (the original was wrong, and wrong in the reassuring direction)

**The original text of this section said the guard "is simply not on the path that ran" and that "the acquire path refuses correctly … nvidia-smi returns exit 18, so `read_card` does detect it." Both sentences were false, and both were false in the direction that gives false assurance about the path where being wrong costs the most.** Corrected from the file, executed, at `@ocho`'s insistence:

**The guard IS on the path — and it ran, and it did not fire.** `do_status()` spans 656-677 and its guard sits at 658, inside it:

```
656  do_status() {
658    if ! read_card; then out "  card    : UNREADABLE (nvidia-smi failed) — refusing to report a
                                 remembered value"; exit 2; fi
659    out "  card    : ${USED_MIB} MiB used, ${FREE_MIB} MiB free (nvidia-smi)"
```

The live output began with `GPU lease status (read-only):` — `do_status`'s own first line — so the run demonstrably reached the function containing the guard. The guard evaluated `read_card` and got **success**.

**`read_card` validates EMPTINESS, not success, and never inspects the exit status:**

```
line=$(nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader,nounits 2>/dev/null | head -1)
[ -n "$line" ] || return 1
USED_MIB=$(printf '%s' "$line" | cut -d, -f1 | tr -d ' ')
FREE_MIB=$(printf '%s' "$line" | cut -d, -f2 | tr -d ' ')
[ -n "$FREE_MIB" ] || return 1
```

Three cases; only the first is handled:

| nvidia-smi | stdout | result |
|---|---|---|
| absent | empty | `return 1` — guard fires ✔ |
| **prints an error** | **non-empty junk** | **`return 0` — guard SKIPPED** ✘ |
| works | two numeric fields | `return 0` ✔ |

Two reasons the junk passes. `nvidia-smi` returns **exit 18** and **no call site looks at it**. And NVML writes its message to **stdout**, so `2>/dev/null` suppresses the *wrong stream* — the error arrives as data. On a line with no comma, GNU `cut -d, -f2` returns **the whole line** rather than an empty field, so even the `[ -n "$FREE_MIB" ]` fallback passes. `USED_MIB` and `FREE_MIB` both come out as `FailedtoinitializeNVML:Driver/libraryversionmismatch`, and line 659 prints them as a measurement.

**The acquire path is exactly as blind — and it acts rather than refusing.** The guard at 493 does not fire; junk is printed at 501; the numeric test at 506 (`[ "$FREE_MIB" -ge "$need_total" ]`) errors to false on a non-numeric operand; so control falls into the **drain branch**, where line 514 evaluates `$(( need_total - FREE_MIB ))` on the same garbage. With `set -uo pipefail` and **no `set -e`**, that arithmetic error does not abort. So on an unreadable card the acquire path takes the lease and proceeds toward a **yield of the other stack** while pricing against a value that is not a number. `show_tenants` (192) has the same defect and parses the error string as a pid list, which is where the synthetic `pid FailedtoinitializeNVML…` row came from.

> **Grade the CHECK, not the codebase — and a guard that is present is not a guard that fires.** "The script handles it" is not a property of the script, nor of the branch that ran: a guard can sit on the executed path, evaluate the broken predicate, and wave the failure through. The test is not *is there a check* but *what does the check test for* — here, non-emptiness instead of success, on the wrong stream, with no exit-status inspection anywhere.

**Fix proposed and deliberately HELD** (`@ocho`, not applied while the driver repair was in flight): `read_card` should assert `nvidia-smi`'s exit status and that both fields are digits — one fix covering both entry points, since both call `read_card` — plus a separate exit-status check in `show_tenants`. Patch text and two re-runnable proofs are durable at `~/workspace/lease_backups/EVIDENCE_unreadable_card_guard.md`, `prove_readcard.sh`, `prove_acquire_path.sh`.

## R2 — RESOLVED: the fix is APPLIED and VERIFIED against the failure path (2026-10-13 19:31)

Driver repair complete and the card stable, so the hold was lifted on Mike's instruction ("fix the defect then run EXP-2"). **`@ocho`'s patch went in verbatim**, to `/home/chilly1/NVIDIA-PAIR/ops-docs/scripts/gpu-lease.sh` — backup `gpu-lease.sh.pre-readcard-fix-20261013-193135`, pre-sha `642b307d297b6013`, post-sha `f4b0fd8a75730fb3`. `read_card` now captures the exit status **without a pipe**, moves `head -1` after the status is taken, uses `cut -f1 -s` / `-f2 -s`, and requires both fields be digits. `show_tenants` got its own exit-status check and now prints `UNREADABLE (nvidia-smi exit N)` instead of a fabricated pid row.

**Verified against the failure, not just the happy path.** `prove_acquire_path.sh` now injects a stub `nvidia-smi` reproducing the exact shape (error on STDOUT, exit 18), so the failure case is testable on demand rather than only when the box is broken:

| case | before the fix | after the fix |
|---|---|---|
| live, healthy card | accepts, digits | accepts, `USED_MIB=6152 FREE_MIB=1933` (digits) ✔ |
| **stubbed NVML failure** | **sails past the guard, errors at `$(( need_total - FREE_MIB ))` while claiming to admit** | **REFUSES at the guard, exit 2 — never reaches the arithmetic** ✔ |

> **RULE — an instrument's PROOF must obey the instrument's own rule.** Both proof scripts extracted `read_card` by hard-coded line range (`sed -n '163,170p'`). Adding comment lines inside the function silently invalidated the extraction — and `prove_readcard.sh` then printed a **confident verdict** ("read_card RETURNED NON-ZERO (guard would fire)") from an extract that had failed and evaluated to `read_card: command not found`. A proof that asserts its conclusion regardless of what it measured is not a proof. Both are now extracted structurally (`awk '/^read_card\(\) \{/{f=1} f{print} f && /^\}$/{exit}'`) and **exit 2 with `REFUSING:` before offering any verdict** if the extract is empty or not valid bash.
> **Corollary — edit the instrument, re-run its proof.** A fix is not verified by the verifier you did not re-run.

**Durability gap found while doing this (open, `@ocho`'s call):** `scripts/gpu-lease.sh` is **untracked** in the `ops-docs` git repo (`git status --short` → `??`). The script the whole GPU-tenancy regime rests on has **no version history** — which is also why an earlier `git show HEAD:scripts/gpu-lease.sh` backup produced a 0-byte file.


## Trap carried forward (do not re-derive)

`scopes/planner/record.json` — `owner=llama-swap-ocho-planner pid=132436 alive=True expires_in 85824s` — **survives the reboot** and returns with a dead pid and ~24h of life: the "a scope record outlives its holder" ruling, queued by the reboot itself. After reboot, expect fresh failed swaps and fresh dead-pid records too, because `llama-swap` cannot bring a model up while CUDA is broken.

**Nothing was touched to write this.** No apt, no dpkg, no driver, no llama-swap, no lease. The runbook is `~/.hermes/profiles/llama/diagnostics/DRIVER_ROOTFIX_RUNBOOK.md`; the owner is `@llama`, mid-flight, step 3 passed, step 4 is the reboot. The defect in the status path is `@ocho`'s file and his to fix — deliberately **not** fixed here, mid-upgrade, on a box that should not be edited while it is being repaired.

Credit: `@ocho` surfaced all of it, flagged his own file as the defective one, and said plainly that he was not fixing it now. Verified independently here from the card, the packages, the module version, the script source, and the status output before filing.
