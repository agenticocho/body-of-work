# 2026-10-08 — test the claim against the other artifact

**Authority:** Chilly (Local Chair). **Source:** a sentence this Chair wrote about one artifact, which the
owner then tested against the artifact already on disk — where it was false. **Class:** a method, plus a
field that answers the wrong question.

## The move that found it

A ruling earlier in the day said, of the chess event: *the same fields that make a silence diagnosable are
the ones just added for the clock.* The owner read it and asked a different question: **is that true of the
artifact already on disk?**

It was not. Measured:

    ITEM record carries:  score, reason, raw, truncated
                          ABSENT  secs
                          ABSENT  gen_tokens

**The runner measured both** — elapsed seconds per trial, completion tokens per trial — **and wrote them to
its log.** A log is discarded relative to the artifact. **So the round could say how long it took and the
item could not**, and the fix for the silent zero had closed the reason while leaving the *time* outside
the record.

## The ruling

**1. A claim written about one artifact is a hypothesis about every other.**

The sentence was **correct about chess and false about the card**, and that asymmetry is the only reason
the card got fixed. **When a rule is stated for one artifact, immediately check it against the nearest
artifact that already exists** — the rule is cheapest to apply at the moment it is written, and the
artifact that already exists is the one with no defence.

**2. A boolean answers whether the output was cut, not how hard the model worked.**

`truncated` says the generation hit the cap. **It does not distinguish *this took eight minutes because
the model was reasoning* from *this took eight minutes because it ran to the limit*** — and those are
different claims about the model and the machine. Elapsed time plus token count are what answer it, **and
they are exactly what a clock renders** — which is why the clock field was specified for chess this same
hour. **A rule written for one artifact and not applied to your own is the ordinary case, not the
exceptional one.**

**3. A measurement that lives only in the log has not been recorded.**

Same rule as the silent zero and the empty bundle, now one level down: **the artifact is the record; the
log is a trace of the run that produced it.** Anything present only in the log is discarded the moment
anyone reads the artifact, and reading the artifact is what a verdict is built from.

## Scope, and why forward-only is the honest answer

The fix lands in `arena.py` and the bundle writer, and **the 29 bundles already measured do not carry the
clock** — the running process imported its code before the change. **Same boundary as every other fix
today: forward-only, stated as such, rather than a backfill that would claim a run-time record it cannot
support.** A field added after the fact and presented as measured would be worse than its absence, which
is the rule the backfill was refused on.

## The shape of the whole day, one last time

A bare name. A count without its denominator. A zero with no reason. A label with nothing behind it. A
channel with no reader. A taxonomy that could not hold a game ending. A record shaped for a puzzle. **And
now a duration that would not leave the log.** Every one is a well-formed artifact with the information
gone, and not one of them was a model failure.
