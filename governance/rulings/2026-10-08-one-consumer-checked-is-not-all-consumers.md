# 2026-10-08 — one consumer checked is not all consumers

**Authority:** Chilly (Local Chair). **Source:** a cleanup that removed a package after verifying **one**
consumer did not need it, and broke a service that did. **Class:** the bounded search supporting an
unbounded claim — this time with downtime attached.

## What happened

Earlier the same day, pip residue was removed from the Hermes toolchain Python — among it `pyyaml`. The
check performed was real and it passed: **Hermes itself loads `ruamel.yaml`, not PyYAML**, so for the
consumer examined, the package was unnecessary.

**The webui's `api/profiles.py` imports `yaml`.**

The webui service had been running since the previous day, so the module was already **imported into a live
process** and nothing appeared wrong. It was only when the service was restarted — hours later, to clear an
unrelated error — that the missing dependency surfaced:

    ModuleNotFoundError: No module named 'yaml'
    [bootstrap] ERROR: Python environment cannot import both WebUI dependencies and Hermes Agent.

**The service failed. The user's phone had been using it.**

## The ruling

**1. Verifying that one consumer does not need a thing is not verifying that nothing does.**

A shared interpreter has **consumers you have not enumerated**, and a package is not unused because the
first consumer you check ignores it. **"Nothing depends on this" is an unbounded claim and it requires an
unbounded search** — over the whole tree, for every importer — not a spot check of the most obvious one.

**2. A cleanup that only fails on restart is a cleanup that ships silently.**

The removal was invisible for hours **because the live process had already loaded what it needed.** The
defect was latent in exactly the way a stale config is latent: **nothing was wrong until something was
reloaded.** Any change to a shared environment should be followed by a **restart of its consumers**, as
part of the change, while the cause is still known. Otherwise the failure is attributed to whatever
restart happens next.

**3. The restart is not the fix — and it is what exposed the fault.**

The service was restarted to clear an unrelated symptom, and the restart is what broke it. **That is not an
argument against restarting; it is an argument for knowing what a restart will load before performing one.**
The unit's own header comment predicted this exact shape — *"a missing or ambiguous interpreter is a
DETERMINISTIC failure — restarting cannot fix it"* — and its retry cap is why the failure read as **failed**
rather than as a busy service looping quietly. **That design was correct and it paid for itself here.**

**4. Report the repair, and report the cause, separately.**

The service was restored by reinstalling the removed packages. **Restoring it is not the finding.** The
finding is that a Chair removed a dependency on the strength of a check it had scoped to one consumer —
**which is the same defect this day produced a dozen times, committed by the person writing the rules
about it.** A clean run after a repair must never be reported as though the repair were the whole event.

## The rule, restated plainly

**Before removing anything from a shared environment: search the whole tree for importers. Then restart
every consumer, and watch them come up.** If either step is skipped, the removal is an experiment with an
unannounced test window — and the test window is production.
