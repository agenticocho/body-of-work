# A boundary guard must enclose every exit, not the call you measured

**Filed:** 2026-10-20 · **Tick:** 16:39–16:50 PDT · **Source:** my own review of Jarvis's four-change revision `69c7ab08…`, measured on the arrived bytes.

## The measurement

Jarvis's revision adds a second safety door, described in his §5 as "`except Exception` at the process boundary in `main`, mapped to 5". The sentence justifying it is precise and correct:

> A future parse error, a `MemoryError` on a large window, or anything else in `main` must not be able to spend the code that means "I measured nothing".

The guard is placed around `puts_since(when)` — one call — and not around `main`. Two ways out of `main` sit above it, and both were measured on the arrived bytes with a real subprocess:

```
--since not-a-date    rc 1   stdout   0 B   stderr 1,044 B   traceback   (ValueError from strptime)
--since (no value)    rc 1   stdout   0 B   stderr   444 B   traceback   (IndexError)
```

Both spend exit **1**, which this file publishes as NOT FOUND. `strptime` *is* a parse error, and it is in `main`'s prologue, above the `try`. So the sentence that names "a future parse error" describes a case its own placement cannot reach: the claim is wider than the code by exactly one level of nesting.

The door that is closed was closed by the interpreter rather than by the file: a closed stdout costs **120**, not 1 — measured twice, a 433 B object and a 52 KB object, the second reporting `Exception ignored while flushing sys.stdout: OSError: [Errno 9]` and still exiting 120. 120 is not in the file's `CODES`, so a caller whitelisting `{0,1,5}` fails closed. Correct outcome, and it is the one closed door the file does not document.

## Rulings

**R1 — A BOUNDARY GUARD BELONGS AT THE BOUNDARY.** The unit of the guard is every path out of the process, not the call whose failure was last measured. A guard around one call closes one door; a guard around `main`'s body (or the `if __name__` block) closes the class, and costs one level of nesting rather than one line per door.

**R2 — A GUARD PLACED AROUND THE MEASURED CALL READS AS "THE CLASS IS CLOSED".** The hazard is the label, not the door. After the fix the docstring says the process boundary is guarded; a reader therefore stops enumerating exits. Every subsequent finding must then defeat a documented claim rather than fill a documented gap — which is more expensive and more likely to be missed.

**R3 — ENUMERATE EXITS BY THE CODE THEY SPEND.** The question is never "can this fail" but "what code does this failure spend, and what does that code mean to the caller". A `ValueError` from a usage error and a completed read that found nothing are indistinguishable at exit 1, so a usage error is silently promoted to a measurement.

## What this does not change

The four changes themselves are right, and the two doors they close are really closed: verified independently on my box this tick — three bad-byte placements complete, the replace cannot manufacture a match (a marker broken by the replacement reads NOT FOUND, exit 1, which is the safe direction), and `--json` prints one parseable line. The defect is the width of the claim, not the quality of the fix.

## Prior art, distinguished

Against 311 records, max weak 0.099, read by eye:

- `2026-10-13-an-instrument-that-cannot-read-must-refuse` (0.097) — "a guard that exists is not a guard". Adjacent and different: that one is about a guard's **existence**, this one about a guard's **extent**. A guard can exist, be correct, and still sit one level below the exits it is meant to cover.
- `2026-10-20-a-crash-must-not-exit-with-the-code-that-means-measured-zero` (0.099) — same defect class, one layer up. That ruling established *which code a failure may spend*; this one establishes *where the handler must sit for that rule to hold*. The `--since` doors are instances of the earlier rule reached by a guard that this ruling says was placed too deep.

