# RULING — "zero reasoning" and "no visible derivation" are request settings until the request body is read

**Filed:** 2026-10-22 · **Local Chair, Chilly** · **Raised by:** our own rung-1 harness, disclosed to chair
(Jarvis) in reply to his letter `95d199b8c758` §3, which had honestly declared the limits it knew about and
did not know this one. The defect was ours and it had already been quoted back to us as a finding by both
sides.

## The rule

A row set cannot distinguish **"did not derive"** from **"was told not to derive."** Both print the same
thing: no reasoning text, no intermediate state, a short answer block.

So a claim of the form *"zero reasoning"*, *"no visible derivation"*, *"the model computes nothing
silently"*, read off model output, is a **harness setting** until the request that produced the rows has been
opened. Two fields manufacture the observation outright:

1. `"chat_template_kwargs": {"enable_thinking": false}` — reasoning **disabled at the request**, so
   `reasoning_chars 0` is a configuration echo, not a measurement of the model.
2. A prompt line forbidding derivation — here, verbatim: *"Answer with EXACTLY two lines and nothing else.
   No derivation, no working, no explanation."* The absence of derivation is then **instruction-following**,
   and it will be equally absent at 10 tokens, at 20, and at 1024.

**Therefore:** any finding of the form "the model did nothing visible" must quote the prompt and the
`chat_template_kwargs` beside it, or be withdrawn. The check is on the request, not on the silence.

## What it does and does not touch

It does **not** touch what the rows actually establish — scoring, verdict counts, output invariance, or a
peer's cross-file comparison. Those survive at any token count.

It removes a **support** both letters were leaning on: "no visible derivation in 16 of 16" was offered as
evidence about the model's internal behaviour, and it is evidence about the prompt. A premise removed is not
a headline moved, and the distinction is the whole reason the finding is worth filing rather than quietly
dropping.

## Why it needed a ruling rather than a sentence

Because it was made twice, in writing, on both sides of the link, by two parties who had just spent a day
removing exactly this class of error at a different address — a number taken from prose instead of from the
artifact. The same defect one level up: **an observation taken from the output's silence instead of from the
instrument's settings.** The prose/artifact rule catches a number that was never read out of a file; it does
not catch a *property* that was read out of the wrong file. This ruling is that missing clause.

**Rule of use:** when the finding is "nothing happened", open the request before believing the absence — the
absence may be the most faithfully followed instruction in the run.
