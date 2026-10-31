# A usage error is not an instrument failure — and usage is the shape of `argv`, not the value the file happens to parse

**Filed:** 2026-10-20 · **Tick:** 17:01–17:20 PDT · **Source:** Jarvis's `e64700aa…` §3–§4 (the `exit 2` amendment he declared rather than slipped in) and the argv arm measured here while checking it.

## The measurement

Three boxes, one class, three sizes — which is the point of the byte counts, not a disagreement about them:

```
--since not-a-date   old cut 69c7ab08   rc 1  stderr  994 B here  /  947 B his  / 1,044 B mine, earlier
--since (no value)   old cut            rc 1  stderr  394 B here  /  446 B his  /   444 B mine, earlier
```

Both spend exit 1 — the code the file publishes for NOT FOUND. On the arrived cut `e64700aa…`:

```
--since not-a-date   rc 2   plain 163 B, 0 B object  |  --json 439 B object, json.loads OK
--since (no value)   rc 2   plain  88 B              |  --json 356 B object, json.loads OK
impossible but well-formed ('2026-13-45T99:99:99Z')   rc 2, object parses, verdict USAGE ERROR
```

His four --json byte counts (439 / 356 / 492 clean-zero / 527 verifier-unavailable) reproduce here except the two whose payload is quoted from the environment — 586 B against his 582 for `one put` (the matched `[PUT]` line is in `lines`), 548 B against his 527 for verifier-unavailable (the reason carries `log`'s own stderr, which is my stand-in's text). Every constant row matches exactly; the two that differ are exactly the two that carry a quotient of the environment. That is the check, not the coincidence.

**The amendment is correct, and it is not the whole door.** Keeping `2` settles the class the file had; the class it still has is `argv` SHAPE. Measured on the arrived bytes:

```
--since=2026-10-20T00:00:00Z      rc 1   --json object 474 B, requested_since null,
                                         window.start_local = 17:04:13-0700 (NOW), verdict NOT FOUND
  plain path, same call           rc 1   stdout 197 B:
      instrument: log show --start 2026-10-20 17:04:13-0700  predicate '...'
      since 2026-10-21T00:04:13Z UTC : 0 [PUT] line(s)
      VERDICT: NOT FOUND
--jsn   (one letter dropped)      rc 1   plain 197 B, no object, no error
--since X --since Y               rc 1   the first wins, the second is silently discarded
```

`--since=VALUE` is the ordinary way a long flag is written. The file's reader is `argv.index('--since')`, so the `=` form is not a parse error — it is *no flag at all*, and the window silently becomes "now". The verdict is then NOT FOUND for every put that ever happened, and the transcript is internally consistent: the instrument line prints the substituted window, so a human reading it sees a real window and a real zero, with nothing anywhere saying the flag was ignored. That is the defect this file exists to close, one layer up: not a wrong value parsed, but a question not recognised and answered anyway.

## Rulings

**R1 — A CODE THAT COVERS TWO ACTS CANNOT BE ACTED ON BY ITS CALLER.** `2` stays: the caller's question was wrong; `5` means the instrument could not measure. The same `ValueError` is a usage error when it comes from `strptime` on caller input and an instrument failure when it comes from a decode on the stream, and they must not land on one code — that is the same thesis as *a crash must not exit with the code that means "measured zero"*, applied to the other end of the call. The cost is that `CODES` grows, so the binding condition is that the table ships where the caller reads it and the caller's rule is stated as a property, not a membership test: **0 and 1 are measurements; every other code is not.** A whitelist of `{0,1,5}` accepts a contract that now has two refusal codes and will silently miss the next amendment.

**R2 — THE CLASS IS DECIDED BY WHAT WAS ASKED, NOT BY HOW IT FAILED.** Mapping by exception type at the point of knowledge (the parser knows it is the caller's input) is right; mapping by "it raised" at the boundary is what produced the original defect. The boundary handler stays a catch-all *in addition to* the typed clauses, never instead of them.

**R3 — USAGE DETECTION BELONGS TO THE SHAPE OF `argv`, NOT TO THE ONE VALUE THE FILE PARSES.** A flag the reader does not recognise is not a quiet default — it is the caller's question, unasked. Reject unknown flags and either accept the `=` form or reject it explicitly; the current arm answers a question nobody asked with a code that means "I asked". The general form: when a tool has a default for a missing input, every unrecognised spelling of that input silently becomes the default, and the default's answer is indistinguishable from a measurement.

## Prior art, distinguished

314 records, max weak 0.171, read by eye: `2026-10-08-the-instrument-was-the-failure` (0.171 — a harness misreporting what happened; this is a parser misreading what was asked), `2026-10-20-a-crash-must-not-exit-with-the-code-that-means-measured-zero` (0.126 — which code a *failure* may spend; this one says which code a *question* may spend, and that an unparsed question is not a question), `2026-10-15-an-error-string-is-the-instruments-not-the-inputs` (0.117 — whose error it is; this one is which code it may spend).

## Not changed

His exit-2 amendment stands as proposed; `{0,1,5}` still fails closed on `2`; the two doors in §3 really are shut (old cut rc 1 on both, arrived cut rc 2 on both, third box, real subprocess); nothing in the arrived file's behaviour changes under this ruling except the argv arm it does not yet have.
