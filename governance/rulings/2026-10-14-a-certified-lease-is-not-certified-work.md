# a certified lease is not certified work

**Date:** 2026-10-14 · **Tick:** arcade-window-watch, diff `planner_at=planner kev_window=closed->open` (planner_at token unchanged)

## The three facts this tick measured

1. **Sample (08:28:45): window OPEN and held.** `nvidia-smi` exit 0, 8192 MiB total,
   used 3104 / **free 4787** at 08:28:56 and used 3086 / **free 4805** at 08:29:00 —
   two reads 4 s apart, both **+498…+516 MiB over the 4289 MiB Kev-4B gate**. Occupants:
   `ocho-planner-smol` 3B 2672 MiB (pid 322575, :5808) + vision 134 MiB + brave gpu-proc 56 MiB.
   Absentee: the 9B primary slot. Window opened at **08:20:13** when the planner's smol
   wrapper took the scoped lease (record owner `llama-swap-ocho-planner-smol`, need_mib 3000,
   pid 322508 ALIVE); the previous sample (08:06:46, `no_change`) read **closed** with the
   4B fallback resident (free 4125, 164 MiB *under* the gate). So the open was a
   **4B→smol slot rotation**, i.e. the arithmetic filed on 2026-07-14 (gate 4289 clears only
   the smol slot, an empty card, or a sub-tick gap) recurring as a *load event*.

2. **The same round FAILED.** `ocho-planner-polymarket.service` 08:20:07 → **status=1** at
   08:20:15. At that instant the scoped-planner flip's three confirmation reads were **all
   positive**: `scopes/planner/record.json` present, holder pid 322508 **alive**, resident
   llama-server 2672 MiB on :5808, `llama-swap /running = ocho-planner-smol state=ready`.
   So the flip was certified live **while the planner produced nothing**; `latest_plan.json`
   stayed at 08:10:37. **The three reads certify the LEASE PATH, not the WORK.** A
   "confirmed live end-to-end" statement to a consumer must name *which* invariant it
   certifies — "the scoped lease acquired and held" — never "the planner ran".

3. **Write-time re-read (08:31:17): window CLOSED.** The 08:30:28 round **succeeded**
   (Finished 08:30:41, `latest_plan.json` 08:30:41) after the **9B primary came back**:
   record replaced by owner `llama-swap-ocho-planner` need 6200 pid 332598 ALIVE (acq 08:30:34),
   resident 5874 MiB on :5805, smol record and pid 322508 gone. Card used 6298 / **free 1594**
   (second read 1603) — **2695 MiB under the gate**. The open interval is therefore
   **08:20:13 → 08:30:34 (10 m 21 s)** and the whole of it sat **between the sample that
   caught it and the entry that would report it**.

## Rules

- **R1 — A certified lease is not certified work.** Liveness + record + resident app prove the
  *lease* is held by a live holder; they say nothing about whether the round completed. Report
  the invariant you actually measured; a consumer reading "confirmed end-to-end" as "it
  worked" is misled by construction. Check the round's own artifact (`latest_plan.json`,
  unit `Result=`) beside the lease before attaching success.
- **R2 — A slot does not own a free-VRAM number.** The 07:58 filing recorded
  "smol 3B (2672 MiB resident) ⇒ free 4884–4990". This tick the **same** 2672 MiB smol holder
  left **free 4787/4805** — ~100–200 MiB lower, the delta being unrelated tenants (brave
  gpu-process 55–56 MiB) and base drift. A slot→free table is **not** reproducible; the
  threshold sits close enough to the slot boundary that an unrelated browser tab moves the
  margin. Report the measured free **with its occupant list**, never a remembered mapping —
  the same rule as "read the artifact", applied to my own recorded figures.
- **R3 — The actionable quantity is *is it open at write*.** Third instance of this class on
  this metric: a transition that is real and held at sample can be fully reverted by the
  time the entry is written. A ping to another agent whose premise is the window carries its
  own falsification condition, because the recipient reads after the write.

## Actions

- **No run action** — Llama is self-authorized under the operator precedence clause and polls
  continuously.
- **No @llama fallback ping, and a re-read is the reason it was correctly withheld.** At the
  sample the ping's premise was TRUE (free 4787 ≥ 4289). By write time free was **1594 MiB,
  2695 under the gate** — the message would have been FALSE at the recipient's read (the
  2026-10-12 blink class). It was also only the first tick of the window (hold-one-tick
  discipline), and the window is now closed by the planner's own success, so no fallback is
  outstanding.
- **No @ocho DM** — the diff is `kev_window`, not a `planner_at global→planner` flip; the
  scoped-flip item was closed on the live channel 2026-10-13 17:25:42/17:28:53; the delivery
  dir `profiles/tiel/runtime/bot_live_delivery/` has no delivery newer than 2026-10-13 18:08,
  so this is a stand-down, not an omission (10th of the class).
- **Ledger: no arcade holder.** No `kev` / `arcade` / `llama-model-test` lease anywhere under
  `gpu-lease/`; `scopes/` = `planner` only, `lease.d/` absent; `kev_probe.json` and
  `kev_server.log` mtime **2026-10-12 22:41** → Kev has not run in any window recorded since.
  Recorded as ABSENCE, not acted past.
- `gpu-lease.sh` / `llama-swap.yaml` / the planner lease / model loads: **untouched** (read-only).

## Flagged for Mike

- The planner's 9B slot failed 7 consecutive rounds (06:40–07:40), ran 07:50/08:00/08:10 on the
  4B fallback, **failed again at 08:20**, and **recovered on the 9B at 08:30:41** — intermittent,
  and while it was degraded the card cleared the Kev gate (~10 min) *because the planner was
  on its smallest slot*, not because capacity existed. The 07:58 flag ("9B live-betting slot
  not loading") is **partially resolved by measurement**: the 9B loaded and a round succeeded
  at 08:30:41.
- Kev has still not run since 2026-10-12 22:41 despite ~12 recorded window events.
