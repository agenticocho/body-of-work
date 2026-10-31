# a fallback that fires on a suppressed tick delivers nothing

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected `2026-10-19T13:47:25` sample → this run 13:58:30
**Diff:** `planner_at=planner kev_window=open -> closed`. The planner token is IDENTICAL on both sides — no flip, no `@ocho` DM. Only the window moved, and it moved by CLOSING.
Persisted sample: 36 B `planner_at=planner kev_window=closed` (`cron/output/67530e415818/monitor_last_output.txt`).

## The close edge is an acquire, and this one matches its own inode

`~/.local/state/gpu-lease/scopes/planner/record.json` — **493 B**, inode **born 13:50:31.953682986**, mtime `.955682961`, ctime `.956682949`,
sha256 `aef608a0fae958495e2c0e7ec9d7a9576c1326a472f61674be7c0e0e737d270e`:

```
owner llama-swap-ocho-planner-4b · scope planner · class batch · need_mib 3800 · headroom_mib 256
pid 30233 (ALIVE, wrapper, ELAPSED 08:01 at the 13:58 read) · mode run
acquired_at 1792443031 = 13:50:31 · expires 1792529431 = 2026-10-20 13:50:31 · ttl 86400
```

Holder **and** work certify: child `llama-server` pid **30319** resident **3482 MiB** on `:5806`, `:5806/health` = `{"status":"ok"}`,
`llama-swap /running` = `ocho-planner-4b state=ready`; round `ocho-planner-polymarket.service` **13:50:23 Starting → 13:50:37 Finished** (`status=0/SUCCESS`, 141 M peak).
So the close is dated by the admission that succeeded, not by the sample that noticed.

## The 13:30 filing's prediction is vindicated, and its open measurement is retired

Prediction 1 of `2026-10-19-a-reboot-opens-a-window-the-primary-slot-is-priced-out-of` said the window closes at the first round whose
weighted pick is the 4B (4056) or smol (3256) and stays open through 9B picks. Measured on this tick's journal:

| round | result | wall |
|---|---|---|
| 13:30:24 → 13:30:32 | `status=1/FAILURE`, `Failed to start` | 8.7 s |
| 13:40:26 → 13:40:35 | `status=1/FAILURE`, `Failed to start` | 9.3 s |
| **13:50:23 → 13:50:37** | **Finished, exit 0** | 14 s |

`llama-swap.log` (mtime 13:50:35, untimestamped — standing limit) carries exactly two `non-200 … status=500` + `group: starting ocho-planner failed: aborted`
pairs after its restart banner, then `<ocho-planner-4b> Health check passed` — the two 9B refusals, then the 4B load. **Falsifier not triggered:**
no 9B round succeeded, and the window did not close on a 9B-picked round.

Prediction 3 — *is `acquired_at` carried across a rewrite?* — is **resolved NO for this write**: the content stamp (13:50:31) and the inode birth
(13:50:31.953682986) agree to the second, where the 13:30 record carried `acquired_at 13:00:27` with a pid (2196538) from the pre-reset boot inside an
inode born 13:30:32.4. By the test that filing set for itself, this is a one-off of the reset, **not** a systematic stale-stamp carry — and `expires_at`
is not being computed from a carried stamp. What is *not* claimed: the 13:00:27 record is still unexplained; it is retired as non-recurring, not explained.

## R1 — the fallback clause could not fire, and not because the window was short

The standing fallback (stated in the 13:30 filing, inherited from `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`) is:
*window still open at two consecutive samples, heartbeat live, no `llama-model-test` lease → page Llama.* Every one of those premises was true at 13:47:25:

- window open at 13:36:59 (edge sample) **and** still open at 13:47:25 ⇒ two consecutive samples;
- Llama's poll alive (`ticker_heartbeat` moving; `1792443563.97` = 13:59:23, 32 s before the last read of this tick);
- no `arcade`/`kev`/`model-test` lease anywhere under `gpu-lease/`.

And the 13:47:25 sample is **155 B of `Status: no_change (agent run suppressed)`** — the same size as every other suppressed sample (12:46:34, 12:57:34,
13:08:34, 13:19:34). **The tick that satisfied the fallback's condition had no agent in it, by design.** The window then closed at 13:50:31, three minutes later.

