# A latch lives as long as the round the rung allows

**Filed 2026-10-26 14:41 PDT by the Arcade GPU co-residency watcher (profile `chilly`, cron job `67530e415818`).**
**Tick diff:** `planner_at=planner` **IDENTICAL on both sides** · `kev_window=open -> closed`.
**Nature of the tick: RECORD ONLY.** No acquire, no release, no load, no lease/unit/config touched, no message
sent — and the message branch's *premise* was re-read rather than assumed (see *Messages*).
**Built on, not re-filed:** `2026-10-13-an-instrument-recovery-is-not-a-subject-transition` (R2 — an identical
token can carry opposite truth; R3 — a playbook action's premise is a separate fact), `2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder`
(the closer is the planner's own 3482 MiB child: same shape, same numbers), `2026-10-21-a-rung-that-cannot-fit-is-a-scheduled-self-eviction`
(the ceiling arithmetic), `2026-10-14-a-window-that-is-a-rung-of-a-rotation` (the window is produced by design).
**Corrects:** `2026-10-26-a-latch-shorter-than-the-poll-and-a-window-open-beside-a-reservation` R1.

## The bracket

| sample | value | artifact |
|---|---|---|
| previous | `planner_at=planner kev_window=open` | `cron/output/67530e415818/2026-10-26_14-30-09.md`, 155 B, `no_change`, mtime **14:30:09.943272862** |
| current | `planner_at=planner kev_window=closed` | `cron/output/67530e415818/monitor_last_output.txt`, 36 B, mtime **14:41:08.943534704** |

Bracket **(14:30:09.943, 14:41:08.943]** = 659 s; its lower bound **is** the 14:30:09 `no_change` sample, so no
sample sits inside the band and the edge must be dated from the writer.
not left at the bracket: the scoped record's birth **14:30:16.373738103** is **6.43 s after** the previous sample,
so that sample legitimately read `open` and the close belongs to the planner's own acquire.

## The closer, on six legs

1. **Cell** — `~/.local/state/gpu-lease/scopes/planner/record.json`, **495 B**, ino **10271591**, birth = mtime
   **14:30:16.373738103**, sha256 **`ad470ab6255d21eec7ab913440a6972806568e20f9f58c4412a02a1ea24bd2c3`**:
   `owner=llama-swap-ocho-planner-4b  scope=planner  class=batch  need_mib=3800  pid=3228651  mode=run`
   `acquired_at=1793050216 (14:30:16)  expires_at=1793136616 (2026-10-27 14:30:16)  ttl=86400  headroom_mib=256`,
   liveness-first policy text unchanged.
2. **Wrapper ALIVE** — `ps` at 14:41:39: pid **3228651**, `ELAPSED 11:23`, `bash gpu-lease.sh run --owner
   llama-swap-ocho-planner-4b --class batch --scope planner --need-mib 3800 --ttl 86400 -- …/llama-server --port 5806
   --model …/Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file …/ocho_grammar.gbnf`.
3. **Child resident** — pid **3228781**, **PPID 3228651**, **3482 MiB** (`--query-compute-apps`). The 10-08 note in
   `chilly_containment/config/llama-swap.yaml:84` measured 3458 for this rung → `need-mib 3800`; today's 3482 agrees.
4. **`/running`** — `ocho-planner-4b`, `state: ready`, `proxy: http://localhost:5806`.
5. **`/health`** — `{"status":"ok"}` on `:5806`.
6. **Work** — `POST :5806/v1/chat/completions`, 8 completion / 17 prompt tokens, 46.27 tok/s decode, 247.3 tok/s
   prompt, output begins `{"contract_id` (the grammar holding). Service rounds: journal **14:30:07 Starting →
   14:30:22 Finished** (`exit 0`, 4.875 s CPU / 14.915 s wall / 141.7 M) and **14:40:09 → 14:40:18 Finished**
   (3.233 s CPU / 9.003 s wall).

`lease.d/` **ABSENT**, `scopes/` = `planner` only ⇒ this is a scoped lease, not a global one, and no other holder exists.

## The card (real measurement, not a dark probe)

`nvidia-smi` at 14:41:39: 8192 total / **5451 used / 2440 free** / 30 % / 46 °C; second read 5384 / **2508**.
Gate = `free -ge 4289` (`scripts/arcade_window_watch.sh:47`) ⇒ **1849 MiB under: closed**.
`--query-compute-apps`: 976745 Bonsai `Ternary-Bonsai-2-9B-PQ2_0` **1466** (unleased, `--n-gpu-layers 0`) + 979586
LFM2.5-VL **134** (unleased) + 3228781 scoped planner **3482** + 3235184 Hermes gpu-process **8** = **5090**;
`used − tenants = 361` (driver/ctx), `total − used − free = 301` standing reservation.

## R1 — CORRECTION: the latch's lifetime is the round's lifetime, and the round's lifetime is the rung's admission

The 14:11 filing measured a **130 s** latch and concluded *"the latch's lifetime floor is below the poll, so a
`planner` sample is a coin flip"*. Thirty minutes later the same artifact class is **11 m 23 s** old with a live
wrapper, a resident child, `ready`, `ok` and tokens in hand. **The lifetime is not a clock distribution.** It is the
**round's duration**, and the round's duration is fixed by the slot the weighted rotation picked. Measured today,
every pick line dated by cycle:

| cycles | pick (`[O55] 🎲 Weighted pick:`) | weight | need | rounds | outcome |
|---|---|---|---|---|---|
| 59910–59915 | `ocho-planner` (9B) | 60 % | 6200 | 13:30:02, 13:40:05, 13:50:07, 14:00:10, 14:10:00, 14:20:07 | **6/6 `status=1/FAILURE`**, 5.912–9.689 s wall, 141–157 M peak |
| 59916–59917 | `ocho-planner-4b` | 30 % | 3800 | 14:30:07, 14:40:09 | **2/2 `exit 0`**, 14.915 s / 9.003 s |

So the coin a `planner` sample tosses is the rotation's **6:3:1 weights**, not the poll's cadence. A tick that reads
`planner` is not sampling a time-varying latch; it is sampling **whichever rung the last round happened to pick**, and
the artifact's truth follows the rung's admission arithmetic. Corollary: the poll period was never the defect — the
14:11 filing's own prescription ("sample faster / gate on liveness") fixes nothing about the 6-in-10 failing rounds.

## R2 — the ceiling arithmetic that makes the 9B pick a scheduled failure (extension of 10-21, not a re-derivation)

9B needs **6200 + 256 = 6456**. With today's unleased floor the card's reachable ceiling is
**8192 − 1608 − 301 = 6283**; measured the same way from this tick's own numbers, evicting the planner child leaves
**2440 + 3482 = 5922**. **6456 exceeds both — by 173 MiB at the theoretical ceiling and by 534 MiB at the measured
one** — so the 9B rung cannot be admitted at any point while the 1466 MiB Bonsai tenant is resident. The six-failure
streak was arithmetic, not contention. What moved since 10-21 (free 6268 reachable, floor 1498) is the **floor**
(Bonsai 1364 → 1466), not the rung's need: a rule about "free VRAM" silently depends on who else is idle on the card.

## R3 — the pick line dates the rung, the journal dates the round, the record dates neither

A record is written by **both** a refusal and a load, so it cannot distinguish them; `/running` + `/health` + a token
completion can (R2 of `2026-10-25-a-lease-record-names-the-wrapper-and-the-card-names-the-child`). What today adds is
the **per-cycle pick line**: `agents/ocho/logs/ocho_planner_polymarket.log` prints `ABC model: <slot>` and
`Weighted pick: <slot> (N% weight, cycle M)`, so the rung is attributable *before* the outcome is known, and the
record's `owner` string must match it — a mismatch means llama-swap served a member the rotation did not choose
(the `planners` group is `swap: true`). `ExecMainStatus` in the unit journal is the only leg that separates
`Finished` from `status=1/FAILURE`; a cell's mere existence separates nothing.

## Messages

- **No `@ocho`.** The branch requires a `global → planner` **edge** and the token is identical on both sides: the flip
  is not new, it is the same value carried across a holder change (the exact shape of `2026-10-13` R2). The premise
  was re-read anyway, per R3 there, and it is **false**: Ocho closed the item himself on **2026-10-25 14:27:49**
  (`profiles/ocho/state.db` row **16736**, answering my row **16730**, 7/7 numbers reproduced), no open board card
  concerns the planner, and he independently read **this** wrapper at **14:35:21** (his row **17066**). A
  true-but-redundant DM into a live thread is the drop hazard; withheld.
- **No `@llama`.** Close edge — nothing is acquirable now, and the fallback is reserved for an OPEN window he did not
  take. Logged for the record: the window stood open from **≤14:11:10 to 14:30:16.374 (≥ 19 m 6 s)** and **no**
  `kev`/`arcade`/`model-test` lease, record or process appeared in it. His ticker still beats
  (`profiles/llama/cron/ticker_heartbeat` 14:43:07, pid 2957785) with `cron/jobs.json` **still absent** — the Kev
  self-authorisation still has nothing executing it. Standing flag for Mike, re-measured this tick.
- **Board** (`sqlite3 -readonly ~/.hermes/kanban.db`): **76 done / 1 triage** — `t_efd6df81` sokoban frontier,
  unrelated to the card.

Read-only apart from this file and the index line: `gpu-lease.sh`, `llama-swap.yaml`, both leases, the planner unit,
every model and every load untouched.
