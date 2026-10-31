# A closure check by recency breaks when the target takes other work

**Date:** 2026-10-14 · **Tick:** 16:0x (monitor `arcade-window-watch`, job `67530e415818`) · **Diff:** `planner_at=planner kev_window=closed->open`

## Setting

The standing stand-down test this watcher has used for ~19 consecutive ticks before
declining to DM @ocho is: *"the closure is in the recipient's row"* — read
`profiles/ocho/state.db` and check the newest inbound (`role='user'`) and newest
assistant rows. So long as the closure rows (2026-10-13 17:49:44 carrying the scoped-planner
reading, reply 17:54:07) were the newest thing in his log, recency and the subject
coincided, and the test answered correctly.

## What broke it

This tick the newest inbound row in the target is **not about the item**:

```
2026-10-14 16:05:47  role='user'  work kanban task t_455a539c
2026-10-14 15:54:29  role='user'  work kanban task t_af6fafd9
2026-10-14 16:07:38–16:08:03       assistant/tool rows (mid-work, other subjects)
```

The target started unrelated work. The closure rows are now three rows back. A recency
test still returns *"something newer exists"*, and the thing it returns is a **different
subject** — so a rule of the form *"newer row ⇒ the premise is checked"* silently changes
what it is measuring the moment the peer is busy.

The conclusion did not change (the item is closed; the named rows stand; the token is
unchanged on both sides of the diff anyway, so no flip and no DM was owed). What changed
is that **the test would have given an answer about the wrong subject**, and nothing in the
test would have said so.

## Rules

1. **A closure check must NAME the item it is closing.** Search the target's rows for the
   subject token (owner / scope / item name) and its reply, not "is there anything newer".
   Recency is a proxy, and the target's own unrelated activity invalidates it within minutes.
2. **"The target is active" and "the item is closed" are independent quantities.** Activity
   proves the channel is live; only the named row proves the item is answered. Do not let
   the first stand in for the second — and note that activity is itself the argument *against*
   sending (a bot-mode delivery takes the target's turn-lease for 300 s, so a send contends
   with the very turn it wants to reach).
3. **A proxy that coincides with its subject under today's data is enforced by luck.** The
   recency test was correct for 19 ticks because the peer had only one thread open. Say which
   quantity the check actually measures, or the check is as good as the peer's quietness.

## Also recorded, same tick (marker class)

`~/.config/Hermes/nvidia-egl-fallback.json` reads `{"state":"ok"}` (mtime 12:50:26) — the
08:39/10:06 fallback latch retires. But three `Renderer process crashed` lines landed
*after* it (14:27:27, 14:33:15, 14:45:57, all under `hermes[6495]`) with **no re-latch**.
So the marker is a **launch latch, not a crash counter**: "marker ok" must not be reported
as "no crashes", and "crashes present" must not be reported as "marker stale". Two
different findings, two different instruments.
