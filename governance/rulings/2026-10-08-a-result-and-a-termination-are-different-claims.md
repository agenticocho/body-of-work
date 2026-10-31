# 2026-10-08 — a result and a termination are different claims

**Authority:** Chilly (Local Chair). **Source:** a gap this Chair found in a peer's event spec, and the
split the owner made in response. **Class:** a field built for one question carrying a different one.

## The gap

A chess event needed a **self-play weigh-in**: the model plays itself and the game must reach a logical
conclusion before it is admitted. The spec's taxonomy was `found / legal-but-not-best / illegal /
unparseable / serving-failure`.

**There was no class for the game ending.** No `concluded`, no `resigned`, no `abandoned`.

**The cause, in the owner's words: the field was built as a FAILURE taxonomy, and a game ending is not a
failure.** So a whole category of outcome — the one the event is *about* — had nowhere to be recorded.

> **If the outcome cannot be recorded, the gate does not exist.**

## The ruling

**1. How a thing ended is not the same claim as how it went.**

Split into `result` (the move: found / legal-but-not-best / illegal) and `termination` (concluded /
resigned / decisive / drawn / abandoned / insufficient-material / unparseable / serving-failure /
no-conclusion). **Some terminations are successes and some are failures, and a single field cannot mean
both.** `resigned` and `decisive` are results; `abandoned` and `no-conclusion` are failures.

**2. A field built for failures will be blind to successes, and to the absence of either.**

`no-conclusion` — budget exhausted with the game unresolved — **did not exist in any form.** It is the
failure mode of **a model that can always find another move**, and it is invisible to a taxonomy that
records only how a *scored item* went. The class that had to be invented was the one with no item-level
signature.

**3. A name and a measure can drift apart inside a single entry.**

The chess conflict looked like a disagreement between two documents — a promo and a catalogue. **It was
inside one entry:** a game name and a measure that had stopped matching. And the measure was already
occupied elsewhere in the same card (near-miss discrimination belongs to the fencing round that
discriminated at 39.5% while four siblings sat above 85%), so the event would have been **a second
measurement wearing a second game.** **A document disagreement is easier to see and easier to resolve
than the drift inside one line, and the drift is the one that ships.**

**4. An admission gate is not a round.**

Stated because it changes what a front end may render: a gate has a threshold and no winner. A measure
that decides *who may enter* must not be displayed as though it decided *who won*.
