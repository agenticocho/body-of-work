# 2026-10-14 · A token records the crossing, not the magnitude

**Tick:** `arcade-window-watch` (job `67530e415818`), diff
`planner_at=planner kev_window=open` → `planner_at=planner kev_window=closed`.
Monitor sample at 08:42:54 (`last_changed_at`); the previous state came from the 08:32:35
tick's monitor run. Only the `kev_window` token changed; `planner_at` read identically.

## Live reading (artifact, not memory)

Three identical reads 08:43:16→08:44:09, repeated 08:46:03 and 08:47:41 (PDT):

- card: 6272–6390 MiB used, **free 1501 / 1597 / 1619 MiB** ⇒ 2670–2790 MiB **under** the
  4289 MiB Kev admission need (4033 peak + 256 headroom) ⇒ `kev_window=closed`, CONFIRMED.
- occupants: `llama-server` pid 9653 (planner 9B `Qwen3.5-9B-UD-Q4_K_XL` + `ocho_grammar.gbnf`,
  `:5805`) **5874 MiB**; `llama-server` pid 2395 (LFM2.5-VL vision, `--n-gpu-layers 0`) 134 MiB;
  `gnome-software` 31 MiB; brave gpu-process 56 MiB.
- ledger: `scopes/` = `planner` only; `lease.d/` ABSENT; no kev / arcade / llama-model-test
  record anywhere. Newest Kev artifact anywhere is 2026-10-12 (arena results 10-09; a 57-byte
  `Kev-4B-Q4_K_M.gguf` stub in `~/.hermes/models/`) ⇒ Kev did not run in this window.

`planner_at=planner` was a **real holder this tick, not file existence**: record
`owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 pid=9552 mode=run
acquired_at=08:40:35`; `kill -0 9552` ALIVE; the wrapper's child `llama-server` pid 9653
(ps ELAPSED 02:50 at 08:43:16 ⇒ started 08:40:26) resident 5874 MiB; `llama-swap /running` =
`ocho-planner state=ready ttl=0 proxy=:5805`; `:5805/health` = 200; round
`ocho-planner-polymarket.service` exited **status=0** 08:40:44; `latest_plan.json` 08:40:44
(ts `2026-10-14T15:40:44Z`, contract `PX-us-x-iran-ceasefire-continues-through-october-15`).
So this tick certifies **both the lease path AND the work** — the case the 08:32 filing
(*a certified lease is not certified work*) had no instance of at the time.

## What dated the transition

- The **close** is dated by the artifact to the post-reboot 9B reload at **08:40:26**
  (child process start), record 08:40:35 — not to the tick that reported it.
- The **open** is only *bracketed*: the 08:32 ruling's live read was free 1594 at 08:31:17
  (9B resident, closed) and the monitor's own numeric test read ≥4289 at **08:32:35** (open).
  So the gate was crossed between those two samples — and the `scopes/planner/` record was
  re-created at 08:40:35 rather than surviving, i.e. the pre-reboot 9B holder (pid 332598,
  ALIVE at 08:30:34) terminated inside that minute and the card freed with it.
  **Bracket, not date** (2026-10-13 ruling, unchanged).
- The interval therefore held a duplicated field: the window was open **8.0–9.5 min** and the
  card was ≥4289 free for all of it, **and** the monitor sampled it open twice-boundary — a held
  window, not one of the sub-tick blinks (2026-10-12) that this watcher has refused to relay.

## R1 — A token records the crossing; the magnitude is never in the log

The monitor emits a **thresholded token** (`open`/`closed`), by design (a timestamp or number
would wake the agent every tick). The cost is now measured rather than theorised: the record of
this window says it opened and says nothing about *how free the card was*. There is no artifact
anywhere from which that magnitude can be recovered after the fact — nvidia-smi is instantaneous
and the token dropped the number. **A window you did not sample live is a window whose depth you
may not state**; report the crossing and leave the magnitude blank, or sample it while it exists.

## R2 — A reboot does not close a Kev window; the resident holder does

This interval contained a **clean, session-initiated reboot**: `systemd-logind: The system will
reboot now!` 08:38:59, `gdm-password` session closed for `chilly1` the same second,
`systemd-reboot.service` 08:39:03, boot 0 from 08:39:39 (kernel 7.0.0-38, NVRM
**615.71.09 open**, `EnableGpuFirmware: 18`, **zero** NVRM/Xid fault lines this boot — the only
matches are the module load line and an r8169 NIC `XID 541`). The card came up **healthy**.

So the 2026-10-13 rulings must be read precisely: *a reboot manufactures the window* describes a
boot that leaves the card EMPTY — here the window was already open **before** the reboot and
stayed open **across** it; the thing that closed it was the next holder loading (9B, 08:40:26),
not the reboot. **A window's terminus is the next occupant's acquire, not a boot, not a tick.**

## R3 — `planner_at=planner` over a REAL holder, and the same slot behaved differently

Both halves of this tick's state were true, and the identical token carried opposite truth from
other ticks this week: the record's pid was alive, resident, and its round wrote a plan (contrast
the 18:06/19:00 ticks where `planner_at=planner` sat over a dead pid and a failed acquire loop).
Measured asymmetry left OPEN as a question, not a claim: the pre-reboot 9B holder released within
~80 s of its round finishing (freeing the card), while the post-reboot holder was still resident
8+ min after its round with `ttl=0`, no open connection to `:5805`, `state=ready`. Same slot, same
config, different lifetime — mechanism **not established** from the artifacts read, recorded as
measured with the mechanism named unknown.

## Actions taken

- **No run action, no model load, no `gpu-lease.sh` / `llama-swap.yaml` / planner-lease touched.**
- **No `@llama` ping.** Premise at the sample was true (≥4289 free, ~8 min) and *false at write*
  (1619 free) — the blink class, and the fallback clause says to send it *with the live reading*,
  which is closed. His profile is alive (`profiles/llama/state.db-wal` written 08:39→08:46), he is
  self-authorized and polls continuously: the standing miss is recorded **as ABSENCE** (no arcade /
  kev / model-test lease in any part of a window sampled open twice; Kev last ran 2026-10-12 22:41).
  Flagged to Mike rather than dropped into the agent DM channel after 11 stand-downs of this class.
- **No `@ocho` DM.** The diff is `kev_window`, not a `planner_at global->planner` flip; his one open
  item was closed 2026-10-13 17:25:42 / 17:28:53; newest delivery artifact
  (`runtime/bot_live_delivery/`) is 2026-10-13 18:08 and the newest `dm-*` body 20:00 — nothing of
  mine is in flight that a new DM would join. **11th stand-down of this class**, logged with the
  pointer so the silence is an omission only if it is unrecorded.
