# A prediction that closed on schedule is still not an acquisition

**Tick:** cron run, 2026-10-14T11:59-12:00 PDT · **Diff:** `planner_at=planner` (unchanged, planner on
BOTH sides) + `kev_window=open->closed` · **Sources read:** `nvidia-smi` (3 identical reads), the
scoped lease record, `ps`, the planner's own timer/service journal, `latest_plan.json`,
`model_cycle_counter.txt`, the O55 slot-picker source, the Kev artifact mtimes, and the readiness
instruments of the self-authorized owner.

## Live at write

| quantity | value |
|---|---|
| card | RTX 3060 Ti, 8192 MiB — **used 6197 / free 1695** (identical at 11:59:53, :57, 12:00:01) |
| gate | 4289 MiB (4033 peak + 256 headroom) ⇒ **CLOSED by 2594 MiB** |
| holder | `scopes/planner/record.json` owner=`llama-swap-ocho-planner` scope=`planner` class=`batch` need_mib=**6200** pid=**104571 ALIVE** mode=run acq=**11:50:28** expires +24h |
| resident app | llama-server pid **104651, 5874 MiB**, :5805, `Qwen3.5-9B-UD-Q4_K_XL.gguf` ctx 8192 + ocho_grammar.gbnf |
| other occupants | vision pid 2395 134 MiB (CPU-only, ngl 0) + gnome-software pid 5612 31 MiB |
| ledger | `scopes/` = `planner` ONLY; `lease.d/` ABSENT; **no kev/arcade/llama-model-test lease in any read** |
| work | round 11:50:22 → Finished 11:50:35, `Result=success ExecMainStatus=0`; 12:00 round ran, `latest_plan.json` 12:00:22.405 |

## The window, measured — and the prediction that held

Open **11:40:28** (smol rung acquires, resident 2672 MiB, free 4897) → closed **11:50:28** (9B rung
acquires, 5874 MiB, free → 1695). Duration **10 m 00 s exactly**. The previous entry (11:46) filed
the close *before* the event: *"the 11:50:22 round = cycle 58040 ⇒ pos 0 ⇒ 9B ⇒ free ~1395 ⇒ THIS
WINDOW CLOSES AT ~11:50:2x, and the next smol rung = cycle 58049 ⇒ the ~13:20 round."* Measured:
close = the 11:50:22 round's acquire at **11:50:28** (+6 s), free **1695** vs the predicted ~1395
(delta 300 MiB = unrelated tenants). The prediction held on both terms.

⇒ **Next predicted window: the ~13:20 round opens it (~13:20:28) and the ~13:30 round closes it.**
(`model_cycle_counter.txt` now holds 58042 — post-increment, read the cycle from the log line.)

## Rulings

**R1 A filed prediction that is checkable and then checked converts a "symptom" class into a
calendar.** Every prior entry in this series explained a window *after* the fact (failed load,
post-boot clock, foreign drain, ladder's bottom rung, rotation rung). This tick is the first where
the *next* transition was named in advance and landed on the named terms. That is the difference
between an instrument and a diary: the window is now a **known, periodic, datable event** —
`pick_model_slot()`'s `pos = count % 10` over `{ocho-planner:6, ocho-planner-4b:3,
ocho-planner-smol:1}` puts the 3B rung on the card once per ~100 min and the Kev gate opens as its
side effect. Record the rung and the *next* rung; never a bare free number.

**R2 A reactive message cannot acquire this window, by arithmetic — the lever is an instrument aimed
at the slot.** Window length **10 m 00 s**; the channel's *measured* latency is **~27 min** (a DM's
premise has repeatedly expired before receipt — the 2026-10-12 "blink" class). So a fallback ping is
**structurally incapable** of being true when read: it would have to land inside a 10-minute slot
while taking ~27 minutes to arrive. This is not a discipline preference, it is a ratio. The only
mechanisms that can take the window are (a) the owner's own poll landing inside the slot, or (b) an
instrument aimed at the *predicted* window (a timer at the ~100-min rung phase). Any future
proposal to "ping when it's open" should be rejected on this arithmetic, not re-litigated.

**R3 The self-authorization has no on-disk instrument this watcher can read; record that as ABSENCE,
never convert it into a ping.** Searched this tick: `pgrep -af "kev|arcade"` = NONE;
`systemctl --user list-units`/`list-timers` = no kev/arcade/model-test unit or timer (only
`ocho-planner-polymarket.timer`, next 12:10); no `*kev*poll*` script anywhere on disk;
`profiles/llama/logs/agent.log` last turn **09:47:11** (2 h 12 m quiet) and its
`cron/executions.db` is **empty** (its cron ticker heartbeats at 12:00:52, so the ticker lives while
carrying no jobs). Absence of an instrument is **not** proof of a dead poll — the owner may loop
inside a live session, and the coordination note asserts he polls continuously — but it does mean
**"he is watching" cannot be certified from any artifact**, so the honest record is *absence* and a
flag to the operator. A message cannot repair a missing instrument; a ping whose premise is a free
card is false at receipt anyway (R2). Kev artifacts remain all mtime **2026-10-12 22:41** — the gate
was clear by 608 MiB for the whole 10 m 00 s and nobody took it.

## Actions

- **No run action; no model load; no `@llama` ping; no `@ocho` DM.** The diff is
  `open->closed` (the task's own rule for this transition is "record; no action").
- Ocho's one open item: **closure checked in HIS rows**, not asserted from ours —
  `profiles/ocho/state.db` newest inbound (`role='user'`) **2026-10-13 20:00:21**, newest message
  **20:05:46**, nothing newer ⇒ 16th consecutive stand-down of the class (the diff carries no
  `planner_at global->planner` flip this tick).
- `gpu-lease.sh` / `llama-swap.yaml` / the planner lease / any model load: **not touched** (read-only).
- **Flagged to Mike, unchanged, record-only mandate:** `~/.config/Hermes/nvidia-egl-fallback.json`
  is still `{"state":"fallback","version":"0.0.0","driverVersion":"615.71.09"}` (mtime 10:06:10) with
  desktop renderer crashes earlier today; the card itself is healthy — module **615.71.09** open
  kernel module, **1** NVRM line this boot (the load line), boot 08:39, uptime 3 h 21 m — so the fix
  is `{state:"ok"}`, taking effect on the NEXT launch.
- **Flagged to Mike, new:** Kev has still not run since **2026-10-12 22:41** across every recorded
  window, and there is **no on-disk instrument** for the self-authorized poll (R3).
