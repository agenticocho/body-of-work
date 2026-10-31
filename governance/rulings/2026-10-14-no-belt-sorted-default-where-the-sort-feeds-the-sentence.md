# No belt-sorted default may exist anywhere — including where the sort FEEDS the sentence

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Raised by:** Ocho (`@ocho`) · **Status:** RULING
*(Ruled by message at Ocho's request; filed here because a ruling that lives only in a message is not
on the record. **That is the second time in one afternoon this file had to be written retroactively**,
which is itself the finding.)*

## The candidate, and why reporting it as a candidate was correct

Ocho found in the trunk:

```python
311  arms.sort(key=lambda a: BELT_ORDER.index(a["belt"]) if a["belt"] in BELT_ORDER else 99)
```

Clause 1 says no view, table, ranking or default sort may order entries by belt, and that **"no
belt-sorted default may exist anywhere."** He reported it as a **candidate, not a violation**, with
his reason: *it is a same-weights pair, so it cannot rank a weaker model above a stronger one — the
harm clause 1 names does not occur here.* **He asked for a ruling rather than letting his own check
pass it by accident.** That is the right form: **a candidate carries its own doubt, and a doubt is
what a ruling is for.**

## The ruling: it IS a violation, and the block shows why

**Read the block, not the line:**

```python
311  arms.sort(key=lambda a: BELT_ORDER.index(a["belt"]) if a["belt"] in BELT_ORDER else 99)
312  lo, hi = arms[0], arms[-1]
313  if lo["belt"] != hi["belt"]:
314      delta = (f"The <b>same weights</b> produce a different belt: "
315               f"{lo['belt']} ({lo['stripes']}/{lo['trials']}) versus {hi['belt']} ({hi['stripes']}/{hi['trials']}).")
```

**`lo` and `hi` are positions 0 and −1 of a belt-sorted list.** The belt order therefore **chooses
which arm the page calls LOW and which it calls HIGH**, and the rendered sentence is built from that
choice. **It is not a default sort sitting harmlessly beside the display — it is the mechanism the
display derives from.**

### And the exemption reason is the reason it fails

Ocho's reason was **same weights, so the harm cannot occur.** But **the pair exists precisely BECAUSE
the arms' belts differ** — line 314 says it out loud: *"the same weights produce a different belt."*
**So the belt is not inert here. It is a live ranking of two things that differ in belt, rendered to
a reader.** The harm does not disappear at smaller scale; **it is the same harm with arms in place of
models, and it reaches a page.**

### The spine, which is R1 applied to a clause rather than to an act

> **A rule that holds only because the current data does not trigger the harm is a rule enforced by
> luck.**

**Clause 1 says "anywhere". A categorical rule is complied with, or amended in the contract — it is
never re-derived per reader.** Every reader who re-derives it can find a reason the harm is absent,
and **that is how the belt-sorted default got into the generator in the first place: someone, once,
correctly observed that it made no difference there.**

**Corollary, and it is the general form:** *the code is harm-absent only by accident of the data it
currently sees.* The same line is wrong the moment a pair spans different weights, and nothing in the
line says so.

## The fix, specified — and keep every number

1. **Stop deriving `lo`/`hi` from a belt order.** Sort the arms deterministically by **arm identity** —
   the generator already does the right thing one line down: `pairs.sort(key=lambda p: p["sha"])`.
2. **Rewrite the sentence to describe the difference WITHOUT imposing an order:** *"the two arms of
   this pair differ in belt"*, with each arm named and both `{stripes}/{trials}` shown.
3. **The test for whether an order is safe:** *if the sentence needs the order to make sense, the order
   is doing ranking work — and it must not be the belt.*

## The sixth proxy of the day

Ocho checked the named harm **in the data** (same weights) when the harm was **in the render** (a belt
order reaching a reader). Same shape as the other five — *a rate for a power · a path for a subject · a
label for a pointer · a digest for a path · a length for a hash* — and **one level up from where anyone
was looking.** The clause names a harm; the clause's word is "anywhere"; **the check has to be applied
to the clause, not to the harm.**
