# A foreign acquire is the only release the planner latch gets

**Filed 2026-10-25 13:08 PDT by the Arcade GPU co-residency watcher (profile `chilly`, cron job `67530e415818`).**
**Tick diff:** `planner_at=planner -> global` · `kev_window=open` **IDENTICAL on both sides**.
**Nature of the tick: RECORD ONLY.** No acquire, no release, no load, no unit touched, no message sent.
Llama remains self-authorized under the operator precedence clause to take Kev-4B at `--scope arcade` when
free >= 4289 on his own poll; this watcher does not preempt that and did not page him.

## The bracket

| sample | value | artifact |
|---|---|---|
| previous | `planner_at=planner kev_window=open` | `cron/output/67530e415818/2026-10-25_12-53-52.md`, 155 B `no_change`, mtime **12:53:52.942141988** |
| current | `planner_at=global kev_window=open` | `cron/output/67530e415818/monitor_last_output.txt`, 33 B, mtime **13:04:52.007223464** |

Edge lies in `(12:53:52.942, 13:04:52.007]` and is **dated 13:03:48.006106290** by the birth of the cell that
carries the new value: `lease.d/record.json`, 487 B, ino 3411587, sha256
`86b551504bedfdd1fc5839ae7e94c2f5909353f6d180cb893204829054f6816f`.

```
owner=ocho-suite-t_c4fa298e  scope="" (GLOBAL)  class=batch  need_mib=5400  headroom_mib=256
pid=2334404  mode=acquire  acquired_at=1792958628 (13:03:48)  expires_at=1792973028 (17:03:48)  ttl=14400
```

**The owner is not the planner.** `scopes/` is EMPTY (`scopes/` dir mtime 13:03) — there is no
`scopes/planner/record.json` on disk at all. The planner held **nothing** at the moment the token said `global`.

## Who wrote the edge

`arcade_window_watch.sh:28-35` decides `planner_at` from file presence only: `scopes/planner/record.json`
exists -> `planner`; else `lease.d/record.json` exists -> `global`; else `none`. So this flip required exactly
two facts: the scoped cell disappeared, and a global cell appeared. Both at 13:03:48.

Mechanism, from the wrapper's own code (read as text, not executed): `gpu-lease.sh:459-476` — a **GLOBAL**
acquire (`[ -z "$scope" ]`) first iterates every `$SCOPES_DIR/*/` through `decide_dir`, and `decide_dir`
`rm -rf`s any dir it calls `free` (`:298-304`). `free` for a `mode=run` holder is `kill -0 $LD_PID`
(`:278`), so a dead refusal holder is free. The latch standing in `scopes/planner/` at 13:03 was a dead-pid
refusal cell — the 12:40 round's, transcribed in the 12:43 filing (need 6200, headroom 256, pid 2316816 dead,
6456 vs 6198 = 258 MiB short) and then rewritten by the 12:50 and 13:00 rounds, both of which also failed
(journal: 12:50:15->12:50:24 `status=1`, 8.734 s wall / 5.533 s CPU / 141.8 M; 13:00:03->13:00:10 `status=1`,
6.701 s wall / 3.152 s CPU / 142.4 M). The 13:03:48 global acquire swept it and wrote its own cell in the same
call. **Stated as code-path plus timestamps, not as a captured log line**: the sweeper is another profile's
process and its stdout is not on disk here.

The planner released nothing, and after its 13:00:10 failure it wrote nothing further.

## Live card

| read | total | used | free | util | temp | occupants |
|---|---|---|---|---|---|---|
| 13:04:55 (sample second) | 8192 | 1776 | **6115** | — | — | Bonsai 1466 + LFM 134 + ~176 driver |
| 13:06:0x (x3, identical) | 8192 | 4557 | **3334** | 77-80 % | 64 °C | + ministral-3b 2776 (pid 2337588, born 13:05:39) |
| 13:07:30 | 8192 | 7049 | **842** | 98 % | 67 °C | Bonsai 1466 + LFM 134 + ornith-9b 5268 (pid 2339392, born 13:07:10) |

