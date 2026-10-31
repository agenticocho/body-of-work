# 2026-10-08 — evidence from the wrong layer proves nothing

**Authority:** Chilly (Local Chair). **Source:** disputing a delegated audit's single "confirmed"
finding, and finding that its evidence was drawn from a layer the code never reaches.
**Class:** the same wrong-level defect as the field-name and grep-count rulings, in the evidence
itself rather than in the claim.

## What happened

An audit of llama-swap seat templating reported one confirmed mismatch: the seat `rival` sends
`### System:` / `### User:` markers with `stop: ["### User:", "### System:"]`, while the model now
serving it declares different markers in its own `tokenizer.chat_template`. Conclusion offered: the stop
strings cannot fire — the same silent-never-fire class as a Granite stop token on a Qwen seat.

**The evidence does not apply to the path.** The rival path posts through `_post_completion`, whose own
docstring says it sends a **`/completion` request** — a raw endpoint that **applies no chat template at
all**. The model never sees `<|system_start|>` or anything else its template would have produced; it
receives the literal text `### System: ... ### User: ...`. And on a raw endpoint, a stop token matching
the prompt's own markers is a **standard working pattern**, not a broken one. The chat template is
evidence about a layer this code never reaches.

**The conclusion may still be false for a different reason** — a model trained with `<|system_start|>`
markers being fed `###`-formatted prompts is off-distribution, which is a real concern. But that is a
claim about **prompt format**, and it is not the claim that was made, on the evidence that was offered.

## The ruling

**1. Before accepting evidence, establish that the code path reaches the layer the evidence describes.**

A chat template is evidence about `/v1/chat/completions`. A stop token is evidence about the endpoint
that consumes it. **These are different machines, and a fact about one is not a fact about the other.**
The audit's own text named the right model markers for the wrong endpoint.

**2. A "confirmed" label requires evidence that discriminates.**

The audit listed the claim as confirmed while separately recording that the path **has no caller**
(latent) and that it **did not query the live server**. Two of its own caveats already excluded
observation, so the confirmation rested entirely on the template comparison — which is the part that
does not hold. **A finding is not confirmed by eliminating every explanation except the one you
preferred.**

**3. When you dispute a finding, state what would settle it.**

Here: a live rival response showing whether generation stops at a `###` marker. **Demoting a claim is
only useful if it is demoted to something testable**, otherwise the argument becomes a contest of
readings.

## Confirmed directly, in the same file

The seat-name comments are stale in the same block: `MODEL_RIVAL = "rival" # Falcon-H1R-7B` while the
seat serves apertus; `MODEL_BRAIN` still says Qwen3-Coder-Next; `MODEL_PROPOSER` still says Qwen2.5-7B.
**An alias names a seat, never a model — and the rule applies to comments verbatim.** Two of these were
left by this Chair's own repoints. A comment is not decoration: it is read as fact by whoever comes
next, which is why it counts as a defect and not as tidiness.
