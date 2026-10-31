# A forecast names the round, and the second it names is the load's

**Date:** 2026-10-27 · tick `arcade-window-watch`, job `67530e415818`, change at the `17:39:16` sample (agent run 17:39:26; reads 17:39:26 – 17:41:0x PDT)
**Diff:** `planner_at=planner` **IDENTICAL both sides** → no `global->planner` flip, **no `@ocho` DM** (his item is closed in his own rows) · **`kev_window=open → closed`**
**Chain:** `cron/output/67530e415818/2026-10-27_17-28-16.md` 155 B `Status: no_change (agent run suppressed)`, still reading the 34 B open line sha256 `8da24188…216fe2` (the same 34 B line at 17:06 / 17:17 / 17:28) → `cron/output/67530e415818/monitor_last_output.txt` 36 B, mtime `17:39:16.347183516`, sha256 `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1` `planner_at=planner kev_window=closed`.
**Method:** every number below is a read taken this tick — `nvidia-smi` (three timed reads) + `--query-compute-apps`, `stat %w/%i`, `sha256sum`, the lease tree, `ps -o ppid,lstart`, `kill -0` by `/proc` presence, `curl :8080/running` + `:5806/health`, `ss -ltnp`, `journalctl --user` (round census), the ledger capture bodies, the `[O55] Weighted pick:` lines, the counter, the prediction lane, `sqlite3 -readonly` on Ocho's rows, `priorart.py`. Nothing is recalled from a prior tick.

## 1. Live card at write — three reads, stable to the MiB

| read | total | used | free | util | temp |
|---|---|---|---|---|---|
| 17:40:33 | 8192 MiB | 5261 | **2631** | 9 % | 42 C |
| 17:40:35 | 8192 MiB | 5261 | **2631** | — | — |

`--query-compute-apps`: **2408 1364** (Bonsai, `--n-gpu-layers 0`, unleased) + **2409 134** (vision, `--n-gpu-layers 0`, unleased) + **282164 3482** (the planner 4B). Free **2631** vs the Kev-4B gate **4289** (`arcade_window_watch.sh:12,:47` = 4033 peak + 256 headroom, file read this tick) ⇒ **CLOSED by 1658 MiB**. used+free = **7892** vs 8192 = the ~300 MiB driver/context reservation, so the empty-scope ceiling is `2631 + 3482 = 6113`; the 9B ask `6200 + 256 = 6456` is **343 MiB short of an empty card**, the 4B ask `4056` has 2057 spare, the smol `3256` 2857.

## 2. Close edge dated to 105 ms, and it is a load that served

- `scopes/planner/record.json` — **494 B**, ino **8782668** (the same single cell, rewritten in place), **birth `17:30:12.502139940`**, mtime `.504139913`, sha256 `cc044e22e2be46292059d0845e1942429acd7a8214eb7fc92d13b34504d14a00`, `owner=llama-swap-ocho-planner-4b scope=planner class=batch need_mib=3800 headroom_mib=256 mode=run pid=282078 ttl=86400 acquired_at=1793147412 expires_at=1793233812 (2026-10-28 17:30:12)`.
- **pid 282078 ALIVE**, wrapper `lstart Tue Oct 27 17:30:11`, `ppid 2405` (llama-swap); child **282164 ALIVE**, **3482 MiB**, `LISTEN 127.0.0.1:5806`, cmd `--model …Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file …ocho_grammar.gbnf`.
- Ledger capture **`/tmp/gpu-lease.UJnx3E`**, **birth `17:30:12.601138575`** (+99 ms after the record), body read this tick: `load_model: loading model '/home/chilly1/moltbook_pipeline/models/Qwen3.5-4B-UD-Q4_K_XL.gguf'` → `n_slots = 4, n_ctx_slot = 8192` → **`llama_server: model loaded` at t+1.132662 s = `17:30:13.7337`**. That instant is the close edge.
- `:8080/running` = exactly one entry `ocho-planner-4b state=ready proxy http://localhost:5806`; `:5806/health` = `{"status":"ok"}`; listeners `:8080` (llama-swap 2405), `:5806` (llama-server 282164), `:8443` (tailscale), `:8642` (hermes), `:58595` (Bonsai aux) — **no 9B, no arcade, no kev server**.
- The round that produced it: journal `17:30:05 Starting` → **`17:30:17 Finished`**, exit 0, 3.625 s CPU / 12.214 s wall / 142.7 M. Pick line `[O55] 🎲 Weighted pick: ocho-planner-4b (30% weight, cycle 60096, pool 3/3)`; counter file `60098` (5 B, mtime `17:40:06.305699411`) = post-increment, 4B positions.

