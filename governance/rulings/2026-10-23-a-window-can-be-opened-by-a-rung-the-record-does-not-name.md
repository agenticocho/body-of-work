# A window can be opened by a rung the record does not name

**Date:** 2026-10-23 · tick `arcade-window-watch`, job `67530e415818` (monitor runs 07:55:52 and 08:06:52 PDT; reads 08:06:58–08:09:56 PDT)
**Diff:** `kev_window=closed → open` · `planner_at=planner` **IDENTICAL both sides** → no flip, no `@ocho` DM
**Nature:** RECORD ONLY. No acquire, no release, no model load, no message. Llama is self-authorized at `--scope arcade` when free ≥ 4289 and self-runs; this tick does not preempt his poll.
**Method:** every number below is a read taken this tick — `nvidia-smi` (six timed reads), `--query-compute-apps`, the lease tree on disk (`record.json`, `stat`, `sha256sum`), `ps` / `pidof`, `curl :8080/running` (three reads), `/dev/tcp` probe of 5800–5810, `llama-swap.log`, `journalctl --user -o short-iso`, `/tmp/gpu-lease.*` captures, `sqlite3 -readonly` on Ocho's rows. Nothing is recalled from a prior tick.

## 1. What changed, measured

```
previous   planner_at=planner  kev_window=closed
current    planner_at=planner  kev_window=open     <- this tick
```

The open edge lies inside **(07:55:52, 08:06:52.112]**: the previous tick wrote a suppressed `no_change` artifact (`cron/output/67530e415818/2026-10-23_07-55-52.md`), the current one is `monitor_last_output.txt` mtime **08:06:52.112025041**. The gate is `free -ge 4289` (Kev-4B 4033 + 256 headroom), numerically validated inside the watcher (`case "$free" in ''|*[!0-9]*) unknown`), so `closed` at 07:55:52 means free was genuinely below the gate — **used > 3903 MiB** — not a dark probe.

Live card, four identical reads:

| read | total | used | free | util | temp |
|---|---|---|---|---|---|
| 08:08:29 / :31 / :33 | 8192 | 1784 | **6107** | — | — |
| 08:09:53.216 | 8192 | 1784 | **6107** | 1 % | 38 C |
| 08:09:54.252 | 8192 | 1784 | **6107** | 2 % | 38 C |
| 08:09:55.288 / :56.319 | 8192 | 1784 | **6107** | 1 % | 38 C |

`--query-compute-apps`: **2360 → 1472 MiB** (`PrismML-Bonsai … Ternary-Bonsai-2-9B`, `--n-gpu-layers 0`, unleased) + **72233 → 134 MiB** (`LFM2.5-VL-1.6B`, `--n-gpu-layers 0`, unleased) = **1606 MiB of tenant**. 1784 − 1606 = **178 MiB** of driver/context; used+free = 7892 = the ~300 MiB reservation. Free **6107** vs the gate **4289** ⇒ **open by 1818 MiB**, and the card is idle (util 1–2 %, 38 C).

## 2. What opened the window: a rung the record does not name

The record on disk **now** describes the *9B* planner rung, and it was born at **08:00:12**, i.e. three minutes *after* the previous tick already read `closed`. So the record cannot be the thing that released the memory:

- `scopes/planner/record.json` — **491 B**, ino **9965165**, birth **1792767612 = 08:00:12**, mtime `.616166147`, sha256 **`c5b5abfdc3036eabae65c60b3f86806ffe89e605c44fbd2f91c56433ec155cf1`**, `owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 headroom_mib=256 pid=749469 mode=run ttl=86400 expires_at=1792854012 (2026-10-24 08:00:12)`. The mutex `lease.mutex` mtime `.598166339` is 18 ms earlier and the `scopes/` parent dir mtime is 08:00 — this is a fresh acquire of the 9B group (`llama-swap.yaml:80`, `Qwen3.5-9B-UD-Q4_K_XL`, `--need-mib 6200`) replacing whatever was there.
- **pid 749469 is DEAD.** `ps -o pid,ppid,lstart,cmd -p 749469` → header only, **rc=1**; 749469 does not appear in `--query-compute-apps`.
- **`/running` = `[]`** on three reads (08:07, 08:08, 08:09), and **no listener on 5800–5810** (all eleven `/dev/tcp` probes refused).
- **No `/tmp/gpu-lease.*` capture was born at 08:00.** The newest capture is `/tmp/gpu-lease.VZoEPz`, mtime **07:50**, and it is a *load*: `loading model '…SmolLM3-3B-128K-UD-Q4_K_XL.gguf'`, `model loaded`, `listening on http://127.0.0.1:5808`, then a served task (prompt eval 2838 tok @ 5098.49 tok/s, eval 125 tok @ 143.92 tok/s). The wrapper writes its capture at `do_run:631`, immediately after `do_acquire`; the record exists but no capture does, so **this acquire died in the same second, before or around exec** — the state the record certifies is an attempt, not a load. (Which of the two it is, this tick cannot date: `TMPDIR` is inherited, and `do_run:658` deletes the capture on a clean exit.)
- `journalctl --user`, 07:55–08:10: `Starting ocho-planner-polymarket.service` **08:00:05**, `Main process exited, code=exited, status=1/FAILURE` **08:00:12**, 7.432 s wall, 3.074 s CPU, 141.6 M peak → the round that acquired at 08:00:12 is the round that failed at 08:00:12. `llama-swap.log` carries **392** `group: starting ocho-planner failed: aborted` lines across its life, interleaved with 500s and the `ocho-planner-4b` / `ocho-planner-smol` health passes.

The memory was freed by a **different rung of the same lane**. At 07:55:52 the card was `used > 3903`; the two long-lived tenants are unchanged (`etime` 22:34:11 and 20:51:50, i.e. both started 2026-10-22 and neither could have appeared between the ticks), so an **extra tenant of ≥ 2100 MiB** was resident then and is absent now — and the only load on the card in the recent window is the **SmolLM3-3B / `:5808` / `ocho-planner-smol`** capture at 07:50. Stated as the inference it is: the opener is the smol rung's exit, measured by difference because the exit itself is not timestamped anywhere llama-swap writes.

## 3. The token is false twice over — liveness, and now arithmetic

`planner_at=planner` is an existence test on the record file (`arcade_window_watch.sh:29`). Against this record it fails the three-read test Ocho adopted as binding in his own rows (`profiles/ocho/state.db` id 9267: *"a scoped lease is confirmed by the record, the holder's liveness, AND a resident compute app; never by the record alone"*): record **yes**, liveness **no** (pid 749469 dead), resident app **no** (`/running` `[]`, nothing on 5800–5810). So no flip is certified and no `@ocho` DM is owed — his item was also re-read **closed in his own rows** (`max(id)=16551` unchanged; 9249 = the user item, 9267 = his assistant adoption).

The new falsifier is cheaper than a pid hunt: **apply the lease's own admission test to its own record.** Admission is `need_mib + headroom_mib` against measured free (the standing 9B refusal is documented as `6200 + 256 = 6456` against `6268`). This reading: **6456 vs 6107 = 349 MiB short**. The record's declared need cannot be admitted on the card it claims this second, so the record cannot be describing an occupant — one `nvidia-smi` read refutes the token without touching `ps`. Corollary that matters operationally: the same free number that makes this window Kev-eligible (**+1818** vs 4289) makes the token's claim impossible (**−349** vs 6456). A wide card is evidence about *which rung was resident*, never evidence that the scope is empty.

## 3b. AMENDED at 08:11 — the record is refreshed by the failing round, so the token can never fall back

The filing above was written at 08:10:12 on a record born 08:00:12 with pid 749469 dead. Between writing it and the final read, the **same twenty-minute cycle produced a second sample**, and it is the stronger one:

| sample | record birth | pid | liveness | sha256 | free at the read |
|---|---|---|---|---|---|
| 1 | 08:00:12 | 749469 | **DEAD** (`ps` rc 1) | `c5b5abfdc303…` | 6107 |
| 2 | **08:10:12.771665816** | **756015** | **DEAD** (`ps` rc 1) | **`1bdd9386e208e040ae9ffd4153e001e987898248a2040405f9aec3e2b9adf4f5`** | 6107 |

Same owner (`llama-swap-ocho-planner`), same `need_mib=6200`, same `mode=run`, same 24 h TTL, a new pid, and the journal dates it to the second: `Starting ocho-planner-polymarket.service` **08:10:07**, `status=1/FAILURE` **08:10:13** (5.599 s wall, 3.068 s CPU, 160.3 M peak) — mirroring 08:00:05 → 08:00:12 (7.432 s, 3.074 s, 141.6 M). `/running` still `[]`, free still **6107**, no new capture.

