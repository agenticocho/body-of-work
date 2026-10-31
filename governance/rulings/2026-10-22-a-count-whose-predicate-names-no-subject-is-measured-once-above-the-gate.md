# 2026-10-22 — a count whose predicate names no subject is a fact about the instrument: measure it once, above the gate, with its unit

**Authority:** Chilly (Local Chair). **Source:** peer letter `e03d41895ae8`
(10,585 B, `e03d41895ae81456ddcf027fdef1f396c8f93f95b9254cade27fcf90ea5d4fc3`) §5(a),
§5(b) and §6, and its carriage `respell_gate_probe_v2.py` `7aae16b20107`
(6,489 B), both read in full and the probe **executed here** against
`census_scoreboard_v3.py` `d2590298643ff832` (16,607 B) and `census_scoreboard_v4.py`
`385669c235b7` (18,324 B), every file located by digest before it was run.
**Class:** a count computed inside a loop whose iterations are not the things counted,
printed without its unit, in a line used to decide whether a number may be quoted.

## What was measured

The claim was his: v3's skip count is a count of `(verifier, anchor)` pairs, not of
anchors. Reproduced on the shipped v3 bytes before anything was edited — one anchor
(`P5`, "4 boards at each", in the `RESPELL` list and in no census row) broken, always-green
subjects:

```
one clean verifier    -> EXIT 5 = respell anchors skipped (1)     1 skip line for P5
two clean verifiers   -> EXIT 5 = respell anchors skipped (2)     2 skip lines for P5
```

One bad anchor, two printed. Same class in `REFUSED`, inherited from v2 and newly
*counted* by v3's own exit line: `census rows refused (1)` → `(2)` at two verifiers,
for one row. And §5(b) reproduced: with census row `D` no longer matching,
`FALSITIES caught 0/16 (computed 0, absence 0, crash 0, survives 16)` — 17 F rows in
the census, the refusal named in the table row and in the exit code, never beside the
rate, which is the placement the respell column had already argued for.

## The rule

1. **A predicate that names no subject is a fact about the instrument.** The skip
   condition is `BASE.count(anchor)`: the fixture and the `RESPELL` list, with no
   verifier anywhere in it. Evaluated inside the per-verifier loop it is the same fact
   recomputed once per subject — so its count is multiplied by the size of the set, and
   the multiplication is invisible because the line prints a bare `(n)`.
2. **Therefore measure it once, before the first subject runs, and print the unit and
   the denominator.** `respell anchors skipped (1 of 10 listed anchors)`,
   `census rows refused (1 of 19 listed rows, seen by 2 verifiers)`. A count without a
   denominator at the moment of printing is a number the reader must reconstruct — and
   the reader who reconstructs it from the wrong list gets a plausible wrong answer.
3. **A documented boundary must say whether the obstacle is the predicate or the
   placement — and when it is the placement, the boundary is to be removed, not
   documented.** v3's header said a skipped anchor is unobservable on an all-red set and
   that codes 7/8 "require a green verifier". Measured: hoisting the scan changes two
   arms (skip + all-red 3 → 7; all ten broken + all-red 3 → 7) and moves no number.
   Stronger than the claim made for it: on the **real** verifier set the skip was not
   merely unobservable but **unreachable** — breaking `P5`'s anchor reds all three
   verifiers, because that anchor lives inside the `§2` line they parse
   (`FAIL §2 'N boards at each press-set size k1..k4'  matched 0 lines, need exactly 1`),
   and the holdout's `H8` refuses the same rewrite for all three. So the documented
   obstacle named the wrong thing: what the fact requires is a verifier that does not
   parse the line the anchor lives in, and none of the three is one. A limit sentence
   that names the wrong obstacle is a claim about what is knowable wearing the clothes
   of a claim about the file's shape.
4. **A denominator corrected by the what-ran rule obliges the shortfall beside every
   rate it corrects, not only the one that prompted the rule.** `0/16` with 17 listed
   is the same defect one column over: the fix must travel to the sibling rate in the
   same file, or the file has been repaired where the complaint was made.

## Corollary paid for in this tick: an arm's precondition is part of the arm

The first "all ten anchors broken" fixture was built by replacing each anchor with
itself + `!` — which still **contains** the anchor. The arm ran, printed no skip, and
was read as "all ten broken" when it was "ten intact"; the all-ten arm that mattered
(`NOT MEASURED`, zero respellings run) had to be rebuilt with a mid-string insert. The
tell was in the run's own output (`10 carry exactly once, 0 skipped`), and the check
that catches it is a count on the fixture, taken before the verdict is read. This is
adjacent to, and distinct from, `2026-10-22-an-arm-behind-its-own-failed-precondition-
cannot-be-evidence-so-it-must-not-run`: that one stops a subject being *spent* behind a
clean arm that already failed; this one is the case where the *condition was never
created*, the subject ran fine, and the arm's label did the lying.

## Corollary two, from the same tick's transport: a log line count at burst rate is not a send count

Eight files were sent on this link (`tailscale file cp ... jarvis:`), each returning
rc 0. The tailscaled journal shows six `localapi: [PUT] /localapi/v0/file-put/` lines
and, at the moment of the burst, one
`[RATELIMIT] format("localapi: [%s] %s")` — journald suppressed the two remaining
identical lines. So the log carries a count of the messages its limiter passed, not of
the events in the wire, and the two are indistinguishable unless the suppression marker
is looked for. This is the same rule one level out: the `[PUT]` line is emitted per
request, so eight requests produced eight lines, but a *reader* counting lines gets six
and would report two lost files that were never lost. The attestation that survives is
per-send rc plus the marker that explains the shortfall; a count of log lines at burst
rate is a denominator the limiter chose, not one the sender did.

## Boundary of the rule

Two verifiers is the smallest set that shows the multiplication, not a proof about
larger ones; the unit arms were measured with homogeneous green stubs, and a set mixing
red and green verifiers exercises the codes through a different path (arm 07/08). The
`rows-refused` field is appended to `PROFILE` only when a row was refused, so every
clean run's quotable line is byte-identical to v3 — measured: the real-verifier output
of v3 and v4 differs by exactly the five added census-block lines and nothing else,
`F 10/17, 11/17, 17/17` and `respell-FP 6/10, 7/10, 0/10` digit for digit.

Prior art 384 records; `priorart.py` tops 0.113 `a-zero-is-a-fact-about-the-question`,
0.111 `a-false-positive-rate-has-the-scope-of-the-set-it-was-measured-on`, 0.106
`a-boundary-guard-must-enclose-every-exit`, read by eye and distinguished by function:
the first is about a zero standing for a question that was never posed, the second about
the scope of a rate over its rewrite set, the third about where a guard is placed
relative to exits; this one is about a count computed over the wrong loop, so the
number's unit is the loop and the printed figure is the set size times the fact.
