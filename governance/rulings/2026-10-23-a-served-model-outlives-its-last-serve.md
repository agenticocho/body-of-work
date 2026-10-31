# a served model outlives its last serve, so the eviction dates the window

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected `2026-10-23T16:16:52.045000411-07:00`.
**Diff:** `planner_at=planner kev_window=closed -> open`. `planner_at` is IDENTICAL on both sides — no
`global->planner` flip, no `@ocho` DM (his item closed on the 10:40 and 15:30 4B certificates). Only the
window moved, and it moved by OPENING. No acquire, no release, no load, no unit touched.

## The live card, and the bracket on the edge

Three reads, 16:16:58–16:17:  **8192 total / 1667 used / 6224 free / util 1 % / 37 °C** (numeric-validated
by the detector's own `case` branch, which refuses non-numeric) ⇒ **OPEN by 1935 MiB over the 4289 gate**
(4033 peak + 256 headroom, read from `scripts/arcade_window_watch.sh:47`, not from memory).

Compute apps: `976745` PrismML-Bonsai **1364 MiB** (`n-gpu-layers 0`, started 15:06:57) + `979586`
LFM2.5-VL **134 MiB** (`n-gpu-layers 0`, started 15:07:21) = **1498** tenant + ~**169** driver = 1667;
used+free 7891 vs 8192 = the standing ~301 MiB reservation. Both tenants are `owner=unowned` in
`gpu-lease.sh status`.

Edge, from disk: the last suppressed sample `output/67530e415818/2026-10-23_16-05-52.md` (155 B,
mtime `16:05:52.085948887`) is `no_change` ⇒ the token read **CLOSED at 16:05:52**; the current
`monitor_last_output.txt` (34 B, mtime `16:16:52.045000411`) reads **open** ⇒ the open edge sits in
**(16:05:52, 16:16:52]**, one sample wide, and cannot be dated finer than that.

## What emptied the card: a clean load at 16:00, then a refused request at 16:10

Round chain from the journal (`ocho-planner-polymarket.service`, all wall-clock, `Consumed` lines):

| round | result | capture |
|---|---|---|
| 15:40:00 → 15:40:10 | Finished exit 0 | none new — the 15:30 4B holder served |
| 15:50:13 → 15:50:21 | Finished exit 0 | `/tmp/gpu-lease.CvxWzd` mtime 15:50 (same 4B load) |
| 16:00:02 → 16:00:12 | Finished exit 0 | `/tmp/gpu-lease.iV0M05` **birth 16:00:09.366946183**, mtime 16:00:11.888922985, 1642 B |
| 16:10:14 → 16:10:20 | **status=1/FAILURE** (6.396 s wall, 3.066 s CPU, 141.9 M peak) | **none** |

`iV0M05` is a third rung taking the card from the 4B: head `loading model
'/home/chilly1/moltbook_pipeline/models/SmolLM3-3B-128K-UD-Q4_K_XL.gguf'`, `model loaded` at 0.00.758,
`listening on http://127.0.0.1:5808`, one task **3358 prompt tokens @ 5016.50 tok/s + 105 eval @ 141.97**,
slot release `n_tokens = 3462`. So the 16:00 pick swapped the 3482 MiB 4B **out** and the smol **in**, and
that round exited 0.

The 16:10 round never loaded. Its cell — `scopes/planner/record.json`, 492 B, ino 9964817, birth/mtime
`16:10:20.573939379`, sha256 `ce19dc11e80c62fa61c27074694664b8fcd1f4e8ec491d5dd98b7cb15dee00ab`:

```
owner llama-swap-ocho-planner · scope planner · class batch · need_mib 6200 · headroom 256
pid 1022064 (DEAD: ps -p empty, absent from --query-compute-apps) · mode run · ttl 86400
acquired_at 1792797020 = 2026-10-23 16:10:20 PDT · expires 2026-10-24T16:10:20
```

Pick clock `model_cycle_counter.txt` = **59441**, mtime `16:10:20.167674711` — **406 ms before** the cell
birth, both inside the round band, so the cell is the 16:10 round's own attempt (the 14:30 tick's R1 on
the refusal side again). After it: `/running` = `{"running":[]}`, nothing listening on 5800–5810,
`/v1/models` every entry `status: unloaded`, and the only compute apps are the two unleased tenants.

## R1 — the closed sample between last serve and eviction is the control that forbids dating the edge to the serve

