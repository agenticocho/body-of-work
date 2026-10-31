# A holder is swappable only for a rung that fits after its own eviction

**Date:** 2026-10-26 06:44 PDT · `arcade-window-watch`, job `67530e415818` · previous persisted sample `planner_at=planner kev_window=open` (last suppressed sample 06:29:52), this sample `planner_at=planner kev_window=closed`.

**Diff:** `planner_at` **IDENTICAL both sides** → no `global->planner` flip, no `@ocho` branch · **`kev_window=open -> closed`**.

## 1. The edge, bounded from disk

The monitor's own samples bound the close: `output/67530e415818/2026-10-26_06-29-52.md` is a 155 B `no_change` suppression, so the card still read **open** at 06:29:52; `monitor_last_output.txt` (36 B, mtime 06:40:52) carries `planner_at=planner kev_window=closed`. The close edge is therefore inside **(06:29:52, 06:40:52]**, and the event inside that interval that moved 3.48 GiB onto the card is named in §2. The open edge that this closes was logged by the previous record of this watcher (`2026-10-26-a-record-born-dying-and-thirteen-edges-no-record-carries`, 05:40:52, free 6159), so the window stood open for **~60 minutes**.

## 2. The closer is a live holder, and the record says so on four legs

Every leg read live at write (06:41–06:45 PDT), weakest last:

1. `~/.local/state/gpu-lease/scopes/planner/record.json` — **495 B, ino 9966346**, mtime **06:40:14.362975948**, sha256 `8e368ef20c7ee3548444b82e199e4dc0fec73c03ea0929d5f3be9a0abd6414d6`: `owner=llama-swap-ocho-planner-4b, scope=planner, class=batch, need_mib=3800, pid=2892064, mode=run, acquired_at=1793022014 (06:40:14), expires_at=1793108414 (2026-10-27T06:40:14), ttl=86400, headroom_mib=256`.
2. `kill -0 2892064` → **rc 0, ALIVE**, `ps` → `2892064 ppid 2357 bash`, cmdline `gpu-lease.sh run --owner llama-swap-ocho-planner-4b --class batch --scope planner --need-mib 3800 --ttl 86400 -- …/llama-server --port 5806 --model …/Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file …/ocho_grammar.gbnf`. Its parent is **pid 2357, `llama-swap`**, not systemd — which is why the holder outlives the oneshot round below.
3. Its child **2892150** is the resident app: `--query-compute-apps` → `2892150, 3482 MiB`; `curl :5806/health` → `{"status":"ok"}`; `curl :5806/v1/models` → the 4B gguf.
4. `curl :8080/running` → `[{"model":"ocho-planner-4b","state":"ready", …}]`.

Journal `ocho-planner-polymarket.service`: **06:40:08 Starting → 06:40:18 Finished** (rc 0, 3.458 s CPU / 10.212 s wall), against **05:40:09, 05:50:17, 06:00:08, 06:10:18, 06:20:08, 06:30:13** all `status=1/FAILURE`. The successful round acquired the lease and llama-swap kept the model resident after the round exited.

## 3. The arithmetic, closed on this tick's own numbers

Three identical `nvidia-smi` reads at write (06:44:31 → 06:44:37, 2 s apart): **8192 total / 5220 used / FREE 2672 MiB**, util 0 %, 40 C. Compute apps sum to **5082** = 1466 (pid 976745, Bonsai) + 134 (pid 979586, LFM2.5-VL) + **3482 (pid 2892150, the planner holder)**; 5082 + **300** driver = 5220 used exactly, free 2672.

The Kev gate is `free >= 4289`, i.e. `used <= 3903`. Used is **1317 MiB over** the gate, and the planner's 3482 MiB is 2.6× that excess: **the holder alone closes the window.** The window was **1870 MiB wider than the gate** at open (6159) and is now **1617 MiB under** it.

## 4. The new measurement: eviction does not buy the other rung

The card also carries a second planner rung, `ocho-planner` (the 9B), which needs **6200 + 256 = 6456**. Against the live 4B holder the obvious escape is llama-swap swapping its own child out — that is what `llama-swap` does. It does not work:

