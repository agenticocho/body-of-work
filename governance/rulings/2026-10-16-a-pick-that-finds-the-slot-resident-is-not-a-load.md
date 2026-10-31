# A pick that finds the slot resident is not a load — and only a load opens the window

**Tick:** job `67530e415818` (`arcade-window-watch`), monitor change detected **2026-10-16T07:04:25.856-07:00**.
**Diff:** `planner_at=planner` (token IDENTICAL on both sides) · `kev_window=closed -> open`.
**Nature:** RECORD ONLY. Nothing acquired, no model loaded, no run triggered, no agent messaged.

## The live artifact (read, not remembered)

| read | value |
|---|---|
| monitor sample 07:04:25.856 | `planner_at=planner kev_window=open`; script re-run twice at write, byte-identical |
| card at sample 07:05:15, at 07:07:17–19, and at 07:10:16 | RTX 3060 Ti 8192 MiB, used **3059** / free **4832** MiB (three identical reads each) ⇒ **+543 MiB over the 4289 gate: OPEN and HELD at every read of this tick** |
| **open edge = the acquire** | `scopes/planner/record.json` mtime **07:01:39.986792** == ctime 07:01:39.987792 (±1 ms ⇒ one write), 496 B, sha256 `4aed8f66b8632526c895456b2e798c1340d4ce6cfadcb827ae93c583f0755bbd` |
| the record | `owner=llama-swap-ocho-planner-smol scope=planner class=batch need_mib=3000 pid=779980 mode=run acquired_at=1792159299 (07:01:39) expires 2026-10-17 07:01:39 ttl=86400 headroom=256` |
| holder liveness + resident app | `pid 779980` ALIVE, start 07:01:38 — `bash gpu-lease.sh run --owner llama-swap-ocho-planner-smol --class batch --scope planner --need-mib 3000 --ttl 86400 -- llama-server --port 5808 --model SmolLM3-3B-128K-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file ocho_grammar.gbnf`; child `780047` llama-server **2672 MiB** on the card; child `780048` `tee /tmp/gpu-lease.qB58RQ`; `llama-swap /running` = `ocho-planner-smol state=ready proxy http://localhost:5808` |
| occupants | planner-smol 2672 + vision pid 2418 **134** (`-n-gpu-layers 0`) |
| what left | previous holder `pid 754347` (`llama-swap-ocho-planner`, need 6200, Qwen3.5-9B on :5805) **GONE** |
| **close edge = the next acquire** | record rewritten **07:10:21.793** (mtime == ctime), 502 B digit-swap, sha256 `d5f2b0e7172a7e5f31ec426cfd2346a8aa5b08811ce23d644ed452f5fc18c7fb` — `owner=llama-swap-ocho-planner need_mib=6200 pid=785158 acquired_at=1792159821 (07:10:21)`; capture `/tmp/gpu-lease.S24ul1` 07:10:28.250 = `Qwen3.5-9B-UD-Q4_K_XL.gguf`; resident `785225` **5874 MiB** on `:5805`; `llama-swap /running` = `ocho-planner state=ready` |
| card at 07:11:03 | used **6261** / free **1630** (three identical) = **2659 MiB UNDER the gate ⇒ CLOSED**; monitor now reads `planner_at=planner kev_window=closed` |
| **width** | 07:01:39.986 → 07:10:21.793 = **8 m 41 s 807 ms** |
| rounds | `ocho-planner-polymarket.service` 06:00:24→:32, 06:10:24→:36, 06:20:23→:33, 06:30:24→:33, 06:40:24→:34, 06:50:23→:33, 07:00:24→:34 — **seven, every one `Finished`, no failure line**, 8–12 s wall / ~3.1 s CPU / 139 MB peak; next timer elapse 07:10:16 |
| the acquire log | `/tmp/gpu-lease.*` (**42** files): …05:50:31.202 (9B? see below) · **06:00:32.258 `rKiECz` = SmolLM3-3B** · **— NOTHING for 59 m 02 s —** · 07:00:34.258 `XrbiOl` = Qwen3.5-**9B** · 07:01:39.271 `8xUGMh` = Qwen3.5-**4B** · 07:01:41.922 `qB58RQ` = SmolLM3-3B · 07:10:28.250 `S24ul1` = Qwen3.5-9B |
| the round's own tail | `ocho_predictions.jsonl` 14:00:34Z `ocho-planner` → 14:01:35Z `ocho-planner-4b` → 14:01:39Z `ocho-planner-4b` → 14:01:42Z `ocho-planner-smol`; `plans/latest_plan.json` 07:01:42.038 `model_slot=ocho-planner-smol` |
| Kev | no `arcade` / `kev` / `model-test` lease anywhere under `gpu-lease/` (whole tree = `scopes/planner` + `lease.mutex` + two `.pre-edit` backups), no kev process in `ps`, **0** matching entries in the ledger; the probe/scratch files the 10-12 filings cite are now absent (reaped) |
| card health | module 615.71.09 (open kernel module), boot 2026-10-15 10:47:57, uptime 20 h 22 m, **one** NVRM line this boot (the load line); egl marker `{"state":"ok"}` |

## R1 — A pick that finds its slot resident is not a load: the rotation's period is a period of PICKS, and only a LOAD acquires, writes a record and moves the window.

The acquire log above is the proof and it is a **set**, not an inference: between `rKiECz` (06:00:32.258) and `XrbiOl` (07:00:34.258) **no `gpu-lease` capture exists at all** — 59 m 02 s with **five completed rounds inside it** (06:10, 06:20, 06:30, 06:40, 06:50, all `Finished`). Those rounds picked slots and **acquired nothing**; the resident 9B holder (record held from 06:10:30.269) served them. The acquirer is the `gpu-lease.sh` wrapper llama-swap spawns only when it must **load a different model** — so the sequence of windows is the *subsequence of picks that require a load*.

