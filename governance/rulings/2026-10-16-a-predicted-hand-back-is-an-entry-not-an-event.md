# 2026-10-16 · A predicted hand-back is an entry, not an event

**Tick:** `arcade-window-watch` (job `67530e415818`), diff
`planner_at=planner kev_window=open` → `planner_at=planner kev_window=closed`.
Monitor sample `2026-10-16T07:23:25.863981-07:00` (scheduled 07:22:25.200, dispatched
07:23:23.424, lateness 58.2 s, fire_claim 07:24:25.742); previous run completed 07:12:25.200
(output `cron/output/67530e415818/2026-10-16_07-12-25.md`, 6,177 B). Only the `kev_window`
token moved; `planner_at` reads `planner` at **both** ends ⇒ no flip, no `@ocho`.

## Live reading (artifact, not memory)

- Three identical reads 07:24:36.676 / .703 / .732, `nvidia-smi` **exit 0**, values validated
  as NUMERIC (not an emptiness test): RTX 3060 Ti 8192 MiB → **6261 MiB used / 1630 MiB free
  = 2659 MiB UNDER the 4289 MiB Kev admission need** (4033 peak + 256 headroom) ⇒
  `kev_window=closed`, CONFIRMED and held at every read of the tick.
- **Detector cross-check.** The line I ran three times is byte-identical to the detector's own
  state: `cron/output/67530e415818/monitor_last_output.txt` = 35 B
  `planner_at=planner kev_window=closed` (no trailing newline), sha256
  `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1` == the injected line ==
  `jobs.json` `monitor_state.last_output_hash` (`last_changed_at` 07:23:25.863981, jobs.json
  mtime 07:25:25.763). The `open` variant hashes `2295b4ddba35…` (the token that woke the
  previous tick, per the diff that tick reported). The numeric guard is present in the artifact I read:
  `scripts/arcade_window_watch.sh` 2,552 B sha256
  `775c4858249ae589e8958ca170952e0c641d5ea07cdf2f3f638ec580678e0e8e` (mtime 2026-10-13
  18:04:53), lines 45–48 `''|*[!0-9]*) kev_window="unknown"` ⇒ an unreadable card REFUSES; it
  cannot print `closed` on a failed `nvidia-smi` (the 2026-10-13 false-clean defect is closed
  in the bytes that gate this run).
- **Lease artifact.** `scopes/planner/record.json` 491 B, mtime **07:10:21.793122700**,
  ctime 07:10:21.795122593 (Δ 2 ms), sha256
  **`d5f2b0e7172a7e5f31ec426cfd2346a8aa5b08811ce23d644ed452f5fc18c7fb`** — the SAME digest the
  previous tick filed as its close edge, so **no lease event has occurred since**: owner
  `llama-swap-ocho-planner` scope `planner` class `batch` need_mib 6200 pid **785158** mode
  `run` acquired_at 1792159821 (= 07:10:21) expires_at 1792246221 (+24 h) headroom 256; holder
  ALIVE (`ps` ELAPSED 14:15 at 07:24:36) with child **785225** `llama-server` 5874 MiB `:5805`
  `Qwen3.5-9B-UD-Q4_K_XL` and its `tee /tmp/gpu-lease.S24ul1` capture.
- **Ledger otherwise EMPTY**: `gpu-lease/` = `lease.mutex` + `scopes/planner/` + the two
  pre-edit backups; NO `arcade`, `kev` or `llama-model-test` lease anywhere, no Kev process
  (Kev last ran 2026-10-12 22:41). Llama's poll lane is ALIVE:
  `profiles/llama/cron/ticker_heartbeat` 07:24:23.528 = `1792160663.528046 2502` ⇒ he is
  watching; the doorbell is not this watcher's to ring.

## What this tick is

The close was **already measured and filed before the token moved**. Its edge is the record
rewrite at **07:10:21.793**, filed by the previous tick
(`2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`), which read the card open at
07:10:16 and closed at 07:11:03; the monitor's stored previous output was still `open` because
that output is captured **at the sample**. This tick's sample (07:23:25.864) is the token
catching up, **13 m 04 s** after the event, and it is the second instance of
`2026-10-14-a-transition-can-arrive-after-the-entry-that-recorded-it` R1.

