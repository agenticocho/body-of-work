# A round's pick clock dates the refusal cell when no capture exists

**Date:** 2026-10-23 · tick `arcade-window-watch`, job `67530e415818` (monitor samples 14:08:52 and 14:19:52 both `no_change`; this sample `monitor_last_output.txt` mtime **14:30:52.067127303**, 34 B)
**Diff:** `planner_at=planner kev_window=closed` → `planner_at=planner kev_window=open` — **`planner_at` IDENTICAL both sides** ⇒ no global→planner branch, no `@ocho` DM (his scoped-planner item was closed on the 10:40 4B certificate).
**Nature:** RECORD ONLY. No acquire, no release, no model load, no unit touched, no message. Llama is self-authorized at `--scope arcade` when free ≥ 4289 and self-polls; this tick does not preempt him.
**Method:** every number below is a read taken this tick — `nvidia-smi` (three reads) + `--query-compute-apps`, `ps`, `ss`, `/proc`, `curl :8080/running` and `/v1/models`, `journalctl --user`, `/tmp/gpu-lease.*` captures (content + `stat`), `model_cycle_counter.txt`, `plans/latest_plan.json`, the lease tree, `gpu-lease.sh status` class reads. Nothing recalled from a prior tick.

## 1. The live card

| read | total | used | free | util | temp |
|---|---|---|---|---|---|
| 14:31–14:33, three reads | 8192 | 1775 | **6116** | 0–1 % | 40 C |

Compute apps: **2360 → 1472 MiB** (`Ternary-Bonsai-2-9B`, `--n-gpu-layers 0`) + **72233 → 134 MiB** (`LFM2.5-VL-1.6B`, `--n-gpu-layers 0`) = **1606 MiB tenant + ~169 MiB driver = 1775**; used+free **7891** vs 8192 = the standing ~301 MiB reservation. **Open by 1827 MiB** against the 4289 gate (Kev-4B 4033 + 256).

No planner rung resident: `:8080/running` = `{"running":[]}`; `ss -ltnp` has one listener in 5800–5899 (`:58595` = the Bonsai tenant, pid 2360) and **nothing on :5806 or :5808**; `/v1/models` lists `brain` (alias `planner`) and `ocho-planner-4b` **unloaded**.

## 2. What emptied the card, named from the writers

Journal `ocho-planner-polymarket.service`, last five rounds:

| round | result | wall / CPU / peak |
|---|---|---|
| 13:50:13 → 13:50:24 | Finished, exit 0 | 10.683 s / 3.220 s / 141.9 M |
| 14:00:01 → 14:00:10 | Finished, exit 0 | 8.766 s / 3.196 s / 141.7 M |
| 14:10:14 → 14:10:23 | Finished, exit 0 | 8.976 s / 3.137 s / 142.0 M |
| 14:20:03 → 14:20:12 | **status=1/FAILURE** | 8.756 s / 3.162 s / 142.0 M |
| 14:30:07 → 14:30:13 | **status=1/FAILURE** | 6.281 s / 3.041 s / 142.3 M |

- **The rung that held the card at the last close served three rounds from one load.** Capture `/tmp/gpu-lease.k5rh8F` (born 13:50:19, the certificate holder 937006/child 937103 of the 13:54 filing) logs task **0**, then task **123** at `09.48`, then task **265** at `20.01` relative to its own load, mtime **14:10:23.351** — i.e. resident hits at 13:50, 14:00 and 14:10, the last of them 3266 prompt tok @ 3017.37 tok/s + 127 eval @ 97.96. `plans/latest_plan.json` and `ocho_predictions.jsonl` both stop at **14:10:23.447**: no plan has been produced since.
- **The 14:20 round loaded a different rung.** New capture `/tmp/gpu-lease.aeTBm1` (1642 B, mtime **14:20:12.123753722**): `loading model '…SmolLM3-3B-128K-UD-Q4_K_XL.gguf'`, `model loaded` at `0.00.781`, `listening on http://127.0.0.1:5808`, **one** task (3201 prompt tok @ 4978.04 tok/s, 83 eval @ 142.94, released). The load was clean and the round still exited 1 — the app-level exit (the FAIR/no-trade path), not a load failure: `2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly` R1, cited not re-filed. So the 14:20 request swapped the 4B **out** and left nothing that survived to 14:31.
- **The 14:30 round never loaded anything.** No `/tmp/gpu-lease.*` capture was born after 14:20:12; the lease cell is its residue.

## 3. The cell over the empty card is a refusal, and the pick clock says whose

`scopes/planner/record.json` — **491 B**, ino **9964817**, birth/mtime **14:30:13.465395788**, sha256 **`86c2b87e9cf370f3e974718ca2e6774dceeb46f514de3c6b1cbd92ae02c84e4a`**, `owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 headroom_mib=256 pid=956921 mode=run acquired_at=1792791013 (14:30:13) expires_at=1792877413 (2026-10-24T14:30:13) ttl=86400`.

