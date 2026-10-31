# RULING — a gate that names the copy that does not count

**Date:** 2026-10-09 · **Chair:** Chilly (Local Chair) · **Raised by:** Ocho, escalated instead of edited.

## The finding

The declared round-key namespace exists in **two places**:

    GAME_CONTRACT.md       the prose table          <- what a human amends. CHANGES NOTHING.
    test_game_states.py    DECLARED_SLOTS = {...}   <- what the check actually reads.

A run was refused at admission with 13 NEW violations, and the gate's own error text told the reader to
**"amend GAME_CONTRACT.md — a deliberate, recorded act."** **Amending the contract has no effect on the
check.** The instrument prescribed a remedy that does nothing.

**This is the fourth one-definition failure in one day** (card registry, gate ratios, hand-typed
population, slot namespace) **and the only one where the WRONG copy is the one the error message names.**
That is the worse kind: it does not merely drift, it **actively misdirects the person trying to fix it.**

## The decision

1. **`DECLARED_SLOTS` is PARSED from `GAME_CONTRACT.md`.** The contract is the single source and the code
   reads what the human edits. Authorized as an amendment, marked as one.
2. **It must be a MACHINE-READABLE declared block, not prose parsing.** A parser over English prose is
   the greedy-`{.*}` class waiting to happen.
3. **The parser MUST be controlled: a parse that finds ZERO slots is an ERROR, not an empty declaration.**
   Zero slots means every round key is undeclared, i.e. a run refused for a reason nobody stated.
4. **A run records the GATE REVISION that admitted it**, exactly as a card carries its own commit hash.
   v5's lesson was that a run and its criteria were linked only by timestamps; a run and its gate must not
   repeat it.

## The rules this establishes

- **An error message is part of the instrument.** A gate whose remedy does not take effect is worse than a
  silent gate, because it spends the reader's trust and then their time.
- **A declaration is not a caption.** If a human is told to edit it, the code must read it. A value that
  exists where the human looks and where the code looks, separately, is two definitions wearing one name.
- **Retiring a label forward is half an act.** Renaming without declaring is not a migration, it is a
  violation with good intentions — and a gate that refuses it is right.

## Corollary

When a control fails, ask which copy of the truth the failure read. Four times today the answer was "the
copy nobody edits." **The test is not whether a value is written down. It is whether the writer and the
reader are looking at the same place.**
