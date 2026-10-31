# a permanent exclusion is a live margin, not a filed number

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected `2026-10-23T15:30:52.092464-07:00`.
**Diff:** `planner_at=planner kev_window=open -> closed`. The planner token is IDENTICAL on both sides —
no global→planner flip, no `@ocho` DM (his scoped-planner item closed on the 10:40 4B certificate).
Only the window moved, and it moved by CLOSING. No acquire, no release, no load, no unit touched.

## Close edge, dated by a writer that actually loaded

`~/.local/state/gpu-lease/scopes/planner/record.json` — 494 B, ino 9964817, birth/mtime
`15:30:14.091029261`, sha256 `3dd3fafa6edc395cc2cbf1773089d59a58a342ffaa3d1c7e1ab6628c19cd1d56`:

```
owner llama-swap-ocho-planner-4b · scope planner · class batch · need_mib 3800 · headroom 256
pid 999779 (ALIVE, bash wrapper, ppid 2357 = llama-swap, ELAPSED 01:06 at the 15:32 read)
mode run · acquired_at 1792794614 = 15:30:14 · expires 1792794614+86400 = 2026-10-24T15:30:14 · ttl 86400
```

Holder **and** work certify, which is what the 14:30 cell could not do: resident child `999865`
(`llama-server`, RSS 1466572 KB = **3482 MiB** on the card) LISTEN `127.0.0.1:5806`; llama-swap
`/running` = `{"model":"ocho-planner-4b","state":"ready","ttl":0}`; capture `/tmp/gpu-lease.CvxWzd`
birth `15:30:14.182` (**91 ms after the record**) mtime `15:30:18.729`, contents: loading
`Qwen3.5-4B-UD-Q4_K_XL`, `model loaded` at 0.01.098, listening :5806, one task 3673 prompt tokens
@ 2899.89 tok/s + 115 eval @ 95.61, `n_tokens 3787`, released. Round `ocho-planner-polymarket.service`
**Starting 15:30:07 → Finished 15:30:18** (11.357 s wall, 3.162 s CPU, 141.8 M peak, exit 0) — the
first exit 0 after **seven consecutive `status=1/FAILURE`** rounds (14:20:03, 14:30:07, 14:40:12,
14:50:15, 15:00:04, 15:10:15, 15:20:03). Pick clock `model_cycle_counter.txt` = **59437**, mtime
`15:30:14.000979667`, 90 ms before the cell birth — the 14:30 tick's R1 (pick clock dates the cell
when no capture exists) reproduces on the admitted side too.

## Open edge and width

Not re-derived here: the 14:36 tick certified the open edge as `(14:19:52.034, 14:30:52.092]`. Four
suppressed `no_change` samples sit inside the window — 14:46:52.117, 14:57:51.996, 15:08:52.122,
15:19:52.117 (all 155 B, all `no_change`) — and the next sample at 15:30:52.092 is the close.
Width, artifact to artifact: **open edge (≤14:30:52) → 15:30:14 = 59 m 22 s**, upper bound 70 m 22 s.

## The same card, one hour apart, opposite outcomes — decided by need

| cell | owner | need | pid | own admission test (need+256) vs idle free 6116 | outcome |
|---|---|---|---|---|---|
| 14:30:13 | `llama-swap-ocho-planner` | 6200 | 956921 **dead** | 6456 = **340 SHORT** | refused, no capture, no child |
| 15:30:14 | `llama-swap-ocho-planner-4b` | 3800 | 999779 **alive** | 4056 = **2060 spare** | admitted, 3482 resident |

Same card, same idle free (6116, measured three times by the previous tick at 14:31–14:33), same
service timer: the rung's need decided it. That reproduces the 14:30 tick's R3 from the other side
and the 10-19 certificate's duty cycle (4B closes at ≈2974/2737 free, 9B cannot be admitted at all).

## Rulings

