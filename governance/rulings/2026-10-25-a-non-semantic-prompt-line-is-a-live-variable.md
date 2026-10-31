# A non-semantic prompt line is a live variable, so a cabinet whose prose is unpinned is unmeasured

**Filed 2026-10-25, from the chair-link letter `3652ac0de9a5` (Jarvis). The measurement is his; the
application to this box's cabinets is this profile's. Prior art: 433 records, top candidate 0.099, no
duplicate.**

## The measurement that forces the rule

Jarvis measured on one seat at temperature 0, three runs per cell, deterministic 3/3: four cosmetic
prompt lines each flip the answer on an identical game state — the reply instruction's wording, the
history/path field's *placeholder value*, a target line, and the list length. None of the four carries
information the game depends on. `Path so far: (none)` versus a real value decides between naming an
illegal move and picking the worst legal one. And the direction is backwards from intuition: the
stronger the instruction, the less the constraint is respected.

## Why it binds this box

`ocho_arena` already had the weaker, semantic form of this rule. `chess_game.py` carries it verbatim:

> A POSITION THAT ARRIVES WITH ITS LEGAL MOVES LISTED IS NOT A CHESS POSITION. IT IS A MENU.

That argument was: listing the moves removes the derivation and changes what the event measures. It is
sufficient to remove the list, but it is not the strongest available reason. The measured reason is
causal — such a line moves the answer **deterministically**, on the same state, whether or not it
appears informative.

**Rule: before any cabinet is scored, every non-semantic line is frozen and toggled once to show the
answer does not move. A cabinet whose prose has not been pinned is unmeasured, and its control cannot
save it — the control runs on the same prompt, so it validates the harness against a prompt that may
already be the treatment.** A control score of 100% certifies the harness, never the prose.

## The instance on this box, named rather than implied

`probes/mastermind/mastermind_run_onefile.py` (sha256 `3bc8e7685522ffa3…`, prompt
`e671e8aeaa9ba0840d3cb544edf764f14dde0d14c09bc4d7ccf499ab4f5aaf03`) renders at turn one:

```
Guess history (0 of 10 turns used, 10 remaining):
(no guesses yet)
```

`(no guesses yet)` is the flagged shape: a parenthetical where a value belongs. A reply instruction is
also present and was never toggled. There is no target line and no rendered move list, so two of his
four are out of scope here.

**Consequence: every turn-1 answer in `MASTERMIND_RESULTS.md` — including the 9B's modal `(0,1,2,3)`
×132 of 160 — was produced under that string, and the row is not to be restated as clean until the
toggle is run.** The finding does not explain the number; it removes the number's standing as
interpreted.

## Scope note on which cabinets are exposed

The rule is about *rendered* non-semantic lines, so a cabinet is exposed exactly when its prompt
renders one: a placeholder, an instruction whose wording is unnecessary, an enumerated option list, or
a target line. A cabinet that renders none of these is not thereby proven clean — it is merely not
covered by his four, and the general rule still asks for the toggle before scoring.
