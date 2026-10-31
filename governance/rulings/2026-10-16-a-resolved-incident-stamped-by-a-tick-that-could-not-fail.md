# A resolved incident stamped by a tick that could not fail

**Tick:** cron job `67530e415818` (Arcade GPU co-residency watcher), sample **2026-10-16 06:08:25**
(`monitor_state.last_changed_at=2026-10-16T06:08:25.838109-07:00`), previous sample **05:57:25** (0.25 s, `no_change`).
**Diff:** `planner_at=planner kev_window=closed->open`. The planner token is **identical on both sides** ⇒ no
`global->planner` flip, **no `@ocho` DM**. The tick owes no run action (Llama self-authorizes) and sends nothing.

## R1 — the window is the 06:00 smol rung, and it closed *while this report was being written*

The `open` token is true of the **sample** and was already false of the card by the write. Measured, not inferred:
the planner scope record was **rewritten at 06:10:30.269** from `owner=llama-swap-ocho-planner-smol need_mib=3000 pid=748499`
(sample-time read; pid alive in `ps` at 06:08:31) to `owner=llama-swap-ocho-planner need_mib=6200 pid=754347 acquired_at=1792156230`
(06:10:30; wrapper 754347 + resident child 754414 on `:5805`, `Qwen3.5-9B-UD-Q4_K_XL.gguf`; llama-swap `/running` = `ocho-planner state=ready`).
Three identical `nvidia-smi` reads: **3060 used / 4831 free** at 06:09:42 (open, +542 over the 4289 gate) → **6262 used / 1629 free** at 06:11:33
(**2660 UNDER** the gate, closed). The 06:00 round's smol rung read `acquired_at=1792155629` = **06:00:29**, so the window is
**10 m 01 s** wide (06:00:29 → 06:10:30) and the token's remaining life at sample was **~2 minutes**. The round's own artifact agrees:
`ocho_predictions.jsonl` `2026-10-16T13:00:32.354636+00:00` = 06:00:32, `model_slot=ocho-planner-smol`, next entry `13:10:36.526809` = 06:10:36, `model_slot=ocho-planner`.
This is the standing `a-transition-can-arrive-after-the-entry-that-recorded-it` shape and the standing reason no `@llama` ping is owed (R5).

## R2 — THE FALSE CLEAN: the incident was marked `resolved` by a run that structurally could not fail

`cron_incidents` row `67530e_7b818e286ef4` (this job, `failure_type=agent`,
`error="RuntimeError: Hermes can't reach the model provider. You may be offline."`) reads:

| field | value |
|---|---|
| `first_seen_at` | 2026-10-13T20:55:52.492221-07:00 |
| `last_seen_at` | 2026-10-16T04:51:37.901562-07:00 |
| `state` | **`resolved`** |
| `closed_at` | **2026-10-16T05:02:25.854922-07:00** |

The stamp is 11 minutes after the last failure — and the run that wrote it is `b93f2e26` (`started_at` 05:02:25.658209,
`finished_at` **05:02:25.908753 = 0.2505 s**), whose output file `cron/output/67530e415818/2026-10-16_05-02-25.md` says
**`Status: no_change (agent run suppressed)`**. A no-change tick **never invokes the agent**, so it never calls the model provider:
it is mechanically incapable of the failure this incident records. It could not have been the tick that failed, and it is not evidence
that the tick that *can* fail has stopped failing. Mechanism read at source, not assumed: `cron/incidents.py:242-259`
`close_incidents_for_recovered_job` — *"Mark every open incident for `job_id` `resolved` after a successful run"* — called from
`cron/scheduler.py:379-386` `_resolve_incidents_for_recovered_job` on any successful run; `resolved` re-opens on a repeat of the same
signature (`incidents.py:163,178`), which is why this row's `first_seen_at` spans three days of re-openings.

**Rule: where a job's failure mode is reachable from only one class of tick, an incident state that is stamped by a
different tick class is a false clean.** For this job the only ticks that can fail are the **change** ticks (a 0.2–0.3 s no-change tick
has no agent and no provider call; a failed change tick runs ~5 m 12 s, e.g. 04:46:25.649 → 04:51:38.084). So `resolved` here asserts
"no change tick has failed since 04:51:38" and *nothing at all* about the delivery leg — while the ticks that could falsify it are exactly
the ones the outage erases from the log (R3). The instrument needs a resolution that names the class it verified on, or no resolution.
Corollary: an incident whose reporter can only fail on rare ticks will read `resolved` almost always, so `resolved` is not a health signal —
`first_seen`/`last_seen` are.

## R3 — the hole, ENUMERATED (an amendment to `2026-10-15-a-delivery-outage-is-a-hole-in-the-log` R3)

That ruling's R3 was written from two failed ticks and concluded *"no later tick can recover it"*. Measured over the whole outage,
the hole is wider and its contents are recoverable — **not for Mike, but for the log**:

Ten change ticks between **2026-10-15 20:30:25** and **2026-10-16 04:46:25**, **every one `status=failed`** with the provider error and
every one **`delivery_outcome=suppressed`** — so no transition in that span was ever reported:

| tick (start) | diff (previous → current) | run outcome |
|---|---|---|
| 20:30:25 | `kev_window=closed->open` | failed (run 5 m 11 s) |
| 20:46:25 | `kev_window=open->closed` | failed |
| 22:08:25 | `kev_window=closed->open` | failed |
| 22:24:25 | `kev_window=open->closed` | failed |
| 23:46:25 | `kev_window=closed->open` | failed |
| 00:02:25 | `kev_window=open->closed` | failed |
| 01:02:25 | `kev_window=closed->open` | failed |
| 01:18:25 | `kev_window=open->closed` | failed |
| 04:30:25 | `kev_window=closed->open` | failed |
| 04:46:25 | `kev_window=open->closed` | failed |

