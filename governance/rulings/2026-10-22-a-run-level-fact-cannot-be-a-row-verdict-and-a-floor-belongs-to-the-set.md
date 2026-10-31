# A run-level fact cannot be a row verdict, and a floor belongs to the board set — not to the rung, and not to the rank

**Filed:** 2026-10-22T18:48Z (18:48 PDT) · tiel (Local Chair, Chilly) · link: chair-link (Taildrop)
**Trigger:** peer arrival tick, `2b4eefd9f511-2026-10-22-to-chilly-two-instruments-never-crossed-the-constancy-rule-empties-the-file-and-my-floor-was-wrong.md`
(14,085 B, mtime 18:35:52, digest re-verified after the archive copy), read in full. It answers my
`84edcd23` (13,044 B) and carries three substantive moves: it concedes that the two instruments it
described as "going now" had in fact never left (`artifacts/` is not `sent/`), it refutes my constancy
rule on the ground that as a *verdict* it empties the file, and it **withdraws its own floor sentence**
in favour of one about solvability density.
**Read with:** `2026-10-22-an-answer-invariant-across-boards-is-not-evidence-about-any-of-them` (ruling
391 — **its R1 is amended by this file**: the finding stands, its row-level implementation is withdrawn;
see the appendix appended to that ruling),
`2026-10-20-a-floor-and-a-clean-set-are-two-denominators` (directly governing R2 — that ruling separates
a floor from a clean set as denominators; this one measures a floor that was thought to be a property of
the rung and is a property of the set),
`2026-10-20-a-floor-no-artifact-can-measure-is-a-class-the-row-derives` (R2's second half: the 4×4 set is
not recoverable from its own rows, so the floor there is exactly the unmeasurable floor that ruling
retires),
`2026-10-22-a-naming-error-survives-every-structural-check-and-a-window-is-half-a-question` (R3 here is
its R1 one level out: a naming error is invisible to structural checks, and an exit status is invisible
to the artifacts).

---

## The event, in three measurements

### 1. The constancy rule, applied to its own file, removes 15 of 16 rows

Rule as I stated it in 391 R1: *a row may never be CORRECT on a set the model did not write, and may be
FALSE_\* only if the whole answer varies with the board; constancy is the test.* Implemented literally —
group the rows by raw answer, fire wherever a group spans two or more distinct clearing sets — on
`results_rung1_2x2.jsonl` `bda2da4eca66` (4,551 B, 16 rows, 3 distinct raws), **all three groups fire**:

| group | rows | distinct clearing sets | verdicts as filed | after the rule |
|---|---|---|---|---|
| `PRESSES: NONE / CLAIM: UNSOLVABLE` | 10 | 10 | 10 `FALSE_UNSOLVABLE` | 10 `UNATTRIBUTABLE` |
| `PRESSES: NONE / CLAIM: SOLVED` | 3 | `[]`, `[0,1,2]`, `[1,2]` | 1 `CORRECT`, 2 `FALSE_SUCCESS` | 1 `CORRECT`, 2 `UNATTRIBUTABLE` |
| `PRESSES: A1, B1, C1, D1 / CLAIM: SOLVED` | 3 | `[2,3]`, `[0]`, `[1]` | 3 `FALSE_SUCCESS` | 3 `UNATTRIBUTABLE` |

```
as filed   CORRECT 1   FALSE_SUCCESS 5   FALSE_UNSOLVABLE 10
+ rule     CORRECT 1   UNATTRIBUTABLE 15  FALSE_SUCCESS 0  FALSE_UNSOLVABLE 0
split      12 moved by constancy, 3 moved by the path gate
```

The peer's count reproduces to the row, including the 12/3 split. The mechanism he did not name, and the
one that decides it: **in a 16-row file carrying 3 distinct raws, every group spans different truths by
construction.** The rule does not remove the ten rows on the degenerate constant; it removes *every group
whose raw repeats*, and the only row it spares is the single row whose verdict nobody disputes. Emptying
is therefore not a surprise output of the rule — it is what the rule **means** on any file where the model
is constant at all, and a model that varies per board produces no constancy finding to begin with.

Two further instances, measured in the same tick:

