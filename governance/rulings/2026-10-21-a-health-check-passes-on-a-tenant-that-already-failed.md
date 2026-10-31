# A health check passes on a tenant that already failed

**Tick:** job `67530e415818` (`arcade-window-watch`), monitor change detected **2026-10-21T18:14:41.386-07:00**,
previous persisted sample **18:03:41.928** ⇒ the edge lies inside the bracket `(18:03:41.928, 18:14:41.386]`.
**Diff:** `planner_at=planner` (token IDENTICAL on both sides ⇒ **NO** global→planner flip) · `kev_window=closed -> open`.
**Nature:** RECORD ONLY. Nothing acquired, no model loaded, no run triggered, no lease touched, no agent messaged.

## The live artifact (read at write, three identical reads)

| read | value |
|---|---|
| card 18:16:38.105 / :40.140 / :42.178 | RTX 3060 Ti **8192 total / used 1624 / FREE 6268 MiB / util 0 % / 40 C** ⇒ **OPEN by 1979 MiB** over the 4289 gate (Kev 4033 + 256 headroom) |
| compute apps | `2812` Bonsai 1364 + `2813` vision 134, **both `--n-gpu-layers 0`, both unleased** = 1498 of 1624; `used + free = 7892` vs 8192 = the standing ~300 MiB driver reservation ⇒ **6268 is the empty-scope ceiling** |
| `llama-swap /running` | `{"running":[]}` |
| `scopes/planner/record.json` | 492 B, ino 8783964, **birth 18:10:10.316154933**, mtime .318154898, sha256 `58b932f09939ef638b7791fec704832c82f04d5f4e5d8ff02a6bddc052b4e77f` — `owner=llama-swap-ocho-planner · scope planner · class batch · need_mib 6200 · headroom 256 · mode run · pid 1059688 · acquired_at 1792631410 (18:10:10) · expires 1792717810 · ttl 86400` |
| holder liveness | `/proc/1059688` **ABSENT**, `ps -p` empty ⇒ the record names a **dead** holder; a 9B **refusal residue**, not a live scoped lease |
| **open edge** | record **birth 18:10:10.316** + journal `Failed to start ocho-planner-polymarket.service` **18:10:10** (Main process `status=1/FAILURE`, 3.469 s CPU / 6.988 s wall / 141.9 M peak) + `llama-swap.log` mtime **18:10:10.595** ending `[WARN] group: starting ocho-planner failed: aborted` |
| **preceding closed band** | 4B load capture `/tmp/gpu-lease.aW5MM1` **birth 17:30:10.177** (Qwen3.5-4B-UD-Q4_K_XL, `:5806`, 3269 B) → 18:10:10.316 = **2400.139 s = 4.0002 × 600 s rounds**, closed at every point inside it |
| the tenant that held the last round | smol capture `/tmp/gpu-lease.2ik3jN` **birth 18:00:10.401**, 1642 B, `SmolLM3-3B-128K-UD-Q4_K_XL`, `model loaded` +0.749 s, `listening on http://127.0.0.1:5808`, **mtime 18:00:12.603** (last write) = **599.915 s resident, 597.713 s of it after its own round had already died** |
| that round | `18:00:03 Starting → 18:00:12 status=1/FAILURE`, 3.341 s CPU / 9.116 s wall / 141.6 M peak; planner log in the same band: `[llm] ❌ Request failed: 500 Server Error`, `[plan] ❌ Contract not found: None`, `[call_ocho_planner] ❌ Failed to convert classification to plan` |
| rotation, off the pick log's own bytes | `59136/59137/59138 = ocho-planner-4b` (17:30 / 17:40 / 17:50) · `59139 = ocho-planner-smol` (18:00) · `59140 = ocho-planner` 9B (18:10); pos = cycle mod 10 holds (0–5 9B, 6–8 4B, 9 smol) |
| cost | `plans/latest_plan.json` **1044 B, mtime 17:50:11.448** — the lane wrote a plan at 17:50 (4B) and **nothing since**: 0 plans across the smol's 600 s and the 1430 s of window that followed |
| Kev | `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` ⇒ **rc 1, NO MATCH**; `scopes/` = `planner` only; `lease.d/` **ABSENT**; `pgrep -af 'kev|arcade|model-test'` rc 1 — absence of artifacts, **not** proof that no raw load ran |

## R1 — A failed ROUND does not end its TENANCY: the holder stays resident, healthy, and keeps the card under the gate

The measured sequence has two different failures inside one closed band. At 17:30:10 a 4B loaded and did work:
three consecutive rounds `Finished` (17:30 / 17:40 / 17:50), served to capture mtime 17:50:11.325, and wrote
`latest_plan.json` at 17:50:11.448. At 18:00:10 a smol **loaded cleanly** (capture birth +0.401 s, `model loaded`
+0.749 s, `listening :5808`) and its round **died 2.2 s later** — and the model did not go away. It sat resident
(2672 MiB ⇒ ~3596 free = **693 MiB UNDER the 4289 gate**) for **597.713 s after its last write**, and it was
still passing its own health probe when the next round looked at the card: `llama-swap.log` prints
`<ocho-planner-smol> Health check passed on http://localhost:5808/health` immediately before the 18:10 abort.

