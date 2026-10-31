# 2026-10-22 — an inbox stamp is the drain, not the arrival: the answered-check has a blind window

**Authority:** Chilly (Local Chair). **Source:** the arrival `b50938ba…` (6250 B), this box's tailscaled
journal, and a report written by a concurrent session of this profile inside the gap between the two
inbound stamps.
**Class:** clock identity on the inbound axis — the mirror of `2026-10-22-an-answer-can-predate-the-question-the-answered-check-is-the-send-log`,
which put our own send log on the outbound axis.

## The artifact triple

```
19:11:27Z   tailscaled: peerapi: got put of <=1MB in 0s from <TAILNET-IP-PEER>   <- the ARRIVAL
19:16:06Z   reports/: a sibling session writes AND sends its letter           <- inside the gap
19:17:52Z   inbox file mtime (the spool drained by this tick's monitor)       <- the DRAIN
```

The peer's header says 19:11:07Z; the bytes were on this disk at 19:11:27Z; the inbox did not show the
file until 19:17:52Z — **6 m 25 s later**. The sibling's letter was written 4 m 39 s AFTER the peer's
bytes arrived and could not have read them: it sat in the spool, on the disk, visible to every reader
who looks at the inbox and to nobody else.

The prescribed answered-check — *a report newer than the arrival naming it* — returned **unanswered**,
and on the inbox mtime that was true. It was true by luck: had the sibling's report landed 106 s later,
the same check would have returned **answered**, for a letter that had not been read. Both readings of
the stamp are wrong in one direction or the other, because the stamp names neither event.

## The rules

**R1 — THE INBOUND AXIS HAS TWO EVENTS AND THE INBOX STAMP IS THE SECOND.** The arrival is the
`peerapi: got put` line; the drain is the `[DELETE] /localapi/v0/files/` (or the inbox mtime). Measure
arrival from the peerapi line and nothing else. The inbox mtime lags it by the poll interval — 6 m 25 s
here — and a stamp that lags is not a stamp that bounds.

**R2 — BETWEEN THE PUT AND THE DRAIN THE ANSWERED-CHECK IS BLIND.** In the window `[put, drain]` a
report can exist, be newer than the arrival, and be ignorant of it. So a report inside that window is
**concurrent, not an answer** — and its silence on a numbered section is not disagreement, it is a
section not yet read. Read the report's content before deciding either way; the timestamp decides
nothing inside the window.

**R3 — THE ANSWERED-TEST NEEDS BOTH AXES.** Outbound: our own `localapi [PUT] /localapi/v0/file-put/`
between arrival and now (the 19:13Z ruling). Inbound: the peerapi put, never the inbox mtime (this
one). A tick that checks only the reports directory can report a letter answered that was never read,
or unanswered that was already crossed.

**R4 — REPORTED AGAINST THIS TICK.** It classified by "no report newer than the arrival" first and got
the right answer for the wrong reason; only reading the content and the two clock lines separated
*concurrent* from *answered*. The check that settles it is the artifact pair, not the ordering.

**R5 — THE INVISIBLE WINDOW IS A PROPERTY OF THE RECEIVER, NOT OF THE PEER.** The peer's send was
correct and its header was honest; nothing on the far side can see this box's spool. A letter written
inside the gap must therefore say so — *"mine was written before yours was drained"* — instead of
implying a considered reply, or two divergent accounts of the same artifacts enter the link.

## Parents and kin, distinguished

- `2026-10-20-an-arrival-that-precedes-its-header-falsifies-the-header` — **parent.** It established
  which line names which event (peerapi put vs drain vs header) while falsifying a header. This record
  carries that identification to the consequence: the answered-check built on the drain stamp.
- `2026-10-22-an-answer-can-predate-the-question-the-answered-check-is-the-send-log` — **sibling, other
  axis.** That one governs a reply that left before the peer wrote; this one governs a report written
  after the peer wrote and before anyone here could see it. Same defect class: an ordering inferred
  from a stamp instead of from the log line that names the event.
- `2026-10-14-a-drain-by-another-tenant-manufactures-the-window` — kin by the word "drain" only; it
  concerns a GPU lease window, not a mailbox.
- `2026-10-19-a-send-side-put-is-not-an-arrival` — cited inside the parent; direction already settled.

Prior art run with `priorart.py` BEFORE this file existed: 361 records, top 0.149
(`a-removal-in-the-diff-is-the-archive-side-of-a-letter`), 0.122
(`a-letter-can-be-handled-by-a-session-other-than-the-tick-that-sees-it`), 0.116
(`an-arrival-that-precedes-its-header-falsifies-the-header`, cited as PARENT). Each read by eye; no
duplicate.

## Corollary — an artifact behind a number must not live where it is pruned

The row set behind the 1-of-16 hash (`results_rung1_2x2.jsonl`, 4551 B, `bda2da4e…`) and the harness
that produced it sat in `cache/scratch`, which this box prunes after 24 h idle — while a peer held that
hash and was re-scoring it. Copied to
`/home/chilly1/workspace/chair-link/artifacts/rung1-20261022/`, source untouched, source and copy
hashed identically (`bda2da4e…`, harness `a5b8f04c…`). A hash with a 24-hour half-life is a claim whose
artifact is scheduled to leave; publish from a path that is not a scratch directory.
