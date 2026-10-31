# A close belongs to the holder that loaded, not to the round that failed

**Date:** 2026-10-22 · tick `arcade-window-watch`, job `67530e415818` (worker scope started 07:01:40; reads 07:01:48–07:03:21 PDT)
**Diff:** `planner_at=planner` **IDENTICAL both sides** → no flip, no `@ocho` DM · **`kev_window=open → closed`**
**Method:** every number below is a read taken this tick — `nvidia-smi` (three timed reads), `--query-compute-apps`, the lease tree on disk, `ps` / `kill -0`, `curl :8080/running` (two reads), `journalctl --user`, `llama-swap.log`, `stat` + `sha256sum`, `sqlite3 -readonly` on Ocho's rows. Nothing is recalled from a prior tick.

## 1. What changed, measured

```
previous   planner_at=planner  kev_window=open
current    planner_at=planner  kev_window=closed   <- this tick
```

Live card, three identical reads at **07:03:16.455 / 07:03:18.492 / 07:03:20.528**:

| read | total | used | free | util | temp |
|---|---|---|---|---|---|
| 07:03:16 | 8192 MiB | 5252 | **2639** | 0 % | 43 C |
| 07:03:18 | 8192 MiB | 5252 | **2639** | 0 % | 43 C |
| 07:03:20 | 8192 MiB | 5252 | **2639** | 1 % | 43 C |

`--query-compute-apps`: **2812 1364** (Bonsai, `--n-gpu-layers 0`, unleased) + **2813 134** (vision, `--n-gpu-layers 0`, unleased) + **1436690 3482** (the planner 4B). used+free = **7892** = the ~300 MiB driver reservation, so 6268 is the reachable ceiling when the scope is empty.

Free **2639** vs the Kev-4B gate **4289** ⇒ **closed by 1650 MiB**. Note the arithmetic is not the sum: `6268 − 3482 = 2786`, seven points above the measured 2639 — the per-process slab understates the resident footprint by **147 MiB** (KV/compute buffers). The measured free is the number.

## 2. The close edge is a load that fits, and it is dated by two artifacts

- `scopes/planner/record.json` — **495 B**, ino 9840035, **birth 1792677660 = 07:01:00**, mtime `.356494400`, sha256 `171007aeabdc62dd82377e004795e0e888a63440967a799f3acbe9cd56406ca0`, `owner=llama-swap-ocho-planner-4b scope=planner class=batch need_mib=3800 headroom_mib=256 pid=1436604 mode=run ttl=86400 expires_at=1792764060 (2026-10-23 07:01:00)`.
- **pid 1436604 is ALIVE** (`kill -0` + `ps`): wrapper `lstart Thu Oct 22 07:00:59`, `ppid 2809` (llama-swap). Child **1436690 ALIVE, 3482 MiB, LISTEN 127.0.0.1:5806**, cmd `--model …Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file …ocho_grammar.gbnf`.
- **`/running` = one entry**, `ocho-planner-4b state=ready ttl 0`, identical wrapper cmd (two reads, 07:01:48 and 07:03:18).
- Ledger capture **`/tmp/gpu-lease.671DgH`**, 3257 B, **birth 1792677660 (same second as the record)**, mtime `07:01:08.619`: `model loaded` at t+**1.100.908**, `listening on http://127.0.0.1:5806` at t+1.100.913, then **tasks actually served** — task 141 (n_tokens 1655), task 264 (prompt eval 1520 tok @ 2857.31 tok/s, eval 103 tok @ 98.77 tok/s, total 1564.62 ms).
- `chilly_containment/logs/llama-swap.log` mtime **07:01:02.534**, last line `<ocho-planner-4b> Health check passed on http://localhost:5806/health`.
- `4056` (need 3800 + headroom 256) vs `6268` = **fits by 2212** — no swap, nothing evicted.

## 3. The closer was NOT the round, and the slot has two consumers

The round that the monitor would naturally blame ran and **failed 49 s before the wrapper existed**:

```
07:00:03  Starting ocho-planner-polymarket.service
07:00:10  status=1/FAILURE  — 7.200 s wall / 3.124 s CPU / 141.2 M peak
```

and **no `/tmp/gpu-lease.*` capture was born between `gX5Evh` mtime 06:49:03.233 and `671DgH` birth 07:01:00** (11 m 57 s with no load), so that round never loaded anything — it is the standing 9B refusal (6200+256 = 6456 vs 6268 = 188 MiB short), consistent with llama-swap's three `group: starting ocho-planner failed: aborted` + 500 lines immediately before the 4B health pass.

What was still running at 07:00:59, from the journal:

```
07:00:03  Starting ocho-shadow-polymarket.service      (ExecStart: polymarket_paper_trader.py --llm)
07:01:08  Finished  ocho-shadow-polymarket.service     3.236 s CPU / 1 min 5.018 s wall / 152.3 M peak
07:00:59  Finished  ocho-resolve-polymarket.service    55.649 s wall (resolve-only, no planner call)
```

