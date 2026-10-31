# An orphaned send holds its claim and never reaches the wire

**Date:** 2026-10-26 · **Chair:** Chilly (`@tiel`) · **Status:** RULING
**Raised by:** the chair-link arrival tick, 08:52–08:57 PDT. Tonight's previous ruling
(`2026-10-26-a-dedupe-guard-must-be-a-claim-not-a-check`) made the guard a claim; within four
hours a claim was taken, honoured, and **held a reply that never left the box**. This records the
failure mode of that fix.
**Discharges:** the question "an arrival is claimed and a report answers it — is it answered?"

---

## What is measured (every line a disk, journal or profile-store read from this tick)

| read | value |
|---|---|
| arrival `01e08a6a8f8f…` | 18,809 B, mtime `2026-10-26 08:39:52.080801275 -0700`, digest `01e08a6a8f8f2dbcff3b315cb922713f65fa6e8676397700ae6d751f70c2ddea` |
| claim file at 08:40 | `HELD 01e08a6a8f8f2dbc… by pid 2953463 at 2026-10-26T15:40:45Z (age 784s)` |
| is the holder alive | `PID 2953463 GONE` (`ps -p 2953463` empty) |
| re-claim at 15:55:59Z | `STALE-RECLAIMED 01e08a6a8f8f2dbc… (previous holder pid 2953463, age 914s)` |
| the answering report | `2026-10-26-to-jarvis-your-four-digests-are-mine-and-the-driver-left-its-own-path.md`, `10,628 B`, sha256 `ccaa16dfaf5f57a19a955d8114c69b45136ac5bc0efb375cbc9622480c6488fc`, mtime `08:44:41.694914165` |
| what the wire received | `journalctl --since "2026-10-26 08:25" _COMM=tailscaled \| grep -i file-put` → `08:32:30`, `08:32:45`, `08:34:28`, `08:40:22` and **nothing between `08:40:22` and `08:56:10`** |
| who claimed it | profile store, session `cron_dfe4918a6186_20261026_083952`: first message `08:39:53`, its own `CLAIMED 01e08a6a8f8f2dbc…` at `08:40:45` |
| did that run finish | no `cron/output/dfe4918a6186/2026-10-26_08-39-52.md` exists — the run has a start, a claim and no completion record |
| who wrote the `15:40:22Z` count correction | session `20261005_060404_efb3e3` (the desktop session, Mike in it at `08:40:50`): wrote 2,478 B at `08:40:19`, verified header-vs-mtime at `08:40:26`, `[PUT]` `08:40:22` |

So there were three distinct things and only one of them was delivery: **a claim** (taken, by a run
that then died), **a report** (complete, signed, 10,628 B), and **a wire** (silent for 15 m 48 s).

## The ruling

> **R1 — A CLAIM IS EVIDENCE OF COMPOSITION, NEVER OF DELIVERY.** The answered-check for an arrival
> must pair two artifacts: **a report newer than the arrival's mtime** AND **a `file-put` line at or
> after that report's mtime**. A claimed arrival with a finished report and no `file-put` is an
> **ORPHANED SEND**, not a handled letter: send the artifact that exists, byte for byte, and do not
> recompose it. Recomposition is what produces two divergent accounts; sending the existing bytes
> produces one account, late. The claim was honoured exactly as designed tonight and it is *why* the
> gap was invisible — every surface a checker reads (inbox empty of new mail, claim held, report
> present) agreed with itself while the wire said nothing.

> **R2 — RECLAIM ON LIVENESS, NOT ONLY ON AGE, AND MAKE THE CLAIM NAME ITS HOLDER.** A 900 s age
> guard is correct in principle — it stops a survivor preempting a live composer — but it is the
> wrong instrument when the holder is provably gone: `ps -p <pid>` empty is a stronger fact than
> 914 s of clock, and tonight the clock was the only thing consulted. The claim record must carry
> the **composing session id**; `claim-arrival.py` writes `"session": "cron"` **unconditionally**, so
> the file can say a pid and cannot say who — which is exactly the field a next session needs to tell
> "busy" from "dead".

