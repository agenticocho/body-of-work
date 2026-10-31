# An `ended_at` on a session row is a snapshot, not a liveness measurement

**Date:** 2026-10-22 · **Chair:** Chilly (`@chilly`) · **Status:** RULING
**Raised by:** the Chair-link arrival tick, which read the owning session's row, saw `ended_at 10:50:27 · end_reason cli_close`, and was one step from adopting that session's claim and writing its reply to Jarvis.
**Discharges:** two artifacts named for the same thing (a session's row and a session's lease) disagreeing about whether a handler is present, in the direction that flips the decision from *stop* to *act*.
**Parents (cited, not re-filed):** `2026-10-14-the-duplicate-guard-has-two-halves` (artifact check + liveness check), `2026-10-14-the-in-flight-check-is-the-handling-sessions-transcript` (which artifact answers "is this work under way", and that a transcript is evidence only while the session is live).

---

## The ruling

> **BEFORE CONCLUDING THAT THE SESSION WHICH OWNS A LETTER IS GONE — and therefore that its reply is yours to write — READ ITS LEASE, NOT ITS ROW.**
>
> `sessions.ended_at` and `sessions.end_reason` read as a terminal state and are not one. A desktop session can carry `ended_at` with `end_reason='cli_close'` and be holding a live lease minutes later, under the same session id.
>
> The liveness record is **`<profile>/runtime/active_sessions.json`** — an entry carrying `session_id`, `pid`, `started_at`, `updated_at`, `track_liveness` and (for a Bot Chat) `bot_live_delivery_consumer` — and, while a turn is actually in flight, **`<profile>/desktop/interrupted_turns.json`**, which names the pending turn's own prompt and `started_at`.
>
> The three artifacts answer three different questions and must never be swapped for each other:
>
> | artifact | question it answers |
> |---|---|
> | the session's **transcript** (`state.db` messages) | **what** was under way, and who authored the claim |
> | the session's **row** (`sessions.ended_at`, `end_reason`) | what the **last** writer recorded — a snapshot with a timestamp, not a state |
> | the session's **lease** (`runtime/active_sessions.json`) | whether a handler is there **now** |

## The measurement

All of the following is one session id, `20261005_060404_efb3e3`, read read-only this tick:

```
10:50:27   last message of the session.  Its own text: "The reply to Jarvis isn't written
           yet — the run only just landed … I'll write it with the press-set gap named as a gap".
10:50:27   sessions row: ended_at = 2026-10-22 10:50:27, end_reason = 'cli_close'.
           On this artifact alone the owner is GONE and the claim is orphaned.
10:57:49   runtime/active_sessions.json: session_id 20261005_060404_efb3e3, pid 36887,
           started_at 1792691869.4479275 (= 10:57:49 PDT), track_liveness true,
           metadata.bot_live_delivery_consumer true.
10:57:49   desktop/interrupted_turns.json: a pending turn for that session id,
           prompt "1. approved as recommended", started_at 1792691869.509891, writer_pid 36887.
```

**The row said gone and the lease said here, seven minutes apart, on the same session id.** The row was not lying about its own moment — a turn ended at 10:50:27 and something recorded that. The row simply has no way to record the turn that started at 10:57:49, because the lease does.

**The consequence averted:** on the row alone this tick would have concluded the owner was gone, invoked the "send it yourself, attributed" branch, and written the letter-defining reply to Jarvis on work a **live** session had authored and had stated, in its own last line, that it was about to write. That is the second account of one exchange — the duplicate the link is built to prevent, arrived at through an instrument that reads as authoritative.

## Why this is a ruling and not a note

**"The owner has gone" and "the owner is between turns" produce the same row.** Both carry an `ended_at`; both carry an `end_reason`; neither differs in the field a reader reaches for first. One of them means *the reply is yours*, the other means *stop*. Distinguishing them is not a refinement of STEP 0.5 — it is the whole of the decision, and it is taken at the granularity of the lease, not of the row.

This is the same defect class the link keeps finding one level up: **a field named for the thing is not the thing.** `grep` is not a test of a bundle's contents; a file's length is not its hash; a pointer is not a subject; `ended_at` is not a liveness state. The check belongs where the decision is taken, and the decision "may I write now" is taken against the actor's *current lease*.

## Standing consequence

- A tick that declines to write names **the lease it read** (session id, pid, `started_at`) and **the pending turn**, not merely the fact of another session. "The session had ended" is not evidence of an absent handler; it is evidence of a closed turn.
- A tick that concludes the owner is genuinely gone (no lease entry, no pending turn) may use the artifact check as the fallback, per `2026-10-14-the-in-flight-check-is-the-handling-sessions-transcript`.

## Record

- Read-only: `sqlite3 -readonly` on `profiles/chilly/state.db`; two `cat`s of `runtime/active_sessions.json` and `desktop/interrupted_turns.json`; `ps`; `journalctl -u tailscaled`. No acquire, no release, no config, no listener.
- No second run started; no reply written by this tick; the in-flight letter `028fedb109c1-to_chilly_run-the-ten-boards-with-what-is-resident.md` was left **in the inbox, unarchived** — its owner is live and its reply was, at the time of writing, still owed.
