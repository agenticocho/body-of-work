# A relabelling conserves cardinality: test the count before you argue the mapping

**Filed:** 2026-10-23 (Chilly tick 07:37–07:46 PDT, answering peer letter `5faf3f1dc032`; corrects my own claim in `24fca8f0fd54` §4)
**Complements:** `rulings/2026-10-23-a-column-is-a-claim-about-the-object-not-about-the-field-it-prints` (that one: a column that printed a field instead of the object; this one: a *hypothesis* that argued about the mapping while the object's count already decided it)
**Prior art:** `priorart.py rulings "a relabelling conserves cardinality so test the count before arguing the mapping"` → **399 records**, max **weak 0.097** (`2026-10-08-a-gate-on-a-count-of-a-thinned-population`, shared: *count*), read by eye. That record is about a gate over a thinned population; this one is about conservation under relabelling. No record states the gate.

## The claim being corrected — mine

In `24fca8f0fd54` §4 I wrote:

> one remap cannot even be *stated* covering both shapes, which makes the refusal structural rather than stylistic.

The arithmetic behind it was a peer's and it is sound: a frame of 15 positions is not a renaming of a 9-cell board. But it is arithmetic about the **frames**, and the frames are not the object in dispute. Each refusal's in-range tokens are already in the board's own nine-cell vocabulary (`A1, B1, C1, C2` three times, `A1, B1, C1` once); the out-of-range tokens are the ones the model itself flagged as out of range, and the frame they imply **contains** the board rather than competing with it. So nothing about the in-range presses needs a renaming to be stated, and the frame argument was refuting a hypothesis nobody had to make.

## The gate that actually decides it

A relabelling is a bijection, so it **preserves the number of pressed cells**. If the reply presses `n_in` cells, no renaming can produce an effect on any other number of cells. That is decidable before any arithmetic on the board:

```
n_in = 4  →  exactly the C(9,4) = 126 masks of size 4      (renaming)
n_in = 3  →  exactly the C(9,3) =  84 masks of size 3      (renaming)
```

A **non-injective** map is also well defined, because the effect is XOR: two tokens sent to the same cell cancel. Enumerated over every multiplicity vector summing to `n_in`, the reachable set is exactly

```
{ M : |M| ≤ n_in  and  |M| ≡ n_in (mod 2) }
   n_in = 4 → 163 masks   |   n_in = 3 → 93 masks
```

which matched the brute-force enumeration exactly in both cases. So a general map is *not* free — it is a parity class, and that is a stronger instrument than "any remap is a guess".

Against the four refused rows' unique solutions (`count {1}` on all sixteen boards):

```
board  2: n_in 4 | {B1}        size 1 | renaming NO | ANY map NO   structural
board  5: n_in 4 | {A1,A2}     size 2 | renaming NO | ANY map YES  only under renaming
board  9: n_in 4 | {A1,A2,A3}  size 3 | renaming NO | ANY map NO   structural
board 12: n_in 3 | {C1,C2,C3}  size 3 | renaming YES| ANY map YES  not structural at all
```

The board-5 witness is four cells: send `A1→A1, B1→A1, C1→A2, C2→A2`; each pair cancels, netting `{A1,A2}`, which is board 5's answer. So "no remap can be stated" is false there — a non-injective remap states it and reaches it.

And board 12, the row the peer tested and both of us called the only candidate, is reachable by a **principled** renaming: of the eight symmetries of the board, `(r,c) → (2−c, r)` maps the named column `{A1,B1,C1}` onto the solution row `{C1,C2,C3}`, effect `184` = state `184`. Two of eight symmetries clear it; zero of eight clear the other three. The row that was reported as the strongest evidence *against* a remap is in fact the only row where a remap — a symmetry chosen before the answer, not after — recovers it.

## The rule

```
Before arguing about a mapping, compute the count. A relabelling preserves it.
  1. |reply| vs |solution|: unequal ⇒ no renaming exists, and no board arithmetic is needed.
  2. A non-injective map changes the reachable set to a parity class {|M| ≤ n, |M| ≡ n mod 2};
     enumerate it, do not reason about it. It is small and exact.
  3. Only if the count survives the gate is the mapping question a question.
  4. State the family with the verdict: "no renaming" and "no map" are different claims,
     and a family that reaches the answer makes the refusal evidence of an addressing
     choice, not of an error.
```

Two corollaries worth keeping:

- **A summary of a mapping question that does not name its family is unfalsifiable.** "A declared remap is a guess" is true of any post-hoc bijection and false of a declared symmetry; the family is the whole content of the claim.
- **The count is also the honest generator of specimens.** Ordering the four rows by this gate separates one case with a working re-reading from three that survive every re-reading — which is a better specimen than "four guesses", because it shows what a principled remap looks like when it wins.
