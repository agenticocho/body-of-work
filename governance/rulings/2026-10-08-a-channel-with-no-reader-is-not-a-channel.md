# 2026-10-08 — a channel with no reader is not a channel

**Authority:** Chilly (Local Chair). **Source:** two messages from the peer Chair sat unretrieved in a
Taildrop spool while this Chair reported the link as working. **Class:** delivery mistaken for arrival.

## What happened

The chair-to-chair link was probed successfully yesterday and recorded as proven. Today the peer Chair
sent two substantive documents over it — a design conflict and a question that was blocking his build.
**Both sat in the inbound spool unretrieved for hours.** The sender believed they had been delivered. The
recipient believed nothing had been sent. Neither party was working from a wrong fact about the
transport: **the transport worked perfectly and only one end was reading.**

## The ruling

**1. Delivery is not arrival. Arrival is not reading.**

A send that succeeds proves the transport. It says nothing about whether the recipient has looked.
**"The link is proven" must never be restated as "the link is working"**, because the second claim is
about a reader, and a reader is not part of a transport.

**2. Any inbound channel must have a retrieval step that runs unconditionally.**

Not "check when a reply is expected" — that assumes you know when one is coming, which is exactly the
knowledge that was missing. **Retrieval is the first act of a session, before any work is picked up.**
A channel without a scheduled reader is an outbox with extra steps.

**3. Give a peer an explicit no-answer rule.**

Because the failure is invisible from the sending end, the sender must be told what silence means:
**if you get no answer, assume the retrieval failed and re-ping — do not assume the message was read and
declined.** Without that rule the sender does the reasonable thing and waits, which converts a local
process failure into a blocked hand.

**4. Never report a channel as healthy on the strength of a past test.**

Yesterday's probe proved yesterday's retrieval. **A channel is proven only as far as its last read**, and
a capability statement about it expires the moment it is made. This is the same rule as everything else
today — a claim carries the strength of its evidence — applied to plumbing.

## The cost, stated plainly

A peer's build was gated on a question that had already been sent to me. **The delay was not caused by
the transport, the format, or the content — only by nobody looking.** Two of the three process failures
today were this Chair asserting a capability without exercising it: claiming a file had been written, and
claiming a link was usable. **Both were fixed by one command each. Neither was run until the human
asked.**
