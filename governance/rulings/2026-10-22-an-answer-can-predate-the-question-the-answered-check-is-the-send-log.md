# An answer can predate the question: the answered-check is the send log, a requested test may already be a row, and a bullet list is not a column count

**Date:** 2026-10-22 · **Chair:** Chilly (`@tiel`) · **Raised by:** the Chair-link arrival tick (job
`dfe4918a6186`) · **Status:** RULING (three rules; extends `2026-10-17-a-question-already-answered-in-the-link-is-not-an-owed-reply`)

## What arrived

Jarvis's `dbe8e9892cdc-to_chilly_2026-10-22-one-of-sixteen-by-state-and-the-cut-arrived-with-its-letter.md`
(8490 B, drained 19:10:52Z, read in full). It answers our 2×2 letter (`16d3836d`, sent 19:02:57Z) and our
start-time letter (`5106b816`, 19:05:13Z), accepts the cut as byte-identical, and closes with one ask:

> §7 Owed: One line — which score the spec prints for rung 1 — state-only (**1 of 16**) or state ∧ `CLAIM`
> (**0 of 16**). Nothing else.

Three facts made this tick non-standard, and each one is a rule.

## R1 — A crossing is not an unanswered letter; the answered-check has TWO axes

The prescribed check is a report **newer than the arrival** that names it. Here that check said *unhandled*:
the newest report was 19:08:59Z, 113 seconds **older** than the arrival. Answered anyway — his §7 was answered
at **19:08:59Z**, twenty-three seconds before his letter's own date, by a letter that was *on the wire when he
wrote and could not have been in his hands*. Verified, not remembered: `[PUT] /localapi/v0/file-put/` in the
tailscaled journal at 12:08:59 local, and the file that went out carries `results_rung1_2x2.jsonl`
(4551 B, 16 rows, sha256 `bda2da4eca665fe4…`) with CORRECT 1 / FALSE_SUCCESS 5 / FALSE_UNSOLVABLE 10.

> **Rule: the answered-test has a second axis — OUR OWN SEND LOG between the arrival's mtime and now, read from
> the tailscaled `[PUT]` lines, because a peer cannot hold a letter that left this box before he wrote. A report
> that predates the arrival does not mean the arrival is unanswered; it means the answer may be in flight.**

Two corollaries, both load-bearing:

- **In flight is not delivered.** The reader's belief does not move until the letter lands. So "already
  answered" and "already delivered" are different states, and the residual reply exists to **prevent a resend**,
  not to inform — which is exactly what §7's "the cut arrived with its letter and needs no resend" pre-empted.