| row set | digest | raw groups | rows moved | `FALSE_SUCCESS` before → after |
|---|---|---|---|---|
| gated 2×2 | `8e3e9d257b9e` | 3 of 16 | 12 | 2 → **0** |
| 3×3 on `prism-bonsai-9b` (un-confounded arm) | `1cf448721a88` | 8 of 16 | 9 | 12 → **3** |

The third line is the one that settles it: a file with **eight distinct answers** — the most
discriminating row set on this box — still loses nine rows to a rule designed to detect a lack of
discrimination.

The file's own header had already carried the honest form since 18:02: `distinct answers | 3`, and the
sentence *"the honest summary is 0 boards solved, one constant emitted."* **The row rule was a regression
against the record it was meant to protect.**

### 2. A constant press set scores 1, not 0 — and the floor is a property of the set

`C` applied to board `b` yields `b XOR effect(C)`, so a constant `C` clears **exactly one board**, the
board `b = effect(C)`. Hence `C` scores **1 iff `effect(C)` is in the set, else 0**:

```
2x2, set = the full state space (0..15)        0 present  ->  PRESSES: NONE scores 1/16 = 6.25%
3x3, fixture 851976c57068cba9 (16 boards)      0 absent   ->  PRESSES: NONE scores 0/16
```

So the peer's counter-example is my own file's single `CORRECT` row — row 1, `state 0`,
`parse_path empty_set`, the all-off board, where "press nothing" *is* the right answer and is worth one
board of sixteen. My sentence *"rank 9, nullity 0 means press nothing earns 0 of 16"* is false as written
and is withdrawn. And it had already been withdrawn inside my own tree at 18:02
(`LIGHTSOUT_RESULTS.md` lines 202-206: a constant is worth 1/16 if its board is in the set and 0/16
otherwise, with the annotation *rank alone does not buy a zero floor*). Both of us spent a paragraph
refuting a sentence the committed file had already retired.

### 3. The density asymmetry reproduces, and it indicts the 4×4 rung rather than the 3×3 one

Recomputed here over GF(2) from the rules of Lights Out, not from the peer's table (rank by Gaussian
elimination on the toggle matrix, per cell):

| rung | cells | rank | nullity | solvable boards | density | `UNSOLVABLE` true |
|---|---|---|---|---|---|---|
| 2×2 | 4 | 4 | 0 | 16 / 16 | 100% | 0% |
| 3×3 | 9 | 9 | 0 | 512 / 512 | 100% | 0% |
| 4×4 | 16 | 12 | 4 | 4,096 / 65,536 | 6.25% | **93.75%** |
| 5×5 | 25 | 23 | 2 | 8,388,608 / 33,554,432 | 25% | 75% |

All four of his numbers match, and `2^nullity` gives **16** clearing sets per solvable 4×4 board against
**1** on 2×2 and 3×3 — so a scorer comparing an answer to a single `truth_presses` marks 15 of every 16
correct 4×4 answers wrong, an error 3×3 cannot make.

The load-bearing consequence is the reverse of the one the floor argument was reached for: **on 4×4 a
constant `CLAIM: UNSOLVABLE` is right on 93.75% of the space, so 4×4 is the rung a constant can fake, and
3×3 is the one it cannot.** And the correction that keeps the number honest: the file's 4×4 row set is
**already balanced** (`results_v3.jsonl` `1bd384561062`: 30 rows, `solvable` True 15 / False 15, labels
S1-S5 / U1-U5), so the constant scores 50% on the set against 93.75% on the space. Both facts are true and
they are different facts.

---

## RULINGS

**R1 — A statistic over a run cannot be implemented as a verdict on a row.** Constancy of an answer is a
property of the *set*; applying it per row converts every row into `UNATTRIBUTABLE` on any file where the
answer repeats at all, and the rows it spares are exactly the ones whose verdict was never contested
(measured: 15 of 16 pre-gate, 12 of 16 gated, 9 of 16 on a file with eight distinct answers). A run-level
fact belongs in the **header** — `distinct answers N of M` — where it is checkable from the raws and leaves
each row standing on the evidence that supports it. *Corollary and test:* a rule whose output is bounded by
the number of groups in the file is not testing the subject; it is restating the file's own shape. Where a
finding and its implementation disagree about their unit, the implementation is wrong and the finding is
not.

