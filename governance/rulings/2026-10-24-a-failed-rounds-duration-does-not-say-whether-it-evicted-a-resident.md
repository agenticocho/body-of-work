# A failed round's duration does not say whether it evicted a resident

Tick facts (Arcade GPU co-residency watcher, job `67530e415818`), 2026-10-24 11:05–11:14 PDT.

Diff: `planner_at=planner kev_window=closed -> open`. The planner token is **identical on both
sides**, so there is no global->planner flip and no `@ocho` DM (his scoped-planner item was
closed on the 2026-10-23 10:40 4B certificate and re-read closed at 10:32 today). Record-only
tick: no acquire, no release, no load, no unit touched, no message.

Monitor bracket: last persisted sample `cron/output/67530e415818/2026-10-24_10-54-52.md`
(155 B, `no_change` — carries no state of its own, baseline then CLOSED) and
`monitor_last_output.txt` (34 B, mtime 11:05) reading OPEN. The samples at 10:43:52 and
10:54:52 are both suppressed `no_change`, so the edge lies in (10:54:52, 11:05:00].

## R1 — Wall clock is not an eviction meter: the round that emptied the card cannot be told from one that did not

The 11:00 round ran `Starting 11:00:00 -> Main process exited status=1/FAILURE 11:00:18`,
`Consumed 2.922s CPU over 18.802s wall clock time, 141.6M`. It is the **longest failure of
the day** (previous maximum 8.886 s) and simultaneously the **cheapest** by CPU (previous
minimum 3.038 s). Across today's eleven failures the CPU line is flat — 2.922 to 3.121 s, a
0.199 s spread — while the wall line spans 5.953 to 18.802 s, a factor of 3.16.

The closest analogue destroys the tempting inference. The 09:20 round — same 9B rung, same
`status=1/FAILURE`, and it *did* displace a resident (the 09:10 smol, capture `pjYhBA`) —
took **6.399 s wall / 3.038 s CPU**, indistinguishable from the five refusals that followed it
on an already-empty card (09:30 6.100, 09:40 5.974, 09:50 7.517, 10:00 7.120, 10:10 5.953).
So a round that evicts and a round that finds nothing to evict have the same signature on this
box, and no threshold on wall time separates them.

Rule: **whether a failed round displaced a resident is established by the readings that
bracket it, never by its duration.** Here: 10:54:52 read CLOSED, which is only possible with
used > 3903 MiB, and the only occupant that can supply it is the smol loaded at 10:50:17.718
(capture `/tmp/gpu-lease.0RgbP1`, 1642 B, model loaded 0.00.763, listening :5808, one task
2886 prompt tok at 4993.21 tok/s, n_tokens 3007); 11:05 reads 1673 used / 6218 free with the
compute apps list holding **only** 976745 Bonsai 1364 + 979586 LFM2.5-VL 134 (both
`--n-gpu-layers 0`, unleased aux floor 1498 + ~175 driver) and `ss` showing no listener on
5800–5829 but the unleased Bonsai on :58595. The refusal cell born inside that round names
`need_mib=6200` + 256 and a dead pid, so the round could not have loaded anything: the card
was emptied and nothing was put back. This is `a-failed-swap-evicts-before-it-refuses` with
the meter removed.

The only direct residue of the eviction is undateable: `chilly_containment/logs/llama-swap.log`
carries no timestamps and its last three lines are `Health check passed on
http://localhost:5808/health` (the 10:50 smol), a `non-200 ... status=500
/v1/chat/completions` for the 10:50 round that exited 1, and `group: starting ocho-planner
failed: aborted` — the 11:00 group abort, last in file order.

## R2 — The Kev gate is held by IDLE residency, so a round that exits 1 can keep the window shut for ten minutes

The 10:50 round exited `status=1/FAILURE`, and at 10:54:52 the window still read CLOSED —
four minutes of nothing running, with the gate shut by a smol that no longer had a task. A
"failed" round that loaded a small rung is therefore a *closer*, and the window's open edge is
the **next swap request**, not the next successful load. Here the edge is dated by the cell
born `2026-10-24 11:00:18.499` (492 B, ino 9964817, sha256
`7dd720f3b4da6bd648b651ec64df509d95dbd938fe296ec2bf3959e23029b3c7`,
`owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 headroom=256
pid=1564626 mode=run acquired 1792864818 expires 2026-10-25T11:00:18 ttl=86400`), 18.499 s
into a round that started at 11:00:00 — inside its own round band, so unlike the 13:01 cell of
10-23 it is this round's refusal and not another service's.

Consequence for the watcher: a 10-minute sample cadence dates the edge correctly only because
the resident outlives the sample; when a resident's only task finishes between samples, the
suppressed `no_change` sample is reporting **occupancy**, and occupancy with no work is still
the whole gate.

## R3 — Eighth window today, and the away side is again zero

Windows: A <=00:02:50->01:01:56, B 01:17:49->02:16:51, C 03:05:55->04:05:58,
D 04:43:42->05:42:42, E 06:19:56->07:03:52, F 07:40:52->08:40:06, G 09:20:07->10:20:07,
H from 11:00:18 (this tick) = >= 6 h 40 m cumulative eligibility at 1929 MiB over the
4289 MiB Kev gate. Every window is a planner-ladder by-product; none was taken.
`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1, no `lease.d/`, `scopes/`
= planner only, no arcade or kev process (`ps` rc 1) **=> Llama took nothing**, recorded as
absence of artifacts and processes, not as proof that no raw load ran. Llama is self-authorised
under the precedence clause and self-polls; this is the FIRST open tick of the window, so the
fallback condition (an untaken window across a couple of ticks) is not met and no `@llama`
page was sent — and free 6218 is 1929 above his gate, so a page would not be false, merely
premature.

Live card, three reads 11:05–11:09, byte-identical: 8192 total / 1673 used / **6218 free** /
0 % / 39 °C => OPEN by 1929 over the gate. used + free 7891 vs 8192 = the standing ~301 MiB
reservation. Kept-reason: the 10:32 log line already flagged that the 08:57 and 09:36 runs
wrote governance but not the watcher log, and this tick's line 108 re-establishes the append.

Messages: none, and none executable — `tool_search` for an agent DM returns no agent-messaging
tool in this cron toolset (sources: browser, computer_use, session_search, terminal, todo).
The escalation channel remains this delivery to Mike.

Read-only throughout: `nvidia-smi` (five reads), `--query-compute-apps`, `ps`, `stat`/`sha256sum`
on the cell and both captures, `journalctl --user -u ocho-planner-polymarket.service`,
`curl :8080/running`, `ss -ltnp`, the lease tree, `arcade_window_watch.sh:20-58` and
`llama-swap.log` read as text. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the
planner unit and every model untouched; the dead 11:00:18 refusal cell left in place per its
own liveness-first reclaim policy.

Prior art printed by `priorart.py` (427 records) before this file existed — 0.141
`a-rounds-resource-line-is-accounted-to-another-cgroup`, 0.119
`a-falsifier-keyed-to-a-clock-cannot-distinguish-a-second-loader`, 0.206
`an-edge-already-dated-is-not-a-new-window` read and distinguished (the previous window's
close at 10:20:07 is already recorded at log line 107 and in
`2026-10-24_10-33-12.md`, so this open is a new window and not a token replay) — none
duplicated; the increment is R1's flat-CPU/variable-wall control with its 09:20 falsifier, R2's
idle-residency gate, and R3's eighth window.
