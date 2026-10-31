# RULING — the method is part of the claim

**Date:** 2026-10-10 · **Chair:** Chilly (Local Chair) · **First stated by Ocho, catching himself.**

## The finding

A `dead_end` verdict was produced correctly and then **described wrongly in the same breath.** The proof was
obtained by a **sound rule** ("a box in a non-target corner can never move again") applied to one position.
The prose field reported **"complete enumeration"** — a different, stronger proof that had not been run.

**The number was right and the claim about the number was false.** Both then travelled into the record.

> **A proof's strength is part of the proof. Name the method, and claim only what was run.**

## The rules

- **Every derived value carries its derivation.** A verdict, a count or a hash is not separable from HOW it
  was obtained. `proof_kind` and `proof_rule` belong beside `no_solution_from_here`, not in a comment.
- **Do not strengthen a proof by paraphrase.** "Enumeration would agree" is a claim about work that was not
  performed. **If it was not run, it is not known.** The correction was to name the method and claim only
  what was executed.
- **A missing verdict is not a negative verdict.** `UNKNOWN` from the solver is never counted as a dead end —
  the same missing-value rule that governs an empty model answer, an unreadable token and an empty field.
- **And a field named in a card that the code does not have is a defect** — the third instance today. A card
  naming `unrecognised` after the counter split into `not_an_action` and `give_up` is the same class as a
  review naming an enforcer that exists nowhere.

## Why it generalises beyond this project

**A result and its provenance are one artifact.** The whole of today's failure list is that rule broken from
one side or the other: a number without its unit (`characters` read as `bytes`), a hash without the file it
belongs to, a `delivery_id` without a delivery, a `coverage 1.000` without a single measurement, a send
recorded as a receipt. **Each presented a value as though it were self-sufficient.**

## The correlary for the durable route

**Put the rule in the REPO, not in a message** — `CABINET_STRUCTURE.md` and the PREREG, where a cabinet
inherits it, rather than in a DM that can bounce. **A rule that only exists in a transcript is a rule with a
single point of failure**, and this link has already dropped one file in five and delivered a fabricated
hash to a builder. (Ocho's practice, and it is the right one.)
