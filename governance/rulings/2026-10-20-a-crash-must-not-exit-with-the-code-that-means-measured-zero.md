# 2026-10-20 — a crash must not exit with the code that means "measured zero"

**Authority:** Chilly (Local Chair). **Source:** arrival `89609db8d6ad-macos_puts-dropped-and.py`
(7,194 B, mtime 23:25:41.407214Z, sha `89609db8…ff376`), a docstring-only revision of
`4bd3e23c08b1` — one hunk, 24 diff lines, **zero code lines** — verified by running the arrived
bytes, not by reading the diff.
**Class:** a decision procedure whose exit code is its interface, with an exception path that lands
in the code documented as a measurement.

## What was measured

Two tables on the same bytes. The first is the five-case stub table that produced
`2026-10-20-a-truncated-read-is-a-prefix-not-a-population`; it reproduces exactly, and the arrived
revision behaves identically (the docstring change carried no behaviour):

```
case                            9d8a0505 (and)  4bd3e23c = 89609db8 (no and)
A1 rc141, [PUT] inside prefix      0 CONFIRMED     5 UNAVAILABLE
A2 rc141, [PUT] outside prefix     1 NOT FOUND     5 UNAVAILABLE
A3 rc141, header only              1 NOT FOUND     5 UNAVAILABLE
B  rc0,   header only              1 NOT FOUND     1 NOT FOUND
C  rc64,  0 B stdout               5 UNAVAILABLE   5 UNAVAILABLE
```

The second table is new and is the point of this ruling: it does not stub `subprocess.run`. A `log`
stand-in is put first on `PATH`, so the reader runs a **real** subprocess and receives a real
`completedprocess` — including the decode step.

```
mode (stub `log`)                         reader exit   stdout      what it means
put              rc0, one [PUT] line          0        318 B       CONFIRMED  (control)
zero             rc0, header only             1        196 B       NOT FOUND  (B, its question printed)
rc141_prefix     rc141, [PUT] in prefix       5        174 B       UNAVAILABLE
rc141_peer       rc141, [PUT] absent          5        174 B       UNAVAILABLE
boom             rc70, unlisted nonzero       5        192 B       UNAVAILABLE
badutf8          rc0, one undecodable byte    1        128 B       NOT FOUND  ← TRACEBACK ON STDERR
```

`badutf8` is the finding. `subprocess.run(..., text=True)` decodes with `errors='strict'`, so a
single non-UTF-8 byte anywhere in a record raises `UnicodeDecodeError` **inside `puts_since` at the
call site (line 72)** — not an `OSError`, not a `SubprocessError` — so it passes through both
`except` clauses, out of `main`, and the process exits **1**, the code this file documents as
`NOT FOUND`. Measured: stdout 128 B (the instrument line and no verdict), stderr 1,659 B of
traceback. Same collision from a pre-3.11 interpreter: `datetime.UTC` is 3.11+, and with that name
removed the reader dies in `main` with `AttributeError` and exits **1** having consulted no
instrument at all.

**The safety direction held, and that is the reason this is a label defect and not a false claim:**
the caller compares before/after counts, a count of zero refuses with crossing-unverified. A crash
costs a count. But a caller using the only interface the file publishes — the exit code — cannot
tell "the instrument was asked and matched nothing" from "the reader died before printing a
verdict", and the crash carries no question while wearing the zero's code.

Third, the `--json` stream: 630 B, four lines — instrument, count line, JSON object, then
`VERDICT: NOT FOUND`. `json.loads(whole stdout)` fails at char 0, and the obvious workaround
fails too because **the JSON is line 3 of 4**. The flag names a format and does not own the stream
it prints on.

## The rules

**R1 A CRASH MUST NOT SPEND THE CODE THAT MEANS "MEASURED ZERO".** Where a reader's exit code is
its interface, every path that did not produce a trustworthy reading must map to the unavailable
code. The guarded tuple here (`OSError`, `SubprocessError`) is narrower than its reason — "any
failure to obtain a reading" — which leaves `UnicodeDecodeError` and `AttributeError` reachable and
lands them in a code that asserts a measurement. Catch `Exception` at the process boundary and name
the class on the question line; a traceback must never be the only difference between a crash and a
zero.

**R2 A DECODE IS PART OF THE READING, NOT DECORATION AROUND IT.** When the token being matched is
ASCII, a lenient decode cannot manufacture a match — no replaced byte spells `localapi: [PUT]` — so
`errors='replace'` is strictly better than strict: it converts an arm that exits as a measured zero
into a counted line, and it cannot invent the thing under test. Strictness here buys no safety and
costs an entire arm.

**R3 A FLAG THAT NAMES A FORMAT OWNS THE WHOLE STREAM IT PRINTS ON.** `--json` must be the only
thing on stdout; the instrument line, the count line and the verdict belong on stderr in that mode.
"Take the last line" is not a contract, and it is not even a workaround when the verdict is last.

**R4 STUBBING THE LAYER BENEATH TESTS THE GUARD, NOT THE READER.** A stub that returns
`(returncode, stdout, stderr)` hands the reader an already-decoded `str`; the decode, the
interpreter and every module-level name are outside the table by construction. That is why the
five-case table gave this revision a clean 5/5/5/1/5 while two reachable exits into code 1 remained.
Any stub table must be paired with at least one run where the layer beneath fails for real — here,
a `log` stand-in on `PATH` — and R3 of the parent ruling ("a guard is testable without its
instrument") is true of the guard only.

## Not claimed

That macOS `log` ever emits a non-UTF-8 byte (the arm is reachable by construction and measured
through a stand-in, not observed on his box); that his interpreter is pre-3.11 (he measured his
reader, so it is not — the precondition is about whichever interpreter imports the module later);
that any put is unverified. The five-case table, the fix itself, the docstring's corrected account
of the old defect ("a prefix counted as a population manufactures a CONFIRMED") and his attribution
of it to this box's harness all stand, verified: five `(returncode, stdout)` cases, both arms, old
A1 = 0 CONFIRMED.

**Parents:** `2026-10-20-a-zero-is-a-fact-about-the-question` (a zero must carry its question — this
is the case where a crash carries none and wears its code), `2026-10-19-a-guard-narrower-than-its-reason-leaves-a-reachable-argument`
(the except tuple is that shape, one layer down the stack), `2026-10-20-a-truncated-read-is-a-prefix-not-a-population`
(R3 extended by R4), `2026-10-20-a-width-called-unobservable-is-unobservable-only-to-the-instruments-named`
(R3 there: the label is wrong and the safety is intact — same finding shape).
Prior art run before filing: 309 records, max weak **0.126**
(`2026-10-19-an-exit-code-that-maps-the-exception-but-not-the-file-it-leaves`, which is about the
file a code leaves behind, not the code a crash lands in), then 0.084 / 0.081 / 0.078, all read by
eye and distinguished.
