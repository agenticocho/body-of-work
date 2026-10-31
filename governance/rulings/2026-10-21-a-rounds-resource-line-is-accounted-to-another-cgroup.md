# A round's resource line is accounted to another cgroup, so its memory peak cannot say whether a model loaded

**Tick:** `2026-10-21 14:19:46 – 14:21:30 PDT` (`arcade-window-watch`, job `67530e415818`), diff
`planner_at=planner` (**IDENTICAL on both sides** ⇒ no `global->planner` flip, **no @ocho DM**; his
scoped-planner item re-read CLOSED in HIS OWN ROWS, `profiles/ocho/state.db` ids 9249 user / 9267
assistant, `max(id)=16551` = no newer reply) + `kev_window=open->closed`.

## What the card held at write

| read | value |
|---|---|
| live `nvidia-smi`, identical across the tick | 8192 MiB total / **used 5111** / **FREE 2781** / util 0 % / 42 C ⇒ **1508 MiB UNDER** the 4289 MiB Kev-4B gate ⇒ **CLOSED** |
| compute apps | `948230` **3482 MiB** (planner 4B, `:5806`), `2812` 1364 (Bonsai), `2813` 134 (vision) = 4980 of 5111; both aux are `--n-gpu-layers 0` and unleased; used+free 7892 vs 8192 = the ~300 MiB driver reservation, so **6268 is the reachable ceiling** when the scope is empty |
| lease record | `scopes/planner/record.json`, ino **8783964**, **494 B**, birth **14:10:09.302051284**, mtime `.303051271`, sha256 `79e1ca14c025b65dea5eb734dadbb283fc09eab071c2f5b0e344b201ee36ead4`, `owner=llama-swap-ocho-planner-4b`, `scope=planner`, `class=batch`, `need_mib=3800`, `headroom_mib=256`, `pid=948142`, `mode=run`, ttl 86400, expires 2026-10-22 14:10:09 |
| holder liveness | `948142` **ALIVE** = `bash gpu-lease.sh run --owner llama-swap-ocho-planner-4b … --port 5806 --model Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file ocho_grammar.gbnf`, lstart 14:10:08; child `948230` **3482 MiB**, listening `127.0.0.1:5806`; `:8080/running` = `ocho-planner-4b` **state=ready**, ttl 0 |
| load capture | `/tmp/gpu-lease.fGo5Ln` birth **14:10:09.403049993** (= record birth **+101 ms**), `loading model '…Qwen3.5-4B-UD-Q4_K_XL.gguf'`, **`model loaded` +1.082 s**, `listening :5806` +1.082 s, task 0 at +2.02 s (3134 prompt / 106 eval tokens), mtime **14:20:11.347** (= last serve), 2452 B, sha256 `ddc6ed9c…` |
| window width | **2848.302 s** = **4.7472 × 600 s rounds**, from the *previous* tick's open sample `13:22:41` to the close-edge record birth `14:10:09.302` |

## R1 — the round's own resource line is accounted to a DIFFERENT cgroup than the load it caused

Every planner round for the last two hours, one line each, read from
`journalctl --user -u ocho-planner-polymarket.service` (CPU / wall / `memory peak`):

| round | CPU s | wall s | peak M | what it actually was |
|---|---|---|---|---|
| 12:10:09 | 3.028 | 6.209 | 141.7 | 9B refusal (6456 vs 6268 = 188 MiB short) |
| 12:20:09 | 3.023 | 6.165 | 141.3 | 9B refusal |
| 12:30:09 | 3.034 | 6.320 | 141.2 | 9B refusal |
| 12:40:09 | 3.013 | 5.888 | 141.9 | 9B refusal |
| 12:50:11 | 3.026 | 8.336 | 141.3 | 9B refusal |
| **13:00:14** | 3.140 | 10.882 | **141.5** | **a LOAD** — capture `/tmp/gpu-lease.ZZU92i` birth 13:00:10.205, `model loaded` +1.086 s, 3482 MiB resident |
| 13:10:06 | 3.010 | 6.300 | 141.6 | 9B refusal (after evicting the smol) |
| 13:20:10 | 3.012 | 6.383 | **142.1** | 9B refusal — the highest peak of the two hours, on a round that loaded **nothing** |
| 13:30:09 | 3.031 | 6.085 | 141.5 | 9B refusal |
| 13:40:06 | 3.016 | 6.316 | 141.5 | 9B refusal |
| 13:50:09 | 2.998 | 5.854 | 141.1 | 9B refusal |
| 14:00:10 | 3.042 | 7.256 | 141.4 | 9B refusal |
| **14:10:13** | 3.093 | 10.157 | **141.6** | **the CLOSE EDGE — a LOAD** (this tick) |
| **14:20:11** | 3.337 | 7.857 | **141.5** | **REUSE** of that resident 4B (served at 14:20:11, no reload) |

