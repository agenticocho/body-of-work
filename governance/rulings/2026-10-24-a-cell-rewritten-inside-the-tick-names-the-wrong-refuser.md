# The refuser's cell is latest-wins at round cadence — a reader that arrives after the tick can name a refuser that never moved the card

**Tick:** `67530e415818` (arcade-window-watch), sample 2026-10-24 09:18:52 → 09:29:52 PDT.
**Diff:** `kev_window=closed -> open`; `planner_at=planner` IDENTICAL on both sides ⇒ no global→planner branch, no `@ocho` DM owed.
**Nature:** RECORD ONLY — no acquire, no release, no load, no unit touched, no message.

## What changed, from the artifact

**Edge bracket:** in `(09:18:52, 09:29:52]` — last suppressed sample `cron/output/67530e415818/2026-10-24_09-18-52.md`
= `no_change` (CLOSED), `monitor_state.last_changed_at` = `2026-10-24T09:29:52.074748-07:00`,
`monitor_last_output.txt` 34 B = `planner_at=planner kev_window=open`, dispatched 09:29:50.6.

**Two refusals, one cell.** Read at **09:30:03**, cell `scopes/planner/record.json` held
`owner=llama-swap-ocho-planner · need_mib=6200 · headroom=256 · pid=1514191 · mode=run ·
acquired_at=1792858807 (= 09:20:07) · expires_at=1792945207 (2026-10-25T09:20:07)`, pid **DEAD**
(`/proc/1514191` absent, absent from `--query-compute-apps`). Read again at **09:31:22**, the same path held
`pid=1519218 · acquired_at=1792859406 (= 09:30:06) · expires_at=1792945806`, also **DEAD**, 492 B,
sha256 `f689f2eb3499193e11e5daf790d021ea7e520f319f65119afd62211625586e90`, **birth `09:30:06.268970077`**
— i.e. the 09:20:07 cell was *unlinked and recreated* inside the tick, and its bytes now exist only in the
runner's own transcript. The 09:20:07 cell's inode identity is unrecoverable; the current one is a different
birth than the one detection saw.

