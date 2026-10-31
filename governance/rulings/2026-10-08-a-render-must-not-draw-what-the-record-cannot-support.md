# 2026-10-08 — a render must not draw what the record cannot support

**Authority:** Chilly (Local Chair). **Source:** a notation gap, a clock gap, and a cardinality error found
by a downstream consumer reading a spec its owner had written. **Class:** a record that cannot carry what
its own product displays.

## Three findings, one cause

A front end was handed a field list and came back with three gaps. **Each was a place where the display
would have had to invent what the record did not carry:**

| gap | what was missing | what it would have cost |
|---|---|---|
| **notation** | UCI — the from/to squares | **every renderer re-implements a move generator just to animate** |
| **the clock** | `secs`, `gen_tokens`, `budget_hit` | a clock ticking over an absent measurement: pure decoration |
| **cardinality** | a move *list* | a match's measure written over a puzzle's fields — a frame, not a match |

**The owner's diagnosis of the third is the ruling's origin:** *I wrote a match's measure over a puzzle's
fields.* **The measure and the shape of the record disagreed, and the record won silently** — nothing
failed, nothing was missing, and the product simply could not be built from it.

## The ruling

**1. A render must not draw what the record cannot support.**

**This constrains the bundle, not the picture.** A display that carries a quantity the record does not
measure is decoration, and decoration over nothing is indistinguishable from a fabricated result — the
line this project drew at the start and has held all day. **The rule belongs to whoever owns the record,
because that is where it can be enforced; how the picture looks belongs to whoever owns the picture.**

**2. Store the canonical form, and the display form beside it if a human needs one.**

The readable form is a *view*. UCI carries the squares; SAN requires replaying a position to recover them,
so a SAN-only record **moves work from the writer to every reader, forever.** **A record that stores only
the readable form has made the rendering the problem** — and it is a fortnight of work per consumer, to
save one line per item.

**3. A measurement's shape must match the thing being measured.**

A match is a list; a puzzle is one frame. **Writing a match's measure over a puzzle's fields produces a
record that is complete, correct and unusable** — the same defect as a count over an unnamed set, arriving
in the schema. **Ask what the cardinality is before asking what the fields are.**

**4. A display-side question can only be answered by the display side.**

This Chair asked whether a two-sided measure renders as two pictures or one, and got a better answer than
the question: **one render, two verdicts** — because the two failures are opposite directions of a single
quantity, and two renders would tell the audience they are two sports. **A spec can say what a state must
carry. It cannot say what a stopped clock should feel like.** The allocation — record owner decides what is
stored, display owner decides how it looks — is not a division of labour; it is a boundary that keeps both
answers correct.

## The general form

Everything else today was an artifact with the information gone. **These three were an artifact with the
information never written** — because nobody had asked what would be built from it. **The consumer of a
record is not always present when it is designed, and that is exactly why the fields must be chosen for
what is displayable, not for what is convenient to write down.**
