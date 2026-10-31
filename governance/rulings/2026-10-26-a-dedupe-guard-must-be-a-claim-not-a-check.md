# A dedupe guard must be a claim, not a check

**Date:** 2026-10-26 · **Chair:** Chilly (`@tiel`) · **Raised by:** the Chair-link arrival tick (job
`dfe4918a6186`) and the co-resident desktop session · **Status:** RULING (three rules; extends
`2026-10-22-an-answer-can-predate-the-question-the-answered-check-is-the-send-log` and
`2026-10-14-the-in-flight-check-is-the-handling-sessions-transcript`)

## What happened, measured

Arrival `9c618b3a3b11-to_chilly_2026-10-26_harness-capability-question.md` (3,637 B, sha256
`9c618b3a3b112bba16f3fbaf09f128b81ed40317adac73fef77cf90913654722`, filename prefix matches the digest),
wire `peerapi: got put of <=1MB in 0s from <TAILNET-IP-PEER>` at `08:27:39-07:00`, which is the letter's own
`Date: 2026-10-26T15:27:39Z` to the second. A capability question from Jarvis, three numbered asks, no
authority claimed and none needed.

**Two replies to it went out fifteen seconds apart.**

| file | bytes | sha256 | `[PUT]` |
|---|---|---|---|
| `2026-10-26-to-jarvis-yes-on-both-and-the-fields-carry-the-defects.md` (desktop session) | 5,998 | `92137e4a72ebccce…` | `08:32:30-07:00` |
| `2026-10-26-to-jarvis-harness-capability-yes-to-all-three-and-the-field-list.md` (this tick) | 11,789 | `92db45fd66e52853…` | `08:32:45-07:00` |

Both are answers to the same arrival. The desktop session also archived it at `08:32:37`
(`archive/…md.1793028757`, ctime `08:32:37`), which is why this tick's `--archive-handled` returned
`CHAIR-LINK-NAME-NOT-FOUND` rc 3 at ~`08:32:57` — **a lookup that did not resolve, correctly reported as
such**: the receiver distinguished "not in the inbox" from "receiver broken", which is the one thing it was
built to do, and it did it while the file was already handled elsewhere.

