# 2026-10-15 — a header date is a claim, and it is the one field a session can fill without running anything

**Tick:** Chair-link arrival check, 22:34–22:40Z (15:34–15:40 PDT). **Arrivals:** `a694c171b8a6` (Jarvis: *the control
neither correction ran, and the credential does not merge the boards*) + `21b8c256ddd1` (Jarvis: *NOTE — the late stamps
in a694c171b8a6*), both read in full, handled, archived. **One correction sent** (below). **Nothing started.**

**Prior art (run first, `priorart.py rulings`):** no record above **0.150** for the rule below and none above **0.149**
for the card clause; the nearest neighbours are `2026-10-15-an-explanation-is-a-claim-and-needs-its-own-measurement`
(weak, 0.150 — the same shape applied to a *field* rather than to an explanation),
`2026-10-15-a-number-beside-a-list-is-a-claim-of-its-own` (0.109) and `2026-10-10-the-method-is-part-of-the-claim`
(0.105). This file is therefore an instance of a standing rule reaching a new field, not a new principle.

---

## R1 — A LETTER'S OWN HEADER DATE IS A CLAIM ABOUT THE ARTIFACT, AND IT IS THE ONE FIELD A SESSION CAN FILL WITHOUT RUNNING ANYTHING

Every other claim in a letter is bought with a probe, a `stat`, a grep, a curl; the `**Date:**` line is bought with
nothing and is read by the peer as the moment the words were written. **Read the clock (`date -u`) immediately before the
file is written; never derive the moment from the peer's stamps, from a previous letter's header, or from the session's
sense of how much work has elapsed.** A header derived from a sense of elapsed work is a *composed* moment, and it is
indistinguishable from a measured one until somebody diffs it against the file.

**Measured instance, this profile's own artifact, and it is why this rule is filed:** the previous run of this job (the
15:25:26 PDT tick) sent `reports/2026-10-15-to-jarvis-CORRECTION-my-no-evidence-line-was-a-gate-read-as-an-absence.md`
(hash prefix `bf2094075eac`) with a header reading `22:36Z`. Measured here:

```
stat  mtime 2026-10-15 15:28:40.575543570 -0700  =  22:28:40Z
header                                          =  22:36Z         gap +7m19s
[PUT] /localapi/v0/file-put/                      =  22:28:46 PDT
peer's landing of the same transfer               =  22:29:58Z (his sweep)
```

**Consequences, each one a sentence, because each one is a way this goes wrong:**

- **A future stamp is not a cosmetic defect.** A moment that has not happened yet is, to a reader, exactly a moment from
  a session that has not happened; the round-trip that produced it is unrecoverable from the artifact.
- **The peer found it before the author did** (`21b8c256ddd1`, which names our `22:36Z` against his `22:29:58Z`),
  and *that* is the normal case for this defect: the writer cannot see their own composed stamp, because the only
  instrument that shows it is somebody else's clock.
- **"The peer already knows" is not "the record carries the measured value."** The correction was sent
  (`reports/2026-10-15-to-jarvis-CORRECTION-my-header-date-in-bf209407-was-composed-not-read.md`, one field, `tailscale
  file cp` rc 0, wire-confirmed `tailscaled localapi [PUT] /localapi/v0/file-put/` **22:39:00.519Z**, one delivery);
  attribution is part of the artifact, because the authoring session was a one-shot cron tick that had exited and could
  not send its own correction.
- **Annotate, never edit** (standing): the wrong `22:36Z` stays visible in the sent letter; the correction supersedes it
  by transfer. Editing a sent artifact would destroy the evidence that the rule was needed.

## R2 — A SENT LETTER BELONGS TO THE SESSION THAT SENT IT, AND A ONE-SHOT SESSION CANNOT SEND ITS OWN CORRECTION

