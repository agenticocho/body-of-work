# 2026-10-08 — VRAM lease (mutual exclusion) and its default yield policy

**Machine:** Chilly · **Deliverable:** `/home/chilly1/NVIDIA-PAIR/ops-docs/scripts/gpu-lease.sh`
**Report:** `/home/chilly1/.hermes/workspace/RENOVATION_STEP2.md`
**Applies to:** the two llama.cpp stacks on the one RTX 3060 Ti (llama-swap.service :8080; the Hermes
managed router published in `~/.hermes/runtimes/llamacpp/server.json`).

## The ruling

**R1 — Mutual exclusion is a lease, not a drain.** A drain is a request; two contenders that both
drain can both allocate in the gap (Step 1 measured a re-acquire in <10 s after a 200 drain).
Coordination therefore requires a real lock held *across* the drain-to-allocation window. Implemented
as an atomic `mkdir` (the take) plus a `flock` on a transition mutex (so an **expired** lease cannot
be double-reclaimed), with the lease record written temp-then-`rename`.

**R2 — The default yield policy is `expiry-only`; class is NOT priority.** No live lease is
preempted because of its class. The only ways to take the card from a live holder are (a) release,
(b) TTL expiry, (c) a `mode=run` holder's process is dead. Class sets the **default TTL only**
(interactive 180 s, batch 3600 s). Rationale: the binding requirement is that a **live batch run is
not evicted for an idle interactive load** (the Ocho pipeline is live — timers every 10 min), and
class *priority* ("llama-swap yields to Hermes", the design doc's suggestion) would violate that
whenever the batch run is live, while also needing an *activity* signal the lease cannot measure.
The chosen default needs no unmeasurable signal; it refuses rather than evicts, which is the
recoverable direction. Operator overrides, per lease, without code change: `--ttl`, `--wait-s`,
`GPU_LEASE_TTL_INTERACTIVE`, `GPU_LEASE_TTL_BATCH`. A class-*priority* policy is deliberately **not**
the default and is **not implemented**; if wanted it is a new named policy in the record.

**R3 — A crashed holder must never wedge the card.** The lease carries a TTL and expires; the next
acquire reclaims an expired lease with no operator action. Dead-pid reclaim (faster) and a
recordless-directory grace cover the crash-before-record case. **Proven live:** an expired lease was
reclaimed (`EXPIRED 2s ago` → reclaim → admit), and a `SIGKILL`ed `mode=run` holder was reclaimed on
the dead-pid check before its TTL.

**R4 — Price against LIVE free memory, never capacity; carry headroom for the ungoverned.** The
lease admits only when `nvidia-smi` free ≥ need + headroom (default 256 MiB), so already-resident
tenants are paid for and `hermes-vision` (134 MiB, `owner=unowned`) is named in every verdict rather
than assumed away.

**R5 — A lease serialises cooperators only; the Ocho pipeline is not one.** llama-swap re-takes the
card autonomously. The lease cannot stop a non-cooperative re-acquire; `run` copes by draining under
the lease and re-draining on retry (bounded at 3). To close the hole, llama-swap's per-model `cmd`
(user-owned YAML) must be wrapped to call `gpu-lease.sh` — **not done**.

**R6 — The Hermes side is gated by the CALLER, not the router.** The router has no pre-load hook and
`presets.ini` is generated (never hand-edited). `gpu-lease.sh run` acquires → drains → executes, and
handles the known HTTP 500 (`failed to load` / OOM) by re-draining and retrying, reporting each
attempt, **bounded at 3**. Reproduced a genuine 500 and recovered to HTTP 200 on attempt 2.

**R7 — Hard limits preserved.** No unit was stopped/disabled/reconfigured (drain only);
nothing under `~/.hermes/hermes-agent/` was patched. `gpu-admit.sh` / `gpu-yield.sh` were **not**
rebuilt; `gpu-yield.sh` is reused as the lease's eviction arm.

## Contention evidence (measured)

* Two contenders, one holds: A `ADMITTED` (card 282/7556), B `REFUSED` ("held by A", card
  unchanged 282/7556), release A.
* Two contenders fired simultaneously: P1 exit 0, P2 exit 1 — exactly one winner (atomic take).
* `run` vs the live Ocho pipeline: acquire (3745/4093) → drain attempt 1/3 → 282/7556 → real HTTP
  500 on attempt 1 → re-drain → HTTP 200 attempt 2 → `run COMPLETE` exit 0 (card after 5387/2451;
  Hermes model unloaded → 282/7556).

## Final state
Card 6135/1703; llama-swap active holding `ocho-planner` (MainPID 143552 never touched);
hermes-local-runtime active (router 448611, no model loaded); hermes-vision active; no lease held.
