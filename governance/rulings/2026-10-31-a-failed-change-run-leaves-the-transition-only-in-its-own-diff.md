# A failed change run leaves the transition only in its own diff — and a swap group closes the gate twice in 50 s

**Date:** 2026-10-31 13:04:26–13:10 PDT · tick `arcade-window-watch`, job `67530e415818` (sample `monitor_last_output.txt` 36 B mtime `13:04:23.209725470`, sha256 `b391e197…145820b1`, body `planner_at=planner kev_window=closed`; previous rows `2026-10-31_12-42-22.md` and `_12-53-23.md` both 155 B `no_change`)
**Diff:** `kev_window open → closed` · `planner_at=planner` **IDENTICAL both sides** → no flip branch, no `@ocho` DM
**Nature:** RECORD ONLY. No acquire, no release, no model load, no unit touched, no message. Llama is self-authorized at `--scope arcade` when free ≥ 4289 and self-runs; this tick does not preempt his poll.
**Method:** every number is a read taken this tick — `nvidia-smi`, `--query-compute-apps`, `ss -ltnp`, `curl :8080/running`, the lease tree (`cat`, `stat -c %s/%i/%w/%y`, `sha256sum`), `ps -o pid,ppid,lstart`, `journalctl -o short-iso`, `/tmp/gpu-lease.*` births and bodies, and the cron job's own output directory (`cron/output/67530e415818/`, 50 files dated today) counted by report class. Nothing is recalled from a prior tick.

## 1. Live card at write

```
13:04:26  8192 MiB total / 4666 used / 3226 free
```

**CLOSED by 1063 MiB** under the 4289 gate (`4033 + 256`). Compute apps: `2424` PrismML-Bonsai **1364** + `2419` PrismML-Bonsai **206** + `2426` llama-server **134** (all `-ngl 0`, unleased tenants) + `42871` llama-server **2672** = **4376**; `used+free 7892` ⇒ **292 MiB** driver/context. Ceiling with the scope empty is `3226 + 2672 = 5898` ⇒ the 9B's `6200 + 256 = 6456` is **558 short in this state**, as on every prior state of this card.

The holder is real, not an existence token. `scopes/planner/record.json` **495 B**, ino **9233518**, birth **`13:02:15.170191639`**, mtime `.171191632`, sha256 **`29121d3a…64eafcd3`**, `owner=llama-swap-ocho-planner-smol`, `scope=planner`, `class=batch`, `need_mib=3000`, `headroom_mib=256`, `pid=42776`, `mode=run`, `acquired_at=1793476935` (**13:02:15**), `expires_at=1793563335` (2026-11-01 12:02:15), `ttl=86400`. Wrapper **42776** alive (`ppid 2421` = llama-swap, started `12:21:37`, cmd `gpu-lease.sh run --owner llama-swap-ocho-planner-smol … --port 5808 … SmolLM3-3B-128K-UD-Q4_K_XL.gguf`), child **42871** alive **2672 MiB** `LISTEN 127.0.0.1:5808`, `:8080/running` = `ocho-planner-smol state=ready`, `:5806` no listener.

So `planner_at=planner` **has a live referent this tick** — the three-way read (pid alive + resident in `--query-compute-apps` + `/running state=ready`) that `2026-10-29-an-open-edge-and-its-orphan-token-are-one-event` R2 named as the only positive flip evidence. It is **not a flip** (identical on both sides), so no DM goes out; §5.

## 2. The edge, dated from disk — the gate closed **twice**, 50 s apart

| stamp (PDT) | artifact | reading |
|---|---|---|
| 12:40:07→12:40:13 | journal `ocho-planner-polymarket.service` `status=1/FAILURE` (6.555 s wall, 143.9 M) | 9B round refused |
| 12:50:09→12:50:16 | same, `status=1/FAILURE` (6.852 s, 143.9 M) | 9B refused |
| 12:53:23 | `2026-10-31_12-53-23.md` 155 B `no_change` | **last sample reading the window open** |
| 13:00:12→13:00:19 | 9B round `status=1/FAILURE` (6.700 s, 143.1 M) | 9B refused |
| 13:00:12 → 13:02:18 | `ocho-shadow-polymarket.service` `Starting` → `Finished` exit 0 (2 min 5.888 s wall, 153.4 M) | the unit whose per-market calls drove the swaps below |
| **13:01:24.929** | `/tmp/gpu-lease.yVmNGs` **4713 B** birth, `loading … Qwen3.5-4B-UD-Q4_K_XL.gguf`, `model loaded` **+2.195 s**, `listening :5806` | **4B load → `13:01:27.12` = FIRST CLOSE** (`4056 + 256` fits in ~6198 free) |
| 13:02:14.215 | same file mtime = last log line (task 4182 slot release) | 4B **stopped** by the group swap |
| 13:02:15.170 | `record.json` birth, owner `…-planner-smol`, need 3000, pid 42776 | lease re-written for the smol |
| **13:02:15.266** | `/tmp/gpu-lease.3w2bou` **1642 B** birth, `loading … SmolLM3-3B…gguf`, `model loaded` **+1.590 s** | **`13:02:16.86` = SECOND CLOSE**, the one the record names |
| 13:04:26 | `nvidia-smi` 4666 used / 3226 free | **closed**, §1 |

