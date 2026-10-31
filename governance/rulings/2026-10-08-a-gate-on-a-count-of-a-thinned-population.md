# 2026-10-08 — a gate on a count of a thinned population

**Authority:** Chilly (Local Chair). **Source:** a completeness gate that the field it gated could not
satisfy — not because the field performed badly, but because the field shrank. **Class:** a stand-in that
outlived the thing it stood for, in the instrument itself.

## The instance

A card declared ~46 entrants and carried a **completeness gate**: no verdict is issued unless **40 entrants
have been measured.** It was written into the card and frozen **before the run**.

The field then did what this project predicted it would do — the largest entrants failed to load. Its final
shape:

```
46  EXPECTED        entrants the card declares
42  UNIQUE attempt  entrants with at least one bundle
50  BUNDLE FILES    copies on disk (8 are re-runs of entrants that emptied)
34  MEASURED        unique entrants with non-empty results
 4  NEVER RUN       declared, no bundle
```

**Ceiling = 34 measured + 4 never-run = 38.** The gate requires **40**.

> **The verdict is not callable. Not a FAIL, not a PASS, not "indeterminate" — UNSCOREABLE, and
> arithmetically so, before any criterion is read.**

## Why this is a result and not a moved bar

**Three checkable conditions, and all three hold:**

1. **The gate predates the run** — frozen in the card at a named commit, not selected after the count was
   known.
2. **The ceiling is computed from the artifacts** — *measured + remaining* — not argued.
3. **The remedy was stated before the number was known**: *a population that can run, not a relaxation of
   the bar.* That sentence was already in the card **and in the evaluator**, printed with the refusal.

**An unsatisfiable gate is a fact about the gate.** Lowering it after the fact is the one move that would
make the outcome worthless, and it is the move that a count-shaped gate invites.

## The ruling

**1. A gate on an absolute COUNT of a thinned population has satisfiability that depends on the thinning.**

A threshold of the form **"N entrants must be measured"** is a claim about the field staying large enough.
**A threshold expressed as a FRACTION of the field that ran is not** — it normalises over exactly the
population that exists.

**So the two diverge precisely where the population breaks**, which is **precisely where a completeness gate
is needed.** A count-shaped gate is therefore least able to do its job in the situation it was written for.

**2. The stand-in outlived the thing it stood for.**

*"40 measured"* was never the requirement. It was a **proxy for "the field is complete enough to judge."**
Chosen when a complete field was assumed, it **became the requirement itself** — and then failed to detect
the one condition it existed to detect.

**Same family as `_EMPTY_` in a filename and an alias naming a retired model** — an artifact that outlives
its referent and keeps answering. **The only new thing here is the location: this time it is in the
INSTRUMENT rather than in the record.**

**3. The next card states its floor as a fraction of the field that ran, and names its denominators.**

Because this run produced **four numbers where the documents said one**:

    46 expected · 42 unique attempted · 50 bundle files · 34 measured

**Any one of those is "the field" in a sentence, and the four differ by 16.** A count is a fragment until it
carries the set it counts — and a gate is **a count in a conditional**, which is the most damaging place to
leave the set unstated.

## The part that is the design working

The evaluator already says, in its own refusal:

> *The criteria above are computed for diagnostics only. Calling a verdict on a partial field is how v3's
> verdict became conditional on the scope of its own correction.*

**So the refusal is not a failure of the instrument — it is the instrument behaving as built.** The honest
output is therefore **the diagnostic with its scope attached**: C1 PASS (4 of 6 in band) · C2 FAIL (3 below
0.34) · C3 FAIL by construction · C4 PASS, with

> **FAILED ON THIS POPULATION, AND THE POPULATION IS A CANDIDATE CAUSE THIS FIELD CANNOT RULE OUT.**

**And the population is no longer a footnote — it is the only thing the verdict can be about.**
