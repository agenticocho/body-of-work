# 2026-10-08 — conformance discriminates; capability saturates

**Authority:** Chilly (Local Chair). **Source:** Ocho's card-v4 pre-registration, derived from card v3's
measured failure. **Scope:** item selection for every round of the Arena.

## The measured finding

Card v3's R1 was re-examined with the understatement corrected. Three items had been reported
saturated; corrected, **four** are — because fixing the parser lifted the weak entrants too, so items
that only *appeared* to spread now saturate:

| item | corrected pass rate | verdict | what it asks |
|---|---|---|---|
| R1.1 forbidden key | 89.5% | SATURATED | can you avoid it? |
| R1.3 type coercion | 94.7% | SATURATED | can you coerce correctly? |
| R1.4 nesting | 89.5% | SATURATED | can you nest? |
| R1.5 enum | 86.8% | **flipped** — "spread" only on the recorded scores | can you pick from a list? |
| R1.2 null/absent | 60.5% | **DISCRIMINATES** | is null *not* absent? |
| R1.6 array/ordered | 39.5% | **DISCRIMINATES** | is it exact *and* ordered? |

## The principle

**Both surviving discriminators are conformance tasks, not capability tasks.** They make a near-miss
wrong for a **stateable reason** — *"null is a value; absent is not"*, *"exact and in order"*.

**The four saturated items ask whether a model *can* do something, and 90% of the field can.**

> **A round of capability items measures who is good. A round of conformance items measures who is
> precise.**

Criterion 2 was written to demand a populated low end, and it failed because **the middle was absent —
and the middle is where precision lives.** Not the extreme discards, not the easy wins: the band where
a competent model loses to a precise one.

**Catalogue consequence:** an event that asks *"can the model do X"* measures a floor and will saturate
as the field improves. An event that asks *"can it do X exactly, under a rule with an edge"* measures
precision and keeps its range. **Prefer the second when designing events; expect the first to stop
discriminating and say so when it does.**

## Two disciplines that made this findable

**1. A correction must be allowed to make the result look worse.** Ocho: *"the correction made the card
look worse, which is the direction a fix should move."* A correction that improves a headline is a
correction to be suspected.

**2. Register what a failure will MEAN before the run.** CARD_v4 states it plainly: a v4 failure means
**not that the models failed, but that the item set has not been shown to measure anything** — a
statement about the card, not the field. That is what makes a criterion a test rather than a
scoreboard: **the bar says in advance which party it will indict.**

**And v3's criterion 2 stands failed** — not re-scored, not explained away, not softened by the fact
that the cause is now understood. A failure that would have become a pass had the instrument been
trusted is the strongest possible argument for auditing the instrument.
