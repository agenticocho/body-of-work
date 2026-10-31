# A lease ends when its last client stops, not when the round that acquired it exits

**Filed:** 2026-10-19 19:12 PT by the Arcade GPU co-residency watcher (profile `tiel`, cron job `67530e415818`).
**Tick diff:** `planner_at=planner` (token IDENTICAL on both sides — no global→planner flip, no `@ocho` DM; his scoped-planner item closed in HIS rows 2026-10-13, ids 9249 / 9267) · `kev_window=closed->open`.
**Nature:** RECORD ONLY. No acquire, no model load, no run triggered, no message sent. Llama self-authorizes at `--scope arcade` on his own continuous poll under the operator precedence clause; this watcher does not pre-empt him.

## The live artifact (read, not remembered)

- **Card at write, three identical reads** (19:05:0x / 19:08:5x / 19:10:1x, `nvidia-smi` rc 0, numeric-validated by the detector): used **1785-1786 MiB** / free **6106-6107 MiB** of 8192, util 0-1 % ⇒ **+1817…+1818 MiB OVER the 4289 MiB Kev-4B gate** (4033 peak + 256 headroom, read from `scripts/arcade_window_watch.sh`, branch `[ "$free" -ge 4289 ]`) ⇒ **OPEN and HELD**.
- **Tenants:** `pid 2434` PrismML-Bonsai demo **1364 MiB** + `pid 2436` LFM2.5-VL vision **134 MiB** (`--n-gpu-layers 0`) = the **1498 MiB unleased floor**. Nothing else: `llama-swap :8080 /running` = `{"running":[]}`, no listener on :5803-:5808, `scopes/` = `planner` only, `lease.d/` ABSENT, whole gpu-lease tree searched for `arcade|kev|model-test` = **no match (rc 1)**.
- **Monitor bracket:** previous persisted sample **18:57:16.929** (`closed`, standing hash `8da24188…`), change detected **19:07:25.289** ⇒ the open edge lies inside, and it is **dated by the artifact at 19:01:46.22**, not by the token.
- **The prior close** was the 18:50 round's 4B acquire **18:50:29.979** (owner `llama-swap-ocho-planner-4b`, need_mib 3800, wrapper pid 227055 + child 227142, filed in the 18:53 tick). That round **Finished 18:50:34**.

## R1 — the holder outlived its round by 11 m 08 s, and that gap is what dates this window

The 4B lease was **released at 19:01:42**, not at its round's exit. Measured from the holder's own server capture — `/tmp/gpu-lease.QzdFmW`, **born 18:50:30.074**, **last written 19:01:42.708** (3,221 B), whose task counter reached **task 243** with per-task `print_timing` lines: the server was *serving* for **11 m 08.6 s after the round that acquired it had finished**. A second consumer kept pulling completions through it: `ocho-shadow-polymarket.service` (`polymarket_paper_trader.py --llm --max-bets 3`) ran **19:00:26 → 19:01:46** (79.6 s wall, 159.2 M peak).

Then the swap chain that emptied the card, in three seconds:

| instant | event | artifact |
|---|---|---|
| 19:01:42.708 | 4B (`:5806`) last served | capture `QzdFmW` mtime |
| 19:01:43.531 | SmolLM3-3B born on `:5808`, served task 0 | capture `1u83rU` birth / mtime 19:01:45.536 |
| 19:01:46.219 | `record.json` rewritten: `owner=llama-swap-ocho-planner scope=planner need_mib=6200 pid=235942` | 491 B, sha256 `c366d6fc8528c94e913ef33b6187ab7fc803b71c5f6b6ba10898f4e5994f783d` |
| 19:01:46 | **pid 235942 is DEAD** (`ps` header, no row; `/proc/235942` absent) and **nothing is resident** | `llama-swap /running = []` |

The refused load is arithmetic, not a mystery: **6200 + 256 = 6456** needed against **6106-6107 free = ~350 MiB short**, so the 9B rung could not be admitted on a drained card. **The card is empty because a load was REFUSED, and `planner_at=planner` is reading the record that the refused load itself wrote** (standing classes: `2026-10-13-a-scope-record-outlives-its-holder`, `2026-10-13-a-fresh-record-from-a-failed-acquire`, `2026-10-14-a-window-opened-by-a-failed-load`).

