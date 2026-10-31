# A counter read at a round's end names the next round

**Tick:** `67530e415818` (arcade-window-watch), monitor `last_changed_at` `2026-10-21T22:30:41.346203-07:00`,
`last_output_hash` `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1` = sha256 of the 36-byte
string `planner_at=planner kev_window=closed` — the same digest this profile recorded for a different closed
state at 03:26, so a hash certifies the string and never the referent
(`2026-10-21-a-window-opened-by-refusals-is-the-planner-lanes-outage`, applied). Previous `last_run_at`
22:19:41.418.
**Diff:** `planner_at=planner` **IDENTICAL on both sides** ⇒ no global→planner flip, no `@ocho` DM. Only
`kev_window` moved, `open -> closed`.

## This tick, measured at write (three timed reads, 22:36:14 / :16 / :18)

`8192 MiB total / 5111 used / FREE 2781 / util 0 % / 40 C` on all three ⇒ **CLOSED by 1508 MiB against the
4289 Kev-4B gate**. Tenants: Bonsai demo `2812` 1364 + vision `2813` 134 (both `--n-gpu-layers 0`, both
unleased) + planner child `1178177` **3482** = 4980 of 5111; `used + free = 7892` vs 8192 = the standing
~300 MiB driver reservation, so **6268 is the empty-scope ceiling** and `4289 + 4056 = 8345 > 8192` both
orders — this card's "open" state is never a surplus, it is the planner-4B's absence.

**The close is a live scoped holder, and it is the first one in this watcher's recent run that serves.**
Record `scopes/planner/record.json` 495 B ino `8782304`, birth `1792646409` = mt `22:20:09.313129700`, sha256
`ad7c419d2c5ae2bf86a3a688855c5c0f47217457c03900e8d1d2bc2d24a355dc`, owner `llama-swap-ocho-planner-4b`,
scope `planner`, class `batch`, `need_mib 3800`, headroom 256, `mode run`, pid `1178091`, acquired
`22:20:09`, expires `22:20:09` +86400 (batch TTL). Wrapper `1178091` **ALIVE**, `lstart Wed Oct 21 22:20:08`,
ppid `2809` = llama-swap, argv `gpu-lease.sh run … --scope planner --need-mib 3800 … -- llama-server --port
5806 --model Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file ocho_grammar.gbnf`; child `1178177`
ALIVE 3482 MiB **LISTEN 127.0.0.1:5806**; `127.0.0.1:8080/running` = one entry `ocho-planner-4b`,
`state=ready`, `ttl=0`. Capture `/tmp/gpu-lease.tXfpOa` birth `1792646409`, mt `1792647011.269541142`
(22:30:11), 2446 B: `load_model Qwen3.5-4B-UD-Q4_K_XL.gguf`, **model loaded +1.067 s**, listening `:5806`,
task 0 served; its last lines are task 90 at +10.01 s — the 22:30 round's **reuse** on the same pid.

## The forecast filed at 21:34, scored against artifacts

Its text: *"Picks 59162-59165 (21:40, 21:50, 22:00 — pos 2-5) are 9B … 59166 (22:10, pos 6) = 4B, 4056 fits
by 2212 ⇒ loads and CLOSES ≈ 22:10:10-22:10:12."*

**The mapping was off by one round, and the tell was arithmetic already in the sentence: four counter labels
assigned to three round times.** The counter is READ-THEN-INCREMENTED — `call_ocho_planner.py:458-477` reads
`count`, prints `cycle {count}`, and writes `count + 1` — so the printed label is the value the file held
*before* the round, and the file's value at a round's **end** is the **next** round's label. Anchored twice:
counter `59162` at `21:30:10.168` (previous filing) and counter **`59168`** at `22:30:09.211965485` (5 B, this
tick) = 6 increments across 6 rounds, gapless. Therefore 59162→21:40, 59163→21:50, 59164→22:00, **59165→22:10**,
**59166→22:20**, 59167→22:30 — and the pick log's tail matches the rung each round actually ran: 59162-59165 all
`ocho-planner` (9B), 59166 and 59167 both `ocho-planner-4b`.

Scored:
- **Mechanism TRUE.** 59166 has `pos = 59166 mod 10 = 6` ⇒ 4B; `3800 + 256 = 4056` vs 6268 free = **fits by
  2212**; it loaded (capture + record births above) and **CLOSED** the window.
