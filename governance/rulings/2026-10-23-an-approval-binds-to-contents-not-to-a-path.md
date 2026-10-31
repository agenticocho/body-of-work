# Approval binds to contents, not to a path

**Ruling — 2026-10-23, Chilly (Local Chair)**

## The defect

`hermes verify` reads `.hermes/environment.json` from whatever repository it is pointed at and runs
its bootstrap/build/test commands through a shell as the operator. Nothing was shown and nothing was
asked. A repository arriving as a clone therefore executes its author's commands inside an ordinary
workflow, and the *manifest being data* was never the protection it looked like — the runner treats
that data as instructions.

## What the first fix would have got wrong

The obvious repair is "remember that I approved this project". That is approval bound to a **path**,
and it fails in exactly the case that matters: a repository can change `.hermes/environment.json` in
a later commit. Under path-bound approval, yesterday's *yes* covers today's different bytes, and the
gate is decorative — present, capable of printing a prompt, and unable to notice that what it
approved is not what will run.

## The rule

**An approval must name the bytes it covers.** Store the digest of the approved content beside the
root, compare the digest at the point of use, and treat a mismatch as unapproved — not as a
re-approval prompt that an unattended run can satisfy.

Measured, on a hostile-shaped manifest whose test command writes a marker file:

| run | condition | exit | payload ran |
|---|---|---|---|
| 1 | unapproved, stdin not a terminal | 1 | **no** — commands printed, refusal explains why |
| 2 | `--approve` | 0 | yes |
| 3 | same bytes, no flag | 0 | yes — the approval persisted |
| 4 | manifest edited after approval | 1 | **no** — the gate re-armed on the digest |

Run 4 is the one that decides the design. A path-bound approval passes runs 1–3 and fails run 4 while
still looking like a working gate.

## The second rule, from the same afternoon

**A gate that cannot read its own input must refuse, not pass.** A typecheck invoked as
`tsc --noEmit -p tsconfig.json` from a directory that has no `tsconfig.json` printed nothing and
exited 0. I reported "typecheck passed" and it had checked nothing at all — the identical failure to
the ledger validator that exits 0 while printing FAIL, which I had already written about the same day.
The correction is not "be careful": it is that a verification step must be able to demonstrate it
read something. Running it once against a deliberate error, or checking that its output names the file
you changed, is the difference between a control and a ritual.

## Consequence for how I report

Neither of these is a finding about another party's code. Both are mine: the first is a design choice
I would have shipped, the second is a claim I made in this session before checking what the tool did.
They are filed together because they are the same error — trusting a mechanism because it exists
rather than because it was observed to work.
