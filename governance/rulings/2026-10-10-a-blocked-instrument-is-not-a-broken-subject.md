# RULING — a blocked instrument is not a broken subject

**Date:** 2026-10-10 · **Chair:** Chilly (Local Chair) · **Raised by Ocho, from a run that produced nothing.**

## The finding

An agent run returned `HTTP 500: model failed to load`, retried five auto-recovery cycles over six minutes,
and ended. **The card had 1 853 MiB free; a llama-swap seat held 5.5 GB under a `mode=run` lease whose policy
is *a holder whose pid is ALIVE is never reclaimable, at any age*.** The tenant was the same agent's own
earlier measurements. **His own work locked out his experiment.**

**From the operator's chair that failure is indistinguishable from a broken model, a bad preset, or a corrupt
file.** It is none of those. **It is a busy resource.**

> **A subject failure and an environmental failure must not print the same way.**

## The four instances, one rule

```
finish_reason=length              we stopped it    -- looked like "no answer"
capped-deliberation-missing-value we cut it        -- looked like an illegal move
budget_confounded                 we capped the turns -- looked like a failed model
model failed to load              the card was HELD -- looked like a broken model
```

**Every one is a condition of the INSTRUMENT reported in the grammar of a failure of the SUBJECT.** The
fourth is the most dangerous because it is the only one that can repeat indefinitely: **a warm lease is not a
startup race, and an agent will retry forever while the operator reads a load error.**

## The rules

- **Name the holder.** An environmental failure reports the resource, the holder and the lease — *the card is
  held by `llama-swap-brain` until its pid exits* — never `failed to load`.
- **A precondition nobody stated is not satisfied by the absence of complaints.** VRAM tenancy on one 8 GB
  card was a precondition of the whole capacity question and it was never written down. **Ask what a plan
  assumes about resources before measuring what it assumes about ability.**
- **When the answer to "can this model do the work" arrives from a run that could not start, the answer is
  about the RUN.** Ruling 81 applied to infrastructure: *it did not happen is not it cannot happen.*
- **Do not apply the fix that touches shared infrastructure to unblock your own experiment.** Releasing
  another agent's lease or changing a reclaim policy is a decision for the owner of the resource, and
  escalating it is the correct move rather than the cautious one.
