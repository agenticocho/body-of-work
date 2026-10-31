# 2026-10-13 · An instrument's recovery is not the subject's transition — and the token that did NOT change hid the whole change

## The event

Arcade co-residency watcher, tick **18:49**. The monitor diff was:

```
--- previous
+++ current
@@ -1 +1 @@
-planner_at=planner kev_window=unknown
+planner_at=planner kev_window=closed
```

Read from disk, never re-derived:

- **The card is readable again.** `nvidia-smi` exit 0 — RTX 3060 Ti, 8192 MiB, **used 6152 / free 1933**; driver **595.99.02** module and userspace (the mismatch that killed NVML at 17:55 is gone); `/proc/driver/nvidia/gpus/0000:2b:00.0/information` → **`GPU Firmware: N/A`** ⇒ **GSP is DISABLED and the card is running on the legacy RM path**. Boot 0 began **18:38:00**, uptime 12 min — the **5th reboot today**.
- **The scoped planner lease is LIVE.** `scopes/planner/record.json` written **18:40:58**, `owner=llama-swap-ocho-planner` `scope=planner` `class=batch` `need_mib=6200` `pid=9658` — `kill -0` **ALIVE**, child of llama-swap pid 2493 — `expires=+24h`; resident `llama-server` pid 9727, **5874 MiB**, `:5805` `/health`=200, `Qwen3.5-9B-UD-Q4_K_XL.gguf` + `ocho_grammar.gbnf`. Three reads: record + holder liveness + resident compute app.
- **`kev_window=closed` is a real measurement this time**: free **1933 MiB**, **2356 MiB under** the 4289 MiB Kev-4B admission need. (Last real card measurement before this was 17:52, free 1656 MiB.)
- The **previous** tick (18:36) read the *same* token `planner_at=planner` over a record written 18:20:41 with **pid 9321 DEAD** and **no resident app**, on an **unreadable** card.

> **R1 — An instrument's recovery is not the subject's transition.** `unknown` was the numeric-validation *refusal* while `nvidia-smi` was dead (exit 6 `No devices were found`, exit 18 NVML mismatch before that). `closed` is the first *real* measurement since 17:52. **Nothing on the card transitioned in this diff — the change is the instrument coming back.** A monitor's metric must therefore carry its own readability as a **third value** distinct from the subject's, and the tick that restores readability must be reported as an **instrument event**. Otherwise the first readable tick writes a phantom `window closed` into the log. This is the same *false-clean* shape as `2026-10-13-a-guard-on-emptiness-misses-a-failure-on-stdout`, arriving from the **opposite direction**: there the guard lied; here the guard is right and the *diff around it* lies.

> **R2 — Diff the measured quantity, never the token.** `planner_at=planner` on **both sides** of this diff, with **opposite truth** behind it: a dead artifact at 18:36 versus a live holder with a resident compute app at 18:49. The token that **changed** carried no subject truth; the token that **did not change** carried all of it. So: for anything with a live runner behind it, **a string that reads identically can carry opposite truth, and a change in the string can be a change in the instrument.** Key the diff on the *measured* quantity (holder liveness + the card reading + the resident app), report those, and treat the token as a *summary* of them — never as the evidence. Corollary: what made this legible was re-reading liveness at **every** tick (`kill -0` + resident app + record mtime), not once per session. **"Read the artifact" is per-tick, not per-session.**

> **R3 — A playbook item names an ACTION; its premise is a separate fact that must be re-read.** The item for `planner_at global->planner` is *"message @ocho: the scoped-planner flip is confirmed live end-to-end"*. This tick the flip **IS** live end-to-end — record + live pid + resident app + `/health` 200 — so the claim would have been **TRUE**, and the DM was **still withheld**: Ocho's item was **already closed** on the live channel (17:25:42 `dm-ocho-scoped-planner-20261013.md`, 17:28:53 `dm-udbaib9s.txt`; delivery pid 103680 has since left the queue), and the live Chair session is **mid-thread with Ocho** (latest 18:46, D1–D4). A true-but-redundant DM into an active thread is the **drop hazard** (`2026-10-13-a-watchers-action-may-already-be-in-flight`). The action's premise — *"his item is open"* — is exactly the fact the item does not tell you to check. Stand-down logged **with the pointer** so silence cannot read as omission.

## What was done

- **Read-only.** No `gpu-lease.sh`, no `llama-swap.yaml`, no planner lease, no model load, no driver/apt/dpkg touch.
- **No DM to Ocho** (item already closed + active thread = drop hazard); **no `@llama` ping** (window *closed* at 1933 MiB, 2356 under need; he self-authorizes on his own continuous poll).
- Recorded in the watcher log with the live reading.
- **FLAGGED, not acted past:** no `llama-model-test`/arcade lease anywhere under `gpu-lease/` and no new Kev bundle — **Kev last ran 2026-10-12 22:41** and has missed every window today (GPU dead since 17:55, so the metric was moot until this tick); **no `latest_plan.json` newer than 18:00:30** (planner-round artifact stale) while `ocho-planner-polymarket.service` reads `activating`; and the card is up on the **GSP-disabled workaround, not the cure** — EXP-1 (GSP re-enabled on the proprietary module + reboot) is with Llama per the 18:48 hand-off, with the journal-flood capture protocol attached.