Between the 4B's stop and the smol's `model loaded` the card stood at **2.65 s** (`13:02:14.215 → 13:02:16.86`) with only the 1704 MiB tenant set resident, i.e. ~6198 free — **above the gate**. A 10-minute sampler can never sample that interval, and by construction it is not a window: `2026-10-23-a-rise-in-free-vram-inside-a-swap-group-is-evidence-of-a-request` R1 already fixed the direction (a rise in free VRAM inside a swap group is evidence of a **request**, not a release), and this tick is its mirror — a **fall** then rise then fall inside one group is one swap of two members, not two Kev windows. Nothing can act in 2.65 s and nothing did.

The two models are both `planners`-group members (`Qwen3.5-4B` on `:5806`, `SmolLM3-3B` on `:5808`), so the card crossed the 4289 gate **twice in 50 s**, and only the **second** crossing survives in `record.json`. That is the same single-slot property `2026-10-29-a-forecast-is-scored-on-the-counter-and-the-interior-refusals-leave-no-record` R3 measured for refusals, now measured for **loads**: the record names the last acquirer, never the first.

## 3. The day's coverage: twelve change runs, twelve provider failures, zero rulings

The job's own output directory holds **50 files dated 2026-10-31**: **37** `no_change` (155 B), **12** `FAILED` (~4.2 KB, prompt + diff + traceback), **1** zero-byte (`_12-21-49.md`). Every one of the twelve failures is the same string:

```
RuntimeError: Hermes can't reach the model provider. You may be offline.
```

| change run | diff it captured |
|---|---|
| 03:24:41 | `closed → open` |
| 04:23:50 | `open → closed` |
| 05:01:37 | `closed → open` |
| 06:00:44 | `open → closed` |
| 06:38:46 | `closed → open` |
| 07:05:44 | `open → closed` |
| 07:21:35 | `closed → open` |
| 08:20:42 | `open → closed` |
| 08:58:42 | `closed → open` |
| 09:58:53 | `open → closed` |
| 10:36:41 | `closed → open` |
| 11:35:42 | `open → closed` |

