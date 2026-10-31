# A recycled pid makes a dead holder read as never reclaimable

**Date:** 2026-10-25 (arcade GPU co-residency watcher tick, ~15:03–15:06 PDT)
**Trigger:** `kev_window closed->open` (`planner_at` unchanged at `planner`) with a **new** `scopes/planner/record.json` on disk whose holder had been dead for three minutes. The record was left by `ocho-planner-polymarket.service`, which started 15:00:00 and exited `status=1/FAILURE` at 15:00:07.
**Parents:** `2026-10-13-a-scope-record-outlives-its-holder` (the record's existence is a claim that an attempt was made) and `2026-10-23-an-inode-number-recycled-by-a-rename-replace-writer-is-not-continuity` (a recycled identifier is not continuity). Neither states what happens when the *reclaim predicate itself* reads the number.

## What is measured (every line a disk or journal read this tick)

| read | value |
|---|---|
| `scopes/planner/record.json` (mtime `15:00:06.721179103`) | owner `llama-swap-ocho-planner`, scope `planner`, class `batch`, need_mib **6200**, pid **2433301**, mode `run`, `acquired_at` 1792965606 = 15:00:06 PDT, `expires_at` 1793052006 = 2026-10-26 15:00:06, ttl 86400, headroom 256 |
| holder liveness at 15:02:31 | `/proc/2433301` ABSENT; `kill -0 2433301` -> `No such process`, rc 1; no child process |
| resident compute apps | only the two pre-existing: 976745 Bonsai-9B 1466 MiB, 979586 LFM2.5-VL 134 MiB; `:8080/running` -> `[]` |
| card at 15:03:31 | 8192 total / 1785 used / **6106 free**, util 1 % |
| window test (free >= 4033 + 256) | 6106 >= 4289 -> `kev_window=open`, slack 1817 MiB |
| journal, user manager | `15:00:00 Starting ocho-planner-polymarket.service` -> `15:00:07 Main process exited, code=exited, status=1/FAILURE` |
| planner stdout log (mtime 15:00:07.014) | `[call_ocho_planner] 📡 Calling LLM via llama-swap...` / `[llm] ❌ Request failed: 500 Server Error` / `❌ Failed to get completion from llama-swap` |
| `llama-swap.log` | `[WARN] group: starting ocho-planner failed: aborted` (a chronic pattern, many prior occurrences) |
| `ocho-planner-polymarket.timer` | `OnCalendar=*:0/10`, `Persistent=true`, next 15:10:00 |

So the token `planner_at=planner` was TRUE of a file and FALSE of a holder: written at 15:00:06, holder gone by 15:00:07, card clear at 15:03:31. The record that Ocho's already-closed item rested on (need_mib 3800, live child `llama-server` on `:5806`, 3482 MiB) is no longer the record on disk — the file has been replaced by this tick's failed attempt.

## The new half: the reclaim predicate is a NUMBER, and numbers recycle

`gpu-lease.sh:278` decides a scoped holder's state with `if kill -0 "$LD_PID" 2>/dev/null; then echo live; else echo free; fi`, and the record's own policy clause (line 147) says a `mode=run` holder whose pid is ALIVE is **never reclaimable at any age, regardless of expires_at**.

Measured on this box, same tick:

* `/proc/sys/kernel/pid_max` = **4,194,304**
* highest allocated pid at 15:05:10 PDT = **2,436,871** -> **1,757,433 numbers remaining**
* allocation rate: **317 pids / 40 s = 7.93 pids/s (28,530/hr)** steady; **101,991 pids / 7,323 s = 13.93 pids/s (50,139/hr)** across the 2 h since pid 2,335,212 was allocated
* at those rates the pid space wraps in **35.0 h (burst) to 61.6 h (steady)**

The record's TTL is 86,400 s = **24 h**, and the "live is never reclaimable" clause is explicitly *not* bounded by it. So a scoped record that no wrapper ever removes sits on disk for longer than the interval in which its pid number can be handed to an unrelated process: at the measured rate the wrap arrives 11–38 h after the TTL stops protecting anyone, and from that moment `kill -0` succeeds on a stranger and the orphan is classified ALIVE — permanently un-reclaimable by the tool's own rule, while holding 6200 MiB of a 8192 MiB card in the precedence arithmetic that a co-residency contender reads.

## Rulings

**R1 — A LIVENESS PREDICATE ON A RECORD THAT OUTLIVES ITS WRITER MUST BE A PREDICATE ON THE PROCESS, NOT ON THE NUMBER.** `kill -0 <pid>` answers "is some process holding this number right now", which equals "is my holder alive" only while the number has not been recycled. Any artifact that (a) survives its writer, (b) is keyed by a reusable identifier, and (c) is believed on the strength of that identifier has a horizon: the identifier's reuse interval. State the horizon with the rule, because the horizon is measurable (`pid_max - highest pid` / allocation rate) and the belief is not re-checkable afterwards.

**R2 — A CLAUSE THAT REFUSES RECLAMATION "AT ANY AGE" CONVERTS AN IDENTIFIER-CONFUSION INTO A PERMANENT BLOCK; THE AGE BOUND IS WHAT MAKES THE CONFUSION SURVIVABLE.** The same dead-pid read is harmless under expiry-only policy (the clock reclaims it) and unbounded under liveness-first (nothing does). So the two clauses that were written to protect a live holder — never-reclaimable-at-any-age, plus a pid join — compose into a permanent reservation for a process that never existed. Where a liveness-first rule is adopted, the join behind it must carry a start-time or a boot-relative identity (`/proc/<pid>/stat` starttime, or the record's `acquired_at` compared against the pid's own start time), not the number alone.

**R3 — "THE HOLDER IS DEAD" IS A READING WITH A TIME ON IT, AND THE RECORD DOES NOT CARRY THAT TIME.** At 15:02:31 pid 2433301 was dead; the record said `mode=run`, lowercase-certain, with a 24 h expiry. Nothing in the artifact distinguished "died 0.3 s after writing" from "died 23 h later" — and the two differ entirely for a contender deciding whether the reservation was ever honoured. Grade such a record by the mechanism that wrote it (`take_lease` writes `pid=$$` before the wrapped command runs; only the EXIT trap removes it) and quote the read's own instant beside it.

## Actions taken / not taken

- **No run action, no model load, no acquisition.** Llama is self-authorized on his own poll for Kev-4B at `--scope arcade` when free >= 4289; this watcher neither triggers nor pings him.
- **No `@ocho` message.** His open item (the `global->planner` flip confirmation) was closed on the live channel at ~14:27 against a *live* holder and stays closed; this tick's `planner_at` did not change, and the prescribed sentence ("confirmed live end-to-end") would be **false** against this tick's reads.
- **Nothing written to `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, or any unit.** Read-only: `record.json`, `nvidia-smi`, `/proc`, `journalctl --user`, the two log files, `pid_max`, `ps`.
- **Flagged to the operator** that the 10-minute failure loop rewrites the scoped record with a fresh dead pid each round, i.e. the record's freshness is manufactured by the failure path (already ruled in `2026-10-13-a-fresh-record-from-a-failed-acquire`), and that the orphan's `need_mib` 6200 exceeds the live free VRAM 6106 — so the record, if read without the liveness predicate, denies a 4289 MiB window on a card that is empty.

## Prior art

`priorart.py rulings` on three phrasings, before this file existed: max `weak 0.190 2026-10-13-a-scope-record-outlives-its-holder`, then `0.155 a-lease-record-names-the-wrapper-and-the-card-names-the-child`, `0.143 a-fresh-record-from-a-failed-acquire`; second phrasing max `weak 0.125 2026-10-13-a-confirmation-carries-an-invariant-not-a-pid`, `0.106`, `0.096 an-inode-number-recycled-by-a-rename-replace-writer-is-not-continuity`; third max `weak 0.123`, `0.110 a-live-process-is-never-evictable-by-the-clock`, `0.099`. Read by eye: the first two are about what a record MEANS to a human reader, the inode ruling is the same identifier-recycling class in a different object, and the "never evictable by the clock" ruling owns the clause R2 extends. No duplicate.
