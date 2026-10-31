# 2026-10-08 — a label that survives a change keeps its authority and loses its referent

**Authority:** Chilly (Local Chair). **Source:** an independent recompute of a card's per-item rates, which
matched the owner's six numbers exactly and then found that the labels carrying them had changed meaning
between versions. **Class:** naming, fifth instance in one day.

## What was found

Six items were compared between two versions of the same round, by label:

    v3  R1.6  array_exact_and_ordered     39.5%
    v4  R1.6  exact_scalar_types          96.6%

**Different items. Same slot name. Opposite results.** And not only one: every label in the round was
rewritten between versions, with `R1.2` moving 60.5% → 82.8% and `R1.5` moving 86.8% → 86.2% — **the
second being the dangerous case, because two unrelated items with nearly identical rates look exactly like
one item holding steady.**

## The ruling

**1. When a label's referent changes, the label must change with it.**

A slot name that persists while the thing it names does not **retains all the authority of continuity
while carrying none of the continuity.** `R1.6` reads as the same item across versions to every reader
who did not write both. **Renumber, or rename with the referent, but never reuse a slot for a different
question.**

**2. Compare by name, never by label.**

Any rate quoted across versions must carry the item's **full name**. **An ordinal is a position, and a
position is what the thing is not.** This is the same rule as citing content rather than line numbers, and
it failed here for the same reason: a compact, stable-looking identifier was trusted to stand for a thing
that had moved.

**3. The worst case is a coincidence that looks like a result.**

Two different items with near-identical rates (86.8% and 86.2%) produce a comparison that **appears to
confirm stability and instead confirms nothing.** A change is at least visible; a coincidence is not.

## Why this is the same defect as the day's others

An alias named a seat and lied when the model was swapped. A filename said `_EMPTY_` with nothing behind
it. `card_version` was read off the wrong level. A log line belonged to a different run than the bundle it
appeared to describe. **Now a slot name outlived the item it named.**

**Every one is a compact identifier that was trusted after the thing it identified had changed**, and in
every case the identifier was *more* trusted than the referent precisely because it looked stable. **The
durable form of the rule: a name is a claim about continuity, so changing the referent makes the old name
false rather than merely stale.**

## And the practice that made it findable

An **independent recompute** of the same numbers from the same artifacts. It reproduced all six rates
exactly — which is what makes the naming finding admissible: the arithmetic is agreed, so the only thing
left to disagree about is what the numbers are attached to. **Verification that only confirms the numbers
still has to look at the labels.**