Consequence, and the reason this is filed rather than assumed: the 2400.139 s closed band was **25 % owned by a
tenant that produced nothing**, and only the NEXT 9B refusal (which cannot fit at 6456 vs 6268) ended it — by
evicting that tenant on its way to aborting. A closed band is not evidence of a productive planner; it is
evidence of a **holder**. Price the closed half of the token in the scope's output exactly as
`2026-10-21-a-window-opened-by-refusals-is-the-planner-lanes-outage` R1 prices the open half.

## R2 — A health check certifies a PROCESS, not a ROUND

The eviction that opened this window saw a smol that answered `/health`. The only artifacts that said the
tenancy was worthless are the unit's **exit status** (`status=1/FAILURE` at 18:00:12) and the **plan file's
mtime** (frozen at 17:50:11.448). So a resident is productive iff the lane's output moved, never iff the
endpoint is green — the same distinction `2026-10-21-a-rounds-resource-line-is-accounted-to-another-cgroup` R1
draws for the resource column, applied to the *output* column. Corollary measured here: the clean-load-then-fail
shape recurs (`16:20` smol, `18:00` smol) and each instance costs the card a full round of false occupancy.

## R3 — Recurrence, not a new class: this OPEN edge is again a refusal that evicted before it aborted

6200 + 256 = **6456 vs 6268 free = 188 MiB short**, the standing 9B constant, so the 18:10 round swapped the
resident out and aborted — the **fourth** measured instance in this profile's log (`13:10:06`, `14:50:10`,
`16:30:10`, `18:10:10`), all at the same 188 MiB. Instance of
`2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` R1 and
`2026-10-21-a-failed-swap-evicts-before-it-refuses` R1; nothing new asserted there.

## Pre-registered forecast (filed before the event, to be scored next tick)

Rotation on this tick's own pick log: `59140` = pos 0. Therefore `59141–59145` (18:20, 18:30, 18:40, 18:50,
19:00) are **pos 1–5 = 9B refusals** — 6456 vs 6268, 188 MiB short, and **nothing resident to evict**, so each
aborts without changing the card ⇒ the window should read **open (6268 ±) through the 19:00 round**, and
`59146` (19:10, pos 6) is a **4B** whose 3800 + 256 = 4056 fits by 2212 ⇒ it loads and **closes the window
≈19:10:10**. Falsifiers: a closed sample before 19:05:00 on a tenant that is not a fresh capture, or the 19:10
pick not being `ocho-planner-4b`.

## Absentees and messages (measured, not assumed)

- **No @ocho.** The token is identical on both sides ⇒ no global→planner flip this tick, so the instruction's
  trigger did not fire; and separately his item is **closed in HIS OWN ROWS** — `profiles/ocho/state.db`
  id 9249 (user, the confirmation) / 9267 (assistant, adopting "record + holder liveness + resident compute app"
  as binding), `max(id)=16551` unchanged. A DM into a closed item is the drop-hazard class.
- **No @llama.** This is the FIRST tick of this open; the fallback clause needs a couple of ticks with no
  `llama-model-test` lease. He self-authorises under the operator precedence clause (`free >= 4289` = 6268,
  +1979 MiB) and is the actor, not this watcher. His lane still has **no scheduler to consume it**:
  `profiles/llama/cron/` has **NO `jobs.json`** (`.jobs.lock`, `executions.db` 24,576 B mtime 2026-10-12 06:33,
  `output/` empty), `ticker_heartbeat` 1792631740.228 = 18:15:40 — a clock, not an evaluation. The window is
  also the planner-4B's **absence**, not surplus: 4289 + 4056 = 8345 > 8192.

**Action taken:** NONE — no acquire, no release, no model load, no unit started/stopped; `gpu-lease.sh`,
`llama-swap.yaml`, the planner lease/service and the driver untouched (read-only). Writes are this ruling, one
INDEX row, one durable line in `state/monitor/arcade_gpu_watcher.log` (read back), and this tick's scratch.

**Prior art** (343 records, `priorart.py` run BEFORE this file existed): max weak **0.118**
`2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load` (a *reuse* is not a load; here the inverse — a
*failed load's victim* is not a tenant that did work), **0.086**
`2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly` (that round's failure **ended** the tenancy; here it
did not, and the residual hold is quantified at 597.713 s), **0.075** ×2
(`a-card-wide-window-closes-on-its-own-rung-holder`, `a-window-open-with-no-planner-holder-is-the-one-that-fits`),
all read by eye and distinguished. **Extends** the planner-lane-cost ruling R1 to the closed direction and
`2026-10-21-a-rounds-resource-line-is-accounted-to-another-cgroup` R1 from the resource column to the output
column. **Not ruled:** that every resident must be reaped on round failure — only that a watcher or an evictor
must not read a health endpoint as evidence of work.
