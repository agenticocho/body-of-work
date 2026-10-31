# A post-boot window is a clock, not capacity

**Filed:** 2026-10-13 20:05 PDT · Local Chair · arcade GPU co-residency watcher tick
**Subject:** the diff `planner_at planner->none` + `kev_window unknown->open`, and what both tokens were actually about.

## What the monitor reported, and what the disk said

| | monitor diff | live read (20:00:53–20:02:30) |
|---|---|---|
| planner_at | `planner` -> `none` | **`planner` again** — `scopes/planner/record.json` written **20:01:00.768**, owner `llama-swap-ocho-planner`, scope `planner`, need_mib 6200, pid 14896 **ALIVE**, + resident `llama-server` pid 14963 **5874 MiB** on `:5805` (`Qwen3.5-9B-UD-Q4_K_XL.gguf`), `llama-swap /running` = `ocho-planner` ready via the scoped wrapper |
| kev_window | `unknown` -> `open` | **`closed`** — `memory.used 6156 MiB / free 1735 MiB` (nvidia-smi, two reads) |

Both tokens in the line that woke this tick were **false at write**, and neither was about demand:

1. **`kev_window unknown->open` was an INSTRUMENT event, not a capacity event.** The reboot at **19:51:13/17 (9th boot today)** loaded kernel module **615.71.09** `NVIDIA UNIX Open Kernel Module`, and the card came up: `GSP Firmware Version 615.71.09`, `/proc/driver/nvidia/params` `EnableGpuFirmware=18` (firmware/GSP path ON), **one** NVRM line this boot (the load line) — versus 216 NVRM lines in boot -1 (19:39:37, module **580.178.04**, userspace already 615 after the 19:47:36 `apt-get install nvidia-driver-615`, so NVML was unreadable and the previous sample's `unknown` was a *driver swap mid-flight*, not a card fault). The earlier standing condition — *GSP-ON kills this card, stay on the GSP-off workaround* — is **superseded on 615 by measurement**, not inference: `-open` module + GSP firmware live + readable card. The token changed because the instrument got its eyes back.
2. **`planner_at planner->none` was a SHUTDOWN release, and it lasted 9 minutes 44 seconds.** `scopes/` and `lease.mutex` both carry mtime **19:50:52**, the same second systemd began `systemd-reboot.service` (journal 19:50:51–57: `Stopping llama-swap.service`/`hermes-local-runtime.service` 19:50:52, `Reached target shutdown.target` 19:50:57). A file-existence token cannot distinguish that from a voluntary release — but the disk can date it, and the emptiness **was over before the tick that reported it finished writing**: the planner's own timer (`ocho-planner-polymarket.timer`, round started 20:00:28, `Result=success ExecMainStatus=0` at 20:01:10) re-acquired the scoped lease at **20:01:00.768** and refilled the card to 6156/8192.

## The rule

**After a reboot, the empty card lasts exactly until the planner's next timer phase — that is a clock reading, not available capacity.** Measured here: boot 19:51:17 -> scoped acquire 20:01:00.768 = **9m44s** of free card, the 3rd instance of this shape today (19:14 boot -> 19:20:28 refill; 19:51 boot -> 20:01:00 refill). The window's opening is set by *when the box booted relative to `*:0/10`*; its closing is set by the reloader, never by Kev's demand. So:

- Report a post-boot window **with its TTL and its clock** (`free 7559 MiB, closes on the next planner phase`), never as "there is room".
- The actionable quantity is *is it open at write* (rule of 2026-10-13-*a-reboot-manufactures-the-window*), and here that was `closed` — 1735 MiB, 2554 under the 4289 admission need.
- Ordered against the 5+ prior instances, this tick adds the **bound**: the post-boot gap has a measurable maximum, and on a 10-minute poll the whole of it sits inside one interval.

## The message hazard this exposes

The live Chair session dispatched two DMs into the gap — **to Ocho 20:00:16.120** (*"the card is completely free ... global: none held / scoped: none held <- no planner lease at all ... level-01 probe is unblocked at BOTH gates"*) and **to Llama 20:00:27.292** (*"the card is now completely free — 333 MiB used / 7559 MiB free, global lease none, scoped leases none"*). Both were **true at their write second and false 44 s / 33 s later**, when `record.json` landed at 20:01:00.768. A message to another agent is read *after* its write, so any window assertion inside it must carry its own falsification condition — *re-measure `gpu-lease.sh status` immediately before you take it* — which the Ocho DM did include and the Llama DM did not. Recorded, not corrected out of band: the live session owns its thread and my remit this tick is record-only.

## Disposition (playbook followed)

- **`planner_at -> none`**: recorded, with the release's cause and duration. No run action.
- **`kev_window unknown -> open`**: recorded with the live reading. Do **not** acquire, do **not** ping Llama to run — he self-authorizes under the operator precedence clause and was demonstrably mid-work (`profiles/llama/logs/agent.log` writing 20:02, DM handed to him 20:00:27). A fallback ping would have been **false against the live read** (window closed, 1735 MiB) — the 2026-10-12 *blink* class.
- **No `@ocho` DM**: this tick's diff is `planner -> none`, not `global -> planner`; his open item has been closed on the live channel since 17:25:42/17:28:53, and two deliveries from the live session are in flight right now into the same two targets — a third concurrent delivery is the drop hazard.
- **Entitlements**: no `kev` / `arcade` / `llama-model-test` lease anywhere under `gpu-lease/` during the 9m44s window; no Kev bundle newer than 2026-10-12 10:39; Kev last ran 2026-10-12 22:41. The window was not taken by anyone.
- **Not touched**: `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, no model load, no driver/apt. The 19:31 `read_card`/`show_tenants` fix (Ocho's, verified by proofs in `~/workspace/lease_backups/`, backup `gpu-lease.sh.pre-readcard-fix-20261013-193135`) was **read**, not modified — it now refuses on a non-zero exit instead of parsing NVML error text as a measurement.
- **Coordination note**: the two in-flight DMs already tell both agents the card is free; by delivery time it is not. The live session, not this watcher, owns that correction.
