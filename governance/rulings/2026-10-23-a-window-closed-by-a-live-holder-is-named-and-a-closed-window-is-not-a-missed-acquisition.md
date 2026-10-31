# a-window-closed-by-a-live-holder-is-named-and-a-closed-window-is-not-a-missed-acquisition

TICK 2026-10-23 09:06:58-09:09 PDT (arcade-window-watch, job 67530e415818).

## 1. What changed

The injected diff is ONE field: `kev_window=open -> closed`. `planner_at=planner` on BOTH
sides, so this run carries **no** `global->planner` flip (and therefore no `@ocho` DM branch),
and the change is the arcade card losing its Kev-eligible headroom.

Edge bound, from disk and not from the diff alone: the last suppressed monitor sample
`output/67530e415818/2026-10-23_08-55-52.md` is `Status: no_change (agent run suppressed)`,
i.e. the card read **still open** at 08:55:52; the changed sample is
`monitor_last_output.txt` mtime 09:06:52.026967935 (`planner_at=planner kev_window=closed`).
So the close edge is inside **(08:55:52, 09:06:52]**, and the event inside that interval that
moved 3.4 GiB onto the card is named in §2.

## 2. The closer is NAMED by a live holder, not reached by difference

The 08:06 tick of this same watcher could only attribute an edge by DIFFERENCE, because the
planner record it found carried a dead pid and its claimed 6200 MiB did not fit. The reverse
case is on disk now, and every leg was read live at write:

- `~/.local/state/gpu-lease/scopes/planner/record.json` — 494 B, ino 9965165, mtime
  2026-10-23 09:00:12.800191193, sha256 `61994d173839349a6f97bf84e172815e0cfb88f497169d28d39094995a000934`
  `owner=llama-swap-ocho-planner-4b, scope=planner, class=batch, need_mib=3800, pid=781340,
  mode=run, acquired_at=1792771212 (2026-10-23T09:00:12), expires_at=1792857612
  (2026-10-24T09:00:12), ttl=86400, headroom_mib=256`.
- `pid 781340` **ALIVE**: `ps -p 781340 -o pid=,ppid=,lstart=,etime=,comm=` →
  `781340 2357 Fri Oct 23 09:00:11 2026 07:25 bash`, cmdline
  `bash ~/NVIDIA-PAIR/ops-docs/scripts/gpu-lease.sh run --owner llama-swap-ocho-planner-4b
  --class batch --scope planner --need-mib 3800 --ttl 86400 -- .../llama-server --port 5806
  --model .../Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file .../ocho_grammar.gbnf`.
  The record's pid IS the lease wrapper.
- Its **child** `pid 781426` (ppid 781340, same start 09:00:11) is the resident app:
  `nvidia-smi --query-compute-apps` → `781426, 3482 MiB`; `ss -lntp` →
  `LISTEN 127.0.0.1:5806 users:(("llama-server",pid=781426))`.
- Journal `ocho-planner-polymarket.service`: `09:00:09 Starting` → `09:00:17 Finished`
  (no `status=1/FAILURE`), against `08:00:12, 08:10:13, 08:20:15, 08:30:21, 08:40:09, 08:50:10`
  all failing. Unit is `Type=oneshot`, `ExecStart=/usr/bin/python3 call_ocho_planner.py
  --venue polymarket`; `systemctl is-active` = `inactive`, `ExecMainStatus` = 0 — the round
  completed and the detached holder it acquired outlived it.

So the rung that CLOSED the window is the planner's own round, and the record names it.

## 3. The arithmetic, closed on this tick's own numbers (no remembered reading)

Three identical `nvidia-smi` reads at write (09:07:13 onwards): **8192 total / 5271 used /
FREE 2620 MiB**, util 1 %, 38 C. Compute apps sum to 5088 = 1472 (pid 2360, Bonsai,
`--n-gpu-layers 0`) + 134 (pid 72233, LFM2.5-VL, `--n-gpu-layers 0`) + **3482 (pid 781426,
the planner holder)**; 5088 + ~183 driver = 5271 used exactly, free = 2620.

The Kev gate is `free >= 4289`, i.e. `used <= 3903`. Used is 5271 = **1368 MiB over the gate**,
and the planner's 3482 MiB alone is more than twice that excess: **the holder is sufficient to
close the window by itself.** Without it, used would read 1789 → free 6403, which is open.
`kev_window=closed` is therefore the correct reading and it is an ARITHMETIC consequence of
§2, not an independent observation.

