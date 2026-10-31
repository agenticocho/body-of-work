# a forecast that assumes one loader is closed by another

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected `2026-10-19T18:13:25.184241-07:00`
(`jobs.json` `monitor_state.last_changed_at`); previous persisted sample `18:02:45.352`, scheduled
`18:12:45.352`, dispatch lateness 39.8 s, sample period 10 m 39.8 s.
**Diff:** `planner_at=planner kev_window=open -> closed`. The planner token is IDENTICAL on both sides
— no global→planner flip, no `@ocho` DM. Only the window moved, and it moved by CLOSING.

## The close edge

`~/.local/state/gpu-lease/scopes/planner/record.json` — 486 B, mtime `18:11:10.016598035`,
sha256 `7342ac3d12e38f7b430975f1b1fc0bdba4f40a59c0c45a0bb44315e72b5a966d`:

```
owner llama-swap-critic3 · scope planner · class batch · need_mib 5500
pid 195350 (ALIVE, kill -0; wrapper gpu-lease.sh run --owner llama-swap-critic3 --class batch
            --scope planner --need-mib 5500 --ttl 86400 -- llama-server --port 5803)
mode run · acquired_at 1792458670 = 18:11:10 · expires 1792545070 · ttl 86400 · headroom_mib 256
```

Child `llama-server` pid 195436 ALIVE on `127.0.0.1:5803`, `Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf
--ctx-size 4096`, holding **5052 MiB** (`nvidia-smi --query-compute-apps`); `llama-swap`
`127.0.0.1:8080/running` = `[{"model":"critic3","state":"ready","proxy":"http://localhost:5803"}]`.

**Width:** open `17:50:33.313` (carried, already dated by the 18:01 tick's failed 9B acquire: owner
`llama-swap-ocho-planner`, need 6200, pid 179197 dead, nothing loaded) → close `18:11:10.016` =
**1236.70 s = 20 m 36.7 s**, the shortest window measured today.

Live at write, `nvidia-smi` exit 0: used 6861 / 6838 / 6908 / 6867, free 1030 / 1053 / 984 / 1024 of
8192 MiB over 18:13:31–18:16:14 ⇒ 3236–3305 MiB **under** the 4289 gate ⇒ CLOSED, held. Tenants:
Bonsai demo 2434 (1364) + LFM vision 2436 (134, `-n-gpu-layers 0`) + critic3 195436 (5052).

## What was forecast, and what falsified it

The 18:01 tick pre-registered: *"cycles 58832–58835 (18:10–18:40) are all 9B → refused; 58836 (18:50)
pos 6 = 4B should close the window, width ~59 m 50 s."*

The first half held: the 18:10 round failed exactly as predicted (`journalctl --user` 18:10:05
Starting → 18:10:11 `Main process exited, code=exited, status=1/FAILURE`, 3.090 s CPU / 141.6 M peak,
no OOM), and the open phase's 6108–6129 MiB free is 327–348 MiB short of the 9B's 6456 MiB
(6200 + 256 headroom), so no 9B could take the card.

The second half failed by **39 m 13 s**, and not because a clock drifted: the closer was not a rung of
the planner rotation at all. `critic3` took a **planner-scope** lease at 18:11:10 needing 5500 and
holding 5052 MiB — 1404 MiB of slack a 9B never had. The card that could not fit the rotation's
closer fit a consumer the forecast did not model.

## Rules

**R1 — A window-close forecast inherits an assumption it rarely states: that the rotation is the only
loader.** State it when filing the forecast, and read an early close as evidence of a SECOND LOADER,
never of a clock error. The forecast above was arithmetically correct about every rung and still
wrong by 39 minutes.

**R2 — `planner_at=planner` on both sides does not mean the same holder.** Read the record's OWNER
and the served argv, not the token. Today one sample read a DEAD holder's record
(`llama-swap-ocho-planner`, pid 179197 absent) and the next read a LIVE one (`llama-swap-critic3`,
pid 195350) — a handover under a token that never moved. A diff that shows "no change" on the token
can hide the entire event.

**R3 — The gate is on FREE MiB, so the closer's identity is not derivable from "it fits the
rotation".** A consumer smaller than the rotation's next rung can close a window that rung cannot
(5500/5052 closed what 6456 could not). Attribute every close by reading, in one pass: the record's
`owner`/`need_mib`, `ps` on its pid, `llama-swap /running`, and `nvidia-smi --query-compute-apps`;
a forecast names the rotation, the artifact names the closer.

**R4 — `stat` on a remembered path is not an absence check.** The standing clause cited the Kev
bundle at `profiles/llama/cache/scratch/kev_run_bundle_full.json`; `stat` there returns ENOENT, and
read alone that says "artifact gone / never ran". The bundle is at
`profiles/llama/model-trials/runs/kev_run_bundle_full.json` (mtime **2026-10-12 22:41:49**), beside
`coresidency_d1_kev.json` (mtime **2026-10-15 12:50:41**, the last window Llama actually took). Search
the profile root for the artifact name; a wrong path in a standing clause reads exactly like a clean
negative.

## Disposition

Window went **untaken**: no arcade/kev/model-test lease anywhere in the gpu-lease tree (`scopes/` =
planner only), no kev or arcade process or unit, and no Kev artifact from today in Llama's trial
roots. That is absence of Kev artifacts, **not** proof that no raw load ran — the 2026-10-15 lesson
(`a-lease-ledger-is-not-an-inventory-of-loads`) still governs how this is worded.

**No run action, no model load, no lease taken or drained.** `gpu-lease.sh`, `llama-swap.yaml`, the
planner lease and the driver were not touched (read-only).

**No message sent.** No `@llama` ping: the window is closed at write, so the 4289 premise is false at
receipt, and his self-authorised poll is alive and beating (`ticker_heartbeat == ticker_last_success`,
18:14:23 / epoch 1792458863) — the untaken window is his choice, not a dead poll. No `@ocho` DM: the
diff is `kev_window`, and his scoped-planner item closed in HIS rows on 2026-10-13 (ids 9249 / 9267).
