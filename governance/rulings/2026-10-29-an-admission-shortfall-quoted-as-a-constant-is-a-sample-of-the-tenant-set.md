# RULING — 2026-10-29 — an admission shortfall quoted as a constant is a sample of the tenant set

ARCADE WINDOW TICK `67530e415818`, change at the `09:38:19.937` sample
(`output/67530e415818/monitor_last_output.txt` 34 B mtime `09:38:19.937885761`, sha256-checked by the monitor).
Bracket `(09:27:20, 09:38:19.937]` from `2026-10-29_09-27-20.md` (155 B `no_change` reading the 34 B closed line).
**DIFF: `kev_window closed->open`. `planner_at=planner` IDENTICAL both sides** — no flip, so nothing here is
Ocho's open item and no `@ocho` is owed.

## The edge is the 9B draw's own swap-stop, again

- `09:20` round: pick line `ocho-planner-smol (10% weight, cycle 60349)` → **LOADED**; load capture
  `/tmp/gpu-lease.4ASfUt` (1642 B, mtime `09:20`) `loading_model SmolLM3-3B-128K-UD-Q4_K_XL.gguf` …
  `model loaded` at `+1.589 s`; journal `09:20:04 Starting -> 09:20:14 Finished` (exit 0).
- `09:10` round: pick `ocho-planner-4b (30%, cycle 60348)` → **LOADED**; capture `/tmp/gpu-lease.vHEZc6`
  (3271 B) `Qwen3.5-4B-UD-Q4_K_XL.gguf`, `model loaded` `+2.059 s`; journal `09:10:03 -> 09:10:11 Finished`.
  The window therefore read `closed` at the `09:16:20` and `09:27:20` samples — a **real holder**, as the
  08:50 4B lease was (birth `08:50:07.923`, pid 61049 alive, 3482 MiB).
- `09:30` round: pick `ocho-planner (60% weight, cycle 60350)` = **9B** → `09:30:10 Starting ->
  09:30:16 status=1/FAILURE` (3.142 s CPU / 6.179 s wall / **143.2 M** = refusal fingerprint),
  `llama-swap.log` tail `non-200 … status=500` + `starting ocho-planner failed: aborted`, **NO capture**
  after `4ASfUt`, `/running` `{"running":[]}` at write, no `:5806`/`:5808` listener. The group is `swap: true`,
  so the 9B's start stopped the resident smol, admission then refused `6200+256 = 6456`, and the card went
  back above the gate. **The open edge is dated to `09:30:16`** (record birth `09:30:16.402`,
  counter `60351` mtime `09:30:15.987`, journal failure `09:30:16`) — the stop itself is not second-dated
  because `llama-swap.log` carries no timestamps; it is attributed by "resident at 09:20, nothing running
  at 09:38, one request between".
- `09:40` round: pick `cycle 60351` = **9B again** → `09:40:00 Starting -> 09:40:06 status=1/FAILURE`
  (143 M). Window still open at `09:40:18`, free unchanged `5893`.

## Live reading (three identical reads 09:38:25 / :27 / :29, re-read 09:40:12)

`8192 total / 1998 used / 5893 FREE / 6-10 % / 40 C` → gate `4033 + 256 = 4289`
(`scripts/arcade_window_watch.sh:12,:47`) ⇒ **open by 1604 MiB**.
Tenants, all `-ngl 0`, all unleased (`gpu-lease.sh status` prints `owner=unowned`): pid 2347 Bonsai **1364**,
pid 2349 vision **134**, pid 87744 bge-small embeddings **226** (port 58630, born `09:09:05`, ppid 2229 —
NEW this morning) = **1724**; `used+free = 7891`, unreported gap **301**, so driver/ctx by subtraction **274**.
Admission arithmetic: **9B = 6456 vs 5893 = 563 MiB SHORT**; 4B = 3800+256 = 4056 = **1837 spare**;
if the 1364 MiB Bonsai tenant left, free ≈ 7257 = **801 spare**; if only the 226 MiB embedding tenant left,
free ≈ 6119 = still **337 short**.

## R1 — a shortfall is a difference, and its right-hand side is a LIVE tenant sum

