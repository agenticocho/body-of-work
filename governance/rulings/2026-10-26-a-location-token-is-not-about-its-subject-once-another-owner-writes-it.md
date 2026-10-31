# A location token is not about its subject once another owner can write the path

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected 2026-10-26T13:54:08.8 PDT.
**Diff:** `planner_at=planner -> global` **and** `kev_window=open -> closed`, both inside the bracket
`(13:43:08, 13:54:08]` (lower bound: the last suppressed sample `cron/output/67530e415818/2026-10-26_13-43-08.md`,
155 B, `no_change`, carrying `planner_at=planner kev_window=open`; upper bound: `monitor_last_output.txt`,
written 13:54:08.8).

Both edges are dated by their own writers, and they are **not** one instant:

| edge | instant | artifact |
|---|---|---|
| planner's scoped cell released | **13:47:24.397107744** | `~/.local/state/gpu-lease/scopes` mtime; the cell is deleted on release, so the directory stamp is the only mark it leaves (`ls -A` -> 0 files) |
| whole-card lease taken | **13:48:07.871717793** | birth of `~/.local/state/gpu-lease/lease.d/record.json`, 484 B, ino 3411587, sha256 `a210ad80b098d445435830f64170174ad8afae1bbcbe5567ef107a9005a7f3de` |

## R1 — The token is now produced by an owner that is not its subject

`planner_at` is derived from file existence (`scripts/arcade_window_watch.sh:31-35`):

```
planner -> scopes/planner/record.json exists
global  -> else, lease.d/record.json exists
none    -> neither
```

Its documented meaning for `global` is *"still on the pre-flip whole-card lease"*. This tick that
sentence is **false**, and every field needed to see why is in the record:

```
owner=ocho-window-t_925f606f  scope="" (global)  class=batch  need_mib=3600
pid=3182731  mode=run  acquired_at=1793047687 (13:48:07)
expires_at=1793069287 (19:48:07)  ttl=21600  headroom_mib=256
```

- the pid is **alive** and its command is a GPU-lease-wrapped benchmark run:
  `bash gpu-lease.sh run --owner ocho-window-t_925f606f --class batch --need-mib 3600 --ttl 21600 --
  python3 -u suite/suite3.py --cabinet mastermind,lightsout,chess,labyrinth,snake,sokoban,zork --entrant all`;
- the run's own window log states its grant verbatim: `lease GRANTED (held) — owner=ocho-window-t_925f606f
  scope=(global) class=batch need=3600MiB ttl=21600s mode=run ... ADMITTED — 6102 MiB free >= 3856 MiB needed`;
- the planner holds **nothing**: `scopes/` is empty, so there is no planner cell, no planner pid, no
  `need_mib 3800` or `6200` bid anywhere on disk.

So the transition `planner -> global` here is not "the planner went back to a whole-card lease". It is
"the planner's scoped cell was released at 13:47:24 and, 43 s later, **a different process class took the
whole card under an owner name the token does not print**". A watcher reading `global` as a statement
about the planner is now reading a path, not its subject: any owner with a legitimate claim may write
`lease.d/record.json`, so the same token value covers "planner on the pre-flip lease" (the case it was
written for) and "planner shut out by an unrelated batch holder" (this case). The token cannot
distinguish them, and the two call for opposite conclusions.

**Rule.** A location token is only about its subject while its subject is the *only* writer of that
path. Before acting on a bare `global`, read the record's `owner` and `pid` and report them beside the
token: `planner_at=global:ocho-window-t` and `planner_at=global:planner` are different states, and only
the second is the state the branch was written for. Where the owner is not the planner, the correct
reading of `planner_at=global` is *"the card is held by someone else"* — a fact about occupancy, not about
the planner's lease mode. A watcher whose branch list was written against the pre-flip topology must
treat an unexpected owner as **unclassifiable**, not as the nearest branch
(`2026-10-25-an-unclassifiable-transition-is-not-its-nearest-branch`).

## R2 — Inside a batch holder's run the gate opens only between that holder's loads

`kev_window` samples free VRAM instantaneously (`arcade_window_watch.sh:39-48`; numeric-validated, so a
failed `nvidia-smi` prints `unknown`). Within this one window run, twelve consecutive reads at 4 s spacing
(13:57:45 → 13:58:29) all returned:

```
7395 MiB used / 497 MiB free / 88-100 % util
```

with a single 5600 MiB entrant `llama-server` (pid 3191917) beside the aux floor (Bonsai 1466 +
LFM2.5-VL 134 + Hermes 8 = 1608 MiB). Two earlier reads inside the *same* run returned **5965 free**
(13:54:14) and **3525 free** (13:56:5x, 97 % util), and the suite's own rows record
`card_max_mib` **4569** (mastermind/ministral-3b), **7063** (mastermind/ornith-9b), **7273**
(mastermind/mimo-9b). The card therefore swings ~5.5 GiB **across the 4289 gate inside one window run**.

**Rule.** `kev_window=open` is a statement about one sampling instant, so it is only evidence of a
co-residency *opportunity* when nothing else is loading. Against a live whole-card batch holder, an
`open` sample is the **gap between two of that holder's own loads** — the holder's duty cycle, not the
card's availability. An away-side self-authorised acquire that fires on such a gap competes with a
holder the lease explicitly will not reclaim (record policy verbatim: *"a mode=run holder whose pid is
ALIVE is never reclaimable at any age, regardless of expires_at"*), and the next entrant load displaces
or fails it. The measurable signature to quote is the pair — *free VRAM now* **and** *the holder's
observed peak* (`card_max_mib`, or the resident app size) — because the gap and the peak are one
distribution and quoting either alone inverts the conclusion.

## R3 — The casualty is the planner, and the token moves to `global` exactly when its subject stops using the card

Two planner rounds inside this band failed against the new holder:

```
ocho-planner-polymarket.service  13:40:05 Starting -> status=1/FAILURE 13:40:11
ocho-planner-polymarket.service  13:50:07 Starting -> status=1/FAILURE 13:50:13
```

`chilly_containment/agents/ocho/logs/ocho_planner_polymarket.log` ends
`[llm] Request failed: 500 Server Error: Internal Server Error for url: http://localhost:8080/v1/chat/completions`,
and `chilly_containment/logs/llama-swap.log` carries `[WARN] group: starting ocho-planner failed: aborted`
(5.912 s wall / 3.194 s CPU / 142.3 M peak — a refusal, not an OOM). So the release the token reports as
`planner_at=global` coincides with the planner becoming **unservable**, which is the opposite of what the
`global` value was defined to mean. A watcher that reports this token without the owner will eventually
report "the planner is back on the whole-card lease" during the exact interval the planner draws are
failing — a false-positive in the reassuring direction, which is the harder kind to notice.