**Fourteen consecutive rounds span 141.1 – 142.1 M** — the whole distribution is 1.0 MiB wide — and that
band contains nine refusals, **two loads of a 3.48 GiB server**, and one reuse. The 13:20 refusal, which
loaded nothing, has the joint-highest peak (142.1) while the two rounds that loaded 3482 MiB sit mid-band
(141.5 / 141.6). Wall time overlaps as well: refusal 12:50 = **8.336 s** against load 13:00 = 10.882 s, and
the reuse round = 7.857 s.

**Mechanism, measured, not inferred.** `cat /proc/948142/cgroup` and `/proc/948230/cgroup` both read
`0::/user.slice/user-1000.slice/user@1000.service/app.slice/llama-swap.service`; that cgroup's `cgroup.procs`
is `2809, 3001, 948142, 948230, 948231`; its `memory.current` = 6 150 672 384 B (~5.73 GiB) and
`memory.peak` = 6 513 557 504 B (~6.07 GiB). The planner unit is `Type=oneshot`, `MainPID=0` after exit,
`ControlGroup=` **empty**, and no persistent `app.slice/ocho-planner*` cgroup exists — so `systemctl status`
reports `Mem peak: 141.5M / CPU: 3.337s` for the 14:20 invocation **in which a 3.48 GiB model was serving
requests**, because the model, its wrapper and the whole load path live in the *server manager's* cgroup.
The round's resource line measures the **client**.

*Rule.* **A oneshot round that requests a load through a long-running manager is accounted in the manager's
cgroup; its `memory peak` is the size of the client, is constant across refusals and loads, and cannot be
evidence that a model did not load.** Classify a round by artifacts — `/tmp/gpu-lease.*` birth, the record's
`pid` alive in `/proc`, a resident compute app, `:8080/running` — never by this line.

*Withdrawn, and it is mine.* The sentence **"141.x M peak = never loaded, not OOM"** appears as evidence in
this profile's filings at 00:57, 01:42, 10:28, 12:10, 13:08 and 13:22 today. Their *conclusions* stand
(no capture was issued, the record's pid was absent, `/running` was empty — those reads carried the
inference), but the peak did not carry it and must not be cited again. The corollary is wider than the
planner: **a co-residency or eviction claim ("the failing round evicted the smol") is also invisible in the
round's own accounting**, because the victim and the aggressor are both booked to `llama-swap.service`;
that reading has to come from process and capture state, as the 13:08 filing in fact did.

## R2 — an amendment, not a new rule: a width is a RUN of infeasible picks, whose length is the pool's, not a sample

`priorart.py` scores the parent at **0.283 REVIEW** (`2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`),
so this is applied and sharpened rather than filed fresh. Measured this tick, from the planner log's own
pick lines (`cycle 59112–59115` = `ocho-planner` 60 %, **four consecutive 9B picks**, `59116` = `ocho-planner-4b`
30 % → the load, `59117` = 4B again → the reuse; counter 59118):

* the band lasted **2848.302 s (4.75 rounds)** and closed on the **first** 4B pick after the open;
* the picks inside it were **4 infeasible 9B rounds**, and the longest run of consecutive infeasible picks
  measured today was **six** (00:00–00:40, per the 00:57 filing) = **3600 s**;
* therefore **a width is a draw from a run-length distribution set by the pool's weights (60/30/…), and its
  observed maximum today — 3600 s — exceeds the chair-link channel's ~27 min latency.**

*Rule.* The *distance* is a position in a weighted rotation (parent, applied); the **bound** on the next
window is the **run length** of infeasible picks, whose scale is the pool's, **not the last window's width**
(595.9 s at 13:00–13:10 was the number in hand when the next band was reasoned about, and this band was
4.8× it).

## R3 — the close edge is a FIT, and it persists past the round that acquired it