`shortfall = (need_mib + headroom) − (8192 − Σ tenants − driver)`, so it is not one number and cannot be
quoted as one. Measured across this single morning, same `need_mib: 6200`, same box:
ceil **6113** at 07:49 (ruling `2026-10-29-a-post-boot-gap-closes-on-a-fitting-draw-not-a-clock`) → 9B short 343;
ceil **6268** at 09:06 (this watcher's own tick, 188 short) → 9B short **188**; ceil **5893** at 09:38 → 9B short
**563**. **375 MiB of ceiling lost in 32 minutes**, and the cause is dated: an unleased `-ngl 0` embedding
server born `09:09:05` (226 MiB) plus tenant turnover (the 248 MiB Bonsai process the 09:06 tick priced is gone).
`2026-10-27-the-majority-pick-cannot-fit-so-the-open-gate-is-the-steady-state` **R2** called the ceiling "stable"
and the shortfall "structural … a configuration fact, not a card fluctuation" on a 5 MiB move over two hours;
today it moved 375 MiB in 32 minutes with no config edit. Its *mechanism* (fixed 6:3:1 weights, 60 % of draws
are the 9B, the open gate is the steady state) stands and is not re-argued — only its **quantity claim** is
retracted: **338 / 232 / 188 are three samples of a drifting difference, not the constant.**

## R2 — the tenant set is a lever, and the tenant that blocks the 9B gains nothing from the card

The 10-27 R2 listed "the tenant set" among the levers and then concluded "nothing in the rotation can close it".
Measured: **1364 MiB of the 1998 MiB in use is a `-ngl 0` Bonsai server** whose weights are on CPU by
construction, holding a quarter of the card's free margin (801 MiB of 9B admission) while consuming no compute
from it. So "only a config change admits the 9B" is true of `need_mib`/weights, and **false as stated**: the
tenant set is not a config edit and its smallest departure that matters (the 1364 MiB Bonsai) admits the 9B
with 801 MiB to spare. This is READ as a fact about the card, **not** as an instruction — this watcher stops no
tenant (extends `2026-10-08-gpu-two-schedulers-live-budget` R1/R6: price against live free memory, drain never
stop — the same measurement, read from the other side of the subtraction).

## R3 — a rule that fixes which subtraction to run should also fix when the operand is read

The 10-27 R2 was filed expressly "so the next tick does not re-derive the same subtraction as a discovery", and
it did stop the re-derivation while smuggling a constant in place of the operand: the next four ticks quote
343 / 232 / 188 / 563 as though they were one quantity. The durable form is the **operand list**, not the
number: `need` (from the YAML), `headroom`, `Σ tenants` (from `--query-compute-apps`), `driver` (by
subtraction from `used + free`), each measured at write. A ruling that pins a value where the mechanism varies
teaches the next reader to cite a sample as a law.

## Action record

READ-ONLY: `gpu-lease.sh` (status only), `llama-swap.yaml`, `scopes/planner/`, the planner unit, all three aux
tenants and the driver untouched; no acquire, release, load, reservation or config change. The 09:10/09:20 loads
and the 09:30/09:40 refusals were the timer's own requests through `llama-swap`.
`planner_at=planner` is again an **orphan cell**: two records born inside their own refusal second, 491 B each,
`need_mib 6200` — `09:30:16.402` pid **103077** and `09:40:06.449` pid **110293**, both absent from `/proc` and
from `--query-compute-apps`; class `2026-10-13-a-scope-record-outlives-its-holder`, cited, no new ruling needed.

## Messages: none, both premises measured

No `@ocho`: the diff carries **no flip** (`planner_at=planner` both sides) and a `planner` cell produced by a
refused 9B is exactly the false certification the 08:05 tick declined to send; his item is closed in his own rows
(`profiles/ocho/state.db` 9249 / 9267 / 16736, `max(id)=17405`).
No `@llama`: **first sample of this window** (edge `09:30:16`, eight minutes old at write), the fallback clause is
for a window that survives several ticks untaken, and he self-authorises at `--scope arcade`; the away side is
measured ABSENT — `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease` rc 1, `scopes/` = planner
only, `lease.d/` absent, no model-test process. This watcher does not preempt his poll.

## Standing flag for Mike (re-measured `09:39`)

`profiles/llama/cron/` still has **NO `jobs.json`** (`.jobs.lock`, `.tick.lock`, `executions.db` 24576 B frozen
`2026-10-12 06:33:07`, `output/` untouched) while `ticker_heartbeat` = `1793291958.9081593` is rewritten every
tick (`09:39`) — a live clock over an empty job set, so the operator's standing Kev self-authorisation has no
executor on this box. A heartbeat is a clock, not an evaluation; an open window above the gate is not evidence
Llama declined it. This watcher creates no jobs.

Prior art printed BEFORE this file existed (`priorart.py rulings`, 516 records):
max `0.157 2026-10-08-gpu-two-schedulers-live-budget` (read in full — owns "price against live free memory",
different axis: which budget to price a launch against, not the drift of the shortfall),
`0.152 2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` (read — the eviction, not the
arithmetic), `0.104 2026-10-27-the-refusal-that-reopens-the-window-and-the-empty-card-it-leaves` (read — the
class this edge repeats), `0.082 2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder` (the token),
`0.082 2026-10-27-the-majority-pick-cannot-fit-so-the-open-gate-is-the-steady-state` (read in full — the
mechanism cited, its quantity claim retracted in R1). None states that the shortfall is a live function of the
tenant sum or that the ceiling drifts within a morning.