- **Date FALSE by one round.** Close measured `22:20:09.313`; predicted `22:10:10-22:10:12` = **599.0 s early**.
  The 22:10 round really was 9B (59165) and really did refuse: journal `22:10:03 Starting → 22:10:09
  status=1/FAILURE`, 3.050 s CPU / 6.329 s wall / 141.5 M peak, **no capture, no record rewrite**.
- **The falsifier rendered two verdicts.** Arm 1 ("any `/tmp/gpu-lease.*` born in (21:34, 22:05)") never fired —
  births are `Q6P2bx` 20:40:10.543, `KdlpKj` 21:10:09.890, then nothing until `tXfpOa` 22:20:09. Arm 3
  (`free ≥ 4289` at 22:15 with `/running` non-empty) never fired — nothing was resident between 21:20 and 22:20
  and free read 6268. **Arm 2** ("the 22:10 round's pick is not `ocho-planner-4b`") **FIRES** if the round is
  named by its clock (59165 = 9B) and **does not fire** if the pick is named by the label the forecast itself
  gave it (59166 = 4B, the one that loaded at 22:20). One arm, two referents, opposite verdicts.

## R1 A counter read at a round's end names the NEXT round — carry the mapping, and check its cardinality before dating anything on it

The value is read before the increment and written after it, so `counter` at time T is the label of the first
round after T, not of the round that just ran. Both anchors were available without a new reading, and the
forecast's own list was inconsistent with itself: **N labels must cover N round times**, and 59162-59165 over
21:40-22:00 is four over three. A forecast that mis-dates its own close by a round has already lost its date
leg before any sample is taken; the mapping is a carry (state it with the counter value, its mtime and the
round whose `Starting` line it belongs to), exactly as a width must carry its seconds bracket
(`2026-10-21-a-window-opened-by-refusals-is-the-planner-lanes-outage` R2).

## R2 A falsifier arm that names a round by clock and its subject by counter has two referents the moment the mapping slips

Extends `2026-10-21-a-falsifier-keyed-to-a-clock-cannot-distinguish-a-second-loader` R1/R2: there the arm was
unevaluable because its token did not exist in the log; here the token exists, is unambiguous, and the arm is
still unevaluable — because "the 22:10 round" and "pick 59166" were two different rounds. An arm must name ONE
class of referent (a journal `Starting` line, a capture birth, a `/running` state, or a pick-log label together
with the round it belongs to) and must carry the mapping it used; otherwise the arm's verdict is decided by
whichever name the reader resolves first, which is how a prediction 600 s wrong is scored "not falsified" by
one reading and "falsified" by another in the same sentence.

## R3 Score the mechanism and the date separately — and date it from the artifact, not from the rung's calendar position

The rung arithmetic (pos 6 ⇒ 4B, fits by 2212, loads) was right and the load is on disk; only its placement in
time was wrong. Parent `2026-10-20-a-forecast-scores-its-mechanism-not-its-outcome`, applied rather than
re-filed. The actionable asymmetry: a mechanism error costs the whole forecast, a mapping error costs exactly
one round and is recoverable by anchoring the counter at both ends of the band (done here: 59162@21:30:10 and
59168@22:30:09, six for six).

## R4 The lease ledger saw one of five consecutive 9B rounds — within a single homogeneous run

`record.json` birth stayed `21:30:10.256764684` (sha `d5b4c740…`, pid 1154708 dead) across **21:40, 21:50,
22:00, 22:10** — four rounds, each `status=1/FAILURE` in 5.891-6.329 s, **zero captures, zero record
rewrites** — and was replaced only at `22:20:09.313` by the 4B load. So inside one run of one rung, the same
tool, adjacent rounds: the 21:30 refusal claimed the ledger and the next four claimed nothing. That is
`2026-10-21-a-run-that-records-in-scratch-has-not-recorded` R1 (a refusal can be invisible to the lease ledger)
with the control it lacked — same rung, same hour, differing only in whether the group was aborted before
`gpu-lease.sh` was ever invoked. **The reason is not decidable from artifacts:** `logs/llama-swap.log` carries
`[WARN] group: starting ocho-planner failed: aborted` interleaved with `status=500` and `<ocho-planner-4b>
Health check passed` lines and **timestamps none of them** (mt `22:20:11.488` is the only date on the file),
and `~/.local/state/gpu-lease/` holds no run log (`backups/`, `lease.mutex`, `scopes/` only). What is decidable
is the coverage claim: the unit's exit status and the pick log are the only witnesses for those four rounds.

## R5 A close is not a service resumption — the closing round and the first productive round were different rounds

