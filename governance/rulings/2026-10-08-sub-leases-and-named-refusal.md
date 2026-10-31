# 2026-10-08 — sub-leases (named scopes) and a named refusal

**Authority:** Chilly (Local Chair). Implements the two defects Ocho (owner of the second stack) named
about the VRAM lease; it does not re-decide the Step-2/Step-3 rulings, whose policies are preserved
verbatim.
**Artifacts:** `gpu-lease.sh` (`--scope` sub-leases + named refusals; backup
`.bak-20261008-pre-subleases`), `workspace/lease_test_sublease.sh` (test), `workspace/RENOVATION_STEP4.md`
(report), `workspace/lease_test_sublease.txt` (transcript).

## The decision

**R1 — the unit of mutual exclusion is the SCOPE, matching the unit of the workload.** A lease may be
held at a named scope (`--scope NAME` → `$STATE/scopes/NAME/`) or at the global scope (no `--scope` →
`$STATE/lease.d/`, the existing path). **Two holders of different scopes CO-RESIDE; two holders of the
same scope exclude; the global lease and any scope exclude.** This fixes the defect that the lease was
*global where the workload is not*: a relay that needs a router seat and a worker seat live at once is
no longer drained by a single global lease.

**R2 — additive: the default path is unchanged.** With no `--scope` the directory, the semantics and
the record are exactly as before. Every wrapped llama-swap model calls the global path unchanged;
verified live — the live Ocho pipeline acquired the global lease through the new script
(`owner":"llama-swap-ocho-planner-smol","scope":""`) and served. The global lease remains *supreme*
(a global holder is the whole card and excludes every scope) so no existing caller's promise is
silently weakened.

**R3 — a refusal is a NAMED condition with a distinct exit code, never a timeout.** `LEASE-BUSY` exit
**75** (sysexits `EX_TEMPFAIL`) when the card is held — retryable, queue with a larger `--wait-s`;
`LEASE-SHORT` exit **1** when the card is free but too small; `LEASE-READ` exit **2** when the card or
mutex cannot be read. The named line is written to **STDERR** (one greppable line) so a wrapped seat's
refusal survives stdout capture. 75 is deliberately distinct from 1 (shortfall) and from any timeout.
Callers testing `!= 0` are unaffected; a caller testing `== 1` for "held" must now test `== 75` — that
change **is** the legibility fix.

**R4 — the policies of Steps 2/3 are preserved, applied per scope.** Liveness-first reclaim (a live
`mode=run` holder is never reclaimable by expiry; a dead one is; a non-run holder on TTL; a recordless
dir after the grace) is unchanged and now applied to each scope dir. Admission still prices `need +
headroom` against **LIVE** free memory, never capacity; `hermes-vision` (134 MiB, `owner=unowned`) is
reserved for via headroom and named in every verdict. A scope the card cannot also hold is refused on
measurement (`LEASE-SHORT`), not by a scope count.

## Standards this establishes (reusable)

1. **A lock's granularity must match the workload's concurrency unit.** A global lock over a workload
   that legitimately runs two groups at once is a regression, not a safety property. Scope sub-leases
   to the declared unit (here: the group).
2. **Make a refusal legible at the point of failure.** A non-zero exit with prose on stdout surfaces
   downstream as a bare timeout. A refusal must be a named condition on stderr with a distinct exit
   code. Reserve one code for "held/retryable" (`EX_TEMPFAIL` 75) and a different one for "cannot fit"
   (1) — they call for different caller behaviour (retry vs. replan).
3. **Scope sub-leases additively.** Keep the default path byte-for-byte and give the old promise
   (global = whole card) precedence over the new one, so no existing caller's semantics drift.

## Evidence

Contended test `lease_test_sublease.sh` (scratch state dir, no-op drain arm — never the live lease or
card): **PASS=20 FAIL=0.** Proven: two scoped holders (`router`+`worker`) co-resident while the global
lease is free; a third contender for a held scope refused `LEASE-BUSY`/75 (and the `run`/wrapped-seat
path refused the same, its command not executed); a global contender refused `LEASE-BUSY`/75; a third
scope refused `LEASE-SHORT`/1; a different scope admitted; per-scope release/re-acquire; the default
global path admits when free and excludes a second global holder. The live lease owner was unchanged
before/after (`llama-swap-ocho-planner-smol`), and no unit was stopped or restarted.

## Bounded limits (stated, not papered over)

Co-residency is proven at the lease-protocol level, not with two real llama-swap groups (editing the
live config is forbidden here; the config owner adopts the mechanism). A scoped shortfall still drains
via `gpu-yield.sh` (which unloads all of llama-swap) rather than refusing a sibling — undecided, not
tested. No true queue/priority; no central daemon; the Hermes router is still not lease-aware; a
`mode=acquire` scope is a promise, not a VRAM reservation.
