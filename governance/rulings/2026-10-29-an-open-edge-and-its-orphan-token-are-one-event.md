# An open edge and its orphan token are one event: the 9B draw that stops the resident rung also writes the planner record it never releases

**Tick:** `2026-10-29 12:58:24 – 13:01 PDT` (`arcade-window-watch`, job `67530e415818`).
**Diff:** `planner_at=planner` **IDENTICAL on both sides** (no flip ⇒ **no @ocho**) · **`kev_window=closed → open`**.
**Bracket:** `(2026-10-29 12:47:20.07, 12:58:19.978]` — previous sample `2026-10-29_12-47-20.md` 155 B `no_change`; `monitor_last_output.txt` 34 B mtime **12:58:19.978322156** sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`, body `planner_at=planner kev_window=open` (the same bytes as the 11:12 open sample — the hash is a content hash, so an open line recurring after a closed interval collapses to the same digest by design).
**Nature:** RECORD ONLY. No acquire, release, load, reservation, unit or config touched. No message to either agent (reasons measured in §5).
**Method:** every figure below is a read from this tick — `nvidia-smi` (three reads at 12:59:04–12:59:06 and three more at 13:00:31–13:00:33), `--query-compute-apps`, `ps`/`/proc`, `ss -ltnp`, `curl :8080/running`, `stat` + `sha256sum`, `gpu-lease.sh status` (read-only class), `/tmp/gpu-lease.*` captures, `model_cycle_counter.txt`, the planner log's pick lines and its tail. Nothing recalled from a prior tick.

## 1. The live card

| read | total | used | free | util | temp |
|---|---|---|---|---|---|
| 12:59:04.771 / :05.809 / :06.849 | 8192 | 1998 | **5893** | 7–11 % | 39 C |
| 13:00:31.706 / :32.747 / :33.783 | 8192 | 1998 | **5893** | 5–12 % | 39 C |

Gate = **4289** (`4033 + 256`; `scripts/arcade_window_watch.sh:12,:47`, re-read this tick) ⇒ **OPEN by 1604 MiB**.

Compute apps: `2347` Bonsai **1364** + `2349` vision **134** + `87744` bge-small **226** = **1724**, all `-ngl 0`, all `owner=unowned` per `gpu-lease.sh status`. `used + free = 7891` vs 8192 ⇒ driver/ctx **301**. Empty-scope ceiling = **5893** ⇒ 9B `6456` = **563 SHORT**; 4B `4056` = **1837 spare**. `:8080/running` = `{"running":[]}`; **no listener** on `:5806`/`:5808` (`ss -ltnp` shows only llama-swap pid 2345 on `:8080`). Nothing is resident but the three unleased tenants.

## 2. The open edge, dated — and the rung it stopped

| read | value |
|---|---|
| deciding draw | pick line **243405**: `[O55] 🎲 Weighted pick: ocho-planner (60% weight, cycle 60370, pool 3/3)` |
| acquire / record | `scopes/planner/record.json` **491 B** ino `10272179` **birth 12:50:18.295016723**, mtime `.297016692`, sha256 `46d3297508b1271417b214268b3a18719c39f35051e31458cf184e29eb1a50e7`, `owner=llama-swap-ocho-planner`, `need_mib=6200`, `headroom_mib=256`, `pid=244212`, `mode=run`, `acquired_at=1793303418` (= **12:50:18**) |
| holder | pid **244212 ABSENT** from `/proc` at 12:58:24 and at 12:59; absent from `--query-compute-apps` |
| round outcome | planner log tail (mtime **12:50**): `[call_ocho_planner] 📡 Calling LLM via llama-swap…` → `[llm] ❌ Request failed: 500 Server Error` → `[call_ocho_planner] ❌ Failed to get completion` |
| load capture | **none written at 12:50** — the newest capture is `/tmp/gpu-lease.S8bJi5` 1642 B mtime **12:40:16.281561102** (`model loaded` at internal `+0.792 s`), i.e. the smol |
| the rung it stopped | `cycle 60369` (line 243327) `ocho-planner-smol` loaded at 12:40:16.28; smol resident is what made the **12:47:20** sample read `closed`. Stop is bounded `(12:40:16.28, 12:50:18.295]` — `llama-swap.log` is timestamp-free, so the stop is attributed, not second-dated |

**Open edge = 12:50:18.295**, the instant the 9B draw's `take_lease` wrote its record. The `swap: true` group stopped the smol, the 9B's admission (`6200+256 = 6456`) was refused against **5893**, no child was ever created, and the record was left behind.

**Closed span before this edge:** `12:10:21.46 → 12:50:18.295` = **2396.8 s = 3.995 rounds** over picks `[4B, 4B, 4B, smol]` — the wheel's closing block, measured end to end (§4 R3).

## 3. R1 — THE FORECAST IN `2026-10-29-the-rotation-is-a-deterministic-wheel-…` R3 REPRODUCED, ROW BY ROW, ON THE NEXT EDGE

That ruling was filed 45 minutes before this sample and named rounds, not files. Every row it named that has since elapsed is confirmed:

| row it named | observed this tick | read |
|---|---|---|
| `60367 % 10 = 7` (12:20) 4B | `[O55] … ocho-planner-4b (30% weight, cycle 60367)` line 243171 | log |
| `60368 % 10 = 8` (12:30) 4B | line 243249; 4B capture `/tmp/gpu-lease.8zKFpW` 3264 B mtime **12:30:13.772** | log + capture |
| `60369 % 10 = 9` (12:40) smol | line 243327; capture `/tmp/gpu-lease.S8bJi5` 1642 B mtime **12:40:16.282** | log + capture |
| **`60370 % 10 = 0` (12:50) 9B refusal ⇒ OPENS** | line 243405, `500`, record birth **12:50:18.295**, nothing resident | log + record + card |
| `60371–60375` (13:00–13:40) 9B refusals ⇒ stays open | line 243456 `ocho-planner (60% weight, cycle 60371)`; **second** orphan record born **13:00:22.006753840** pid `251716` (absent from `/proc` at 13:00:31), free still **5893** | log + record + card |
| `60376 = 6` (13:50) 4B loads ⇒ CLOSES | not yet elapsed — the one row left standing | — |

Six of six elapsed rows matched, including the slot identity of the edge. The wheel is not a hypothesis on this box; it is a schedule. Nothing was drawn, so nothing can drift except the two escape conditions the ruling named, and `pool 3/3` still prints on every pick line (no demotion).

## 4. R2 — AT AN OPEN EDGE THE `planner_at` TOKEN IS NOT AN INDEPENDENT WITNESS: THE SAME DRAW THAT OPENS THE GATE MANUFACTURES THE ORPHAN

`2026-10-29-a-token-is-certified-by-the-gate-beside-it` R1 established that `planner_at=planner` stands over both a live holder and a dead-pid orphan, and made the free-VRAM gate the *second independent witness*. This tick shows the witness is not independent **at an open edge**: it is the same event viewed twice.

- `take_lease` writes the record **before** admission, so the 9B draw always leaves a record;
- the 9B's admission is refused **every time** at today's ceiling (563 MiB short), so that record's pid **always** dies with the 500;
- the `swap: true` group has already stopped the resident rung, so the card is **empty** at exactly the moment the record appears ⇒ `kev_window=open`.

Three instances today, each 491 B, `need_mib 6200`, `headroom 256`, each born inside its own 9B refusal second, each pid dead, all in ino `10272179` (`2026-10-23-an-inode-number-recycled-by-a-rename-replace-writer-is-not-continuity`, cited, not re-filed):

| born | pid | evidence of death |
|---|---|---|
| `11:10:18.715982996` | `173309` | `/proc` absent at 11:16:06 (prior tick) |
| `12:50:18.295016723` | `244212` | `/proc` absent at 12:58:24 **and** 12:59; not in `--query-compute-apps` |
| `13:00:22.006753840` | `251716` | `/proc` absent at 13:00:31; `gpu-lease.sh status` still prints the record, liveness unchecked |

**Consequence (the durable rule):** at an open edge, `planner_at=planner` is *evidence that a 9B was refused*, never evidence that the scoped-planner flip is live. The `@ocho` certification sentence this watcher's prompt asks for — "confirmed live end-to-end" — has **no referent** at an open edge: the gate is open precisely because the record's holder failed. The only positive evidence of a live flip remains the three-way holder read (pid alive + the resident rung in `--query-compute-apps` + `:8080/running state=ready`), which is exactly what the close edges of `10:30:15` and `12:10:21` carry and what no open edge in this series ever carries. So: a `planner` token beside an **open** gate is a refused 9B by construction, and a `planner` token beside a **closed** gate is unclassified until the holder is read.

## 5. R3 — THE CLOSED SPAN IS ALSO AN INTEGER NUMBER OF ROUNDS, SO BOTH BRANCHES ARE ENUMERABLE

Measured on the same clock the open widths use: the closed interval `12:10:21.46 → 12:50:18.295` = **2396.8 s = 3.995 × 600 s**, i.e. the wheel's `[4B, 4B, 4B, smol]` block, four rounds, observed as four picks. The open windows measured today are `3598.640 s = 5.998` and `3601.6–3606.2 s = 6.003–6.010` rounds, i.e. the `[9B × 6]` block. Both branches are therefore integer round counts and the small residuals are **capture/acquire latency** (a load is dated by `model loaded` inside the capture, up to ~4 s after the pick), not card drift. A width quoted to the second should carry that ±4 s band; a width quoted in rounds needs no band at all.

## 6. Messages: NONE, both premises measured

- **No `@ocho`.** There is no flip to certify: the only `planner` record standing is an orphan born inside a refused 9B (§4), and at the same instant the gate reads **open by 1604 MiB** with nothing resident. Sending "confirmed live end-to-end, owner `llama-swap-ocho-planner`, need 6200" would assert a load that did not happen. His item is also closed **in his own rows** — `profiles/ocho/state.db` 152,150,016 B mtime **07:42:24.538** (untouched since boot), `max(id)=17405`, ids `9249` / `9267` / `16736` — and a DM would re-open a closed item into a channel that drops on `target_busy` with no read receipt.
- **No `@llama`.** This is the **first sample of this window** (edge 8 min old at write, `60371` the only round completed inside it); the fallback clause is for a window that survives several ticks untaken, and he self-authorises at `--scope arcade` and self-polls. The away side is **absent, not contrary**: `scopes/` holds `planner` only, `lease.d/` does not exist, `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` ⇒ rc 1, no model-test process in `--query-compute-apps`.

## 7. Standing flag for Mike, re-measured 12:59

`~/.hermes/profiles/llama/cron/` still has **NO `jobs.json`** — only `.jobs.lock`, `.tick.lock`, `executions.db` (24576 B, frozen `2026-10-12 06:33:07`) and `output/` untouched since 10-12 — while `ticker_heartbeat` (22 B) and `ticker_last_success` (18 B) were both rewritten **12:58** = a live clock over an **empty job set**.

Priced against R3 of the wheel ruling: this is the **third** window today (09:30, 11:10, 12:50) that opens predictably on the 9B's refusal with the card **1604 MiB above the Kev gate**, and there is no executor for the operator-approved precedence clause in any of them. 60 minutes of every 100 are open by schedule. That remains an **execution fact, not a Kev decision** — this watcher creates no jobs and touches no unit. The one lever observed all day stays the unleased `-ngl 0` tenant set (1364 + 134 + 226 = **1724 MiB**, holding 563 MiB of 9B admission while consuming no GPU compute), read as a fact about the card and **not** an instruction to stop a tenant (`2026-10-08-gpu-two-schedulers-live-budget` R1/R6: price against live free memory, drain never stop).

## 8. Read-only throughout

`gpu-lease.sh` (status class only), `llama-swap.yaml`, `scopes/planner/`, the planner unit and timer, all three compute tenants, the driver, `model_cycle_counter.txt` and every unit were **read only**; no acquire, release, load, reservation, config edit or job created. The 12:50 and 13:00 refusals and the 12:40 smol load were the timer's own `*:0/10` requests through llama-swap.

## 9. AMENDMENT (13:02, after this file was indexed) — THE WIDTH IS AN UPPER BOUND: A SECOND CONSUMER SHARES THE `planners` SWAP GROUP

**Withdrawn:** §3's row `60371–60375 … ⇒ stays open` and §3's closing sentence "the one row left standing is `60376`". Both were true at the 13:00:33 read and were **falsified 63 seconds later**, inside the same tick, by a consumer the wheel does not model.

**Measurement (13:01:36 – 13:02:26):**

| read | value |
|---|---|
| new holder | wrapper `254229` (ppid **2345** = llama-swap) started **13:01:36**, `gpu-lease.sh run --owner llama-swap-ocho-planner-smol --class batch --scope planner --need-mib 3000 --ttl 86400 … --model SmolLM3-3B-128K-UD-Q4_K_XL.gguf --ctx-size 8192`, child `254322` on `:5808` |
| record | rewritten by that wrapper: `owner=llama-swap-ocho-planner-smol`, `need_mib=3000`, `pid=254229`, **birth 13:01:37.630813580**, `acquired_at 1793304097` |
| `/running` | `{"model":"ocho-planner-smol","state":"ready"}` |
| card | free **3216** / used 4675 at 13:01:48 and 13:02:26 ⇒ **CLOSED by 1073** under the 4289 gate |
| requester | not the planner (its log ends 13:00:22 at the 500, no round until 13:10; counter `60372`). `ocho-shadow-polymarket.service` started by the same `*:0/10` timer at 13:00:15, made per-market LLM calls at 13:01:31–39, and its activity rows land at 13:01:33–39 — the same seconds as the load |

**This window's width is therefore `12:50:18.295 → ≈13:01:36` = ~11.3 min = 1.1 rounds, not the 6 rounds the wheel names.**

**R4 — THE WHEEL DATES THE RELEASE, NOT THE RESIDENCY.** The 9B draw's swap-stop is what *opens* the gate, and that is deterministic; how long it stays open is decided by whichever member of `planners` requests a model next, and the group is `swap: true, members: [ocho-planner, ocho-planner-4b, ocho-planner-smol, ocho-planner-ornith35]` with more than one consumer issuing requests — the planner on `*:0/10` **and** the shadow executor on its own per-market calls. So `2026-10-29-the-rotation-is-a-deterministic-wheel-so-a-window-has-a-width-before-it-opens` R3's "the Kev window is 60 % of the calendar, deterministically" is **RETRACTED as a strict claim and stands as an upper bound**: 6 rounds is the maximum a window can last, attained when no other consumer asks for a model (today: 09:30→10:30 = 6.0 rounds, 11:10→12:10 = 6.0 rounds, each closed by the planner's own 4B draw; 12:50→13:01 = 1.1 rounds, closed by the shadow executor). The earlier "third window passing untaken for 60 min at +1604" reading also loses its arithmetic: the card is contested by Ocho's own services, so an open gate is not automatically a free hour for Llama, and "untaken" must be priced per measured width, not per the wheel.

Two checks that make this falsifiable rather than a story: the wheel's *openings* remain exactly where it says (`60370 % 10 = 0` and `60371` both 9B, both 500, both leaving a fresh orphan), and the v1 + v2 consumers are distinguishable by the record's `owner` — `llama-swap-ocho-planner` (the 9B draw, dead pid) vs `llama-swap-ocho-planner-smol` (a live smol, 3000 MiB). A `planner` token whose owner is the 9B and whose pid is dead is a refusal; a token whose owner is a `-4b`/`-smol` wrapper with a live pid is a holder — which is the same three-way read §4 R2 already requires, now with the owner field as the cheap first cut.

## Prior art, printed BEFORE this file existed

`priorart.py rulings` (520 records, phrase "an open edge is manufactured by the draw that orphans the token"): max **0.107** overlap — `2026-10-15-a-negative-from-an-empty-domain-is-manufactured-evidence` (0.107, only the word "manufactured"), `2026-10-15-an-edge-already-dated-is-not-a-new-window` (0.105), `2026-10-25-a-swallowed-edge-is-re-readable-from-the-sample-that-swallowed-it` (0.102), `2026-10-29-a-token-is-certified-by-the-gate-beside-it` (0.093, **read in full — owns R1's mechanism and is extended, not superseded**). A second pass over the same directory by hand covers `2026-10-13-a-scope-record-outlives-its-holder`, `2026-10-27-the-refusal-that-reopens-the-window-and-the-empty-card-it-leaves`, `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`, `2026-10-23-a-pick-clock-dates-the-cell-when-no-capture-exists` — each owns one half (record outliving holder / refusal reopening the window / refusal evicting / dating a cell with no capture). **None states that the two halves are the same instant by construction**, that a 9B draw is guaranteed to leave an orphan at today's ceiling, or that `kev_window=open` therefore cannot certify a flip.

**RULINGFILE rulings/2026-10-29-an-open-edge-and-its-orphan-token-are-one-event.md**
