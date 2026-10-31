# The hour-wide window closed on the first draw that fits, and the band logged no plans

**Tick:** `67530e415818` (arcade-window-watch), change at the `08:40:08` sample. Bracket from the persisted
chain: previous sample `cron/output/67530e415818/2026-10-27_08-29-08.md` (155 B, `Status: no_change`,
mtime `08:29:08.852725249`, still carrying the 34 B open line sha256 `8da24188…216fe2`) → current
`cron/output/67530e415818/monitor_last_output.txt` (36 B, mtime `2026-10-27 08:40:08.900131536`, sha256
`b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`, `planner_at=planner kev_window=closed`).

**Diff:** `planner_at` **IDENTICAL both sides** (no `global→planner` flip, so the `@ocho` branch does not fire) ·
**`kev_window open → closed`**.

**Filed as a dated instance, not a new class.** `priorart.py rulings` (503 records) on three phrasings returned
nothing above `weak 0.175` (`2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits`) and
`weak 0.171` (`2026-10-27-the-window-closes-on-a-live-rung-under-an-unchanged-token`, ten hours earlier today);
the mechanism is owned by `2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits` and
`2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits`. The increment is the numbers in §1–§4 and
the away-side measurement in §5. This close is the **second edge of the window whose open edge is
`rulings/2026-10-27-the-window-opener-is-the-workloads-own-refusal-and-nothing-acquires.md`** (open at cell birth
`07:30:08.434641369`), cited not re-derived.

## 1. Live at write — three identical reads

```
08:41:0x / :1x / :2x   8192 MiB total · 5393 used · FREE 2499 · util 6–13 % · 43 °C
```

`2499 < 4289` = **CLOSED by 1790 MiB**. Gate is `free >= 4289` = Kev-4B 4033 peak + 256 headroom
(`scripts/arcade_window_watch.sh:12` comment, `:47` test — read this tick, not quoted from memory).

Occupants (`--query-compute-apps`): pid `976745` PrismML-Bonsai **1466** + pid `979586` LFM2.5-VL **134** +
pid `4035235` scoped planner-4B **3482** = **5082** of `used 5393`, leaving **311** MiB of driver/context over the
tenants; `used + free = 7892` against `total 8192` puts the standing **300** MiB in neither column. `scopes/` holds
`planner` only, `lease.d/` absent (no whole-card lease).

## 2. The closer is the workload's own live rung — six artifacts, one instant

The record under the scoped lease at write:

```
scopes/planner/record.json  495 B  ino 10354824  birth 08:30:07.170133141  mtime .172133109
sha256 32d2a4298118ed01922747e9bffb044f120f5125ee3767bc245d9e19752c482a
owner llama-swap-ocho-planner-4b · scope planner · class batch · need_mib 3800 · headroom_mib 256
pid 4035148 · mode run · acquired_at 1793115007 (08:30:07) · expires_at 1793201407 (2026-10-28 08:30:07) · ttl 86400
```

1. `scopes/planner` **dir born** `08:30:07.166133205` — a birth, not an mtime move, so the 07:30 cell dir was
   unlinked before it (a release deletes its own bid and its scope dir: `2026-10-25-the-scoped-cell-is-written-by-a-refusal-and-a-release-deletes-its-own-bid`).
2. Wrapper `4035148` **ALIVE** (`lstart Tue Oct 27 08:30:06`, ppid `2357` = llama-swap, etime `10:45` at read),
   args `gpu-lease.sh run --owner llama-swap-ocho-planner-4b --class batch --scope planner --need-mib 3800 --ttl 86400 -- llama-server --port 5806 --model …/Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192`.
3. Child `4035235` **ALIVE**, ppid `4035148`, **3482 MiB** on `127.0.0.1:5806`.
4. `curl :8080/running` → one entry `{ocho-planner-4b, state ready, proxy http://localhost:5806, ttl 0}`;
   `:5806/health` → `{"status":"ok"}`.
5. Capture `/tmp/gpu-lease.3tVKiW` ino `21084`, **birth `08:30:07.271131525`** (+101 ms after the record), mtime
   `08:40:10.908112276`, 2454 B: `load_model … model loaded` at **+1.118190 s** ⇒ **08:30:08.389**, `listening on
   http://127.0.0.1:5806`, task 0 served (3467 prompt tok @ 2858.85 tok/s + 97 eval @ 94.78 tok/s, `n_tokens 3563,
   truncated 0`, released at +4.250249 s), then **task 102 launched at +600.018328 s = 08:40:08.9** on the same
   resident — the rung served the next round without a reload.
6. Journal `ocho-planner-polymarket.service`: `08:30:00 Starting` → `08:30:11 Finished` **exit 0** (3.487 s CPU /
   11.218 s wall / 142.7 M peak). Exit 0, unlike every 9B round in the band (§3).

**Close instant = `08:30:08.389`,** dated off the capture's own `model loaded` line and bracketed by the samples
(`open` at `08:29:08.852` → `closed` at `08:40:08.900`). The record alone cannot date it: a **refusal writes the same
495 B cell** with the same owner/need/mode fields (`2026-10-26-a-refusal-arrives-as-the-flip-and-a-pre-registered-directive-fires` R1),
so the discriminating artifact is the capture, and behind it the journal's exit status.

## 3. Width, and the band priced in the scope's own output

**Width `07:30:08.434641369 → 08:30:08.389 = 3599.955 s` = 5.99992 × the 600 s scheduler period** — six rounds:
the 07:30 refusal that authored the open cell, five more refusals (07:40, 07:50, 08:00, 08:10, 08:20 — all
`status=1/FAILURE`, 6.392–7.109 s wall, 3.392–3.446 s CPU, 142.0–142.9 M peak, the refusal fingerprint), then the
08:30 4B draw that **finished exit 0**.

