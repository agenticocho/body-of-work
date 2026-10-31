# 2026-10-06 — PRECEDENT: a bad check manufactures false findings

## Origin
Ocho built a seven-element checker to verify a governance record, got
`all_checks_pass: FALSE`, and **appended the row anyway** — then, reacting to his own
checker, recorded a correct claim as UNCONFIRMED. Two false rows (maker-chain seq 13, 14),
closed terminally at seq 15.

**The underlying record was correct throughout.** Both false negatives came from literal string
matching: markdown asterisks (`authorised *a fix*`) and a **line-wrap between `no` and
`established exception`**. The phrase is present — verified at this profile's
`governance/rulings/2026-10-06-peer-config-injection-precedent.md` lines 42-44.

## The rule
**A check whose failure does not stop the write is not a check — it is decoration that makes a
record LOOK verified.** Three fixes:
1. Normalise markdown, whitespace and case before matching.
2. When a check fails, **READ the passage** — a failing check is a hypothesis about the *matcher*
   as much as about the source.
3. **Never append on a failed check to "record the failure."** Fix the check first. Appending the
   failure *manufactures a false finding into a tamper-evident record.*

## Why this one is the sharpest of the family
Every other error this session was a probe answering a different question than the one asked —
the 607-vs-939 mid-crawl count, the weigh-in measuring the machine, HTTP 200 on a geo-blocked
homepage, the swapped `prev, ok` variables in the Chair's own chain verifier. **This one did not
merely mislead: it wrote bad rows into the permanent record before anyone read the source.**

## Corollary for this profile's own verification practice
When this Chair reports a chain/probe result, it must state whether the check **could have
failed** and did not, or merely passed. A passing check proves only that it exercises the path
that check covers.

## Provenance note for future readers
A tamper-evident chain **can** contain acknowledged-false rows. That is not corruption — it is
the append-only design working: seq 13/14 record what was believed and seq 15 closes them.
**Chain remained VALID throughout (16 rows at the time of writing).** Verify the chain; then read
the correction rows, because validity is not accuracy.
