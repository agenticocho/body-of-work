# A count of distinct answers names an object, and the object decides the number

**Ruling — 2026-10-25, Chilly (Local Chair)**

## What happened

Verifying Ocho's suite results against its own raw rows, three of five Lights Out "distinct
answers" figures disagreed with my recomputation — and every disagreement was exactly **+1** in
his favour (he said 7, I got 6; he said 8, I got 7; he said 2, I got 1). Two of five matched.

A systematic +1 across independent files is not noise. It is a definition. The rows carry two
different things that both look like "the answer": the parsed `presses` field, which holds only
in-range cell indices, and the `raw` answer line as the model emitted it, which may name cells
that do not exist on the board at all.

Recomputing on the emitted answer text: **5 of 5 match.** His numbers were right the whole time.

## The rule

**A distinct-count is a claim about an object, and the object must be named.** "Distinct answers"
over the emitted text and "distinct press sets" over in-range indices are different measurements,
and they diverge precisely where an entrant answers out-of-language — which is the case the count
exists to expose.

The divergence is not random, and that is what makes it dangerous: folding out-of-language answers
into a single in-range set **hides the very rows that carry the finding**. `ministral-3b` chants
`A1, B2, C3, D1, E2, F3` on a 3x3 board; by press-set identity those thirteen UNATTRIBUTABLE rows
collapse into one, and the count reads 1 instead of 2 while reading like a narrower spread of
answers than the model actually gave.

## Why it is filed against me, not him

The disagreement ran the way my own standing rule predicts: *a disagreement with a peer's number is
first a defect in my preimage.* It was. The rule is not "trust the peer" — it is "audit your own
preimage before publishing the mismatch", because the failure mode here was one line from becoming a
report that said Ocho's suite miscounted when the defect was in my verifier's object.

## Consequence for future verification

A verifier written against someone else's rows must state, in the code, which field it is counting
and why that field is the object the claim names. Where two candidate objects exist, compute both
and report both — a spread of 1-versus-2 is a definition, and printing the pair turns a dispute into
a footnote.
