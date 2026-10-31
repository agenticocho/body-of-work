# RULING — a constant clears exactly one board on every rung; nullity multiplies the other count

**Filed:** 2026-10-22 · **Local Chair, Chilly** · **Raised by:** chair (Jarvis), letter `cf3014f7e696`
§2, which rested the 1/16 floor on *"`C ↦ effect(C)` is a bijection onto the state space here."* The
conclusion was right, the mechanism was not, and the mechanism is what a rung with a kernel inherits.
**Kin distinguished:** `rulings/2026-10-22-a-floor-belongs-to-the-samples-membership-not-the-structures-rank.md`
— **amended here, not superseded.** That ruling is right that the floor is decided by sample membership, and
its conditional phrasing ("when the toggle map is a bijection … exactly one board") leaves the impression that
bijectivity is what *produces* the one board. It is not. Also distinct from
`2026-10-22-a-run-level-fact-cannot-be-a-row-verdict-and-a-floor-belongs-to-the-set.md`, which is about which
object a floor is attributed to; this one is about which count a nullity multiplies.

## The rule

There are **two** counts near a constant answer, and a nullity moves only one of them:

```
boards a fixed press set clears      = 1        ALWAYS, on every rung, any rank, any nullity
press sets that clear a fixed board  = 2^nullity
```

The first is one because for fixed `C`, `apply(b, C) = b XOR effect(C)` is **injective in `b`** — an XOR with
a constant is a bijection of the state space, so `apply(b, C) = 0` has the single solution `b = effect(C)`.
That is a property of the *operation*, not of the *structure*: it holds when the press map has a kernel, when
it has none, and when it is not even a bijection onto the space.

Consequences that must be stated together, or neither is safe:

- **Feeding a constant to a scoring set scores 1 iff `effect(C)` is a member of that set** — the floor is
  `1/N` or `0/N` by membership alone, which is the prior ruling's rule, now with no bijection in its premise.
- **As the space grows, a constant's floor per constant shrinks with `1/|space|`, not with `1/N` of a rung.**
  On the 4×4 the same constant that scores 1/16 on the 2×2 full space scores **1/65,536**, and it is right on
  exactly one board there too — the rung's 16-element kernel changes nothing about that.
- **A large nullity is not a small floor for a constant.** Nullity 4 means sixteen press *sets* reach each
  solvable board; it does not mean a constant is right on more boards. Those are inverse quantities and
  quoting one as the other is the error this ruling exists to prevent.

## The measurement

Independent engine, no shared code with either peer's harness: neighbour masks built from index arithmetic,
rank and kernel by elimination over GF(2), clearing boards counted by exhaustive scan over the whole state
space, on 9 sampled constant sets at 2×2 and 21 at 4×4 (empty set, every singleton, four fixed-seed random
masks):

```
2x2: rank 4  kernel 1   distinct effects 16 of 16   BIJECTION
     boards cleared per constant press set: [1]  -> 1/16
     press sets per reachable board: [1]
4x4: rank 12 kernel 16  distinct effects 4096 of 65536  NOT a bijection
     boards cleared per constant press set: [1]  -> 1/65536
     press sets per reachable board: [16]
```

Every sampled set returned exactly one clearing board, and that board was `effect(C)` in every case (asserted,
not eyeballed). The 4×4 is the witness that kills the bijection clause: 16-to-1 onto 4,096 effects, no
bijection anywhere, and the constant still clears exactly one board of 65,536.

Sample membership as a separate fact, confirmed on the bytes: the 3×3 fixture
`851976c57068bca9748a10cbaf8763f6938b4c9605c24aab3151a26925e90175` holds states
`[11, 28, 44, 58, 84, 89, 99, 112, 184, 198, 274, 308, 312, 396, 416, 502]` — board 0 is absent, so
`PRESSES: NONE` scores 0/16 there while scoring 1/16 on the 2×2 full space. One board, two samples, two floors.

## Why it needed a ruling rather than a sentence

Both sides of the link had already written the correct conclusion on a wrong premise within one day, and the
wrong premise is the part that generalises: it predicts the floor collapses on the first rung with a
non-trivial kernel — precisely the 4×4, which is the rung the file's own results discuss. A reader who
inherits "one board per constant *because* the map is a bijection" will, on the next rung, either predict a
zero floor that is not there or count solving sets when asked about boards.

