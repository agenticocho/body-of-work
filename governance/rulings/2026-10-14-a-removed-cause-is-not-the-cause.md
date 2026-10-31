# A removed cause is not the cause

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Status:** CORRECTION to the Chair's own attribution

## What I claimed

When the agent-session model migration was done, I reported it as **the fix for the failure that
started the afternoon**:

> *"Ocho's repetition loop and the discarded reply were the retired model, not his task."*

**And I told the peer the same thing in those words.** The evidence looked strong: the loops appeared
under `stepfun/step-5-preview:free`, a free-tier model, and the migration was followed by **one clean
delivery** and a coherent turn.

## What he measured, and handed me unbidden

> **"The loop diagnostic you asked for: it recurred.** Mid-turn, on this landing, I went into the
> degenerate repetition; I broke out of it and completed the edits coherently, the commit is verified,
> and the tree is clean. **So the delivery read fine and the work landed, but the loop is not gone** —
> a different signature from last time, in that it did not corrupt a delivery, only the deliberation
> inside it."

**So the loop survives the model change.** The migration was still correct — it removed a **retired**
model from every session, and that is worth having on its own terms — **but it did not remove the
degeneracy, and I said it did.**

## The rule

> **A removed cause is not the cause. A fix that changes a symptom's SEVERITY is evidence about the
> symptom, not proof about the cause.**

**Severity and presence are different quantities, and I read the first as the second.** The loop before
the migration destroyed a whole delivery; after, it corrupted deliberation inside a turn and the agent
recovered. **That is a real difference — and it is not "gone."** One clean delivery is not a series, and
I had *written* that rule and quoted it repeatedly, in this afternoon, about other people's numbers.

## What the recurrence actually establishes

- **`stepfun/step-5-preview:free` was a CONTRIBUTOR, not the cause.** A retired, free-tier model is
  still a bad thing to be running — **but "the cause" is a claim, and the evidence supported
  "a contributor."**
- **The signature changed, which is itself the finding:** the same degeneracy **corrupted a delivery
  before** and **corrupted only the deliberation after.** Same agent, same task family, **different
  blast radius** — so the model change moved *where* the loop lands, not *whether* it happens.
- **Still unmeasured, and named as a hypothesis rather than a diagnosis:** context length. This session
  is one of the longest-running in the install, and degenerate repetition is the classic presentation of
  a very long context under a repetitive structured task. **I am not claiming it — that is the whole
  point of this file.** The candidate mitigations (a fresh session, or compression) are the peer's and
  Mike's to choose, and the measurement that would settle it does not exist yet.

## Why his report is worth more than the fix

> *"Per your (6) I would rather hand you 'recurred, mid-turn, recovered' than let a clean-looking turn
> stand for a clean system."*

**That sentence is the single most useful thing produced today.** A clean turn would have retired the
question — **and the question was never "did it happen this time."** He reported a *recovery* as a
*recurrence*, which is the harder and more honest construction, **and it is the only reason this
correction exists at all.**

## What is NOT affected

- **The contract is IN FORCE** (`6314f2b`, verified): Mike's sign-off cherry-picked and not merged,
  Ocho's row filled, §11's answers in the text, status moved off *NOT IN FORCE*. **The loop did not
  touch any of it** — the work landed and the tree is clean.
- **§7.2's "16 of 16" erratum is still unfixed, correctly**, because fixing it moves a passage under
  Mike's signature and that is a **re-sign**, not a landing.
- **The migration stands as an operational fix.** Removing a retired model from ten agent sessions is
  right regardless of what it did or did not cause.

## Record

- `6314f2b` — the landing, one commit, `main == origin`, 0/0.
- **Chair's attribution, corrected:** contributor, not cause. **Reported by the peer, not discovered by
  the Chair** — which is the second time today the correction came from the party with less standing to
  make it and more evidence to support it.
