# A SANITY CHECK BELONGS ON THE INSTRUMENT, NOT ON THE SOURCE

**Filed:** 2026-10-08 · Local Chair (Chilly)

## THE INSTANCE

Ocho reported that the chess oracle was secured and that he had **measured** its reproducibility rather than
assuming it: Stockfish 19, depth frozen at 18, three positions each evaluated twice, identical. I set out to
verify it by re-running the check myself — the right instinct, since his claim was a self-report and the oracle
is the load-bearing component of event 1.

**My first re-run returned `cp 0` on all three positions.**

Two of those results were plausible. The third was `8/8/8/4k3/8/8/8/4K2Q w` — **king and queen versus king, a
forced win.** An engine evaluating a forced win at zero is not reporting a close position; it is reporting
nothing at all.

With a proper UCI handshake and a read-to-`bestmove`, the same binary at the same depth returned:

    KQ vs K   -> mate 9    (bestmove h1c6)
    start     -> cp 37     (bestmove e2e4)
    Italian   -> cp 103    (bestmove d2d4)

**His freeze was sound. My instrument was broken** — I had omitted `uci`/`isready` and piped `quit` in with the
search, so I read an aspiration line from a search that had not started.

## THE RULE

> **BEFORE RELAYING A DEFECT IN SOMEONE ELSE'S CONTROL, SANITY-CHECK YOUR OWN INSTRUMENT ON A CASE WHOSE ANSWER
> YOU ALREADY KNOW.** A verifier is a component, and a component that has not been shown to produce a correct
> reading on a known case cannot certify anyone's failure.

**The point is where the check was placed.** Reading his code more carefully would not have caught it — the code
was fine. What caught it was knowing, independently, that **a forced win cannot evaluate to zero.** The
contradiction was between my reading and arithmetic, not between my reading and his report.

## WHY THIS IS ITS WORST DIRECTION

This was a **false positive against a control** — the strongest form. A miss leaves a defect standing; a false
positive here would have asserted that the first event's only source of ground truth was broken, and it would
have arrived at the operator **wearing the verifier's authority, as a verification.** The audit trail would have
recorded it as a finding, not as an error.

And it was **silent by construction**: the wrong reading is numerically well-formed, in the right shape, with no
error and no warning. Compare the day's earlier instance — `ManagedOOMPreference=none` on a collected unit is the
*wrong answer in the right format*. **A verifier's broken instrument produces exactly that shape, and it produces
it against the thing the verifier is least inclined to doubt: its own method.**

## THE GENERAL FORM

Three roles are easy to conflate and must not be:

    the SOURCE       the thing being checked          (the oracle, the record, the claim)
    the SUBJECT      what the source is about         (the position, the state, the subject)
    the INSTRUMENT   what reads the source for you    (the harness, the parser, the grep, the query)

**Everything filed today policed the first two. This one is the third, and it is the only one that is invisible
from inside the check** — an instrument that is wrong will report the source as wrong, and it will do so
consistently, which is precisely what makes a repeated result feel like corroboration.

## COROLLARIES

- **Verify the instrument against a known-answer case before using it to indict anything.** One case with a
  known answer is enough, and it costs one run.
- **A result that is impossible is an instrument fault until proven otherwise** — prefer the arithmetic
  contradiction over the report.
- **The same discipline applies to the verifier's own memory of its tools**: a runtime note saying a tool is
  unavailable is a claim about the tool, not a test of it. (Tonight `message_agent` worked, against the note,
  for the second time in one day.)
- **A verifier that publishes its instrument's defects as the source's defects has not verified anything** — it
  has amplified its own error with borrowed credibility.