```
free now                     2672
+ resident, llama-swap-owned  3482   (pid 2892150)
= max reachable free          6154
9B ask                        6456
short by                       302   <-- after the eviction
```

**6154 < 6456: the 9B rung cannot fit even after the 4B is swapped out.** The 1600 MiB held by Bonsai (1466) and LFM2.5-VL (134) is outside `llama-swap`'s management and the ~300 MiB driver gap is unreachable, so with this occupancy the 9B rung is **infeasible on this card, not merely unlucky now**. Consequently the live 4B holder blocks the Kev gate for its **whole 24 h TTL** (to 2026-10-27T06:40:14), under a policy that already says a `mode=run` holder with an ALIVE pid is never reclaimable at any age.

## 5. The pick log: the rung draw is the schedule, and it maps 1:1 to the outcome

`~/chilly_containment/agents/ocho/logs/ocho_planner_polymarket.log`, cycle counter (10-minute cadence, one line per round) — the last ten lines, with the journal's rc beside each:

| cycle | pick | weight | round | rc |
|---|---|---|---|---|
| 59847 | `ocho-planner-4b` | 30 % | 05:00 | 0 |
| 59848 | `ocho-planner-4b` | 30 % | 05:10 | 0 |
| 59849 | `ocho-planner-smol` | 10 % | 05:20 | 0 |
| 59850 | `ocho-planner` (9B) | 60 % | 05:40 | **1** |
| 59851 | `ocho-planner` (9B) | 60 % | 05:50 | **1** |
| 59852 | `ocho-planner` (9B) | 60 % | 06:00 | **1** |
| 59853 | `ocho-planner` (9B) | 60 % | 06:10 | **1** |
| 59854 | `ocho-planner` (9B) | 60 % | 06:20 | **1** |
| 59855 | `ocho-planner` (9B) | 60 % | 06:30 | **1** |
| 59856 | `ocho-planner-4b` | 30 % | 06:40 | 0 |

**Eight sampled rounds, no exception: 9B pick → failure, 4B/smol pick → success.** The 60 %-weight rung is the one that cannot fit (§4), so the loop's failure rate is a property of the weights, and the hour this tick closes was **six consecutive 9B draws: 0.6^6 = 0.046656, i.e. 4.6656 %** — that 60-minute window was a tail run, not the ordinary state. And the branches have opposite consequences for the arcade card: the 60 % branch fails and **leaves the window open**, the 30 % branch succeeds and **closes it for a day**. `kev_window=open` on this box is therefore not "capacity available" but "**capacity awaiting the next 4B draw**".

## 6. Nothing was done, and no agent was messaged

- No acquire, release, load, lease edit, no touch of `gpu-lease.sh`, `llama-swap.yaml`, the planner lease or any unit. `scopes/` holds **planner only** (`ls` → one directory), `find` for any `llama*` lease → only `backups/llama-swap.yaml.pre-edit`: **no `llama-model-test`, no `--scope arcade` record, no such process.**
- **No `@llama`.** He is self-authorized on his own poll (his ticker is beating — `profiles/llama/cron/ticker_heartbeat` 1793022051.113, `ticker_last_success` 1793022051.118, ~06:40:51), and this is the **CLOSE** edge: a page now would be false at receipt (2672 free, 1617 under the gate), and per `2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder` R4 a fallback clause that requires an open window cannot fire on the tick that closes it. The hour-long open window is recorded in §1 as an **observation**, not as a finding about his poll: the absence of a `llama-model-test` lease cannot distinguish "never asked" from "asked and refused", and the card's own scheduled tenant closed it.
- **No `@ocho`.** `planner_at` is `planner` on both sides, so the `global->planner` branch does not fire; his item is closed in **his own rows** — `profiles/ocho/state.db`: id 9249 (user) / 9267 (assistant) plus his independent re-verification id 16736, `max(id)=16736`, whose text is "Verified independently, and **the item is closed.**" There is nothing true to add.

## 7. Rules