The `kev_window=open` this tick woke on was accurate **at sample time** (6115 free, 1826 over the 4289 gate at
`arcade_window_watch.sh:47`) and was **superseded 47 s later**: the suite's ministral-3b load at 13:05:39 took
free to 3334, and by 13:07:30 it is 842 — 3447 MiB under the gate. The next sample will read `closed`.

The closer is not the planner ladder. It is the **Ocho arena suite** run by kanban worker pid 2328357
(`hermes -p ocho … kanban task t_c4fa298e`, started 12:58:17) whose own log records
`[suite] baseline VRAM at suite start: 1776 MiB` — byte-agreeing with my 13:04:55 read — then cycling 9B
entrants at `-ngl 99`: bonsai-9b 13:01:08, mimo-9b 13:03:51, ministral-3b 13:05:40, ornith-9b 13:07:10.

## Rulings

### R1 — The `global` value is owner-blind and its edge is foreign-owned

`arcade_window_watch.sh:32` documents `global` as "still the pre-edit whole-card lease", which reads as a
statement about the **planner**. Measured this tick: the token reached `global` while the planner held nothing
and the holder was `ocho-suite-t_c4fa298e`. Both values are produced by file presence alone, and the presence
of `scopes/planner/` is created by a planner load but destroyed by **any** global acquire's sweep — so neither
direction of the token names the planner, and the `global -> planner` branch (the one that messages @ocho) is
keyed to the same file whose deletion a global acquire performs.

This is the **fourth** direction on the same token, after `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`
(early fire; never late) and `2026-10-24-a-silent-release-failure-keeps-the-planner-latch` (the empty end is
unreliable too): **identity is unreportable in the `global` direction.** A reader who wants to know who holds
the card must open the cell; the token cannot be quoted for it.

### R2 — The latch is released by the next tenant, and its numbers die in the same `rm -rf`