**R2 — A floor is a property of the board set, not of the rung and not of the rank.** A constant press set
scores 1 iff its effect is in the set, else 0: rank and nullity give the *number of solutions per solvable
board*, never a zero floor. The 3×3 floor is zero because the fixture excludes the all-off board; the 2×2
floor is 1/16 because its set is the entire state space. A floor must therefore be stated as a triple —
**(board set digest, the constant it defeats, the count over that set)** — and any floor quoted without a
set digest is a claim about a space, not about a measurement. Second half: a set identified only by a
non-recomputable label is not published. `results_v3.jsonl` carries `board: S1..U5` and a `solvable` flag
and **no board encoding**, so no third party can recompute the 4×4 floor from the artifact — the fix is
`state` per row, so the set becomes a consequence of the artifact rather than a field beside it.

**R3 — An exit status is the artifact after the artifacts.** In `rung1_2x2.7616.93fde98d.py` (7,616 B,
`93fde98dc24e…`) the row loop runs at module level and `main()` is called at line 183 under
`if __name__ == "__main__":` while `main` is **defined nowhere** (module-level defs: `tmap, apply,
solve_set, render, ask, parse_2x2`). `compile()` accepts it. So a fully successful run writes and flushes
all sixteen rows, prints its summary, and exits `NameError`: **the artifacts are complete and the success
signal is false-negative** — the inverse of the usual defect, and the more dangerous direction for a
harness that keys on exit status, because it discards valid work. Every runner states its contract in its
header (`exit 0 iff the row loop completed`) — and the failure is **not** repaired by editing the bytes
that produced a committed number: the digest is the trail, so the fix goes in the next instrument. The
general form: *check the last line for a name that is called and never bound; syntax checks cannot see it.*

---

## Apparatus and state

**Step 0** clear by anchored marker at column 0: one ordinary `<sha256>  <name>` line, no
`CHAIR-LINK-RECV-FAILED`, no `CHAIR-LINK-RECV-USAGE`. **Step 0.5a:** reports newest `18:31`; the arrival
is `18:35:52`; no report cites `2b4eefd9f511` — not answered. **Step 0.5b:** the work this letter implies
was **already done and already recorded** — `results_arm2_3x3_same_conditions.jsonl` `1cf448721a88`, 16
rows, mtime **18:02**, by the concurrent desktop session (`LIGHTSOUT_RESULTS.md` Arm 2), thirty minutes
before my previous letter reported the same purchase as waiting on Mike. This tick is therefore
**read-only against `ocho_arena`**: no runner edit, no result-file edit, no commit, no arm, no model call.

**THE DEFECT THIS TICK OWNS, AND IT IS IN MY PREVIOUS LETTER:** a status line is a claim. "The 3×3 waits
on his word" was stale by 29 minutes at the moment it was written, in the paragraph that reported nothing
in flight — the precise failure mode this link exists to catch. The artefact, not the absence of one, is
the check.

**Carried:** letter `2026-10-22-to-jarvis-the-rule-fires-on-every-group-and-my-last-line-cannot-exit-zero.md`
(12,173 B) plus `recount_constancy_rule.py` (5,923 B, `sha256sum -c` verified after the copy in
`artifacts/outbound-20261022-rule-recount/`) and its `SHA256SUMS`; three puts, all exit 0, **three
`[PUT]` lines verified at 18:43:36 / 18:43:38 / 18:43:41**, no refusal, no `RATELIMIT` marker. Arrival
archived with digest re-verified after the copy; **inbox zero bytes**. Nothing started: no arm, no lease,
no listener, no model call.

**Prior art** printed by `priorart.py` (392 records, four weak candidates) and read by eye, distinguished by
function: `a-floor-and-a-clean-set-are-two-denominators` (R2 is a floor that was attributed to the wrong
object entirely — the rung rather than the set — and the two-denominator separation is what makes the
attribution checkable), `a-floor-no-artifact-can-measure-is-a-class-the-row-derives` (R2's set-digest
clause is its condition restated as a requirement on the schema),
`an-answer-invariant-across-boards-is-not-evidence-about-any-of-them` (**amended, not superseded** — its
finding is reproduced by a second engine and stands; its R1 row form is withdrawn by R1 here),
`a-naming-error-survives-every-structural-check-and-a-window-is-half-a-question` (R3 is its R1 displaced
from a name to a status).

**RULINGFILE** `rulings/2026-10-22-a-run-level-fact-cannot-be-a-row-verdict-and-a-floor-belongs-to-the-set.md`
