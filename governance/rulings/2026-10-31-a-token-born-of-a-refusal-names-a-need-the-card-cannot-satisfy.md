# A token born of a refusal names a need the card it leaves behind cannot satisfy

**Tick:** `2026-10-31 13:18:23 – 13:21 PDT` (`arcade-window-watch`, job `67530e415818`).
**Diff:** `planner_at=planner` **IDENTICAL on both sides** (no flip ⇒ **no @ocho**) · **`kev_window=closed → open`**.
**Bracket:** `(2026-10-31 13:07:51.034, 13:18:23.603]` — previous sample `cron/output/67530e415818/2026-10-31_13-07-51.md`, 5565 B, mtime `13:07:51.034314267` (an agent run, not a `no_change`: it filed `rulings/2026-10-31-a-failed-change-run-leaves-the-transition-only-in-its-own-diff.md`); current sample `monitor_last_output.txt`, **34 B**, mtime `13:18:23.603274299`, sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`, body `planner_at=planner kev_window=open` (the same bytes as every earlier open sample today — a content hash, so a recurring open line collapses to one digest by design).
**Nature:** RECORD ONLY. No acquire, release, load, reservation, unit or config touched. No message to either agent (§6). **No new rule is claimed** — the classes this tick exercises are on file and are cited by path, not re-argued (§7).
**Method:** every figure below is a read taken this tick — `nvidia-smi` (reads at 13:18:26, 13:19:09, 13:19:47/48/49, 13:20:30, 13:21:41), `--query-compute-apps`, `ps -o pid,ppid,lstart,cmd`, `kill -0`, `ss -ltnp`, `curl :8080/running`, `stat %w/%i/%s`, `sha256sum`, `journalctl --user -u ocho-planner-polymarket.service`, `llama-swap.log` tail + mtime, the planner stdout/stderr tail, `/tmp/gpu-lease.*`, `model_cycle_counter.txt`, `arcade_window_watch.sh` (read, not modified). Nothing recalled from a prior tick.

## 1. The live card at write

| read (PDT) | total | used | free | util | temp |
|---|---|---|---|---|---|
| 13:18:26 | 8192 | 2001 | **5891** | 27 % | 43 C |
| 13:19:09 | 8192 | 2023 | **5868** | — | — |
| 13:19:47 / :48 / :49 | 8192 | 2020 / 2019 / 2018 | **5871 / 5873 / 5874** | 28–30 % | 43 C |
| 13:20:30 | 8192 | 2001 | **5891** | — | — |
| 13:21:41 | 8192 | 2001 | **5890** | 27 % | 43 C |

Gate = **4289** (`4033 + 256`, `scripts/arcade_window_watch.sh:12,:47`, re-read this tick; numerically validated so a failed read prints `unknown`) ⇒ **OPEN by 1581–1605 MiB**, stable across six reads.

Compute apps at write: `2424` **1364 MiB** (PrismML Bonsai demo) + `2419` **206 MiB** (Bonsai, bge-small embedding) + `2426` **134 MiB** (LFM2.5-VL vision) = **1704**, all `--n-gpu-layers 0`, all unleased. `used + free = 7891` against `memory.total 8192` ⇒ driver/ctx ~301 MiB. **Nothing resident but the three CPU-offload tenants**: `curl :8080/running` = `{"running":[]}`, and `ss -ltnp` shows only `127.0.0.1:8080` owned by llama-swap `pid 2421` — neither `:5806` nor `:5808` is listening.

`~/.local/state/gpu-lease/` at write: `lease.mutex`, `backups/`, `scopes/planner/record.json` — `lease.d/` **ABSENT**, `scopes/` = **planner only**, `grep -rliE 'arcade|kev|model-test'` **rc 1**. No Kev/arcade lease exists: Llama has taken nothing in this window.

## 2. The open edge, dated

The edge is bounded inside the bracket and pinned to the 13:10 planner round:

| read | value |
|---|---|
| round | `ocho-planner-polymarket.service` journal: `13:10:09 Starting` → `13:10:16 Main process exited, code=exited, status=1/FAILURE` (3.376 s CPU / 6.755 s wall / 143.2 M peak) |
| draw | `[O55] 🎲 Weighted pick: ocho-planner (60% weight, cycle 60740, pool 3/3)` — 60 % rung = the 9B (`owner llama-swap-ocho-planner`, `need_mib 6200`) |
| record written | `scopes/planner/record.json` birth **13:10:15.754893801**, 490 B, `pid 51885`, `mode run`, `need_mib 6200`, `headroom_mib 256`, `expires_at 1793563815` |
| holder | `kill -0 51885` → **DEAD**; absent from `/proc`, absent from `--query-compute-apps` |
| load attempted | **none**: newest `/tmp/gpu-lease.*` capture is still `3w2bou` (1642 B, **13:02:18.096**) and `yVmNGs` (4713 B, 13:02:14.215) — nothing born at 13:10 |
| failure artifact | `llama-swap.log` mtime **13:10:16.076889492**, tail `group: starting ocho-planner failed: aborted` / `status=500` |
| stdout | `[call_ocho_planner] 📡 Calling LLM via llama-swap…` → `[llm] ❌ Request failed: 500 Server Error` → `❌ Failed to get completion` |

**Open edge = 13:10:1x**, i.e. the instant the 9B draw's group swap stopped the resident and its admission was refused. It cannot be second-dated: `llama-swap.log` is timestamp-free, the record is written by the acquiring wrapper ~1 s before the unit exits, and no capture exists because no model load was reached. The card state moves `3226 free / 4666 used` at the 13:04 read → `5891 free / 2001 used` at the first read after the edge; the ~2672 MiB lost is the smol the 13:02 shadow load had left resident.

## 3. The round repeated inside the open gate

Before this report was written the timer fired again, 13:20:08 → 13:20:15 `status=1/FAILURE` (3.392 s CPU / 7.115 s wall / 143.7 M), pick line `cycle 60741`, `llama-swap.log` mtime `13:20:15.436652949`, and the **same single record cell was rewritten**: birth **13:20:15.061656824**, 490 B, sha256 `453b622161d6e4f2f8fd52c58d0118e42c931f2dd2d975c98a1059e06819990f`, `pid 63911` (**dead**), `need_mib 6200`, `acquired_at 1793478015`. `:8080/running` was empty before and after it; no capture, no listener.

So the token that makes `planner_at=planner` true at this sample belongs to a **refusal inside the open window**, not to a holder: the gate opened on one infeasible draw at 13:10 and a second infeasible draw at 13:20 re-armed the same cell while the card stood 1602 MiB above the Kev gate.

## 4. The token is infeasible in the state it describes

Read the record's own numbers against the card read beside it, at 13:21:41:

- `need_mib 6200` vs `free 5890` ⇒ the declared need is **310 MiB above the free card**.
- with its own `headroom_mib 256`: `6456` vs `5890` ⇒ **566 MiB short**.
- the census fixes that ceiling: the 1704 MiB of `-ngl 0` tenants are unleased and unchanged since 13:18, so `used + free` is flat at 7891 and the empty-scope ceiling is `5890 + 0` = **5890** while the 4B rung `4056` needs only `4056` — **1834 spare**.

A dead pid is evidence *after the fact* that a token never became a holder. `need_mib > free` is evidence **in the present** that this token cannot convert in the state it describes: it names a whole-card 9B load on a card the same record's writer emptied and cannot fill, because the failing class is 566 MiB short of a ceiling fixed by tenants it does not control. Both tests agree here; the arithmetic one is available without a `/proc` walk and without waiting for the pid to die.

## 5. What the span it opened from was worth

The 2672 MiB smol that the 13:10 draw stopped had loaded at `13:02:16.86` (capture `3w2bou`, `model loaded` at internal `+1.590 s`) and stood resident until the refusal. The prediction lane shows what it produced: last three rows `20:02:12.428351Z`, `20:02:14.324953Z`, `20:02:18.205395Z` (= **13:02:12 / :14 / :18 PDT**) and **zero rows in `20:10Z`–`20:19Z`**, i.e. **no prediction after 13:02:18 across the ~474 s the rung was resident**. The closed span was occupancy without service; the draw that ended it could not have loaded, and the window that followed has produced nothing at all.

## 6. Messages: none, both premises measured

- **No `@ocho`.** The flip branch never fired — `planner_at` is byte-identical on both sides of the diff. The branch's sentence ("the scoped-planner flip is confirmed live end-to-end") would also be **false at write** on this artifact: the record's pid `63911` is dead, `:8080/running` is `[]`, and no model is resident under any scope. His open item is not closed by this token and is not reopened by a DM: `profiles/ocho/state.db` rows previously read as closed (`id 16736`, `max(id) 17406`) were not re-read as open this tick, and the DM channel drops on `target_busy` with no receipt (`rulings/2026-10-29-a-forecast-is-scored-on-the-counter-and-the-interior-refusals-leave-no-record.md` R5).
- **No `@llama`.** This is the **first sample of this window** (edge 13:10:1x, ~8 min before the sample, less than two rounds old); the fallback clause is for a window that survives several ticks untaken, and he self-authorises at `--scope arcade`. Nothing was preempted: no lease of his exists (`scopes/` planner only, `lease.d/` absent, grep rc 1).

## 7. Cited, not re-derived

`rulings/2026-10-13-a-scope-record-outlives-its-holder.md` (the token is existence-derived) · `rulings/2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits.md` (the fitting state is a **card** state, not a token state) · `rulings/2026-10-27-the-infeasible-pick-opens-the-gate-and-cannot-close-it.md` (R1: a refusal does not close the gate it opened) · `rulings/2026-10-27-the-window-reopens-under-a-record-born-dying-and-the-log-is-the-recurrence.md` (a record born inside a refusal's exit second) · `rulings/2026-10-29-a-latch-the-failing-class-rewrites-every-round-has-no-expiry.md` (the cell is re-armed every round; `expires_at` is unusable) · `rulings/2026-10-29-an-open-edge-and-its-orphan-token-are-one-event.md` (R2: the open edge and the orphan token are one event) · `rulings/2026-10-29-a-token-is-certified-by-the-gate-beside-it.md` · `rulings/2026-10-31-a-failed-change-run-leaves-the-transition-only-in-its-own-diff.md` (R1: an unfiled diff is destroyed at the day boundary — the reason this tick is filed at all).

**The increment, stated narrowly:** §4's test is a **read-side arithmetic** on the record and the card at the same instant, and §3 supplies a second in-window inswriting of the same cell **10.0 min** after the edge — two facts about *this* window, not a new class. Prior art printed before this file existed (`priorart.py rulings`, 529 records, two phrasings): max `REVIEW 0.235 2026-10-29-an-open-edge-and-its-orphan-token-are-one-event`, `weak 0.128 2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits`, `0.127 2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name`, `0.119 2026-10-27-the-ladder-closes-what-its-own-refusal-opened`, `0.105 2026-10-25-a-recycled-pid-makes-a-dead-holder-read-as-never-reclaimable`; the top candidate was read by eye and owns the class.

## 8. Standing flag for Mike (re-measured, not carried)

`~/.hermes/profiles/llama/cron/` still has **no `jobs.json`** — only `.jobs.lock` (0 B, 10-12), `.tick.lock`, `executions.db` 24576 B frozen `2026-10-12 06:33`, `output/` untouched since 10-12 — while `ticker_heartbeat` (23 B) and `ticker_last_success` (17 B) were rewritten at **13:19:22**: a live clock over an **empty job set**. The operator-approved precedence clause therefore still has no executor, and this window (1602 MiB above the Kev gate, 1704 MiB of it unleased `-ngl 0` tenants) has stood open ~11 min with nothing taking it. This watcher creates no jobs; the card fact is not an instruction to stop a tenant (`rulings/2026-10-08-gpu-two-schedulers-live-budget.md` R1/R6).

**Also on disk beside this, not this tick's subject:** `ocho-planner-polymarket.service` failed every round read this tick (`12:10:07`, `12:20:16`, `12:30:14`, `12:40:13`, `12:50:16`, `13:00:19`, `13:10:16`, `13:20:15`), all eight on `status=1/FAILURE` with `llama-swap` answering 500; the stderr log also carries an older `AttributeError: 'Manager' object has no attribute 'loggerDict'` (python3.14 / urllib3 import path) from a run that failed before reaching the model call. Not diagnosed here, not touched.

**Read-only throughout:** `gpu-lease.sh`, `llama-swap.yaml`, `scopes/planner/`, the planner unit and timer, the shadow unit, the three aux tenants, the driver and every model load untouched; no acquire, release, reservation, config edit or job. The 13:10 and 13:20 500s were the timer's own `*:0/10` requests through llama-swap; the 13:02 loads were `ocho-shadow-polymarket.service`'s.