The dead-pid refusal cell standing at 12:40:19.723926783 lived until 13:03:48.006106290 = **23 min 28.3 s**,
and what ended it was an unrelated acquire's sweep — not the planner's release path, not TTL, not the
liveness rule firing on its own. So `planner_at=planner` has **no lifetime of its own**: it persists until
someone else wants the whole card. That is the observed positive of the release failure named in
`2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R1 — the latch does eventually clear, and the
clearing agent is a stranger.

Corollary, and the terminal case of `2026-10-25-a-refusals-arithmetic-dies-with-its-cell` R2: the refusal's
`need`/`headroom`/`pid` are deleted by that sweep, so after 13:03:48 no artifact on disk records what the
12:50 or 13:00 rounds bid. A tick that samples after a foreign acquire can no longer reconstruct the refusals
that held the latch — the count survives in the journal, the arithmetic does not.

### R3 — A window can close off the ladder's schedule, and this tick's did

The ninth window opened with the 12:40:19.723926783 refusal cell and closed at ~13:05:39 when a **non-ladder**
tenant loaded: 1519.3 s = **2 x 600 s + 319.3 s**, which is *not* the `k x 600 s + within-round offsets` shape
reproduced by `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`,
`2026-10-25-a-refusals-arithmetic-dies-with-its-cell-and-the-width-repeats-to-six-cycles` (k=6) and
`2026-10-25-an-intra-band-handover-is-bracketed-by-the-two-captures-either-side-of-it` (k=4). Free stayed
inside the `[4056, 6456)` band the whole time, so the previously stated falsifier band does not explain it.

**Falsifier, stated plainly:** the `k x 600 s` reproducibility is conditional not only on free staying in the
band but on **the planner ladder being the only writer**. An outside tenant closes a window at an arbitrary
time, so a width measured in round multiples is evidence that no foreign load occurred — and once Arcade
entrants run at `-ngl 99` on this card, that is no longer the default assumption.

### R4 — `open` and `spoken for` coexist, and the precedence hook is one-sided

`kev_window` is computed from `nvidia-smi` free alone (`:39-48`) and cannot see the lease. That is correct for
a memory reading and wrong as an entitlement reading: at the 13:04:52 sample a 5400 MiB global reservation had
already stood for 64 s, and the load that closed the window landed 47 s later. Under the operator precedence
hook (`gpu-lease.sh:437-448`) an `--scope arcade` contender is **not** refused by a live global lease — it
preempts — and nothing in that path stops the global holder's in-flight load. So an arcade acquisition taken on
an `open` reading during another tenant's batch window lands on the same card as that tenant's load
(here: 4289 needed against 6115 free at 13:04:52, with 2776 MiB more demanded by the suite 47 s later).

**Not observed this tick** — nothing was acquired, nothing collided — so this is filed as a mechanism read from
code with the numbers that were in play, not as a defect proved in the field.

## Away side (Llama)

`grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease` rc 1, no match; `scopes/` empty; no
arcade/kev/model-test process. He took nothing across the window. His clock beats (`ticker_heartbeat` 23 B and
`ticker_last_success` 18 B, both mtime 13:05:51) over a cron dir with **no `jobs.json`** and `executions.db`
24576 B stopped at 2026-10-12 06:33 — a beat certifies a clock, not an evaluation
(`2026-10-21-a-heartbeat-is-not-an-evaluation`). Flagged to Mike; not a finding against Llama.

## Messages

**NONE, and none executable.** No @ocho: this is the `planner -> global` direction, not the confirming branch,
and his scoped-planner item closed on the 2026-10-23 10:40 4B certificate. No @llama: the window is shut by
measurement (842 free, 3447 under his gate), so an "open" page would be **false at receipt**, and the fallback
is defined for an untaken *open* window. The DM path is re-measured ABSENT in this cron toolset (tool_search on
two phrasings returned no agent-messaging tool; deferred catalog = browser, computer_use, session_search,
terminal, todo) => the escalation channel is this delivery to Mike.

## For Mike (not corrected out of band)

1. The 9B ladder rung is still structurally inadmissible at today's ceiling (6456 vs 6115-6198), so every
   failing 9B pick evicts a serving tenant and opens a window that nothing uses. Tenth such window today.
2. **New this tick:** the Arcade arena suite is now a sustained occupant of this card at `-ngl 99`
   (bonsai-9b, mimo-9b, ministral-3b, ornith-9b inside six minutes; 7049/8192 used at 13:07:30). The planner
   ladder and the suite each treat the card as theirs; the lease arbitrates only at acquisition time, and the
   batch reservation (`mode=acquire`, 5400 MiB, TTL 4 h) sits on the card with a **dead pid by design** — an
   `acquire`-mode cell is written by a caller that then exits, and the liveness rule only reclaims dead
   `mode=run` holders, so this cell reads as a tenant in `gpu-lease.sh status` until 17:03:48 regardless of
   whether the suite is still running.

## Read-only throughout

`nvidia-smi` x8 (query-gpu, query-compute-apps), `date`, `ps`/`lstart`, `/proc` liveness on pids 2334404 and
2337588, `ss -ltnp`, `curl :8080/running`, `journalctl --user -u ocho-planner-polymarket.service 12:30-13:05`,
`stat`/`sha256sum` on the cell and the captures, `/tmp/gpu-lease.*` inventory, the lease tree, `gpu-lease.sh
status` (read-only verb), `gpu-lease.sh` and `arcade_window_watch.sh` read as text, arena suite log inventory,
`profiles/llama/cron` inventory. **Untouched:** `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and unit,
every model, the suite's own run, and the live global holder.

## Prior art

Printed by `priorart.py` on three phrasings **before this file existed** (437 records; all weak — 0.158
`2026-10-15-an-edge-already-dated-is-not-a-new-window`, 0.142 `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`
read and extended as R1, 0.134 `2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits` read and
distinguished — that one is about a window opening with no holder, this is about a window closing with no
ladder pick — and 0.117/0.112/0.104/0.098 on the other two phrasings) and read by eye. Cited by memory and
reused, not re-filed: `2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R1 (R2 is its observed
positive), `2026-10-25-a-refusals-arithmetic-dies-with-its-cell` R2 (R2's corollary is its terminal case),
the three width filings named in R3 (R3 is their falsifier instance). **Increment filed:** R1's identity
direction on the token, R2's foreign-release lifetime with the cell-deletion corollary, R3's off-schedule
close as a falsifier of the width rule, R4's entitlement-vs-memory gap with the precedence hook's one-sidedness.
