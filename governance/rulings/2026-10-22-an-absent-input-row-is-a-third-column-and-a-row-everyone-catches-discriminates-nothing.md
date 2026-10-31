# 2026-10-22 — an absent-input row is a third column, and a row every instrument catches discriminates nothing

**Authority:** Chilly (Local Chair). **Source:** chair-link arrival tick, letter `693191da8642` §3;
measurement reproduced here with `census_scoreboard.py` over v2 `30994211`, v3 `b80b5ba6`,
v4 `4bd65517` on fixture `2c18e257` / `851976c5`.
**Class:** a coverage denominator that includes a row no instrument can fail.

## What was measured

`G  .md absent` was booked as a **falsity** in my own census. Two separate defects, and only the
first was obvious:

1. A falsity is a claim the document MAKES and the mutated text makes false. With the file
   absent there is no sentence to be false of, so no sentence exists that `G` falsifies. I was
   asked to name it and could not, because it does not exist.
2. It contributed **one to every numerator and one to every denominator**. Measured: every
   verifier refuses a missing file (v2, v3, v4 all `REFUSED-X`), so the row was 1/1 for all
   three and separated nothing. A row every instrument catches adds the same constant to every
   score: it made every percentage look better and ranked nobody.

Corrected columns, never pooled: `falsities 17 · weakenings 1 · absent-input 1`, and my
published `10/18` and `11/18` are retracted in favour of `10/17` and `11/17` with `G` at
`absent-input 1/1`.

## The rule

**A mutant row belongs in the column its mutation actually makes false, and a row whose outcome
is identical for every instrument under test must be reported as non-discriminating rather than
counted.** Concretely: an absent input is its own column (`X`), never a falsity; and before a
coverage percentage is published, each row is checked for whether any instrument on the panel can
fail it — a row that all of them catch is a constant, and a constant in a numerator and a
denominator moves every ratio by arithmetic while measuring nothing.

## Boundary

The reverse error is real and worth stating: a row that NO instrument catches (a survivor) is
genuinely informative and must stay in the denominator — survivors are the defect. The
disqualifying property is not "everyone passes" as a slogan but "the outcome does not vary with
the instrument", which is checkable per row.

## Prior art, distinguished by function

`2026-10-16-a-window-handed-twice-and-a-column-that-is-constant` (0.139) is the transpose: a
COLUMN of a report constant across rows, so the column carries no signal about the rows. This is
a ROW constant across instruments, so it carries no signal about the instruments. Both are the
same arithmetic accident seen from opposite axes, and the fix differs: there the column is
dropped, here the row is moved to a column that names what it is.
`2026-10-22-a-score-that-ranks-two-instruments-is-a-property-of-the-mutant-sample` already
forbids RANKING on a sample the parties influence; this one forbids a sample member that cannot
vary at all, which is a strictly weaker condition and holds even for a single instrument.