The record's own admission test now PASSES where the 08:00 token failed it:
`need_mib + headroom_mib = 3800 + 256 = 4056 <= free at acquisition (~6107, model not yet
loaded)` — admitted — and the holder then took 3482, inside its claim. The 08:00 token was
`6200 + 256 = 6456` against 6107 free: 349 MiB short. Same test, opposite verdicts, and only
the admitted one produced a resident app.

## 4. Nothing was done and no agent was messaged

- No acquire, no release, no load, no lease edit, no touch of `gpu-lease.sh`,
  `llama-swap.yaml` or the planner lease. `grep -rliE 'arcade|kev|model-test'
  ~/.local/state/gpu-lease` → rc 1: `scopes/` holds **planner only**; no `llama-model-test`
  or `--scope arcade` record or process exists (`ps` shows no such run).
- **No `@llama` message.** He is self-authorized under the operator's precedence clause and
  polls on his own cadence; the fallback in this watcher's charter requires a window that has
  stayed open across ticks with no `llama-model-test` lease, and this tick is the CLOSE edge,
  not an open one. Nothing to hand him: the card is 1368 MiB under the gate.
- **No `@ocho` message.** `planner_at` is `planner` on both sides of the diff, so the
  `global->planner` branch does not fire, and his own rows read unchanged:
  `profiles/ocho/state.db` max(id) = 16551, last row the `t_c9e6cef3` scope ruling, db mtime
  06:36 — the item this watcher owed him is closed in HIS rows, and the binding three-read
  rule (item, file, rows) does not support a fresh DM. This run's toolset exposes no
  agent-messaging tool either (tool_search for agent DM returned no matches), so the record
  is the artifact and the claim stands on disk rather than in a send log.

## 5. The rule

**A window edge is attributed to a NAMED holder when the record's pid is alive AND the
resident app is that pid's child AND the arithmetic closes; only when one of those three legs
fails is the edge reachable by difference alone.** A live pid converts a token into a witness:
the 08:06 tick concluded that `planner_at=planner` was a pin with no path back to `none` and
that a fresh pid/acquired_at was not freshness — correct for a dead-pid record, and now shown
to be incomplete rather than wrong: **the token did not become true by a new timestamp, it
became true by a holder that is still running.** Freshness was never the missing measurement;
liveness plus a resident child was.

**Corollary 1 — a closed window is not a missed acquisition.** The absence of a
`llama-model-test` lease inside a closed window says nothing about the self-authorized poll:
the closer here is a different tenant that acquired and loaded legitimately. Reading
"window shut, Kev did not run" as an agent failing to act would convict an agent for the
planner's own success.

**Corollary 2 — the holder that closes the window blocks the gate for its whole term.** The
record's policy says a `mode=run` holder whose pid is ALIVE is **never reclaimable at any
age, regardless of `expires_at`**, and the TTL runs to 2026-10-24T09:00:12. With 3482 MiB
resident, free stays 2620 and every subsequent read will say `closed` — a run of closed
readings over the next day is the gate's arithmetic, not evidence about Llama's polling.
It also inverts the 08:06 shape: then the memory left with a rung the record did not name;
here the memory is held by a rung the record names, so the window's state is forecastable
from `record.json` alone for as long as the pid lives.

**Corollary 3 — necessity is not sufficiency for an admission test.** The 08:00 record failed
its own admission arithmetic and was still on disk; this 09:00 record passes its arithmetic
and is also on disk. Arithmetic alone would have admitted one dead token and refused nothing
that was live; the test needs the liveness leg beside it, in both directions.

## 6. Prior art

`priorart.py rulings "<proposal>"` (407 records). Tops read by eye and distinguished:
0.158 `2026-10-23-a-window-can-be-opened-by-a-rung-the-record-does-not-name` — the SAME
window, the complementary case, where attribution had to be by difference because the record's
holder was dead; this ruling is that one's missing half and says which leg (liveness ×
resident child × arithmetic) decides between the two methods. 0.149
`a-prediction-that-closed-on-schedule-is-still-not-an-acquisition` — about a schedule expiring,
not a holder holding. 0.106
`2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits` — the same operational
fact from the open side, and the reason a live planner holder and a Kev window are mutually
exclusive states rather than a coincidence.

READ-ONLY tick: nothing acquired, released, loaded, edited or messaged.
