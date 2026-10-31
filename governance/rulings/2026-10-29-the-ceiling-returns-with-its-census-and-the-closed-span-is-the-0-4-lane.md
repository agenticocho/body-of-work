# The ceiling returns with its census, and the closed span is the 0.4 lane

**Tick:** `67530e415818` (arcade-window-watch), change detected at the `11:12:19.944` sample
(`monitor_state.last_changed_at = 2026-10-29T11:12:19.944520-07:00`). Previous sample `11:01:19`
(`output/67530e415818/2026-10-29_11-01-20.md`, 6 lines, `no_change (agent run suppressed)`), so the
bracket is `(11:01:19.9, 11:12:19.944]`. `monitor_last_output.txt` 34 B ino `8527887` mtime
`11:12:19.944454148` sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`
(= `jobs.json.monitor_state.last_output_hash`), body `planner_at=planner kev_window=open`.

**Diff:** `kev_window closed -> open`; `planner_at=planner` **IDENTICAL on both sides** — no flip, so
no `global->planner` branch and **no `@ocho` message**.

```
previous   planner_at=planner   kev_window=closed
current    planner_at=planner   kev_window=open     <- this tick
```

## Live at write (three identical reads `11:15:57.757 / :58.794 / :59.833`)

| read | value |
|---|---|
| card | 8192 MiB total / **1998 used / 5893 free** / util 5-14 % / 39 C |
| compute apps | `2347` Bonsai 9B **1364** + `2349` LFM2.5-VL **134** + `87744` bge-small **226** = **1724** (all `--ngl 0`, all unleased); no 9B, no 4B, no smol |
| `used+free` | 7891 vs 8192 ⇒ **301 MiB** unreported driver/ctx (same 301 as the 10:37 tick) |
| gate (`arcade_window_watch.sh:47`) | `4033 + 256 = 4289` ⇒ **OPEN by 1604 MiB** |
| 9B (`ocho-planner`) | `6200 + 256 = 6456` vs 5893 free ⇒ **563 MiB short of an empty card** |
| 4B (`ocho-planner-4b`) | `3800 + 256 = 4056` ⇒ clears by **1837** |
| smol | `3000` ⇒ clears by **2893** |
| `:8080/running` | `{"running":[]}`; `:5806` and `:5808` both **not listening** |
| away artifact | `grep -rliE 'arcade\|kev\|model-test' ~/.local/state/gpu-lease` **rc 1**; `lease.d/` ABSENT; `scopes/` = `planner` only ⇒ **Llama took nothing** |

## The edge: a refused 9B draw swap-stopped the resident smol

Opener, named from artifacts, not inferred:

| artifact | reading |
|---|---|
| unit journal | `11:10:07 Starting` → `11:10:19 Main process exited, code=exited, status=1/FAILURE` (3.100 s CPU / 11.484 s wall / **142.6 M** — the refusal fingerprint, against 143.3 M exit 0 for a load) |
| deciding draw | `[O55] Weighted pick: ocho-planner (60% weight, cycle 60360, pool 3/3)` |
| counter | `ocho_sandbox/model_cycle_counter.txt` = **60361** (POST-increment), mtime `11:10:18.364536141` |
| record | `scopes/planner/record.json` **491 B** ino `10272179` **birth `11:10:18.715982996`** mtime `.716983041` sha256 `c3eef3fb38583d482659b1193cbfdbebdde56ce8591b1d47cab349ed99e26921`; owner `llama-swap-ocho-planner` scope `planner` class `batch` need **6200** headroom 256 mode `run` **pid 173309** acquired `1793297418` = 11:10:18 expires 2026-10-30 11:10:18 ttl 86400 |
| holder liveness (`11:12:23`, re-read `11:16:06`) | `/proc/173309` **ABSENT**, no `ps` row, never in `--query-compute-apps` |
| resident rung being stopped | `/tmp/gpu-lease.CU4pKM` 1642 B mtime `11:00:25.938962737`: loads `SmolLM3-3B-128K-UD-Q4_K_XL.gguf`, `model loaded` + `listening on http://127.0.0.1:5808` at `0.796 s`, task 0 = 2778 prompt tok @ 4889 tok/s + 114 eval tok @ 141.31 tok/s, n_tokens 2891 — the 11:00 round (`cycle 60359`, smol 10 %, exit 0, `Finished 11:00:26`) |
| prior plan | `logs/ocho_predictions.jsonl` last rows `17:40:21.906 / 17:50:16.222 / 18:00:26.045 Z` (= 10:40 / 10:50 / 11:00 PDT); none at 18:10 or 18:20 Z |
| capture for the 9B attempt | **no new `/tmp/gpu-lease.*`** after `CU4pKM` ⇒ the 9B never reached a load, as its own policy predicts |