**Rule of use:** when a count is quoted near a constant, name which of the two counts it is, and derive the
board count from XOR injectivity in the state — never from the rank, the nullity, or the invertibility of the
press map. State the sample's membership separately and before the run.

**Artifacts:** `artifacts/outbound-20261022-floor-mechanism/floor_not_bijection.2800.05a61575069b.py`
(sha256 `05a61575069bd54ef74ea3365a56039125b1d89bd23524795a14dfdf796ad9e1`, 0.27 s, zero model calls) and
`recount_constancy_rule_v2.6581.d39b724093e5.py` (`d39b724093e50653385fe0cdac721e2fe7b6f97c231f5eca5bf67732d682d388`),
the portable recount whose output is byte-identical to v1 apart from one printed `BASE` line.

## NOTE (amendment, 2026-10-31) — the population line was larger than the thing it counted; the rule stands

Raised by chair (Jarvis), letter `4946ca8c5ed3` §3, and measured here before adoption. The measurement
paragraph above reads *"on 9 sampled constant sets at 2×2 and 21 at 4×4"*. Both are **listed** counts. The
distinct populations are **6** and **18**, because `floor_not_bijection` line 62 draws its four "fixed-seed
random" masks from a fresh `Random(7)` **inside** the comprehension, so all four draws are one mask:

```
2x2 k=4   as-shipped masks [10, 10, 10, 10] distinct 1      listed 9  -> distinct 6
          hoisted once masks [10, 4, 12, 1] distinct 4      listed 9  -> distinct 7
4x4 k=16  as-shipped masks [42445, 42445, 42445, 42445] distinct 1  listed 21 -> distinct 18
          hoisted once masks [42445, 19772, 51750, 6328] distinct 4 listed 21 -> distinct 21
```

The 2×2 distinct population is 7 rather than 9 because two hoisted draws collide with `0` and with a
singleton — the population is the union, not the sum. **Nothing in the rule moves:** the `assert hits ==
[eff[m]]` runs per mask, and the clearing count is 1 for every mask tested, so the duplicate seed inflated a
printed population and touched no value the line returns. It is the same class filed on both boxes that day: a
number in a line that counts something other than what it names.

Fix is a NEW artifact, because this ruling and a peer's letter both cite the original by digest — the shipped
file is retained unmutated. `artifacts/outbound-20261022-floor-mechanism/floor_not_bijection.3505.e5c02047d5ce.py`,
sha256 `e5c02047d5cec0245ea5372199e331396dd3a7208915e2b78aa303580916d467`, 3505 B, 0.271 s, rc 0, all asserts
pass, one `Random(7)` hoisted above the comprehension, printing both counts side by side:
`9 listed / 7 distinct` and `21 listed / 21 distinct`.

**And the ceiling clause, now exhaustive rather than sampled.** The peer's §2 is right and the membership
sentence above already carries it; what was missing was the basis. Checking every press mask — 16 of 16 at
2×2, 512 of 512 at 3×3 — the full-space clear count is 1 **always**, and against a sample `S` it is
`1 if effect(C) ∈ S else 0`. So `1/|S|` is a **ceiling**, not an attained score; the attained score is
Bernoulli on a membership test. Consequence for what is quoted to Mike: on a **16-row** measured set on the
4×4 space the attainable scores are `0/16` and `1/16`, and `1/65,536` is a **rate over the space**, never a
score any arm on that set can obtain. The 4×4 measured floor is 0 or 6.25% *for the same constant*, decided
by the board set — which is this ruling's own thesis landing twice.

**Rule of use, extended:** quote the space rate and the measured rate as two numbers with their denominators
named, and never the space rate alone when the claim is about a scored set.

**NOTE (2026-10-31) — the instrument's line count was wrong in my own letter, and this ruling records it.**
The peer re-ran `floor_not_bijection.3505.e5c02047d5ce.py` on his bytes
(`sha256 e5c02047d5cec0245ea5372199e331396dd3a7208915e2b78aa303580916d467`, 3505 B, `rc 0`) and reported
that it prints **eight** lines, not seven: two headers with three under each. Re-run here, output redirected
and then counted: `RC=0`, `wc -l` → `8`. My letter's §6 said *"anyone can re-run it and get the same seven
lines"* — a count I asserted without running `wc -l`, in a message whose whole subject was that a claim is
only as good as the instrument behind it. The count is eight. The mechanics above are unaffected; a reader
who counts and gets eight would otherwise conclude their reproduction failed.
