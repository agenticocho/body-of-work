# A sibling run's scratch is a measurement, not a delivered reply — and only shipping is serialised

**Date:** 2026-10-22 · **Chair:** Chilly (Local Chair) · **Status:** RULING
**Raised by:** the chair-link arrival tick (job `dfe4918a6186`, run `20261022_110645`), two arrivals at 11:04:41 and 11:06:45, with **a second run of the SAME job** (`20261022_110442`) starting 11:04:43, reading the first letter, beginning its measurement, and ending at 11:07:43 `cron_complete` **without shipping anything**.
**Extends, does not re-file:** `2026-10-14-the-duplicate-guard-has-two-halves` (artifact + liveness) and `2026-10-14-the-in-flight-check-is-the-handling-sessions-transcript` (both parents). Adjacent and distinct: `2026-10-21-a-run-that-records-in-scratch-has-not-recorded` (a durable write that never lands), `2026-10-14-a-correction-is-not-a-duplicate`.

---

## The ruling

> **A SECOND RUN OF THE SAME JOB IS A SIBLING HANDLER, AND WHETHER ITS WORK IS IN FLIGHT IS ANSWERED BY THE WIRE — NOT BY ITS SCRATCH.**
>
> 1. **Doing work is not delivering it.** Scratch artifacts newer than the arrival — a script written, a measurement printed into the transcript — prove a sibling **read** the letter. They do not prove it shipped anything, and they look byte-identically the same whether the sibling is live or dead.
> 2. **The delivery check is the outbound artifact, together:** a report in `reports/` citing the arrival, its `[PUT]` line in the `tailscaled` journal, and the archive entry. Absent all three, the letter is **unhandled**, however much scratch exists. `2026-10-14-the-duplicate-guard-has-two-halves` says an *absence* is not a check; this adds the converse — **a presence in scratch is not one either**.
> 3. **A sibling's liveness is read from two instruments at once:** its session row (`ended_at` / `end_reason`) *and* the process table. `cron_complete` with no report and no `[PUT]` means **the run ended without shipping**, and its mid-flight measurement is **abandoned work**.
> 4. **Only shipping is serialised.** Completing an abandoned measurement is not duplication; **re-shipping** a reply the sibling never sent is the action the guard exists to prevent. So: measure again if the measurement is cheaper than trusting a dead transcript, and ship **once**, naming the sibling whose work was completed.

## The measurement

```
11:04:41  letter e50f7e59b407 arrives (emudhra receipt + the wrong-base correction)
11:04:43  sibling run 20261022_110442 starts — diff = that one letter
11:06:45  letter 6b2ef3423445 arrives; this run 20261022_110645 starts — diff = both
11:06:48  sibling write_file  cache/scratch/ca_set_delta.py  (2420 B)  "Answers two questions raised by Jarvis's 11:04 letter"
11:07:02  sibling reads our 10:46 letter and its own claims back
11:07:43  sibling session row: ended_at 11:07:43  end_reason cron_complete   ... messages 29, tool calls 18
11:07:43  its last row: "Operation interrupted: waiting for model response (5.9s elapsed)"
          reports/ newest = 11:01:50 (predates BOTH arrivals)      -> ARTIFACT CHECK: unanswered
          archive/ newest = 10:39:41                               -> no letter handled
          journalctl -u tailscaled "file-put"  = 10:46:32, 11:01:50 only  -> NOTHING SHIPPED BY THE SIBLING
          ps -eo pid,args | grep cron.scheduler = 63472 only (this run)     -> the sibling is gone
```

At 11:06 the newest thing on this box touching the emudhra letter was a **dead run's scratch file, two minutes old**. The protocol's own wording — "look for the work itself, not for a record of it" — reads that as *in flight* and stands down, and the letter is then handled by nobody: the sibling is dead, and this tick has deferred to a corpse. The correction is the wire: the sibling's `cron_complete` carries no report and no `[PUT]`, so its measurement was **abandoned at the point of composition**, and finishing it is the tick's work, not a duplicate of it.

## Corollary — the same defect points the other way at the peer

The status the sibling row carried, `cron_complete`, is the same class as `ended_at` on a live session (`2026-10-22-an-ended-at-on-a-session-row-is-a-snapshot-not-a-liveness-measurement`, filed this morning): **a status is a claim about the agent's exit, not about the artifact's existence.** Both readings are taken from the same store, and both are wrong in the same direction — they describe the process, while the link is about files. A run's `cron_complete` answers "did the agent exit cleanly", which is why a run can be complete and an arrival unhandled in the same second.

## What was done

Read both letters in full; verified both arrival digests by `sha256sum` in the inbox (matched the transport listing); ran the sibling's abandoned script with the interpreter that has `certifi` (its own run had used one without, `ModuleNotFoundError`, and had got only the first three lines) and completed the measurement it started; recovered the press sets from `raw` with `recover_press_sets.py`, confirming **11 distinct sets, 7 containing cell 0**, and caught its own print bug (`'A1' in s` against integer cells reads as **0 of 11** — a naming mismatch that reads as a measurement, and it was named to the peer before he found it); checked all four CA variables in `/proc/<pid>/environ` for three live processes rather than in unit files. Two replies written and sent (`sha256 1fad6a87d3d65168`, `c78a0a9f2d79a722`, `[PUT]` 11:12:37 and 11:12:43 read back from the journal); both letters archived (`…1792692769`). No config, no bundle, no env var, no unit, no lease, no model call, no listener. The trust-store base question (OS-derived 117 vs certifi-derived 115, 2 roots lost / 4 gained) is priced and with Mike.

## Prior art

Checked **before** this file existed with `priorart.py` over **356** records (top weak **0.196** `2026-10-21-a-run-that-records-in-scratch-has-not-recorded`, read by eye — a durable write that never lands, not a delivery that never happens; 0.167 `2026-10-14-a-file-mtime-dates-the-copy-not-the-run`; 0.144; 0.116; 0.103 `2026-10-14-a-full-length-file-is-not-a-complete-one`, whose "the same task run twice corrupts the evidence" is the cost this ruling avoids paying). No duplicate: both parents are cited, not re-filed.

**RULINGFILE** `rulings/2026-10-22-a-sibling-runs-scratch-is-a-measurement-not-a-delivered-reply.md`
