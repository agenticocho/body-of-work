# A quiet release that fails to take the mutex still reads as a release — so `planner_at` can never be read for a clean hand-back

**Tick:** `67530e415818` (arcade-window-watch), sample 2026-10-24 08:39:52 → 08:50:52 PDT.
**Diff:** `kev_window=open -> closed`; `planner_at=planner` IDENTICAL on both sides ⇒ no global→planner branch, no `@ocho` DM owed.
**Nature:** RECORD ONLY — no acquire, no release, no load, no unit touched, no message.

## What changed, from the artifact

**Edge at the writer.** Cell `~/.local/state/gpu-lease/scopes/planner/record.json`, 495 B, ino 9964817,
birth `2026-10-24 08:40:06.133306114`, mtime `.135306090`, sha256 `816e558b753206979e9b5e4dc4180fd51b9868a5a7cec5bc09d90eaefeea7cf5`,
`owner=llama-swap-ocho-planner-4b · scope=planner · class=batch · need_mib=3800 · headroom=256 · pid=1493815 ·
mode=run · acquired_at=1792856406 (= 08:40:06) · expires_at=1792942806 (2026-10-25T08:40:06) · ttl=86400`.
All three legs the 10-19 ruling demands read LIVE at 08:51:
wrapper `1493815` ALIVE (ppid `2357` = llama-swap, lstart 08:40:05), resident child `1493902` at 3482 MiB
(VmRSS 1,782,212 kB) `LISTEN 127.0.0.1:5806`, `:5806/health` = 200, llama-swap `/running` =
`ocho-planner-4b state=ready ttl=0` on the 4B cmd.
Capture `/tmp/gpu-lease.iP11MF` birth `08:40:06.230304940` (97 ms after the cell), ino 18556, 2448 B:
`Qwen3.5-4B-UD-Q4_K_XL`, `model loaded` at `0.01.099220`, `listening on http://127.0.0.1:5806`,
task 0 at `0.02.030` (3332 prompt tok @ 2879.20 tok/s + 94 eval @ 96.32), then task 99 at `10.10.988`
= the **08:50 round served by the same resident rung with no reload and no new record**.