`rulings/` contains **no record dated 2026-10-30 or 2026-10-31** — the last filed ruling is `2026-10-29-a-latch-the-failing-class-rewrites-every-round-has-no-expiry` (19:17). So the whole of today's gate traffic survives **only inside the failure reports' diffs**, and the directory is pruned at the day boundary (today's 50 files are the only ones present, oldest `_02-57-43`), which means the diffs are the only durable trace and they expire with the directory.

The twice-observed pair is the load-bearing detail: **11:35:42** already captured `open → closed` for exactly the pair this tick captured again at **13:04:23**, 89 minutes apart, with no committed record in between — and §2's ledger shows the card was genuinely **open** in between (the 4B did not load until `13:01:24.929`). So the repeat is not a flapping card and not a duplicate to be deduped; it is a comparison value that did not advance across a failed run. The diffs are evidence of **what was read at that instant**, never of how long the reading stood.

## 4. Rulings

**R1 — A watcher's day is audited by report CLASS, not by sample count, because a failed change run persists its diff and nothing else.** Twelve of today's fifty runs were change runs and all twelve died in the agent layer (`RuntimeError: Hermes can't reach the model provider`); the monitor still wrote the diff into the run report, so the transitions are recoverable, but no ruling, no INDEX row, and no delivery exist for any of them. The directory's two classes are separable by size alone — 155 B `no_change` rows versus ~4.2 KB `FAILED` rows — so `grep -l FAILED` over the day's files is the coverage measurement, and "37 samples arrived" says nothing about whether any transition was recorded. Corollary: because the directory is pruned daily, an unfiled diff is destroyed at midnight, so a watcher's ledger must be brought current by the next run rather than "next time there is something to report".

**R2 — One swap group can close the gate twice in a minute, and the lease record keeps only the second closure.** `Qwen3.5-4B` loaded at `13:01:27.12` (capture `yVmNGs` birth `13:01:24.929`, `model loaded +2.195 s`) closing the gate that had been open since at least 12:53; llama-swap stopped it at `13:02:14.215` and loaded `SmolLM3-3B` at `13:02:16.86` (capture `3w2bou`, `+1.590 s`), closing it again. `record.json` carries **only the smol** — 495 B, birth `13:02:15.17` — so the first closure is datable **only** from the /tmp captures. Durable form: when the record's `owner` is a member of a multi-member group and two captures are born inside the same minute, the **first** capture birth + its `model loaded` is the edge, and the record names the last acquirer (extends `2026-10-29-the-closing-value-can-be-the-shadow-runs-own-draw-and-the-record-names-the-holder-after-it` R2 from "the closer's token is destroyed 8 s later" to "the first closer is never in the record at all").

**R3 — The 2.65-s rise between a swap's stop and start is a request, not a window, and it is invisible to every sampler on this job.** `13:02:14.215 → 13:02:16.86` with ~6198 free is above the 4289 gate by ~1909 MiB, yet it is the interior of one group swap driven by `ocho-shadow-polymarket.service` (active `13:00:12 → 13:02:18`, finished 0), and the next member's load is what ends it. Under a 10-minute poll such an interval is unobservable by construction; if it were ever sampled it would read as a Kev window opened and would then be "closed" by a load that is part of the same event. Applies `2026-10-23-a-rise-in-free-vram-inside-a-swap-group-is-evidence-of-a-request` R1 in the opposite direction and fixes the scoring: an open sample that no consumer can act on and that is followed within seconds by the next member's load is not an edge to log.

## 5. Messages — none, both premises measured

**No `@ocho`.** `planner_at` is identical on both sides, so the `global → planner` branch never fired. The positive evidence that branch exists to certify — wrapper `42776` alive, `42871` resident 2672 MiB on `:5808`, `/running state=ready` — is filed here instead of DM'd, because his item is closed in **his own** rows: `sqlite3 -readonly profiles/ocho/state.db` → `max(id)=17406`, `count(*)=17406`, db mtime `12:21` today (live, not frozen), and a DM re-opens a closed item into a channel that drops on `target_busy` with no receipt (`2026-10-29-a-forecast-is-scored-on-the-counter-and-the-interior-refusals-leave-no-record` R5). A transport channel is not an archive.

**No `@llama`.** This is a **close** edge: live free 3226 is 1063 MiB the wrong way, the window is gone at write, his authorisation is `free ≥ 4289` at `--scope arcade`, and the fallback condition (a window untaken across several ticks) is a condition on an **open** card. Away side absent by artifact: `find ~/.local/state/gpu-lease` shows `scopes/planner` only, no `lease.d/`, and nothing matching `arcade|kev|model-test` exists in the tree.

## 6. Standing flag for Mike, re-measured 13:04

- **Coverage failure, today:** 12 change detections (03:24 → 11:35) all died with `Hermes can't reach the model provider`; the gate flipped across them and **no ruling was filed for any of the 12**. No ruling at all since 2026-10-29 19:17.
- **Standing flag, re-measured:** `profiles/llama/cron/` still carries a live `ticker_heartbeat` (22 B, rewritten `13:04`) over an **empty job set** — `jobs.json` absent in that profile — so the operator-approved precedence clause has no executor on his side; this tick's gate was held closed by the planner group, and the ~2 h the card spent open earlier today was taken by nothing. Execution fact, not a Kev decision; this watcher creates no jobs.
- **Arithmetic, not an instruction:** the unleased `-ngl 0` set (**1704 MiB**: 1364 + 206 + 134) fixes the empty-scope ceiling at **5898**, against the 9B's **6456** — the 60 %-weight rung is **558 short in every state of this card**, so each 9B draw refuses after evicting, which is what opens these windows (`2026-10-29-a-latch-the-failing-class-rewrites-every-round-has-no-expiry` R2, third instance). A fact about the card, **not** an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6).

**Read-only throughout:** `gpu-lease.sh`, `llama-swap.yaml`, `scopes/planner/`, the planner/shadow units and timers, all four compute processes, the driver and any model load untouched; no acquire, release, reservation, config edit or job. The `13:01:27` 4B load and the `13:02:16` smol load were `ocho-shadow-polymarket.service`'s own requests through llama-swap. `record.json` was read and left in place (its holder's pid is alive, so nothing is reclaimable).

**Prior art** (`priorart.py rulings`, **528 records**, run **before** this file existed, read by eye): `0.189 2026-10-23-a-rise-in-free-vram-inside-a-swap-group-is-evidence-of-a-request` (read; R3 applies it in the mirror direction), `0.109 2026-10-27-the-ladder-closes-what-its-own-refusal-opened`, `0.113 2026-10-08-liveness-predicate-implemented-models-wrapped`; plus `2026-10-29-an-open-edge-and-its-orphan-token-are-one-event` R2 (positive-flip evidence named, applied in §1/§5), `2026-10-29-a-forecast-is-scored-on-the-counter-and-the-interior-refusals-leave-no-record` R3/R5 (single-slot record; DM-into-closed-item), `2026-10-29-the-closing-value-can-be-the-shadow-runs-own-draw-and-the-record-names-the-holder-after-it` R2 (extended by R2), `2026-10-29-a-latch-the-failing-class-rewrites-every-round-has-no-expiry` R2 (third instance). None states that a **failed** change run persists its transition only as a diff inside its own failure report, and none states that one group swap closes the same gate twice with only the second reaching the lease record.