So the smol (2672 MiB class) was swap-stopped by the 11:10 round **before** the 9B's own acquire wrote
its cell at `11:10:18.716`, and the 9B then failed admission. Free rose from
`5893 - 2672 = 3221` (arithmetic from the live ceiling + the capture, not a measured reading) to
**5893**. `llama-swap.log` carries no per-line timestamps, so the stop instant is **bounded**
`(11:10:07, 11:10:18.716]` and not dated; the cell's birth is the tightest artifact we have.

**Closed span:** from the 10:37 tick's close edge `10:30:15.042` (4B load) to the reopen:
`2403.674 s` at the record's birth = **40.0612 min = 4.0061 × 600 s**; lower bound at the round's
start `2391.958 s = 3.9866 cycles`. Same 4-draw band as the 10:30 close (which itself ended a
3598.640 s, 5.998-cycle window).

## The token is an orphan — and the gate beside it is what says so

`planner_at` is `[ -f scopes/planner/record.json ]` (`arcade_window_watch.sh:29-35`) and `take_lease`
writes the cell **before** admission, so this tick's `planner` token is the 11:10 **refusal's** cell
over a dead pid. The cheap discriminator filed at 10:37 holds and needed no second witness this time:
**a `planner` token beside an OPEN gate is evidence the token holds nothing** (a live holder would
have taken the card and closed the gate). Three reads agree — record yes, `/proc` no, resident app no,
`/running` `[]` — so the flip is **not** certified and no certification was sent.

Ocho's item stays closed in **his own rows**, re-read this tick: `profiles/ocho/state.db`
152,150,016 B mtime `07:42:24.538963598` (untouched since boot), ids **9249** / **9267** / **16736**
(*"Verified independently, and the item is closed"*), `max(id)=17405`.

## RULINGS

**R1 — THE EMPTY-CARD CEILING RETURNS TO ITS VALUE WHEN THE CENSUS RETURNS: THE RESIDUAL IS
NON-MONOTONE JITTER, NOT DRIFT.** Corrects R3 of `2026-10-29-a-token-is-certified-by-the-gate-beside-it`,
which read `5888 now vs 5893 at 09:38 — 5 MiB in 52 min` as drift on a ceiling it called "flat
between births". Same three-tenant census at all three readings (`1364 + 134 + 226` = 1724 MiB, all
`-ngl 0`, unchanged since `87744` was born `09:09:05`), and the ceiling reads **5893 (09:38) → 5888
(10:37, 10:40) → 5893 (11:15:58)** — it came back. A quantity that returns is not drifting; the ±5 MiB
is the driver/ctx reserve's own allocation noise inside the standing 301 MiB gap (`used+free` 7891 vs
8192, identical at 10:37 and 11:15:58). Consequence for every shortfall this watcher quotes: the operand
is a census function **plus a ±5 MiB band**, so `563 MiB short` is true to ±5 and must not be quoted
as a single-MiB figure across ticks — the 09:38 tick's `568` and today's `563` are the same quantity
at two draws, not a 5 MiB erosion. (R1 of `2026-10-29-an-admission-shortfall-quoted-as-a-constant-is-a-sample-of-the-tenant-set`
owns the operand rule; this adds that the residual has a **band and a sign that reverses**, so a
trend fitted through it is noise.)

**R2 — THE CLOSED SPAN IS THE GEOMETRIC WAIT ON THE 0.4 BRANCH, AND IT IS MEASURABLE DRAW BY DRAW.**
The four draws between the 10:30 close and this reopen are `60357` 4B (30 %) → `60358` 4B (30 %) →
`60359` smol (10 %) → `60360` 9B (60 %, refused). Three of them **load** and therefore *hold* the gate
shut; only the 9B draw clears the card (by refusing and taking the resident rung with it). Under the
fixed 6:3:1 weights the closed span is the count of consecutive non-9B draws:
`P(span ≥ 4) = 0.4^4 = 2.56 %`, mean `0.4/0.6 = 0.667` draws ⇒ **~7 min** typical. This is the exact
inverse of the open-width statistic owned by R2 of `2026-10-29-a-token-is-certified-by-the-gate-beside-it`
(`P = 0.6^k` for survival) — same weights, opposite branch — so the card's duty cycle is a two-sided
geometric process and neither the 40-minute closed span nor the 60-minute open span is evidence of a
mechanism change. Increment: the closed span had never been enumerated by pick line; it is now
`[4B, 4B, smol, 9B]` with the 9B last, matching `2403.674 s = 4.006 cycles`.

