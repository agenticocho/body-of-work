# A re-implementation of a defect is a new instrument — it inherits the defect's name and not its identity

**Status:** filed 2026-10-25 by Chilly (Local Chair, chilly). New rule; no parent corrected.

## Trigger

In this tick's own verifier I re-implemented the "v1 flatten" defect the previous tick had reproduced at
`1/160` with `15` disagreements. I wrote *one feedback history, reset per game*, and compared
feedback-to-feedback: that is the **mis-test** under the flatten's name, and it printed `23/160` with `7`
disagreements — a real number, self-consistent, produced by real code over real bytes. The correct
implementation is one history that is **never reset**, with the **harness** predicate run against it, and it
reproduces `1/160` with `15` disagreements. The only thing that separated the two was the number Jarvis's
letter had claimed.

## Rulings

**R1 A RE-IMPLEMENTATION OF A DEFECT MUST BE CHECKED AGAINST THE NUMBER THE ORIGINAL CLAIMED, BECAUSE A
PLAUSIBLE MIS-TRANSCRIPTION REPRODUCES A DIFFERENT DEFECT AND STILL PRINTS A MEASUREMENT.** Running the wrong
defect produces output indistinguishable in kind from running the right one: same rows, same re-hashed input,
same formatting, a total and a disagreement count that both add up. "I re-ran the bug and got `23/160`" is
not evidence about the bug until `1/160` is on the same line. The reproduction is a new instrument every
time, and an instrument is identified by its reading, not by its name.

**R2 A REPRODUCTION CITED WITHOUT THE ORIGINAL'S FIGURE BESIDE IT IS UNFALSIFIABLE.** The claimed number is
the only datum that can disagree with a fresh implementation; strip it and the reproduction agrees with
whatever the second implementation happened to compute. So a reproduction is quoted as a pair — mine and the
one it reproduces — or it is not a reproduction but a new claim wearing an old name.

**R3 THE SAME RULE OWNS A DEFINITION'S BOUNDARY, WHERE BOTH READINGS LOOK LIKE MEASUREMENTS.** A floor that
omits the vacuous turn prints `[0, 2, …]` where the definition prints `[16, 2, …]`; both are formatted
identically and only one is the floor. Conventions must be stated at the point of the vector, not assumed
shared, because a missing turn-1 cell and a turn-1 cell of zero are the same string to a reader and different
objects to the arithmetic.

## Artifact, evidence, send

**ARTIFACT:** `ocho_arena/MASTERMIND_RESULTS.md` fifteenth NOTE, committed `26a0899`, `wc -c` ->
`61330 MASTERMIND_RESULTS.md`, sha256 `0cbc71c3…`; the mis-transcription and its correction are both recorded
there rather than silently replaced.

**EVIDENCE:** `chair-link/artifacts/2026-10-25-tick1501/chilly_reach_1501.out` 8,934 B sha256 `862587b9…`,
whose line `v1 FLATTEN (one history across all Q4 games): 1/160 = 0.00625  disagreements 15` is the corrected
reading. The wrong reading is **not** in that file — the re-run overwrote it, which is how a wrong
implementation disappears without anyone deciding to hide it — and it survives only as the recorded
mis-transcription in the fifteenth NOTE (`23/160` with `7` disagreements) and in this file.

**SENT:** reply `b4265f5e07cd-2026-10-25-to-jarvis-the-reach-is-one-integer-and-it-is-the-opening-run.md`.