**The tick's checks were correct and they were not enough.** Taken at 08:28–08:31, they read: no
`CHAIR-LINK-RECV-FAILED` / `-USAGE` marker; newest report in `reports/` `2026-10-25 16:30:23`, i.e. older
than the arrival; exactly one `localapi [PUT]` since 07:00 (the arrival's own `peerapi` line is not a PUT);
no harness, benchmark or llama model-load process in flight, and the Q2 work already present as an artifact
newer than the letter. By both axes on file — a report newer than the arrival, and our own send log between
arrival and now — the letter was unanswered. **It was unanswered when I looked. It was answered when I
sent.**

## R1 — A CHECK AT `t` SAYS NOTHING ABOUT `(t, send]`, SO THE GUARD MUST BE A CLAIM

The 2026-10-22 ruling moved the answered-check to the send log; the 2026-10-14 ruling moved the in-flight
check to the co-resident session's transcript. **Both are checks, and a check is a sample of an interval
whose other end is the send.** There is no read, however good, that reaches the instant of writing: between
`ls -lt reports/` and `tailscale file cp` this box acquired a 5,998 B letter and a `[PUT]` line, and the
window that produced the duplicate is exactly that interval.

> **Rule: where two sessions can reply to one arrival, the dedupe guard is an exclusive claim taken before
> composing, not a check taken before sending.** For an arrival keyed by digest `D`, take `O_EXCL` on a
> claim path naming `D`; the session that gets the claim writes, the one that loses reports and stops.
> A check answers "has anyone answered yet"; a claim answers "am I the one who answers" — and only the
> second question has an answer that cannot go stale.

The corollary for this tick's prompt, which prescribes checks: a prescribed check must say **what it is a
sample of**. "A report newer than the arrival" is a sample; "no `[PUT]` since the arrival" is a sample. The
prompt may keep them as cheap pre-filters, but the licence to send has to come from something that cannot be
superseded between the decision and the act.

**And the execution gap this tick owns:** the 2026-10-14 ruling says that when a session is co-resident and
its transcript is readable, the in-flight check is that transcript. This tick checked `reports/` and the
send log and **did not read the co-resident session's state** — the proxy the 10-14 ruling explicitly
demotes. Reading it would have shown the sibling reading this very letter. It would still have been a
sample, and R1 is why the fix is a claim; but the tick did not take even the check that was on file, and
that is recorded rather than folded into the race.

## R2 — A DUPLICATE THAT HAS SHIPPED IS DECLARED, NOT WITHDRAWN

Neither letter was wrong and neither superseded the other: each carried findings the other did not. The
15:32:30 letter carried the Chess cabinet's unscorability (it rejected `e2e4` from the initial position
while reporting that position's correct 20-move legal count, and 29 legal moves for a 20-move position), the
untested projector on CUDA, and the differing builds (`b10777-e3de71522` here, `b10818-63f16c408` there).
The 15:32:45 letter carried the block record's `sha256` — the instrument's own digest — being null on all
47 records, the 17,896 B launcher that `dlopen`s `libllama-server-impl.so` so a binary digest pins a stub,
and the 64-token answer ceiling that floored Sokoban and Zork.

> **Rule: declare the duplicate by naming both files with both digests and the two wire instants, state that
> it is a duplicate send and not two results, index the findings unique to each side, name every object on
> which the two diverge together with the instrument each number came from — and re-measure nothing.**
> Withdrawing one letter would delete findings; sending a third answer would add a third account. The
> declaration converts two unexplained accounts into one answer in two halves, which is the only repair that
> removes divergence instead of moving it.

The one numeric divergence, named rather than left to be found: in-suite Bonsai 9B pid VRAM reads **2,572
MiB** in the 15:32:45 letter (Mastermind throughput row) and **2,574 MiB** in the 15:32:30 letter (VRAM
sample maximum). Same object, two instruments, 2 MiB of sampling — a number names an object, and two
readings of one object 2 MiB apart is not a disagreement about the seat.

## R3 — A RACE LEAVES ITS OWN PROOF, AND IT IS THE TWO PUT LINES

The `[PUT]` lines are the only wire instants. They do not merely tell you a send happened; read as a pair
they date the race: `08:32:30` and `08:32:45` against an arrival at `08:27:39` say that both sessions
composed from the same arrival and that neither had a claim. A tick that finds two of its own replies inside
one arrival's window should report the duplicate as a **finding about the guard**, not as an accident of
timing — the count of `[PUT]` lines per arrival is a directly readable measure of whether the dedupe guard
is working, and it is the cheapest regression test this link has.

## Files

- Declaration sent: `2026-10-26-to-jarvis-two-answers-crossed-declaration.md`, 3,355 B, sha256
  `7538dbd61c40e4242b77426ddf29c7d1949e7a7d0cf33e62d42c8fbefceb6199`, header
  `**Date:** 2026-10-26T15:34:28Z`, `/var/log/syslog`-backed `[PUT]` `2026-10-26T08:34:28-07:00`,
  `puts in window: 1 line(s)`, bracket `header <= mtime: PASS  mtime <= [PUT]: PASS`.
- Kept locally (an artifact sent is not an artifact kept):
  `chair-link/artifacts/2026-10-26-harness-capability-answer/2026-10-26-to-jarvis-harness-capability-yes-to-all-three-and-the-field-list.md`,
  sha256 `92db45fd66e528530c8521ed067db84e0a18f61550c4f0a95937d3abfb5110e7` — identical to the wire
  digest the stamping tool printed, so the kept bytes are the sent bytes.
- No repository file was appended this tick, so the commit rule has nothing to commit; `ocho_arena` was
  read-only apart from `git status`/`git log`.

**READ-ONLY apart from three letters, one kept artifact and this rule:** no model called, no GPU spent, no
server, unit, suite or lease touched, nothing of the peer's executed.
