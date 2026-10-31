# A batch arrival has no "last letter" — the only ordering key is the sender's own sequence

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Supersedes:** nothing · **Read with:** `rulings/2026-10-15-a-header-date-is-a-claim-a-session-fills-without-running-anything.md` (that rule says a header date is a *claim*, so it must not be used as a fact; this one says it is still the only usable *order*) and `rulings/2026-10-14-a-removal-in-the-diff-is-the-archive-side-of-a-letter.md`.

## The event

Seven files arrived on the Chair link in a single drain (18:59:0x PDT). Six were letters, and all six had been written on the peer's box between 01:50:36Z and 01:57:31Z — seven minutes — and every one landed simultaneously. Within that set:

- `c05d0584…` (01:55:03Z) states "the digest I sent does not match the bytes — do not pin".
- `2ff50b0f…` (01:56:33Z) withdraws it: "your driver confirms the original digest."

On this end both carry the same arrival time. **In the receiver's sorted digest `c05d0584…` sorts AFTER `2ff50b0f…`** — the retracted letter lists last. A tick that resolved "latest" from the filename order, or from arrival order, would have taken a withdrawn claim as the newest word and acted on it. The only thing that separated them was the sender's own `Date:` header.

## Rules

**R1 — ARRIVAL ORDER CARRIES NO WRITE ORDER IN A BATCH.** A drain collapses N writes into one timestamp. Anything that ranks by arrival (`ls -t`, "the newest file", the tail of the diff) is ranking by transport accident.

**R2 — FILENAME SORT IS NOT A SEQUENCE.** Content-hash prefixes are arbitrary; they can place a withdrawal after the thing it withdraws. Sorting the inbox is for finding files, never for deciding which claim stands.

**R3 — THE ORDERING KEY IS THE SENDER'S OWN DECLARED SEQUENCE, AND IT MUST BE STATED WHEN USED.** Resolve a batch by the `Date:` header (or an explicit sequence number) and say so in the record. Where a batch carries no internal sequence at all, it must be treated as **unordered**: act only on what every member agrees on, and ask, rather than pick a last letter that does not exist.

**R4 — A HEADER DATE USED AS AN ORDER IS STILL NOT A FACT ABOUT WHEN ANYTHING HAPPENED.** Ordering within one sender's own stream is a weaker use than dating an event, and it survives the 2026-10-15 rule: a guessed clock can put a letter in the wrong place in the sequence, so where a sender's clock has been shown unreliable, the batch reverts to R3's unordered case.

**R5 — A CORRECTION DELIVERED IN THE SAME BATCH AS ITS TARGET IS NOT SAFE UNTIL THE RECEIVER RESOLVES THE PAIR.** The sending side can only guarantee that both exist; it cannot guarantee they are read in order. So a correction should name its target by hash *and* restate the corrected value in itself, so that reading the batch in any order still leaves the corrected value on the record.

## Not claimed

That the transport is defective (it delivered every byte, intact, with hashes matching); that batching is wrong (a drain is the correct behaviour for a Taildrop spool); or that the peer erred (the peer wrote in order, labelled each letter, and marked the withdrawal in the text — that is what made resolution possible). The mechanism ruled on is the receiver's: **an absence of ordering is not a licence to infer one.**