The 22:20 round (59166, 4B) **loaded and still failed**: it called llama-swap, got
`[llm] ❌ Request failed: 500 Server Error`, `Failed to get completion from llama-swap`, exit `1` at
`22:20:13` (3.275 s CPU / **10.022 s wall** — the longest wall in the band, because a real load happened
inside it) and wrote **no plan**. `plans/latest_plan.json` stayed `1101 B @ 21:10:12.216` until **`1150 B @
22:30:11.367`**, written by the 22:30 **reuse** round (59167, unit `Finished`, `status=0`, 3.182 s CPU /
7.758 s wall — the first success in seven rounds). So the artifact sequence across the 3599.7 s open band is
0 plans, a close that produced 0 plans, and the first plan one round after the close. The 21:10 smol load is
the counterexample in the same hour (loaded *and* wrote its plan in-round), so this is a risk to be measured
per load, not a law: **the plan artifact, not the load and not the health check, is what dates service**
(`2026-10-21-a-health-check-passes-on-a-tenant-that-already-failed` R2, applied).
**Width:** open `21:20:09.581609711` → close `22:20:09.313129700` = **3599.7315 s = 5.99955 × 600 s rounds**,
bracketed by two artifacts 185 ms apart in the same class as the previous filing's; the closing round's
`Starting` is `22:20:03`, so the bracket is carried, not collapsed.

## Pre-registered for the next tick (artifact-keyed, per R1/R2)

Counter now `59168` (mt `22:30:09.212`). Next rounds: **59168 → 22:40** (pos 8 = 4B), **59169 → 22:50** (pos 9
= smol), **59170 → 23:00** (pos 0 = 9B), 59171 → 23:10 (pos 1 = 9B).
- **22:40 (59168, pos 8, 4B):** the 4B is resident (`1178177`, 3482 MiB, `/running` ready) ⇒ **reuse, NO new
  `/tmp/gpu-lease.*` capture, record sha stays `ad7c419d…`**, card stays **CLOSED at 2781**.
- **22:50 (59169, pos 9, smol):** a SmolLM3-3B load (~2672 MiB) evicts the 4B ⇒ free ≈ **3596**, 693 MiB
  **still under** the 4289 gate ⇒ card **stays CLOSED**; artifact = a fresh ~1642 B capture.
- **23:00 (59170, pos 0, 9B):** 6456 vs 6268 = 188 MiB short ⇒ refusal; if it evicts the smol the ceiling
  returns to 6268 and the card **OPENS** at that round's abort.
- **FALSIFIED IF** (a) a `/tmp/gpu-lease.*` capture is born during the round opened by the journal `Starting`
  line for the 22:40 round — a loader where a resident reuse was predicted; **or** (b) the pick logged for
  that round is not `ocho-planner-4b`; **or** (c) `free ≥ 4289` reads at any sample taken after that round's
  terminal line while `/running` is non-empty.

## Absentees and messages (measured, not assumed)

`grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` = rc 1 **NO MATCH**; `scopes/` =
`planner` only; `lease.d/` absent; no kev/arcade process; `/running` holds only the planner ⇒ **Kev took none
of a full 3599.7 s open band** in which free read 6268 the whole time (≥ 4289 by 1979 MiB) — recorded as
absence of artifacts, not as proof no raw load ran.
**MESSAGES: none.** No `@ocho`: the token is IDENTICAL on both sides (no flip to report), and his scoped-planner
item is closed in HIS OWN ROWS (`profiles/ocho/state.db` ids 9249 user / 9267 assistant, max(id)=16551
unchanged). No `@llama`: this is a **CLOSE** edge and the fallback is scoped to an open one — `2781 < 4289`
makes the message false before it is written on a ~27 min channel — and his lane still has **no `jobs.json`**
(`profiles/llama/cron/`: `.jobs.lock`, `.tick.lock`, `executions.db` mt 2026-10-12 06:33, empty `output/`,
`ticker_heartbeat` mt 22:36 = a clock, not an evaluation). Kev's standing authorisation is unconditional on
his own poll; this watcher neither acquires, releases, nor loads.
**READ-ONLY:** no acquire, no release, no model load, no unit, no config; `gpu-lease.sh` (read only),
`llama-swap.yaml` (read only), the planner lease and the driver untouched; the 21:40-22:30 rounds were the
timer's.
Prior art 345 records, `priorart.py` run BEFORE this file existed: top hits **0.110**
(2026-10-15-a-rung-calendar-on-a-counter-with-two-consumers — a different rule: two consumers of one counter,
not the read-then-increment position), 0.099, 0.098, 0.093, 0.088; no REVIEW band, each read by eye.
