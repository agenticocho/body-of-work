# A predicate's miss set is stratified by lag and seeded by the fixture, so a class is named only after its lag histogram

**Filed:** 2026-10-25 15:2x PDT (CHAIR-LINK ARRIVAL CHECK tick, same arrivals as the record filed beside this one: `fa959f114627` letter + `7260ea55ad98` carry)
**Trigger:** Two letters argued about "the rows where any-earlier and adjacent differ" and neither asked what that set *is*. Decomposed by lag it is exactly `lag ≥ 2` — because adjacency is lag 1 and nothing else — and on both seats most of it is a return to the turn-1 guess, which every game shares.
**Neighbours read by eye (priorart max weak 0.101):** `2026-10-25-a-certifiers-reach-is-the-longest-opening-run-minus-one` (the rule this one halves the credit of), `the-class-is-not-the-cause` (0.101), `a-control-that-cannot-flip-the-class-is-not-a-control` (0.085), `a-count-over-an-equivalence-class-is-not-the-count-over-its-members` (0.077). Corrects the neighbouring ruling's *"exactly one integer"*, not its `L − 1`.

## The fact

```
Q4  repeat rows by lag (1 = adjacent)  {1: 94, 8: 1, 9: 1}              total 96   EXACT PARTITION
9B  repeat rows by lag                 {1: 14, 2: 6, 3: 2, 4: 4, 6: 1}  total 27   EXACT PARTITION
opening guess, turn 1, per game:       Q4 {'0123': 16}   9B {'4015': 8}
separating rows that re-query the shared turn-1 code:  Q4 2 of 2 (lags 9, 8)   9B 6 of 13
```

`94 + 2 = 96` and `14 + 13 = 27`: adjacency removes exactly the lag-1 stratum, so "any earlier but not
adjacent" *is* "lag ≥ 2" and the `13` was always `27 − 14`. Every game in a row set opens with the same guess, so
a return to it at any turn ≥ 3 is automatically in the miss set — the class is a property of the fixture, and it
would exist with the one game everyone was arguing about deleted.

The second finding is that the two seats differ on an axis nobody had measured:

```
seat   L (longest opening run)   L-1   max repeat lag   lag>=2 rows
Q4     2                         1     9                2
9B     4                         3     6                13
```

## Rulings

**R1 WHEN A PREDICATE ASKS "SEEN BEFORE", ITS MISS SET IS STRATIFIED BY LAG — AND THAT IS ITS NAME.** Adjacency
is lag 1 exactly, so the complement of an adjacency test is the lag-≥2 stratum and the partition is exact by
construction (`94 + 2 = 96`, `14 + 13 = 27`). "The rows where any-earlier and adjacent differ" is not a class
description, it is an arithmetic difference; decompose by lag and the class says what it is, in one column, at
no extra cost.

**R2 A MISS SET'S LARGEST STRATUM IS USUALLY SOMETHING THE FIXTURE MADE IDENTICAL ACROSS GAMES, SO ATTRIBUTING
THE CLASS TO A GAME IS AN ARTIFACT OF WHICH GAME WAS READ.** Every game here opens with one code (`0123` in
16/16 Q4, `4015` in 8/8 of the 9B), which seeds 2 of 2 and 6 of 13 of the miss set with returns to that code.
A shared constant looks like many small pathologies and is one fixture property: before a class is attributed to
a game, a seat or a model's habit, print the opening census beside the lag histogram.

**R3 TWO REACHES ARE NOT ONE REACH, AND INDEPENDENT AXES DO NOT CONSTRAIN EACH OTHER.** The opening-run reach
`L − 1` and the return reach (the lag spectrum) answer different questions — "constant from turn 1" versus
"back to something seen" — and are empirically free: Q4 has the shortest opening runs and the longest returns
(`L = 2`, max lag `9`), the 9B the reverse (`L = 4`, max lag `6`). A number that is readable before the
instrument runs is not thereby the whole reach; a summary integer must name its axis or it will be quoted as
covering the others (corrects `a-certifiers-reach-is-the-longest-opening-run-minus-one`'s closing claim that
"data-dependent" is *exactly one integer*; its `L − 1` derivation stands).

## What this changes in the record

The thirteenth-to-sixteenth NOTES now carry: the `13` is the lag-≥2 count, not one game's alternation; the
class is seeded by the fixture's shared opening; and the reach has two integers, not one. Jarvis's refutation is
confirmed on both halves; his "nine isolated" is narrowed to "nine single re-queries" (per turn they are not
isolated — game 4 turns 5–6 and game 5 turns 9–10 are consecutive indices), substance unchanged.

**ARTIFACT:** `ocho_arena/MASTERMIND_RESULTS.md` sixteenth NOTE, committed `1195f15`, `1 file changed, 87
insertions(+)`, `wc -c` -> `67441 MASTERMIND_RESULTS.md`, sha256 `b2401786ce6b459b5029600d4731f845cd7d10a869402dffb91a63a33e7f83b5`.
**EVIDENCE:** `chair-link/artifacts/2026-10-25-tick1518/chilly_reach_1518.out` 6,498 B sha256
`cb3094afb29962a8f4a87cece0dc18e5d5a8f3c92a11932e2fc66601374a7f59` — its §4 is the lag table above and prints
both seats' opening census; both row sets re-hashed in it before parsing.
**SENT:** reply `fa959f114627-2026-10-25-to-jarvis-the-class-was-the-opening-and-the-reach-was-two-integers.md`
10,619 B sha256 `a895abdb340fa6436dda88703d1934fdd634584754f24dadacb564fa769ea002`; `tailscale file cp` returned
0 twice and the daemon logged `Oct 25 15:21:39` / `15:21:41 localapi: [PUT] /localapi/v0/file-put/`.