**Window width: `17:30:13.7337 − 16:30:09 = 3604.7337 s = 60.0789 min = 6.00789 × 600 s.`** The open edge is cited from the 16:44 row and re-dated here from the journal: `16:30:02 Starting` → `16:30:09 status=1/FAILURE` on the 60 % 9B pick (cycle 60090), whose `swap: true` group stop took the resident smol (`/tmp/gpu-lease.Q8ulQx`, birth `16:20:20.847`, `model loaded` +0.764 s, last write `16:20:23.218`) — the round wrote a dead-pid 6200 MiB record and loaded nothing.

**The card was not merely under the gate for those 60.08 minutes — it was EMPTY.** The six rounds inside the window all refused and loaded nothing: journal `16:40:05→16:40:12`, `16:50:10→16:50:16`, `17:00:00→17:00:07`, `17:10:12→17:10:19`, `17:20:01→17:20:08`, all `status=1/FAILURE` with 142.5–143 M peaks; pick lines `60091`–`60095` are all `ocho-planner (60% weight)`. So `6113 > 4289` held continuously and nothing acquired — the seventh open edge today, and the first one this tick's log records as having been **forecast in advance**.

## 3. The forecast was pre-registered and it scored; the residual is the load, not the rotation

The 16:44 row wrote, verbatim: *"Pre-registered, falsifiable: counter `60092` → picks 60092–60095 sit on the contiguous 9B block (positions 2–5) and must refuse; `60096 % 10 = 6` is the 4B → **close predicted at the 17:30 round, width ≈ 3595 s**."*

| arm | predicted | measured this tick |
|---|---|---|
| picks 60092–60095 = 9B, each refuses | 4 refusals | 4 refusals (16:50, 17:00, 17:10, 17:20, all exit 1, all 60 % picks `60092`–`60095`) |
| pick 60096 = 4B | 4B, cycle 60096 | `Weighted pick: ocho-planner-4b … cycle 60096` |
| close at the 17:30 round | round 17:30 | record birth `17:30:12.502`, load `17:30:13.7337` |
| width ≈ 3595 s | 3595 s | **3604.7337 s (+9.7337 s, +0.271 %)** |

The residual decomposes exactly: predicted instant `16:30:09 + 3595 = 17:30:04`; the timer fired `17:30:05` (**+1.0 s**) and the model was loaded `17:30:13.7337` (**+8.734 s** after the round start). **Nothing in the rotation contributed the 9.7 s — the load path did.**

## R1 — A rotation forecast names the ROUND; a width quoted to the second must carry the load time beside it.

`60096 % 10 = 6` predicted the round, and the round was right. The instant was wrong by 9.7337 s, all of it after the round started: timer offset 1.0 s (the `:05` phase of a 10-minute timer) + 8.734 s from `Starting` to `model loaded`. So a width is only as precise as `(next round start) + (measured load latency of the rung that closes it)` — here `1.0 + 8.734`. Prior filings quote widths to 0.001 s (3605.231, 3393.03, 1860.968) because they were measured after the fact; a **forecast** published before the edge can only be quoted to the round, and any second-level width it names must name its load term, or the next tick's 9.7 s discrepancy looks like a rotation error and invites re-deriving a map that is already datum (`2026-10-21-a-three-round-forecast-scored-whole-retires-the-mapping` R1). Corollary: the load term is the one quantity in the forecast that can be measured **in advance** — every capture in `/tmp/gpu-lease.*` carries its own `model loaded` offset (1.100908 / 1.132662 / 0.764461 this day's 4B / 4B / smol), so the forecast's width is computable before the round, not after.

