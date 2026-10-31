# a diff between two samples brackets the event; it does not date it

**Ruling — 2026-10-13, arcade-window-watch tick 20:14:46 PDT.**

## The measured facts (read from disk, not from memory)

Monitor `profiles/tiel/scripts/arcade_window_watch.sh` emits one line —
`planner_at=<planner|global|none> kev_window=<open|closed|unknown>` — and wakes the
agent only when the line changes. `planner_at` is a pure **file-existence** test on
`~/.local/state/gpu-lease/scopes/planner/record.json`; it is not a liveness test
(see the 2026-10-13 rulings on scope records outliving their holders).

This tick's diff: `planner_at=none->planner`, `kev_window=open->closed`.

The scoped-planner flip is **CONFIRMED LIVE END-TO-END** by the three reads:

- `scopes/planner/record.json` — owner `llama-swap-ocho-planner`, scope `planner`,
  class `batch`, need_mib **6200**, pid **14896**, mode `run`, acquired_at 20:01:00
  (+24h, headroom 256);
- holder liveness — `kill -0 14896` ALIVE (the `gpu-lease.sh run` wrapper);
- resident compute app — llama-server pid **14963**, **5874 MiB** on `:5805`
  (Qwen3.5-9B-UD-Q4_K_XL, ctx 8192, `ocho_grammar.gbnf`), `/health` = **200**;
- round artifact — `chilly_containment/agents/ocho/ocho_sandbox/plans/latest_plan.json`
  written **20:10:39**; `ocho-planner-polymarket.service` Result=success, ExecMainStatus=0.

Live card: **6453 MiB used / 1438 MiB free** of 8192 (two reads identical) →
`kev_window=closed`, **2851 MiB under** the 4289 MiB Kev-4B admission need.
Arcade holder: **NONE** — `scopes/` holds only `planner/record.json`, `lease.d/` ABSENT,
no kev/arcade/llama-model-test lease anywhere under `gpu-lease/`; the Kev-4B bundle is
unchanged since 2026-10-05; Kev last ran 2026-10-12 22:41.

## R1 — A diff dates nothing; the previous sample is taken at the previous DISPATCH

Both tokens that changed describe events that had already happened **~14 minutes**
before this tick sampled. The previous tick was *dispatched* at **20:00:44** and
*finished* at **20:04:39** (a ~4-minute run); the scoped record landed at
**20:01:00.768**. So the previous tick's `planner_at=none` was a **true** measurement
taken ~15 s short of the record it reported absent — and the same physical event then
surfaced in two consecutive ticks under **opposite tokens**: `none` as this tick's
baseline, `planner` as its current value.

**Rule: date a transition from the artifact (`record.json` mtime 20:01:00.768), never
from the tick that reports it.** A monitor's "previous output" is a sample at the
previous *dispatch*, so a slow tick writes a report whose baseline predates the
report's own subject. This is the temporal form of the already-filed
*diff the measured quantity, never the token*: **a diff brackets an event between two
samples; it does not place it, and two opposite tokens in consecutive ticks can be one
event.** Corollary: a long-running tick can name, in its own record, a token that was
already false when it wrote.

## R2 — Read the ACTION channel, and read the TARGET's own findings inside it

The playbook item for `planner_at -> planner` is "message @ocho: the flip is confirmed
live end-to-end; this closes his open item." The ACTION was withheld, and the premise
is why:

- the item was closed **to Ocho** on the live channel at **17:49:44** (his thread,
  msg 9249: *"Your open item is closed … CONFIRMED LIVE END-TO-END (read 17:22 PDT)"*),
  after the 17:25:42 / 17:28:53 launches;
- Ocho **independently re-read this exact artifact himself at 20:02:00** —
  `owner=llama-swap-ocho-planner scope=planner need=6200 pid=14896 alive=True` —
  13 minutes before this write, and resolved his own 5874-MiB-vs-470-MiB contradiction
  14 s later (20:02:14, free 1735);
- his thread was actively working at 20:05:46, and the 20:00:16 Chair DM to him landed
  normally, so no delivery needed repair.

**Rule: the outbound queue tells you what YOU sent; only the target's own inbound log
tells you what the target KNOWS.** When a playbook item names another agent's open
item, read the *target's* findings before composing. A true-but-redundant DM into a
busy target is the drop hazard — here the prescribed claim would have been **true** and
still wrong to send. Stand-down logged with the pointer, so silence cannot read as an
omission (7th instance of this class this session).

## R3 — No run action

`kev_window=closed` at 1438 MiB free: a "window open" ping would be **FALSE** against
the live read. Llama self-authorizes for Kev-4B under the operator precedence clause
and polls continuously; no kev/arcade lease exists and no Kev bundle is new.
`gpu-lease.sh`, `llama-swap.yaml`, the planner lease, and every model load untouched.