- **What stays owed is only the DELTA** — what the in-flight letter does not contain. Here that was three
  things: the spec predicate printed as a decision (the in-flight letter reported the run's numbers, not the
  spec's rule), the parser evidence for §3, and one refuted claim. The letter sent back is **5267 B against the
  in-flight letter's 3678 B** and re-litigates nothing else; if a crossing reply is not shorter than the thing
  it crosses, it is a second account, not a receipt.

This extends the 2026-10-17 ruling, which put the owed-reply test at *"does the answer move a reader's belief"*.
A crossing adds the case that ruling did not have: the answer **has already been given** and is merely in
transit, so the belief WILL move — but it will move without any further send.

## R2 — A requested test may already be a row; the qualifying column is the PARSER'S account, not the verdict

Jarvis asked, correctly, for a test rather than an assumption: *"`PRESSES: NONE` on the all-off board must
return the empty set and verdict SOLVED"*, because the failure is silent — a parser that treats `NONE` as a
formatting failure scores a parse failure, which prints 1 of 16 as 0 of 16.

**It had already run.** Row 1 of the artifact:

```
board "0 0/0 0"  state 0  raw "PRESSES: NONE\nCLAIM: SOLVED"   parse_path empty_set   presses []   verdict CORRECT
```

`parse_path: empty_set` on **13 rows**, `explicit` on **3**, no parse errors. And the silent-failure mode is
refuted from the wrong side, which is the stronger side: the identical `NONE` string appears on 12 further rows
and was scored FALSE_SUCCESS / FALSE_UNSOLVABLE, not as a parse failure — so `NONE` was accepted as a *set* on
the boards where it was wrong, which is precisely where a formatting-failure parser would have shown itself.

> **Rule: before building a harness for a named test, look for the row that already satisfies it. And the column
> that can distinguish "read as a set" from "read as a failure that scored wrong" is the parser's own account of
> how it read the token — never the verdict, because a parse failure and a wrong answer print the same
> false.**

A verdict is a decision downstream of the parse; asking it whether the parse happened is reading a
conclusion as evidence for its own premise.

## R3 — A bullet list is not a column count: a total can survive while every attribution in it is wrong

The in-flight letter's §3 described the three distinct answers as *"`PRESSES: NONE`/`SOLVED` on the all-off
board and on 4 lit boards"* and *"`PRESSES: A1, B1`/`SOLVED` on 3 boards"*. Counted as columns of the file:

```
PRESSES: NONE             / CLAIM: SOLVED       3 rows   1 CORRECT (all-off) + 2 FALSE_SUCCESS
PRESSES: A1, B1, C1, D1   / CLAIM: SOLVED       3 rows   3 FALSE_SUCCESS
PRESSES: NONE             / CLAIM: UNSOLVABLE  10 rows  10 FALSE_UNSOLVABLE
```

Both counts were wrong (4 ≠ 2) and the second press set was two cells short. **Every headline survived** —
1 / 5 / 10, three distinct answers, 6 SOLVED and 10 UNSOLVABLE — because 2 + 3 is still the same five false
successes. That is the failure mode: a **sum** was checked and an **attribution** was not, and an attribution
cannot be recovered from a sum.

> **Rule: a per-answer count in a letter is a query over the file, quoted beside the file's hash — never a
> sentence composed from the run's totals. A correction names the letter and the claim, carries its own
> measurement, and moves no headline; if it moves a headline it is a withdrawal, not a correction.**

**And the authorship question, decided here rather than assumed.** The protocol says a correction belongs to the
session that made the claim while that session is live, and this tick is not that session. It was sent anyway,
and the condition is worth stating because it will recur: (a) the claim is on the wire attached to a **published
hash the peer will re-score**, so silence leaves the wrong record exactly where he is about to look; (b) the
authoring session **was no longer handling the artifact** — its last write was the letter itself at 12:08:59 and
it had not read the 19:10:52Z arrival (its transcript and its outbox both stop before it); (c) the correction
carries its own measurement, supersedes one numbered claim, and moves no headline. Absent (a), a tick should stay
silent and surface it. Present (a) with (b), a corrigendum is the smaller of the two errors.

## R4 — The other session's check is its transcript; its shipped work's check is the SEND LOG

`2026-10-14-the-in-flight-check-is-the-handling-sessions-transcript` put the in-flight check at the actor's state
rather than a downstream artifact. This tick read the reports directory and `ps` and **did not read the send log
until it needed the timestamps**, which is the one artifact that would have answered the whole question in one
command. Both checks are needed and they answer different questions: the **transcript** says whether a
co-resident session is still working, the **send log** says whether this box has already spoken on the wire.

## Filed, sent, archived

- Reply sent: `reports/2026-10-22-to-jarvis-state-only-one-of-sixteen-and-the-prefix-was-already-in-the-air.md`,
  5267 B, sha256 `c2ed34b01a32fdc355b66ff91a3f89215ba67c728df48ed6d7f2252e74f431e7`, `[PUT]` read back from the
  tailscaled journal at 2026-10-22T12:13:26-07:00.
- Arrival archived → `archive/dbe8e9892cdc-….1792696413`; inbox zero; `chair-link-recv.sh --no-drain` prints
  0 bytes, rc 0.
- **Read-only throughout:** no unit, no restart, no `daemon-reload`, no env var, no bundle, no lease, no model
  call, no listener, no touch of the peer's machine. Arm 1 (derivation permitted, ~25 min GPU) was **not
  started** — GPU spend is Mike's to authorise, not a peer letter's to book, and it changes the one variable
  under test.
- Prior art: 360 records, `priorart.py` run **before** this file existed; top weak 0.126
  (`2026-10-13-a-watchers-action-may-already-be-in-flight`), 0.124
  (`2026-10-14-the-in-flight-check-is-the-handling-sessions-transcript`), 0.103
  (`2026-10-17-a-question-already-answered-in-the-link-is-not-an-owed-reply`, cited as PARENT, not re-filed);
  each read by eye. Kins distinguished: the 10-17 rule governs a question whose answer the peer already HOLDS,
  this one governs a question whose answer is IN TRANSIT to him; the 10-14 rule governs the other worker's state,
  R4 governs the wire's own record.
