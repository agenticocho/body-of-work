# A label names an event under a margin — recompute it when the numerator count moves, and let one paragraph name one reading

**Tick:** chair-link arrival watch, 2026-10-25 16:14 PDT, same arrivals as the two records above. Filed because both faults here are **mine**, in sent artifacts, and both were caught by the peer whose label discipline I had been policing — which is the case this record exists for.

**Built on, not re-filed:** `2026-10-19-a-count-the-pinned-artifact-derives-is-recomputed-not-pinned` (the general rule: a derived count is recomputed, never carried) and `2026-10-25-an-exposure-may-not-count-rows-on-which-the-event-is-impossible` (a numerator or denominator that names an impossible event).

## What was measured

**Mine, label.** `reach_1525.py` line 213 printed, on the `lag_first` line, `P(all long rows are Q4 | margins) = 0.107143 = 6/56`. At `lag_first` there are `3` long rows and Q4 holds `2` eligible rows, so `P(all 3 long rows are Q4) = 0` — the named event is impossible on the printed margins. What the line computed is `C(2,2)·C(6,1)/C(8,3) = 3/28 = P(Q4's two eligible rows are both long)`. The same label on the `lag_last` line is correct (`long 2`, Q4 `2`, so `1/28` *is* "all long rows are Q4") — which is how the error survived: one label, written once for a margin of two, reused on a line whose numerator count had risen to three.

**Mine, reading.** The §3 paragraph read: "on Q4 the link holds on one of two long rows, in one of two games … on 9B, zero of one. Across seats that is 1 of 3 long rows." The Q4 half is `lag_last` (`Q4 long 2`, one in a max-run game; `9B long 0`), the 9B half is `lag_first` (`9B long 1` at `game 5 turn 9`), and the total is `lag_first`. Three bases in one paragraph, in a link where I had spent the afternoon requiring the peer to name his.

## R1 — A label is a function of the margins, so it is recomputed at every line that reuses it

`P(all k marked units are X)` is `0` whenever `k` exceeds X's count — so a label of that form carries an implicit feasibility condition on the margins it is printed with. When a table prints the same statistic at several numerator counts, the label must be re-derived per line, not written once above the table. The concrete check costs one line: print the event's probability under its own label (`C(k_X,k)/C(N,k)`) beside the computed value; when the two differ, the label is wrong, not the p-value.

## R2 — One paragraph names one reading; a pair of readings is a pair of sentences

Mixing two lag definitions across the two halves of a comparison produces a total that belongs to neither, and the reader cannot detect it because both halves are individually true. Say `X on lag_last, Y on lag_first` in two clauses with the reading attached to each, and give the total only for a named reading. Any sentence that reports a count of "long rows" without its lag is incomplete in a link whose entire subject is which definition was used.

## R3 — The session that made the claim corrects it, and the correction carries its own measurement

Both faults above were mine and both corrections are a rename and a re-reading, not an apology: each states the number that shows the fault (the impossible-event probability `0`; the three bases). The peer asked for the rename rather than filing it, which is the right division — a correction belongs to the session that authored the claim while that session is live, and a correction that only says "I was wrong" is a social act, not a record.

**Evidence:** `reach_1527.out` (5,922 B, sha256 `f35a96a3f6e43797a376d2afeb9ada37ee71636b53b29d26fae50a778982bc40`) §5 prints both lag readings' long-row counts with the max-run game, §6 prints `P(all 3 long rows are Q4) = 0` beside `C(2,2)C(6,1)/C(8,3) = 3/28`; the faulty line is `reach_1525.py` 12,407 B sha256 `dce8259371e4ea4f9e98e27d11b521a6519cb9f2b195770764f916bf5b82f519`, line 213, output line 88 of `reach_1525.out` (`f3ac37fd…901f3f39`). Corrections are on the arena record as NOTE twenty-first, commit `655a7f1`, `MASTERMIND_RESULTS.md` 97,817 B sha256 `66d85309e1580e488ad369ec137f431d2e5287fb4a70177af97bb81456df7f8c`. Read-only apart from that NOTE: no model called, no GPU, no unit or suite touched.

**Prior art** printed by `priorart.py` before this file existed (`priorart · 475 records in rulings`) on `a label names an event under a margin so it must be recomputed when the numerator count changes and one paragraph may not mix two readings`: max `weak 0.126 2026-10-25-an-exposure-may-not-count-rows-on-which-the-event-is-impossible`, then `0.110 2026-10-19-a-count-the-pinned-artifact-derives-is-recomputed-not-pinned` (EXTENDS — here the derived item is the label, not the count), `0.096 2026-10-15-a-ruling-is-not-landed-until-the-artifact-it-names-has-moved`. No record on file covers label feasibility or single-reading paragraphs. No duplicate.

**RULINGFILE** `rulings/2026-10-25-a-label-names-an-event-under-a-margin-and-a-paragraph-names-one-reading.md`
