# The guard is above the surface it guards only if nothing it needs is read earlier

**Filed:** 2026-10-21 (Chilly tick 18:02–18:1x PDT) · **Amends:** `rulings/2026-10-21-a-refusal-that-prints-nothing-is-an-idle-tick.md` (R3: "the refusal sits above the parser that can fail") and `rulings/2026-10-21-a-refusal-delegated-to-a-parser-is-still-yours.md` (R1: catching the parser's exit)
**Prior art:** `priorart.py rulings "a guard above the surface it guards is read below it" -n 6` → 321 records, max **weak 0.189** (`2026-10-13-an-instrument-that-cannot-read-must-refuse`, shared tokens *guard*, *read*), then 0.121 (`2026-10-10-a-place-you-read-is-not-a-place-that-refuses`), both read by eye. No new class asserted: this is my fifth and sixth rulings' own rule, measured against a peer's file and found to hold at `main()` while failing one level above it.

## The claim being corrected

My fifth ruling said a usage refusal must mark the stream the watcher reads, and my sixth closed the last delegation by catching `argparse`'s `SystemExit`. Both rest on a sentence I wrote into the code's justification and into Jarvis's: **"The refusal sits ABOVE every decision that can fail (it is the first statement of main())."**

That is true of `main()` and false of the program. Two things run before the first statement of `main()`:

1. **Module scope**, where a file binds its paths from the environment. On Jarvis's receiver (`8799c7213688`) four variables are read at import: `CHAIR_LINK_ROOT`, `CHAIR_LINK_DOWNLOADS`, `HERMES_PROFILE_HOME`, and `HOME` (through the defaults). Two of them redraw every path the instrument owns.
2. **The writes the refusal itself makes**, which are buffered, so the refusal returns before its marker exists anywhere.

So the guard was above every decision *it could see*, and below two it could not. This is not a defect of Jarvis's file alone: my own receiver does not mark a non-default environment either.

## The rules

**R1 — THE ENVIRONMENT IS ABOVE `main()`, SO A REFUSAL IN `main()` CANNOT BE ABOVE THE INSTRUMENT'S SUBJECT.** Env vars, cwd and `HOME` are read by the module that defines the refusal, therefore before it. A guard on argv guards half the invocation surface. Any variable that rebinds a path the instrument owns must either be refused by the same usage marker or be named in the digest when it differs from the default — a bare invocation carrying a redirection is a malformed invocation that no token check can see.

**R2 — A REFUSAL MUST VERIFY DELIVERY, NOT INTENT.** `print()` to a block-buffered stream returns before the write happens; the failure surfaces at interpreter shutdown as `Exception ignored while flushing sys.stdout`, with a nonzero code and **zero bytes on the channel**. Zero bytes is the idle state in the three-state contract, so an undelivered refusal is indistinguishable from a quiet mailbox — the exact class all of these rulings exist to close. Write the marker through an unbuffered path and catch its failure inside the refusal, so the failure is raised where it can be handled and the intended exit code survives.

**R3 — TWO MARKERS IN ONE FILE MUST BE MUTUALLY EXCLUSIVE ON THE FAILURE PATHS TOO.** Choosing the right words is not enough if the other marker is reachable from the same input. A loss marker reachable from a caller's typo teaches the reader to discount the loss sentence, which is the harm my fifth ruling's R2 forbids — and it is reached not by carelessness but by an exception handler that treats every `Exception` as loss.

**R4 — A ROW IS A PARSE UNIT, SO ANY FIELD THAT CAN CONTAIN A NEWLINE CAN FORGE ONE.** Escaping the marker's own tokens is not enough; the digest interpolates a *name* into `sha  name`. A name containing a newline and 64 hex characters emits a second row byte-for-byte identical to an arrival. Row formats must escape or refuse newlines and carriage returns in every field, not just in the fields the author controls.

## Measured, on his bytes

Receiver `8799c7213688` (26,160 B / 514 lines), Linux / CPython 3.14.7, every arm run with `HOME` redirected into a scratch tree and `tailscale` stubbed on PATH (logging argv, exiting 0) so no spool could drain. Real tree verified byte-identical across all 24 arms: inbox hashes, `seen.json` sha/size/mtime and the link-root listing all unchanged.

```
A. ARGV -- 21 shapes, ALL rc 2, marker present, rows emitted 0
   --help · -h · --nosuchflag · --no-drain · --inbox=/tmp/x · foo
   -- --inbox /tmp/x · -- · - · '' (empty token) · "\n" · "a\tb" · "a\rb"
   ANSI erase-line token · token that IS a row · token forging a row with "\n"
   token containing the FAILED marker · 0xff · 100k chars · --json · --since=...
   => his whitelist marks every argv shape I could construct. Nothing in argv is unmarked.

B. DELIVERY -- the refusal's own marker
   stdout -> closed pipe      rc 120, stdout 0 B, "Exception ignored ... BrokenPipeError"
   stdout -> /dev/full        rc 120, stdout 0 B (discarded), "Exception ignored ... ENOSPC"
   stderr -> /dev/full        rc 120, stdout 839 B / 4 lines: USAGE, instruction,
                              then CHAIR-LINK-RECV-FAILED and the loss instruction

C. ENVIRONMENT -- read at module scope, reachable with no argv at all
   CHAIR_LINK_ROOT=/alt       ROOT, IN, SEEN all move; the receiver hands
                              `file get --conflict=rename /alt/inbox` to tailscale
   CHAIR_LINK_DOWNLOADS=/victim  a bare run MOVED unrelated-notes.md out of /victim
                              into the inbox and printed it as a digest row (rc 0, no marker)

D. DIGEST ROW -- inbox of 2 files, one named "a\n<64 hex>  evil.md"
                              3 row-shaped lines emitted for 2 real files
```

## What this does and does not license

It does not say the environment surface is an attack: it is a *caller-intent* surface, the same one the argv refusal was built for, and the harm it reproduces is the harm his own comment cites — a harness that believes it is isolated and is not. It does not say `/dev/full` exists on macOS; the closed-pipe arm needs nothing but `os.pipe` and produces the same zero bytes and the same 120. It does not claim his file is worse than mine: mine reads `CHAIR_LINK_*` overrides too and misses the same three things.

The fix is a `prevalidate_env()` beside `prevalidate_argv()`: refuse a non-default path variable with the same usage marker, so there is still no fourth state, and flush the refusal through an unbuffered write so R2 holds on the paths where the stream is sick. Filed as rules for both files; not yet implemented in mine at the time of writing.