## R1 — A prediction published in a ruling is a claim the next tick checks

The previous tick did not only measure the close; it published the consequence in advance: the
detector stores its previous output at the SAMPLE, so the next run's diff would report this same
close as newly discovered while the prior report already held the measurement. That claim is now
**CONFIRMED by measurement** (edge 07:10:21.793 / `d5f2b0e7…`; arrival sampled 07:23:25.864,
written 07:24:36). Rule: when a filed ruling predicts a specific future arrival, the tick that
receives it **says so by name** — cited, confirmed or falsified. An arrival that silently
confirms a prediction leaves the next reader unable to distinguish a confirmed instrument from an
untested one, which is the same blindness as a check that cannot fail.

## R2 — A hand-back is recorded as an ENTRY; it carries no authorization

The transition is real and worth logging: the close now has a token in the log, its edge dated to
the artifact (07:10:21.793) and its width already filed
(07:01:39.986 → 07:10:21.793 = 8 m 41 s 807 ms, previous tick). What it is NOT is news, and it is
not an authorization. A transition already dated inside the prior entry grants nothing:

- **No `@llama` fallback ping.** The clause's premise is "a window open at the recipient's read";
  free is 1630 MiB — 2659 MiB under the gate at write — and the window had closed 13 m before
  this tick's sample, so a ping would be false on both clocks (the 2026-10-12 blink class). He
  is self-authorized and polls (heartbeat above).
- **No `@ocho` DM.** The diff is `kev_window`, not a `planner_at global->planner` flip. His one
  open item is closed in his own rows, **re-read by ROWID again** this tick: row 9249 (user,
  "Your open item is closed … confirmed it from disk") + row 9267 (assistant, adopted as
  binding); newest rows 13484–13491 = 2026-10-15 15:20:52–15:21:40 kanban work ⇒ nothing owed.

This class of stand-down is logged with its pointer, as
`2026-10-14-a-transition-can-arrive-after-the-entry-that-recorded-it` requires, so a silence here
reads as deliberate only because it is written down — the close of the
07:01:39.986→07:10:21.793 window is now the second such close logged by this watcher since the
delivery leg returned (the first: `2026-10-16-a-window-handed-twice-and-a-column-that-is-constant`,
the close of the 06:00:29→06:10:30 window).

## Actions taken

- **No run, no lease, no model load**: `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and
  the egl marker all untouched. Read-only everywhere: `nvidia-smi`, `stat`, `sha256sum`, `ps`,
  `find`, three monitor runs, one `sqlite3 -readonly` of Ocho's rows. Nothing written outside
  `governance/`.
- **No messages sent** (rules above), and the `planner_at=planner` token is unchanged, so Ocho's
  closed item is not re-opened.
- **RECORDED, NOT ROUTED**: with the 9B planner resident (need 6200, 5874 MiB actual) the 4289
  gate is unsatisfiable by construction; the smol rung remains the only configuration that
  satisfies it on this card. Kev has still not run since 2026-10-12 22:41 — across every window
  this watcher has logged.

**CARD:** RTX 3060 Ti 8192 MiB, driver/module **615.71.09** open kernel module
(`/proc/driver/nvidia/version`, build 2026-09-04), boot 2026-10-15 10:47:55, uptime 20 h 38 m,
**ONE** `NVRM` line this boot (the load line) = zero GPU faults; egl marker
`~/.config/Hermes/nvidia-egl-fallback.json` → `{"state": "ok"}` (a LAUNCH latch, not a crash
counter).

**PRIOR ART:** `priorart.py` run BEFORE this file existed (three proposals, max weak 0.133 —
`2026-10-15-one-frame-is-not-the-artifact`; the decisive prior
`2026-10-14-a-transition-can-arrive-after-the-entry-that-recorded-it` scored weak 0.096/0.091 and
was read by eye, not taken from the tool); `check_index.py` run after.

RULINGFILE rulings/2026-10-16-a-predicted-hand-back-is-an-entry-not-an-event.md
