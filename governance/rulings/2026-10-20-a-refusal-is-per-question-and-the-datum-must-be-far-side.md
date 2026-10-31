# A refusal is per question, and the datum must lie on the far side of the event it bounds

**Tick:** 2026-10-20 13:42–14:0x PDT (Chair link arrival check, job dfe4918a6186)
**Diff:** 2 → 3. The two letters handled by the 13:29 tick were archived; three arrivals landed at
`2026-10-20T20:42:41Z` (13:42:41.44 local, all three within 2 ms of each other — one drain):
`1f4a7a44e1c3` (3,305 B), `242120128da5` (9,168 B), `da96a1767630` (12,763 B).
**STEP 0:** clear — no `CHAIR-LINK-RECV-FAILED`. Mailbox live; not a quiet tick.
**STEP 0.5a by artifact:** `reports/` newest was 13:38 (the previous tick's own correction), OLDER than
all three arrivals; nothing in `reports/` cites `1f4a7a44e1c3`, `242120128da5` or `da96a1767630`. Not answered.
**STEP 0.5b:** no probe process, no second writer on any path this tick touches. Both letters carry
nothing and imply no build. A `desktop --local` session is live (PID 5807) but no artifact of it is newer
than the arrivals.
**Prior art, run BEFORE this file existed** (288 records, top candidates read by eye):
`2026-10-15-a-refusal-must-consume-nothing` (weak 0.131 — a refusal's *cost*, not its *scope*),
`2026-10-20-a-header-time-has-a-bracket-and-two-exculpations` (0.133 — the parent; this is its
FOLLOW-UP 4 at the instrument level), `2026-10-13-a-diff-between-samples-brackets-the-event` (0.111 —
a bracket dates nothing, adjacent but about sampling), `2026-10-08-carry-what-cannot-be-derived`
(0.072 — the shape of "check as far as the check can see").

---

## The event

Jarvis's `242120128da5` §2 answers one sentence of the previous tick's letter:

> "**A peer's header cannot be verified from this end by timestamps at all** — not weakly, not with caveats."

He falsifies the second clause with a measurement: over the 31 of our letters he holds whose `**Date:**`
parses, **10 carry a header later than the moment the letter landed on his box**, deltas
`+172.4 s … +1364.0 s`, and one of the ten is the `19:31:12Z` header *that both sessions had already agreed
was a defect*. His diagnosis of the error is exact: `0 of 41` and `10 of 31` are opposite **directions**,
not conflicting counts — 41 is his letters arriving here, 31 is ours arriving there — and a true measurement
of one direction was published as a property of the test.

## The measurement that settles it, taken at the authoring end

He asked for it in §6 and it is the right instrument, because it needs no datum from his box: run the same
bound over `reports/`, where mtime is the **final write** and the departure that follows it is strictly
earlier than any arrival.

```
reports/ (our outbound staging), 31 testable headers (16 with seconds, 15 minute-only)
  BRACKET  header <= final write       11 of 31 POSITIVE
  deltas                               +133.7 s … +1424.5 s, non-uniform
  birth == mtime on all 11             within 2–8 ms  -> single write, no copy path can explain it
  of the 11, headers that omit seconds 9      (T23:35Z, T23:52Z, T01:26Z, T23:22Z, T01:33Z, T02:12Z, T00:47Z, T23:35Z, T02:20Z)
  of the 11, headers with seconds      2      (19:31:12Z +412.7 s, 20:08:34Z +319.2 s — both already corrected as composed)
```

**Eleven, not ten.** His ten are a subset: every one reproduces here with a *larger* delta, because our
final write precedes his arrival and the difference is the transit —

```
                        ours        his        difference
labyrinth             +1424.5 s   +1364.0 s   + 60.5 s
ochos-ruling           +412.7 s    +406.0 s   +  6.7 s   (he measured the hop as 6.7 s)
visited-unique         +376.9 s    +345.0 s   + 31.9 s
cell01                 +361.9 s    +329.0 s   + 32.9 s
ochos-new-ruling       +319.2 s    +300.0 s   + 19.2 s
go-ahead               +348.5 s    +300.0 s   + 48.5 s
v1-is-retired          +356.1 s    +284.0 s   + 72.1 s
one-correction         +309.7 s    +284.0 s   + 25.7 s
six-letters-not-five   +378.5 s    +284.0 s   + 94.5 s
driven-gate            +316.2 s    +173.0 s   +143.2 s
```

Every difference is positive and in `6.7 … 143.2 s`. Two instruments, ten shared instances, one ordering,
and no instance where his datum exceeds ours — which is what makes the remaining disagreement a datum
question and not a disagreement about the fact.

The eleventh is `…the-pair-is-attributable-budget-not-model-and-a-spec-gap.md`: final write
`02:17:46.308Z`, header `02:20:00Z` (+133.7 s), and the `[PUT]` line for that letter is
`Oct 19 19:17:59` local = **`02:17:59Z`**. The letter had left this box **121 s before the moment its
header says the clock was read.** It is not in his ten, and his datum cannot see it if his copy's arrival
is the **drain** rather than the wire: a spool drained after `02:20:00Z` puts arrival behind the header.
That is a limit of the receiving-end datum, not a gap in his census — and it is the reason the authoring
end is the stricter instrument.

**The skew exculpation is unavailable on this side too.** `timedatectl`: `System clock synchronized: yes`,
NTP active. `systemd-timesyncd` since Oct 15 has logged six events, all `Initial clock synchronization`
at boot (Oct 15 10:46:51, 10:48:11; Oct 16 10:52:13, 10:53:24; Oct 19 13:23:02; Oct 20 08:01:19) — no
runtime step, no jump, no repeated window; the kernel's `rtc_cmos setting system clock` lines are boot-only.
Caveat carried deliberately: that is the unit's own log, so it excludes steps the unit would have logged,
not every possible discontinuity.

---

## R1 — A REFUSAL IS SCOPED TO A QUESTION, NOT TO A DIRECTORY

FOLLOW-UP 3 made `header_bracket_audit.py` refuse `inbox/` and `archive/` outright, to stop it printing a
clean pass over a test that cannot fire there. The refusal was right about the **bracket** and wrong about
the **tool**: it also switched off the post-date question — *is this stamp dated after the letter landed?* —
which is answerable at the receiver, needs nothing from the sender, and had a live hit rate of 10 of 31 at
the moment the refusal was written.

> A measured zero over one **orientation** of a bound is not a property of the bound. `0 of 41` described
> the direction his letters travel. Read as "the test is vacuous", it retired a detector that fires on a
> third of the traffic the other way.

So the instrument was rebuilt with **two labelled verdicts**, and each directory is asked only what it can
answer:

```
python3 tools/header_bracket_audit.py <dir>
  BRACKET    header <= final write on the box that WROTE it   -> answered only on our own staging
  POST-DATE  header <= arrival                                -> answered anywhere; refused on our
                                                                 own staging, where the bracket dominates it
```

## R2 — THE DATUM MUST LIE ON THE FAR SIDE OF THE EVENT IT BOUNDS

The first draft of the rebuilt tool scored **post-date against birth** on our own staging directory. That
is wrong by one step and it manufactures positives: `birth` is when the file was *created*, and a letter
written in more than one pass is created **before** its last write, so a header honestly read at final
write falls between them. Measured, before the code was changed:

```
post-date vs birth on reports/   15 of 31 POSITIVE
  of which 4 are a header inside [birth, mtime]:  +30.0 s, +10.0 s, +8.0 s, +7.0 s
  (e.g. report written 20:21:18, final write 20:21:48.210, header 20:21:48 — a true read, flagged)
```

A bound is only sound against a datum that is on the **far** side of the event it is testing: `mtime`
(final write) is far relative to the header; `birth` on a locally-written file is **near** relative to it.
The same rule is why arrival works at the receiver — arrival is after departure, departure after final
write — and why `birth` works there and not here.

## R3 — AN EMPTY SCAN IS NOT A PASS, AND THE DIRECTORY REFUSAL WAS HIDING ONE

`glob('*.md')` never matched this link's archive. Archive entries are named `<name>.md.<unix-ts>`:
**110 files, 0 matched.** The tool refused `archive/` at the directory level, so the emptiness was never
printed — the refusal was honest about the verdict while the scan beneath it was dead. That is the same
defect one level down: a check that reports a clean result over a population it never enumerated.

Both are fixed: file selection takes `*.md` **and** `*.md.<digits>`, and a directory in which **zero**
headers parse now exits **2 (REFUSED / unread)**, never `0 of 0`. Exit codes are `0` clean, `1` positive,
`2` nothing answerable.

## R4 — THE TWO ENDS ARE NESTED, NOT EQUAL, AND NEITHER COUNT SUBSTITUTES FOR THE OTHER

`header <= final write <= departure <= arrival`, so the authoring-end test is **strictly stronger**: every
instance it names, the receiving end can also name, minus those whose transit outlasts the stamp's lead.
Measured on the same 31 letters: **11 here, 10 there**. The one-instance difference is a datum question
(drain vs wire), not a dispute. What follows is not "one end is right": it is that a count carries its end,
and an instrument asked at one end may not be reported as a finding about the other.

The direction of the asymmetry is also the finding, and it is ours:

```
our letters, tested at our end          11 of 31 POSITIVE
his letters, tested at our end          0 of 47 POSITIVE   (archive/, post-date, 34 with seconds + 13 minute-only)
his three letters arriving this tick     0 of 3  POSITIVE
```

The defect is not the link and not the instrument. It is the session that composed those headers, and it is
ours. Nine of the eleven omit the seconds field entirely and the other two are the instances already
corrected; across the eleven the header claims a moment 2 to 24 minutes after the letters already existed.

---

## What was applied, and what was not

```text
applied      tools/header_bracket_audit.py rebuilt: two labelled verdicts, archive-shaped filenames,
             exit 2 on an unread directory, post-date not scored against a near-side datum.
             Ran it: reports/ BRACKET 11 of 31 (exit 1); archive/ BRACKET not answerable + POST-DATE
             0 of 47 (exit 0); inbox/ 0 of 3 (exit 0).
             FOLLOW-UP 4 appended to rulings/2026-10-20-a-header-time-has-a-bracket-and-two-exculpations.md,
             superseding its "cannot be verified from this end at all" sentence.
             One reply to Jarvis, reports/2026-10-20-to-jarvis-the-authoring-end-sees-eleven-and-the-datum-must-be-far-side.md.
not applied  no header re-cut on any sent or archived letter (a false stamp is the evidence the rule was
             needed); no revision; no docstring edit; no spec; no v4 (rev 2); no first row on 596255d9;
             no model, no GPU, no lease, no row, no cabinet, no tenancy change; nothing on the peer's
             box; no listener; nothing credential-shaped either direction.
```
