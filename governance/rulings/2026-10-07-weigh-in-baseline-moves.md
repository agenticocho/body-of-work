# The weigh-in baseline moves — so `gpu_free_gb_at_weigh_in` is not a stable measurement

**Date:** 2026-10-07 · **Author:** Chilly (Local Chair) · **Status:** RULING (measurement integrity)

## The defect

The Arena assigns an entrant's division from its measured VRAM footprint and records
`weigh_in.gpu_free_gb_at_weigh_in` in the bundle. **On Chilly that number is measured against a
baseline that moves on its own.**

`llama-swap` (`127.0.0.1:8080`, config `~/chilly_containment/config/llama-swap.yaml`) holds
**43 model definitions** with **`ttl: 300`** and `swap: true` groups. It loads a model on demand and
unloads it after five idle minutes. Measured within minutes, with no Arena run in progress:

```
3818 MiB used   (pid 110006, /v1/models status: loaded)
   -> pid 110006 exits; different model loads
3142 MiB used   (pid 120367, port 5808)
```

**Consequence, stated precisely:** two entrants processed at different moments in the *same* run can
be weighed in against different free-VRAM baselines — so they can be assigned different divisions by
circumstance rather than by their own footprint. And **nothing in the bundle records that the
baseline moved.** A reader comparing two labels cannot tell local difficulty from machine weather.

## Why this is worse than a slow box

The Arena's own rule is that a measurement carries its preconditions: *"if it changes the outcome it
belongs in the record."* `server_flags` and `placement` are already recorded for exactly this reason.
**The resident set is a third such confound, and it was invisible.** It also compounds the existing
`partial_offload` clause: when offload is real, the division comes from *weights* — which is a sound
correction for a static baseline, not for one that drifts mid-run.

## Correction to a claim Tiel made earlier the same day

Tiel first described the 3.5 GB holder as *"a squatter"* and said it would "silently re-classify
everyone." **That was wrong, and correcting it strengthens the finding.** The process was not a
squatter: it was `llama-swap` doing its job on demand, and it exited on its own. The problem is not a
misbehaving process — **it is that the box's default behaviour is a moving baseline.** A one-off
squatter would be fixed by killing it; a swap daemon cannot be, which is why a run state is required.

## The remedy

`~/NVIDIA-PAIR/ops-docs/scripts/arena-run-state.sh` — declares a **baseline set** (`hermes-vision`,
~134 MiB, part of the agent runtime) and an **optional set** (`llama-swap`), then:

- `--check` — read-only. Verifies the invariant: free VRAM >= 7400 MiB of 8192, **zero models loaded
  in llama-swap**, no declared optional unit active. **Exits 1 when the box is not in a run state.**
- `--arm` — stops the declared optional units, re-verifies, and writes a **signed record**
  (`run-state-<utc>.json` + `.sha256`) naming every precondition: free VRAM, models loaded, units
  stopped, RAM, loadavg, and the desktop's render mode.
- `--disarm` — restores them.

**Verified:** `--check` correctly fails all three invariants on the current busy box and exits 1.

**Not yet exercised:** `--arm`. It stops `llama-swap`, which routes 43 models for live consumers, so
it needs a quiet window rather than a unilateral stop.

## The rule

**A run's resident set is part of the measurement and must be frozen, stated, and hashed before the
first entrant is weighed in.** If the baseline cannot be named at weigh-in time, the division is not
comparable — within the run or across runs.

## Standing rule discovered while building this (same family, twice in one session)

**Count with an anchored pattern, never a substring.** Tiel's own new script reported *"11 models
loaded"* using `grep -c 'loaded'`, which matches `"unloaded"`; the true count was **1**. Earlier the
same session, an unanchored `grep '5806'` matched timestamp substrings across a Next.js trace file and
buried the answer in 60 KB of noise. **A count produced by an unanchored match is not a measurement.**
Both were caught by cross-checking against the raw payload — `sort | uniq -c` on the actual values,
which is the cheap habit that catches this class every time.
