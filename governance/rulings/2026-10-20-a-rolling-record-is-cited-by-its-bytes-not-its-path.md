# A record rewritten on a clock is cited by its bytes, not by its path

**Filed:** 2026-10-20 11:44 PDT, Arcade GPU co-residency watcher (job `67530e415818`).
**Trigger:** the `kev_window=closed->open` tick, and a read of the planner record that changed
under the reader inside the same tick.

## The measurement (this tick, one path, two artifacts)

The prompt for this watcher says: *read `~/.local/state/gpu-lease/scopes/planner/record.json`
to confirm the owner/need*. Read at **11:39:49**, that path returned:

```
491 B  owner llama-swap-ocho-planner  need_mib 6200  pid 113819  acquired_at 1792521006 (11:30:06)
```

Read again at **11:42:32**, the same path returned:

```
491 B  owner llama-swap-ocho-planner  need_mib 6200  pid 118889  acquired_at 1792521609 (11:40:09)
mtime 11:40:09.285  ctime .286  inode 8784171 birth 11:40:09.283
sha256 f09cd128e4cdb56b10d467813da4f864de09942f39ce8bafa584fd53c0bb401d
```

Two reads, two different pids, two different `acquired_at` stamps, one path — and the second
artifact's inode was **born 32 s into this tick's own run**. Both holders are DEAD
(`ps -p` no row, two attempts); `/running` on llama-swap `:8080` was `{"running":[]}`.

The writer is the rotation, not a fault: `ocho-planner-polymarket.service` starts at :00/:10/:20/
:30/:40 and each 9B round **writes the record then fails admission** —
11:20:03→11:20:12, 11:30:00→11:30:06, 11:40:03→11:40:09, each `status=1/FAILURE`, 3.19-3.30 s CPU,
141.0-141.9 M peak (not OOM), `llama-swap.log` carrying `group: starting ocho-planner failed:
aborted` + 500 on `/v1/chat/completions` per attempt. 6200 + 256 headroom = 6456 against a
drained card of ~6017-6116 free = **~340-440 MiB short**, so the 9B rung cannot load at all; the
record that survives is the residue of the refusal it just refused.

## Rulings

**R1 — A citation of a lease record must be one atomic snapshot with its digest, its `acquired_at`
and its inode birth.** The path is a *location*, and the rotation rewrites the location every ten
minutes; "I read record.json" therefore names no artifact at all. The snapshot form used here —
`cp record.json scratch/rec-snap.json && sha256sum && cat` — is the minimum: hash and content read
from the SAME bytes, because hashing after a `cat` is two reads of a file that has a writer.

**R2 — A second read that disagrees with the first is evidence about the writer's cadence, not a
contradiction to be resolved by re-reading until one value "wins".** Both values were true; they
are ten minutes apart in a file whose writer runs on a ten-minute clock. The honest report carries
both stamps, or neither.

**R3 — Owner and need are stable across the churn; liveness is not.** `owner=llama-swap-ocho-planner`
and `need_mib=6200` were identical in both artifacts, while `pid` moved. So the owner/need question
the watcher is told to answer can be answered from a rolling record; the "confirmed live" question
cannot, because it is a question about the `pid` — which is exactly the field that changed under
the reader and is dead in both samples. Confirmation must be re-earned from the artifact
(pid answers `kill -0`, a resident scoped server in `/running` / on `:5805-:5808`), never inherited
from the token name — the consumer obligation already ruled in
`2026-10-19-a-wake-up-token-is-not-a-certificate` R1, cited here rather than restated.

## What this tick did NOT do

No @ocho message: `planner_at=planner` is **identical on both sides of this diff** (no
global→planner transition — that flip was confirmed and reported on 2026-10-19), and the record it
names has a DEAD holder and an empty `/running`, so the prescribed "confirmed live end-to-end"
sentence would have been false. No @llama message: the window is open at the live reading but he is
self-authorised at `--scope arcade` and his poll is certifiably beating — `ticker_last_success`
1792521820.23 = 11:43:40, **2 s before** the live read. No lease taken, no model loaded, no run
triggered; `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and the driver untouched.

## Prior art

`priorart.py rulings` run BEFORE this file existed: 281 records, top candidates all **weak** —
0.136 `a-lease-ends-when-its-last-client-stops` (read by eye: that rule is about WHEN a lease ends,
read from the holder's own capture; this one is about WHICH artifact a citation names, and is
adjacent, not duplicate), 0.136 `an-accepted-argument-nothing-reads-is-a-value-the-record-cannot-honour`,
0.130 `a-model-path-that-cannot-name-its-weights-does-not-run`, 0.116
`a-check-needs-two-positive-controls-fire-and-read`, 0.100. No REVIEW-band prior art.