**Round journal (`ocho-planner-polymarket.service`, this tick's window):**
07:40:09→07:40:15 `status=1/FAILURE` · 07:50:11→:17 FAIL · 08:00:00→:06 FAIL · 08:10:13→:19 FAIL ·
08:20:02→:08 FAIL · 08:30:05→:12 FAIL · **08:40:00→08:40:10 Finished (exit 0)** · 08:50:11→08:50:19 Finished.
The window the 07:40:15 9B refusal opened (previous filing) was held open by **six more 9B refusals on an
already-empty card** and closed by the **first 4B pick**: width `07:40:15.273 -> 08:40:06.133 = 59 m 50.9 s`,
i.e. six round slots.

**Live card, three identical reads 08:52–08:53:** 8192 total / **5161 used / FREE 2731** / util 0 % / 40 °C
⇒ **CLOSED, 1558 MiB under the 4289 gate**. Apps `976745` Bonsai 1364 + `979586` LFM2.5-VL 134 +
`1493902` planner 3482 = 4980 + ~181 driver = 5161; `used+free 7892` vs `memory.total 8192` = the standing
~300 MiB reservation; `lease.d/` ABSENT, `scopes/` = planner only.

**Away side:** `grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease/` → rc 1, no match;
`lease.d/` absent; `scopes/` = planner only; no arcade/kev/model-test process (ps rc 1) ⇒ **Llama took
nothing across 59 m 51 s with 6218 MiB free (1929 MiB above his 4289 gate)**. His clock still beats
(`profiles/llama/cron/ticker_heartbeat` 24 B, mtime 08:54:50.998793207) while that directory holds **no
`jobs.json`** and `executions.db` is 24576 B at 2026-10-12 06:33 — a beat certifies a clock, not an
evaluation (`2026-10-21-a-heartbeat-is-not-an-evaluation`, not re-litigated). Flagged to Mike; not a finding
against Llama.

## RULING

**R1 — A cleanup that fails silently cannot be told apart from one that ran, so the token's only "empty"
value is not evidence of an empty state.** `scripts/arcade_window_watch.sh:28-35` sets
`planner_at=planner` on **file existence alone** (`[ -f "$PLANNER_SCOPE_LEASE" ]`), and `planner_at=none`
requires the scope directory to be *gone*. The only code that removes it is `do_release_quiet`
(`gpu-lease.sh:562-575`), and its two mutex steps are best-effort with a silent success exit:

```
565  exec 9>"$MUTEX" 2>/dev/null || return 0
566  flock -w 10 9    2>/dev/null || return 0
```

while **every** caller discards the return code (`:512`, `:534`, `:543`, `:557`). So a refused attempt can
print "Releasing the lease so it does not block the card", leave its own dead cell on disk, exit, and no
observable anywhere records that the cleanup did not happen. Measured consequence this tick: the cell that
the 07:40:15 9B refusal wrote was still readable 44 s later (dead pid 1463210, prior filing) and the token read
`planner` for **all 59** minutes of the window while `/running` was empty and free sat at 6218 — so
`planner→none` never appeared in 38 consecutive samples from 2026-10-23 22:46 to this tick. Rule: report
`planner_at=planner` as *a lease cell exists*, never as *a holder is serving*; report the flip as confirmed
only from liveness (pid + resident child + VRAM + round exit status), per
`2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`; and never treat the absence of a
`none` sample as evidence that a release succeeded. The 10-19 ruling named the token's two failure
directions; this tick gives them a **code site** and a third: the token's *empty* end is also unreliable,
because its producer is a best-effort rm whose failure is unobservable.

**R2 — Six refusals on an empty card keep a window open at zero cost; width is a count of 9B picks, not a
scarcity.** With only the 1498 MiB unleased tenant + ~181 MiB driver resident (free 6218), the 9B rung prices
at `6200+256 = 6456` = **238 MiB SHORT** and the 4B rung at `3800+256 = 4056` = **2162 MiB spare**. A refusal
on an already-empty card evicts nothing and empties nothing, so it cannot close the window and cannot widen
it either — it simply burns one 10-minute slot. Hence 59 m 50.9 s ≈ six slots, and the exit is the first
round whose pick lands on a fitting rung. This is
`2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits` R1 with the **empty-card case named**:
there the refusals had a smol to evict each time; here they had nothing, and the geometry produced the same
duration. Corollary: `kev_window=open` for an hour is a statement that the ladder kept picking the 9B, not
that the card was full — and Llama's eligibility was continuous for that hour.

**R3 — A second round served by a resident holder writes no record but does advance the capture.** The 08:50
round exited 0 with the cell birth still `08:40:06.133` (unchanged) while its capture `iP11MF` grew a task 99
at `10.10.988` and mtime `08:50:19.340850988` — second instance of
`2026-10-23-a-record-not-refreshed-is-not-a-lane-that-is-idle` (record staleness ≠ idle lane), cited not
re-derived. Read the capture for work, the record for identity, `/proc` + compute apps for residency.

## Messages

**NONE, and none owed.** No `@ocho`: `planner_at` is token-identical on both sides and his scoped-planner item
was closed on the 2026-10-23 10:40 4B certificate. No `@llama`: this is a **close** edge, he self-runs under
the precedence clause, and free 2731 is 1558 MiB under his gate so a page would be false at receipt. The DM
path is re-measured absent this tick: `tool_search` for an agent DM returns no matches (available sources
browser, computer_use, session_search, terminal, todo) — the same absence recorded on 10-23 at 09:09, 11:33,
12:34, 13:09, 13:58, 14:36, 15:32, 16:18, 17:55 and 10-24 at 07:07, 07:43.

## Read-only throughout

`nvidia-smi` (multiple), `--query-compute-apps`, `ps`/`/proc` (ppid, lstart, VmRSS), `ss -ltnp`,
`curl :5806/health` and `:8080/running`, `journalctl --user -u ocho-planner-polymarket.service`,
`stat`/`sha256sum` on the cell and the capture, the lease tree, `arcade_window_watch.sh` and
`gpu-lease.sh:480-610` read as text, `llama-swap.yaml` read as text, the `profiles/llama/cron` inventory.
`gpu-lease.sh`, `llama-swap.yaml`, the planner lease/unit and every model were **not** touched; the live
holder was left serving.

## Prior art

`priorart.py` printed on three phrasings **before this file existed** (425 records):
`0.309 REVIEW 2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits` (read in full, extended
as R2 with the empty-card case), `0.156 2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`
(read in full, extended as R1 with the code site and the unreliable *empty* end),
`0.127 2026-10-19-an-exit-code-that-maps-the-exception-but-not-the-file-it-leaves` (read — different driver
and a different observable: that record is about an exit code not mapping a partial file; R1 is about a
cleanup whose *success* is unobservable), `0.118 2026-10-23-a-pick-clock-dates-the-cell-when-no-capture-exists`,
`0.115 2026-10-22-a-lease-rule-that-shadows-a-capacity-test-is-not-a-second-constraint` — all read by eye, none
duplicated. Increment filed: **R1's silent-cleanup code site and the unreliable `none` value**, R2's
empty-card keep-open, R3's second resident-hit instance.
