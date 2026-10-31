# The scoped cell is written by a refusal, and a release deletes its own bid

**Tick:** arcade-window-watch, job `67530e415818`, 2026-10-25 13:18:52–13:21 PDT. Diff (injected): `planner_at=global -> none`, `kev_window=open` **IDENTICAL on both sides** → no window edge, no enumerated confirming branch, no `@ocho` DM. Nature record only: no acquire, no release, no load, no unit touched, no message.

**Built on, not re-filed:** `2026-10-25-a-foreign-acquire-is-the-only-release-the-planner-latch-gets` (R1 the `global` value is owner-blind; R2 the latch has no lifetime of its own and its numbers die in the same `rm -rf`), `2026-10-23-a-scope-record-is-one-cell-written-only-by-attempts-that-reached-the-wrapper` (the scope dir is one last-writer-wins cell, not a log), `2026-10-24-a-silent-release-failure-keeps-the-planner-latch`, `2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits`.

## What was measured

- **The sample and its bracket.** `cron/output/67530e415818/monitor_last_output.txt` mtime `13:18:52.035055913`, 31 B, reads `planner_at=none kev_window=open`; the previous agent sample `2026-10-25_13-08-22.md` (mtime `13:08:22.225564313`) carried `planner_at=global kev_window=open`. So the edge lies in **(13:08:22.226, 13:18:52.035)** and the whole lease tree was re-read at 13:18:58: **no `record.json` anywhere** — `find ~/.local/state/gpu-lease` returns only `backups/`, `lease.mutex`, `scopes/` (empty, dir mtime `13:03:29.382`).
- **The removed cell, and who removed it.** The cell is the one transcribed in the 13:08 filing and is now **deleted, so that transcription is its only surviving statement**: `owner=ocho-suite-t_c4fa298e scope="" (GLOBAL) class=batch need_mib=5400 headroom_mib=256 pid=2334404 mode=acquire acquired_at=1792958628 (=13:03:48.006) expires_at=1792973028 (=17:03:48) ttl=14400`. Its owner removed it itself: kanban log `t_c4fa298e` records `~/NVIDIA-PAIR/ops-docs/scripts/gpu-lease.sh release --owner ocho-suite-t_c4fa298e`, and the suite's completion says "the global lease was released (`lease in scope (global) … removed`), the card read **1775 MiB used / 6116 MiB free**, both lease stores empty". Artifact times: `lease.mutex` mtime `13:15:58.235035155` (the release verb's mutex open), `SUITE_RESULTS_multi_model_2026-10-25.md` written `13:16:35.920552`, commit `4e73bdb` `13:16:39.224`.
- **The claim's real duration.** `13:03:48.006 -> 13:15:58.235` = **730.2 s = 12 m 10.2 s**, i.e. **5.07 %** of its own 14400 s TTL and **3 h 47 m 50 s before** its `expires_at`. The TTL was never consulted.
- **Live card, three identical reads (13:18:5x, 13:19:0x, 13:20:4x):** 8192 total / **1775 used / 6116 free** / util 0 % / **39 °C**. `--query-compute-apps`: `976745 = 1466` (Ternary-Bonsai-9B, `--n-gpu-layers 0`) + `979586 = 134` (LFM2.5-VL, `-ngl 0 --no-mmproj-offload`) = 1600 + ~175 driver = 1775; used+free 7891 vs 8192 = the standing ~301 MiB reservation. `gpu-lease.sh status` agrees: both tenants `owner=unowned`, **global lease: none held**. `/running = {"running":[]}`; every `/v1/models` entry — including `brain` (alias `planner`) — `status: unloaded`. **`kev_window=open` by 6116 − 4289 = 1827 MiB.**
- **The token moved twice inside this one tick.** 77 s after the `none` sample, `scopes/planner/record.json` exists: 492 B, ino `9965781`, birth `13:20:09.119806666`, `owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 headroom_mib=256 pid=2352608 mode=run acquired_at=1792959609 expires_at=1793046009 ttl=86400`. **pid 2352608 is DEAD** (`ps -p` rc 1, `/proc/2352608` absent, absent from `--query-compute-apps`, no listener). Unit journal: `13:20:03 Starting` → `13:20:09 Main process exited, status=1/FAILURE`, `3.132 s CPU / 5.955 s wall / 142.4 M` — the 10-minute round, failing. The **last `/tmp/gpu-lease.*` capture today is `ahr6tW`, 13:01:14.014**, so nothing loaded in the 13:10 or the 13:20 round. Admission arithmetic agrees: 6200 + 256 = **6456 vs free 6116 = 340 MiB short**, the standing 9B deficit.
- **The status surface still words it as a live tenant.** `gpu-lease.sh status` printed at 13:20: `scope planner: owner=llama-swap-ocho-planner … pid=2352608  expires in 86380s (expires_at=1793046009)` with **no liveness column**, while `ps -p 2352608` was empty in the same second.