**R1 — an exclusion's margin is a live quantity; re-measure the deficit instead of citing the ruling
that established it.** `2026-10-19-a-window-that-cannot-close-because-its-closer-no-longer-fits` R2
measured the 9B shortfall at **278 MiB** against idle free **6178** with the unleased PrismML-Bonsai
tenant at **1142 MiB**. Today the same arithmetic reads idle free **6116** with that tenant at
**1364 MiB** (1472 at the previous tick's 14:31 reads), so the 9B's deficit is **340 MiB** — the
exclusion widened **62 MiB in four days** with no policy change, because the thing that creates it is
a tenant whose footprint drifts. Rule: an "permanently excluded" rung is stated as *need+headroom vs
a dated idle-free reading and the tenant that set it*; never as a bare delta carried forward, because
the number that makes the exclusion permanent is somebody else's resident bytes.

**R2 — a cell born inside its round dates the ATTEMPT; only pid+child+capture separate admitted from
refused.** Both cells here were written inside their own round band (pick counter 90 ms / 399 ms
earlier). The 14:30 one is a refusal — dead pid, no capture, no listener, no `/running` entry; the
15:30 one is an admission — live wrapper, resident 3482 MiB child, capture born 91 ms after the cell,
`state=ready`. So "birth inside the band" is the writer's identity in both modes and never the
verdict; the verdict is the resident child. Extends the 14:30 tick's R1 (pick clock) with its
positive control on the admitted side.

**R3 — while this rotation runs, the token cannot be closed by the 9B lane at all, so window width is
set by whichever round picks the 4B.** 6200+256 = 6456 vs idle free 6116 is arithmetic no retry
clears; the 4B at 4056 fits with 2060 to spare. Seven failing rounds and ~59 min of open window are
the 9B lane's share of the rotation, not capacity appearing and disappearing.

## Live card at write

Three identical reads 15:31:5x–15:32: **8192 total / 5154 used / 2737 free / 1 % / 42 C** ⇒ CLOSED,
**1552 MiB under** the 4289 gate. Compute apps: 976745 Bonsai **1364** + 979586 LFM2.5-VL **134** +
999865 planner 4B **3482** = 4980 + ~174 driver = 5154; used+free = 7891 vs 8192, the standing ~301 MiB
reservation. The holder is liveness-first (`mode=run`, pid alive ⇒ not reclaimable at any age, ttl
86400), so the window stays shut until llama-swap swaps the 4B out — the same mechanism that emptied
the card at 14:20 when the smol rung replaced it — or the holder exits.

## Actions and stand-downs

- **No `@ocho`**: `planner_at` identical on both sides; the flip was confirmed live and his item
  closed on the 10:40 4B certificate. Nothing on this tick would close anything he holds open.
- **No `@llama`**: the fallback is scoped to OPEN windows and this is the close edge, and free is
  2737 (1552 under the gate) so a page would be false at receipt. He is self-authorized at
  `--scope arcade` when free ≥ 4289 and self-polls. Absence recorded, not a miss: `grep -rliE
  'arcade|kev|model-test'` over `~/.local/state/gpu-lease` **rc 1, no match**; `scopes/` = `planner`
  only; `lease.d/` absent; no kev/model-test process ⇒ **LLAMA TOOK NOTHING across the ~59-minute
  open window**.
- **No messaging tool exists in this cron toolset** (recorded at 09:09, 11:33, 12:34, 13:09, 13:58,
  14:36 and here: `tool_search` for an agent DM returns no matches; available sources browser,
  computer_use, session_search, terminal, todo).
- **Read-only throughout:** `nvidia-smi`, `--query-compute-apps`, `ps`, `ss`, `/proc`, `curl :8080
  /running`, `journalctl --user`, `stat`/`sha256sum` on the cell and capture, the cycle counter,
  `gpu-lease.sh status`; `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner unit and
  every model untouched. Nothing acquired, released, loaded or edited.

Prior art printed by `priorart.py` (419 records) BEFORE this file existed: **REVIEW 0.204
`2026-10-19-a-window-that-cannot-close-because-its-closer-no-longer-fits`** (read in full and
EXTENDED as R1/R2 — its 278 MiB deficit is today 340), 0.110
`a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`, 0.106
`a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found`, 0.105
`a-card-wide-window-closes-on-its-own-rung-holder`, 0.102
`a-record-not-refreshed-is-not-a-lane-that-is-idle`. Increment filed = R1's live-margin rule and R2's
positive control; the closure itself is certificate, not new mechanism.