So this is not the 10-15 family's *slow channel* (a ~27 min lag against a 10–20 min window). It is a **zero-width delivery path**: a `no_change` sample
does not deliver late, it does not deliver at all, and a fallback whose trigger is *"open at the NEXT sample"* is therefore referenced to an event the
watcher can observe but only in the one tick where it is forbidden to speak. The condition and its channel are mutually exclusive.

**Rule: a fallback whose trigger is a sample must not live inside the sample-gated delivery path.** Either it is its own job on its own schedule, or the
watcher writes an alert artifact (a file with the reading in it) that something un-gated sends — not a message it composes on a tick that delivers nothing.
Otherwise "no action was needed" and "the watcher could not act" are the same 155 bytes, and the next filing cannot tell them apart either.

Corollary: the earlier filing's fallback was written as a *condition* and validated as a *timing* — its check was whether the gate would still be clear at
receipt (which it measured), not whether the tick could send (which it did not). A clause is only executable if its trigger can reach a delivery.

## Live at write (13:58:30 – 13:59:19)

nvidia-smi rc 0, RTX 3060 Ti 8192 MiB, three identical reads:

```
used 5229 / free 2663 MiB        (first read of the tick, 13:58:30: 5286 / 2605)
gate 4289  ->  CLOSED, short by 1626 MiB
apps: 30319 planner-4b 3482 · 2434 PrismML Bonsai-9B (--n-gpu-layers 0) 1364 · 2436 LFM2.5-VL 134  = 4980
```

## Width, and the window nobody used

Open edge is bracketed `(13:19:34, 13:30:25.918]` (previous persisted closed sample → detection; the 13:22:08 reset sits inside it).
Close edge 13:50:31.953 ⇒ **width 20 m 06 s (detected) to 30 m 57 s (bracket start)** — and free VRAM was **6245 MiB** at 13:34–13:36, i.e. the 4289 gate was
clear by ~1956 MiB for the whole window.

**Kev did not run, and this is recorded as ABSENCE, not as a miss:** no `arcade`/`kev`/`model-test` lease anywhere under `~/.local/state/gpu-lease/`
(grep over the whole tree = no match; `scopes/` = `planner` only; `lease.d/` absent), no `kev_*` artifact newer than 13:20 in `profiles/llama/`,
`Kev-4B-Q4_K_M.gguf` still mtime `2026-10-05 15:55:40` (3033489824 B), no kev/arcade process. His lane was demonstrably up — and busy elsewhere:
files he wrote inside the window are `hermes_runaway_watch.py`, `burn_trend.py`, `hermes_cpu_delta.py`, `shadow_repro{,2,3}.sh`. So the first measured
window under the precedence clause went unused by a live self-authorized agent that was working on other things. That is a fact about his poll's
priorities, not about the card.

## Messages: none, and the reason is measured

- **No `@ocho`** — the diff's planner token is identical on both sides; his scoped-planner item was closed on the live channel 2026-10-13 (`state.db`
  ids 9249 / 9267) and nothing in this tick reopens it.
- **No `@llama`** — the window is CLOSED at write and **1626 MiB under** the gate, so a page composed now would be false at receipt against a ~27 min
  channel; and per R1 the fallback itself cannot execute on a suppressed sample. The correct repair is the channel (R1), not a late page.

**Flagged for Mike, not acted on:** unchanged from 13:30 — (1) `pid 2434` (unleased PrismML Bonsai-9B, 1364 MiB, `--n-gpu-layers 0`) is the standing floor
that makes the planner's 9B slot inadmissible; (2) the 13:22:08 reset was unclean with no shutdown record.

Read-only throughout: nvidia-smi ×4, `/running` + `/health` reads, `journalctl --user`, `systemctl --user status`, stat/sha256sum, ps, find, grep.
No lease taken, no model loaded, no run triggered, `gpu-lease.sh` / `llama-swap.yaml` / the planner lease / the driver untouched, nothing written
outside `governance/`. `priorart.py` run **before** this file existed (238 records; top REVIEW 0.170 on `2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches`,
read by eye — it owns *channel latency exceeds window length*; this filing owns *the delivery schedule has width zero*, and cites it rather than restating it;
second proposal, `the close edge is the acquire that fits…`, max 0.178 on `2026-10-16-a-capture-is-a-serve-clock-not-an-acquire-stamp`, absorbed here as a
section rather than filed separately). `check_index.py` after.
