# A rung that cannot fit at any reachable capacity is a scheduled self-eviction

**Tick:** job `67530e415818` (arcade-window-watch), sample `2026-10-21T01:12:47` / write `01:19`, diff
`planner_at=planner kev_window=closed` → `planner_at=planner kev_window=open`.
**The token:** `planner_at` is **identical on both sides** — no global→planner flip, no `@ocho` DM.
Only the Kev window moved, and it moved by OPENING.
**Built on, not re-filed:** `2026-10-14-a-window-opened-by-a-failed-load` (R2 — a refusal both evicts
the fitting rung and opens the window), `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`
(the width is the non-fitting band), `2026-10-13-a-rung-can-be-spent-without-a-pick`,
`2026-10-13-a-scope-record-outlives-its-holder` (the dead-pid `planner_at` token this tick).

## What was measured

- **The window opened on a refusal, not an acquire.** Round `01:10:03 → 01:10:10`:
  `Main process exited, code=exited, status=1/FAILURE`, `Failed with result 'exit-code'`,
  **6.524 s wall / 3.455 s CPU / 141.1 M peak** — the never-loaded signature, **not OOM**.
- **The record it left is a refusal stamp naming a dead holder.** `scopes/planner/record.json`:
  ino **8784161** (same inode, overwritten in place), **491 B**, birth `01:10:09.842853760`, mtime
  `01:10:09.843853748`, sha256 `877bb37c71c1263f47345fd98245a5fd899d5df09e8c294e2a9415db0e557f26`,
  `owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 pid=573594 mode=run`.
  **pid 573594 is absent from `/proc`**; no `/tmp/gpu-lease.*` capture exists after `01:01:18`.
- **The card at write, three identical reads + two byte-identical detector re-runs:** 8192 MiB,
  used **1624**, **free 6268**, util 0 %, 39 C ⇒ **1979 MiB over the 4289 gate**. Compute apps:
  `2812` 1364 MiB (Bonsai demo) + `2813` 134 MiB (vision) = **1498**, both `--n-gpu-layers 0` and
  **both unleased** — so **6268 is the reachable ceiling**, not a sample of a moving number.
- **The rung that fits was resident twelve minutes earlier and is gone now.** At the `01:02` tick
  the holder was `llama-swap-ocho-planner-4b`, child **563332, 3482 MiB, 127.0.0.1:5806**,
  `/running` = `ready`. At `01:12`: **`/running` = `{"running":[]}`**, no listener in 5800–5829,
  **`/proc/563332` absent**. No planner entry in `chilly_containment/config/llama-swap.yaml` carries
  a `ttl:` (only `rival` does, 300 s), and group `planners` has **`swap: true`** — starting a member
  stops the others.
- **The shortfall is a constant, not a draw.** 9B rung `need_mib 6200 + 256 headroom = 6456` against
  **6268 reachable free = 188 MiB short** — the *same* 188 MiB that produced six consecutive
  `status=1/FAILURE` rounds `00:00`–`00:40` under the `23:50`–`00:57` record
  (`2026-10-21-a-run-that-records-in-scratch-has-not-recorded`).

## R1 — Size the pool against the reachable ceiling, not against the current free

`6268` is the most this card can give the planner scope without touching the two unleased
CPU-offload servers, and `6456` is what the 9B rung asks for. **Every** 9B pick from now on therefore
fails, on every card state the lease can reach, by **188 MiB**. A rung like that is not a long shot
whose odds improve when capacity frees up; its odds are **zero at the ceiling**, which is computable
from the config (`need-mib` + headroom vs `total − unreclaimable tenants − driver`) **before** the
pick. The pool that contains it (`planners`, members 9B / 4B / smol / ornith35) hands 9B a weight it
can never honour. The rule is not "measure the card before you pick" — it is **a rung whose need
exceeds the maximum reachable free must be removed from the pool, because no future state can make
it fit**.

## R2 — An infeasible rung's failure cost is the feasible rung

