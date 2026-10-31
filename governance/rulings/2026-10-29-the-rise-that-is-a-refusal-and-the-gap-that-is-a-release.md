# The rise that is a refusal, and the gap that is a release

**Tick:** cron job `67530e415818` (Arcade GPU co-residency watcher), change detected at the
`08:05:20.088` sample (`monitor_state.last_changed_at`), previous sample `07:54:35` (run
`output/67530e415818/2026-10-29_07-54-35.md`, 6,238 B). Bracket `(07:54:35, 08:05:20.088]`.
**Diff:** `planner_at none -> planner` · `kev_window=open` on **both** sides (no Kev edge; no
`@llama` branch).

```
previous   planner_at=none      kev_window=open
current    planner_at=planner   kev_window=open     <- this tick
```

## What the flip actually is: a refused 9B acquire, dated to 2 ms

| read (instant) | value |
|---|---|
| `scopes/planner/record.json` (08:05:26) | 490 B, ino `8785873`, **birth `08:00:17.679802322`**, mtime `.681802138`, sha256 `5b898d1886c59bfc651e93d9e240aa5d5fe9f917c108dbe161088575c9d6ee2b` |
| its body | owner `llama-swap-ocho-planner`, scope `planner`, class `batch`, need_mib **6200**, headroom 256, mode `run`, pid **23496**, `acquired_at` 1793286017 = **08:00:17**, `expires_at` 1793372417, ttl 86400 |
| holder liveness (08:05:26, re-read 08:13) | `/proc/23496` **ABSENT**; no `ps` row; never in `--query-compute-apps` |
| resident compute apps (08:07:5x ×3 identical) | pid 2347 Bonsai 9B **1364 MiB** + pid 2349 LFM2.5-VL **134 MiB**, both `--n-gpu-layers 0`; **no 9B**, no 5806/5808 listener, `:8080/running` -> `{"running":[]}` |
| round journal | `08:00:09 Starting ocho-planner-polymarket.service` -> `08:00:18 Main process exited, code=exited, status=1/FAILURE` (3.745 s CPU / 8.475 s wall / **143.1 M peak**) |
| pick | `[O55] Weighted pick: ocho-planner (60% weight, cycle 60341, pool 3/3)`; counter file `60342` mtime `08:00:17.569928694` = post-increment |
| `llama-swap.log` (mtime 08:00) | `[WARN] non-200 response ... status=500` + `[WARN] group: starting ocho-planner failed: aborted` |
| capture | `ls /tmp/gpu-lease.*` -> **no match** (a load writes one; the boot cleared `/tmp` at 07:42 and nothing has been written since) |
| card (08:07:5x ×3) | 8192 total / **1667 used / 6224 free** / 6-11 % / 40 C |

Admission: `need_mib 6200 + headroom 256 = 6456` against **6224 free** = **232 MiB SHORT** on an
already-empty card (ceiling `8192 - 1498 aux - ~300 driver`). So all three depths Ocho adopted as
binding (`state.db` id 9267: record + holder liveness + resident compute app, never the record alone)
read **false**: record yes, pid dead, no resident app, and the round's own exit status `1/FAILURE`.

**The rise is manufactured by the refusal, and it repeated 10 minutes later.** Measured inside this
tick with a 5 s sampler on the record path:

```
08:09:52.910  PRESENT ino=8785873 size=490 birth=2026-10-29 08:00:17.679802322
08:10:17.964  PRESENT ino=8784112 size=490 birth=2026-10-29 08:10:13.761533817
```

The new file is the 08:10 round: journal `08:10:07 Starting` -> `08:10:14 status=1/FAILURE`
(3.751 s CPU / 6.545 s wall / **143.4 M**), pick **60342 = the 60 % 9B** (counter `60343` mtime
`08:10:13.664590876`), pid **31354** — dead at 08:13:06, `/running` still `[]`, free still **6224**.
Three consecutive 9B draws (60340 at 07:50, 60341 at 08:00, 60342 at 08:10) and **three refusals**;
the token rose once and was refreshed once, and neither event loaded anything.

## The gap in this diff is a RELEASE, not a sampler artefact

`gpu-lease.sh:319` writes `mv -f "$tmp" "$dir/record.json"` (atomic replace, inode changes, the path
is **never** absent) and `:627` is `trap 'do_release_quiet ...' EXIT` (the path **does** go absent when
the wrapper exits). Both paths are visible in this tick: the 08:10 refresh changed the inode
(`8785873` -> `8784112`) with **no absent sample at 5 s granularity**, while the `none` in this diff is
a genuine absence — at `07:54:35` the 07:50 record (pid 16384, dead) had already been released and the
next acquire did not bind until `08:00:17.68`. So the previous sample's `none` and this sample's
`planner` bracket a **release followed by a fresh refusal**, not a release followed by a load.

## RULINGS