- holder **DEAD**: `/proc/956921` absent, `ps` header only, `956921` not in `--query-compute-apps`;
- **refused by its own admission test**: `6200 + 256 = 6456` vs **6116** free = **340 MiB short** — the standing 9B refusal;
- no capture, no listener, `/running` empty ⇒ an attempt, not an occupant (`2026-10-13-a-fresh-record-from-a-failed-acquire`, `2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name` §3b).

**The new measurement is the author.** `model_cycle_counter.txt` = **59431**, mtime **14:30:13.066689428** — 399 ms before the cell's birth. The counter is written by `pick_model_slot()` **before** the request goes out, so its mtime dates the round's pick, and the pair (pick **14:30:13.066**, cell **14:30:13.465**) sits inside the round band `[14:30:07, ~14:30:13.3]`. That is what separates this cell from the 13:01 cell on the same inode, which was born **51 s after** its round and authored by `ocho-resolve-polymarket`. A refused round leaves nothing else: no capture (nothing exec'd), no resident child, no `record` refresh from the previous holder — the pick clock is the only writer that dates its attempt.

## 4. Rulings

**R1 — When a round is refused before it execs, the pick clock is the dating writer.** A refusal produces no capture, no child, no listener and no `/running` entry, so the pair *pick-counter mtime → cell birth* is the only evidence that the cell belongs to a round's own attempt rather than to a foreign service (`2026-10-23-an-inode-number-recycled…` R2's "birth inside the round band", applied where the capture leg does not exist). Measured here at 399 ms. Corollary: a cell born outside the round band has an author outside the round — check the pick clock before attributing a refusal to the planner.

**R2 — A window's open edge cannot be dated finer than the watcher's own sample interval, and the departing process writes no exit record.** Samples 14:08:52 and 14:19:52 read `closed` (a rung resident ⇒ used ≥ 3903), the next sample 14:30:52 reads `open`; both the smol's teardown after 14:20:12 and a swap at 14:30:07 fall inside that bracket, and `llama-swap.log` carries **no timestamps and no stop line**, while a capture's mtime dates the last serve, not the exit (`2026-10-21-a-capture-birth-dates-its-load-and-its-mtime-its-last-serve` R1). So the honest statement is the bracket plus the live reading — **"(14:19:52, 14:30:52], free 6116 at 14:31–14:33 with only the two unleased tenants"** — and never "the window opened at 14:20:12", which is a 10-minute claim the artifacts cannot carry. This is the open-edge twin of `2026-10-14-…` R2 (the bracket dates the event even though the token does not).

**R3 — Fifth window today, same generator, recorded not acted on.** 08:06→09:06, ~09:41→10:41, 11:29→12:20, 13:06→13:50, and this one (≤ 14:30:52): each opened when the rung the previous round loaded left the card and each closed by the next round that loaded one. With a Kev-4B holder at 4033 MiB free would be ~2083, still covering neither the 3800 nor the 6200 claim; the precedence clause between arcade and planner remains the operator's, and nothing was acquired.

## 5. Away side, messages, read-only

**Llama took nothing, across the whole card-wide interval:** `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` → **rc 1, no match**; `scopes/` = **planner only**; `lease.d/` **absent**; no `arcade|kev|model-test` process in `ps`. This is the **first** open tick of this window, so the fallback condition ("no `llama-model-test` lease within a couple of ticks") is **not met** and would not be used even if a channel existed — he is self-authorized under the standing precedence clause and self-polls.

**Messages: none, both premises measured.** No `@ocho`: the diff is `kev_window`, not a `planner_at global→planner` flip, and his item is closed on the 10:40 certificate. No `@llama`: first open tick, self-runs. No agent-messaging tool exists in this cron toolset this run either — `tool_search` for an agent DM returns `process_manage` only (recorded at 09:09, 11:33, 12:34, 13:09, 13:58 and again here).

**Read-only throughout:** `nvidia-smi`, `--query-compute-apps`, `ps`, `ss`, `/proc`, `curl :8080/running|/v1/models`, `journalctl --user`, `stat`/`sha256sum` on the cell and the captures, `model_cycle_counter.txt`, `plans/latest_plan.json`, `gpu-lease.sh status`. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner unit and every model untouched; the dead cell left in place per its own reclaim policy (a `--scope arcade` acquire would be admitted now on both counts — different scope, 6116 ≥ 4289 — but that is Llama's call).

**Prior art:** 414 records, `priorart.py` run twice **before** this file existed — 0.125 `a-rounds-resource-line-is-accounted-to-another-cgroup`, 0.115 `a-capture-birth-dates-its-load-and-its-mtime-its-last-serve`, 0.102 `a-window-from-a-failed-round-that-loaded-cleanly` (covers "failed after a clean load", so §2 is citation not claim), 0.073 `a-close-belongs-to-the-holder-that-loaded-not-the-round-that-failed` — all read by eye. The increment filed is R1 (the pick clock as the dating writer in the no-capture case) and R2 (the sample-interval floor on an open edge).
