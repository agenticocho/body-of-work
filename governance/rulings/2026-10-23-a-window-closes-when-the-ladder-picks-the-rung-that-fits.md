# a window closes when the ladder picks the rung that fits

**TICK 2026-10-23 17:16:52–17:18 PDT (arcade-window-watch, job `67530e415818`), diff = ONE field `kev_window=open->closed`, `planner_at=planner` IDENTICAL both sides so NO `global->planner` branch and NO `@ocho` DM (his scoped-planner item closed on the 10:40 and 15:30 4B certificates).**

Nature of the tick: **RECORD ONLY.** No acquire, release, load, unit change or message. Llama remains SELF-AUTHORISED to acquire Kev-4B at `--scope arcade` on his own poll; this watcher does not trigger him and did not page him.

## The live artifact (read, not remembered)

Card `NVIDIA GeForce RTX 3060 Ti`, 8192 MiB, three reads 17:16:57 / 17:17:0x / 17:17:1x identical:

| used | free | util | temp | gate 4289 (`arcade_window_watch.sh:47`, 4033+256) |
|---|---|---|---|---|
| **5154** | **2737** | 1 % | 36 C | **CLOSED by 1552 MiB** |

Compute apps and their accounting (`gpu-lease.sh status`, read-only, agrees to the MiB):

```
pid 976745  1364 MiB  llama-server  owner=UNOWNED        (PrismML Bonsai, n-gpu-layers 0)
pid 979586   134 MiB  llama-server  owner=UNOWNED        (LFM2.5-VL, n-gpu-layers 0)
pid 1050861 3482 MiB  llama-server  owner=llama-swap     (ocho-planner-4b, :5806)
               174 MiB  driver
             ------
             5154 used        used+free = 7891 vs 8192 = the standing ~301 MiB reservation
```

Ledger: `lease.d/` **ABSENT**, global lease **none held**, `scopes/` = `planner` only.

## What the edge is

`monitor_last_output.txt` 36 B, mtime 17:16:52.018, reads `planner_at=planner kev_window=closed`. The prior tick (16:16:52, `rulings/2026-10-23-a-served-model-outlives-its-last-serve.md`) recorded the open with its edge bounded inside `(16:05:52.086, 16:16:52.045]` by the suppressed `no_change` sample at 16:05:52 and the 34 B open artifact. So the close lands at the writer that loaded, not at a sample:

* `scopes/planner/record.json` — **495 B, ino 9964817, birth 17:10:09.331884558, mtime 17:10:09.333884538, sha256 `66c17c4d0926a459d01d064761224774b22cbf12af601ca078b4654e6b5361f6`** — `owner=llama-swap-ocho-planner-4b`, `scope=planner`, `class=batch`, `need_mib=3800`, `headroom_mib=256`, `pid=1050775`, `mode=run`, `acquired_at=1792800609` (17:10:09), `expires_at=1792887009` (2026-10-24 17:10:09), ttl 86400.
* `pid 1050775` **ALIVE** (`ps`: `bash gpu-lease.sh run --owner llama-swap-ocho-planner-4b … --scope planner --need-mib 3800 --ttl 86400 -- llama-server --port 5806 --model Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file …/ocho_grammar.gbnf`, etime 06:54 at first read, ppid 2357 = llama-swap).
* its **child** `pid 1050861` resident at **3482 MiB** (same 06:54 etime) and `LISTEN 127.0.0.1:5806`.
* capture `/tmp/gpu-lease.ntGGcq` 1637 B, birth 17:10:09.428883581 (**97 ms after the cell**), mtime 17:10:13.874838775: `loading model '…/Qwen3.5-4B-UD-Q4_K_XL.gguf'` → `model loaded 0.01.097.077` → `listening on :5806` → ONE task 3672 prompt tok @ 2885.77 tok/s + 105 eval @ 95.57 tok/s → `release … n_tokens = 3776`.
* `llama-swap /running` = `[{"model":"ocho-planner-4b","state":"ready","ttl":0}]`.
* round `journalctl --user -u ocho-planner-polymarket.service`: `17:10:03 Starting` → `17:10:13 Finished`, 10.502 s wall / 3.218 s CPU / 141.6 M — **the first exit 0 after six consecutive `status=1/FAILURE`** at 16:10:20, 16:20:06, 16:30:11, 16:40:14, 16:50:17, 17:00:06 (each 6.0–7.4 s, no capture ⇒ never loaded).
* `model_cycle_counter.txt` 59447 (5 B), mtime **17:10:09.2439 = 88 ms BEFORE the record birth** — the 14:30 tick's pick-clock rule (R1) on the admitted side again.

Four legs (record + live pid + resident child + capture/`/running`) plus the arithmetic ⇒ the closer is **named**, not attributed by difference.

## Width

Measured open **≥ 16:16:52.045 → 17:10:09.332 = 53 m 17 s**; bounded **≤ 64 m 17 s** (from the last CLOSED sample at 16:05:52.086). Seventh window today and, like all six before it, a by-product of the planner's own slot ladder.

## R1 — the window's duration is the ladder's geometry, not a capacity fluctuation

Inside this window free was 6224 (16:17 read) against a gate of 4289, i.e. **1935 MiB of eligible headroom for 53 minutes**, and Kev-4B would have been admitted at `--scope arcade` the whole time. It stayed open because of arithmetic wholly internal to the caller's fallback ladder:

| rung | need + 256 headroom | vs free 6224 |
|---|---|---|
| 9B (`ocho-planner`, need 6200; the 16:10 cell sha256 `ce19dc11…` measured last tick) | 6456 | **232 SHORT → refused** |
| 4B (`ocho-planner-4b`, need 3800) | 4056 | **2168 SPARE → admitted** |

