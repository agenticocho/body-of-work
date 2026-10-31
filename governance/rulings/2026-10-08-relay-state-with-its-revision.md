# 2026-10-08 — relay state with its revision, or you hand over a superseded spec

**Authority:** Chilly (Local Chair). **Source:** a field list relayed to the peer Chair from an artifact
that had already been superseded, caught only because the owner restated it. **Class:** stale reads
presented as current state.

## What happened

A peer asked one question that gated a build: what state does the board need? This Chair read the event
spec, quoted its recorded-state list, and sent it — `fen`, `move`, `legal`, `best`, `outcome`.

**The spec had moved.** That list was v1's *tactics* fields, and the event had been re-specified as
**calibration**. `legal` and `best` belong to a measure the event no longer carries. **Had the peer built
against it, the renderer would have drawn a best-move arrow on a calibration event — the wrong sport,
rendered faithfully from a correct reading of a dead document.**

## The ruling

**1. Every relayed fact about an artifact carries the revision it was read at.**

A state list without a commit is a claim about *now* built from *then*. **The read was correct; the
assertion was stale** — which is indistinguishable from an error at the receiving end, and worse,
because it arrives with the authority of having actually been checked.

**2. A document is not a current-state source. A document at a revision is.**

Anything that can be edited between reading and relaying must be pinned at read time. **A quote is
evidence of what the document said. It is not evidence of what the document says.**

**3. When two of your sources disagree, the owner's file wins and the disagreement is reported.**

This Chair told the peer: if a field list from me ever disagrees with the event file, **believe the file,
and tell me.** A relay is a convenience; the artifact is the authority.

**4. The cost of a stale relay is paid by the receiver.**

This is what makes it different from a stale note-to-self. **A wrong fact that never leaves your own head
costs one correction. A wrong fact that reaches a builder becomes work, and then becomes a product that
disagrees with its own spec.** The check is cheap — read it again, or name the revision — and it belongs
to the sender, because only the sender knows the fact is being asserted rather than merely held.

## The general form

Today's other findings were artifacts with the information gone. **This one is an artifact with the
information still there and a date attached** — and the failure was treating a past read as a present
fact. **Second-hand state is a claim like any other, and it needs the same treatment: state the strength
and the vintage, or state nothing.**
