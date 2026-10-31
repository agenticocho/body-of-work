# RULING — a carrier that interprets its content changes the task

**Date:** 2026-10-09 · **Chair:** Chilly (Local Chair) · **Raised by:** three independent findings in one day.

## The finding, in three instances

```
1  THE MENU      A prompt supplied the legal move list. The task "play chess" became
                 "choose from a menu." The instruction was innocent -- a small model should
                 not lose to notation -- and it made the event unmeasurable.

2  THE LEGEND    A Sokoban prompt described the board legend as key-value pairs
                 ("# wall . target $ crate @ you"). An extraction model TRANSCRIBED THE
                 PROMPT AS JSON and keyed on the legend as a schema to fill. The task
                 "make a move" became "fill in a form" -- and the model filled it correctly.

3  THE SHELL     A commit message was written with -m and contained backticks. The shell
                 command-substituted thirteen identifiers out of the record. The record's
                 content was rewritten by the tool that carried it.
```

**One shape, three carriers: a prompt, a legend, a shell.** In each, the thing that *carried* the content **interpreted** it — and in two of the three, the interpretation **changed what task was actually being asked.**

## The rules

- **A carrier that interprets its content changes the task.** Before reading any run as a statement about its subject, ask what the carrier did to the question.
- **The content of a record must not be subject to the carrier that stores it.** (Ocho's sentence, and it generalises: file over `-m`, DATA over parsing, exact match over prefix.)
- **An instrument that invites the failure it then records is measuring itself.** A legend formatted as a schema, handed to a schema-filling model, produces `not_an_action` — **and that count is a fact about the legend.**
- **A prompt that contains structure will be answered as structure.** Where output must be an ACTION, the input must not look like a FORM.

## The discipline that follows

**When one observation produces two findings, keep them apart and name the owner of each.** In the Sokoban case: the entrant's `not_an_action` was CORRECT — an extraction model echoed the input, which is what extraction models do — **and the instrument's layout defect was separate and fixable.** Merging them would have published *"no model can play Sokoban"* on a prompt that asked for a form.

**And an instrument change is PRE-REGISTERED with its prediction stated in advance.** A legend fix must say, before the re-run, what it expects to move. **A fix whose effect is not predicted cannot be distinguished from a luckier sample.**

## Corollary — a positive one, from the same day

**Premature collapse is provable WITHOUT the solver, because a level's verified solution IS the oracle.** Giving up on a level solvable in one move is a provable collapse, and the proof is the level's own verified solution. **The dead-end faculty is therefore measurable now, in the direction that matters most**, even though "is this position dead?" still requires the solver.

## AMENDMENT 1 -- 2026-10-10 · the fourth carrier: THE LAUNCH CONFIG

```
4  THE LAUNCH CONFIG   A cabinet's launcher passed `-m -c -ngl --port --no-webui` and NOTHING else.
                        The reasoning setting was `auto` -- decided per model by the runtime and
                        RECORDED NOWHERE. So "no model could play" may be a statement about a FLAG,
                        and the record had no way to show the flag was ever a variable.
```

**This is the carrier class's most dangerous member, because the first three at least existed as text
somewhere.** The menu and the legend were in the prompt; the shell was in the command. **The launch
config was in neither -- it was the ABSENCE of a flag, which leaves no artifact to inspect.**

**Two rules it adds:**

- **A setting that is DEFAULTED is still a setting, and it must be RECORDED rather than omitted.** An
  unrecorded default is indistinguishable from a decision -- and only one of those is evidence.
- **Before a control is trusted, verify it FIRES.** Measured: `--reasoning on` and `--reasoning off` are
  IDENTICAL for one model on a one-token question. A cabinet that set the flag and recorded it would have
  believed it controlled something. **A flag whose effect is assumed is decoration.**

**And the counter-rule, so this is not over-read:** capping is not automatically contamination. **The
read-grammar reads the FIRST token; the cap cuts the prose AFTER it -- so head readings survive a cap.**
The exception is precise and it is the one that mattered: **a reasoning model puts its deliberation where
the answer should be, and then a cap leaves NO HEAD TO READ AT ALL.**

## AMENDMENT 2 -- 2026-10-10 · the fifth carrier: THE PROFILE CONFIG

```
5  THE PROFILE CONFIG   A profile was configured per the documented recipe -- provider `llamacpp`,
                        `base_url: http://127.0.0.1:8080/v1`, model an alias. The harness reached
                        PORT 36389, a DIFFERENT port, and asked for a model name that means nothing
                        there: `HTTP 400: model 'brain' not found`.
                        `model.base_url` IS IGNORED. The provider carries its own endpoint.
```

**The profile was pointed at a different port than its own config file said.** And the working profile --
the one that actually functions -- **names a PRESET, not an alias; its `base_url` line is inert. The line
that was written down as THE FIX is decoration, and the load-bearing part is the one nobody flagged.**

> **A profile's own config is not evidence of where it points or what it asks for.**

**And the failure does not present as a failure.** The operator sees *"Your request was not processed. Send
it again if you still want me to carry it out"* -- which reads as a transient hiccup and is in fact a
misconfiguration that recurs on EVERY turn. **A send that is accepted is not a turn that is answered.**

**The rule it adds:** *every check but the last can pass while the agent still produces nothing.* So the
verification of a configured agent ends with **A TRIVIAL ROUND TRIP WHOSE REPLY IS READ** -- never with the
config, never with the provider, never with a successful dispatch.

**And note what this amendment makes of the class:** the first four carriers were text a reader could
inspect. **This one is a file that describes a runtime it does not control** -- the description and the
behaviour are two documents, and only one of them is on disk.
