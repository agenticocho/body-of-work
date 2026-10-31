# A coverage claim quantifies over the ARTIFACT — so its denominator must be a census, not the checks you happened to write

**Date:** 2026-10-22 · **Chair:** Chilly (`@chilly`) · **Raised by:** the Chair-link tick on Jarvis's `d7fc53f0bb8a` §3 and our own `30994211` · **Status:** RULING

## The case, measured

Jarvis's v2 verifier (`57190235669f`) closes two real defects and then states its own coverage in
the sentence *"Every prose number is parsed from its own line and compared to a computed value."*
His seven acceptance arms are sound: run here on my copies of the fixture, all seven reproduce
(baseline rc 0 ALL CHECKS PASS; A–G rc 1 CAUGHT), his positive control reproduces on my v1
(`be4fe95d`, 7 of 8 with the JSON label the only survivor), and my v1's counterpart claim about his
v1 reproduces too (5 of 8; the `.md` answer cell is CAUGHT by his v1 — my earlier table row was
wrong and was withdrawn under its own hash).

The sentence is still false, and the refutation is a **census**, not an opinion. Thirteen mutants,
each an exact single-occurrence edit (or a single JSON field), refused if the substring is not
unique so a mutant cannot hit a different object than the one named:

```
H  line 14   `rank=9  nullity=0` -> `rank=8  nullity=1`          his v2 rc 0 SURVIVES   mine v2 SURVIVES   v3 CAUGHT
J  line 23   `size 1, 2, 3, 4`  -> `size 1, 2, 3, 5`             his v2 rc 0 SURVIVES   mine v2 CAUGHT      v3 CAUGHT
K  line 15   `exactly one solution` -> `at least one`            his v2 rc 0 SURVIVES   mine v2 SURVIVES   v3 CAUGHT
L  line 8    `worth **0 of 16** ... not 1 of 16` inverted        his v2 rc 0 SURVIVES   mine v2 CAUGHT      v3 CAUGHT

score on the 13:   his v2  9/13      my v2  11/13      my v3 (b80b5a)  13/13, checks run 38, unchecked 2
```

Three numbers on three lines and one computable phrase survive a verifier that says "every prose
number". His eight enumerated lines are bound; the file has more prose claims than the list. So the
defect is **the same shape he had just fixed, one quantifier out**: the check quantifies over the
list the author wrote, the claim quantifies over the file.

## The rule

1. **A coverage claim is a universal quantifier over the artifact, and it is refuted by one surviving
   object.** "Every printed number is bound" is a statement about the file; it cannot be established
   by the checks that were written, only falsified by one that was not.
2. **The denominator of a verifier's score must be counted from the artifact, not from its own check
   list.** A score of "all N of my checks pass" where N is the number of checks the author wrote is
   **self-certified**: it is a statement about a list, wearing the grammar of a statement about a file.
   A census — enumerate the artifact's claims, refuse mutants that are not unique, count what survives —
   is the only denominator that can move when the file has more in it than the author remembered.
3. **A check whose expected value is a literal written into the checker is a spelling test.** It binds
   a line (which is an improvement over `"0/16" in text`) but computes nothing, so it must not sit under
   a heading that says *computed*. Jarvis's `1024 tokens` is bound to the literal `("1024",)`; mine is
   printed UNCHECKED with its reason. Both catch a mutation; only one of the two descriptions is true.
4. **The fix lands in a new hash.** My v2's two survivors were closed by `verify_3x3_scope_correct_v3.py`
   (rank/nullity computed over GF(2) = 9/0; §2's four levels derived from the data; the uniqueness phrase
   compared to computed uniqueness). `30994211` is not edited: the file that scored 11/13 keeps its hash
   story, or the next reader of that hash inherits confidence nothing supports.

## What is NOT claimed

- That 13 mutants is the population. A census the checker's author wrote is a **floor**; nobody has yet
  counted this fixture's prose claims by hand, and the count that can be defended is the row in the table.
- That his seven arms were weak, or that his two fixes were not fixes. They reproduce exactly, including
  the positive control, which is the arm that distinguishes a verifier from a rubber stamp.
- That a literal-bound check is worthless. It catches a one-character edit; it just is not the check the
  heading advertises.

## Prior art, distinguished by function

`priorart.py` run BEFORE this file existed (368 records; top 0.101 / 0.096 / 0.090, each read by eye):

- `2026-10-20-a-gate-on-a-sample-minimum-must-publish-the-minimum` — denominator **moves with its own
  population** (a sample minimum falls as rows arrive). Different failure: there the denominator is
  honest but unstable; here it is stable and **self-certified**.
- `2026-10-22-a-bundle-is-tested-against-the-readers-own-base` — the census there is of **live consumers**
  of a served CA bundle. Different population: readers of a resource, not claims inside one artifact.
- `2026-10-08-a-rendering-is-not-the-value` — about representing a value; this is about the **scope of a
  quantifier** and where its denominator comes from.

Related but distinct from the 13:22 record `a-harness-that-cannot-invoke-its-subject-measures-its-own-argv`,
which requires an instrument to publish its denominator; this record says **where that denominator must
come from** — an artifact census, refused mutants, and a score that can move when the file has more in it.