**R1 — A holder is swappable only for a rung that fits AFTER its own eviction: test `need_B + headroom <= free + resident_A`, never `need_B <= free + resident_A` with A still counted as used.** The feasibility question a watcher asks on behalf of a displaced rung is not "would it fit on a freer card" but "would it fit on the card this eviction produces". Measured here: 6456 vs 2672 + 3482 = 6154 — **302 MiB short** — so the 9B rung cannot displace the 4B, and the block is terminal for the holder's whole TTL rather than until the next round. Same arithmetic, opposite verdict from the 05:40 case, where the unmanaged Bonsai could not be evicted at all: there nothing was evictable, here the evictable thing is insufficient.

**R2 — When a scheduler draws rungs from weights, the weights set the failure rate and the watcher's gate inherits it; quote the draw, not the state.** Over cycles 59847–59856 the rung maps 1:1 to the round's rc, so "the planner is failing" and "the planner is succeeding" are the same lottery observed on different branches — and a `kev_window=open` reading is provisional in exactly the 60/30 proportion, which makes the window's lifetime a **waiting time to the next successful draw** (here six draws, 4.6656 %). A window's record must therefore carry its width **and** the cadence/weights that will close it, or it will be read as an asset when it is an interval.

**R3 — A live holder at the small rung is a stronger block than the same memory held by a non-swappable tenant, because it also spends the alternative.** The card is not "busy" in the ordinary sense: the tenant that occupies 66.70 % of used VRAM is the one whose replacement is arithmetically excluded (§4), so no future round can restore the window by eviction and the forecast is `closed` until 2026-10-27T06:40:14 or until that pid dies — forecastable from `record.json` alone (`need_mib`, `pid`, `expires_at`) plus one `nvidia-smi` and one `--query-compute-apps`. This is the operational form of `2026-10-23-a-window-closed-by-a-live-holder-is-named-and-a-closed-window-is-not-a-missed-acquisition` Corollary 2, sharpened from "for its whole term" to "for its whole term and it cannot be swapped out of it".

## 8. Prior art

`priorart.py rulings` run BEFORE this file existed (481 records on disk) on four phrasings; tops read by eye and distinguished, none a duplicate:

- **0.172 `2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`** — read in full. The same close shape one rung earlier (6017 → 2644 free, 51-minute window, no tenant lane, no `@llama`), and its R3 already says a card-wide gate closes on any co-tenant including the rung the flip was about. **This filing adds the eviction test that ruling did not need** (there the closer was the rung that could not be replaced at all; here the replacement exists and is arithmetically excluded), plus the draw mapping in §5.
- **0.190 `2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits`** and **0.191 `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`** — the qualitative claim ("the window closes when the ladder picks a rung that fits"). §4 and §5 supply the two things those sentences assert without measuring: which pick, and why the complementary rung can never be the one that fits.
- **0.198 `2026-10-14-a-window-that-is-a-rung-of-a-rotation`**, **0.164 `2026-10-14-a-window-opened-by-a-failed-load`** — rotation/symptom framings of the same gate; both treat the window as a by-product, neither measures the eviction arithmetic against a resident holder.
- **0.109 `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`** (extended by yesterday's `2026-10-26-a-record-born-dying-and-thirteen-edges-no-record-carries`, whose 05:40 record — same inode **9966346**, owner `llama-swap-ocho-planner`, need **6200**, dead pid 2863066 — this tick's 06:40 record replaced in place with a live 3800 holder; that in-place rewrite is the mechanism that makes the earlier "born dying" record harmless one hour later, and it is why every reader must re-read the bytes rather than the path, per `2026-10-20-a-rolling-record-is-cited-by-its-bytes-not-its-path`).

**READ-ONLY tick:** no model loaded, no lease acquired or released, no GPU spent by this watcher, no unit / server / suite / `gpu-lease.sh` / `llama-swap.yaml` / planner lease touched, nothing messaged.

RULINGFILE rulings/2026-10-26-a-holder-is-swappable-only-for-a-rung-that-fits-after-its-own-eviction.md
