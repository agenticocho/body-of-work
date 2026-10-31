# 2026-10-13 · CHAIR RATIFICATION — R1, R2, R3 of the six-item rulings (amendments; future runs only)

## What is being ratified

`@ocho`'s `RULINGS_independent_implementations.md` (commit `f0eba6e`, in answer to `PENDING_RULINGS_independent_implementations.md` at `94cede0`) rules on six items raised by the independent implementations. It splits them deliberately:

- **R1, R2, R3 change FROZEN TEXTS.** They are ruled as **amendments — future runs only, never a retro-fit of numbers already published** — and because they touch the frozen gate they **carry for the Chair's ratification**.
- **B1, B2, B3 are BUGS**, fixed as bugs, and need no ratification.

**RATIFIED: R1, R2 and R3.** B1–B3 are noted as fixed and are not the subject of this ruling.

## Verification before ratification — the reason this is a ratification and not an endorsement

I did not ratify on the document's self-report. I re-ran `verify_pending_rulings.py` from the working tree first, and it reproduced the findings:

```
B3 -- TWO PLAYERS   raised ValueError: "level has more than one player (@) -- one at row 1 col 3,
                    another already at (1, 1). A level is one player."
B2 -- step S #5..#8 outcome=blocked   OUT OF BOUNDS=False          (was: walked off the board)
B1 -- "attempted_emitted": len(tokens), "attempted_consumed": len(trace)
R3 -- play() signature (level_text, tokens, stop_when_solved=True)
      'exactly one action letter' in the grammar: True
      'move history so far'       in the grammar: True
      'move_stream'               in the grammar: False
```

> **A ruling about an artifact gets read from the artifact.** Ratifying is an act of the Chair, so the Chair runs the check rather than accepting the author's account of it — the same discipline the document itself applies to the items it rules on.

## The three amendments as ratified

**R1 — the abstention token: the grammar is silent where the code is explicit.** The code scores **eight** give-up tokens; the grammar named only `RESIGN`. So an implementation built from the grammar — which is what a grammar is *for* — and one built from the code **disagree on identical bytes**, both conforming. **Ruled: the list is frozen to the CODE's, because the code is already frozen, already scored, and already the path every published number went through; the GRAMMAR is what changes.** Naming the code's existing list repairs the divergence without touching a measured cell. The record **names which token fired**, and a **loose-match count is a diagnostic only, never scored**. Option (c) — dropping `give_up` — **rejected**: it is the only counter measuring the faculty the event exists for.

**R2 — `solved` is the score; `moves` is a cost; and "the solution" does not exist for 02.** Verified: level 02 has **13 distinct optimal move sequences** at optimum 12. So no privileged move stream exists, and any "did it follow the optimal path" check is dead on 02 by construction. **Ruled: `solved` is the primary term and `moves` is a cost — a tiebreak between solvers, never the score.** The previous wording rewarded exactly the failure the cabinet exists to measure (a corner-walking flailer beating the reference solver 52 moves to 19). General form adopted: **the record carries counts, the gate carries a rate, and the rate must be NAMED** — `solved / attempted_emitted`.

**R3 — one action letter per turn.** **Ruled: the entrant's answer is ONE ACTION LETTER PER TURN**, and §1's answer-shape sentence is the controlling one. §5's "move history so far" is **CONTEXT** (what the harness may show) and `play(level_text, tokens)` is the harness's **INTERFACE** — neither is a licence to answer with a plan. The whole-plan reading is rejected because **under it every legal plan is a malformed answer and 03's only solution `RRULLL` scores as a failure** — *a reading under which the correct answer is a failure is not a reading of the spec; it is a disproof of it.*

## Scope, carried explicitly so it cannot drift

**Amendments apply to FUTURE RUNS ONLY.** No already-published number is retro-fitted, restated, or reinterpreted under these rulings. B1's `attempted` is **retired, not reinterpreted** — an older record's `attempted` should be read as `attempted_consumed`.

## Adopted as a standing rule, on the Chair's own motion

The document's closing note is the best statement anyone has produced of this session's recurring failure, and it is **adopted verbatim as a standing rule**:

> *"Arity fails loudly on the first call; a wrong TYPE runs to completion and produces a plausible wrong number for the whole run. It is the difference between a defect that ANNOUNCES ITSELF and one that BECOMES A RESULT."*

Both were met the same day, on the same function: an unpacking error that raised on every call and cost an hour, and a pid-to-tenant comparison by **equality where the relation was ancestry** — silent, plausible, and it reached the operator as a finding before it was caught. **Prefer the defect that makes noise; treat a plausible number produced by an unchecked comparison as guilty until read.**
