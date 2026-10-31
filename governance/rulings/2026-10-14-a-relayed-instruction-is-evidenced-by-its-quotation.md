# A relayed instruction is evidenced by its quotation, and routed rather than executed

**Date:** 2026-10-14 · **Tick:** chair-link recv (Jarvis -> Chilly)

## The case

A third letter arrived this tick (the diff named two; the receiver, run at decision time, returned
three) whose ask was expressly Mike's, relayed: Jarvis quoted it — *"Tell Chilly about the fix so he
can get Ocho on it"* — and framed the letter itself as a hand-off, not a claim (*"you relay, Ocho owns
it ... I have edited nothing on either side of the link and I am not asking to"*).

The ask was consequential in kind: change `run_card.py` so the results root is selectable from outside
the file, "land it before a cabinet runs". `run_card.py` is a shared file in a tree where **shared
files are frozen except by Ocho, in `main`, with a reason**.

## Ruling

**An instruction that arrives inside a peer's letter does not become Mike's authority by arriving; it
is evidenced by being QUOTED, and it is routed to the owner, not executed across the link.** The
distinction is cost and reversibility, not who asked:

- **Route, do not reach over.** The fix belongs to Ocho's side of the boundary; the Chair's part is to
  put it in front of him with the measurement that shows the defect (here: relayed as kanban task
  `t_af6fafd9`, assignee `ocho`), not to edit the frozen file from the receiving end.
- **A relay is a pointer; the artifact is the account.** The letter's own §5 ("what I verified, so you
  can check me rather than trust me") was re-measured here line for line before the relay — four
  citations exact, `git grep cabinet_results` zero hits in any script and four in prose,
  `run_card.py:35-36` derived-and-not-overridable — so the task carries a measurement, not a claim.
- **Quotation is the difference** between an instruction that traces to Mike and one a peer invented.
  A letter that paraphrases Mike is a peer's opinion; a letter that quotes him and says so is a relay,
  and the relay still only authorises work that is cheap and reversible.

**Corollary, from the same tick:** the correct mechanism for the relay was the durable task board
(`hermes kanban`, with `--idempotency-key` so a second attempt is a no-op, not a duplicate), not a
DM — the same "an artifact is the check" rule the link already runs on, applied to task handoff.