**Priced in the lane's own output, per R1 of `rulings/2026-10-21-a-window-opened-by-refusals-is-the-planner-lanes-outage.md`:**

* `ocho_sandbox/ocho_predictions.jsonl` carries a row at `2026-10-27T14:20:16.352281Z` (07:20:16 PDT,
  `model_slot=ocho-planner-smol`) and then **nothing until `15:30:11.690968Z` (08:30:11.690 PDT,
  `model_slot=ocho-planner-4b`)** — **zero plans inside the 3599.955 s band**.
* The close's own round wrote a plan **2.70 s after the load** (`15:30:11.690` vs `08:30:08.389`); the 08:40 round
  wrote another (`15:40:11.028656Z`) on the same resident. `plans/latest_plan.json` 989 B, mtime `08:40`.
  So the hour bought nothing and the closed state bought two plans in ten minutes — the same asymmetry the 10-21
  filing priced, measured again.

**The arithmetic that held it open, and the shortfall is now the widest on file:**

```
9B  ask  6200 + 256 = 6456   vs empty-card ceiling 5981 = 475 MiB SHORT   (every 9B draw in the band)
4B  ask  3800 + 256 = 4056   vs 5981 = 1925 MiB spare                     (the 08:30 draw)
ceiling reconstructed: 2499 free + 3482 resident = 5981 (arithmetic on two measured numbers, not a read)
```

`475` is the widest this ledger has carried (317 at 2026-10-22 12:53, 345 at 2026-10-26 08:48, 354 at 2026-10-26
11:15, 470 at today's 07:30 open). It is not a property of the 9B: it is `(ceiling − asks)`, and the **ceiling
itself** reads 5981 today against 6139 on 2026-10-22 — `used` with nothing scoped is 1911 here (aux floor 1600 +
driver/ctx 311) against 1752 there. Read the pair every tick; the 9B has been priced out on an **empty** card for
the whole of today's band.

## 4. The token's byte-string is again identical to a different close

The current line's sha256 `b391e197…0b1` is the digest the profile recorded for the **07:07** close, an hour earlier
and a different holder process; the intervening open line `8da24188…6fe2` was itself byte-identical to the 06:32
open sample. Recurrence, not new: `2026-10-27-the-window-reopens-under-a-record-born-dying-and-the-log-is-the-recurrence`
R2 — identical bytes are not a continuous state, and a digest certifies the string, never the token's referent.

## 5. Away side: an hour-wide window with 1692 MiB of headroom went untaken, and the reason is measurable

Free stood at ~5981 (1692 MiB over the 4289 Kev gate) for the full 3599.955 s. **Llama took nothing:**
`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` → no match (rc 1); `scopes/` = `planner` only;
`lease.d/` absent; `pgrep -af 'kev_run|arcade_|model-test'` matched only this shell. Recorded as **absence of
artifacts and processes**, never as proof that no raw load ran, and not as proof he did not try from a live session.

His lane, re-measured this tick rather than carried: `profiles/llama/cron/` holds `.jobs.lock`, `.tick.lock`,
`executions.db` (24576 B, mtime **2026-10-12 06:33**), `output/` and the two ticker files rewritten **08:40** —
**`jobs.json` does not exist**. So the standing self-authorisation (acquire at `--scope arcade` when free ≥ 4289)
has a live clock over an **empty job set**: there is no executor on this box to act on an hour-scale window.
This is the third measured instance of that flag (`2026-10-21-a-heartbeat-is-not-an-evaluation`,
`2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits`, `2026-10-26-a-latch-lives-as-long-as-the-round-the-rung-allows`),
now on the widest window yet. Flagged for Mike in this tick's report; the watcher cannot create a job list.

## 6. Messages: none, and both premises are measured

* **No `@ocho`.** `planner_at` is identical on both sides, so the clause's trigger never fired. His scoped-planner
  item is closed **in his own rows**: `sqlite3 -readonly profiles/ocho/state.db` → `max(id) 17362`, count 17362,
  newest message `2026-10-26 15:50:00`; the closure row is 16736 (2026-10-25 14:27) and the only later row that
  mentions `--scope planner` is his own `ps` output at id 17066 (26th, re-reading the live-4B certificate). There
  is nothing to close, and a DM into a closed item is the drop-hazard class
  (`2026-10-14-the-closure-is-in-the-recipients-row`). Re-measured, and the DM path is still absent from this
  cron toolset (deferred catalog: browser/computer_use/session_search/terminal/todo — no agent-message tool).
* **No `@llama`.** This is a **close** edge and `2499` is 1790 MiB on the wrong side of his gate, so a "window is
  open" page would be false before it was written (`2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder` R4).
  He self-authorises and this watcher does not trigger runs.

## 7. Read-only, and what this does not establish

No acquire, no release, no load, no reservation, no unit or config edit: `gpu-lease.sh`, `llama-swap.yaml`,
`scopes/planner/`, the planner unit, the resident 4B and the driver were read, never written. The 08:30 load and
the 08:40 serve were the timer's own requests through llama-swap. Every number above is a disk read from this tick
(`nvidia-smi` ×3 + `--query-compute-apps`, `stat`/`sha256sum`, `ps`/`/proc`, `journalctl --user` 07:29–08:31,
`curl :8080/running` + `:5806/health`, `/tmp/gpu-lease.3tVKiW` as text, the predictions jsonl and plan file, the
lease tree, `arcade_window_watch.sh:12/47`, `profiles/llama/cron/`, `sqlite3 -readonly` on Ocho's db).

**Not established:** the 5981 ceiling is reconstructed by adding the resident's footprint to the current free, so
a load whose measured footprint drifted inside the band would shift it by that drift; and nothing here says the
band would have been taken by an arcade contender had one existed — it says none appeared.