**R3 — THE RECORD'S INODE NUMBER REPEATED ACROSS A 40-MINUTE GAP, AND THAT IS RECYCLING, NOT
CONTINUITY.** Today's cell carries ino `10272179` — the number the 10:37 tick recorded for the
**10:30:13** 4B cell (birth `10:30:13.820034833`) — while its own birth is `11:10:18.715983`, 40 min
later, over a different owner (`ocho-planner` not `ocho-planner-4b`), a different size (491 vs 494 B),
a different pid (173309 vs 145542) and a different digest. A second live instance of
`2026-10-23-an-inode-number-recycled-by-a-rename-replace-writer-is-not-continuity` R1 (`take_lease`
begins `rm -rf "$dir"` and publishes via `mv -f`, so a freed number in the same directory is
immediately re-taken), cited rather than re-filed. The handle for record identity stays **content
(491 B + sha256) + birth + holder liveness + the round's journal**, never the number — and this tick
is the first where the recycling returned the *same* number after a gap long enough that a tick could
plausibly have read it as "the 10:30 cell still standing".

## Actions taken

- **No `@ocho` message.** No flip (both sides `planner`), and the prescribed sentence — *"the
  scoped-planner flip is confirmed live end-to-end"* — is false on three reads (dead pid `173309`, no
  resident app, `status=1/FAILURE` + `142.6 M`). His open item is closed in his own rows (ids above);
  a DM would reopen a closed item with a false certification into a channel that drops on
  `target_busy` and has no read receipt.
- **No `@llama` message.** This is the **open** edge, so the fallback clause is in scope in principle,
  but it belongs to a window that *survives several ticks untaken*; this is the first tick of a window
  **121 s** old at the sample (`11:10:18.716` → `11:12:19.944`), and no `llama-model-test` /
  `--scope arcade` artifact exists yet. He self-authorises and self-polls; not preempted.
- **No acquire, release, load, reservation, unit or config touched.** `gpu-lease.sh` (not invoked for
  mutation), `llama-swap.yaml`, `scopes/planner/` (the dead cell left in place under its own reclaim
  policy: *a `mode=run` holder whose pid is dead is reclaimable* — reclaiming it is Llama's or the next
  acquirer's act, not this watcher's), the planner unit, the three aux tenants and the driver
  **read-only** throughout. The 11:00 smol load and the 11:10 9B refusal were the timer's own rounds
  through llama-swap.

## Standing flag for Mike, re-measured this tick

`profiles/llama/cron/` still has **NO `jobs.json`** (`jobs.lock`, `tick.lock`, `executions.db` 24576 B
frozen `2026-10-12 06:33:07.322361061`, `output/` untouched since 10-12), while `ticker_heartbeat`
22 B mtime `11:15:18.924334984` and `ticker_last_success` are rewritten every tick — **a live clock
over an EMPTY JOB SET**. The window that closed at 10:30 ran 59.98 min at `+1604` MiB above the gate
with nothing executing the standing Kev authorisation (cited from the 10:37 tick); it has now reopened
at the same `+1604 MiB` with the same empty job set. That is an execution fact, not a Kev decision, and
the only lever observed today is the unleased `-ngl 0` tenant set (1724 MiB holding 563 MiB of 9B
admission). This watcher creates no jobs and touches no tenant.

## Prior art, printed BEFORE this file existed

`priorart.py rulings` (518 records, three phrasings):
`REVIEW 0.266 2026-10-29-a-token-is-certified-by-the-gate-beside-it` (read in full — owns the
gate/token discriminator, cited; R1 here corrects its R3), `0.137
2026-10-21-a-capture-birth-dates-its-load-and-its-mtime-its-last-serve`,
`0.132 2026-10-14-a-file-mtime-dates-the-copy-not-the-run`, `0.125
2026-10-23-an-inode-number-recycled-by-a-rename-replace-writer-is-not-continuity` (read in full —
owns R3, cited), `0.125
2026-10-29-an-admission-shortfall-quoted-as-a-constant-is-a-sample-of-the-tenant-set` (owns R1's
operand rule, cited), `0.117 2026-10-14-a-window-that-is-a-rung-of-a-rotation`, `0.110
2026-10-27-the-refusal-that-reopens-the-window-and-the-empty-card-it-leaves`, `0.104
2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`, `0.100
2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits`. No record states that the
ceiling's residual returns with its census (R1) or that the closed span is the `0.4^k` branch measured
by pick line (R2).

**READ-ONLY THROUGHOUT:** `nvidia-smi` ×4 + `--query-compute-apps`, `stat %w/%i/%s/%y`,
`sha256sum`, `/proc/<pid>` + `ps -p`, `curl :8080/running` + `/v1/models`, `ss -ltn`, `journalctl
--user`, unit round census, `ocho_sandbox/model_cycle_counter.txt`, pick lines, `/tmp/gpu-lease.*`
captures, `logs/ocho_predictions.jsonl`, `ocho state.db` via `sqlite3` (SELECT only), `priorart.py`.

RULINGFILE rulings/2026-10-29-the-ceiling-returns-with-its-census-and-the-closed-span-is-the-0-4-lane.md
