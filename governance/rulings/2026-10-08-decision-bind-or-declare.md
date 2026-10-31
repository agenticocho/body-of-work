# 2026-10-08 — DECISION: bind the contract, and declare the slot namespace rather than migrate it

**Authority:** the **operator**, on a recommendation from the Local Chair. **Status:** AUTHORISED — both items
applied, with the verification controls named below. **This supersedes nothing; it closes the two items the
arena arc left open.**

## Item 1 — BIND THE EXIT CODE (authorised)

`test_game_states.py` returns non-zero on a **NEW** game-contract violation and **nothing consumes that exit
code today** — no CI, no workflow, no systemd unit (verified, not assumed). **The check can fail and does; it
stops nothing.**

**Decision: bind it, hard, at admission.**

**Why, in the order that matters:**

1. **The discrimination is already built and already correct.** `NEW` is computed and gates the exit code;
   the **301 historical are counted separately** so a real regression cannot hide behind them. Binding
   changes **no logic** — only which consumer reads the result.
2. **Unbound, the check is a comment.** A gate on a thinned population, a condition that can never be met, a
   diagnostic block after an early return, a taxonomy with no slot for *neither* — today produced a whole
   family of instruments that could not fail. **This is the last one standing.**
3. **The cost is one call site.** `run_card.py` does not reference it today.
4. **And the escape hatch is the right shape, which is what makes a hard refuse safe:** if a future case is
   legitimate, **the remedy is to amend the contract** — a deliberate, recorded act — **never to ignore the
   exit code.** *The rule changes visibly rather than being circumvented.*

**Form:** invoke the check **before any model is spawned** and refuse on non-zero. **Admission, not during** —
the same shape as the weigh-in and C4's partition. **A warning would not be a gate.**

## Item 2 — DECLARE THE SLOT NAMESPACE, DO NOT MIGRATE (authorised)

`R1_fencing` / `R2_chess` / `R3_pitstop` name games. **The check inspects the `metaphor`/`game` FIELDS, so
they are legal** — but a slot name that names a game is a label whose referent has moved.

**Decision: keep the keys. Declare what they mean. Do not rename anything.**

**Why renaming is the wrong move:**

1. **The key is a join key in measured evidence.** `evaluate_v4.py:35` is `ROUND = "R1_fencing"` and the
   evaluator joins on that literal; `"R1_fencing"` appears **151 times** across 151 bundles. Renaming means
   rewriting keys in recorded bundles — **an overwrite of history**, refused twice today already (the empty
   bundles preserved rather than replaced; the 301 annotated rather than edited).
2. **A forward-only rename would split the join for nothing.** New cards would key differently from v2–v4, so
   every cross-version comparison would need a mapping **anyway** — which is precisely what declaring the
   table provides, at no cost to the record.
3. **And the project already treats a slot as a slot.** The evaluator's own warning —
   *"v3 and v4 item IDs are NOT comparable. Same slot, different item. Any cross-version sentence must name
   BOTH sides; a slot alone is [a claim about one item]"* — establishes that **a slot is not a referent.** So
   `R1_fencing` is already an opaque label everywhere it matters; the game name is residual decoration on a
   slot, **not a live claim.** The *claim* was the `metaphor` field, and that is gone forward-only.
4. **The debt is therefore cosmetic in the reading and expensive in the editing.**

**Form:** a **SLOTS table** in `GAME_CONTRACT.md` (slot ID → what it measures → the historical name, marked
as a costume kept for key stability); the round carries the description (**already written forward-only** as
`class` + `staged_as`); the existing 151 recover it by joining the round key to the task file, which now
carries both; and **a check that every round key is in the declared table**, with controls. **That check is
what makes "opaque ID" true rather than convenient.**

## The logic underneath both, and it is one logic

- **Item 1: the rule already exists and is already computed — give it a consumer.** *Make the assertion
  executable.*
- **Item 2: the label is stale but it is a stable key inside measured evidence — declare what it means
  rather than overwrite the record.** *A note may add information; it may never change an artifact's
  standing.*

**Enforcement belongs at admission, and the remedy for a stale label is a declaration, not an edit.** Neither
item touches the 151 bundles, and both are reversible: the bind by removing one call, the namespace by
editing one table.

---

# ADDENDUM — checking an agent-authored AUTHORITY document

One of the governed agents wrote a skill describing its own authority boundaries. **That is the one class of
self-improvement that should be verified rather than accepted, because an agent that authors its own
constraints could author them loosely** — and the failure would be invisible, since it would read as
compliance.

**The test is one question, and it is checkable in a single pass:**

> **Does the document grant its AUTHOR anything?**

**A document that grants its author nothing is a constraint and is safe to hold.** A document that grants its
author even one permission — to decide, to default, to self-certify, to proceed when the ratifier is silent —
**is a claim to authority wearing the clothes of a boundary**, and it should be returned rather than filed.

**Verified against the source: this one grants nothing.** Every rule narrows the author's room — no
self-certification, no defaulting when the ratifier is unreachable, no applying what the spec does not cover,
no unreported decisions. It is a **restatement**, and where it sharpens the source it sharpens it *toward* the
constraint: *"drafting is not deciding — produce the artifact, state its premise, name the one-line flip, and
stop short of the act that changes your own obligations."*

**Two consequences worth keeping:**

1. **The boundaries originate with the operator and the Chair; an agent may restate them, never define them.**
   A restatement can be checked against its source. **A definition has no source to check it against** — which
   is precisely why the second is not the agent's to write.
2. **And the direction of a self-authored constraint tells you whether to trust it.** An agent writing its own
   authority document under a real ceiling will produce something **smaller than the ceiling**, because the
   cost of overstepping is borne by the author. **A self-authored boundary that expands the author's room is
   evidence about the author, not about the boundary.**