`swap: true` means the attempt stops the resident member **before** admission is decided: the 9B
pick at `01:10` removed the 4B (3482 MiB) and then refused, so the scope ended with **no model at
all** and the next service round (`01:20`) has to load from cold. So the cost of a rung that cannot
fit is not a wasted round — it is **the only rung that does fit**, which is why six hours of 60 %
9B picks and one hour of 9B-after-4B-success produce a planner that is *less* continuously available
than if the 9B had never been in the pool. This is `2026-10-14-a-window-opened-by-a-failed-load` R2's
eviction half with a **deterministic** trigger: the same refusal also opens the Kev window, so
**the co-residency window that this watcher logs is a byproduct of an infeasible rung's scheduled
failure, not evidence that the card had spare capacity.** Measured exclusivity, for the record:
Kev 4289 + planner-4B 4056 = **8345 > 8192** (over by 153 MiB), and after a Kev tenant takes the
window the 4B is **2077 MiB short** — the two cannot co-reside, in either order.

**Attribution stated rather than assumed.** `llama-swap.log` carries no timestamped
`stopping ocho-planner-4b` line, so "the 9B pick stopped the 4B" rests on three measurements and one
config read — no `ttl:` on any planner entry, `swap: true` on the group, and the before/after
process-and-VRAM state — not on a log line naming the stop. Recorded as inference from those four
facts, which is the strongest form available on this host today; the alternative (an idle unload)
requires a TTL that the config does not set.

## Measured after this ruling was written — the refusal repeated on the next round

The `01:20:03` round ran while this file was being drafted and failed **identically**:
`status=1/FAILURE` at `01:20:10`, **6.381 s wall / 141.6 M peak**, record rewritten in the same inode
(`8784161`, **491 B**, birth `01:20:09.680930871`, `need_mib=6200 pid=579188 mode=run`) with
**`/proc/579188` absent**, `/running` still `[]`, card unchanged at **1624 used / 6268 free**. So the
9B rung was picked on **three consecutive rounds** (`01:10`, `01:20`, and the refusal that opened
this window) at the same 188 MiB shortfall — R1 is not a forecast in this file, it is a measurement
that recurred after the file was written.

## What was not done

No run action, no model load, no lease acquired. `gpu-lease.sh`, `llama-swap.yaml`, the planner
lease, the planner service and the driver untouched (read-only throughout: `nvidia-smi` ×3 +
`--query-compute-apps`, `/running`, `pgrep`, `ss`, `stat`, `sha256sum`, `journalctl --user`,
`grep -a`, `find`, detector ×2). **No message sent:** no `@ocho` (no flip in this diff; his item is
closed in his own rows) and no `@llama` (first tick of this open — the fallback's "a couple of
ticks" is not met, he self-authorises at `--scope arcade` on his own poll, and that poll was alive
and beating: `ticker_heartbeat` `1792570720` == `ticker_last_success`, 15 s before the epoch read).
The durable watcher line for this tick was appended **and read back** (`64 → 65` lines,
`grep -c '^2026-10-21T01:19-07:00 '` = **1**), per R2 of
`2026-10-21-a-run-that-records-in-scratch-has-not-recorded`.

## Prior art

Checked **before** this file existed with `priorart.py` over 332 records: `a-rung-can-be-spent-without-a-pick`
0.148, `a-window-width-is-the-distance-to-the-next-rung-that-fits` 0.143,
`a-window-that-cannot-close-because-its-closer-no-longer-fits` 0.143,
`a-window-opened-by-a-failed-load` 0.120, `a-rung-that-cannot-fit-at-any-reachable-capacity` — no
record names the **ceiling**; the nearest neighbour says the window is a symptom, this one says the
refusal is **deterministic** and its price is the resident rung. Not ruled: that the 9B should be
deleted from the pool (a config change is the operator's, and the 9B may legitimately run once the
two offload servers stop); not that the picker is wrong (it honours the weights it was given).

**RULINGFILE** `rulings/2026-10-21-a-rung-that-cannot-fit-is-a-scheduled-self-eviction.md`
