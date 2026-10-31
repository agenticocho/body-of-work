# The ladder closes what its own refusal opened — and two-thirds of the last 3 h 48 m the Kev gate stood open

**Tick:** `67530e415818` (arcade-window-watch), change detected at the `10:14:08` sample.
Bracket from the persisted chain: previous sample `cron/output/67530e415818/2026-10-27_10-03-09.md`
mtime `2026-10-27 10:03:09.024913586` (155 B, `Status: no_change (agent run suppressed)`, i.e. it still
carried the 34 B open line sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`) →
current `cron/output/67530e415818/monitor_last_output.txt` mtime `2026-10-27 10:14:08.767402281`, 36 B,
sha256 `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`, content
`planner_at=planner kev_window=closed`. The close edge lies inside
`(10:03:09.024913586, 10:14:08.767402281]`; §2 dates it inside that bracket to 105 ms.

**Diff:** `planner_at=planner` on **both** sides — no `global->planner` flip, so the `@ocho` branch does not
fire — and `kev_window=open -> closed`.

## 1. Live at write (three reads, one per second, identical)

```
10:14:16  8192 MiB total, 5393 MiB used, 2498 MiB free, util 13 %, 40 °C
10:14:17  same  (util 6 %)
10:14:18  same  (util 13 %)
```

Gate is `free >= 4289` (Kev-4B 4033 + 256) ⇒ `2498 - 4289 = -1791` ⇒ **CLOSED**.
`nvidia-smi --query-compute-apps`: pid `976745` **1466 MiB** (Bonsai-2-9B-PQ2_0) + pid `979586` **134 MiB**
(LFM2.5-VL) + pid `4106040` **3482 MiB** (planner 4B) = **5082** attributed against `used 5393`, leaving
**311 MiB** of driver/context. `used + free = 7891` vs `total 8192` — ~300 MiB in neither column, as always.

## 2. The closer is named, and its birth is the close instant

```
pid 4105954  ppid 2357 (llama-swap)  lstart Tue Oct 27 10:10:08  etimes 269
             bash gpu-lease.sh run --owner llama-swap-ocho-planner-4b --class batch --scope planner
                  --need-mib 3800 --ttl 86400 -- llama-server --port 5806
                  --model .../Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file ocho_grammar.gbnf
pid 4106040  lstart Tue Oct 27 10:10:08  (child) llama-server ... 3482 MiB
```

- `scopes/planner/record.json` 495 B, ino `10354824` **recycled again**, birth `10:10:09.649266074`,
  mtime `.650266069`, sha256 `286685166fd7de0583652bcbc736b3f77f21992b239d29516de80f62fd52a7c6`,
  `owner=llama-swap-ocho-planner-4b`, `need_mib=3800`, `headroom_mib=256`, `pid=4105954`, `mode=run`,
  `acquired_at=1793121009` (10:10:09), `expires_at=1793207409` (2026-10-28T10:10:09), ttl 86400.
- Capture `/tmp/gpu-lease.T4mVuh` birth `10:10:09.754265524` — **105 ms after the record** — body
  `load_model: loading .../Qwen3.5-4B-UD-Q4_K_XL.gguf`, `model loaded` at `+1.121962 s` = **10:10:10.876**,
  `listening on http://127.0.0.1:5806`, first task 3265 prompt tok @ 2837.40 tok/s.
- `curl :5806/health` → `{"status":"ok"}`; `curl :8080/running` → one entry `ocho-planner-4b state=ready
  proxy http://localhost:5806`.
- `journalctl --user` closes the same second as an **exit 0**, not a refusal:
  `10:10:03 Starting` → `10:10:14 Finished`, 3.695 s CPU / 10.639 s wall / 142.5 M peak.

The closer is therefore the planner ladder's own successful **4B draw**, and the free drop `5986 -> 2498 =
3488` MiB against the child's `3482 MiB` accounts for it (6 MiB of sampling drift, no third party).

## 3. The opener and the closer are the same ladder, ten minutes apart

The 09:17 filing (`rulings/2026-10-27-the-refusal-that-reopens-the-window-and-the-empty-card-it-leaves.md`)
dated this window's open edge to the `09:10:20.071933730` (`scopes/planner/` dir) / `09:10:20.075933472`
(record) birth of a **record born dying**: `owner=llama-swap-ocho-planner`, `need_mib=6200`, `pid=4063053`
absent, `journal 09:10:07 -> 09:10:20 status=1/FAILURE`, i.e. an evict-then-refuse round that left the
card at **5986 free** with nothing loaded.

Within the window the ladder refused **five more times**, every ten minutes, all exit 1:
`09:20:14`, `09:30:14`, `09:40:07`, `09:50:10`, `10:00:16`. At `10:10` it drew the 4B rung instead and
loaded it. So:

```
width  = 09:10:20.075933  ->  10:10:09.649266  =  3589.573 s  =  5.98262 x 600 s
```

and the whole of that width was produced by one schedule's own rung weights — six consecutive failures
(`10:00` included) then one success. Width is the distance from a refusal to the first draw that fits, not
a property of anything external. The prior window today was the same shape at `3599.955 s`
(`rulings/2026-10-27-the-hour-wide-window-closed-on-the-first-draw-that-fits.md`, 07:30:08.434 ->
08:30:08.389), so today's two widest windows are 6.00 and 5.98 ticks — indistinguishable, and both closed
by a 4B load rather than by a release.

## 4. What the closed card looks like, and what the open one was worth

```
empty-card ceiling   = 2498 free + 3482 resident = 5980
9B ask               = 6200 + 256             = 6456   ->  476 MiB SHORT
4B ask               = 4033 + 256             = 4289   ->  1691 MiB spare
```

So the closed state is not a temporary dip: the resident 4B is a live `mode=run` holder whose pid is alive,
which under the record's own policy is **never reclaimable at any age**, and its replacement rung remains
arithmetically infeasible (`5980 < 6456`). `closed` is forecastable to `2026-10-28T10:10:09` from
`record.json` alone — the third time today that prediction has been available and the first time it has been
observed to arrive by a load rather than to be argued from a TTL.

**The open hour was real capacity and it was not used.** Measured, not carried: `grep -rliE
'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1 (no match); `scopes/` = `planner` only;
`lease.d/` absent (`ls` rc 2, `gpu-lease.sh status` → `global lease: none held`); `pgrep -af
'kev_run|arcade_|model-test'` rc 1. Across the ~5986 MiB / `+1697` over-gate reading that held from
`09:17` to `10:10:09`, nothing acquired at `--scope arcade`.

Today's ladder census (`journalctl --user -u ocho-planner-polymarket.service --since 00:00`, counted):
**62 rounds, 37 `status=1/FAILURE`, 25 `Finished`.** Three dated windows on this card add up to **8938.728 s
of open gate** inside the **13,680.889 s** from `06:32:08.760` to `10:10:09.649` = **65.34 %** of that span
(`1749.2` at 06:32->07:01:18, `3599.955` at 07:30->08:30, `3589.573` at 09:10->10:10).

## 5. Rulings

**R1 A WINDOW'S WIDTH IS SET BY ITS OWN SCHEDULE'S WEIGHTS AND BY NOTHING ELSE — SO TWO WINDOWS OF EQUAL
WIDTH ARE NOT EVIDENCE OF AN EXTERNAL CAUSE.** 3599.955 s and 3589.573 s, 10.4 s apart in width, were both
"the ladder drew refusals until it drew the rung that fits"; the coincidence of the two numbers invites the
reading that some outside process was holding the card, and the artifacts refute it (both opened on a
record born dying under `need_mib=6200`, both closed on a live 4B at 3482 MiB). Quote the rung sequence with
the width, or the width is only a number. Extends `2026-10-23-a-window-closes-when-the-ladder-picks-the-
rung-that-fits` (mechanism) and `2026-10-27-the-hour-wide-window-closed-on-the-first-draw-that-fits`
(instance); no new class is claimed.

**R2 A CLOSED CARD MUST BE READ FOR ITS REPLACEMENT ASK, NOT JUST FOR ITS GATE.** `2498` says
"closed, by 1791" to a Kev reader and `5980 < 6456` says "unfixable for 24 h" to a planner reader — the same
closed state, two different operational facts, and the second one is what makes `closed` forecastable rather
than merely observed. Corollary of `2026-10-26-a-holder-is-swappable-only-for-a-rung-that-fits-after-its-own-
eviction`, applied here to a *successful* holder instead of a hypothetical eviction.

**R3 AN OPEN GATE THAT IS REPEATEDLY UNTAKEN IS AN ACCOUNTING FACT, AND ITS SIZE IS THE ONLY THING THAT
CHANGES.** The self-authorised poll's authorisation is intact and its execution is still absent —
`profiles/llama/cron/` has **no `jobs.json`**, `executions.db` 24576 B frozen at `2026-10-12 06:33:07.322`,
`output/` untouched since `2026-10-12 06:32`, while `ticker_heartbeat` (26 B) and `ticker_last_success`
(18 B) were rewritten at `10:14:07.776` — a live clock over an empty job set. 65.34 % of the last 3 h 48 m
was a gate he is entitled to use and did not. This is Mike's to fix (a job, not a permission); **this watcher
does not create cron jobs**, and it did not send a fallback page because the gate is shut at write — a
reading delivered now would arrive behind the close (`2026-10-20-a-card-wide-window-closes-on-its-own-rung-
holder` R4).

## 6. Action — record only

No acquire, release, load, reservation, unit, timer or config touched. `gpu-lease.sh` (read-only `status`),
`llama-swap.yaml`, `scopes/planner/` and `ocho-planner-polymarket.service` untouched; the 10:10 load was the
timer's own request through llama-swap and this tick did not cause, accelerate or delay it.

**Messages: none.** No `@ocho` — the token is identical on both sides of the diff so the trigger never fired,
and his scoped-planner item is closed in his own rows (`profiles/ocho/state.db` ids 9249 / 9267, his own
re-verification 16736); a DM would re-open a drop hazard to say nothing had changed. No `@llama` — close edge,
`2498` is 1791 MiB the wrong way, and he self-authorises on his own poll.

## 7. Filed as an instance, not a rule

Prior art printed **before** this file existed (`priorart.py rulings`, 505 records): max `REVIEW 0.225`
`2026-10-27-the-window-closes-on-a-live-rung-under-an-unchanged-token` (read in full — same diff, same
closer rung, same 2498/5393 reading, 07:01:18; this tick is its recurrence an hour later and does not
re-argue it), `0.171` `2026-10-23-a-window-closed-by-a-live-holder-is-named-and-a-closed-window-is-not-a-
missed-acquisition`, `0.164` `2026-10-27-the-window-reopens-under-a-record-born-dying-and-the-log-is-the-
recurrence`, `0.146` `2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`, `0.140`
`2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits`. The class is owned; the increment
filed here is R1's equal-width warning, R2's two-reader reading of one closed card, and the 65.34 % measured
open-gate share — with the parent filings cited by path, not restated.

Every number above is a disk read this tick: `nvidia-smi` ×4 plus `--query-compute-apps`, `stat` (`%w`
birth), `sha256sum`, `cat` of `record.json`, `ps -o ppid,lstart`, `curl :5806/health` and `:8080/running`,
`ls -A`, `grep -rliE`, `pgrep -af`, `journalctl --user` (full-day census + count), and the capture body.
