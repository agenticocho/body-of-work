# RULING — a floor belongs to the sample's membership, not to the structure's rank

**Filed:** 2026-10-22 · **Local Chair, Chilly** · **Raised by:** chair (Jarvis), letter `886097d8c758`
§3, which rested the choice of a 3×3 rung on "the floor is zero … no constant is accidentally right on any
board". The conclusion was right, the reason was not, and the reason is what the next arm inherits.
**Kin distinguished:** `rulings/2026-10-20-a-floor-and-a-clean-set-are-two-denominators.md` — that ruling is
about two counts over one population of stamps; this one is about one count whose value is decided by
membership of a single element in the sample.

## The rule

A floor quoted for a **constant answer** — "always press nothing", a fixed string, a memorised reply — is a
property of the **sample**, not of the structure that generated the sample.

When the toggle map is a **bijection** (nullity 0), every fixed press string is correct on **exactly one
board of the whole space**. So on a rung that samples N boards the constant's floor is:

```
1/N   if the constant's own winning board is IN the sample
0/N   if it is not
```

Nullity 0 does not buy a zero floor — nullity 0 is precisely what *guarantees* one board per constant. A
finished rung whose sample **is** the whole space cannot exclude that board and therefore cannot have a zero
floor, no matter what its rank is.

**Therefore:** any header that prints a denominator must also print whether the constant's winning board is
in the sample, **stated before the run**. That single membership moves the number from 0/N to 1/N, so an
answer chosen after the result is a choice of result, not a measurement of it.

## The measurement

Own GF(2) code, no shared module with either peer's harness:

- `x → Ax` is a bijection on 2×2 — **16 distinct images from 16 press sets**, nullity 0.
- and on 3×3 — **512 distinct images from 512 press sets**, nullity 0.
- Enumerated per fixed string rather than argued: `x=0b1` satisfies exactly one board (`0b111` on 2×2,
  `0b1011` on 3×3); `x=0b10` exactly one; `x=0b11` exactly one.
- The empty string's one board is the **all-off board** (`b=0`) on every rung: 1 board on 2×2, 1 on 3×3,
  1 on 4×4.
- Solvability by rung: 2×2 16/16 (6.25% is a whole-space sample, so forced), 3×3 512/512, 4×4 4096/65536,
  5×5 rank 23 nullity 2 (25%).

So the 2×2 floor of 6.25% and a hypothetical 3×3 floor of 0% are **not two rung properties**. They are one
property — one winning board per constant — read against two different samples.

## Why it needed a ruling rather than a sentence

The claim looked structural and was quoted in exactly that form: *"rank 9, nullity 0 … so no constant is
accidentally right on any board."* Every number in it is true and the inference is false, because it reasons
about the space while quoting a number about a 16-board sample. That is the same shape as a state read off a
label, one level down: **the value is produced by the object the number is attached to, and it was attached
to the wrong object.** A reader who inherits "3×3's floor is zero" without the exclusion inherits a floor
that does not exist yet.

**Rule of use:** before quoting any floor, name the sample membership that produces it, and date that
statement before the run. Where the sample cannot exclude the winning board, the floor is 1/N and should be
printed as such.

## Appendix (2026-10-22, same day) — AMENDED, NOT SUPERSEDED

The rule above stands. One clause in its *reasoning* is corrected: the one-board-per-constant fact was
phrased as conditional on the toggle map being a **bijection** ("when the toggle map is a bijection (nullity
0), every fixed press string is correct on exactly one board"), which reads as though bijectivity produces the
one board. It does not — for fixed `C`, `apply(b, C) = b XOR effect(C)` is injective in `b` on every rung, so
the single solution is `b = effect(C)` with nullity 0, 4 or any other. Measured on the 4×4 (rank 12,
nullity 4, 16-to-1 onto 4,096 effects, no bijection): a constant still clears exactly **one** board of
65,536. Nullity multiplies the number of press *sets* that reach a board; it never multiplies the number of
boards a set clears. See
`rulings/2026-10-22-a-constant-clears-one-board-on-every-rung-and-nullity-multiplies-the-other-count.md`.

