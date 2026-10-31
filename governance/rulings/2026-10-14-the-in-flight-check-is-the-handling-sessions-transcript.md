# The in-flight check is the handling session's transcript

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Raised by:** the Chair-link tick · **Status:** RULING

## The case, measured

Nine letters from Jarvis landed at **14:40:07** (`31e0d21d75aa`, `41e0cd864680`, `70ed47d347b1`,
`9c849e1daaa1`, `a6823817e96d`, `b35a567aa6bb`, `e426ae2de05f`, `fbd0256f1b67`) plus a ninth at
**14:43:35** (`4b8cdb770b85`). The tick's prescribed check — *a reply artifact newer than the
arrival* — **found nothing that answers them.** The newest report was `…CORRECTION-his-hash-list-is-right.md`
at 14:42:28, which supersedes §4 of the weights letter and answers an earlier arrival.

**By the prescribed check the nine were unhandled, and the tick was obliged to write.** They were not
unhandled. The co-resident desktop session `20261005_060404_efb3e3` — live, `last_activity_at`
14:43:34 — had already read all nine:

```
14:43:47  "Nine letters just arrived from Jarvis — and they carry Mike's decisions … Reading them:"
14:44:04  "Nine letters … Pulling the three where he contradicts or corrects me:"
14:44:35  running ITS OWN receiver against Jarvis's third control case (unreadable manifest)
```

A reply written by this tick at 14:44 would have been the second account of the same nine letters.

## The ruling

> **When the handling session is co-resident and its transcript is readable, the in-flight check is
> THAT TRANSCRIPT (or the running process), not the reports directory. A reply artifact is a PROXY
> for "this is being handled"; the proxy's failure mode is that it reports *unhandled* for work that
> is already under way, which is precisely the case where acting is expensive.**

And the general form, which is the same move the link made twice today in the other direction:

> **put the check where the decision is taken.** For a peer-link tick whose decision is *"do I write
> now"*, the check is **the actor's state**, not a downstream artifact of the actor's work. Jarvis
> moved his dedupe guard from the RECEIVE end to the SEND end for exactly this reason; the tick must
> make the same move, from *its own outbox* to *the other worker's transcript*.

**Corollary, and it is the half that prevents damage rather than duplication:** the tick must **not
archive** arrivals that a co-resident session is handling. An archived file is a claim that *this*
session dealt with it; archiving on another session's behalf converts "in flight" into "done" in the
only record the next tick reads. The nine stayed in the inbox, unarchived, and were left there.

## Why it is not a licence to do nothing

The check is not "is anyone alive" — it is **"is this specific work, on these specific bytes, already
under way"**, and it must name the work. Evidence admitted here was concrete: the arrival filenames
quoted in the live session's own turns, and its control run against the specific defect case in the
letters. Nothing here would have stood down a tick whose arrivals were *unmentioned* by a live
session; that state is still "reply absent + file present", which obliges work.

**And it cuts the other way when the actor dies:** a transcript is evidence only while the session is
live. Once the co-resident session is gone, the proxy is all that is left — which is why the artifact
check stays as the fallback rather than being replaced.

## Record

- Inbox left at **9 files, unarchived**; archive unchanged at 6; no reply written by this tick.
- The nine letters' own subjects (Mike's two decisions — jukebox is a side project, Arcade loose on a
  one-of-two signature; Jarvis's three measured corrections to our dedupe rule; the same-build DFlash
  pair; his answer on the weights source) are handled by `20261005_060404_efb3e3`.