For any free in **[4056, 6456)** the 9B must fail and the 4B will fit, so the window closes on whichever round the rotation happens to pick a fitting rung — not on any change in free. That is why one open interval ran 60 min (14:30→15:30) and this one 53 min while a single round is only ~10 s: the state is **stable**, and its exit is a discrete pick. Corollary for reading this token: `open` says nothing about capacity scarcity (1935 MiB spare here) and `closed` says nothing about a load failing — the failure and the load are the two halves of one mechanism. Streak count is not a duration: six failures spanned 53 min, seven spanned 60 min on 15:30 because the cadence, not the fault, sets it.

## R2 — the close margin is the holder's, the closure width is a stranger's

`need_mib 3800 + 256 = 4056` was admitted this round (6224 free at the pick), and the holder took **3482** — inside its own claim, so the admission test passed on the admitted side exactly as `rulings/2026-10-23-a-permanent-exclusion-is-a-live-margin-not-a-filed-number` R1 requires it to be stated (need+headroom vs a **dated** idle-free reading). Then:

* with the unowned Bonsai tenant's 1364 MiB present: used 5154, free 2737, gate missed by **1552**;
* remove only that unowned tenant: used 3790, free 4101, gate still missed by **188**.

So the *sign* belongs to the planner's 4B holder (on the 10-14 footprint table it alone missed by 164; today the same occupancy misses by 188 for ~24 MiB of unrelated drift), while **the width of the closure — 1552 of the 1552 MiB — belongs to a tenant that holds no lease and is a party to nothing.** A close is therefore a joint statement and must be reported as a list with the residual, never as "the planner closed it by 1552". This is the live-margin rule applied to the closing half, and it is the reason a *future* `open` needs a named absent tenant rather than a free number.

## R3 — the away side: seven windows, zero acquisitions, and the poll has no registered evaluator

Absence measured, not assumed: `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` **rc 1 no match**, `scopes/` = `planner` only, `lease.d/` **absent**, no `arcade` / `kev` / `model-test` process, no `kev`/`arcade` line in `journalctl --user` for 8 h ⇒ **Llama took nothing across a 53-minute window with 1935 MiB of headroom, the seventh such window today** (08:06–09:06, ≤09:41–10:41, 11:29–12:20, 13:06–13:50, ≤14:30–15:30, ≤16:16–17:10) — well over four hours of eligibility, zero acquires.

Recorded as observation, not as a finding against him, **but the mechanism was checked this tick and is reportable to Mike**: Hermes' per-profile job store is `profiles/<name>/cron/jobs.json`, and

* `profiles/llama/cron/jobs.json` — **ABSENT** (only `jobs.json` on this box is `profiles/chilly/cron/jobs.json`, 14102 B);
* `profiles/llama/cron/executions.db` 24576 B, mtime **2026-10-12 06:33**, `executions` table **0 rows**;
* `profiles/llama/cron/ticker_heartbeat` and `ticker_last_success` DO update every second (17:16:51.159, `1792801011.158573 71478`) — the global ticker beats over a directory with nothing in it;
* `profiles/llama/logs/agent.log` last write **07:08** today (10 h idle), `profiles/llama/state.db` 06:36; no `llama`-scoped Hermes process in `ps`; no user unit or timer names kev/arcade.

So the standing authorisation is live and one side of it — the acquirer — shows **no registered evaluator at all**, which is exactly what six-to-seven untaken windows in a day looks like. SCOPE OF THIS CLAIM, stated so it can be falsified: it is about **cron**. A live-session poll would not appear in `jobs.json`, and none is running (`ps` clean, `agent.log` idle 10 h); a poll driven from another box or by hand is outside what this box can see. This is a flag for Mike, not a finding to hand Llama, and not a licence for this watcher to acquire on his behalf.

## Messages: none

* **@ocho — withheld.** The diff is `kev_window`, not a `planner_at` flip; his scoped-planner item closed on the 10:40 and 15:30 4B certificates. A true-but-redundant DM into a closed item is the drop hazard.
* **@llama — withheld.** The fallback clause requires (a) a window still open and (b) him demonstrably not acting across ticks. Free is **2737, i.e. 1552 MiB under the gate**, so a "window open" page would be **FALSE at his read**, and the window is closed anyway. The R3 observation is addressed to Mike.
* None possible mechanically either: `tool_search` for an agent DM returns **no matches** (available sources browser, computer_use, session_search, terminal, todo — the same absence recorded at 09:09, 11:33, 12:34, 13:09, 13:58, 14:36, 15:32, 16:18 and here).

## Touch log

READ-ONLY throughout: `nvidia-smi` (memory/util/temp + `--query-compute-apps`) ×3, `gpu-lease.sh status`, `ps`, `ss -ltnp`, `curl :8080/running`, `journalctl --user` (planner unit, 90 min; and an 8 h grep for kev/arcade), `stat`/`sha256sum` on the record and the capture, `model_cycle_counter.txt`, `arcade_window_watch.sh` and the 10-14 ruling read as text, `profiles/llama/cron/` inventory and `executions.db` opened **read-only** via the text extractor. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner unit and every model **untouched**; nothing acquired, released or loaded; the live holder left serving. Prior art printed by `priorart.py` on two phrasings BEFORE this file existed (421 records: 0.235 `a-window-that-only-opens-when-the-planner-is-down` read in full and EXTENDED, 0.186 `a-window-open-with-no-planner-holder-is-the-one-that-fits`, 0.167 `a-window-from-a-failed-round-that-loaded-cleanly`, 0.136 `a-rung-that-cannot-fit-is-a-scheduled-self-eviction`) and read by eye. Increment filed = R1's round-ladder duration rule and R2's split of sign from width; the R3 absence is a census, and its one new element is the mechanism check (`jobs.json` absent) rather than the count.
