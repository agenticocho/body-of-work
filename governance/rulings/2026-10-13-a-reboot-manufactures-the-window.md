# 2026-10-13 · A reboot manufactures the window — and a poll's sample instant is not its write instant

## The event

Arcade co-residency watcher, tick **19:20**. The monitor diff was:

```
--- previous
+++ current
@@ -1 +1 @@
-planner_at=planner kev_window=unknown
+planner_at=planner kev_window=open
```

Read from disk, never re-derived:

- **The card is readable again.** `nvidia-smi` exit 0 — RTX 3060 Ti, 8192 MiB, **used 6215 / free 1869** (two reads 5 s apart, identical); driver **595.99.02** module and userspace; `GPU Firmware: N/A` ⇒ **GSP disabled**.
- **Boot 0 began 19:14:05** — the **7th boot today** (14:55:03, 18:12:06, 18:18:31, 18:26:39, 18:38:00, 18:52:29, 19:14:05). `journalctl -b 0` holds **0** `RmInitAdapter`/`RegReadError` lines: the ~10^5 lines/s NVRM register-read spam that ate boot -2's journal is **absent** this boot.
- **The `-open`-vs-proprietary question is settled by the single-variable re-run.** `/etc/modprobe.d/nvidia-no-gsp.conf` is **restored** (present; mtime 18:36 preserved by the move-back; `modprobe.d` dir mtime 19:12), so boot 0 is the **proprietary 595.99.02 module with GSP OFF** and the card is **up**, against boot -1 (18:52:29, same module, GSP **on**) with **no devices**, and boot -1's predecessor (18:38:00, GSP off) up. **GSP-off → card up (2/2); GSP-on → dead (1/1).**
- **The scoped planner lease is LIVE, and this time the round finished.** `scopes/planner/record.json` written 19:20:32 — `owner=llama-swap-ocho-planner` `scope=planner` `need_mib=6200` `pid=11431` `kill -0` **ALIVE** — resident `llama-server` pid 11500, **5874 MiB**, `:5805`, `Qwen3.5-9B-UD-Q4_K_XL.gguf` + `ocho_grammar.gbnf`; `latest_plan.json` written 19:20:41; `ocho-planner-polymarket.service` ran 19:20:00 → **exit 0** at 19:20:41 (`lease.d/` absent, `scopes/` = planner only).
- The **previous** tick (19:09) read the *same token* `planner_at=planner` over a **failed-acquire record with two dead pids** and no resident app, on an **unreadable** card.
- **No `kev`/`arcade`/`llama-model-test` lease exists anywhere under `gpu-lease/`; Kev last ran 2026-10-12 22:41.**

> **R1 — A reboot manufactures a window, and a poll's sample instant is not its write instant.** The monitor's `open` was **not a measurement error**: between the boot (19:14:05) and the planner's next timer reload (19:20:28) the card genuinely had free ≥ 4289 MiB, because a boot leaves the card *empty*. That makes the post-boot/open pairing the one class of `open` that is **true at sample time and still not actionable**: the refill is driven by the planner's own `*:0/10` timer, so the window is **bounded by the reloader's clock, not by co-residency demand**, and the whole of it sits between the tick that detects it and the entry that records it. So the actionable quantity is never *"was it open at sample"* but *"is it open at write"* — and on a 10-minute poll the two are separated by the entire reload. Corollary, and the sharper half: the **instrument's recovery and the phantom window are the same event**. The return of readability (`unknown` → a real number) *created* the favourable subject state it then reported, so an instrument event and a subject event can be one event — which is why the reading, not the diff, has to decide (rulings `2026-10-13-an-instrument-recovery-is-not-a-subject-transition`, `2026-10-12-arcade-window-blink-refuted-by-live-read`).

> **R2 — A cross-boot comparison becomes a finding only when a single variable moves — and this one did.** Restoring `nvidia-no-gsp.conf` and rebooting, with the module held fixed, produced a working card where GSP-on had produced *no devices*; so the attribution is no longer *strong but not exclusive* (the caveat recorded in `2026-10-13-a-fresh-record-from-a-failed-acquire`), it is **confirmed**: on this box the **GSP path is what kills the card**, and the `-open` module — which **requires** GSP and has no legacy fallback — therefore **cannot be used here** until the GSP path itself is fixed. The card is currently up on the **workaround**, not on a cure.

> **R3 — A pointer is not durable where the record that cites it is pruned.** The two DM bodies this watcher's own log cites (`cache/scratch/dm-ocho-scoped-planner-20261013.md`, `dm-udbaib9s.txt`) have been **pruned from scratch**. The reading survives in the watcher log and in the two 17:25/17:28 delivery records, but a hand-over that is named only by a scratch path is **one prune away from unrecoverable**, and the caller cannot tell a pruned pointer from a stale one. Cite the repo or the delivery record; do not cite the working copy (`2026-10-13-a-vanished-file-is-answerable`, `2026-10-13-a-discipline-that-lives-in-one-file`).

## What was done

- **Read-only.** No `gpu-lease.sh`, no `llama-swap.yaml`, no planner lease, no model load, no driver/apt/dpkg touch.
- **No DM to Ocho.** `planner_at` did not change this tick (no `global->planner` transition), and the prescribed claim, though it would now be TRUE, was withheld: the item was closed on the live channel at 17:25:42/17:28:53, no delivery remains in `runtime/bot_live_delivery/`, and a true-but-redundant DM into a closed item is the drop hazard (third instance of `2026-10-13-a-watchers-action-may-already-be-in-flight`). Stand-down logged with the pointer, so silence cannot read as omission.
- **No `@llama` ping.** The window is **closed on the live read** (1869 MiB free, 2420 under the 4289 need); a "window open" ping would have been **false** against it (the 2026-10-12 blink class). He self-authorizes on his own continuous poll under the precedence clause, is demonstrably mid-work on this exact fault, and this was the **first tick** of the window.
- **FLAGGED FOR MIKE, not acted past:** the card is up **only** on the GSP-disabled option; GSP-on is now **confirmed** fatal for this card, which rules out the `-open` module here until the GSP path is fixed. Also standing: while the planner holds the **9B** (need 6200) free sits at ~1869 MiB, **2420 under** the 4289 need, so there is **no held Kev window** in that configuration — Kev-4B only fits in the sub-tick reload gaps, or while the planner is on the 3B (≈4884–4990 free, which clears) rather than the 4B (4073, which does not).
