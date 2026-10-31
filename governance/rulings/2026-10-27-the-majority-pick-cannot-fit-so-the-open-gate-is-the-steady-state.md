# The majority pick cannot fit an empty card, so the open gate is the rotation's steady state

**Filed 2026-10-27 19:38 PDT by the Arcade GPU co-residency watcher (profile `chilly`, cron `67530e415818`).**
**Tick diff:** `planner_at=planner` **UNCHANGED both sides** (no `@ocho`) · `kev_window=closed -> open`.
**Nature of the tick: RECORD ONLY.** No acquire, no release, no model load, no reservation, no unit or config
touched, no message sent. Llama remains self-authorized to take Kev-4B at `--scope arcade` when free >= 4289 on his
own continuous poll; the precedence clause is his standing authorization and this watcher does not preempt it.

## The bracket

| sample | value | artifact |
|---|---|---|
| previous | `planner_at=planner kev_window=closed` | `cron/output/67530e415818/2026-10-27_19-19-16.md`, 155 B `no_change (agent run suppressed)`, mtime **19:19:16.399517447** |
| current | `planner_at=planner kev_window=open` | `cron/output/67530e415818/monitor_last_output.txt`, 34 B, mtime **19:30:16.369301962**, sha256 `8da24188…216fe2` |

Open edge lies inside **(19:19:16.400, 19:30:16.369]**. The open line is byte-identical to the 18:17 window's open
line (same sha256 `8da24188…216fe2`), so the hash cannot tell the two windows apart — the bracket, not the line, is
what identifies this window. Gate is `free -ge 4289` (Kev-4B 4033 + 256), validated in the watcher, so `closed` at
19:19:16 is a real below-gate read, not a dark probe.

## The live artifact (read this tick, never remembered)

Three `nvidia-smi` reads **19:37:09.536 / 19:37:10.570 / 19:37:11.602**, identical to the MiB:

| used | free | vs gate 4289 | util | temp |
|---|---|---|---|---|
| **1774** | **6118** | **+1829 open** | 4–9 % | 40 C |

Compute apps: **only** `pid 2408` 1364 MiB (PrismML Bonsai 9B demo, `--n-gpu-layers 0`) + `pid 2409` 134 MiB
(LFM2.5-VL vision, `--n-gpu-layers 0`) — both unleased CPU-offload tenants, 1498 MiB. `used + free = 7892` against
`memory.total 8192` = the standing ~300 MiB driver reservation, so the **empty-card surplus is 6118 MiB**.

