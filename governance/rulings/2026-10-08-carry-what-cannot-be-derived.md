# 2026-10-08 — carry what cannot be derived, and check as far as the check can see

**Authority:** Chilly (Local Chair). **Source:** a field list answered by derivability rather than
preference, and a staleness check that reported a hang on a working field. **Class:** the derivability
test, and the visibility horizon.

## Part one — carry what cannot be derived; derive what can

A display asked for four move flags: capture, promotion, castling, check. They were **refused**, because all
four fall out of the primitives already present:

    promotion   the suffix on the move (`e7e8q`)
    castling    a king moving two files (`e1g1`) -- the rook follows
    capture     the destination square is occupied in `fen`
    check       the position after the move, reproducible from `fen` + the move

**Carrying them would create a second source for a fact the primitives already state** — and a recorded
flag that disagreed with `fen` would be **a defect with no way to tell which side was right.**

**The same rule runs the other way, and that is what proves it is a rule rather than a preference:** the
clock fields (`secs`, `gen_tokens`, `budget_hit`) **are** carried, because they are facts about the *run*
and cannot be recovered from the board. `wins`/`trials` are carried and the aggregate is derived, for the
identical reason.

> **One test: can a stranger recompute it from what is already in the bundle?**
> If yes, do not store it. If no, you must.

**A second source is not redundancy, it is ambiguity** — and the ambiguity is unrecoverable, because the two
copies carry equal authority by construction.

## Part two — the fifth member, found in a live artifact

Applying the day's family rule to his own card, the owner found **15 of 29 entries storing the round
aggregate rounded (`0.3333`) while 14 store it exactly (`0.3333333333333333`)** — one field written two ways
inside one artifact, with `wins` and `trials` present in every record.

**The exact value is always derivable from the primitives; the stored form only ever loses precision.** The
remedy is a **read rule**: compare the primitive, never the rendering. **Two entrants that differ will look
identical to anything that sorts, thresholds or colours by the stored aggregate.**

## Part three — a check with a ceiling on what it can see reports a number that looks like a measurement

A staleness check reported **`RUNNING BUT STALE — 2727s`** on a field that was working: the server log
showed the token counter climbing and had been written **three seconds earlier.**

**The cause was a visibility horizon, not a bug.** The runner log is written **per entrant**; the server log
is written **per token.** A large model therefore produced no runner output for 45 minutes while working
perfectly — and the check, reading only the runner log, could not see it. **A check is only as good as the
distance it can see, and a short horizon produces a confident number rather than a visible gap.**

**This is distinct from the check that cannot fail** — that one never fires. **This one fires, and its
number is computed correctly, from insufficient evidence.** The remedy is to read the newest of every log
that carries progress, so the horizon is longer than the thing being watched.

## The family, five members, one test

| representation | the thing it stands for |
|---|---|
| a greedy regex's extraction | the model's actual output |
| `_EMPTY_` in a filename | the reason a bundle was empty |
| a slot name surviving a version change | the item the slot used to mean |
| a rounded percentage stored beside its own ratio | the measured rate |
| **a log's silence** | **a run's progress** |

**Not one was found by examining the thing itself.** Every one came from applying a rule to something
adjacent — which is the argument for the rules existing as rules rather than as five anecdotes.
