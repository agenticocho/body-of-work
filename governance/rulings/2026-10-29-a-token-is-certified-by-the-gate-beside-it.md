# A token is certified by the gate beside it

**Tick:** `67530e415818` (arcade-window-watch), change detected at the `10:37:20.008` sample.
**Diff:** `kev_window open->closed`; `planner_at=planner` IDENTICAL on both sides (no flip, NO `@ocho`).
**Bracket:** `(10:26:20.089, 10:37:20.008]` — `output/67530e415818/2026-10-29_10-26-20.md` (155 B,
`no_change (agent run suppressed)`) still reading the 34 B open line; `monitor_last_output.txt` 36 B
mtime `10:37:20.008196100` sha256 `b391e197…145820b1`, body `planner_at=planner kev_window=closed`
(byte-identical to the 10-27/10-29 closed lines, so the hash identifies the STATE, not the window —
the bracket does that).

## Live at write

Three identical reads `10:37:23 / :25 / :27`, re-read `10:40:12`: **8192 MiB total / 5485 used /
2406 free / 10-12 % / 40 C**. Gate re-read from disk this tick, `scripts/arcade_window_watch.sh:47`:
`4033 + 256 = 4289` ⇒ **CLOSED by 1883 MiB**. Compute apps (`--query-compute-apps`): `2347` Bonsai
**1364** + `2349` vision **134** + `87744` bge-small **226** + `145641` planner-4b **3482** = **5206**
(resident rung included); `used+free = 7891` vs 8192 ⇒ unreported driver/ctx **301**; **empty-scope
ceiling `2406 + 3482 = 5888`**, so the 9B's `6200 + 256 = 6456` is **568 MiB short of an empty card**
and the 4B's `3800 + 256 = 4056` clears it by 1832.

## The close edge, dated

The planner lease is a **real holder this time**, not the orphan cell the 09:30/09:40 ticks filed:
`scopes/planner/record.json` 494 B ino `10272179` birth **`10:30:13.820034833`** mtime `.822034791`
sha256 `75569bb0…d992d` owner `llama-swap-ocho-planner-4b` scope `planner` class `batch` **need 3800**
headroom 256 mode `run` pid **145542** acquired `1793295013` = 10:30:13 expires `1793381413` =
2026-10-30 10:30:13; wrapper `145542` **ALIVE** (`bash gpu-lease.sh run … -- Qwen3.5-4B-UD-Q4_K_XL.gguf`
`--ctx-size 8192 --port 5806`), child `145641` **ALIVE 3482 MiB** LISTEN `127.0.0.1:5806`,
`:8080/running` = `ocho-planner-4b state=ready proxy :5806`; journal
`ocho-planner-polymarket.service 10:30:07 Starting -> 10:30:17 Finished` exit 0 (3.210 s CPU /
10.333 s wall / 143.3 M — the success fingerprint, against 142-143 M + `status=1/FAILURE` for the
five refusals).

Capture `/tmp/gpu-lease.ofiB13` 1637 B birth `10:30:13.931032480` mtime `10:30:17.798950478` body
`loading model …/Qwen3.5-4B-UD-Q4_K_XL.gguf` … `model loaded` at **+1.110957 s** ⇒ **close
`10:30:15.042`**, `listening on http://127.0.0.1:5806` at +1.110961 s. The deciding draw is on its own
pick line, not inferred from the counter: `[O55] Weighted pick: ocho-planner-4b (30% weight, cycle
60356, pool 3/3)`; `model_cycle_counter.txt` = **60357** (POST-increment), mtime `10:30:13.729731719`.

## The open edge and the width

Carried from the 09:38/09:42 tick: **`09:30:16.402`** — the record born inside the 09:30 round's own
refusal (`cycle 60350` = 9B 60 %, `09:30:10 Starting -> 09:30:16 status=1/FAILURE`), whose swap-stop
took the resident smol (`/tmp/gpu-lease.4ASfUt`, loaded 09:20:14.8, 2672 MiB) and left the card above
the gate. Width, artifact to artifact: `10:30:15.042 - 09:30:16.402` = **3598.640 s = 59.9773 min =
5.99773 × 600 s** — six cycles, closed on the **sixth** draw after the opener.