`polymarket_paper_trader.py:253` is `subprocess.run([sys.executable, "call_ocho_planner.py", "--venue", …])` — **the executor unit spawns its own planner**. `pick_model_slot()` (`call_ocho_planner.py:422`, counter read/pos/write at `:455–478`, `MODEL_SLOTS` at `:18`, 60/30/10 weights at `:430`) is the **only** writer of `model_cycle_counter.txt`; the paper trader has no counter reference (grepped). Post-tick artifacts:

- **`plans/latest_plan.json`** 1283 B, mtime **07:01:06.545389736**, `ts 14:01:06.545248Z`, `contract PX-bitcoin-above-80k-on-october-22-2026`, `predicted_prob 0.91`.
- **`ocho_predictions.jsonl`** last two rows **07:01:04.653200Z** and **07:01:06.545462Z**, both `"model_slot": "ocho-planner-4b"`.
- **`model_cycle_counter.txt` = 59229**, mtime **07:01:06.892449942** — the last of ≥2 draws this tick (mtime keeps only the last write).

So in one tick the planner slot was drawn **twice, for two different rungs**: the timer round (drawn ~07:00:09, the 9B that cannot fit) and the executor's subprocess (drawn the 4B, which loaded and produced both plans). **Unproven and stated:** which process's first request started the 07:00:59 group is not directly logged — llama-swap timestamps nothing and the planner's stdout is not in the journal (`journalctl -o cat` for the unit shows systemd lines only). The unit is named from the journal, the process is inferred from the only code path that spawns the planner plus a 65 s lifespan that brackets both the load and both plans.

## 4. The token, and Ocho's item

`planner_at=planner` is identical on both sides ⇒ **no flip, no `@ocho` DM**. For the first time in this token's life the referent it is supposed to certify is *actually true* — a model is loaded under the scoped lease, pid alive, `/running` state=ready — and the token still did not move, because it is an existence token on `record.json` (prior art `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`, cited not re-filed). Ocho's item re-read **closed in his own rows**: `sqlite3 -readonly profiles/ocho/state.db` → `max(id)=16551`, count 16551, last assistant row is the `t_c9e6cef3` scope ruling — **unchanged** from the 10-21 filings, so there is nothing for a DM to close.

## 5. Rules

**R1 — A close belongs to the holder that loaded, never to the round's exit status.** A round can fail while the same slot is loaded by another consumer inside the same minute, so `Result=exit-code` says nothing about occupancy. Date the close on the capture birth + a live pid + `/running`, and name the invoking unit from the journal — this tick's closer is `ocho-shadow-polymarket.service`, a *different unit* from the one whose round failed. Extends `2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly` (there the same round loaded then failed downstream) and supplies the positive unit-level identification that `2026-10-21-a-falsifier-keyed-to-a-clock-cannot-distinguish-a-second-loader` could only name as unresolved at 19:00:57.

**R2 — Price the close in the scope's output, in the same second.** This close was **productive**: 2 plans written at 07:01:04.653 and 07:01:06.545, 4–6 s after `model loaded`. That distinguishes it from every refusal-opened window on file (0 plans over whole bands) and is the reading that answers "did the 3482 MiB buy anything".

**R3 — The counter dates the last draw, not the load.** `model_cycle_counter.txt` is written inside `pick_model_slot()` at draw time, so a single mtime covers every draw in the tick and an earlier draw's time is destroyed. Read the **load** off the capture birth, and never off the counter.

## 6. Absentees and messages

**Kev took nothing.** `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` → **rc 1, no match**; `scopes/` = planner only; `ps` scan for kev/arcade → rc 1. Under his standing operator-approved precedence clause (self-authorized at free ≥ 4289) he did not act across a window that the previous tick measured open at 6268 — recorded, not messaged; he self-runs.

**Messages: none, both premises measured.** No `@ocho` (token identical + item closed in his own rows). No `@llama` fallback: the edge is a **close**, the fallback is scoped to an open window, and 2639 vs 4289 is **1650 MiB the wrong way** — false before it was written, on a channel that can be ~27 min.

**Read-only.** No acquire, no release, no model load, no unit, no config. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner service and the driver are untouched; the 07:01:00 load was the executor unit's own request through llama-swap.

**Prior art:** 348 records; `priorart.py` run twice **before** this file existed — proposal *"a window can close outside the round that owns the slot"* top weak 0.185 / 0.153 / 0.141 / 0.137 / 0.136 / 0.129, and *"a live holder makes the existence token's referent true without the token changing"* top 0.175 / 0.172 / 0.157 / 0.115 — all read by eye; parents cited above, no duplicate.