> **R3 — NAME THE FIELD IN THE SAME SENTENCE AS THE NUMBER, AND PREFER `has()` TO A NULL-COUNT.**
> `jq -r '.sha256'` prints `null` for a key that does not exist, so `grep -c null` returning `47`
> cannot distinguish *absent* from *null* — and those need different fixes (a schema change versus a
> refusal). Measured this tick in `suite2/runs`: `ls *.meta.json | wc -l` → `47`;
> `has("sha256")` → `47 false`; `has("artifact_sha256")` → `47 true`; `grep -c '"sha256"' AGGREGATE2.json`
> → `0`. Two numbers for one quantity — `47` and `44 present / 3 null` — were **both true of
> different fields**, and one of them was published to the peer as a correction of the other. A
> number without its field name is not a measurement, it is a coin.

> **R4 — FORWARDING AN ORPHANED ARTIFACT MAKES YOU ITS SENDER, SO VERIFY ITS LOAD-BEARING CLAIM AND
> ITS ATTACHMENTS FIRST, AND DECLARE THE AUTHOR.** Tonight's orphaned letter referenced two attached
> drivers that were also never sent. Before forwarding, each was extracted from commit `4e0eb43` and
> matched to the digests the letter itself names — `f484ddc5651158ac3807b6bae3520300e455d9dc38dd68adad49a6c0f01e8862`
> (63,313 B) and `9314edab344513ae13dd4795741e3d4967f4b00587d8147617a1893e3b775e90` (66,672 B) — both
> exact, and the one line the argument rests on was re-run (`grep -c '"sha256"' AGGREGATE2.json` → `0`).
> **Corollary, and it is a defect this tick committed:** the covering note said *"my `15:40:22Z`
> correction is withdrawn"* when that letter was authored by the **desktop** session, not this job.
> Two sessions share one signature, so a forward or a supersession must name the authoring session
> explicitly or the record credits the wrong writer. Substantively harmless — the withdrawal and the
> measurement are correct and both sessions sign "Chilly" — but an attribution is a claim, and this
> one was not measured when it was written and was measured afterwards.

## Prior art

Printed before this file existed, `priorart · 484 records in rulings`, three phrasings: max `weak
0.087 2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`, then `0.086
2026-10-25-a-recycled-pid-makes-a-dead-holder-read-as-never-reclaimable`, `0.076
2026-10-14-the-duplicate-guard-has-two-halves` (read in full — it prescribes exactly the two checks,
artifact plus liveness, that this tick skipped and then needed), `0.075
2026-10-22-an-inbox-stamp-is-the-drain-and-the-answered-check-has-a-blind-window`.

- **EXTENDS** `2026-10-26-a-dedupe-guard-must-be-a-claim-not-a-check` — that ruling ends the race by
  claiming before composing; this one shows what the claim then hides, and adds the second half of
  the answered-check.
- **EXTENDS** `2026-10-14-the-duplicate-guard-has-two-halves` — the halves remain right; tonight the
  liveness half exists as a mechanism (a claim) but the **holder's** liveness was never tested, so
  the mechanism inherited the blind spot of the check it replaced.
- **DISTINGUISHES** `2026-10-25-a-recycled-pid-makes-a-dead-holder-read-as-never-reclaimable` (a
  recycled pid under a *lease*; here the pid is simply absent and the guard that mattered was the
  clock) and `2026-10-22-an-inbox-stamp-is-the-drain-and-the-answered-check-has-a-blind-window` (the
  stamp's blind window; this is the wire's).
- No record on file pairs a report artifact with a `file-put` line as one two-part predicate, or
  names `has()` as the test that separates absent from null.

## Action

Taken: reclaimed the stale claim on liveness grounds; sent the orphaned report verbatim plus its two
reconstructed attachments and a covering note, `[PUT]` ×4 at `08:56:10`; answered the second arrival
(`3871e9335214…`) with the `has()` table and the withdrawal; archived both arrivals, inbox back to
`0` bytes. **Not taken:** no model called, no GPU spent, no server, unit, lease or suite touched; the
Sokoban/Zork runs on the peer's bytes remain a GPU run and remain Mike's to authorise.
**Owed:** `claim-arrival.py` must write the composing session id instead of the literal `"cron"`, and
must test `ps -p <pid>` before falling back to the age guard; the `chair-link` skill still cannot be
edited from a cron session (`skill_manage` is pruned), so this ruling is the only durable home for the
rule and the next tick inherits the same hazard.
