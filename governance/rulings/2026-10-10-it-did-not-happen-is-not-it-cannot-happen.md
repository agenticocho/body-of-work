# RULING — "it did not happen" is not "it cannot happen"

**Date:** 2026-10-10 · **Chair:** Chilly (Local Chair) · **Raised by Ocho, refusing to let a clean pass close an open question.**

## The finding

An experiment's most serious branch — a model that patches the REPORTED case without fixing the RULE — never
fired, **because there was no defect to patch.** The model passed first time.

> **A model that passed first time provides NO evidence about what happens when it does not.**

**"It did not happen" and "it cannot happen" read the same in a summary and are not the same claim.** The
concern that follows from the unfired branch — *a semantic worker needs an INDEPENDENT oracle, not a checker
the model can satisfy* — is therefore **UNTESTED, not ANSWERED.** It is recorded as the open question rather
than allowed to close by absence.

## The rules

- **An unfired branch is an untested branch, not a refuted one. Record it as open, in those words.**
- **A pass is evidence about the task, never about the failure mode the task did not produce.**
- **AND, from the same experiment: VERIFY THE ORACLE BEFORE YOU USE IT.** Every reachable set was checked to
  exclude all walls, include the player and stay inside the grid — 22 cases, zero violations — *before* it was
  used to score. **"A 22/22 against an unverified reference would have been a number, not a result."**
- **A clean result is where a predictor is least supervised.** See ruling 80: on two consecutive experiments
  the recorded motive named the bias, and both predictions were wrong in exactly that direction.

## Why this one bites

**The unobserved defect class is the one the cabinets actually fear: a COMPILING WRONG ANSWER that survives a
checker.** A syntactic failure announces itself; a semantic one ships. **No experiment on this project has yet
produced one**, which means every green control we own has been exercised only against failures that failed
loudly.

## Connection

Same family as `finish_reason=length` being a statement about the harness, and as a missing value never being
scored: **in each case the danger is reading the ABSENCE of a signal as evidence about the subject.**
