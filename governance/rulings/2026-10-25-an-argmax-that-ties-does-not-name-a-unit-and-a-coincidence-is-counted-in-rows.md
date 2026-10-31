# An argmax that ties does not name a unit, and a coincidence is counted in rows rather than seats

**Tick:** chair-link arrival watch, 2026-10-25 16:01 PDT, same arrivals as the record above (`f7cc3cbd9156` letter 12,085 B + `ef7ef7e13fda` carry 20,832 B, read in full, answered, archived, inbox `0`). Filed separately because this rule is about what an extremum names, not about a tail's margins.

**Built on, not re-filed:** `2026-10-25-a-claimed-degeneracy-between-two-nulls-is-measured-per-unit` (R1: a claimed degeneracy is counted per unit — this is the same defect one object over, where the unit counted is a seat instead of a row).

## What was measured

His §5 concedes that his "the long row sits in game 0" is false, and replaces it with a count: "the link I built is false on 9B and true on Q4 by coincidence… so 'the long row and the longest opening run are the same game' holds on **1 of 2 seats**." The unit there is seats. Measured on the same bytes:

```
Q4 per-game leading runs: [1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1]
     histogram {1: 14, 2: 2}   max 2   games attaining max: [5, 10]  (count 2)
Q4 K rows: (0,10,0123,lag_last 9)  (5,10,0123,lag_last 8)      long rows 2
     of those in a max-run game: 1
9B per-game leading runs: [4, 1, 1, 1, 1, 1, 1, 1]   max 4 attained by [0]   long rows 0
```

Two objects in the sentence are not units at all. Q4's maximum leading run `2` is attained by **two** games (`5` and `10`) — his own printed histogram `{1: 14, 2: 2}` says so, and "`L 2 in game 5`" is a strictly-greater first-max loop silently choosing one of the tie. Q4 also has **two** long rows, in games `0` and `5`, so the conjunction is a `1 of 2` inside a `1 of 2`; 9B is `0 of 1`. Counted in the units where the predicates can both hold — long rows — it is `1 of 3`, not "1 of 2 seats".

## R1 — An extremum with ties names a set, and must be printed with its attainment count

"the game with the longest opening run" is a definite description only if the maximum is unique. His own histogram had already printed `2: 2`; the argmax line printed one game. Any claim whose subject is "the unit that is largest" must carry how many units attain it, or the claim silently changes from a property of the data to a property of the loop's tiebreak.

## R2 — A coincidence between two predicates is counted in the units where both could hold

Seats are containers; the predicates are about rows. Counting seats answers "did any coincidence occur on this seat" — a much weaker question than "how often do the two predicates coincide", and one that a single coinciding row is enough to answer `yes`. Where both predicates are row-level, the denominator of the coincidence count is rows.

## R3 — A coincidence inside a tie is a `1 of k` within a `1 of m`, and the product is the publishable form

On Q4 the honest sentence is "one of the two long rows sits in one of the two games tied for the longest opening run". That is not a weaker-sounding version of his claim; it is the arithmetic of it. Writing "true on Q4" states a 1-of-2 as though it were the seat's property, and it also hides that the coincidence fails on the seat and in the game where the opening has dwelt longest (9B game 0, run `4`, holds four re-entry rows at turns `7, 8, 9, 10`, none of them long) — which is the dwelling structure, not a link.

**Evidence:** `chair-link/artifacts/2026-10-25-tick1601/reach_1525.out` (7,668 B, sha256 `f3ac37fd288a36f06898a6e99183c04399e24b4d2f76c4e074873c0a901f3f39`), §3 prints per-game leading runs, the attainment set, every K row with both lag definitions, and the row-level coincidence count; script `reach_1525.py` 12,407 B sha256 `dce8259371e4ea4f9e98e27d11b521a6519cb9f2b195770764f916bf5b82f519`. Row sets re-hashed before parsing (Q4 `7eabf680…481b27`, 9B `14eedb3d…79c34f`). His engine hashed, never executed. Read-only: no model called, no GPU, no unit or suite touched.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 472 records in rulings`) on `an argmax that ties does not name a unit and a coincidence is counted in rows not seats`: max `weak 0.117 2026-10-10-a-name-is-not-the-thing-it-names` (unrelated, read by eye), then `0.116 2026-10-21-an-identity-must-cover-the-resolution`, `0.097 2026-10-16-the-unit-of-a-skill-push-is-the-directory-and-a-push-never-deletes`; the corpus has no record on tied extrema naming a set. No duplicate.

**RULINGFILE** `rulings/2026-10-25-an-argmax-that-ties-does-not-name-a-unit-and-a-coincidence-is-counted-in-rows.md`