The producer is a **10-minute timer round that fails and re-acquires every time**: `Starting ocho-planner-polymarket.service` at 06:30:13, 06:40:00, 06:50:03, 07:00:07, 07:10:03, 07:20:03, 07:30:11, 07:40:14, 07:50:00, 08:00:05, 08:10:07, with `status=1/FAILURE` on 06:30:19, 07:10:10, 07:20:09, 07:50:09, 08:00:12, 08:10:13. Because `do_acquire` writes the record *before* the wrapped model is exec'd and the round dies before the EXIT trap can remove it, **every failing round leaves a fresh record with a dead pid, ~10 minutes apart**.

That changes the consequence from "a stale record" to **"a pinned token"**: `planner_at` reads `planner` because the file exists, and the file is refreshed by a producer that never loads anything, so the token has no reachable path back to `none` while that timer runs. Its `pid` field is therefore useless as a staleness cue — the pid is *always* new and *always* dead. Only liveness-plus-resident-app (Ocho's rule) or the arithmetic test (R2) distinguishes this from a real flip, and the arithmetic test is the one that needs no `ps` race.

## 4. Away-side: Kev has not acted, and that is expected

`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease/` → **rc 1, no match**; `scopes/` contains **planner only**; `ps` scan for `kev|arcade|model-test` → **rc 1**. This is the **first** tick of the window, so the fallback-to-Llama condition ("no `llama-model-test` lease within a couple of ticks") is not met and was not used. His own continuous poll carries the precedence clause; recorded, not messaged. A `--scope arcade` acquire would be admitted right now on both counts (different scopes co-reside; 6107 ≥ 4289).

## 5. Rules

**R1 — Name a window's opener as a process, and check it is the process the record names.** Here the token's owner (the 9B group, never loaded) and the actual opener (the smol 3B rung, unloaded) are different rungs of one lane, and the record was rewritten *after* the previous tick had already read `closed`. Reading `planner_at` and `kev_window` as two ends of one state machine inverts the causality and would have credited the 08:00:12 acquire with freeing 2 GiB it never held. Extends `2026-10-22-a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed` to the *open* edge: there the close belonged to another unit's holder, here the open belongs to another rung's exit. Corollary from §3b: **a fresh `pid`/`acquired_at` is not freshness** — a producer that fails after acquiring refreshes both fields every cycle, so recency must be read on liveness or on the arithmetic, never on the record's own timestamps.

**R2 — Refute a presence token by arithmetic before hunting a pid.** Compare the record's `need_mib + headroom_mib` against measured free; if the holder's own admission test would refuse it now, the record is history. This is one read and works when `ps` is unavailable or the pid has been recycled; liveness remains the positive confirmation, arithmetic is the negative one. Parents: `2026-10-13-a-scope-record-outlives-its-holder`, `2026-10-13-a-fresh-record-from-a-failed-acquire`, `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` — cited, not re-filed.

**R3 — Price a window against every gate that reads it, not just its own.** `6107` is `+1818` for Kev (4289) and `−349` for the record's own claim (6456). Reporting only the first number turns a stalled planner rung into "capacity".

## 6. Absentees, messages, read-only

**Messages: none, both premises measured.** No `@ocho`: token identical on both sides *and* item closed in his own rows. No `@llama`: first open tick, fallback not triggered, and he self-runs under the standing precedence clause.

**Read-only.** No acquire, no release, no model load, no unit touched, no config edited. `gpu-lease.sh`, `llama-swap.yaml`, `scopes/planner/record.json` and the planner service are as found; the dead holder's record was **read and left in place** (its own policy already calls a dead-pid `mode=run` record reclaimable, so leaving it blocks nothing).

**Prior art:** 403 records; `priorart.py` run twice **before** this file existed — *"an existence token whose referent died inside the same tick certifies a lease nobody holds"* top weak 0.130 / 0.065 / 0.064, and *"a window opened by a dead holder is not a release, and a lease record with no liveness is a claim not an occupancy"* top weak 0.163 / 0.148 / 0.128 / 0.109 / 0.107 / 0.102, all read by eye; the increment filed is the arithmetic falsifier (R2) and the rung-identity of the opener (R1).
