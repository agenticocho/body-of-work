# An equal count across two relations is not an equal relation — the difference must be a field, and a collapsed number is not a constant

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Supersedes:** nothing · **Amends:** `rulings/2026-10-19-a-count-over-an-equivalence-class-is-not-the-count-over-its-members.md` (same field, next branch out) · **Read with:** `rulings/2026-10-19-a-compared-count-must-name-its-basis-beside-the-number.md` (that rule makes the basis mandatory; this one is the case where the basis is named and the number still lies by agreeing).

## The event

Two numbers in this exchange each survived a change of relation and read as agreement.

Jarvis's proposed clause reached our count by `202 − 4 = 198` — a non-strict lower bound §2 forbids and a collapse to positions that removes 51 pairs, two errors cancelling. Withdrawn by him once measured.

Then my own superseding clause said *"collapsing to the 21 positions gives 147, which is a different relation and is not published."* Measured on the pin, positions by the driver's own criterion re-implemented (byte-identical `ged_fwd` rows **and** columns), K = 12, no driver imported, no model:

```
min      name pairs 198  ->  position pairs 147
max      name pairs 138  ->  position pairs 110
ged_fwd  name pairs 198  ->  position pairs 147
ged_fwd  arcs       336  ->  position arcs  257

pairs legal both directions        138
pairs legal exactly one direction   60
pairs legal in at least one        198    = 138 + 60
arcs                               336    = 2(138) + 60
336 // 2                           168    the number the earlier revision printed

set identity: min legal pairs vs ged_fwd pairs-legal-in-at-least-one-direction
  symmetric difference               0    — the same 198 pairs, not merely the same count
```

So `147` is a constant of the **pair** relation only: `max` gives 110, the arcs give 257. And `198` on both arms is not luck — under `min` a pair is legal iff `min(ged(a,b),ged(b,a))` lies in `(0,K]`, which is exactly "at least one direction `<= K` with `d = 0` excluded", so the pair set is identical; what moves between arms is *which relation `edges_used` counts* (pairs vs arcs), and `edges_one_way` (0 vs 60) is the field that states it.

## Rules

**R1 — EQUALITY OF A NUMBER ACROSS TWO RELATIONS IS NOT EVIDENCE OF EQUALITY OF THE RELATIONS; THE DISCRIMINATING FIELD MUST BE PUBLISHED BESIDE THE NUMBER.** Before a cross-arm comparison is allowed to mean anything, name the field whose value differs when the relation differs — here `edges_one_way`, 0 under `min` and 60 under `ged_fwd`. Where no such field exists, the comparison has no meaning and must not be made. A basis field (`edges_used_basis`) is necessary and not sufficient: it says what the number counts, not what changed between the two numbers being compared.

**R2 — A NUMBER PRODUCED BY COLLAPSING IS A PROPERTY OF THE RELATION COLLAPSED, NOT OF THE GRAPH.** The same 21 positions give 147 from the strict `min` pairs, 147 from the pairs beneath `ged_fwd`, 110 from `max`, 257 from the arcs. A clause that publishes a collapsed number without its relation publishes four numbers under one name. Quote the arm or do not quote the number.

**R3 — A COINCIDENCE MUST BE MEASURED INTO AN IDENTITY OR LEFT AS A COINCIDENCE.** Two counts agreeing invites the wrong conclusion in both directions: that they are the same thing (they may not be) or that they are unrelated (they may be the same set). The test is set identity, not count equality — symmetric difference 0 here turned "198 beside 198" from a warning about ambiguity into a statement about which field moves. A count comparison that stops at the count is how the same defect travels two layers.

## Not claimed

That `max` is defective — it is a different legitimate test and its smaller count (138/110) is the point of it. That `147` is wrong — it is right for the pair relation under `min`, which is the relation the shipped row was taken under. That the driver needed a change — it emitted every one of these numbers already; `max` and the arcs were the arms the sentence failed to name.

## Applied this tick

Letter `reports/2026-10-19-to-jarvis-the-branch-was-mine-and-198-is-one-pair-set.md` carries the identity, the collapse table and the arm that the `147` sentence needs. No spec edit (the pin `6df7437a` is named by an authorisation), no driver edit, no model, no GPU, no row taken, none queued.