## R1 — A release deletes its own bid, so `expires_at` is a ceiling and occupancy has no artifact

The 13:08 filing established that a **stranger's acquire sweep** `rm -rf`s the planner latch and its numbers die with it. This tick is the same deletion by a different hand: the owner's own `release` verb, on time, with no failure — and the result on disk is identical, an empty store. Three consequences, each measured here rather than argued:

1. **The claim's duration is birth-to-deletion, and the deletion destroys the only record of the claim.** 730.2 s of a 14400 s TTL. The 13:08 transcription is now the sole on-disk statement of a 5400 MiB global reservation that stood across four 9B entrant loads; nothing in the lease tree records it any more.
2. **`expires_at` is a ceiling on a claim, never a forecast of occupancy.** Reading 17:03:48 as "the card is spoken for until then" would have been wrong by 3 h 48 m. The liveness-first policy line inside the cell already says a TTL only bounds reclamation; this tick adds the positive: even a *live, correct* holder leaves early, so the TTL is the maximum of nothing observed.
3. **Therefore the watcher's own per-tick transcription is the journal.** An artifact that is deleted by the act it records cannot be cited after the fact; the ordered, durable evidence of a lease's content is the sample series, not the lease store.

## R2 — The `planner` value is written by refused attempts, so file presence is not a flip confirmation

The tick's own branch list says `planner_at global->planner` means "the --scope planner flip is CONFIRMED LIVE (a model loaded under the scoped lease)". This tick produced the counterexample **inside its own bracket**: 77 s after a `none` sample the scoped cell existed, and it names a **dead pid, a 340 MiB-short admission, no capture, no resident model, and a FAILURE unit**. The wrapper writes its cell at acquire, before the admission test; a refusal therefore leaves the same file a load would.

Rule, in evidence order — a scoped cell is a **confirmation** only when all four hold, and any missing one makes it a **refusal receipt**:

1. `pid` alive in `/proc` (and its wrapper's parent still `llama-swap`);
2. a resident child visible in `nvidia-smi --query-compute-apps` with non-trivial MiB;
3. a `/tmp/gpu-lease.*` capture **born after that round's start** (its own `tee` holds it);
4. `/running` naming the alias with `state=ready`.

**Directive for the next sample:** the next reading will be `planner_at=planner`, and its diff will be `none -> planner`, which is **not** the enumerated confirming branch. Do not report it as a flip confirmation, and do not message `@ocho` on file presence. (Extends `2026-10-23-a-scope-record-is-one-cell-written-only-by-attempts-that-reached-the-wrapper`, which proved refusal cells exist, into the branch that would carry a message.)

## R3 — A clear card has the ladder's 10-minute horizon, not a capacity horizon

`planner_at=none` **with** `kev_window=open` is the "effectively clear" state, and it was real: no lease in either store, nothing resident, 1827 MiB above Kev's gate. It lasted **at most 4 m 51 s** (release ≈13:15:58 → the 13:20:09 cell). So a clear reading is a statement about an instant whose expiry is the round timer; whoever reads it as durable eligibility is measuring the ladder's cadence, not the card. For Kev the two gates now point the same way — free 6116 ≥ 4289 by 1827 and nothing loaded — but the same ladder that re-writes this dead 9B latch every round also carries a 4B rung (3800 + 256 = **4056, 2060 spare**) whose pick both closes the window and is admissible inside it: **the round that shuts this window can be the round that opens the slot**, which is why the window's width is a pick schedule and not a scarcity reading.

## Away side — Llama took nothing, and nothing is owed

No `arcade` / `kev` / `model-test` record, dir or process: `find` over `~/.local/state/gpu-lease` returns `backups/`, `lease.mutex`, `scopes/` only; `ps` matches nothing for those names. His clock beats (`profiles/llama/cron/ticker_heartbeat` 24 B, mtime `13:19:51.013`) over a profile cron dir with **no `jobs.json`** and `executions.db` 24576 B frozen at `2026-10-12 06:33` — a beat certifies a clock, not an evaluation. The fallback clause is for an **untaken open window across a couple of ticks**; this clear state was four minutes old and the window has been open by measurement for 13 minutes, so **no `@llama` message**: paging him on the first clear tick would preempt the poll he is authorised to run himself.

## Messages: none, and one of them would have been false

- **`@ocho`: none.** The enumerated branch (`global->planner`) was not the one taken; the scoped cell that did appear is a refused attempt (R2), so "the scoped-planner flip is confirmed live" would have been a **false statement to a peer** — the exact failure this session's discipline exists to prevent. His scoped-planner item was already closed on the 2026-10-23 10:40 4B certificate.
- **`@llama`: none** (reason above).
- **The DM path is absent in this cron toolset again** — `tool_search` for an agent DM returns no match; the deferred catalog is `browser_vault`, `computer_use`, `session_search`, `process_manage`, `todo_list`. Escalation channel is this delivery to Mike.

## For Mike

- **The 9B rung remains structurally inadmissible at today's ceiling:** 6456 needed vs 6116 free = 340 short, so every 9B pick (60 % weight) fails; and each failing round **re-writes a dead latch that `gpu-lease.sh status` prints as a live 4-hour tenant with no liveness column** (measured again: `pid=2352608 expires in 86380s` while `ps -p 2352608` is empty).
- **The suite closed cleanly and early:** it released its global lease at 5.07 % of its TTL and its own completion's reading (1775 used / 6116 free, both stores empty) **agrees byte-for-byte** with my independent `nvidia-smi` — a second witness for a state whose artifact it had just deleted. That agreement is corroboration, not the measurement.

**Read-only throughout:** `nvidia-smi` (query-gpu x5, query-compute-apps x2), `gpu-lease.sh status`, `ps`/`/proc` liveness, `curl :8080/running` and `/v1/models`, `journalctl --user` (13:00–13:21), `stat`/`find`/`sha256`-free inspection of the lease tree, `/tmp/gpu-lease.*` inventory, `arcade_window_watch.sh`, `gpu-lease.sh` and `llama-swap.yaml` read as text, kanban log `t_c4fa298e` and `SUITE_RESULTS_multi_model_2026-10-25.md` read as text. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and unit, and every model were untouched; nothing was acquired, released, or loaded.

**Prior art** printed by `priorart.py` on two phrasings before this file existed (440 records): 0.277 `2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits` (read; the "clear card" state, extended by R3's horizon), 0.193 `2026-10-25-a-foreign-acquire-is-the-only-release-the-planner-latch-gets` (read in full; R1/R2 extended from stranger-sweep to owner-release), 0.109 `2026-10-23-a-scope-record-is-one-cell-written-only-by-attempts-that-reached-the-wrapper` (read in full; R2's mechanism cited, the confirming-branch directive is the increment), 0.095 `2026-10-24-a-silent-release-failure-keeps-the-planner-latch`, 0.072 `2026-10-13-a-confirmation-carries-an-invariant-not-a-pid` (read as the shape of R2). Increment filed = R1's ceiling/duration split with the deleting act as the subject, R2's four-artifact test plus the none→planner warning, R3's ladder-bounded horizon.

**RULINGFILE** `rulings/2026-10-25-the-scoped-cell-is-written-by-a-refusal-and-a-release-deletes-its-own-bid.md`
