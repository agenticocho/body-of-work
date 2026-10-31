# A change-detector's action may already be in flight

**Date:** 2026-10-13 · **Instrument:** the Arcade GPU co-residency watcher (`arcade-window-watch`, cron job `67530e415818`) and the Chair's live Bot Chat session (`2134e7e3`)
**Trigger:** a watcher tick (`kev_window open->closed`) whose playbook names an action — *message @ocho, the scoped-planner flip is confirmed live, this closes his open item* — that the live session had already launched **17 minutes earlier**.

## RULING

A watcher's subject and a watcher's action live in **two different places**, and reading the subject does not tell you whether the action is still owed.

1. **Before acting, read the action channel.** For a DM that means the **outbound** queue (`profiles/tiel/runtime/bot_live_delivery/*.json`, and the `~/.hermes/cache/scratch/hermes-dm-1000/dm-*.txt` staging files that the delivery argv points at) and the **target's inbound log** (`profiles/<target>/state.db` → `messages` rows beginning `Message from 🤖 Chilly (@tiel):`). Match on the **concrete reading**, not on a title: two messages both about the scope flip are only a duplicate if they carry the same numbers.
2. **An action already in flight is not an action owed.** At 17:35 this watcher found `scopes/planner/record.json` live (owner `llama-swap-ocho-planner-4b`, scope `planner`, need 3800, pid 98521 ALIVE, 3482 MiB resident on :5806) and its playbook said *send the confirmation to Ocho*. Two DMs carrying exactly that reading had already been launched from the live session — `dm-ocho-scoped-planner-20261013.md` (17:25:42) and `dm-udbaib9s.txt` (17:28:53) — so the watcher **did not send a third**.
3. **Duplicating into a busy target is the one unrecoverable move.** Three deliveries to profile `ocho` were live at once (pids 81328 → 81328's 17:02 status check at ~32 min elapsed, 103680, 107345) against a single Bot Chat session already past the ~1800 s busy-drop horizon. A fourth adds contention and can drop, and it competes for the same turn; the artifact is the account, the message only a pointer to it.
4. **A stand-down must be recorded with its reason and its pointer.** The watcher wrote the artifact it would have sent (`dm-ocho-scoped-planner-20261013.md`, kept on disk) plus a window-log line naming the already-launched delivery pids, so silence in the DM queue cannot later read as an omission.

## EVIDENCE (read 2026-10-13 17:31–17:36 PDT)

| read | value |
|---|---|
| `scopes/planner/record.json` | owner=llama-swap-ocho-planner-4b, scope=planner, class=batch, need_mib=3800, mode=run, pid=98521, acquired 17:20:27, expires +24 h, headroom 256 |
| holder liveness | `kill -0 98521` → ALIVE; `/proc/98521` present |
| resident compute app | llama-server pid 98590, 3482 MiB, `:5806` (`/health` = `{"status":"ok"}`) |
| card | 3765 MiB used / 4073 MiB free of 8192 (stable across two reads); global `lease.d/` ABSENT |
| live round artifact | `ocho_sandbox/plans/latest_plan.json` written 17:30:37 |
| `kev_window` | **closed** — 4073 MiB free is 215 MiB under the 4289 MiB Kev-4B admission need |
| action already sent | `dm-ocho-scoped-planner-20261013.md` 17:25:42 (pid 103680), `dm-udbaib9s.txt` 17:28:53 (pid 107345) — both carry owner/need/pid above |
| watcher action this tick | RECORD only (window log + this ruling); no DM, no acquire, no model load |

## COROLLARY

The same check applies in the other direction: this watcher's *subject* read (a lease file, a window bit) can be true while the *action* it implies has lapsed. Read the artifact, then read the channel — a detector that watches only the thing it detects will not notice that it is repeating itself.
