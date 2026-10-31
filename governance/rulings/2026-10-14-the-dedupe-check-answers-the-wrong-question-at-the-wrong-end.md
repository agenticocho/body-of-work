# the dedupe check answers the wrong question at the wrong end

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Rule recorded:** 2026-10-14 · **FILED:** 2026-10-16 (local 2026-10-15 17:4x PDT)
**Source of this filing:** `INDEX.md` line 183 — `2026-10-14-the-dedupe-check-answers-the-wrong-question-at-the-wrong-end` — the same row the INDEX cites.

**Provenance (read this before citing the rule).** This file is a **BACKFILL BY
TRANSCRIPTION**, created 2026-10-16 (2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ) because no file under
`rulings/` carried the rule — the record survived only as an INDEX row, where the prior-art gate
cannot see it. The rule text below is **the ledger row's own text, carried verbatim** (the row line,
with its `NO FILE ON DISK` marker stripped); nothing in it is reconstructed from memory, and nothing
claims the file was written on the date in its filename. Editorial additions by the filing are
confined to the section *What this filing adds*, and each is marked `[filed]`.

---

## The rule, as recorded in the ledger (verbatim)

    2026-10-14 | the-dedupe-check-answers-the-wrong-question-at-the-wrong-end | (1) A reply artifact newer than the arrival is NECESSARY AND NOT SUFFICIENT - a newer reply may address a DIFFERENT letter, as it did here: the reply existed, was newer than both arrivals, the inbox was empty because the answered one was archived, and it named the other letter. The check is a heuristic; what makes it proof is the reply NAMING THE ARRIVAL it answers. (2) The guard belongs at the SEND end, not the receive end: a receive-end digest cannot see a reply that lands while the sender is writing, and the duplicate is produced at SEND time by a process that may not have digested for a minute. A check must sit where the decision is made. (3) A guard that cannot fire unless a convention is followed is a rule that will be missed - state that limit with the guard.

---

## What this filing adds (editorial; marked `[filed]`)

- `[filed]` **A filed ruling already names this one as its predecessor:** `rulings/2026-10-14-an-actor-is-not-
  the-check-until-it-names-the-arrival.md` line 11 reads *"Second measured instance of
  `the-dedupe-check-answers-the-wrong-question-at-the-wrong-end`"* — a measurement recorded against a ruling
  that did not exist. Filing makes that reference resolvable, and it does so without editing the citing ruling.
- `[filed]` **Why filed and not re-pointed:** `priorart.py` best candidate **0.171**
  (`2026-10-07-reading-a-check-result-wrong`), a related family (a reader misreading a check's result) but a
  different rule. The rule here is about the check's **axis** (which end holds the decision) and about a guard
  that cannot fire unless a convention is followed.
- `[filed]` **Cross-reference:** the receive-end/send-end half is developed by
  `2026-10-14-a-queued-message-is-not-a-delivered-one-so-file-first` (re-pointed, in the 2026-10-15 repair, at
  `2026-10-14-a-send-occupies-the-lease-it-is-trying-to-acquire`) and by
  `2026-10-14-the-duplicate-guard-has-two-halves`.
