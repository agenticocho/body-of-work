# A rise in free VRAM inside a swap group is evidence of a request, not a release

**Date:** 2026-10-23 09:41:57–09:45 PDT · tick `arcade-window-watch`, job `67530e415818` (samples 09:19:52 and 09:30:52 suppressed `no_change`; `monitor_last_output.txt` mtime 09:41)
**Diff:** `kev_window=closed → open` · `planner_at=planner` **IDENTICAL both sides** → no flip, no `@ocho` DM
**Nature:** RECORD ONLY. No acquire, no release, no model load, no unit touched, no message. Llama is self-authorized at `--scope arcade` when free ≥ 4289 and self-runs; this tick does not preempt his poll.
**Method:** every number is a read taken this tick — `nvidia-smi` twice, `--query-compute-apps`, `ss -ltnp`, `curl :8080/running`, `curl :8080/v1/models`, the lease tree (`cat`, `stat --printf` incl. `%w`/`%y`, `sha256sum`), `ps -p`, `journalctl --user -o short-iso`, `/tmp/gpu-lease.*` births, and **`llama-swap.yaml` read as the writer's own policy**. Nothing is recalled from a prior tick.

## 1. Live card at write

```
09:41:57  8192 MiB total / 1784 used / 6107 free / util 2 % / 38 C
09:44:0x  8192 MiB total / 1784 used / 6107 free / util 1 % / 38 C
```

Compute apps: **2360 = 1472 MiB** (`PrismML-Bonsai … Ternary-Bonsai-2-9B`, `--n-gpu-layers 0`, unleased) + **72233 = 134 MiB** (`LFM2.5-VL-1.6B`, `--n-gpu-layers 0`, unleased) = **1606 MiB of tenant**; 1784 − 1606 = **178 MiB** driver/context. Free **6107** vs the gate **4289** ⇒ **open by 1818 MiB**, card idle.

The open token is TRUE this time, not an existence artifact: `/v1/models` lists **all ten** llama-swap entries — brain, critic1, critic2, critic3, helper, ocho-planner, **ocho-planner-4b**, ocho-planner-ornith35, **ocho-planner-smol**, proposer — `status: unloaded`; `/running` = `{"running":[]}`; `ss -ltnp` shows **nothing listening on 5800–5810** (only llama-swap itself on 8080). Nothing of llama-swap's is resident.

`scopes/planner/record.json`: **491 B**, ino **9965165**, birth **09:40:11.340979109**, mtime **.341979100**, sha256 **`468747fc3b543615b642ea15d9287d1bf6306061fcabda4a074a80559ffe2341`**, `owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 headroom_mib=256 pid=800083 mode=run acquired_at=1792773611 (09:40:11) expires_at=1792860011 (2026-10-24T09:40:11)`.

**pid 800083 is DEAD** — `ps -o pid,ppid,etime,cmd -p 800083` returns header only, rc=1, and 800083 is absent from `--query-compute-apps`. And the record's own admission test refuses it: **6200 + 256 = 6456 vs free 6107 = 349 MiB short**, exactly the standing 9B refusal. So `planner_at=planner` is again a token over a body that is not there (`2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name` R2 applied, not re-filed).

## 2. The edge, bounded from disk

| stamp (PDT) | artifact | reading |
|---|---|---|
| 09:30:10 | journal `ocho-planner-polymarket.service` **Finished**, exit 0, 8.827 s wall | round succeeded |
| 09:30:52 | `cron/output/67530e415818/2026-10-23_09-30-52.md` = `no_change`, i.e. still `closed` | **last closed sample** |
| 09:30 | `/tmp/gpu-lease.SnHwt6` birth, 1642 B, `loading … SmolLM3-3B-128K-UD-Q4_K_XL.gguf`, `model loaded` +0.739 s, `listening on http://127.0.0.1:5808`, one task served (2833 tok @ 5065 tok/s) | the **smol** rung was the resident planner |
| 09:40:05 → 09:40:11 | journal `Starting` → `Main process exited, code=exited, status=1/FAILURE` (6.151 s wall, 3.062 s CPU, 141.6 M peak) | **9B round fails** |
| 09:40:11.34 | `record.json` birth, owner `llama-swap-ocho-planner`, need 6200, dead pid | the failing round's own write |
| — | **no `/tmp/gpu-lease.*` born at 09:40** (newest is 09:30 `SnHwt6`) | the 9B request never wrapped a load |
| 09:41 | `monitor_last_output.txt` = `open` | **first open sample** |

Closed at the 09:30:52 sample, open at 09:41, and the only planner actor inside that band is the 09:40 round that failed. Its victim is the smol rung: smol's server is gone from `ps`, from 5808, and from `/v1/models`.

## 3. The increment over 2026-10-21-a-failed-swap-evicts-before-it-refuses

That ruling measured the same mechanism once (13:10:06, 9B request evicted a resident smol, then aborted) and left a **boundary**: *"Not measured: whether the smol was evicted by the 9B request or by a client-driven swap (llama-swap's own log is not on this box at a readable path)."* This tick closes that boundary **without needing the log's timestamps**, by reading the writer's policy:

