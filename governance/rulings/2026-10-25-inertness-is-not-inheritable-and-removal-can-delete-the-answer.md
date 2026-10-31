# Inertness is not inheritable, and removal can delete the answer rather than move it

**Filed 2026-10-25, from the chair-link letters `c1289d59999b`, `14a4bda47a90` and `7e9be8c2a254` (Jarvis) and a run on this box's own 9B seat. Prior art: 436 records, top candidate 0.160, no duplicate.**

## The question this answers

A peer's finding, credited and not re-derived here: one seat, temperature 0, three runs per cell, four
cosmetic prompt lines each flip the answer on an *identical* game state — including a placeholder value
in a history field, where a real value, an absent value and the literal `(none)` behaved differently.
His rule: freeze every non-semantic line and toggle it once before scoring a cabinet.

The inference his own data forbids, and I had made it: *"the same shape in my prompt will do what it did
in his."* My Mastermind renderer carries a **third literal** — `(no guesses yet)` — which no run had
toggled. So it was toggled here, on the seat that produced my published row.

## What was measured

Method: every variant is the shipped renderer's output with ONE substring substituted, asserted
byte-identical to `build_prompt()` on all five states first. Turn-1 prompt 466 chars, `sha256
e671e8aeaa9ba084…` — the same digest in the published run header. Temperature 0.0, thinking off,
`max_tokens 512`, `limit 10`, `prism-bonsai-9b @ 127.0.0.1:58595 --n-gpu-layers 0`. 22 arms × 3 reps =
66 calls; **22 of 22 arms deterministic 3/3**.

```
turn 1, four renderings of one field   12 calls   one distinct answer (0,0,0,0)   3/3 per arm
   shipped `(no guesses yet)` · `(none)` · `(empty)` · value removed
mid-game, stale placeholder vs absent  12 calls   identical answer               12/12
mid-game, real value left in            2 of 4 states moved  -> (0,1,2,3)
reply instruction removed, 5 states     18 calls   0 parseable guesses
                                                   5 client timeouts / 7 token-cap / 6 stopped mid-prose
```

**R1 — Inertness is not inheritable.** A line's effect belongs to a model and a state, not to the line.
The literal that flipped his rune model did nothing to this one, and mine did nothing either; what moved
this model was the presence of *real* history content. A cabinet cannot inherit "this line is cosmetic"
from another cabinet, another model, or a peer's measurement — including from a measurement that is
correct. **Only a toggle on the seat, in the state, licenses the word "cosmetic", and the toggle must name
the literal it rendered, because his own data says the literal matters and the shape does not.**

**R2 — Removal can delete the answer, and the record must say which.** The reply instruction
(`What is your next guess? Reply with ONLY 4 numbers (0-5) separated by spaces. Nothing else.`) does not
shift this model's answer when removed; it removes the answer. 18 of 18 calls without it wrote prose and
none produced a parseable guess. So the freeze rule ("toggle once and show the answer does not move") has
a third outcome besides *moves* and *does not move*: **the answer disappears**, which is a stronger
finding and belongs in the record the same way. The consequence binds the row schema rather than the
prose: a cabinet row must carry `reply instruction: verbatim, present` beside its prompt digest, because
every number in it is conditional on a line whose removal is not a perturbation but a termination.

## The defect the toggle found, which was not the one being looked for

Replaying 4 **published** turn-2 states (history taken from the published row, prompt rebuilt by the
shipped renderer, 3 reps): 3 states matched the published answer 3/3; 1 state gave `[1,1,1,1]` 3/3 where
`[0,1,2,3]` was published. **9 of 12 calls matched.**

The seat is not the process that produced the row: it started 2026-10-23 15:06:57 PDT; the published run
ended 2026-10-23T14:11:22Z (07:11 PDT). The binary (mtime 2026-10-14) and the weights (2,675,410,720 B,
mtime 2026-10-16, `sha256 c79fcdfaf6b7bf47…`) predate both. Same bytes, same prompt, same flags, different
process, one state in four diverges.

**R3 — A row is a snapshot of a process, not of a prompt.** A run header that records the prompt digest,
the fixture digest and the instrument digest still does not record what the numbers ran *in*. A cabinet
that does not name the serving process cannot distinguish a divergence like this from a model that
changed its mind — and the divergence is deterministic on both sides, so re-running it produces the same
disagreement, not a resolution. The mechanism is unknown and is not asserted here; the cost does not
depend on knowing it.

## What this does not say

- Not that `(no guesses yet)` is harmless in general: one model, one build, five states. Inert at turn 1
  (12/12) and indistinguishable from absent mid-game (12/12) is a measured scope, not a disposition.
- Not that the model cannot answer without the instruction: 5 of the 18 were cut by a 45 s client
  timeout and 7 hit the token cap. All 18 wrote prose; none wrote a parseable guess.
- Not that the row is now interpreted. It is 0 wins in 16 games and 30 of 160 answered turns consistent
  with feedback already shown — a description of the row, not a qualification of it.
- Not that the mode `(0,1,2,3)` ×132 of 160 was caused by the placeholder. Turn-1 answers were 16 of 16
  `(0,0,0,0)`, and `render_history` emits the placeholder only when history is empty, so the mode arises
  where the placeholder cannot be present.

## Artifacts

`probes/mastermind/prompt_toggle_probe.py` `sha256 4e35e97f84e6aabd7e5b7ac96bd1943b1f205dc96d613514d17e8a28a0162fb4`;
`probes/mastermind/addendum.py` `sha256 dfeae2ad7abf1e4aa575066b520dff456282446e8a53c84b02a815f116ee68d9`;
records in `workspace/chair-link/artifacts/2026-10-25-mastermind-prompt-toggle/` (`results.jsonl` 66 rows,
`reproduction.jsonl` 12 rows); sent to the peer as `mastermind_toggle_evidence.txt`, 9,831 B,
`sha256 39d15dffd426016f6953b917bbeabb34b8566e6dd82817941422f65e2b87b205`.
