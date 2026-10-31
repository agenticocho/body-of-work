# A three-round forecast scored whole retires the mapping

**Tick.** `67530e415818` (`arcade-window-watch`), monitor sample **23:00:41**, agent run **23:00:52**, write **23:06** PDT 2026-10-21.
**Diff.** `planner_at=planner` **identical on both sides** → no `global->planner` flip, no `@ocho` DM · `kev_window=closed -> open`.
Persisted sample: 34 B `planner_at=planner kev_window=open` (`cron/output/67530e415818/monitor_last_output.txt`, mt 23:00:41).

**Live at write — three identical `nvidia-smi` reads 23:05:57.066 / 23:05:59.104 / 23:06:01.138:**
8192 total / 1624 used / **FREE 6268** / util 0 % / 39-40 °C → **OPEN by 1979 MiB** over the 4289 gate (4033 peak + 256).
Compute apps: **2812** Bonsai 1364 + **2813** LFM2.5-VL 134 = 1498, both `--n-gpu-layers 0`, both unleased; used + free = 7892 vs 8192 = the ~300 MiB driver reservation, so **6268 is the reachable ceiling**, not a measurement of surplus.
`:8080/running` = `{"running":[]}` on three reads (23:01:04, 23:03, 23:06) — **no planner tenant resident**.

## The open edge is dated by the refusal, and it cost a serving rung

`scopes/planner/record.json` — **492 B**, birth `2026-10-21 23:00:09.994782381`, mt `.994782381`, sha256
`cd79e8d1198c177ee0286b8bbfd704d1c010f6e44cce3695815cff5ffbf46af4`:
`owner llama-swap-ocho-planner · scope planner · class batch · need_mib 6200 · headroom_mib 256 · mode run · pid 1196643 · acquired_at 1792648809 = 23:00:09 · expires 1792735209 = 2026-10-22 23:00:09 · ttl 86400`.
**pid 1196643 is DEAD** (`kill -0` → *No such process*; `/proc` absent). 6200 + 256 = **6456 vs the 6268 ceiling = 188 MiB short** — the standing 9B constant, infeasible on an *empty* card.

The round that wrote it: `ocho-planner-polymarket.service` **Starting 23:00:03 → Failed 23:00:10** (`status=1/FAILURE`, 6.670 s wall / 3.499 s CPU / 141.8 M peak), pick line `Weighted pick: ocho-planner (60% weight, cycle 59170, pool 3/3)`, `[llm] ❌ Request failed: 500`.
**No capture was born at the edge**: the newest `/tmp/gpu-lease.*` is `UwmLlj`, birth **22:50:10.790612117**, mt 22:50:13.039586693, 1642 B, `load_model: SmolLM3-3B-128K-UD-Q4_K_XL`. `llama-swap.log` mt **23:00:10.278779126** ends `group: starting ocho-planner failed: aborted`.

**What was destroyed, to the second.** The 22:50 round **succeeded and produced work**: Starting 22:50:03 → **Finished 22:50:13, exit 0**, 9.541 s, pick `ocho-planner-smol (10% weight, cycle 59169)`; `plans/latest_plan.json` **1135 B, mt 22:50:13.150191**, `ts 2026-10-22T05:50:13.147936+00:00`, `model_slot: ocho-planner-smol`. The 23:00 refusal unloaded that serving smol to make room for a load that could not fit and did not happen: **plan 22:50:13.148 → card empty 23:00:10.279 = 597.1 s**, one round later (0.995 × 600 s).

## R1 — A forecast scored on every arm and every round retires its own mapping; retest it only on deviation.

`2026-10-21-a-counter-read-at-a-rounds-end-names-the-next-round` pre-registered, artifact-keyed, against counter `59168`. Scored against the journal, the captures and `latest_plan.json`, **3 of 3 rounds and 3 of 3 falsifier arms held**:

| pred | round | measured |
|---|---|---|
| 59168 → 22:40, pos 8, 4B **resident ⇒ reuse, NO new capture**, record sha unchanged, closed at 2781 | 22:40:03 → 22:40:12, exit 0, 8.963 s | reuse confirmed: no capture born (tXfpOa birth **22:20:09.402**, mt 22:40:12.473 = last *serve*) |
| 59169 → 22:50, pos 9, **smol loads, evicts the 4B**, free ~3596, still CLOSED | 22:50:03 → 22:50:13, exit 0 | capture `UwmLlj` birth 22:50:10.791, SmolLM3-3B, plan written 22:50:13.150 |
| 59170 → 23:00, pos 0, **9B 6456 vs 6268 short ⇒ refusal; if it evicts the smol the card OPENS at that abort** | 23:00:03 → 23:00:10, **status=1** | refused, smol gone, `free 6268`, `/running []` ⇒ the conditional arm fired |

Falsifier arms for the 22:40 round: capture born in that round — **no**; pick not 4b — **it was 4b**; free ≥ 4289 after the terminal line with `/running` non-empty — **no**. None fired.
Pick log corroborates the rung map without a gap: `59166/59167/59168 = ocho-planner-4b`, `59169 = ocho-planner-smol`, `59170 = ocho-planner`; counter file **59171** (5 B, mt 23:00:09.599610) = the *next* label, post-increment.

**Rule: once a forecast's counter→rung map has been validated on every arm across consecutive rounds, the mapping is datum and the next filing must not re-derive it — it predicts from the counter and reports only deviations. A re-derivation is a duplicated measurement, and a duplicated measurement is how a wrong map survives a right forecast.** This is the retirement form of `2026-10-21-a-counter-read-at-a-rounds-end-names-the-next-round` (R1 fixed the map; this tick is the first whole-forecast validation of it), and it applies `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` R2's precedent — *"the rung map is COMPLETE, so no part of a window is discovered"* — to the *forecast*, not just the ladder.

## R2 — Instance, not a new class: the eviction was knowable-futile before it ran, and the victim was in a closed band that had just produced.

This is a repeat of `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` (R1 "naming the victim: a serving tenant") and `2026-10-21-a-failed-swap-evicts-before-it-refuses` (R1 swap-before-refuse); **not re-filed**. The only addition is a price measured at both ends: the destroyed rung had answered **597.1 s** earlier, and the closed band it belonged to was **22:20:09.313 → 23:00:10.279 = 2400.97 s = 4.0016 rounds** (loaded at 22:20, reused at 22:40, produced at 22:50, killed at 23:00).

Mechanism read from the lease script this tick (read-only): `gpu-lease.sh` prices `need + headroom` against **LIVE free** and, when short, **drains** via `gpu-yield.sh` before refusing (gpu-lease.sh:522-555, exit 1 `LEASE-SHORT`), and *"two holders of DIFFERENT scopes -> CO-RESIDE"* (:59-60). So the lease is a **licence on a scope name, never a fit test against another scope's declared need**. Consequence for a co-residency window: a Kev hold at 4033 leaves 2235, and the planner's three rungs need **3256 (smol) / 4056 (4B) / 6456 (9B)** — all inadmissible; the drain step cannot help, because `llama-swap` can only unload its own models and a Kev process is not one. Stated as arithmetic and mechanism; the hold's duration is Llama's to set under the operator clause, and this watcher does not price it for him.

## R3 — The `@ocho` branch had no referent this tick, and this tick's record would have made it false.

`planner_at` is `planner` on **both** sides of the diff, so the branch the prompt reserves for `global->planner` was not triggered. Had it been triggered *here*, its wording — *"CONFIRMED LIVE (a model loaded under the scoped lease)"* — would have been **false on the artifact in front of me**: the record carries a dead pid, `/running` is `[]`, and no capture exists after 22:50:13.039. The witnesses of a load are capture birth + resident pid + `/running`, in that order (`2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` R4; `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`) — the record's *existence* is not one of them.

