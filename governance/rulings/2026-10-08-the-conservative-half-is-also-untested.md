# 2026-10-08 — the conservative half is also untested

**Authority:** Chilly (Local Chair). **Source:** a dead calibration block whose revival would have made a
gate *more permissive*, found by reading it before deciding. **Class:** the complement of the
flattering-error rule, from the same day.

## What the block was

A panel of critics approves or flags work. One block in it softens `CONCERNS` → `APPROVE` when a single
critic flags one known pattern while the others approve. **It had never fired** — because its lookups asked
for `c.get("model")`, a key the critic dictionaries do not carry, so every lookup returned `None` and the
whole block was unreachable.

**So the panel has been stricter than designed for as long as the bug has existed.**

## The ruling

**1. A bug fix to a gate is a decision about permissiveness, not a repair.**

Correcting the lookup would have **widened what the panel lets through.** That is not a neutral
restoration of intent — **it is a change to the gate's behaviour, and it needs evidence of what it would
actually approve before it is enabled.** A fix that makes a system more permissive must be reviewed as a
policy change, because that is what it is.

**2. Dead code that looks live is the class.**

A block must be either **genuinely live** or **explicitly, nameably dead.** This one read as an active
safety valve while being unreachable — the worst of both, because a reader reasons from its presence and
its presence decides nothing. **The remedy is a named switch**: the bug corrected, the intent preserved and
readable, and the decision carried by a constant whose only possible states are deliberate.

**3. Do not delete a decision to tidy a file.**

*"We considered softening `CONCERNS` for this specific pattern and chose not to"* is a decision. **An empty
space is not**, and the next person will re-derive it — probably the other way, and probably without
knowing it was ever considered.

**4. An instrument error has no preferred direction, and BOTH halves escape testing.**

Earlier today: the instrument's failure made models look **worse** than they were (a FAIL where a PASS
belonged). Then the same instrument made an item look **harder** than it was, and the flattering reading
was the one nobody would have checked.

**This is the third case and the one that closes the set: the error made the gate STRICTER.** A system that
says *no* does not get investigated. **Nobody audits a refusal they agree with** — and a conservative
failure mode sits unexamined for exactly as long as a convenient one, for the same reason: **both produce
an outcome nobody wanted to question.**

> **The untested half of an instrument error is not the favourable half. It is every half that fails
> silently in the direction of the answer you already hold.**

**5. When it is fixed, say what changed about the system's behaviour, not what was repaired.**

The honest report here was not *"a lookup bug is fixed."* It was *"this gate has been stricter than
designed; correcting it would make it more permissive; we are correcting the bug and keeping the strict
behaviour deliberately, under a name."* **A repair report that does not say which way the behaviour moved
has not reported the change.**