**Rule.** Report the release instant (directory mtime) and the new owner's birth instant as **two**
facts; never collapse them into one edge. Where the new owner is not the planner, the pair to state is
"planner's cell released at T1; the card was taken by <owner> at T2", because the width between them is
the only interval in which the card belonged to nobody.

## Action taken

NONE on hardware. No lease acquired or released, no model loaded, no unit or config touched; `gpu-lease.sh`,
`llama-swap.yaml`, the planner lease, the Ocho window lease and every model were read-only.

**No `@ocho`:** the only message-carrying branch is `global -> planner`, and this diff is its inverse; his
scoped-planner item was closed on the 2026-10-23 10:40 live-4B certificate and stays closed in HIS rows
(`2026-10-14-the-closure-is-in-the-recipients-row`), so a true-but-redundant DM into a closed item is the
drop-hazard class.

**No `@llama`:** this is a CLOSE edge — 497 MiB free on twelve consecutive reads, 3792 MiB under the gate —
so a page would assert a window already false at write and still false at receipt
(`2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` R1); he self-authorises at
`--scope arcade` under the operator precedence clause, and this watcher does not trigger runs. Independently,
this cron toolset has **no agent-DM tool at all** (`tool_search "send message to another agent profile dm"`
-> 0 matches), which is itself a fact a watcher prompt should stop pretending otherwise about.

**Away side, measured not assumed:** `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1
NO MATCH; `ls -A scopes | wc -l` -> 0; `pgrep -af 'kev_run|arcade_|model-test'` self-match only;
`ss -ltnp` = `127.0.0.1:8080` llama-swap 2357 only, nothing on 5800-5829. Llama took nothing — with the
standing caveat that scope records are deleted on release, so this is the absence of an artifact, not
proof that no raw load ran.

## Prior art (printed before this file existed)

`priorart · 488 records in rulings`, two phrasings:

- *a lease-location token cannot report who holds the lease* — max **REVIEW 0.264**
  `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`, then weak 0.100
  `2026-10-14-a-certified-lease-is-not-certified-work`, 0.098
  `2026-10-22-a-solve-rate-cannot-report-a-false-success`.
- *a window sampled between another holder's loads is not a co-residency window* — weak 0.186
  `2026-10-12-arcade-window-blink-refuted-by-live-read`, 0.178
  `2026-10-24-a-window-can-be-closed-between-rounds-by-another-client`, 0.147
  `2026-10-14-a-drain-by-another-tenant-manufactures-the-window`.

The 10-19 record was read in full and is **extended**: its rules qualify a *cell* by the holder it names
(record + `/proc` + resident app) and cover a token firing early on a dead holder and never firing late on
a live one. Its subject is always `scopes/planner`. Nothing in it covers a **foreign owner occupying the
global path**, so the `planner -> global` direction had no rule at all — its `global` value was treated as
unambiguously about the planner. The 10-24 record was read in full and is **distinguished**: it owns a
window *closed* by a client the timer does not own; this is a window *manufactured* between another
client's loads, and the client in question is the lease holder rather than a co-tenant. `grep -rlE
'ocho-window|window-t_' rulings` -> NO MATCH, i.e. a non-planner owner holding the whole-card lease is new
to the record.

**What would overturn this:** a `planner_at=global` sample whose `lease.d/record.json` names a
`llama-swap-ocho-planner*` owner (then the old meaning holds and the token is merely under-qualified), or a
`kev_window=open` sample inside a batch run at which a co-resident model was admitted and survived the
holder's next entrant load (then the gap is a real opportunity).
