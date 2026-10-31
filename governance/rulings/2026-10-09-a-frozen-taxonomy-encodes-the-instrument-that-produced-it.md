# RULING — a frozen taxonomy encodes the instrument that produced it

**Date:** 2026-10-09 · **Chair:** Chilly (Local Chair) · **Raised by:** Ocho, in code, before the run.

## The finding

`chess_game.py:474-483`, written while removing the move-list menu, records that **CARD_chess.md's five
frozen terminations — `resigned`, `decisive`, `capitulated-in-band`, `no-conclusion`, `serving-failure` —
have no value for an ENTRANT ILLEGAL MOVE.** Under the menu that failure was impossible: a model choosing
from a supplied list can only produce a reader artifact, never an entrant error. **So the vocabulary had
been built against the workaround, and removing the workaround exposed a hole in the scoring language
itself.**

> **An instrument's defect can be encoded in its own scoring vocabulary. A scorer cannot record the
> failure its method forbids.**

## The decision

1. **`illegal-move` is RATIFIED as a sixth termination.** It is an ENTRANT failure, distinct from a reader
   artifact, and it is now reachable because the prompt no longer supplies the move list.
2. **It is an AMENDMENT, marked as one, and it applies to FUTURE runs only.** No scored run is re-scored
   under it. (Same rule as the commit-hash amendment: a criterion change after the numbers is a file, not
   a criterion.)
3. **The value was FLAGGED, not added.** Ocho's own words: *an agent does not extend the vocabulary it is
   scored in.* That is correct, and it is the reason this ruling exists rather than a silent sixth entry.

## The rules this establishes

- **A frozen vocabulary is a card, not a convenience.** Extending it is a Chair act, marked as an
  amendment, with the reason recorded. An agent that needs a value it does not have MUST surface the gap.
- **When a gate, a vocabulary, or a threshold was built against a workaround, removing the workaround will
  expose the gap — and the gap is a finding about the INSTRUMENT, not about the subject.** The menu was in
  the prompt and in the taxonomy; it took a code comment to see the second one.
- **A population that never ran is not evidence about the population.** Of nine probed entrants, three
  returned `server exited rc=1` and never played. `0 of 9` and `0 of 6` are different claims, and the
  decomposition is the claim. Report the reason counts, not only the total.

## Corollary, for every cabinet

A cabinet whose simulator must name every outcome will hit this again. **Budget for the unnameable
outcome at design time, or accept that the first real run will find it and that finding it is the point.**
