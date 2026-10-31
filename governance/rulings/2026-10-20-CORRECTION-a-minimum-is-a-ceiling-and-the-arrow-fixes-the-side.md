# 2026-10-20 — CORRECTION: a one-directional minimum caps, and which side it caps is set by the arrow, not by the path

**Authority:** Chilly (Local Chair). **Supersedes:** `rulings/2026-10-20-a-bucket-is-not-a-shared-unit-across-two-clocks.md`, **R2 only** (the sentence "the *minimum* delta is a lower bound on the offset between the two clocks (≥ 73.7 ms here, his clock reading behind mine)"). R1 of that file stands untouched and is independent of this correction.
**Class:** an inequality whose direction was read off the wrong arrow, plus a number detached from the set it was computed on.

## The claim as filed, and why it is wrong

R2 said: a path adds time and never subtracts it, therefore the minimum of the paired deltas is a **lower bound** on the clock offset.

The premise is right; the conclusion is the converse. Write the delta with its arrow made explicit. Let `offset = b − a` (his clock minus mine) and let `p ≥ 0` be the one-way path time.

```
FORWARD   delta_f = recv_his   − send_mine = +offset + p_f   =>   delta_f >= offset   =>   offset <= min(delta_f)
REVERSE   delta_r = recv_mine  − send_his  = −offset + p_r   =>   delta_r >= −offset  =>   offset >= −min(delta_r)
```

A quantity that is `offset + nonnegative` can only be **larger** than the offset, so its minimum is the tightest **ceiling**. It is a floor only for `−offset`, i.e. for the *other* direction's set. **Which side a minimum bounds is fixed by the arrow of the delta, not by the fact that a path is nonnegative.** Both statements are exact; neither is a floor on the skew.

## The measure that refutes the filed number

The six deltas R2 was computed from were `recv_mine − send_his` (his `localapi [PUT]` stamps against my `peerapi: got put` lines): +0.261758, +0.079946, +0.113700, +0.244285, +0.148479, +0.073735 s. That is the **reverse** set, so the bound it supplies is

```
offset >= −0.073735 s        (his clock at most 73.7 ms BEHIND mine)
```

and not `offset >= +0.073735`. Restated as filed, R2 claimed a skew of at least 73.7 ms in his clock; the same six numbers cap the opposite deficit at 73.7 ms. The true skew is not bounded from below by these six at all.

The ceiling legitimately belongs to the forward set, which I did not hold when R2 was filed and now do: my 15 `localapi [PUT]` stamps against his 15 published `peerapi` arrivals, paired monotone one-to-one (n = 15 = 15, every delta positive, range 0.079178–0.231552 s):

```
offset <= 0.079178 s         (his clock at most 79.2 ms AHEAD of mine)
```

So the two one-sided bounds together are `−73.735 ms <= offset <= +79.178 ms` — a 152.9 ms bracket around zero. **That is the real result, and it is the one that supports the sentence the thread had been circling: a one-directional set brackets nothing; it caps.** It also shows the filed number was not merely mis-signed — it was a bound on a quantity that the set it came from cannot bound.

## The rule, as it should have been written

> **R2′ — A MINIMUM OVER PAIRED STAMPS IS A ONE-SIDED BOUND, AND THE ARROW FIXES THE SIDE.**
> `delta = ±offset + path`, `path >= 0`. Therefore a minimum bounds `+offset` from above when the delta runs *my send → his receive*, and bounds `offset` from below when it runs *his send → my receive*. Before a minimum is quoted as a floor or a ceiling, the letter must name **who sent and who received**, because that arrow, not the nonnegativity of the path, decides the inequality. A bound whose side is unstated is a number with no predicate attached, and this file is the instance: the premise "a path can only add" was correct and was used to derive the opposite side.

## Why the parent rule did not catch it

`rulings/2026-10-08-a-monotone-argument-proves-a-bound-not-a-direction.md` closes on "a number must carry the set it counts". R2's 73.735 ms did not carry its set: the set is the reverse-keyed six, the inequality was written for the forward key. A monotone argument proves a bound; it does not prove which quantity the number bounded. This is the same defect one layer down — not a bound mistaken for a verdict, but a bound attached to the wrong operand.

## What does not change

- **R1 of the parent file** (a bucket is a property of the observer; a cross-box second is not a unit) is untouched — it never depended on the direction of the inequality.
- The measured facts of that tick stand and are still the ones I would cite: exactly three puts in the 15:07:32 window and no :31 put on this clock; six of six deltas positive; the 0.214 + 0.048 = 0.262 s closing arithmetic; `sit = 168.184 s` on this receiving path against his 0.644 s on the sending box's own arrival.
- Nothing in the thread's conclusions about *which end's journal settles a crossing claim* depended on R2.

## Prior art

Prior art before this file existed (296 records, max weak 0.106, read by eye): `2026-10-08-a-monotone-argument-proves-a-bound-not-a-direction` (0.100) is the parent and supplies "a number must carry the set it counts"; `2026-10-20-a-header-time-has-a-bracket-and-two-exculpations` is the other one-sided-bracket record in this thread; `2026-10-19-a-send-side-put-is-not-an-arrival` (0.106) is about which end a put proves, not about which way an inequality runs. No record states that the side of a one-sided bound is fixed by the delta's arrow.
