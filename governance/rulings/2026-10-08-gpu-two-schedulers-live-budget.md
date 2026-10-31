# RULING — 2026-10-08 — the GPU has one card and two schedulers; admission must price against live free memory

**Artifact delivered:** `/home/chilly1/.hermes/workspace/GPU_SCHEDULER_DESIGN.md` (287 lines).
**Class:** venue-plumbing measurement/design. Makes no claim about model capability.

## The finding

On Chilly one 8 GB card is shared by two independent llama.cpp schedulers that cannot see
each other: the **Hermes managed runtime** (`hermes-local-runtime.service` → `hermes serve`
→ a `llama-server` router on 127.0.0.1:18434, per-model policy generated into
`presets.ini`) and **`llama-swap.service`** (127.0.0.1:8080, `chilly_containment` config,
per-model `ttl`/`swap` groups). Hermes prices its launch policy from a **capacity** budget
(total minus reserve) on the stated assumption that the managed server *owns* the card and
unloads itself (`hardware.py:404-411`). llama-swap breaks that assumption whenever it holds
a model.

Measured failure 2026-10-08: with 6161 MiB held (1677 MiB free), a Hermes launch aborted —
`common_fit_params: … model_params::tensor_buft_overrides already set by user, abort`, then
`cudaMalloc failed: out of memory`. The same model loaded fine by hand when allowed to size
itself.

## The mechanism, read to source

1. `--override-tensor` sets `params.tensor_buft_overrides` (`llama.cpp/common/arg.cpp:2752`),
   and `common_fit_params` **throws** the instant a user override is present
   (`llama.cpp/common/fit.cpp:483-484`). So `-ot` disables llama.cpp's own auto-fit.
2. Hermes emits `-ot` **iff the launch plan spilled** (`context_policy.py:309-310`; MoE
   pattern `context_policy.py:285-286`).
3. The plan spilled because it was priced against **capacity**: `_generate_presets` uses
   `probe_budget(planning=True)` (`bootstrap.py:251-252`).
4. The live re-fit that should have narrowed it is a **no-op for exactly the spilled plans**:
   `fit_to_free_memory` returns the plan unchanged when `decision.spilled`
   (`context_policy.py:195`). The only plans carrying the fatal flag are the only plans the
   live fit refuses to touch. **That early-return is the defect.**

## Rulings

- **R1 — admission prices against live free memory, never capacity, when another tenant is
  resident.** A launch plan that assumes it owns the card is invalid and must be re-priced or
  refused, never dispatched.
- **R2 — a plan must not contain the flag that defeats its own fallback.** Emitting
  `override-tensor` from a capacity-sized plan disables the `--fit` that would absorb the
  surprise. A plan that disarms its own safety net is worse than no plan.
- **R3 — the smallest correct fix is a launch-path branch, and it is an UPSTREAM patch.**
  Drop the `spilled` early-return in `fit_to_free_memory` so a capacity-spilled plan is
  re-derived against live free memory, and refuse when the floor cannot be placed.
  `hermes_cli/local_runtime/context_policy.py` **is a git checkout clobbered by
  `hermes update`** — propose it upstream; never record it as a local fix. The
  non-clobbered stopgap is a guard outside the checkout that refuses below a measured
  floor and **drains** (not stops) llama-swap via `POST /unload` before the load.
- **R4 — no pure-config fix exists.** `config_defaults.py:2707-2720` deliberately exposes no
  context/VRAM knobs ("No context/VRAM knobs by design"); the margin is hardcoded in
  `hardware.py` (`_MARGIN_FLOOR = 2 GiB`). Any claim of a config-only fix is false.
- **R5 — the binding constraint on this box is RAM+CPU offload, not VRAM** (60 GiB RAM, 52,930
  MiB available; 8 GB card). A static per-tenant VRAM partition (Candidate D) is therefore
  rejected as the primary design: it steals capability the machine has. "VRAM-infeasible" is
  a known past error here.
- **R6 — do not stop/disable llama-swap as the answer.** It serves a live workload. The
  existing `arena-run-state.sh --arm` stops the unit; the GPU guard must **drain** it and let
  it keep serving.
- **R7 — two residents are outside BOTH schedulers** and must be *reserved for, not assumed
  away*: `hermes-vision.service` (134 MiB, measured — add to accounting) and the
  desktop-scoped llama-server (Chromium app scope — not stoppable from this shell; reserve
  the measured headroom, cf. `_MARGIN_FLOOR`).

## Recommended architecture (recorded, not applied)

Candidate A (**Live-Budget Honour Code**) immediately as stopgap; Candidate B (**VRAM Lease
Broker**, a single `gpu-broker` unit both stacks acquire leases from, priced against live free
memory, with an explicit yield policy) as the target. Candidate C (**One Stack, Two Doors**)
deferred to the end-state; Candidate D rejected per R5. The broker must carry the
yield/priority policy in the lease format from day one, or it is only a mutex.

## Could not verify (carried into the design's §5, not asserted)

The 2026-10-08 numbers were the task's recorded measurement, not re-observed; the failing
Hermes model id was inferred from `presets.ini`; llama-swap's `/unload` verb/semantics were
not called (only `GET /unload` → 200 observed), so no drain design may rely on it unverified;
whether `ttl: 300` is global; the desktop llama-server's present footprint; which model the
18434 router held; and whether the two stacks execute the same llama.cpp build (both
`llama-server` files are ~17.8 KB — likely shims, not inspected).
