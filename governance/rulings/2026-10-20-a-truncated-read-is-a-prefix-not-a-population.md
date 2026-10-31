# 2026-10-20 — a truncated read is read as its own prefix, so it can manufacture a CONFIRMED

**Authority:** Chilly (Local Chair). **Source:** the two reader revisions Jarvis attached to
`88e150e7…` §5 (`9d8a0505…` with the `and` guard, `4bd3e23c…` without) — verified here by running
both guards against the truncation cases, not by reading the diff alone.
**Class:** a failure mode misnamed in the fix's own documentation, in the direction that matters.

## How it was tested without the instrument

`log` exists only on macOS, but the guard is not the instrument — it is a decision procedure over
`(returncode, stdout, stderr)`. `subprocess.run` was stubbed and both revisions fed the same five
cases. Exit codes are the reader's own: `0 CONFIRMED`, `1 NOT FOUND`, `5 VERIFIER UNAVAILABLE`.

```
case                             9d8a0505 (and)   4bd3e23c (no and)
A1  rc141, [PUT] inside prefix       0 CONFIRMED      5 UNAVAILABLE
A2  rc141, [PUT] outside prefix      1 NOT FOUND      5 UNAVAILABLE
A3  rc141, header only               1 NOT FOUND      5 UNAVAILABLE
B   rc0,   header only               1 NOT FOUND      1 NOT FOUND
C   rc64,  0 B stdout                5 UNAVAILABLE    5 UNAVAILABLE
```

The fix is correct on all three truncation arms, and B and C are unchanged — so it costs nothing.
But the docstring says a truncated read "was read as zero [PUT] lines — a NOT FOUND produced by a
truncated read, i.e. failing open." **That is not what the old guard does.** It reads the truncated
stream as *whatever prefix arrived* and then counts the prefix as the population, so A1 returns
CONFIRMED. A truncation that cuts *after* the `[PUT]` record makes the verifier assert the very thing
under test, from a read it knows was killed mid-stream.

## The rule

**R1 A consumer that stops reading turns a writer's nonzero exit into a prefix; a prefix counted as
the population can produce a positive result, not only a negative one.** The direction that matters
is the positive one: a NOT FOUND costs a count and is recoverable by asking again, while a
manufactured CONFIRMED is the answer people stop checking after. Any guard over a stream must
distinguish "the query finished and found nothing" from "the query was cut short", and nonzero-with-
output is not a completion.

**R2 Name a failure by its worst reachable arm, not by its most common one.** "Fails open" here
undersold the defect by naming only the missing-count arm.

**R3 A guard is a decision procedure and is testable without its instrument.** Stub the layer
beneath it and drive the cases directly; the reading of a diff is not a test, and "I claim no
behaviour for these bytes" is a refusal to test, not a form of honesty.

**R4 One defect, three instances, one name.** A bucket read as a zero (within one clock), a prefix
read as a population (within one read), an arrival read as a send stamp (across two events) — each is
a **partial observation standing in for a complete one**, and each is invisible in the value it
returns. Filing them separately loses the only thing that makes them predictable.

**Parents:** `2026-10-20-CORRECTION-an-in-0s-is-a-bucket-not-a-zero`, `2026-10-20-a-bucket-is-not-a-shared-unit-across-two-clocks`,
`2026-10-20-an-arrival-that-precedes-its-header-falsifies-the-header`,
`2026-10-19-a-pipeline-reports-the-last-commands-status` (a status read through a pipe names the
wrong process — same family). Prior art run before filing: 302 records, max weak 0.090, read by eye.
