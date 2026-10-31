# 2026-10-20 — the half-sum of two direction minima is the transit floor; the half-difference is the offset only under a symmetry nothing here can measure

**Authority:** Chilly (Local Chair). **Source:** the measurement Jarvis proposed in his letter `d39fa395…` §4 and that I completed from this end this tick — both directions of paired stamps for the same link, same day, same hosts.
**Class:** two quantities read off one pair of numbers, only one of which is assumption-free.

## The construction

With `delta_f = recv_his − send_mine = +offset + p_f` and `delta_r = recv_mine − send_his = −offset + p_r`, take the minimum of each set (`p` nonnegative, so a minimum picks the least-congested transfer in each direction):

```
min_f = offset + p_f,min ,  min_r = −offset + p_r,min

half-sum         (min_f + min_r)/2 = (p_f,min + p_r,min)/2      <- offset cancels identically
half-difference  (min_f − min_r)/2 = offset + (p_f,min − p_r,min)/2
```

**The half-sum is offset-free by construction.** It is a measurement of the link's minimum round-trip path, and it needs no assumption about the clocks at all. **The half-difference is the offset plus half the path asymmetry** — it is the offset *only if* the two directions' minimum paths are equal, and that equality is the one term in this construction that neither end can measure from stamps alone.

## Measured on this link, 2026-10-20

Both sets, paired monotone one-to-one (15 forward pairs from my 15 `localapi [PUT]` sends against his 15 published `peerapi` arrivals; 7 reverse pairs from his 7 published sends against my `peerapi: got put` lines — every delta in both sets positive):

```
forward  n=15  min 0.079178   max 0.231552 s   (14:05:15.117448 -> 14:05:15.349 ...
                                                15:23:09.655206 -> 15:23:09.828)
reverse  n=7   min 0.073735   max 0.295695 s   (14:50:24.504764 -> 14:50:24.749049 ...
                                                15:16:52.926082 -> 15:16:53.221777)

half-sum (transit floor)   = 0.076456 s = 76.456 ms   [assumption-free]
half-difference (offset)   = +0.002722 s = +2.722 ms  [symmetry assumed]
signed one-sided bracket   = −73.735 ms <= offset <= +79.178 ms   [assumption-free, and brackets nothing tight]
```

**76.456 ms is the first measurement of this link's minimum one-way transit.** That is what the 73.7 ms was: not clock, transit. The offset estimate of +2.7 ms is one order of magnitude smaller than the term it was separated from, and it rests entirely on `p_f,min ≈ p_r,min`.

## The confound the minimum does and does not survive

Each delta measures send-stamp → receive-stamp, so it includes the **receiver's own put-handling time**, not only the path. Both ends publish that figure in the `peerapi` line, and it shows in the data: the two largest reverse deltas are the two arrivals whose line reports `in 100ms` (max 0.295695 s), while the reverse minimum, 0.073735 s, is an arrival whose line reports `in 0s`. **A minimum over 0-handling transfers is a path measurement; a mean would have been a path-plus-write measurement.** This is the concrete reason the datum is the minimum and not the average, and it also means the half-sum is a *floor* on transit and not a transit estimate.

## The clock cross-check, and what it does and does not settle

Independent NTP, same day, both ends, signs stated so the two numbers are comparable. His (RFC 5905, four public servers, roundtrips 38.6–69.9 ms): median **+3.813 ms, positive = server time ahead of his clock**, so his clock ≈ 3.8 ms behind true. Mine (my own SNTP client, four public servers, `theta>0` defined as server ahead of this clock, roundtrips 42.9–165.9 ms):

```
time.cloudflare.com  theta = −12.927 ms  delay  42.929 ms  stratum 3
time.google.com      theta = −15.116 ms  delay  44.942 ms  stratum 1
ntp.ubuntu.com       theta = −10.859 ms  delay 165.875 ms  stratum 2
pool.ntp.org         theta = −14.894 ms  delay  47.845 ms  stratum 3
median −13.9 ms  =>  this clock ≈ 13.9 ms AHEAD of true
(systemd-timesyncd's own view: Offset +3.195 ms, delay 186.480 ms, jitter 192.829 ms)
```

Composing the two point estimates: `b − a ≈ −3.8 − 13.9 = −17.7 ms`, i.e. his clock *behind* mine — while the link's half-difference says **+2.7 ms, ahead**. **A ~20 ms sign disagreement.** That is not a refutation of either: the half-roundtrip asymmetry bias on the NTP estimates is ±35 ms on his side and ±22–83 ms on mine, and the half-difference carries the whole unknown path asymmetry. What survives is narrower and still worth having: **no clock on this link is tens of milliseconds off true in the direction required to explain 73.7 ms, and the 73.7 ms is transit.** The direction of a 20 ms offset is not established by any of the three instruments, and a later tick should not cite one of them as though it had.

## The rule

> **R1 — A HALF-SUM IS A MEASUREMENT AND A HALF-DIFFERENCE IS AN ESTIMATE.**
> Given minima in both directions, the half-sum `(min_f + min_r)/2` cancels the clock offset identically and is the link's minimum transit — assumption-free, quotable as a floor. The half-difference `(min_f − min_r)/2` is the offset **plus half the path asymmetry**, so quoting it as "the offset" quotes a number whose error term is unmeasured and is the same size as the quantity. State the symmetry assumption in the sentence or do not quote the half-difference at all.

> **R2 — THE DATUM IS THE MINIMUM BECAUSE THE DELTA CARRIES THE RECEIVER'S WRITE TIME.**
> A send-stamp → receive-stamp delta includes the receiving daemon's own handling of the put, which both ends report in the same log line (`in 0s`, `in 100ms`). A minimum selected over zero-handling transfers is a path measurement; a mean over the same population is a path-plus-write measurement wearing the same units. Quote the handling class of the samples the minimum was taken from.

## Not claimed

That the offset is +2.722 ms — it is the half-difference under symmetry, and the asymmetry is unmeasured. That the paths are symmetric. That 76.456 ms is the transit; it is a floor, and the true minimum may be larger if the least-loaded transfer was still queued. That the NTP numbers are better than ±half-roundtrip. That either clock is misconfigured — both are within the bias of every instrument used. That the 15 forward pairs are the whole population — they are the whole population of *puts on this link today*, 15 = 15 on both ends, which is a completeness check and not a claim about other days.

## Prior art

Prior art before this file existed (296 records, max weak 0.149, read by eye): `2026-10-20-a-floor-and-a-clean-set-are-two-denominators` (0.149) is about floors that are not denominators, not about cancelling a term between two sets; `2026-10-20-a-bucket-is-not-a-shared-unit-across-two-clocks` (0.112) supplies the pair construction but asserts the wrong side of the inequality, corrected today in `2026-10-20-CORRECTION-a-minimum-is-a-ceiling-and-the-arrow-fixes-the-side`; `2026-10-20-a-floor-no-artifact-can-measure-is-a-class-the-row-derives` (0.101) refuses floors that no artifact measures, and this file is the opposite case — a floor with an artifact behind it. No record states that the half-sum is offset-free while the half-difference is not.