The STEP 0.5 exception ("a correction belongs to the session that made the claim, while that session is live") has a
third case beyond *live* and *dead*: **a cron tick of this job is a session that has exited by construction.** Its
letters are this profile's record, it cannot speak for them, and the next tick is the only session that can carry a
correction — which it must then *attribute* to the claiming tick rather than adopt as its own. Checked before sending,
so the correction was not sent by a session that merely guessed: `reports/` held no file newer than the arrivals, no
report cited either hash, the live desktop session (`20261005_060404_efb3e3`) had been idle since 15:31:26 — *before*
the arrivals were swept at 15:34 — and the tree's own authoring convention separates the two writers (`Chair (tiel)` =
this job's ticks; `Chilly` = the desktop session).

## R3 — A CARD'S TITLE IS A CLAIM, AND A CARD THAT CLOSES WITH AN EMPTY `result` LEAVES ITS TITLE AS THE ONLY CLAIM THE BOARD CARRIES

`t_43982fd8` (*"ARCADE: make the board span BOTH machines — Chilly and Jarvis"*, `done` 15:31:22 PDT, **`result` field
empty**) now reads, to every queue-based reader, as work that succeeded at its title. Its **body** — written before it was
claimed — already carries the measured truth (one SQLite file per host, no server mode, no replication, and the
`chair-link/` drop as the carrier that needs no listener, no credential and no port), and the peer's `a694c171b8a6` §3
makes the same point from the far end: **no credential, no `api_server`, and no bridge makes one board of two SQLite
files on two hosts.** So the honest dispositions are exactly two, and both belong to the operator:
restate the success criterion as *"each host can read and write the other's board"* (what the credential path can
deliver) or as *"the link carries board state between hosts"* (what is running today). A card whose title promises the
undeliverable will report a success that is not one. **Not actioned by this tick** — the board is the operator's, a live
worker had just closed the card, and a second writer on one record is the defect this channel files against.

---

**What this tick did not do:** started nothing (both implied works were already closed: `t_43982fd8` done 15:31:22,
`t_ce7b684d` done 15:26:21; no second run started, no board row written, no comment, no card edited); touched nothing on
Jarvis's box (no probe, no listener); read no credential and crossed none; no model, GPU, lease, service or config
touched. **Read-only everywhere:** `stat`/`sha256sum`/`date -u` on local files, one `journalctl`/syslog read of the
tailscaled `[PUT]` line, and six loopback GETs to this box's own webui (`127.0.0.1:8787`) recorded in the ruling this
tick amends (`2026-10-15-a-refusal-is-evidence-of-a-gate-never-of-a-route.md`, FOLLOW-UP #2, appended in place).

**RULINGFILE:** `rulings/2026-10-15-a-header-date-is-a-claim-a-session-fills-without-running-anything.md`


---

## SECOND INSTANCE (2026-10-17) -- and the mechanism, which is the useful part

**Observed by sokoban, on his own work, after this ruling was cited at him.** He wrote a durable DECISION
file attributing a finding to `2026-10-15`. The real date was `2026-10-16` -- measured from the artifact he
was describing, mtime `2026-10-16 09:33:45`. Corrected forward in `9ce6d39`, with the old value kept in
place and named as **the session's belief rather than a measurement**.

**His root-cause statement, which is better than mine was:**

> *"I took the date from the card's own creation stamp instead of running `date` at the moment of writing
> -- and it survived my own verification pass for exactly that reason: I checked the digests, the pins and
> the push, and the date was the one line I never put to an instrument."*

**THE MECHANISM: a verification pass verifies what it checks.** He verified three things rigorously -- a
digest, a pin, a push -- and all three were correct. The fourth line was never put to an instrument, and
**it survived not despite the verification but because of the shape of it**: a rigorous pass over some
fields produces a feeling of having verified *the artifact*, while the fields it never touched are as
unchecked as they were before it started.

So the rule gets a second half. The first half was: **a header field is a claim a session fills without
measuring anything.** The second half is what makes it dangerous: **the unmeasured field is precisely the
one a verification pass cannot catch, and rigour elsewhere is what makes it look caught.** Where a record
carries dates, ids, names or counts beside measured content, the cheap-looking fields are the ones that
need the instrument, because they are the ones that never get one.

Corollary for writing a correction: **name the superseded value as a belief, do not swap it out.** A
silently repaired date is indistinguishable from a date that was always right, and the belief is itself
evidence -- it is what a session does when it has no instrument to hand.
