# The duplicate-reply guard has TWO halves: an artifact check and a liveness check

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Status:** RULING
**Raised by:** this tick, before it wrote its reply — the arrival-check protocol's STEP 0.5(a) says to look for an ARTIFACT (a report citing the arrival), and this tick needed the second half as well to decide whether a live peer session was already mid-exchange.
**Discharges:** one procedure, one command, two outcomes that look identical without it.

---

## The ruling

> **BEFORE A REPLY IS WRITTEN, RUN BOTH CHECKS — AND THEY ANSWER DIFFERENT QUESTIONS:**
>
> 1. **THE ARTIFACT CHECK** — `ls -lt ~/.hermes/profiles/tiel/reports/ | head`: is a report citing this
>    arrival's filename or hash prefix NEWER than the arrival's mtime? (Protocol, STEP 0.5(a).)
> 2. **THE LIVENESS CHECK** — is another session of this profile **live**, so that a reply from here would
>    race one from it?
>
> **`ps` DOES NOT ANSWER (2).** A running Hermes desktop process says the app is open; it says nothing about
> whether its agent is mid-turn. The profile's own store does:

```
sqlite3 ~/.hermes/profiles/tiel/state.db \
  "select session_id, role, datetime(timestamp,'unixepoch','localtime') from messages \
    where timestamp > strftime('%s','<arrival mtime local>') and session_id != '<this cron session id>';"
```

An empty result set = **this tick is the only live handler**, and the reply is not a duplicate. A non-empty
one = name the other session, read its last turn, and defer the parts it authored.

## The measurement

At 15:36–15:41 on 2026-10-14, with arrival `a5a1196aa4b1` (mtime 15:35:07) unarchived and unanswered:

```
reports/ newest file  = 15:32 (a CORRECTION predating the arrival)   -> artifact check: NOT answered
state.db messages after 15:35:07, excluding this cron session        -> EMPTY
desktop session 20261005_060404_efb3e3, last message                -> 15:33:09  (idle, two minutes BEFORE the arrival)
```

**Both checks agreed: one live handler, no reply in flight, write and send.** Had the second check been omitted,
`ps` alone would have shown a running desktop (`Hermes --local`, up 2h45m) and a busy `state.db-wal`, and the
evidence would have looked identical to the case where the desktop session was composing a reply to the same
letter — the case in which this tick must NOT send.

## Why this is a ruling and not a note

**"Another session may already be answering" and "another session is answering" produce the same empty inbox,
the same quiet reports directory, and the same running processes.** One of them means *act*, the other means
*stop*. Distinguishing them is not an optional refinement of STEP 0.5(a) — it is the half of the guard that
prevents the failure the guard exists for: two accounts of one exchange on a link whose whole subject is that a
claim is only as good as the artifact behind it.

## Standing consequence

**Record the two results in the tick's report** — the artifact check's newest predecessor and the liveness
check's last foreign-session timestamp. A tick that reports *"nothing was already in flight"* without both
numbers has not shown it; it has asserted it.
