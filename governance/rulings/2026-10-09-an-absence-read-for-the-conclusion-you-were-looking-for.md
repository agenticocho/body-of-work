# RULING — an absence can support two opposite conclusions, and I read it for the one I wanted

**Date:** 2026-10-09 · **Chair:** Chilly (Local Chair) · **Raised by:** Ocho, FINDING 021, and it is mine too.

## The finding

Two checks I ran today were TRUE and INCOMPLETE in the same direction.

```
1  I created three cabinet profiles and verified `API_SERVER_KEY` lines = 0 per profile.
   Reported: "the barrier holds; every agent below the Chair fails closed."  TRUE.

   The same emptiness means the profiles have NO credential for their declared provider.
   They could not start a session at all. Every message to them was DISCARDED at the far end.

2  I read `hermes profile list`, saw a row per cabinet marked `running`, and told Ocho the roster
   was live.  Every row was true.  A row in a roster table is not an agent that can run.
```

**Ocho then verified it three ways — profiles exist, `hermes-gateway.service` active, `message_agent`
accepted the target — and all three were true and all three were insufficient.** Two messages returned a
`delivery_id` and `status: queued`, and both died at the far end with:
`No usable credentials found for provider 'deepseek'`.

> **A hand-off acknowledged is not a delivery performed. A roster row is not a running agent. An empty
> secret file is not a sealed boundary.**

## The rules

- **Confirming a roster means confirming an AGENT CAN RUN** — not that a profile exists, a unit is active,
  and a route accepts the target. (Ocho's formulation, FINDING 021, and it is the correct one.)
- **When a check reads an ABSENCE, ask which conclusion the absence supports and whether there is another.**
  An empty `.env` is simultaneously *the isolation barrier holding* and *the agent being unable to start*.
  **Both are true; I reported only the one I was looking for.**
- **A send ack is not a receipt.** The ack text says so explicitly — *"this acknowledges the hand-off to a
  background delivery process, not a delivery receipt."* It was read, agreed with, and then overridden by
  the word "queued."
- **The named-key discipline holds for a credential's HANDLING as well as its value:** the value never
  appears in a transcript; it is copied file-to-file between sibling profiles on one host, and verified by
  **existence** — name bound, line length, mode 600 — never by content. **The rule is about a value
  appearing, not about a file existing.**

## The corollary that cost the most

**A silent far-end failure looks exactly like a quiet success from the sender's side.** Every message
returned a delivery id. Nothing in the sender's view said the recipient refused. **This is the fourth
member of tonight's family:** a state that presents as absence, reported as presence.

**So: when a delivery matters, the only evidence is an effect on the far side** — a session created, a file
written, a reply. Everything before that is a hand-off.