**RECOVERY MECHANISM (the amendment):** a failed change tick still writes `cron/output/<job_id>/<run-time>.md`, and that file carries the
**injected diff** — so the transitions are enumerable after the fact from a directory the delivery leg does not own:

```bash
cd ~/.hermes/profiles/tiel/cron/output/67530e415818     # or: list -size +200c (the 155-byte files are no_change records)
grep -H -A3 '^--- previous' *.md                       # the diff block of every change tick, failed or reported
```

What is lost is the **report**, not the **record** — which is the distinction the hole ruling needed. Bound of this hole: the last
successfully reported transition is the **2026-10-15 17:52** tick (its report is in the session store, `cron_67530…` session started
17:52:27 with 53 messages); the hole is **8 h 16 m** wide and holds **exactly 10** transitions. This tick (06:08:25) is the **first
transition since 20:30 whose agent run reached the provider** — this report is the evidence, so the delivery leg is back as of 06:08:25
and the hole is closed.

## R4 — two opens whose producing round left no per-round artifact (recorded with the limit)

The `open` at **22:08:25** and the `open` at **04:30:25** have no matching `ocho_predictions.jsonl` entry for the 22:00 / 04:20 rounds
(the timeline jumps 21:50 → 22:10 and 04:10 → 04:30, one round missing in each case), i.e. the round that changed the card state produced
no plan — the `a-window-from-a-failed-round-that-loaded-cleanly` class. Recorded as what it is: the monitor's token is a statement about
**free VRAM crossing 4289** (numerically validated by the script), which is not by itself a statement about **a smol residency** — a swap
gap also presents as a numeric crossing. No rung is claimed for those two, and **no cycle arithmetic is offered anywhere in this ruling**:
`2026-10-15-a-rung-calendar-on-a-counter-with-two-consumers` R1 stands — `model_cycle_counter.txt` is consumed by the planner round *and*
by every shadow-planner subprocess (measured here: 151 counter increments against 141 ten-minute periods between the dated anchors
`cycle 58159` = the 2026-10-15 06:40 round and `cycle 58310` = the 2026-10-16 06:10 round, ≈10 extra increments), so a cycle number is not a clock.
The dateable datum is the timestamped `ts`+`model_slot` in the producer's predictions log.

## R5 — nothing was sent, by arithmetic and by the token

- **No `@ocho` DM.** The diff is `kev_window`; `planner_at` is `planner` on both sides ⇒ no flip. His scoped-planner item stands closed in
  **his own rows** (`profiles/ocho/state.db`, newest row `role='assistant'` **2026-10-15 15:21:40**, unrelated board work) — the read-back the
  correction ruling requires, not a prose echo.
- **No `@llama` fallback ping.** The window was **CLOSED at write** (1629 free = 2660 under the gate), so the 4289 premise is false at receipt
  before the channel's latency is considered; even at sample time the token had **~2 minutes** of life against the channel's measured ~27 min.
  His self-authorization still has **no on-disk instrument** this watcher can read: the whole `~/.local/state/gpu-lease/` tree is `scopes/planner`
  (plus `lease.mutex` and two `.pre-edit` backups), no `llama-model-test` lease, no kev/arcade process in `ps`.
- No acquire, no model load, no lease taken, nothing written outside `governance/`.

## EVIDENCE (read 2026-10-16 06:08:31–06:20 PDT, all read-only)

| read | value |
|---|---|
| card | RTX 3060 Ti 8192 MiB; **3060 used / 4831 free** (06:09:42, 3 identical) → **6262 / 1629** (06:11:33, 3 identical) |
| planner record @sample | `llama-swap-ocho-planner-smol`, `need_mib=3000`, `pid=748499` `mode=run`, `acquired_at`=06:00:29 |
| planner record @write | `llama-swap-ocho-planner`, `need_mib=6200`, `pid=754347`, `acquired_at`=06:10:30, mtime 06:10:30.269 |
| monitor determinism | `bash arcade_window_watch.sh` ×2 → byte-identical, sha256 `2295b4ddba35…` (both `planner_at=planner kev_window=open`) |
| round artifact | `ocho_predictions.jsonl` ts `13:00:32.354636Z` smol → `13:10:36.526809Z` planner; counter `58311` (post-increment) |
| rotation | timer `ocho-planner-polymarket.timer` `OnCalendar=*:0/10`, next elapse 06:20:00 |
| incident | `67530e_7b818e286ef4` resolved, last_seen 04:51:37.901, closed_at 05:02:25.855, stamped by run `b93f2e26` (0.2505 s, `no_change`) |
| failed change ticks | 10, 2026-10-15 20:30:25 → 2026-10-16 04:46:25, all `failed` + `suppressed`, full diff table in R3 |
| card health | module **615.71.09** open kernel module, boot 2026-10-15 10:47:55, **1** `NVRM|Xid` line this boot (the load line) = zero GPU faults |
| egl marker | `~/.config/Hermes/nvidia-egl-fallback.json` = `{"state":"ok"}` (a LAUNCH latch, not a crash counter — standing) |
| prior art | `priorart.py` run **before** the file existed: max weak **0.156** (`2026-10-15-a-delivery-outage-is-a-hole-in-the-log`), no REVIEW-band prior; `check_index.py` clean after |

## Files touched
`governance/rulings/2026-10-16-a-resolved-incident-stamped-by-a-tick-that-could-not-fail.md`, one line appended to `governance/INDEX.md`.
**Read-only** on `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the card and the egl marker: no lease taken, no model loaded, no run
triggered, no message sent.
