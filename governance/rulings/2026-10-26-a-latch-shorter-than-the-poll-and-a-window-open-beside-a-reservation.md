# A latch shorter than the poll, and a window open beside a standing reservation

**Filed 2026-10-26 14:20 PDT by the Arcade GPU co-residency watcher (profile `chilly`, cron job `67530e415818`).**
**Tick diff:** `planner_at=global -> planner` · `kev_window=closed -> open` (both tokens moved in one band).
**Nature of the tick: RECORD ONLY.** No acquire, no release, no load, no lease/unit/config touched, no message
sent — and none executable from this toolset (see *Messages*).

## The bracket

| sample | value | artifact |
|---|---|---|
| previous | `planner_at=global kev_window=closed` | `cron/output/67530e415818/2026-10-26_14-00-59.md`, 6,904 B, mtime **14:00:59.512757532** |
| current | `planner_at=planner kev_window=open` | `cron/output/67530e415818/monitor_last_output.txt`, 34 B, mtime **14:11:10.590793522** |

Band width **611.078 s**; no suppressed sample exists between them (`ls -t` on the output dir: 14:11:10 monitor
write, then 14:00:59). This tick's dispatch was `scheduled 14:10:59.549 / dispatched 14:11:07.912 / lateness 8.4 s`
(`cron/jobs.json`), so the sample instant is **14:11:10.590** — 8 s after the cell that triggered it was already dead.

## Both edges, dated by their writers — and both inside the band

**(a) CELL BIRTH 14:10:07.046532478** — `~/.local/state/gpu-lease/scopes/planner/record.json`, **492 B**
(the 9B-rung cell size class; the 4B cells are 495 B), parent dir born `14:10:07.041532536`, so dir + cell in one
acquire. Content, verbatim:

```
owner=llama-swap-ocho-planner  scope=planner  class=batch  need_mib=6200  pid=3206007  mode=run
acquired_at=1793049007 (14:10:07)  expires_at=1793135407 (2026-10-27 14:10:07)  ttl=86400  headroom_mib=256
```

No `-4b` in the owner string ⇒ the **6200 MiB 9B rung** (`llama-swap.yaml:80`, Qwen3.5-9B-UD-Q4_K_XL, ctx 8192,
wrapped as `gpu-lease.sh run --owner llama-swap-ocho-planner --class batch --scope planner --need-mib 6200`).

**(b) The cell's birth second IS its round's exit second.** `journalctl --user -u ocho-planner-polymarket.service`:
`Starting` **14:10:00** → `Main process exited, code=exited, status=1/FAILURE` **14:10:07** → `Failed with result
'exit-code'`, `Consumed 3.498s CPU time over 6.980s wall clock time, 142.2M memory peak`. Same signature as
`2026-10-26-a-record-born-dying-and-thirteen-edges-no-record-carries` R1: a refusal, not a load.

**(c) SWEEP + FOREIGN GLOBAL TAKE 14:12:17.695…14:12:17.708** — `scopes/` mtime `14:12:17.695028523` with
**0 entries** (`ls -A | wc -l` → 0); `lease.d/` born `14:12:17.702028442`; `lease.d/record.json` mtime
`14:12:17.708028373`, **483 B**:

```
owner=ocho-window-t_925f606f  scope="" (GLOBAL)  class=batch  need_mib=3600  pid=3208569  mode=run
acquired_at=1793049137 (14:12:17)  expires_at=1793052737 (15:12:17)  ttl=3600  headroom_mib=256
```

That pid is **ALIVE**: `bash /home/chilly1/NVIDIA-PAIR/ops-docs/scripts/gpu-lease.sh run --owner
ocho-window-t_925f606f --class batch --need-mib 3600 --ttl 3600 -- python3 -u suite/suite3.py --cab…` (read at
14:12:43, etime 00:25). **The sweeper is the Ocho arena suite, not the planner** — the same owner family that took
the whole card at 13:48:07 (`2026-10-26-a-location-token-is-not-about-its-subject-once-another-owner-writes-it`).

**(d) Latch lifetime = 14:12:17.695 − 14:10:07.046 = 130.649 s.**

**(e) The excursion completed before the next sample:** at **14:14:17** `lease.d/` is **absent** and `scopes/` is
empty, i.e. the arena released too. Both edges — birth and sweep — and the foreign occupancy all sit inside the
611 s band; the poll saw only the first.

## Live card

| read | total | used | free | util | temp | compute apps |
|---|---|---|---|---|---|---|
| 14:11:14 | 8192 | 2099 | **5793** | — | — | 1466 Bonsai(976745) + 134 LFM(979586) + 8 Hermes(3025101) + **314** MiMo-9B(3206754, `-ngl 0`) |
| 14:12:27 | 8192 | 1779 | **6112** | 0 % | 50 °C | 1466 + 134 + 8 (the `-ngl 0` child gone) |
| 14:14:17 | 8192 | 1734 → 1795 | **6158 → 6097** | 0 % | 43 → 46 °C | 1466 + 134 + 8 |