The five draws inside the window were all the 60 % 9B and all refused (each `status=1/FAILURE`,
142.8-143.4 M peak): journal `09:40:06`, `09:50:21`, `10:00:13`, `10:10:09`, `10:20:12`, picks
`60351 / 60352 / 60353 / 60354 / 60355` = `ocho-planner (60% weight)` each, and **no capture after
`4ASfUt`** — no 9B load was ever reached; `/running` was `{\"running\":[]}` at every prior tick.

**The window bought nothing and its close bought one row:** the prediction lane
`agents/ocho/logs/ocho_predictions.jsonl` has rows `16:00:15.687`, `16:10:11.690`, `16:20:14.759`
(= 09:00 / 09:10 / 09:20 PDT, the 4B and smol loads that preceded the window) and then **nothing until
`17:30:17.898342` (10:30:17.898)** — zero plans across the 4200.6 s of the window, one plan from the
load that closed it (`plans/latest_plan.json` 942 B mtime `10:30:17.898271097`).

## Rulings

**R1 — `planner_at=planner` IS TWO OPPOSITE FACTS AND THE `kev_window` FIELD IS THE DISCRIMINATOR.**
The watcher derives the token from file existence (`arcade_window_watch.sh:31-38`: `[ -f
scopes/planner/record.json ]`), and `take_lease` writes the record **before** admission, so the same
token string stood on this box at the 10:26 sample over an **orphan** cell born inside the 10:20
refusal (dead pid, nothing resident, `{\"running\":[]}`) and at the 10:37 sample over a **live**
wrapper + 3482 MiB child on `:5806`. Nothing in `planner_at` changed between them; the only field
that moved is `kev_window`, and it moved *because* the holder took the card (free 5893→2406). So the
free-VRAM gate is not just the Kev question — it is the **second, independent witness** to the planner
token that file existence cannot give: a `planner` token beside an **open** gate is evidence the token
holds nothing, a `planner` token beside a **closed** gate with a live `/proc` + resident app is the
only state in which the flip is certified. Read the pair as one state machine; never `planner_at`
alone (extends `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` R1 and
`2026-10-29-the-rise-that-is-a-refusal-and-the-gap-that-is-a-release` R1 — those named the false rise,
this names the field that settles it; the three-read test stays the confirmation, the gate reading is
the cheap pre-filter).

**R2 — THE WIDTH REPLICATED EXACTLY AND NEEDS NO NEW MECHANISM.** Six cycles, 3598.640 s, opener a 9B
refusal, closer a 4B load — the same shape as `2026-10-19-a-window-width-is-the-distance-to-the-next-
rung-that-fits` R1 (59 m 47 s, 16:10:32.556 → 17:10:19.590, same six-cycle band) and
`2026-10-27-the-hour-wide-window-closed-on-the-first-draw-that-fits`. Under the fixed 6:3:1 weights a
window opened by a majority refusal survives `k` more rounds with `P = 0.6^k`: this one survived five
(`0.6^5 = 7.78 %`) and the mean wait is `0.6/0.4 = 1.5` refusals ⇒ **~2.5 cycles ≈ 25 min**. So a
60-minute window is the **upper tail of a geometric wait**, not an anomaly and not evidence that the
card or the rotation changed. Cite, do not re-derive; the increment here is only that the same width
recurred on a **drifting** tenant set (ceiling 5888 today vs 6113 at 07:49), i.e. the width is
insensitive to the ceiling within the range that keeps the 9B 232-568 MiB short.

