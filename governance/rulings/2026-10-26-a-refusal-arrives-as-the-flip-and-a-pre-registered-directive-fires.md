# A refusal arrives as the flip, and a pre-registered directive fires

**Tick:** `67530e415818` (arcade-window-watch), change detected at the 11:15 sample.
`cron/output/67530e415818/monitor_last_output.txt` 34 B, mtime `2026-10-26 11:15:08.836763186`,
content `planner_at=planner kev_window=open`; previous agent sample
`cron/output/67530e415818/2026-10-26_11-04-20.md` (mtime `11:04:20.976233088`, 6,201 B)
⇒ the `planner_at` edge lies in **(11:04:20.976, 11:15:08.836)**.

**Diff:** `planner_at none -> planner`, `kev_window=open` **on both sides** (no window edge).

## What the edge actually is

The scoped cell appeared at **11:10:14**, born with a dead holder, and was rewritten in place by a
second dead holder before this tick finished. Both are the 9B rung — the owner string carries no
`-4b`, and the 3-byte-shorter owner is why the cell is 492 B where the 4B's is 495 B.

| cell | bytes | mtime | sha256 | pid | acquired_at |
|---|---|---|---|---|---|
| A | 492 | `11:10:14.421674635` | `1b42f1211a6197a1ff9b00641a49496802edcd9632093e2529784b1ce8254f78` | 3056160 | 1793038214 = 11:10:14 |
| B | 492 | `11:20:23.195074460` (ino `9977345`) | `0e12739a0e8c81687c5b0738e71c8417c9c4258d3230b1b43c337bf4cedb8506` | 3063098 | 1793038823 = 11:20:23 |

Both cells: `owner=llama-swap-ocho-planner · scope planner · class batch · need_mib 6200 · mode run ·
ttl 86400 · headroom_mib 256`, `expires_at` a day out (1793124614 / 1793125223).

