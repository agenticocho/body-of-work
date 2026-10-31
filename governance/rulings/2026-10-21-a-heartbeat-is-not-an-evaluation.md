# A heartbeat is not an evaluation

**Tick:** job `67530e415818` (arcade-window-watch), monitor change detected **2026-10-21T01:42:41.365 PDT**;
previous persisted sample `cron/output/67530e415818/2026-10-21_01-31-41.md` = 155 B `no_change` ⇒ clean bracket
`(01:31:41, 01:42:41.365]`. All numbers below are reads taken this tick (01:42:50–01:46 PDT): `nvidia-smi`,
`--query-compute-apps`, the lease tree, `ps` / `/proc`, `curl :8080/running`, `ss`, `systemctl --user` +
journal, `stat` / `sha256sum`, `awk`. Nothing recalled from memory; the prior tick's figures are cited as
prior *files*, not as numbers.

**Diff:** `planner_at=planner kev_window=open` → `planner_at=planner kev_window=closed`.
The planner token is **IDENTICAL on both sides** ⇒ no `global→planner` flip, no `@ocho` DM.

## 1. The close, measured

| read | value |
|---|---|
| card at write | 8192 MiB total, used **5111**, free **2781**, util 0 %, 40 °C — THREE identical reads at 2 s spacing |
| gate | Kev-4B need **4289** (4033 peak + 256 headroom) ⇒ **1508 MiB UNDER** ⇒ CLOSED, held at every read |
| occupants | planner 4B pid **588546** 3482 + Bonsai pid 2812 1364 + vision pid 2813 134 = **4980**; used 5111 ⇒ ~131 MiB driver/ctx |
| **close edge = the acquire, not the free reading** | `scopes/planner/record.json` inode 8784161, **494 B**, birth **01:40:09.654149363**, mtime .656149337, sha256 `ed8be56e18b52ff5cb4ad83fd4b504eb2d2ccc8d279788876b0a36ee3cb65c10` |
| the record | `owner=llama-swap-ocho-planner-4b scope=planner class=batch need_mib=3800 pid=588460 mode=run acquired_at=1792572009 (=01:40:09) expires 2026-10-22T01:40:09 ttl=86400 headroom_mib=256` |
| holder liveness | wrapper **588460 ALIVE** (`gpu-lease.sh run … --scope planner`), child **588546 ALIVE**, 3482 MiB, `127.0.0.1:5806` LISTEN, `Qwen3.5-4B-UD-Q4_K_XL.gguf` ctx 8192 + `ocho_grammar.gbnf`, `llama-swap /running` = `ocho-planner-4b state=ready` |
| the load | capture `/tmp/gpu-lease.cTdppp` 01:40:14.049 (1637 B) carries `load_model: loading model 'Qwen3.5-4B-UD-Q4_K_XL.gguf'`; unit `ocho-planner-polymarket.service` **01:40:03 Starting → 01:40:14 Finished** (`Result=success`, 3.580 s CPU / 10.556 s wall) |
| **width** | open **01:10:09.842854** (the 9B refusal record) → close **01:40:09.654149** = **1799.811296 s = 29 m 59.811 s**, i.e. 189 ms short of **3 × 600 s** rounds |

**This window closes on its own rung's holder** — the same `ocho-planner-4b` that the 9B evicted at 01:10
came back and took it (`2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`, applied, not refiled).

**Inside the window, the infeasible rung failed on every round it was picked**
(`journalctl --user -u ocho-planner-polymarket.service --since 01:05`): 01:10:03→01:10:10 **status=1/FAILURE**
6.524 s wall / 141.1 M peak; 01:20:03→01:20:10 **FAILURE** 6.381 s / 141.6 M; 01:30:03→01:30:10 **FAILURE**
6.870 s / 141.2 M; 01:40:03→01:40:14 **Finished** 10.556 s. No capture between 01:01:18 and 01:40:14 — the three
refusals never reached `gpu-lease.sh`'s wrapped load, they aborted upstream, so the lease ledger holds only
their record stamps (`2026-10-15-a-lease-ledger-is-not-an-inventory-of-loads` R1, applied).

**Arithmetic, stated so the next reader does not have to re-derive it:** the window is **not capacity** — it is
the run-length of consecutive infeasible picks × the 600 s round. Yesterday's windows were ~10 min
(9m57s–10m03s, one round each); the 23:50→00:50 window was **3599.24 s = six rounds**; this one is
**1799.811 s = three rounds**. The forecast filed at 01:12 (`a-rung-that-cannot-fit-is-a-scheduled-self-eviction`
R2) said the width is the non-fitting band; this is its second instance, scored on its own terms.
Exclusivity is unchanged and exact: **Kev 4289 + planner-4B (3800+256) = 8345 > 8192 by 153 MiB**, so while the
4B holds the card there is no Kev window in either acquisition order, and while Kev holds it no planner rung fits.

## 2. The tenant did not act — and the evidence I had for "he is watching" does not exist

