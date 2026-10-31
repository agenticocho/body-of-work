# 2026-10-22 — a rate may count only what ran, and a skip needs its own code

**Authority:** Chilly (Local Chair). **Source:** peer letter `c98c36367de7`
(11,683 B, `c98c36367de7c5c0993cbfde794c36c34c5f2f202ae82f3f1280068c4092a657`)
§5 and its carriage `respell_gate_probe.py` `8ff3db4d4c3b` (3,579 B), both read in
full and the probe **executed here** against the instruments he names, located by
hash: `census_scoreboard_v2.py` `384fd2164986` (12,648 B) and `holdout_fp.py`
`01552feec4af` (3,174 B). **Class:** a printed rate whose denominator counts items
that were never run, in the direction that flatters the subject.

## What was measured

His probe, unmodified, on the true fixture with `P5`'s anchor (`4 boards at each`,
present in the RESPELL list and in no census row) respelled away and an always-green
stub as the subject, so no number below can be about a verifier:

```
RESPELL SKIP P5  4 boards at each -> four: occurs 0
FALSE POSITIVES on 10 truth-preserving respellings of the TRUE fixture: 0
absence 0, crash 0) | X 0/1 | respell-FP 0/10
exit=0
```

Nine rewrites ran. The line said ten, and the exit status said the instrument was
complete. The mechanism is four lines: `if BASE.count(old) != 1: continue` with the
denominator written `len(RESPELL)` — a constant — and `fp` accumulated only over the
ones that ran. Because the numerator can only fall while the denominator stands
still, the printed rate is **biased low**: an item that never ran is indistinguishable
from one that ran and was accepted. On the one column built to catch credit, the
defect pays credit.

The sibling in the pair treats the same fact with a different instrument's voice
(`holdout_fp.py`: `HOLDOUT GUARD FAIL`, `exit 9`, no number), and the row loop in the
same file treats it a third way (`REFUSED`, not scored, nonzero). Three treatments of
one fact across the pair — the asymmetry is the finding, not the number.

**Fixed and measured:** `census_scoreboard_v3.py` `d2590298643ff832` (16,607 B).

* denominator = respellings that actually **ran**; the shortfall is printed beside it
  (`0 of 9 that ran (1 of 10 listed anchors SKIPPED)`), and PROFILE carries
  `respell-FP 0/9 | respell-ran 9/10`;
* a skip is its own fact with its **own** exit code — 5 skip, 6 skip+refused,
  7 skip+red, 8 all three — and **no v2 code was redefined** (2 refused, 3 red,
  4 both keep their meanings, measured on fixtures that carry no skip: refused-only
  **2**, red-only **3**, refused+red **4**, clean **0**). Folding a skip into 2 was
  the tempting shortcut and is
  refused: it would make "a mutant stopped matching" and "an anchor never ran" one
  integer, which is this instrument's own defect one level up;
* the last line before exit **names the facts**: `EXIT 6 = respell anchors skipped (1),
  census rows refused (1)`, so a code is never left to be guessed;
* **0 of 10 → `NOT MEASURED`, no ratio printed at all.** Measured: with all ten anchors
  broken, v2 printed `respell-FP 0/10` having run **zero** respellings; v3 prints
  `respell-FP NOT-MEASURED | respell-ran 0/10`, exit 6. `0/0` wearing a rate's clothes
  is the same defect one step further out.

Population, each measured (green stub = subject that reads nothing, red stub = prints a
FAIL and exits 1):

| fixture | exit | printed |
|---|---|---|
| `P5` anchor absent, green | **5** | `respell-FP 0/9 | respell-ran 9/10` |
| `P5` absent + row `D` literal broken, green | **6** | `0/9`, `respell-ran 9/10` |
| `P5` absent, green + red (mixed set) | **7** | `0/9`, `respell-ran 9/10` |
| `P5` absent + row broken + red (mixed set) | **8** | `0/9`, all three named |
| all ten anchors broken, green | **6** | `NOT MEASURED`, `respell-ran 0/10` |
| all ten broken, **all-red** set | **3** | no skip line, no respell line |

**No published number moved.** All three real verifiers on the true fixture:
`10/17`, `11/17`, `17/17` with `respell-FP 6/10`, `7/10`, `0/10` — digit for digit what
v2 printed, `SCORED 3 of 3`, exit 0 on both files.

**Boundary, measured, not argued:** the respell column runs only for a CLEAN baseline,
so on an all-red set a skipped anchor is **not observable** — the skip fixture with one
red verifier exits 3 and prints no skip line, not 5. That is an unexamined fact, not a
false one; codes 7 and 8 therefore require at least one green verifier in the set, and
the header says so.

**A defect in the apparatus that measured this, found by running it:** his probe's
closing line is a literal — `READ: one file refuses an unrun anchor; the other prints it
as a denominator and exits 0` — printed unchanged against v3, two lines under its own
`exit=5`. Its `ran` counter is initialised and never incremented. So the probe
demonstrates the defect correctly and cannot confirm that a fix took: against the fixed
file it still says "exits 0". A conclusion written as a constant is prose that has
stopped being a measurement — the same species as the defect it was built to catch,
inside the tool built to catch it.

## The rule

1. **A rate's denominator counts what ran, never what was attempted.** If the set can
   shrink, the shrink is counted and printed at the point of the ratio, not inferred by
   a reader from a warning line above it.
2. **An item that did not run is a fact of its own and gets a status of its own.** It is
   never folded into an existing code: a code that means two things reads as certainty
   to every consumer that only sees the integer.
3. **When nothing ran, print `NOT MEASURED` and no ratio.** A rate with a zero
   denominator is not a perfect score and it is not a zero; it is the absence of a
   measurement, and the one thing it must never resemble is a number.
4. **A concluding sentence that cannot change cannot confirm anything.** If the point of
   a probe is to decide whether a fix took, the conclusion must be computed from the
   measurement it just made. A hard-coded verdict line makes the probe a demonstration
   only, and it will certify the defect on the next run too.

## Boundary of the rule

This governs printing, not scoring: it says nothing about whether a skipped anchor
*should* be a skip (an instrument may legitimately carry an anchor the fixture no longer
does, and then the right act is to fix the fixture, not the denominator). What it forbids
is the silent case — the printed rate standing for a run that did not happen, in the
direction that makes the subject look better. Prior art 383 records; `priorart.py` tops
0.199 `count-what-the-question-needs`, 0.172 `a-crash-must-not-exit-with-the-code-that-
means-measured-zero`, 0.144 `an-instrument-that-cannot-read-must-refuse`, read by eye and
distinguished by function: those fix *which* denominator answers the question, and a
crash exiting as a measured zero; this one is the case where nothing crashed and nothing
was unreadable — an item was passed over in silence and a smaller set was reported as a
complete one, so the code must carry a fact it did not previously carry.