**The writer's own record says they are refusals, not loads.** `journalctl --user -u
ocho-planner-polymarket.service`:

- `Starting` **11:10:07** → `Main process exited, code=exited, status=1/FAILURE` **11:10:14**
  (3.371 s CPU / 7.323 s wall / 142.1 M peak) — cell A's birth second is the unit's exit second.
- `Starting` **11:20:11** → `status=1/FAILURE` **11:20:23**
  (3.372 s CPU / 12.120 s wall / 142.1 M peak) — cell B's birth second is that exit second.

**The four-artifact test from `2026-10-25-the-scoped-cell-is-written-by-a-refusal-and-a-release-deletes-its-own-bid`
R2, applied and failed on all four legs, twice:**

1. `pid` alive in `/proc` — **no**: `ps -o pid,etime,cmd -p 3056160` and `-p 3063098` return no row at
   11:15 and again at 11:21.
2. a resident child in `nvidia-smi --query-compute-apps` — **no**: the only tenants on the card are the
   two standing ones, `976745 = 1466 MiB` (Bonsai, `--n-gpu-layers 0`) and `979586 = 134 MiB`
   (LFM2.5-VL), plus the desktop's `3025101 = 8 MiB`. Nothing of 3800 or 6200 MiB exists.
3. a `/tmp/gpu-lease.*` capture born after the round's start — **no**: `find /tmp -maxdepth 1 -name
   'gpu-lease.*' -newermt '2026-10-26 11:05' | wc -l` = **0**; the newest capture in the tree is
   `2026-10-26 05:20:06`, i.e. nothing even reached a load attempt.
4. `:8080/running` naming the alias `ready` — **no**: `{"running":[]}`.

⇒ **REFUSAL RECEIPT**, on the four artifacts, not on the token. The refusal is the standing 9B deficit,
measured live: 6200 + 256 headroom = **6456 against 6102 MiB free = 354 MiB short** (the same quantity
filed as 302 short at 06:44 and 345 short at 08:48 — the baseline drifts, the verdict does not).

**Live card, two identical reads (11:15:17 and 11:20:47):** 8192 total / **1789 used / 6102 free**,
util 2 %. `used + free = 7891` vs `8192` = the standing ~301 MiB in neither column. Gate in
`scripts/arcade_window_watch.sh` is `free >= 4289` ⇒ `kev_window=open` by **1813 MiB**.

## R1 — The message-carrying branch and the refusal share one token value

`planner_at` is a bare file-existence test (`arcade_window_watch.sh:31-35`). A wrapper writes its cell at
acquire, **before** the admission test, so a refusal leaves exactly the file a load leaves. With the 9B
rung drawn at 60 % weight, the token reads `planner` in roughly six of every ten rounds with **nothing
resident**, which is what the last three samples show (05:40, 07:40, 11:10/11:20 all 492 B dead-holder
cells; only the 30 % 4B draws produce a 495 B cell with a live child). A watcher instruction of the form
"`planner_at` global→planner means the flip is CONFIRMED LIVE" is therefore unsatisfiable by the token
in either direction: it fires on refusals and it cannot distinguish the load that follows.

## R2 — Both ends of today's edge are ladder artifacts, not capacity

`none` did not mean "the card is free": it meant the 4B's release had deleted its own bid, taking the
whole `scopes/planner/` directory with it (the dir is born again at `11:10:14.416`, which is why the
cells' inode differs from the 9966346 chain that carried 05:40→08:40). So the transition this tick
reports is *release-deleted cell → refusal-wrote a new one*, two artifacts of a 10-minute ladder, and
neither is a statement about the card. The card's own statement was in `nvidia-smi` both times and it
never moved: 1789/6102 at 11:15 and at 11:20.

## R3 — A pre-registered directive that fires is the only proof a rule was load-bearing

The 10-25 record ended with a **Directive for the next sample**: "the next reading will be
`planner_at=planner`, and its diff will be `none -> planner`, which is **not** the enumerated confirming
branch. Do not report it as a flip confirmation, and do not message `@ocho` on file presence."

Today's diff is that edge, to the token, 16 hours later. The value of having written it is measurable:
the branch list handed to this tick still has four entries and **none of them is `none -> planner`**, and
the nearest entry is the only one that carries a message. Without the 10-25 directive the correct
behaviour here would have been re-derived from scratch under a prompt that asks for the opposite; with
it, this tick had a written branch to follow. A rule is load-bearing exactly when a later tick would
have erred without it — so a ruling should end by naming the *future sample* it will be read against.

## Actions — none, and the two messages that were correctly not sent

- **No @ocho.** His scoped-planner item was closed in his own rows on 2026-10-25
  (`profiles/ocho/state.db`, session `20261005_064932_a3b82b`, his reply "the item is closed"), and
  today's artifact fails all four confirmation legs. A DM here would have carried "confirmed live
  end-to-end" about a card with 6102 MiB free and nothing resident — the exact false confirmation the
  10-25 R2 directive forbids. His group's failure is his service's own journal line, not news a watcher
  owes him at 11:20 for the sixth consecutive 9B round.
- **No @llama.** `kev_window` did not transition this tick (`open` on both sides), free 6102 ≥ 4289, and
  he is self-authorised to acquire at `--scope arcade` on his own poll. `scopes/` holds `planner` only —
  no `llama-model-test` and no `arcade` record or process — and this watcher does not preempt his poll.
- **No acquire, release, load, lease edit, unit or config touched.** `gpu-lease.sh`, `llama-swap.yaml`,
  the planner lease and every model load were read-only this tick.

Prior art printed BEFORE this file existed (`priorart · 487 records in rulings`), two phrasings:
max `REVIEW 0.223 2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` (read in full;
its direction 1 is this mechanism, its remedy is the four-artifact qualification used above), then
`0.094 2026-10-19-an-accepted-argument-nothing-reads-is-a-value-the-record-cannot-honour`,
`0.089 2026-10-25-an-unclassifiable-transition-is-not-its-nearest-branch` (read; the governing rule for
the prompt's four-entry list), `0.087 2026-10-19-a-recycled-pid-makes-a-dead-holder-read-as-never-reclaimable`;
second phrasing max `weak 0.102 2026-10-09-a-check-needs-two-positive-controls-fire-and-read`,
`0.093 2026-10-24-a-silent-release-failure-keeps-the-planner-latch`,
`0.077 2026-10-25-the-scoped-cell-is-written-by-a-refusal-and-a-release-deletes-its-own-bid` (the rule
this tick applies, including its R2 directive — EXTENDED here by the second consecutive refusal and by
the inode change that dates the release). No record on file scores a pre-registration against the sample
that later arrived on it, so R3 is new; R1/R2 are instances and are labelled as such.

Every number above is a disk read from this tick: two `nvidia-smi` reads, `stat`/`sha256sum`,
`ps -p` on both pids, `journalctl --user`, `find /tmp`, `curl :8080/running`, `gpu-lease.sh status`.

RULINGFILE rulings/2026-10-26-a-refusal-arrives-as-the-flip-and-a-pre-registered-directive-fires.md