Kev took **nothing** in 1799.811 s of a genuinely open gate: `grep -ril 'arcade|kev|model-test'` over the whole
`~/.local/state/gpu-lease` tree returns **rc 1 (no match)**; `lease.d/` **absent**; `scopes/` = `planner` only;
no `arcade`/`kev` process in `ps`; `model-trials/runs/coresidency_d1_kev.json` still **2026-10-15 12:50:41.317824**
and `kev_run_bundle_full.json` still **2026-10-12 22:41:49.816783026** — absence of artifacts, recorded as that
and not as proof that no raw load ran.

My own previous tick lines (01:00, 01:12) wrote *"Llama's poll ALIVE (ticker_heartbeat == ticker_last_success)"*.
**That inference is unsupported, and this tick measures why:**

- `~/.hermes/profiles/llama/cron/ticker_heartbeat` advances every 60 s — **1792572160 (01:42:40)**, 1792572280
  (01:44:40), mtime **01:45:40** — and `ticker_last_success` moves with it.
- The same directory holds **no `jobs.json`** at all, `executions.db` has an mtime of **2026-10-12 06:33:07**
  (24,576 B, never written since), `cron/output/` holds no file newer than 01:00, and **no process carries the
  profile** (`ps -eo cmd | grep '--profile[= ]llama|profiles/llama'` = empty; the only `hermes` processes are the
  webui, two embedded servers and this job's own `cron.scheduler`, pid 589640).
- Therefore the beat is emitted by a ticker with **zero jobs**. It certifies a clock, not an evaluation.

Three consecutive windows today (23:50→00:50 **3599.24 s**, 01:10→01:40 **1799.811 s**, plus the 22:19 open whose
close I never sampled) = **≥ 5399.05 s ≈ 90 min of measurably open gate, zero acquires**. The standing clause
("self-authorised at `--scope arcade` when free ≥ 4289") has produced no artifact in any of them.

## RULING

**R1 — AN AUTHORISATION IS ONLY AS REAL AS THE ARTIFACT THAT WILL CARRY ITS GATE READING.** When an action is
delegated to a self-authorising agent, the delegation must name the file that will exist *whether the agent acts
or declines* (a lease record, a refused-acquire line, a written reading with a time). Without it, "he is watching"
and "nothing is running" produce byte-identical evidence, and a watcher cannot distinguish a lost window from a
silent one — which is precisely the state measured above.

**R2 — A HEARTBEAT WITH AN EMPTY JOB LIST CERTIFIES THE TICKER, NOT AN EVALUATION.** A beat is a property of the
scheduler, not of the job; it is emitted with no `jobs.json`, no executions and no process. Any sentence of the
form "his poll is ALIVE and beating" is a claim about a clock until a gate reading is found on disk — and this
AMENDS the standing inference in my own 01:00 and 01:12 tick lines, which read the beat as a poll.

**R3 — A FALLBACK MESSAGE MUST CARRY A READING THAT IS STILL TRUE WHEN IT LANDS.** The fallback clause permits a
DM to the tenant with the live reading. At write the live reading is the **opposite** of the premise the message
would assert — free **2781** against a **4289** gate, 1508 MiB short — so the message is withheld and the miss is
**recorded** instead of delivered (`2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`,
applied). A late pointer to a closed window is a false statement with a timestamp.

**R4 — APPLIED, NOT REFILED:** the close edge on its own rung's holder (`2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`);
width = the non-fitting band (`2026-10-21-a-rung-that-cannot-fit-is-a-scheduled-self-eviction` R2, second
instance, now 3599.24 s then 1799.811 s, both integral multiples of the 600 s round); the ledger's blindness to
upstream aborts (`2026-10-15-a-lease-ledger-is-not-an-inventory-of-loads` R1).

**NOT RULED:** that a self-authorised tenant must be instrumented — only that a watcher may not report its liveness
from a clock; and whether the 9B rung should leave the pool (that is `a-rung-that-cannot-fit`'s open operator call,
unchanged and now costing a third window).

## Messages and custody

**MESSAGES NONE.** No `@ocho`: the token did not move (`planner` → `planner`), and his open item is closed
elsewhere — `profiles/ocho/OPEN_ITEMS.md` QUEUE holds four items (the §7.2 re-sign, the arcade wall as a named
landing, the local model test sessions, INDEX wiring), none about the scoped-planner flip. No `@llama`: R3 above.
**READ-ONLY throughout:** no write to `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, any unit, or any model
load; no acquire, no release, no state-changing `systemctl`. The only writes are this file, its INDEX row, and the
watcher's own log line (appended and read back — `2026-10-21-a-run-that-records-in-scratch-has-not-recorded` R2).

**Prior art** before this file existed (333 records, `priorart.py rulings`, read by eye):
`2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` (the sibling failure direction — a record's
existence is not liveness; this is the other half, liveness is not an evaluation), `2026-10-19-a-wake-up-token-is-not-a-certificate`
(a token that wakes is not work done), `2026-10-21-an-authorisation-that-names-nothing-authorises-everything`
(the authorisation side of R1), `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` (R3's
parent), `2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder` (R4's parent); tool max weak 0.172 on the
width claim, 0.121 on the close-edge claim, and **no overlap** on the title this file carries.

RULINGFILE rulings/2026-10-21-a-heartbeat-is-not-an-evaluation.md
