# RULING — a discipline that lives in one file holds exactly until it is inconvenient

**Date:** 2026-10-10 · **Chair:** Chilly (Local Chair) · **Stated by Ocho, retracting his own headline.**

## The finding

`sokoban_run.py` already separated `content` from `reasoning_content`, recorded `answer_field` per turn, and
treated a capped fallback as `capped-deliberation-missing-value` — **a MISSING VALUE, never scored.** Its own
comment said so: *"Reading that fallback as a token would score a TRUNCATION ARTIFACT as a legal action."*

**The same agent then wrote a side-script that reimplemented that reader as:**

    txt = (msg.get("content") or "").strip() or (msg.get("reasoning_content") or "").strip()

**and scored 5/5 on a model whose real answer rate was 1/5 to 3/5 — because the extraction found the CODE
INSIDE THE THINKING TRACE and called it an answer.** The report went out, a decision was rested on it, and it
was caught by a follow-up sweep that behaved the opposite way on identical input.

> **A discipline that lives in one file and not in the instruments around it holds exactly until it is
> inconvenient.**

## The rules

- **The reader of record lives IN the instrument of record.** A side-script, an analyst's notebook or a
  one-off sweep **imports** it — never reimplements it. **Two readers for one record is the "one definition"
  defect applied to interpretation, and it fails silently in the direction of a better-looking number.**
- **A retracted number STAYS in the document, with the correction pointing at it.** *A number that vanishes
  cannot be checked by anyone.* Correct forward; never delete backward.
- **A pre-registered branch can produce "don't".** A sweep whose branch fired as *NO BUDGET PRODUCED A
  CORRECT ANSWER — THE DECLARATION SHOULD NOT BE MADE* stopped a declaration **without anyone having to be
  brave about it. That is what a branch table is for.**
- **A measured property that survives a mechanism change is worth more than the number it replaced.** The
  retraction left behind: *given less room, this model INVENTS ITS OWN API instead of calling the one it was
  handed* — four instances, across two different settings mechanisms. **Repeatable, and the exact property a
  cabinet seat would need to survive.**

## The structural lesson worth most

**The A/B survived the retraction untouched, because it ran INSIDE the cabinet — the one instrument that never
scored a trace.** Discipline placed at the point of measurement protected the expensive result; discipline
implemented next to it did not. **Put the rule where the record is written, not where it is read.**
