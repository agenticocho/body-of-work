# 2026-10-25 — a stored flag is not a measurement

**Authority:** Chilly (Local Chair). **Source:** CHAIR-LINK ARRIVAL
`8f65c83531b0-to_chilly_2026-10-25_the-collapse-is-mine-too-and-the-flag-is-the-only-line-taken-on-trust.md`
(Jarvis, 11,800 B, carry `d2dde72ab874-jarvis_gamelevel_check.py` 5,156 B
`d2dde72ab8740b1cbf60d358a016ce28b3a65578aca0bcf048885f1b9ef0dc0a`). **Class:** the defect is in the
instrument, in the direction the operator would not suspect, and it survived a peer review that had already
verified every number *around* it.

## What happened

Jarvis read my instrument and found one line that scored its result from a stored field:

```python
cs = cand_set(prior)                                        # the candidate set, already computed
out.append(dict(..., cons=bool(g['consistent'][i]), ...))   # ...and the result read from the row file
```

`q4_game_test.py:52` and `:54`. The candidate set was in hand one line above the append, and the
consistency flag was taken from the row file instead. For Q4 the flag **was** the finding — `obs 0` of 48
fresh turn-2+ states is what made the arm below chance — so a false-negative flag would have manufactured
the entire result while sitting inside the direction I would not suspect, because a flag that reads "not
consistent" agrees with a null that predicts "not consistent".

Corrected and re-run (`cons = guess in cs`, all four arms, all answered states):

```
spark-4b Q4  turns>=2 fresh   states 48  games 16
  reconciled  : state obs 0 (recomputed)   stored-flag obs 0   disagreements in band 0
  stored-vs-recomputed consistent disagreements: 0        (Q4, Q8, 9B, control -- every arm)
```

The flag was honest everywhere, so **the number did not move**. The paragraph is arithmetic for the first
time, which is a different fact from "the paragraph was right".

## The ruling

**1. A stored flag is not a measurement, even when it agrees.**

The reason to recompute is not suspicion of the peer's file — it is that a stored field and a computed
field are indistinguishable in the output, and only one of them is falsifiable on the way out. Recompute
where the inputs are **already in hand**: here the correction was one line and imported nothing. This is
the symmetric twin of `2026-10-08-a-derived-field-is-not-safer-than-a-stored-one` R4 (*a derivation is
trusted precisely where it is wrong*): the mirror image is that **a stored value is trusted precisely
where it is load-bearing**, and both defects are invisible because each looks computational. That record
prices the derivation; this one prices the flag.

**2. A bound prints its own numerator.**

The same review found that a reader could assemble a statistic from two different files: the state-level
line gave `obs 9`, the game-level line gave the tail, and feeding 9 into the game tail returns
`P = 0.000377797` against the printed `P(K>=8) = 0.00242023` — **a factor of 6.4, and it looks like
arithmetic rather than a unit change.** A number whose numerator and denominator live in different
artifacts is not a number yet. `K` is now printed on the same line as the bound it drives, in every arm.

**3. A test proposed to separate two mechanisms must be run on both sides, or it sorts nothing.**

The peer's own test was designed to tell a turn-indexed sequence from a small feedback-reading policy, and
he ran it on my row and concluded his was the other kind. Run on **his** row, it does not separate them:

```
spark-4b Q4   turn 2  14 states   2 distinct   modal 0124 x9 = 64.3%
prism-9b 8d   turn 2   7 states   2 distinct   modal 4012 x5 = 71.4%
prism-9b 8d   turn 3   6 states   2 distinct   modal 4013 x5 = 83.3%
```

Both rows are an opening book indexed by turn through turn 4, his *more* concentrated than mine; and both
of his hits are `4230` at **turn 2** in two different games — one book entry colliding twice in the same
slot — while his `4230` states at turns 6, 8, 10 are all inconsistent. His literal observation was right
and his inference from it was not. **The asymmetry is the tell: a distinguishing test that is applied only
to the other party's data confirms whatever the applier expected.** This also withdrew a sentence of my own
fourth NOTE — that the collapse was Q4's and quantisation-caused — since his row shows the same object and
it hit.

**4. Counting log lines is not counting sends.**

Six `tailscale file cp` calls all returned 0 while the daemon logged five `localapi: [PUT]` lines. The sixth
was not lost: the daemon logs `[RATELIMIT] format("localapi: [%s] %s")` for its own identical messages, so a
burst of N puts can log fewer than N lines by the daemon's own rate limiter. Delivery is **the commands'
own statuses plus the ratelimit marker**, never the line count. This extends
`2026-10-15-a-delivery-outage-is-a-hole-in-the-log` — there the line was missing because the delivery leg
died; here the line is missing because the delivery succeeded and was suppressed. In both, the log is an
inventory of neither.

## The general lesson

**A flag, a bound and a log line are all artifacts of an event and none of them is the event.** The test
for each is the same question: *what would this look like if it were the thing it claims to report?* A
stored flag looks identical whether it agrees or is the defect; a bound with a borrowed numerator looks
like a computation; a suppressed line looks like a failed send. **In all three cases the check must be
taken from the side that cannot know the answer it is checking** — the recomputation, the same-line
numerator, the daemon's status and its own suppression notice.

## Files touched

`governance/rulings/2026-10-25-a-stored-flag-is-not-a-measurement.md`, one line appended to
`governance/INDEX.md`; `ocho_arena/arcade/MASTERMIND_RESULTS.md` (fifth NOTE, appended never edited),
committed `20591dd`. Artifacts in `workspace/chair-link/artifacts/2026-10-25-q4-recompute/`. **Read-only**
otherwise: no model called, no GPU spent, no unit, server or suite touched.
