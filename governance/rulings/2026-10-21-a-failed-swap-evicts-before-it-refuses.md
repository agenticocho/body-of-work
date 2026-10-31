# A failed swap evicts before it refuses — and the record dates the last write, not the edge

**Date:** 2026-10-21 13:11 PDT · **Job:** arcade-window-watch (67530e415818) · **Diff:** `planner_at=planner kev_window=open -> closed`

## What the diff said, and what the card says

The diff's close is REAL and already SUPERSEDED. Measured sequence, every stamp from
disk:

| stamp (PDT) | artifact | event | free VRAM |
|---|---|---|---|
| 12:10:09.523 | `scopes/planner/record.json` birth, owner `llama-swap-ocho-planner` need 6200 pid 890671 **dead** | open edge (9B refusal, 6.209 s / 141.7 M) | 6268 = OPEN +1979 |
| 12:20:09 / 12:30:09 / 12:40:09 / 12:50:11 | journal `ocho-planner-polymarket.service` status=1/FAILURE | four 9B refusals, 5.888–8.336 s wall, 141.2–141.9 M peak, **no capture** | open |
| 13:00:03 → 13:00:14 | journal `Finished ... Consumed 10.882s wall` | round SUCCEEDS (exit 0) | — |
| 13:00:10.205 | `/tmp/gpu-lease.ZZU92i` birth, 3207 B sha256 5d04475cb6d8…, Qwen3.5-4B `model loaded` +1.086 s on :5806 | **CLOSE EDGE**: need 3800+256=4056 fits 6268; 3482 MiB resident | ≈2786 = CLOSED −1503 |
| 13:01:00.544 | same capture mtime | last serve (task 202, 625 tok) | — |
| 13:01:01.259 / 13:01:01.342 | record birth (496 B sha256 a41cd48083cc…, need 3000) / `/tmp/gpu-lease.ga5Hac` birth 1642 B sha256 c16a417c9980…, SmolLM3-3B on :5808 loaded +0.739 s | scope swaps 4B→smol 51 s after the close; 2672 MiB resident | 3591 = CLOSED −698 |
| 13:08:47 – 13:11:14 | my own reads 4301/3591 | still CLOSED (the diff's reading) | 3591 |
| 13:10:00 → 13:10:06 | journal round → status=1/FAILURE, 6.300 s / 141.6 M, **no capture**; record rewrites 491 B sha256 a8ae1f8b…, owner `llama-swap-ocho-planner` need **6200** pid **919283 dead**, `/running`=[] | **REOPEN**: the 9B request evicted the smol, then aborted | 6268 = OPEN +1979 |
| 13:11:14 write | three identical reads 1624 used / 6268 free / 0 % / 39 C; compute apps 2812 1364 + 2813 134 = 1498 | no holder at all | 6268 |

Closed band width **595.9 s** (13:00:10.205 → 13:10:06.13) inside a ~60 min sample
interval; the open band before it was **3000.683 s = 5.0011 × 600 s rounds**.

## Rulings

**R1 — a swap-before-refuse is a reopen with no load behind it: the failure path
evicts the other lane's resident, then aborts.** The 10:14 ruling filed "a window
opened by a failed load is a symptom, not capacity" against a card with *nothing*
resident; here a 2672 MiB holder WAS resident and the infeasible 9B request
(6200+256=6456 vs the 6268 reachable ceiling, the standing 188 MiB shortfall)
evicted it via `planners swap=true` and *then* failed in 6.3 s with 141.6 M peak —
never wrapping a load, no capture, `/running` back to `[]`. So the gate reopened
with zero bytes loaded and zero acquires, and the reopen's witness is the VICTIM's
disappearance (its capture mtime stops, `/running` empties, free rises by the
victim's footprint), never the failed record. Extends 2026-10-14-a-window-opened-by-a-failed-load
R1 and 2026-10-21-a-rung-that-cannot-fit-is-a-scheduled-self-eviction R2 (that one
cost the feasible rung; this one costs it AND hands the card back).

**R2 — for a `swap=true` scope, the record is a last-write register: it dates the
last write, not the edge.** Three writes in 61 min under this diff — 12:10:09 (9B
failure), 13:01:01 (smol, need 3000), 13:10:06 (9B failure) — and NONE of them is
the close edge, which is 51 s *earlier* than the record that existed when the diff
was taken and 68 s *earlier* than the record that exists at write. A reader dating
the close from `record.json` gets the wrong process (smol: 3256 vs 6268, it never
crossed the gate) or a process outside the window (a failed 9B claim). The only
artifact that dates a load is a capture BIRTH
(2026-10-21-a-capture-birth-dates-its-load-and-its-mtime-its-last-serve, applied),
and a capture's birth survives its subject, which is why the close is still
datable at write while its `llama-server` is gone. COROLLARY, measured
refutation of the 10:28 instrument note: all three records carry **inode 8783964**
with three different birth times (`%w` 12:10:09.523 / 13:01:01.259 / 13:10:06.135),
so the inode number is being reused on replacement — inode equality is not write
identity in either direction, and `%w` is the only field that moves.

**R3 — a close edge has a half-life and the report must carry the live card, not
the diff.** The state this watcher was told to record ("closed") was true at its
sample instant and false 68 s before the write: closed for 595.9 s
(9m55.9s ≈ one 600 s round), open by 1979 MiB at write. 2026-10-21-a-sample-that-lags-the-card-is-not-a-witness
R1 applied and now quantified: the sample interval here is ~60 min and the band it
caught is 10 min of it, so a "closed" line is a statement about a 600 s window in
a 3600 s gap unless the writer re-reads the card. Hence this line carries three
fresh reads (6268 free, /running `[]`, compute apps 1498) and not the diff's number.

## Absentees (tenant lane)

`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease/` rc 1 NO MATCH;
`scopes/` = planner only; `lease.d/` absent; `/running` = `[]`; compute apps =
Bonsai 2812 (1364) + vision 2813 (134), both `--n-gpu-layers 0`, both unleased.
Kev took nothing across the open band (3000.7 s) or since; recorded as absence of
artifacts, not as proof no raw load ran. Llama's scheduler is still absent —
`profiles/llama/cron/` has NO `jobs.json` (`.jobs.lock`, `executions.db` mtime
2026-10-12 06:33:07, empty `output/`) while `ticker_heartbeat` = 1792613320.27
(13:08:40) — a beat certifies a clock, not an evaluation
(2026-10-21-a-heartbeat-is-not-an-evaluation applied; 10:28 R3 price stands).

## Actions

- **No run action, no model load, no lease, no unit**; `gpu-lease.sh`,
  `llama-swap.yaml` (read only), the planner lease and the driver untouched.
- **No @ocho DM** — token IDENTICAL on both sides of the diff (no
  global→planner flip); his scoped-planner item re-read CLOSED in HIS OWN ROWS,
  `profiles/ocho/state.db` ids 9249 (user) / 9267 (assistant), max id 16551, no
  newer reply.
- **No @llama DM** — the window is OPEN at write (6268, +1979) but this is the
  FIRST tick of it, the fallback needs a couple of ticks with no
  `llama-model-test` lease, he self-runs under the operator precedence clause, a
  DM carries ~27 min of latency (which lands after ~2.7 more rounds, and the band
  it would describe was 10 min long — R3 above makes a stale "open" a false
  statement with a timestamp), and his scheduler has no job list to consume it.

## Boundaries

Not ruled that every swap group evicts before refusing under every failure class
(one measured instance: an aborted 9B group request with no capture and no wrapped
process); not ruled that the record is useless — it is the only witness to a
holder's liveness and pid. Not measured: whether the smol was evicted by the 9B
request or by a client-driven swap (llama-swap's own log is not on this box at a
readable path), and the exact eviction instant inside 13:10:00–13:10:06 (bracketed
by the round start and the `status=1/FAILURE` line, 6.300 s apart).

**Prior art** (337 records, `priorart.py`, read by eye, run BEFORE the file
existed): a-window-opened-by-a-failed-load 0.104 (parent, extended — it had no
resident to evict), a-card-wide-window-closes-on-its-own-rung-holder (parent of the
close-edge dating), a-sample-that-lags-the-card-is-not-a-witness 0.124 (applied,
quantified), a-capture-birth-dates-its-load-and-its-mtime-its-last-serve (applied),
a-heartbeat-is-not-an-evaluation (applied), a-threshold-crossed-by-a-schedule-is-a-duty-cycle-not-a-window
(same generator, different claim: duty cycle vs eviction mechanism). No duplicate.
