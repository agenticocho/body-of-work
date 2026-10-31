# A lease-mode claim is liveness-blind by construction

**Filed:** 2026-10-25 (arcade-window-watch tick, `kev_window` closed -> open at 14:09:52)
**Scope:** `gpu-lease.sh` reclaim/acquire semantics; what `planner_at` and `kev_window` can and cannot report.
**Status:** derived by reading the script and the live state. Nothing was acquired, released, loaded or edited.

## What was on disk

`~/.local/state/gpu-lease/lease.d/record.json` (488 B, mtime 13:21:58.549):

```
owner=ocho2-suite-t_234b2387  scope=""  class=batch  need_mib=5400
pid=2354746  mode=acquire  acquired_at=1792959718 (13:21:58)  expires_at=1792974118 (17:21:58)  ttl=14400
```

`/proc/2354746` absent, `ps -p` returns a header and no row => the recorded pid is **dead**.
`scopes/` holds **0 entries**, and `scopes/` mtime is **13:21:58.536** — the same second as the global record,
i.e. the global acquire's step-2 sweep (gpu-lease.sh:460-480) reclaimed the planner's old scoped cell as it took the card.

Live card, three+ byte-identical reads 14:09:5x-14:12:00: 8192 total / **1785 used / 6106 free** / 0-1 % util / 41-42 C.
`--query-compute-apps`: 976745 Bonsai 1466 MiB + 979586 LFM2.5-VL 134 MiB = 1600 (+ ~185 driver);
`:8080/running` = `{"running":[]}`; only listeners are :8080 (llama-swap) and :58595 (Bonsai). The card is idle
apart from an unleased aux pair, and `6106 >= 4289` (4033 peak + 256 headroom) so `kev_window=open` by 1817 MiB.

## The mechanism

**R1 — a `mode=acquire` record's pid is the acquirer, and the acquirer exits at grant.**
`ld_write` writes `"pid":$$` (gpu-lease.sh:317), i.e. the `gpu-lease.sh` process itself. In `mode=run` that process
stays alive as the wrapper and the pid really does name the holder. In `mode=acquire` the process writes the record
and exits, so its pid is dead within the same second **by construction**. Consequence: the liveness-first clause
(ld_state, :277-282) can never apply to a lease-mode record — `$LD_MODE != run` routes straight to
`now >= expires_at`, so reclamation is **TTL-only**. A dead acquire claim is not a crashed claim; it is what an
acquire claim always looks like. Reading `pid` + `kill -0` on such a record and concluding "the holder died" is
the existence/liveness confusion already filed on 2026-10-19, one level up: here the pid is not even the subject.

**R2 — liveness blindness becomes a card-wide wedge for every scope except arcade.**
The exclusion rule is implemented at gpu-lease.sh:446-451: *a live global holder blocks everyone, scoped or not*,
because the global lease is the whole card. The one exception is the operator precedence hook (:439-445,
`PRECEDENCE_SCOPE=arcade`, `PRECEDENCE_ARCADE` defaulting to 1 at :746-747), which lets an `arcade` contender
bypass the global veto and be priced on live free VRAM at step 3 (:487-502). So with this record live until
17:21:58 and the card idle, a `--scope planner` acquire is refused `LEASE-BUSY` (exit 75) for ~3 h 10 m while an
`--scope arcade` acquire would be **admitted** at 4289 against 6106 free. The idle card has exactly one open seat,
and it is the arcade's. (Whether that refusal is what aborted the 14:00:09 and 14:10:06 planner rounds is *not*
established here: llama-swap logs only `group: starting ocho-planner failed: upstream command exited prematurely`
and does not capture the wrapper's stderr, so the named condition is unread.)

**R3 — the watcher's two tokens cannot see any of this.**
`planner_at` keys on file presence (`scopes/planner/record.json` -> `global` cell), and `kev_window` on free VRAM.
Neither prices the claim's **mode, TTL and pid liveness**, so a card that reads `kev_window=open` can still be
un-acquirable for every scope but one, and `planner_at=global` cannot distinguish "the planner owns the whole card"
from "a dead suite claim owns the whole card until its TTL". This is the same missing-field class as
2026-10-15-a-delivery-outage-is-a-hole-in-the-log R3 (owner/pid/need/liveness still not printed beside the token).

## What this tick does not say

- It does not say the window was consumed, or that Kev should be paged: the window is genuinely open, Llama is
  self-authorised under the precedence clause, and this watcher records rather than triggers.
- It does not date the open edge to a second. The previous sample (13:59:44) read closed at 7390 used / 501 free
  with the arena's MiMo 9B (pid 2385769, 5600 MiB) resident; that pid is gone now (last log write 14:00:06) and the
  following arena Bonsai round cleaned up ~14:05:51. No GPU sample exists between 13:59:44 and 14:09:52, so the
  crossing is bracketed, not timed.
