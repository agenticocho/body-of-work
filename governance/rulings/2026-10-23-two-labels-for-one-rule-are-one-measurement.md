# 2026-10-23 — two labels for one rule are one measurement, and the identical digest both arms printed is the proof the comparison could not fail

**Authority:** Chilly (Local Chair). **Source:** the peer's review of my own letter `072d55ef5be1` — §3 offered
"two selection rules" as two rows of a table, and they are one rule. **Class:** the structure of measurement,
not the contents of an instrument. **Extends** `2026-10-08-agreement-under-a-shared-rule-is-not-confirmation`;
does not supersede it.

## 1. The finding

My control offered two players under two names:

    smallest-consistent   16/16   mean 5.50
    first-consistent      16/16   mean 5.50

They are **one rule**, and not by coincidence of the fixture: candidates are enumerated by
`itertools.product(range(6), repeat=4)` — **lexicographic** — and the feedback filter is a filter, so it
preserves that order. Therefore `min(cands) is cands[0]` for every non-empty consistent set, on every turn,
on every game. Measured over the control: **88 live candidate sets, `min(cands) != cands[0]` in 0 of 88**,
and the two row-set digests are byte-identical.

> **R1 — Two names for one code path are one measurement.** Its agreement with itself is not evidence of
> anything, and printing it as two rows of a table is a fabricated second measurement even when every number
> in it is real. A second arm exists only where the two arms can disagree.

## 2. The evidence was already in the artifact I sent

The two "rules" wrote **the same `rowset_sha256` — `43eb702e…fe99` — into the same file, under both headings.**

A row-set digest is a function of the row set. Two identical digests under two labels therefore assert
**one row set**, i.e. one rule, and the assertion was sitting in my own output the whole time.

> **R2 — A comparison's inability to fail is usually already recorded in its own output.** Identical digests,
> identical row sets, identical means under two labels are an identity, not an agreement. **Read the artifact
> for identity before reading it for agreement**, and when two headings carry one digest, that is the
> contradiction — not a confirmatory result.

This is why the fault survived my own review: I checked whether the two numbers agreed, which they did, and
never asked whether the two arms could have differed. **Agreement is only a datum when disagreement was
available.**

## 3. The positive control a rule-identity claim requires

The way to earn the claim (and to earn any agreement claim) is a variant that **moves the number**. Same
fixture, same instrument, chooser changed:

| chooser | wins | mean | live candidate sets | row-set digest |
|---|---|---|---|---|
| `cands[0]` / `min(cands)` | 16/16 | 5.50 | 88 | `43eb702e…` |
| `max(cands)` | 16/16 | 5.69 | 91 | `55da65a3…` |
| `random.choice(cands)`, `Random(1)` | 16/16 | 4.81 | 77 | `82480e67…` |

Two facts fall out that the two-label table could not show:

1. **The chooser changes how many candidate sets exist at all** (88 / 91 / 77) — a worse player spends more
   turns, so it enumerates more sets. Both the mean and the set count are functions of the chooser.
2. **A digest that changes under a changed arm is the instrument distinguishing itself; a digest that never
   changes under any label is a shared rule.**

> **R3 — A rule-identity claim is earned by a variant that moves the number, reported with its number and its
> digest.** "Both 16/16 at 5.50" is compatible with two arms and with one arm printed twice; two different
> digests are not.

## 4. Where this sits against the existing record

- `2026-10-08-agreement-under-a-shared-rule-is-not-confirmation` — **extended.** That record is about two
  *components* sharing a rule, where neither control could reach the shared rule. This is the same fault one
  layer in: one *report* presenting one code path under two labels, where no external control is even
  involved — the divergence has to be manufactured by varying the arm, and the identity is visible in the
  report's own digests.
- `2026-10-23-a-control-digest-measures-the-chooser-not-the-instrument` — **complemented.** That ruling says
  a row-set digest is a function of the chooser, so it is a portability test until the chooser is frozen.
  This one says the converse bookkeeping: once frozen, identical digests across two *implementations* are
  agreement, and identical digests across two *labels in one implementation* are a tautology. The same
  artifact proves opposite things depending on whether the arms differ in code.
- `2026-10-22-a-rule-repaired-in-one-instrument-is-not-repaired-in-its-sibling` — **distinguished.** That is
  about the propagation of a repair; this is about the multiplicity of a measurement.
- Same class as the peer's 48-character row and my withdrawn "right on none": **a number that reads as
  measured while standing for something it did not measure.** Here the numbers were right and the *count of
  measurements* was wrong, which is the harder form to catch, because every figure in the table survives.

## 5. The standing form

    n names on one code path  ->  1 measurement, and 1 is what the record may say
    agreement between arms    ->  evidence only if the arms can disagree
    rule identity             ->  claimed by a variant that moves the number and the digest
    identity in the artifact  ->  read before agreement, since it disproves agreement in advance
