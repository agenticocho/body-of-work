# 2026-10-08 — the template outlives the model: a seat's prompt/stop must be re-derived when its model changes

**Authority:** Chilly (Local Chair). **Source:** a read-only seat audit of
`/home/chilly1/chilly_containment/molty_critic.py` extended to the seats it does not serve, prompted by the
already-fixed critic1 stop-token defect. **Class:** stored prompt templates and stop tokens that are matched to
the model a seat *used to serve*. Extends `2026-10-08-a-condition-that-can-never-be-met.md` (instance 5 below).

## What the audit found, in one line

The three critic seats are now correct. The **other** seats are not served by molty_critic.py at all — they are
served by `planner_client.py` (brain / proposer / helper / rival) and `agents/ocho/call_ocho_planner.py`
(ocho-planner*). Following the seat to the module that actually serves it is where the fifth instance lives.

## The fifth instance of "a condition that can never be met"

**Seat `rival`.** `planner_client.py` `call_falcon` sends a `### System:` / `### User:` / `### Assistant:`
prompt with `"stop": ["### User:", "### System:"]` (L942–951) to `MODEL_RIVAL`. The seat now serves
`apertus-8b-financial-reasoner-v1.Q4_K_M.gguf` (llama-swap.yaml L75). That model's own
`tokenizer.chat_template` (read from the GGUF) emits `<|system_start|>`, `<|user_start|>`,
`<|assistant_start|>` and their `_end` partners — **and contains `### User:` / `### System:` zero times.** So
the stop token cannot fire, exactly as `<|endoftext|>` could not fire on Qwen.

**It is worse than a one-model slip:** the function's own docstring (L939–940) says the seat requires
`<|System|>` / `<|User|>` markers, while the code sends `### System:` / `### User:`. The template was already
inconsistent with its stated model **before** the swap, and the swap made it squarely wrong.

## The two new rules

**1. A stored template or stop token belongs to the SEAT, and the seat's model moves — so the pair must be
re-derived at every model swap, or the swap is incomplete.** critic1's `<|endoftext|>` and rival's
`### User:` are the same event two seats apart: a token matched to the retired model. A model swap is not done
when llama-swap.yaml points at the new file; it is done when every caller that formats a prompt for that seat
has been re-checked against the new model's own chat template.

**2. "No template/stop is applied" is not the same as "correct" — read it as its own finding.** Seat `helper`
passes **no `stop` key at all** (`call_helper_model`, L925–929). Its ChatML wrapper matches LFM2 fine, so it is
*not* an emittable-token mismatch — but nothing enforces the `<|im_end|>` boundary the wrapper writes. The
brief's phrase holds: *a setting that looks handled and is not.* A missing stop and a wrong stop are different
defects and must be reported separately, not merged into one verdict.

## Corollaries carried from the audit

- **The molty_critic tables are not missing rows for the other seats** — those seats are simply not in that
  file. "The table covers only the critics" is true and benign; the review question is *where else* the seat is
  served. Follow the seat, not the file.
- **A default fallthrough is a silent decision.** `molty_critic.py` L327–328 hands any unrecognised critic id
  `_wrap_chatml` + `["<|im_end|>"]` with no error. A new seat added to the panel without a table row will not
  fail — it will quietly get someone else's template.
- **A definition is not a call.** `call_falcon` has **no caller in the repository**; the rival mismatch is
  latent (defined, not observed firing). Report that distinction — a confirmed defect in a dead path and a
  confirmed defect in a live path are different risks, and merging them overstates the first and understates
  nothing about the second.
- **A model's emittable tokens are read from its own artefact, not assumed from its family name.** The rival
  finding rests on the GGUF `tokenizer.chat_template` string, not on "it's an 8B so it's probably ChatML".

## What is clean (a clean result is a result)

`critic1`, `critic2`, `critic3`, `brain`, `proposer`, and all four `ocho-planner*` seats: the template reachable
by the served model matches, and every stop token sent is one the model can emit. Reported plainly rather than
padded — a clean seat and a broken seat in one table is the point of the table.

## Instance

Deliverable: `/home/chilly1/.hermes/workspace/AUDIT_seat_templating.md`. No file under audit modified; no
service touched; no model launched. Evidence is file+line plus quoted content (the GGUF chat-template blob is
quoted in the report).
