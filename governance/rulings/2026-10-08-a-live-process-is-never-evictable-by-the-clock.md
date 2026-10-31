# 2026-10-08 — a live process is never evictable by the clock

**Authority:** Chilly (Local Chair), deciding under explicit delegation from Mike ("You're the expert.
You decide what's best"). **Scope:** the VRAM lease's reclaim predicate (`gpu-lease.sh`), and by
extension any lease on this machine.

## The decision

**A live `mode=run` holder must never be reclaimable by expiry.**

The predicate as built was effectively `expired OR (mode=run AND holder-pid-dead)`. **That OR is the
defect.** It lets the clock take the card away from a server that is alive and serving — which is the
exact collision the renovation exists to prevent. Two allocators on one card is the original OOM,
reached by policy rather than by accident.

The rule is now:

| holder | reclaimable? |
|---|---|
| `mode=run`, pid **alive** | **never**, at any age, whatever `expires_at` says |
| `mode=run`, pid **dead** | yes — the card was released |
| lease-mode (no process to check) | TTL governs, as before |
| recordless / unreadable | after the existing grace, as before |

## The reasoning

**TTL is the primary tenure signal only when there is no process to inspect.** When a process *is*
inspectable, its liveness is the truth and the clock is a backstop against a broken record — never a
licence to evict something still running.

The practical consequence, and the reason this was worth deciding rather than defaulting: **a resident
llama.cpp server is held for hours or days, and llama-swap's models do not expire at all by default.**
A finite TTL on such a holder could only ever do one of two things — expire harmlessly, or evict a live
server. The first is pointless and the second is the failure. So a generous TTL is **correct as a
backstop**, not a band-aid, and this ruling supersedes my earlier characterisation of it as one.

## What this does not decide

- **Class still confers no priority** (expiry-only policy, unchanged). A live batch run is not evicted
  for an interactive load.
- **A live-but-hung holder is still protected**, and deliberately. Reclaiming from a wedged process
  would double-allocate; the honest instrument for that case is a drain request or an operator, not a
  timer. This is a known bounded risk, stated rather than papered over.
- **A third, unwrapped client remains invisible to the lease.** Nothing here covers it.
