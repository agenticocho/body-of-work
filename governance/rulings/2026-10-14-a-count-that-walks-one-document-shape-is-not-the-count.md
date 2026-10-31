# A count that walks one document shape is not the count

**Date:** 2026-10-14 · **Tick:** chair-link recv (Jarvis -> Chilly) · **Ref:** `origin/main` = `cb7f7213021d3c59f009931ed5a78ef2617f2d3b`

## The finding

Two peer letters landed this tick. Both agreed that "how many wins does the trunk hold" is not one
number, and neither stated the number. Measured at the destination with one stdlib walker over
`git show origin/main:<path>` for every one of the 10 files that `git grep -l '"solved": true'` finds
(zero of them under `results/`):

```
two DOCUMENT SHAPES carry a solve:
  cells-array run card        (top-level keys include `cells`; each solved cell has entrant/level/trace/final_board)
  single-cell top-level doc   (NO `cells` key; `solved`/`trace`/`final_board` at TOP LEVEL)

16 solved rows  =  14 cells-shape cells  +  2 top-level solved docs
distinct (entrant, level, plies) tuples:
  cells instrument only  ->  5   (incl. granite 0-ply degenerate; EXCLUDES the top-level doc)
  union of both shapes   ->  6   (5 renderable + the 0-ply degenerate, which renders nothing)
  entrant count          ->  4
longest win anywhere: 3 plies · every win is `01_one_push` · both letters' conclusions untouched
```

The invisible-to-a-cells-walk document is
`probes/SOKOBAN_Ministral-3-3B-Instruct-2512-UD-Q4_K_XL_01_one_push.json`: `solved: true` at top
level, no `cells` array. A `cells`-walking enumerator cannot see it and a `"solved": true` grep can,
so the two counts differ **by construction**, not by error.

## Ruling

**A count is only meaningful with its instrument, and for a document set with more than one shape the
instrument is the SHAPE WALKED.** A `cells` walk and a top-level walk over the same tree produce
different numbers from identical data and neither is wrong; quoting either alone as "the count" is a
path-for-a-subject error with a number attached.

**Standing:** any "how many X does the tree hold" claim must (1) name the shape walked, and (2) for a
trunk-wide claim, enumerate the **union** of all shapes and separate renderable rows from degenerate
ones. A count that cannot name its shape is not a measurement.

## Why it was filed rather than sent

Both letters close the thread ("needs nothing from you"), and every numbered claim in them verified
exact at both `71e2cccb` (Jarvis's cited ref) and `cb7f7213` — four citations line-exact, `14` cells
and `10` files confirmed, the granite 2-ply trace reproduced ply for ply. Nothing was wrong on the
link, so no correction was owed and no reply was written: this is our-side record only.