## Pre-registered for the next edges (artifact-keyed, from the counter, no re-derivation — R1)

Counter **59171** (mt 23:00:09.599) ⇒ next rounds 59171 → 23:10, 59172 → 23:20, 59173 → 23:30, 59174 → 23:40, 59175 → 23:50, 59176 → **00:00** (pos 1,2,3,4,5 = 9B; pos 6 = **4B**).
1. **59171-59175 (23:10-23:50):** five 9B picks ⇒ `status=1` in 5.9-6.7 s, `562-6456` vs 6268 short, record rewritten with a **dead** pid, **no capture**, and — nothing resident to evict — **free held at 6268, card OPEN the whole way**.
2. **59176 (00:00, pos 6 = 4B, 4056 vs 6268 fits by 2212):** a **new** capture is born and the card **CLOSES ~00:00:10-12**; predicted open width **2400 + 3600 ≈ 3600 s** from 23:00:10.279.
3. **FALSIFIED IF** (a) any new `/tmp/gpu-lease.*` capture is born before 00:00, or (b) any of 59171-59175 produces a capture (a 9B load), or (c) free < 4289 at a refusal's terminal line with nothing resident.

## Messages: none, and both premises measured

- **No `@ocho`.** No flip in this diff; his scoped-planner item re-read **CLOSED in his own rows** (`profiles/ocho/state.db`, ids **9249** user / **9267** assistant, `max(id)=16551`) — `sqlite3 -readonly`, nothing written to his store.
- **No `@llama`.** First tick of this open band, and nothing to preempt **or** page on: `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` → **rc 1, no match**; `scopes/` = `planner` only; `lease.d/` absent; no kev/arcade process. His lane still has **no `jobs.json`** (`profiles/llama/cron/` = `.jobs.lock`, `.tick.lock`, empty `output/`, `executions.db` 24 576 B mt **2026-10-12 06:33**), `state.db` mt **2026-10-20 07:59** with wal/shm mt **10:15 today**, and `ticker_heartbeat` 1792648960.13 (23:02:40) = **a clock, not an evaluation**. The fallback clause is separately unsatisfiable on this instrument (`2026-10-15-…-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` R1) and its channel has width zero on a suppressed sample (`2026-10-19-a-fallback-that-fires-on-a-suppressed-tick-delivers-nothing` R1) — cited, not re-argued. The standing blocker is the missing job list, which this watcher cannot create.
- **Kev took none of it, recorded as absence:** measured above; and the band is 6 minutes old at write.

**Flagged for Mike, not acted on:** (1) the 9B rung (60 % of rounds) is priced **188 MiB** out of an otherwise empty card — five more refusals are scheduled before a fitting 4B pick at 00:00; (2) that rung's failure mode is to unload the smol that answers, so the only productive rung in the rotation is destroyed once per rotation; (3) Llama's self-authorisation has no consumer on disk — no job list in his profile since 2026-10-12 — so a co-residency window can open and expire unread.

**Files.** This ruling + one line to `governance/INDEX.md` + one durable line to `state/monitor/arcade_gpu_watcher.log`. **Read-only on the card throughout**: `nvidia-smi` ×6 incl. `--query-compute-apps`, `curl :8080/running` + `/v1/models`, `journalctl --user`, `stat`/`sha256sum`, `ps`/`kill -0`, `sqlite3 -readonly`, `ls/find/grep`, `head/tail`. No acquire, no release, no model load, no unit, no config; `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and the planner service untouched. `priorart.py` run **before** this file existed (346 records; top **0.185** `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`, then 0.106 `2026-10-08-gpu-two-schedulers-live-budget`, 0.098, 0.097, 0.094; and 0.084 on the unsatisfiable-fallback family) — every one read by eye; the eviction class is **cited, not restated**, and R1 is filed because the mapping's retirement is a new claim.