`:8080/running` → `{"running":[]}` at 14:11:14 and again at 14:14:17. `/v1/models` lists the eleven planner-family
groups; none resident. Gate (`arcade_window_watch.sh`, Kev-4B 4033 + 256) = **4289** ⇒ over by 1504 / 1823 / 1869-1808.

**Admission arithmetic at the same reads:** ask `6200 + 256 = 6456` vs **5793** free at 14:11:14 = **663 MiB
short**, and vs 6112 at 14:12:27 = **344 MiB short**. The 9B rung is still structurally inadmissible at today's
ceiling (297 short at 05:40, 863 at 11:15's 5593-equivalents, 663/344 now) — baseline drifts, verdict does not.

## RULINGS

### R1 — The latch's lifetime is set by the next stranger and can be SHORTER than the poll, so a `planner` sample is a coin flip, not a detection

`2026-10-25-a-foreign-acquire-is-the-only-release-the-planner-latch-gets` R2 established that the dead-pid refusal
cell has *no lifetime of its own* — it ends when someone else wants the whole card — and measured one instance at
**23 min 28.3 s**. This tick measures the same class at **130.649 s**, i.e. **0.21 of the sampling period**, with
both edges inside one band. So the published lifetime range is now `[130.6 s, 23m28s]` and its floor is below the
poll: a cell of this class can be **born and swept between two samples**, in which case the diff reports nothing at
all and the `global -> planner` branch — the only message-carrying branch — never fires. The token therefore fails
in both directions the corpus already named **and** in a third it did not: it can be *absent at every sample* while
the event happened (`2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` covers early fire; this
covers no fire). Any statement built on this token must quote the sample instant, and the word "confirmed" may
describe only that instant.

### R2 — The confirming branch's evidence can die before the turn reading it finishes; gate the message on the holder's LIVENESS, never on presence

The branch as written is: *"read `scopes/planner/record.json` to confirm the owner/need, then message @ocho: the
scoped-planner flip is confirmed live end-to-end."* Measured this tick, in the order it happened: cell intact at
**14:11:14** (492 B, `need_mib=6200`, `owner=llama-swap-ocho-planner`); cell `rm -rf`'d and its path re-occupied by
another owner's **global** cell at **14:12:17** — 63 s later, while this turn was still reading. And the four
independent artifacts refute the branch's premise *at* the intact moment:

1. `ps -p 3206007` → **no row** (and never in `--query-compute-apps`);
2. no resident tenant of 3800/6200 MiB (largest non-floor app was 314 MiB at `-ngl 0`);
3. `curl :8080/running` → `{"running":[]}`;
4. `llama-swap.log` tail carries repeated `[WARN] group: starting ocho-planner failed: aborted` and
   `upstream command exited prematurely` interleaved with `non-200 … status=500, path=/v1/chat/completions`.

So the evidence for a *message* can be destroyed by a third party mid-turn, while the evidence *against* it needs
one `ps` and one `curl`. The gate must be the record's own liveness predicate (`mode=run` + `kill -0 $pid`), read
in the same pass as the content, with the journal line that dates it — never file presence, never a remembered pid.

### R3 — `open` beside a standing reservation is now OBSERVED, not read from code

`2026-10-25-a-foreign-acquire-is-the-only-release-the-planner-latch-gets` R4 filed the gap between `kev_window`
(`nvidia-smi` free only) and entitlement (the lease) explicitly as **not observed**: *"nothing was acquired, nothing
collided."* This tick observes both sides at once: at **14:12:27** a `need_mib=3600` **global** reservation had stood
for 10 s with a live holder pid, and `kev_window` read **open by 1823 MiB** (6112 free vs 4289 gate) because the
holder's entrant loads had not landed yet. Under the precedence hook (`gpu-lease.sh` `PRECEDENCE_SCOPE=arcade`) an
`--scope arcade` contender is **not refused** by that reservation, so a Kev-4B acquisition taken on this reading would
have entered the same window whose suite rows record `card_max_mib` 4569 / 7063 / 7273 — a collision the lease would
have permitted by design. Quote the pair (free **and** who holds the card), because either alone inverts the
conclusion: `open` alone says "go", the cell alone says "taken", and both were true in the same second.

**Extends** `2026-10-25-a-foreign-acquire-is-the-only-release-the-planner-latch-gets` (R2's lifetime floor measured
below the poll period; R4's mechanism observed in the field), `2026-10-26-a-record-born-dying-and-thirteen-edges-no-record-carries`
R1 (`birth == exit` reproduces exactly, 14:10:07) and `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`.
**Distinguishes** `2026-10-24-an-eviction-inside-an-unsampled-band-opens-the-window-its-receipt-names-the-later-refusal`
(an *eviction* in an unsampled band; here the band held a refusal, a sweep, a foreign take and a release) and
`2026-10-24-a-window-can-be-closed-between-rounds-by-another-client` (a window closed by a client the timer does not
own; here the window was **opened** by a refusal and **closed** by a reservation that had not yet loaded).

## Messages

**NONE, and none executable.** No `@ocho`: his scoped-planner item closed on the 2026-10-23 10:40 live-4B
certificate and is closed in **his own rows**; today's diff would have carried the opposite of the truth — a
"confirmed live end-to-end" message about a cell whose pid was dead at the sample second and whose file no longer
exists. This is the third tick today on which the 60 %-weight 9B round has produced the branch that would carry that
message, and the second on which the pre-registered directive in
`2026-10-26-a-refusal-arrives-as-the-flip-and-a-pre-registered-directive-fires` R3 fired exactly as written
(*"the next reading will be `planner_at=planner` … do not report it as a flip confirmation, and do not message
`@ocho` on file presence"*). No `@llama`: he self-authorises at `--scope arcade` on his own poll under the operator
precedence clause, this is the **first** tick of the window, and the fallback clause wants an untaken window across a
couple of ticks. Independently, the DM path is re-measured **absent** in this toolset — `tool_search "send message to
another agent profile dm"` → 0 matches; deferred catalog = `browser`, `computer_use`, `session_search`, `terminal`,
`todo` — so the escalation channel is this delivery to Mike.

## Away side (Llama), measured not assumed

`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` → rc **1**, no match; `ls -A scopes/ | wc -l` → **0**;
`pgrep -af 'kev_run|arcade_|model-test'` → self-match only. He took nothing, with the standing caveat that scope
records are deleted on release, so this is absence of an artifact rather than proof of inaction.

## For Mike (re-measured, not carried)

1. **The 9B rung cannot fit and every attempt leaves a corpse that can hold the latch for an arbitrary time.**
   Ask 6456 vs a ~6100 MiB ceiling; today it held 130.6 s, on 10-25 one held 23m28s. A rung that only ever fails
   still writes the cell that the confirming branch reads.
2. **The arena suite is now a whole-card tenant, not a scoped one.** `ocho-window-t_925f606f` took the **global**
   lease (need 3600, ttl 3600) at 14:12:17, ten minutes after a 21-minute window that nothing used; it released by
   14:14:17. Its entrant rows reach 7273 MiB used, so while it holds the whole card the precedence clause is the only
   thing that would admit Kev.
3. **Standing flag, unchanged:** `profiles/llama/cron/ticker_heartbeat` and `ticker_last_success` both beat at
   **14:15:07**, but `profiles/llama/cron/jobs.json` **does not exist** and `executions.db` is frozen at
   **2026-10-12 06:33:07** — a beat certifies a clock, not an evaluation. The operator's Kev self-authorisation has
   nothing on this box executing it; the card was genuinely clear (`none` held, 6158 free) at 14:14:17.

## Read-only throughout

`nvidia-smi` (query-gpu ×4, query-compute-apps ×2), `date`, `ps`/`pgrep`/`/proc` liveness, `curl :8080/running` and
`/v1/models`, `stat`/`ls -A`/`find` on the lease tree, `journalctl --user -u ocho-planner-polymarket.service` and
`--user` 14:05-14:15 (no OOM line), tails of `chilly_containment/logs/llama-swap.log`, reads of `gpu-lease.sh`
(`do_acquire`, `do_run`, `LEASE-SHORT`), `llama-swap.yaml`, `arcade_window_watch.sh` and `cron/jobs.json` as text.
**Untouched:** `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the arena window lease, every model, every unit.
The only writes are this file, its INDEX row and the tick row in `state/monitor/arcade_gpu_watcher.log`.

## Prior art

`priorart.py` printed **before this file existed**, over **489 records in `rulings/`**, on three phrasings:
max **0.151** `2026-10-25-a-foreign-acquire-is-the-only-release-the-planner-latch-gets` (read in full — R2 owns
"no lifetime of its own", extended here with a measured floor below the poll; R4 owns the open-vs-entitlement gap
but filed it *unobserved*, so R3 here is its field instance), **0.143** `2026-10-13-a-fresh-record-from-a-failed-acquire`
(owns "a fresh record from a failed acquire is evidence of the FAILURE, not of a holder" — scored instance),
**0.150** `2026-10-21-a-change-token-is-not-an-event-without-an-artifact`, **0.129** `2026-10-19-a-token-that-closes-on-its-own-subjects-success`,
**0.115** `2026-10-24-an-eviction-inside-an-unsampled-band-opens-the-window-its-receipt-names-the-later-refusal`,
**0.086** `2026-10-26-a-record-born-dying-and-thirteen-edges-no-record-carries` (read in full — R1 reproduces exactly
and is cited, not re-filed). `grep -rlE 'lifetime.*poll|shorter than the poll' rulings` → no match; no record on file
states a latch lifetime below the sampling period, and none records an `open` reading taken against a live global
reservation.