- `models:` has **no idle `ttl` anywhere** — the file's only `ttl:` key is line 76, on `rival` (300 s), a model that is not in the `planners` group at all. No global `ttl` key exists (top-level keys are `healthCheckTimeout`, `models`, `groups`).
- `groups: planners: swap: true, members: [ocho-planner, ocho-planner-4b, ocho-planner-smol, ocho-planner-ornith35]` (comment on the same block: *"Only one planner resident at a time (VRAM)"*).

So **llama-swap has no idle-unload path for any planner rung**: a planner member can only leave when another member's request swaps it out. The smol did not time out. And I did find the log — `/home/chilly1/chilly_containment/logs/llama-swap.log`, 23.7 MB — but its event lines carry **no timestamps**, so it can confirm *what* (`group: starting ocho-planner failed: aborted`, interleaved with 500s and `ocho-planner-4b` / `ocho-planner-smol` health passes) and never *when*. The config is what excludes the alternative; the log only corroborates the abort.

## 4. Rules

**R1 — To exclude a mechanism, read the writer's own policy; a missing timestamp is not a missing proof.** The question "did the holder leave on its own or was it evicted?" is answerable from `ttl` presence alone: no idle timer on any member ⇒ the only unload path is a swap request. This is cheaper and stronger than hunting a timestamp in a log that does not have one, and it generalises: before attributing an edge by difference, check whether the writer's configuration admits the alternative at all.

**R2 — A rise in free VRAM inside a `swap: true` group is evidence of a REQUEST, not of a release.** The 08:06 edge and this one have the same shape — 6107 free, 1784 used, idle card, same record owner, dead pid — and the same cause class: an infeasible 9B attempt landing on a resident member. Two measured instances in one morning on a 10-minute timer is enough to stop calling these windows "capacity": **the window is a duty-cycle artifact of a failing lane**, which is why a `closed` reading is the norm and an `open` reading needs a reason (`2026-10-21-a-threshold-crossed-by-a-schedule-is-a-duty-cycle-not-a-window` applied).

**R3 — Price the window against the writers that will reclaim it, not against the gate alone.** Kev-4B is 4033 MiB; admitted here it leaves **6107 − 4033 = 2074 MiB**, against planner needs of **6456 (9B)**, **4056 (4B)**, **3000 (smol)** — every planner rung would then be refused, and each refusal is the same swap-before-refuse path that empties the card again. So the acquisition this window admits is exactly the one that starves the lane which produced it, and the next 9B round at :50 will evict nothing (no member resident) and fail on the lease instead. Stated as arithmetic only: precedence between the arcade lane and the planner lane is the operator's standing clause, not this watcher's call, and nothing was acquired.

## 5. Absentees and messages

**Llama took nothing.** `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease/` → rc 1, no match; `scopes/` = planner only; `lease.d/` absent; no `kev`/`arcade`/`model-test` process. This is his **second** open window today (08:06–09:06 ≈ 60 min, and from ~09:40), so the fallback condition ("open across a couple of ticks with no `llama-model-test` lease") is now factually met — and **no message was sent**, for three reasons measured this tick: (a) this run's toolset exposes **no agent-messaging tool** (`tool_search` for an agent DM returns no matches — the same finding as 09:09); (b) `profiles/llama/cron/` has **no `jobs.json`** (`executions.db` 24576 B, mtime 2026-10-12 06:33, empty `output/`) while `ticker_heartbeat` moves at 09:43 — a beat certifies a clock, not an evaluation (`2026-10-21-a-heartbeat-is-not-an-evaluation` applied), so there is no scheduler here to consume a DM; (c) he is authorised to acquire and this tick's window is a byproduct of a failure, not an operator instruction. The absence is recorded as absence of artifacts, not as proof that no raw load ran.

**No `@ocho`.** `planner_at` is identical on both sides — no `global → planner` branch — and his scoped-planner item stays closed; the record's owner is the 9B group, whose holder is dead, so there is nothing to certify to him.

## 6. Read-only

Nothing acquired, released, loaded, or edited. `gpu-lease.sh`, `llama-swap.yaml` (read only, twice), the planner lease and the planner service are as found; `record.json` was read and left in place (its own policy calls a dead-pid `mode=run` holder reclaimable, so leaving it blocks nothing).

**Prior art** (`priorart.py`, 408 records, run **before** this file existed, read by eye): `2026-10-21-a-failed-swap-evicts-before-it-refuses` 0.115 — **same mechanism, parent, second instance and its stated boundary closed**; `2026-10-14-a-window-opened-by-a-failed-load` 0.187 (parent, no resident to evict); `2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name` 0.164 (R2 arithmetic applied); `2026-10-22-a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed` 0.135 (the mirror edge); `2026-10-21-a-threshold-crossed-by-a-schedule-is-a-duty-cycle-not-a-window` (applied in R2); `2026-10-21-a-heartbeat-is-not-an-evaluation` (applied in §5). The increment filed is R1's method (exclude an alternative from the writer's configuration) plus the second measurement that narrows the Oct 21 boundary — not a re-derivation of the eviction mechanism itself.