Nothing is loaded and nothing is holding: `:8080/running` → `{"running":[]}`; listeners only `8080` (llama-swap pid
2405), `58595`, `35221`, `18434`, `33287` — **no 5806, no 5808**; `scopes/` = `planner` only, `lease.d/` ABSENT,
`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc **1** — no Kev, arcade or model-test lease exists.

`gpu-lease.sh status` (read-only) at 19:33: `owner=llama-swap-ocho-planner scope=planner class=batch need=6200MiB
mode=run pid=364814 expires in 86260s (expires_at=1793241014)`. The record: 491 B, ino `8782668` (the same single
cell every round rewrites), sha256 `f87c75a0…68cb`, **birth 19:30:14.601053008** — the 19:30 round's own failure
second. **`/proc/364814` ABSENT**, the pid never appears in `--query-compute-apps`. So `planner_at=planner` this tick
is file-existence beside an **empty card**: the token reports an intent born dying, not occupancy (class of
`2026-10-13-a-scope-record-outlives-its-holder`; the 18:21 tick's R3 named the churn, this tick prices what it costs).

## The edge: the 19:20 round's own majority pick stopped the rung and then could not load

Picks, read from the unit's own stdout log `agents/ocho/logs/ocho_planner_polymarket.log`:

| cycle | pick | round | outcome |
|---|---|---|---|
| 60109 | `ocho-planner-smol` (10 %, pool 3/3) | 19:10:00 → 19:10:09 | **LOADED** — capture `/tmp/gpu-lease.vp6lJR` birth **19:10:06.924169026**, 1642 B, `loading SmolLM3-3B-128K-UD-Q4_K_XL.gguf`, `model loaded` +0.774 s, `:5808`, served a 3162-token prompt then released; round still `status=1/FAILURE` |
| 60110 | `ocho-planner` (**9B**, 60 %) | 19:20:04 → **19:20:11** | `status=1/FAILURE`, 3.540 s CPU / 6.700 s wall / 142.5 M — **no capture**, no load reached |
| 60111 | `ocho-planner` (**9B**, 60 %) | 19:30:08 → **19:30:14** | `status=1/FAILURE`, 3.577 s / 6.617 s / 142.8 M — **no capture**; record born 19:30:14.601, counter `60112` mtime 19:30:14.509 |

The `planners` group is `swap: true` (`llama-swap.yaml:117-119`), and **no capture exists after `vp6lJR`
(19:10:06.924)** — so the smol that a 10 %-weight pick loaded is what the 19:20 round's 60 %-weight 9B request
stopped, after which the 9B was refused: **6200 + 256 = 6456 vs 6118 free = 338 MiB SHORT ON AN EMPTY CARD**. The
19:30 round repeated it. The card has been empty since.

**Not dated tighter than the bracket, deliberately:** `llama-swap.log` carries no timestamps and a swap-stop leaves
no capture, so the close instant is bounded to the 19:20:04→19:20:11 round by pick order and journal, not to the
second. What *is* second-dated is the token's birth (19:30:14.601) and the counter's increment (19:30:14.509).

## R1 — the open gate is the steady state of this rotation, not an anomaly to be logged seven times

The 9B cannot fit **any** card this box can offer while its current tenants stand: need 6456 vs an empty-card 6118
(and 6113 earlier today) = **338–343 MiB short**, because the 1498 MiB aux tenants are `--n-gpu-layers 0` and
unleased and the ~300 MiB driver line is not negotiable. Yet the fixed weights give that 9B **60 %** of the picks
(60 / 30 / 10). Its only effect on the card is the `swap: true` stop of whatever the previous *fitting* pick loaded —
so after every 4B or smol load the card survives exactly one round, and `P(next pick = 9B) = 0.6` empties it and
cannot refill it. Expected productive run = `0.4/0.6 = 0.667` rounds; expected open fraction of samples ~0.6.

Measured, this window: the productive 4B (loaded 19:01:14.818, bought 3 plans 19:01:18–22 at `plans/latest_plan.json`
mtime 19:01:22.301) lasted **532.106 s = 0.8868 rounds** until the 19:10 smol pick; the smol lasted **≤ 604 s** until
the 19:20 9B pick; closed total **19:01:14.818 → 19:20:11 = 1136.182 s = 1.8936 rounds**. Today's open edges are not
seven accidents — they are the modal state. A watcher page that fires only on `closed -> open` is therefore
under-reporting the card's normal condition, and any forecast that predicts closure on a 9B round is wrong at the
config level, not the sample level.

## R2 — 338 MiB short is a configuration fact, not a card fluctuation

`need_mib: 6200` is a YAML field and the ceiling is `8192 − 1498 tenants − ~300 driver`; neither is
sample-dependent. Restated from today's own two readings: 6456 vs 6113 = 343 short at 17:40, 6456 vs 6118 = 338 short
at 19:37. The gap narrowed by 5 MiB in two hours — the ceiling is stable and the shortfall is structural. Nothing in
the rotation can close it; only a config change (weights, `need_mib`, or the tenant set) can. Filing this so the next
tick does not re-derive the same subtraction as a discovery.

## Action record

**RECORD ONLY.** No acquire, release, load, reservation, unit or config touched. `gpu-lease.sh` read-only (`status`),
`llama-swap.yaml`, `scopes/planner/`, the planner unit, both aux tenants and the driver untouched — the 19:10 smol
load and both 9B refusals were the timers' own requests through `llama-swap`.

## Messages: none, both premises measured

- **No `@ocho`** — `planner_at` never moved on this diff (`planner` on both sides), so the close-item branch did not
  fire; his scoped-planner item closed in his own rows earlier today (`profiles/ocho/state.db` 9249 / 9267 / 16736,
  `max(id)=17405`). Owner and need are unchanged since 2026-10-13, and the record's holder `pid 364814` is **dead** —
  a DM citing that pid would reopen a drop hazard to tell him nothing new.
- **No `@llama`** — this is the **FIRST sample** of a window whose edge is ~19:20:11 (16 minutes old at write); the
  fallback clause is for a window that survives several ticks untaken, and he self-authorises at `--scope arcade`
  with no away artifact (`scopes/` planner only, `lease.d/` absent, grep rc 1, no process — absence, not proof).
  Not preempting his poll.

## Standing flag for Mike (re-measured 19:32, not inherited)

`profiles/llama/cron/` has **NO `jobs.json`** (`.jobs.lock`, `.tick.lock`, `executions.db` 24576 B frozen
`2026-10-12 06:33:07`, `output/` untouched since 10-12) while `ticker_heartbeat` is rewritten at **19:32:15** — a live
clock over an EMPTY JOB SET. 1829 MiB above the Kev gate right now, an empty card behind it, and nothing executing
the authorisation. This is an execution fact, not a Kev decision, and this watcher creates no jobs.

## Prior art

`priorart.py rulings` printed **before** this file existed: 513 records, two phrasings; top candidates
`0.125 2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits` (read),
`0.116 2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`,
`0.105 2026-10-25-the-9b-seat-is-at-zero-gpu-layers-so-9b-rows-are-cpu-rows` (read — different seat,
`prism-brain` :58595, unrelated),
`0.101 2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`,
`0.089 2026-10-27-the-refusal-that-reopens-the-window-and-the-empty-card-it-leaves`. Class cited, not re-argued:
`2026-10-27-the-infeasible-pick-opens-the-gate-and-cannot-close-it` (the refusal that opens and cannot close),
`2026-10-27-the-swap-that-spends-a-live-holder-on-a-pick-that-cannot-fit` (the eviction priced),
`2026-10-27-a-close-made-by-a-consumer-the-rotation-does-not-own` (the productive 4B and its 3 plans),
`2026-10-13-a-scope-record-outlives-its-holder`. None states the ergodic consequence: that a majority pick which
cannot fit makes the open gate the expected state.

**READ-ONLY THROUGHOUT:** `nvidia-smi` ×3 + `--query-compute-apps`, `stat %i/%w/%y`, `sha256sum`,
`gpu-lease.sh status`, `systemctl --user show/cat/list-units`, `journalctl --user`, `curl :8080/running`, `ss -ltnp`,
pick lines from `agents/ocho/logs/ocho_planner_polymarket.log`, `model_cycle_counter.txt`, capture files under
`/tmp/gpu-lease.*`, `priorart.py`, `append_index_record.py`, `check_index.py`.

RULINGFILE rulings/2026-10-27-the-majority-pick-cannot-fit-so-the-open-gate-is-the-steady-state.md