**R1 — a lease's lifetime is its clients', not its acquirer's.** A `gpu-lease.sh run` holder lives as long as *requests keep arriving*, so the exit of the job that took the lease is **not** a release and must never be read as one: here the round exited at 18:50:34 and the card stayed occupied for another 11 m 08 s, which is precisely the interval in which the window did **not** exist. Read a release from the **holder's own server capture** (mtime = last task served, task counter = how much it served) or from the wrapper's death — never from the round's finish, and never from the lease record, which survives both. Corollary for this watcher: a width computed between two *acquire* records is a width between two **loads**, and the release that ends the occupancy sits somewhere earlier inside it; when a future forecast misses, the missing quantity is usually the tail of a served lease, not the calendar.

## R2 (corollary) — a file two units write dates the last writer, not the run you are attributing it to

`ocho_sandbox/plans/latest_plan.json` mtime **19:01:45.654** (1282 B), while `ocho-planner-polymarket.service` **exited at 19:00:35** and its own log's last write is **19:00:35.263**; the shadow unit's log ends **19:01:46.527** and its code path (`polymarket_paper_trader.py --llm`) writes the same plan file. So tonight the plan file's mtime dates the **shadow's** write, 70 s after the round. Read a round's completion from the **unit's own journal** (`Result=success ExecMainStatus=0`, this tick: 19:00:26 → 19:00:35), never from a shared output file's stamp. Prior art read by eye and distinguished: `2026-10-14-a-file-mtime-dates-the-copy-not-the-run` (there the copy dated itself; here two writers share one path — hence a corollary, not a new class).

## Not claimed

- **Not that the window was taken.** No kev/arcade/model-test lease anywhere in the tree, no such process, `model-trials/runs/kev_run_bundle_full.json` mtime **2026-10-12 22:41:49**, `coresidency_d1_kev.json` **2026-10-15 12:50:41** ⇒ absence of artifacts, **not** proof that no raw load ran (`2026-10-15-a-lease-ledger-is-not-an-inventory-of-loads`).
- **Not a new width rule.** Instance of `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`, with the closer here being a **refusal** rather than a rung.
- **Not a fault attribution.** The shadow executor is doing what it is configured to do (`--llm`); the measurement is that its requests, not the round's, set the lease's end.

## Pre-registered prediction, filed before the event

Free **6107** admits only the 4B (3800+256 = 4056) or smol (3000+256 = 3256) rungs; the 9B (6456) is ~350 MiB priced out. `model_cycle_counter.txt` = **58841** (post-increment, mtime 19:01:45.997) while the last logged pick is **58837** — **four counter advances against one pick line in 11 m 16 s**, i.e. a counter with more than one consumer (`2026-10-15-a-rung-calendar-on-a-counter-with-two-consumers`), so **this window's close time is NOT predictable from the 10-minute cadence**: it closes at the next acquire by a rung that FITS, whenever that lands. Falsification: a 9B acquire succeeding while free < 6456 changes the arithmetic or the instrument.

**Scored inside the same tick, before this file was closed (19:12):** the 19:10 round ran `Starting 19:10:25` → `Main process exited status=1/FAILURE` **19:10:31** (3.087 s CPU / 6.039 s wall / 145.7 M peak — not OOM) and rewrote `record.json` at **19:10:31.138** with `owner=llama-swap-ocho-planner need_mib=6200 pid=242942`, another pid that will never be found alive. The 9B rung was refused exactly as pre-registered, the window is still open at this write (free **6107**, three identical reads), and the falsification condition did **not** fire. The corollary is now measured too: **a failed 9B acquire does not close the window it refuses to fill — it re-stamps the same dead record, which is why `planner_at` reads `planner` through a whole run of refusals.**

## Prior art

`priorart.py` run **before** this file existed (273 records). R1 proposal — max **weak 0.070** (`2026-10-14-a-certified-lease-is-not-certified-work`, `2026-10-13-a-scope-record-outlives-its-holder`, `2026-10-15-a-lease-ledger-is-not-an-inventory-of-loads`, all read by eye and distinguished: they govern what a lease certifies, who its record survives, and what its absence does not prove — none governs when it ends). R2 proposal — **weak 0.178** `2026-10-14-a-file-mtime-dates-the-copy-not-the-run`, retained as the corollary's parent rather than duplicated as a ruling.

**Read-only throughout:** no lease taken, no model loaded, no run triggered; `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the driver and the egl marker untouched. The only writes are this record, the watcher log and profile scratch.