**R3 — THE SHORTFALL'S DRIFT IS STEPWISE AND DATED BY PROCESS BIRTH, NOT NOISE.** The 09:38 tick
retracted the "constant" quantity and left the operand rule (`2026-10-29-an-admission-shortfall-
quoted-as-a-constant-is-a-sample-of-the-tenant-set` R1/R3: ceiling 6113 → 6268 → 5893 within a
morning). Measured again across this window: **5888 now vs 5893 at 09:38 — 5 MiB in 52 min** while
the tenant set read `1364 + 134 + 226` at both ends. The 375 MiB move earlier that morning coincided
with a tenant birth (`87744` bge-small, 226 MiB, born `09:09:05`) and a tenant death (the 248 MiB
Bonsai process); so the operand rule holds and gains its **resolution**: the ceiling is a **step
function of the live tenant set**, flat between births/deaths, and a shortfall quoted across a drift
should be quoted with the tenant census and the census' dates, not as a rate.

## Actions

No acquire, release, load, reservation, unit or config touched: `gpu-lease.sh`, `llama-swap.yaml`,
`scopes/planner/`, the planner unit, the three aux tenants (`-ngl 0`, all unleased) and the driver
READ-ONLY. `lease.d/` ABSENT, `scopes/` = `planner` only, `grep -rliE 'arcade|kev|model-test'
~/.local/state/gpu-lease` rc 1 — no away artifact. The 10:30:13 load was the timer's own request
through llama-swap; the five refusals were the timer's own.

## Messages

**NONE, both premises measured.** No `@ocho`: the diff carries `planner_at=planner` on both sides — no
flip — and his scoped-planner item is closed in HIS rows (`profiles/ocho/state.db` 9249 / 9267 /
16736, `max(id)=17405`); a DM here would reopen a closed item to certify a token the close edge, not
the flip, produced. No `@llama`: this is a **close** edge, free 2406 is 1883 MiB the wrong way, and he
self-authorises at `--scope arcade` — the fallback clause belongs to a `closed->open` window that
survives several ticks untaken, which this is not.

## Standing flag for Mike, re-measured `10:38`

`profiles/llama/cron/` has **NO `jobs.json`** (`jobs.lock`/`tick.lock` only, `executions.db` 24576 B
frozen `2026-10-12 06:33:07.322361061`, `output/` untouched since 10-12) while `ticker_heartbeat`
`1793295439.0969088` pid 2451 is rewritten every tick = **a live clock over an EMPTY JOB SET**. This
window ran 59.98 min at `+1604` MiB above the gate and nothing executed the standing Kev
authorisation; that is an execution fact, not a Kev decision. This watcher creates no jobs and
touches no tenant, and the only lever actually observed today is the **unleased `-ngl 0` tenant set**
(1724 MiB of CPU-only servers holding 568 MiB of 9B admission) — read as a fact about the card, never
as an instruction to stop a tenant (extends `2026-10-08-gpu-two-schedulers-live-budget` R1/R6).

## Prior art, printed BEFORE this file existed

`priorart.py rulings` (517 records, two phrasings): max **REVIEW `0.278
2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`** (read in full — owns R2's
mechanism, cited), `0.185 2026-10-27-the-hour-wide-window-closed-on-the-first-draw-that-fits`,
`0.155 2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits`,
`0.141 2026-10-19-a-window-that-cannot-close-because-its-closer-no-longer-fits`, `0.128
2026-10-27-the-refusal-that-reopens-the-window-and-the-empty-card-it-leaves`; second phrasing max
`0.151 2026-10-25-a-fitting-rung-is-not-a-load-and-a-window-across-a-failure-streak-is-not-an-
opportunity`. None states that the gate field certifies the token field (R1) or that the shortfall's
drift is a step function of tenant births (R3).

**READ-ONLY THROUGHOUT:** `nvidia-smi` ×6 + `--query-compute-apps`, `stat %w/%i/%s/%y`, `sha256sum`,
`ps -p`, `curl :8080/running`, `ss -ltnp`, `journalctl --user`, unit journal round census,
`model_cycle_counter.txt`, pick lines, `/tmp/gpu-lease.*` captures, prediction lane + plan file,
`gpu-lease.sh` not invoked for mutation, `priorart.py`.

RULINGFILE rulings/2026-10-29-a-token-is-certified-by-the-gate-beside-it.md