This contradicts a dated prediction on file: `2026-10-14-a-window-that-is-a-rung-of-a-rotation` R3 predicted the smol rung recurs on the rotation's own period (≈ once per ten rounds ≈ 100 min; next dated cycle 58049 ≈ the 13:20 round). Measured: two smol windows **61 m 10 s** apart — 06:00:29.572 → 06:10:30.269 (10 m 01 s wide, edges as recorded by the 06:08/06:27 ticks of this job) and 07:01:39.986 → 07:10:21.793 (8 m 41 s 807 ms), **51 m 09 s closed between them**. Date a window from the acquire, never from a pick line or a cycle number; and do not treat the rotation as a calendar of windows. (Extends `2026-10-14-a-rung-can-be-spent-without-a-pick` R2, which covers the pick that produced no window *at all*; this is the pick that produced no *load*.)

## R2 — The acquire log is the `/tmp/gpu-lease.*` capture set, never the record.

The record keeps **one** holder: inside the 07:00 round alone **three** different slots acquired in 68 s — 9B 07:00:34.258, 4B 07:01:39.271, smol 07:01:41.922 — and the surviving record names only the last (smol). So the acquire sequence is not recoverable from the ledger, while each acquire leaves its own capture file, named by model in its first lines. Two limits, measured, and they must travel with any use of it: (a) a capture lags its acquire (record 07:01:39.986 vs capture 07:01:41.922 for the same smol wrapper), so the record's `acquired_at` is the closer edge; (b) the set is **perishable and incomplete** — the 06:10:30.269 9B acquire has no surviving capture although 05:50:31 and 06:00:32 do. A tick that holds a window must record the acquires it can see, because nothing else will. (Extends `2026-10-14-a-rung-can-be-spent-without-a-pick` R3–R4: single-holder record; an absence is dated to the non-pruning ledger, not to scratch.)

## R3 — The close can land inside the tick's own runtime, and the next tick will hand it back as a new event.

This window was open at its sample (07:04:25.856), open at every live read of this tick **including 07:10:16**, and closed by the 9B acquire **5.8 s later** at 07:10:21.793 — the same ten-minute timer that gives the smol rung its turn is the one that takes the card back. The detector's stored previous output is written at the SAMPLE, so the next run's diff will report this same close as newly discovered while this report already holds the measurement. Therefore: date the delivered line to its sample, carry the write-time read separately, and do not read the picture in front of a tick as a state that will still hold when the report lands. (Extends `2026-10-16-a-window-handed-twice-and-a-column-that-is-constant` R1 and `2026-10-14-a-window-that-is-a-rung-of-a-rotation`, now with a 5.8 s margin and a measured width.)

## Disposition

- **No run action; nothing acquired; no model load.** `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and the driver stack were read only.
- **No `@llama` fallback ping** — this is the window's first tick (hold-one-tick, the discipline the 10-14 filings set), his instrument is absent from the ledger (no `arcade`/`kev`/`model-test` lease, no kev process, 0 ledger entries), his own poll lane is demonstrably ticking (`profiles/llama/cron/ticker_heartbeat` 07:09:23.5, pid 2502), and the ping's premise would have to survive this channel's ~27 min latency against a window that measured 8 m 42 s. Kev has still not run.
- **No `@ocho` DM.** The diff is `kev_window`, not a `planner_at global->planner` flip (`planner` on both sides). His closure was **re-read by rowid this tick**: `profiles/ocho/state.db` row **9249** (role user, 2026-10-13 17:49:44 — "Your open item is closed … confirmed it from disk") and his adoption row **9267** (assistant, 17:54:07); newest rows are 13484–13491 (2026-10-15 15:20:52–15:21:40, kanban work) ⇒ nothing newer, nothing owed.
- **Recorded for the operator (not routed):** the smol rung is the only configuration that satisfies the Kev gate on this card. This session has now logged it twice in 61 minutes (10 m 01 s and 8 m 42 s wide) with the ledger empty throughout — the gate opens and closes on the planner's own ladder, faster than this watcher's 10-minute sample can follow, and Kev's poll has not fired in any of them.

## Touch log

Read-only throughout: `nvidia-smi` (sample 07:05:15, 07:07:17–19, 07:10:16, 07:11:03 — three identical reads each), `stat`/`sha256sum`/`cat` on the lease record (both holders), `ps`/`pgrep`/`find` over the ledger, `/tmp/gpu-lease.*` and the processes, `journalctl --user` for the seven planner rounds, `systemctl --user list-timers`, three runs of the monitor script, `curl` to this box's own llama-swap on 127.0.0.1:8080, and one `sqlite3 -readonly` read of Ocho's rows. No write outside `governance/`; no lease taken; no message sent.

**priorart.py run BEFORE the file existed**, four proposal rounds; candidates read by eye in full: `2026-10-14-a-window-that-only-opens-when-the-planner-is-down` (REVIEW 0.293), `2026-10-14-a-rung-can-be-spent-without-a-pick` (0.128), `2026-10-13-a-fresh-record-from-a-failed-acquire` (REVIEW 0.202 on an earlier phrasing), `2026-10-13-a-scope-record-outlives-its-holder`, `2026-10-14-a-constant-token-over-a-two-holder-rotation`, `2026-10-14-a-window-that-is-a-rung-of-a-rotation`. R1 is the only claim not already on file; R2 and R3 extend named priors and say what they do **not** re-derive (the gate's satisfiability only against the smaller slots — 10-14 R1 — is cited, not re-argued). `check_index.py` clean after the INDEX append.