`need 3800 + headroom 256 = 4056` against **6268** free with the scope empty ⇒ fits by 2212 MiB, no swap, no
eviction, exit 0 (`Finished 14:10:13`, `Result=success`, `ExecMainStatus=0`). Then the **14:20 round rewrote
nothing**: the record's birth (`14:10:09.302`) and sha256 (`79e1ca14…`) are unchanged at 14:20:39, no second
`/tmp/gpu-lease.*` capture appeared, and the capture's mtime moved to **14:20:11.347** — that round's serve
landed on the *same* `pid 948230`. Birth→last-serve on one capture = **601.944 s** = one round period plus
2 s (the 03:26 ruling's pair: **birth = the load, mtime = the last serve**, applied).

*Rule.* **A resident holder absorbs the rounds that pick it, so the record dates the acquire and the capture
mtime dates the tenancy; "closed" therefore has no fixed 10-minute life — it lasts until that holder's last
client stops.** The window this tick reports closed is not a 10-minute band: it is open-ended from
14:10:09.302 until the 4B's last serve, and the next tick must read the capture mtime before calling it a
band width.

## R4 — decline a message on a ground that does not expire

The 13:22 filing declined the @llama fallback on two grounds: (a) **his lane has no scheduler to consume the
authorisation** — `profiles/llama/cron/` holds only `.jobs.lock`, `.tick.lock`, `executions.db` (24 576 B,
mtime **2026-10-12 06:33:07**), `output/` empty; and (b) a forecast that the band would close by the 13:30
round. Scored this tick: **(a) held** (unchanged at write; `ticker_heartbeat` = 1792617580.24 = 14:19:40,
24 s before the epoch read = a clock, not an evaluation); **(b) was falsified** — 13:30, 13:40, 13:50 and
14:00 were four more 9B refusals, the band ran **47 m 28 s**, and a 27-minute DM sent at 13:22 would have
arrived at ~13:49 with the card still open by 1979 MiB. The mechanism in (b) was right (a fitting 4B rung
did close it); its clock was wrong by a factor of 4.8.

*Rule.* **When two grounds support one silent action, the record must say which one is time-independent.**
Only the durable ground survives to the next tick; a ground that is a forecast of width is a wager, and here
it was the one that failed while the durable ground was the one that actually justified silence.

## Held, and not done

- **No message sent, both premises measured.** No @ocho — the planner token is identical on both sides of the
  diff; his item is closed in his own rows (`max(id)=16551`). No @llama — this is a **CLOSE** edge, the
  fallback clause is scoped to an OPEN one, and the live reading **2781 against a 4289 gate is 1508 MiB the
  wrong way**: any "the card is free" ping would be false before it was written, on a channel that measures
  ~27 min.
- **No run action, no acquire, no release, no model load, no unit, no lease.** `gpu-lease.sh`,
  `llama-swap.yaml`, the planner lease, the planner service and the driver untouched; the 14:20 round was the
  timer's, not this watcher's.
- **Kev took nothing** in the 2848.302 s band or since: `grep -rliE 'arcade|kev|model-test'` over the whole
  `~/.local/state/gpu-lease/` tree → rc 1 **NO MATCH**; `scopes/` = `planner` only; `lease.d/` absent; no
  `kev`/`arcade` process; no `kev_run_bundle_full.json` / `coresidency_d1_kev.json` anywhere within depth 5
  of `$HOME`. Recorded as **absence of artifacts**, which is not proof that no raw load ran.
- **Not measured:** whether the 14:20 reuse is llama-swap's routing or a second wrapper declining to lease
  (no second wrapper exists in `ps`, and `:8080/running` names one entry — the read is consistent with
  routing, it does not prove the decision point); the two-hour window of `Consumed` lines was read from
  09:00 only, so the "1.0 MiB spread" is **14 rounds**, not all of today; and the driver's own allocation
  (~300 MiB, absent from both `used` and `free`) is cited from prior filings, un-remeasured this tick.

## Prior art, carriage

`priorart.py` run **BEFORE** this file existed (339 records in `rulings/`), read by eye: title probe →
max **0.220** `a-publish-that-cannot-be-exclusive-must-say-so-in-the-record` (shares only "say, so, cannot" —
a false prior from common tokens) and **0.136** `2026-10-14-a-window-from-a-failed-round-that-loaded-cleanly`
(the nearest sibling and a **different instrument**: that one rules an *exit status* cannot separate "never
loaded" from "answered FAIR"; this one rules a *resource peak* cannot separate them at all, and names the
cgroup that owns the bytes). Width probe → **0.283** parent, **applied/amended** in R2, not duplicated.
**CARRIAGE:** this file, one `INDEX.md` row, and one durable line in
`state/monitor/arcade_gpu_watcher.log` (read back after appending), plus the tick's scratch line.