**R1 — A PRESENCE TOKEN HAS TWO PRODUCERS FOR ITS RISE, AND IN THIS CONFIG THE REFUSAL ONE FIRES.**
`planner_at=planner` is `[ -f record.json ]` (`arcade_window_watch.sh:29-35`). A rise therefore
announces *a writer ran*; the writer runs **before** admission and its record survives the refusal
(`take_lease` writes, then the wrapped load fails). While `need_mib 6200 + 256 = 6456` exceeds this
card's empty ceiling (6224-6394 MiB), **every 9B draw manufactures a rise** — at the fixed 6:3:1
weights, ~6 rises/hour, none of them loads. Any instruction of the form "`planner_at` `none→planner`
means CONFIRMED LIVE, now message X" is a 60 %-per-round false certification by construction and must
be keyed to the holder (`/proc` + resident compute app + the round's exit status), never to the token.
(Extends `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` R1 and its 10-20
recurrence; the increment here is the **rate**: the failure is not an occasional early fire but the
steady-state producer of the token's rises on this card.)

**R2 — THE TOKEN'S DUTY CYCLE IS THE WRAPPER'S LIFETIME, SO "PINNED" AND "SAWTOOTH" ARE THE SAME
OBJECT AT DIFFERENT PHASES.** Release-on-EXIT plus atomic `mv -f` refresh means the path is present
for the whole wrapper lifetime and absent only between a release and the next acquire. A 10-minute
sample therefore reports `planner` over **both** a live holder and a dead-pid orphan, and reports
`none` only when a release lands between acquires. Consequences, each measured today: (a) a `none→
planner` diff cannot distinguish a first acquire after a release (this tick) from an orphan refreshed
in place (the 08:10 event); (b) the `2026-10-23` "pinned token" reading of a permanently-refreshed
cell and today's "sawtooth" reading are not competing mechanisms — the cell is refreshed per round and
released when the wrapper exits, and which face the sampler sees is a race between a ~10 min round
cadence, the wrapper's exit, and a ~10 min sample period. Neither face certifies a holder, so no
sampling rate rescues the token: the discriminator is the three-read test, not more samples.

**R3 — A FORECAST THAT NAMES A *STANDING* RECORD IS WRONG ABOUT THE MECHANISM EVEN WHEN ITS SHAPE
HOLDS.** The `07:47` tick pre-registered "NEXT TICK EXPECTS A FALSE `planner`: the 07:50:12 record
stands over a DEAD pid". The shape held — this rise is a refusal — but the named record was **released
before 07:54:35**, so the rise this tick reports came from a **new** refusal (08:00:17, pid 23496), not
from the standing one. Displaying a refusal loop as a persistent record is the error R2 prices; a
forecast about it must name the **round** (pick cycle + timer phase), not the file.

## Actions taken

- **No `@ocho` message.** The prescribed sentence is "the scoped-planner flip is confirmed live end-to-end
  with the record's owner and need" — false on three reads (dead pid, no resident app, exit 1). His open
  item is closed in **his own rows**, re-read this tick: `profiles/ocho/state.db` (mtime 07:42, untouched
  since boot) ids **9249** (user, 2026-10-13 17:49:44) / **9267** (his adoption of the three-read rule) /
  **16736** (2026-10-25 14:27:49, "the item is closed"), `max(id)=17405`, unchanged. A DM would reopen a
  closed item with a false certification into a channel that drops on `target_busy` and has no read
  receipt.
- **No `@llama` message.** `kev_window` did not move this diff; free 6224 is **+1935** over the 4289 gate
  but the window opened at the 07:42 boot, not here; he self-authorises at `--scope arcade` and this
  watcher does not preempt his poll. DM path re-measured **ABSENT** (`tool_search`, two phrasings ->
  0 matches; connected sources only browser / computer_use / session_search / terminal / todo).
- **No acquire, release, load, reservation, unit or config touched.** `gpu-lease.sh`, `llama-swap.yaml`,
  `scopes/planner/`, the planner unit, both aux tenants and the driver were read-only throughout. The
  08:00 and 08:10 loads were the timer's own requests through llama-swap.

## Standing flag for the operator (re-measured, not new)

The planner has served **nothing** since the 07:42 boot: three consecutive 9B draws refused
(07:50 / 08:00 / 08:10), 25 of 37 rounds `status=1/FAILURE` since 02:00, and the reason is arithmetic —
`need_mib 6200 + 256 = 6456` against an empty-card ceiling of 6224-6394 MiB leaves it **232-343 MiB
short of any card this box can offer**, so no sample-level change can ever admit it and only a config
change can (`2026-10-27-the-majority-pick-cannot-fit-so-the-open-gate-is-the-steady-state` R2,
re-measured; class cited, not re-argued). This watcher creates no jobs and touches no config.

## Prior art

`priorart.py rulings` on two phrasings **before** this file existed (515 records):
`0.164 2026-10-25-a-recycled-pid-makes-a-dead-holder-read-as-never-reclaimable` (read in full — about the
reclaim predicate on a *recycled number*, not about what a rise means), `0.156
2026-10-27-the-refusal-that-reopens-the-window-and-the-empty-card-it-leaves` (the refusal opens the window;
here the refusal manufactures the *token*), `0.140 2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`,
`0.104 2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`, `0.099 2026-10-13-a-scope-record-outlives-its-holder`,
`0.115 2026-10-21-a-falsifier-keyed-to-a-clock-cannot-distinguish-a-second-loader`. Class cited not re-filed:
`2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` (R1 here extends it with the rate),
`2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name` (whose pinned-token reading R2
reconcilies rather than contradicts), `2026-10-29-a-post-boot-gap-closes-on-a-fitting-draw-not-a-clock`
(whose 07:47 forecast R3 scores). No record states that the refusal is the steady-state *producer* of the
token's rises, or that release-on-EXIT plus atomic refresh makes the token's gaps a race.