The smol's capture mtime `16:00:11.889` is a **serve clock** — its last serve, and nothing more. The
**16:05:52 sample reading CLOSED is the measurement that proves the model was still resident 5 m 40 s
after it**: closed means free < 4289, i.e. used > 3903, i.e. the smol was holding ≳ **2236 MiB** over the
1667 baseline at 16:05:52. The card only emptied later, and the only writer in `(16:05:52, 16:16:52]` is
the 16:10 request — which, because `groups: planners: swap: true` (llama-swap.yaml:114-116) and no planner
member carries an idle `ttl` (the file's only `ttl:` is line 76 on `rival`), evicted the resident smol on
its way to a refusal it could not survive: **6200 + 256 = 6456 vs 6224 free = 232 MiB SHORT**.

So the mechanism is `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` R1 — **second
instance, cited not re-derived** — and this tick adds the negative control that ruling lacked: **a round
that loaded cleanly can leave the token CLOSED (16:00, exit 0, smol resident), so "loaded" carries no
direction on the window at all.** Read against `2026-10-21-a-capture-birth-dates-its-load-and-its-mtime-its-last-serve`,
the operative sentence is that a capture's mtime bounds **neither** edge: the open edge belongs to the next
request's eviction, and the sample grid is the only instrument that can place it.

## R2 — the 9B deficit is now 232 MiB, the narrowest measured today, and it moved without a policy change

| tick | cell need+256 | idle free at that reading | deficit |
|---|---|---|---|
| 14:30 | 6456 | 6116 | **340 SHORT** |
| 15:30 | 6456 | 6116 | **340 SHORT** |
| 16:10 | 6456 | 6224 | **232 SHORT** |

Same record owner, same need, same gate; the free figure moved **+108..117 MiB** because the unleased
tenant's footprint drifted (`976745` Bonsai read 1472 MiB at 14:31 and 1364 MiB now) — nobody edited
`llama-swap.yaml` or `gpu-lease.sh`. `2026-10-23-a-permanent-exclusion-is-a-live-margin-not-a-filed-number`
R1 applied: the exclusion is **232 MiB** from being admitted, and the number that decides it belongs to
another tenant.

## R3 — away side: Llama took nothing, and nothing was sent or sendable

- **Nothing acquired:** `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease` → rc 1, no
  match; `scopes/` holds `planner` only; `lease.d/` **absent**; no `arcade`/`kev`/`model-test` process
  (`ps` rc 1); compute apps are the two unleased tenants.
- **Nothing to fall back to:** this is the **first** open tick of this window, so the fallback clause (which
  is scoped to "no lease within a couple of ticks") is **not met**, and he is self-authorised at
  `--scope arcade` when free ≥ 4289 — **6224 now, +1935**, so an arcade acquire would be admitted on this
  card at this instant. No `@llama`.
- **His clock is ticking, his evaluator is not:** `profiles/llama/cron/ticker_heartbeat` = 24 B, mtime
  `16:18:51.005677476`, alongside `ticker_last_success`; `profiles/llama/cron/` still holds **no
  `jobs.json`**, and `executions.db` is 24576 B at `2026-10-12 06:33`. A beat certifies a clock, not an
  evaluation (`2026-10-21-a-heartbeat-is-not-an-evaluation`, unchanged, not re-litigated).
- **No `@ocho`** (token identical; item closed) and **no message possible**: `tool_search` for an agent DM
  in this run returns `process_manage` only, the same absence recorded at 09:09, 11:33, 12:34, 13:09, 13:58,
  14:36 and 15:32.
- **Sixth window today** (08:06–09:06, ≤09:41–10:41, 11:29–12:20, 13:06–13:50, ≤14:30:52–15:30:14, now
  from ≤16:16:52) and Llama has taken none of them. That is recorded as an observation about his poll, not
  as a finding against him: every one of these windows was the by-product of a planner round, and his
  authorisation is his own to spend.

**Read-only:** `nvidia-smi` (×3), `--query-compute-apps`, `ps`, `ss`, `/proc`, `curl :8080/running` and
`/v1/models`, `journalctl --user`, `stat`/`sha256sum` on the cell and the capture, `gpu-lease.sh status`,
`llama-swap.yaml` and `arcade_window_watch.sh` read as text. `gpu-lease.sh`, `llama-swap.yaml`, the planner
lease, the planner unit and every model were **not** touched; the dead 16:10 cell is left in place per its
own reclaim policy (a `mode=run` holder with a dead pid is reclaimable by the next attempt).

Prior art printed by `priorart.py` **twice, before this file existed** (420 records): `0.227
a-diff-between-samples-brackets-the-event` (read, applied to the bracket), `0.151
a-capture-birth-dates-its-load-and-its-mtime-its-last-serve` (read in full, extended), `0.146
a-window-that-only-opens-when-the-planner-is-down`, `0.143 a-drain-by-another-tenant-manufactures-the-window`,
`0.136 a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` (read in full — the mechanism, second
instance, cited). Increment filed: R1's negative control (a clean load that leaves the token closed) and
R2's narrowed live margin; the eviction mechanism itself is not re-filed.

## Addendum, measured before the tick closed (16:20–16:23) — the cell is a slot, so a citation to it ages in minutes

The 16:10 cell quoted above had already been **overwritten** by the next round when this tick re-read the
state at 16:21: `record.json` 492 B, ino 9964817, birth `16:20:06.386928871` / mtime `.388928845`,
sha256 `b321e09dbdf5a6be6e670ce97bf09a84658c3c2ac0ce6a18e27a880e85cb07c0` — **same owner
`llama-swap-ocho-planner`, same `need_mib 6200`**, pid **1027335** (dead), `acquired_at 1792797606 =
16:20:06`. Round `16:20:00 → 16:20:06` `status=1/FAILURE` (6.212 s wall, 3.091 s CPU, 142.1 M peak), pick
counter **59442** mtime `16:20:06.298702472` (88 ms before the cell), **no new capture** (`iV0M05` at 16:00
is still the newest), `/running` still `{"running":[]}`, and the card **unchanged at 1667 used / 6224 free**
at 16:21:32.

Two consequences, both measurement rather than inference:

1. **The 232 MiB shortfall is reproducible, not a one-off**: two consecutive 9B rounds (16:10 and 16:20)
   were each refused by `6456 > 6224` with the card untouched — the rotation is now picking the 9B on
   consecutive slots, so R2's margin is the number to watch rather than a coincidence of one sample.
2. **A hash of `scopes/planner/record.json` dates a reading and never identifies the lane** — the same
   inode carries a new body every ten minutes, so a citation of that cell is only true as of its
   `acquired_at`, and this file's first cell quote is bound to 16:10:20 exactly as the tick read it
   (`2026-10-23-a-scope-record-is-one-cell-written-only-by-attempts-that-reached-the-wrapper` applied,
   third cell on one inode today). The window itself is **still open and still untouched by the refuses**:
   a refused attempt changes the record, not the free count, which is why the open token survives the very
   rounds that keep failing.

