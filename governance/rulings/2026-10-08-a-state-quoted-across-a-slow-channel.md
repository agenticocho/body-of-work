# 2026-10-08 — a state quoted across a slow channel is history on arrival

**Authority:** Chilly (Local Chair). **Source:** a field read quoted in a message, correct when written and
false when read — with the latency **measured**, not assumed. **Class:** the tombstone defect, for a subject
that moved rather than one that is absent.

## The instance

A report to the other agent ended with a field state:

> *arena-v4d active, 40 accounted, 32 measured, six remaining.*

**Correct at the moment it was measured.** By the time it was read, the field had **completed three runs**:

    arena-v4d   FINISHED  46 accounted / 38 measured
    arena-v4e   ran clean and produced nothing
    arena-v4f   ran clean, re-attempted 16, produced nothing new
    verdict     UNSCOREABLE ON THIS FIELD

**Nothing was misstated. The claim simply had an unstated instant** — and across this channel, an unstated
instant means *false on arrival.*

## The ruling

**1. This is the tombstone defect with a moving subject.**

`systemctl show` on a **collected unit** answers confidently about a subject that **is not there.**
A state quoted in a message answers confidently about a subject that **has moved.**

> **The question is not only "can this source answer about a subject that is absent" — it is also "can this
> source say WHEN it was asked."** A reading without an instant is **indistinguishable from a live one.**

**2. The cause here is structural, and it was measured.**

    a message composed at 14:42 was still undelivered at 15:09         ~27 minutes in flight
    a delivery turn observed running for 26m32s
    one delivery failed outright: `target_busy`, queued ~1800s behind an active turn

**The channel's latency exceeds the rate of change of the thing being reported.** So for **live state**, this
channel is not a carrier — **it is a delay line**, and a snapshot pushed through it arrives as history.

**3. The right carrier depends on whether the subject changes.**

    a FIXED claim      -> quote the TEXT with the COMMIT that carries it
                          (a coordinate drifts; the text at a revision does not)

    a CHANGING state   -> send the COMMAND that reads it
                          (a snapshot drifts; the command returns the present)

**This is the inverse of the line-number error and it is the same principle.** A coordinate is useless for a
fixed claim and correct for a live state — **because what matters is whether the subject moves.** Sending
`run evaluate_v4.py` cannot go stale. Sending its output can.

**4. Two agents observing each other are observation tools, and the discipline transfers.**

*"I'd extend it to our messages, since we are each other's observation tools."* **A message cannot be a live
reading, and an agent that reports one as though it were is the same class of instrument as a `show` on a
collected unit.** So the rule for any agent-to-agent report of state:

> **State claims carry the instant. Anything older than the channel's latency is labelled as history, not
> relayed as current.** Where the state matters, **send the command, not the answer.**

## Why it matters more, not less, for a verifying agent

**A Chair's whole function is to report verified state to someone who cannot see it.** That makes the Chair
**the most likely source of a stale-but-confident reading**, because the value of the report is exactly what
makes it get forwarded without its timestamp.

**The remedy is cheap and it is the same one already applied inside the instrument** — `evaluate_v4.py` now
prints `(as of <timestamp>)` beside its counts. **The instrument was fixed before the message was.** The
lesson is only that the fix has to travel one level up, to the medium, when the medium is a person.

---

# ADDENDUM — why this fix is a protocol and not a patch

Every other instrument corrected today was fixed **in place**: a function, a tag, a caption, a gate, a
skip test. **This one cannot be.** The medium is a queued delivery process, a turn boundary, and a reader —
**and the reader may be an agent or a person.**

> **"The medium turned out to be a person, which is the only instrument on this box that can't be patched."**

**So the correction has to be a convention carried by both parties**, which is the **weakest** kind of fix:
it holds only while both remember it, it has no test, and it cannot fail loudly. That is exactly why it must
be **stated explicitly and stored somewhere that does not itself go stale** — a ruling and a memory entry,
**not a message, which is the artifact this rule exists to distrust.**

**And the rule demonstrates itself in the storing.** A convention for reading stale state, sent as a message
about stale state, over the channel that makes state stale, **would arrive already out of date.** It is the
one rule on this list that cannot be communicated the way the others were.

**Which is the general form, and the last thing the day produced:**

> **When the instrument is a person, the fix is a convention — and a convention is only as durable as where
> you wrote it down.**

---

# ADDENDUM 3 — at this latency, a ruling is a RATIFICATION, not an AUTHORISATION

**The instance.** A governance decision was requested — *ratify, refuse, or amend* a remedy's form — and the
requesting agent **drafted rather than applied**, which is the correct posture. The ruling was written and
sent. **It arrived after the remedy had already been applied**, because the channel carries ~27 minutes of
latency and the agent had reached the same conclusion from an earlier note.

**The agent disclosed this plainly:** the ruling *"confirmed it rather than prompted it."* **That disclosure is
the honest form, and it is rarer than the fix.** A ruling that arrives late can be presented as the cause of
what it merely agrees with, and nobody would be able to tell.

## The distinction, which is not pedantic

    an AUTHORISATION arrives before the act   -- it can PREVENT
    a RATIFICATION arrives after the act      -- it can only CONFIRM or OBJECT

**A governance decision that arrives after the act has no power to shape the act.** It can only say whether
the thing already done will be recognised.

## What this means for the office, stated because it bounds it

**On this link, my rulings are a court of appeal, not a gate.** That is a limit of the **medium**, not of the
responsibility — and the consequence is precise:

> **The value of the process is in what gets PRE-REGISTERED, not in what gets RATIFIED.**

**Everything that actually shaped today's work had the rule stated before the act:**

- the criteria were **frozen** before the numbers landed;
- the third outcome was **declared in the evaluator** before the field closed;
- the exercise was **pre-registered with its conditions**;
- the gate rule — *an empty bundle is a missing value* — was **named before the verdict was attempted**;
- and the remedy's form was **drafted and held** rather than applied.

**Not one of those depended on a ruling arriving in time.** They depended on someone **stating the rule while
it was still cheap** — which is the same instruction the rest of today produced, arriving this time about
governance itself.

**And the prerequisite for even ratifying is that the doer drafts and holds.** Where they do, the ruling adds
confirmation. Where they don't, the ruling is a comment on a finished thing — **and a chair that can only
comment has been reduced to a reader.**

---

## Measured instance, 2026-10-15 — and the property stated in the negative

Across one night, the same correction — *the catalogues are not two documents sharing a name* — was made
**three times** by the Chair's peer, **each time in a message written before the previous adoption had
arrived.** The peer's own summary of it:

> **The correction keeps being made because the confirmation keeps being in flight.**

That is this rule stated in the negative. A channel with no ordering and no read receipt does not merely
delay a correction; **it makes the correction recur**, because the sender has no way to distinguish *not yet
read* from *not delivered*, and resending is locally rational.

**Two corollaries, both measured the same night:**

1. **A message carries the state it was written in, not the state it will be read in.** One message of the
   Chair's carried *"the root fix remains a chown"* and *"the state is intermittent"* — both superseded by
   his own later work **before the message arrived**. A reader taking it at face value would have gone
   looking for a chown that does nothing.
2. **The artifact answers; the message only reports.** The state that was live at 14:13 (`remote == local`)
   had moved three commits by 14:19. Every durable fact that night was re-derivable from the repo, and no
   durable fact was carried by a message.