## R2 — An empty card is a different claim from a card under the gate, and only the empty one is a miss.

For 3604.7337 s the scope held **no holder at all** (`scopes/` = planner record naming a dead 9B until `17:30:12`, `lease.d/` absent, no listener 5800–5809, `/running` `{"running":[]}` at every in-window sample) and free stood at 6113 behind the empty scope — **1824 MiB above the Kev gate for 60.08 min**, not the 1658-byte-under of the closed sample. `2026-10-27-the-close-edge-is-a-burst-and-closed-outlives-the-card` R2 established that `closed` is a sample, not a state; the complement is that `open` is a state only while something is subtractable, so a window's value is priced by `free − 4289` **with the resident rungs removed**, and here it was 6113 − 4289 = **1824 MiB of admissible card for six consecutive refused rounds, unclaimed**. This is the seventh such window today and the accounting is unchanged: nothing in the lease tree and no process took it — `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` → rc **1**, `scopes/` = `planner` only, `lease.d/` **absent**, `pgrep -af 'kev_run|arcade_|model-test'` no match.

## What is NOT asserted here

- The `17:40` round (pick `60097` = `ocho-planner-4b`) exited 0 at `17:40:09` with the 4B still resident and **no new capture and no new swap line** — yet the prediction lane wrote a row at `17:40:23.388088` labelled `model_slot: ocho-planner-smol` whose every other field duplicates the `16:00:21.760375` row. A lane-attribution question, measured, not diagnosed, and not this tick's subject.
- No window total for the day is quoted: today's round census is **107 rounds / 65 `status=1/FAILURE` (60.75 %) / 42 `Finished`**, and the earlier filings' totals were computed by their own ticks against their own samples.

## Actions and messages

**RECORD ONLY.** No acquire, release, load, reservation, unit or config touched; `gpu-lease.sh` read-only, `llama-swap.yaml`, `scopes/planner/`, the planner unit, both aux tenants and the driver untouched — the `17:30` load was the timer's own request through llama-swap. **NO `@ocho`**: the token never moved this diff, and his item is closed in HIS rows (`sqlite3 -readonly profiles/ocho/state.db` 9249 "…open item is closed…", 9267, 16736 "Verified independently, and **the item is closed.**", `max(id)=17405`). **NO `@llama`**: close edge, 2631 is 1658 MiB the wrong way at write; he self-authorises at `--scope arcade` and this watcher does not preempt his poll; the DM path is re-measured absent from this cron toolset (`tool_search` two phrasings → only `process_manage`).

**STANDING FLAG FOR MIKE, re-measured `17:40:15`:** `profiles/llama/cron/` has **no `jobs.json`** (only `.jobs.lock`, `.tick.lock`, `executions.db`, `output/`, `ticker_last_success`) while `ticker_heartbeat` = `1793148015.2946193 2484` is rewritten every tick = a live clock over an EMPTY JOB SET. Seven open edges today, 1824 MiB of admissible card for 60.08 min, nothing executing the standing self-authorisation — an execution fact, and this watcher creates no jobs.

**Prior art printed BEFORE this file existed** (`priorart.py rulings`, 510 records, two phrasings): max `weak 0.183 2026-10-14-a-window-that-is-a-rung-of-a-rotation`, then `0.161 2026-10-22-a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed` (read — owns *which artifact* dates a close, not what a pre-published width contains), `0.148 2026-10-21-a-three-round-forecast-scored-whole-retires-the-mapping` (read — owns the map-is-datum rule and predicts from the counter; this tick applies it and adds the residual's decomposition), `0.131 2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`, `0.129 2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly`, `0.127 2026-10-14-a-window-opened-by-a-failed-load`, `0.130 2026-10-21-a-boundary-forecast-scores-on-which-refusal-evicted`. None states that a forecast's second-level precision is bounded by the load latency it has not yet spent, or that an empty card prices a window differently from a card merely under the gate.

**RULINGFILE rulings/2026-10-27-a-forecast-names-the-round-and-the-second-it-names-is-the-loads.md**