**Round journal (`ocho-planner-polymarket.service`):** 09:00:01→09:00:12 **Finished** · 09:10:13→09:10:21
**Finished** · 09:20:01→09:20:07 `status=1/FAILURE` (3.038 s CPU / 6.399 s wall / 142 M) · 09:30:00→09:30:06
`status=1/FAILURE` (3.048 s / 6.100 s / 142.1 M). **No capture born in either failure minute** — newest
captures are `/tmp/gpu-lease.pjYhBA` birth `09:10:19.436505683`, mtime `09:10:21.701384064`, 1642 B,
sha256 `1883f4e4e057e6cf21d6afa456b38e82f6aaad91599bfb15ee3aab7d18afa699`, loading
**SmolLM3-3B-128K-UD-Q4_K_XL** (`model loaded` at `0.00.775.731`), and `/tmp/gpu-lease.iP11MF` birth
`08:40:06.230304940` 3265 B, mtime **09:00:12.099** with task 194 / `n_tokens = 3418` = the 08:40 4B retainer
serving the 09:00 round, displaced by the 09:10 smol (consistent with this morning's R3 resident-hit rule).

**Live card, three identical reads 09:31:0x:** 8192 total / **1673 used / FREE 6218** / util 1–3 % / 38–39 °C
⇒ **OPEN by 1929 MiB over the 4289 gate** (`arcade_window_watch.sh:47` = 4033+256). Apps `976745` Bonsai 1364
+ `979586` LFM2.5-VL 134 = 1498 + ~175 driver = 1673; `used+free 7891` vs 8192 = the standing ~301 MiB
reservation; llama-swap `/running` = `{"running":[]}`, no planner listener on 58xx; `lease.d/` ABSENT;
`scopes/` = planner only.

## RULING

**R1 — A cell that is rewritten at round cadence names the LAST refuser, not the refuser that moved the card,
and no field of it can tell you which.** Both attempts wrote the same path 10 minutes apart (09:20:07 dead pid
1514191, 09:30:06 dead pid 1519218), the second by unlink-and-recreate (birth moved), and the card reading was
**byte-identical either side** (1673 used / 6218 free). So a report that samples after 09:30:06 and quotes the
cell's `pid`/`acquired_at` as the edge writer is off by one round, with nothing in the token to warn it. The
discriminator is **admission arithmetic plus the journal**, not the ledger: a refusal on an **already-empty
card cannot move the card** (no tenant left to evict — the empty-card case of
`2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R2), so with one edge between two consecutive
refusals **only the first can be the writer** — here 1514191 at 09:20:07, whose round evicted the 09:10 smol.
Rule: cite a cell only **with the round that wrote it** (`pid` and `acquired_at` must both fall inside one
journal `Starting`→`Finished/FAILURE` pair), date an edge from the journal + captures, and treat a dead-pid
cell as a receipt for the *most recent* attempt only. This is the **observer-side complement** of
`2026-10-24-the-refusers-cell-erases-the-fitting-holder-that-preceded-it` (writer-side erasure of a predecessor
holder): there the fitting holder vanished from the ledger; here the *refuser itself* is overwritten inside the
watcher's own sample period.

**R2 — The watcher's tick is long enough to contain an erasure, because detection is 10 minutes wide and a
round is 10 minutes wide.** Detection was baseline-persisted at 09:29:52 and the runner's first read was
09:30:03 — **11 seconds** before a round landed — so on any tick whose dispatch coincides with a round boundary
the artifact read at the end of reasoning is a different writer than the one that triggered the alert
(`2026-10-15-the-sample-period-includes-the-watchers-own-runtime`, made concrete with a 14-second margin).
Rule: read the cell **twice** (immediately on dispatch, and again before composing the report) and if the two
reads disagree, the **earlier** one is the edge and the later one is a new attempt; reconcile both against the
journal. A single read of a file whose writer runs on the same clock as the watcher is a coin flip.

**R3 — Seventh window today, and the away side is unchanged and structural.** Windows so far: A `<=00:02:50→
01:01:56`, B `01:17:49→02:16:51`, C `03:05:55→04:05:58`, D `04:43:42→05:42:42`, E `06:19:56→07:03:52`,
F `07:40:52→08:40:06`, G `from <=09:20:07` — roughly 5 h 50 m of cumulative eligibility at 1929 MiB over the
Kev gate, every window a by-product of a planner round. Llama took **nothing**: `grep -rliE
'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` → rc 1, `lease.d/` absent, `scopes/` = planner only,
no arcade/kev/model-test process. His clock still beats (`profiles/llama/cron/ticker_heartbeat`
`1792859571.0110407` = 09:32:51) over a directory that holds **no `jobs.json`** at all and an `executions.db`
of 24576 B stopped at 2026-10-12 06:33 — a beat certifies a clock, not an evaluation
(`2026-10-21-a-heartbeat-is-not-an-evaluation`). Recorded as an observation about his poll and flagged to
Mike, **not** a finding against him and not a licence to acquire on his behalf.

## Messages

**NONE, and none executable.** No `@ocho`: `planner_at` is token-identical on both sides and his scoped-planner
item was closed on the 2026-10-23 10:40 4B certificate. No `@llama`: this is an open edge he is expected to act
on himself under the precedence clause, and the DM path is **re-measured absent** this tick — `tool_search` for
an agent DM returns no matches (available sources: browser, computer_use, session_search, terminal, todo), the
same absence recorded on 10-23 at 09:09/11:33/12:34/13:09/13:58/14:36/15:32/16:18/17:55 and 10-24 at
07:07/07:43/08:57. The fallback clause is therefore **not executable**, not declined: with nine untaken
windows today and a poll that has no registered job, the escalation channel that exists is this delivery to
Mike.

## Read-only throughout

`nvidia-smi` (multiple), `--query-compute-apps`, `ps`/`/proc`, `stat`/`sha256sum` on the cell and the captures,
`journalctl --user -u ocho-planner-polymarket.service`, `curl :8080/running`, `ss -ltnp`, the lease tree,
`arcade_window_watch.sh` read as text, the `profiles/llama/cron` inventory. `gpu-lease.sh`, `llama-swap.yaml`,
the planner lease, the planner unit and every model were **not** touched; the dead cells were left in place per
their own reclaim policy.

## Prior art

`priorart.py` printed on three phrasings **before this file existed** (426 records):
`0.145 2026-10-15-the-detection-margin-slips-one-minute-per-idle-sample`, `0.136
2026-10-23-a-pick-clock-dates-the-cell-when-no-capture-exists` (read — that record dates a refusal cell by the
pick clock when no capture exists; R1 is the case where the cell no longer holds the round it is dated to),
`0.125 2026-10-24-the-refusers-cell-erases-the-fitting-holder-that-preceded-it` (read in full — extended as
the observer-side complement, R1), `0.122 2026-10-15-the-sample-period-includes-the-watchers-own-runtime`
(read — given the 11-second margin and the double-read rule, R2), `0.110
2026-10-21-a-failed-swap-evicts-before-it-refuses`, `0.098 2026-10-13-a-confirmation-carries-an-invariant-not-a-pid`
(read — R1 applies it to an artifact rather than to a message). None duplicated. Increment filed: R1's
latest-wins/latest-attempt distinction with its ordering argument, R2's double-read rule, R3's seventh window
with the empty-job-store mechanism re-checked.
