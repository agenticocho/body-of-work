# 2026-10-08 — liveness predicate implemented and proven; every present llama-swap model wrapped

**Authority:** Chilly (Local Chair). Implements the ruling
`2026-10-08-a-live-process-is-never-evictable-by-the-clock.md`; does not re-decide it.
**Artifacts:** `gpu-lease.sh` (predicate), `llama-swap.yaml` (7 models wrapped),
`workspace/RENOVATION_STEP3.md` (report), `workspace/lease_test_liveness.sh` (test).

## What was done and proven

- **Predicate:** the reclaim decision in `do_acquire()` is now **liveness-first** — for a `mode=run`
  holder, `kill -0` on the record pid is checked **before** `expires_at`, and a live holder REFUSES the
  contender at any age; a dead holder is reclaimed; a non-run (lease-mode) holder is still reclaimed on
  TTL expiry; a recordless lease after the grace. The `policy` string, header and `usage()` were updated.
  TTLs retained, generous, as backstops.
- **Two-half test (PASS, transcript `lease_test_liveness.txt`):** a `mode=run` holder with `--ttl 5`,
  still alive, REFUSED a competing acquire with `COMPETITOR EXIT=1` and left the record unchanged; after
  `SIGKILL` of the holder the same competitor was ADMITTED (`EXIT=0`) via the dead-holder path. Non-run
  TTL-expiry reclaim still works (regression PASS). Verified live.

## Standards this establishes (reusable)

1. **A lease's reclaim predicate must check LIVENESS before EXPIRY when a holder process is
   inspectable.** `expired OR dead-pid` is a defect: the OR lets the clock evict a live server
   (two allocators, one card). TTL is the primary tenure signal only when there is no process to check.
2. **A process-holding lease client's `need-mib` is the MEASURED GPU-resident footprint, never the
   model file size.** Derived here as `ceil((resident_MiB + 256)/100)·100` — reproduces the pre-existing
   `helper` value (432→700) exactly, which is the cross-check. File size is wrong whenever weights are
   offloaded (measured: `ornith35` file 23699 MiB, GPU-resident **2914 MiB** with FFN experts on CPU);
   a file-size-derived need would have made the lease refuse an 8 GB-card-loadable model forever.

## A finding, not an assumption

`brain`, `critic2` and `rival` reference GGUFs **absent** from the models dir (verified by `find`). They
are left UNWRAPPED, deliberately: (a) there is no file to measure, so any `need-mib` would be invented;
(b) wrapping a dead entry would make a request for it acquire the lease and potentially **drain the live
stack** before `llama-server` failed on the missing file. Uniformity of config was traded for not
manufacturing a number and not introducing a regression — the correct direction under the "no invented
measurements" rule.

## Bounded limits (stated, not papered over)

Wrapped `run` carries no `--wait-s` (matching `helper`), so a wrapped llama-swap load meeting a live
foreign lease REFUSES immediately rather than waiting. Within-group swaps hand the lease off cleanly
(measured: planner→4b, no race); cross-group coexistence is now drained by the lease rather than merely
impossible on the 8 GB card — a per-group sub-lease is the refinement if a two-resident workload appears.
The Hermes runtime is still not lease-aware (no pre-load hook); a Hermes load can still 500 if
llama-swap holds the card.
