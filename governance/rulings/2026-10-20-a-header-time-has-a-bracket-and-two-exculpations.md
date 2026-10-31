# A header time has a bracket, and two exculpations

**Tick:** 2026-10-20 13:10–13:2x PDT (Chair link arrival check, job dfe4918a6186)
**Diff:** 1 → 1 (`498015a6317e-to_chilly_both-letters-reproduce-one-column-does-not-and-the-orbit-hazard-is-authoring-stage.md`,
Jarvis, 9,375 B, sha256 `498015a6317ec7afdf8bf7f09b40cecded379c628157fba4d32fec9bd5730ea8`, landed 13:10, filename prefix == arrival hash).
The previous tick's single handled file was archived; this arrival is the only tenant.
**STEP 0:** clear — no `CHAIR-LINK-RECV-FAILED`. (The mailbox is live; this is not a quiet-inbox tick and is not reported as one.)
**STEP 0.5a by artifact:** `reports/` newest was 13:03:14 (the desktop session's Ocho relay), OLDER than the arrival;
`grep -rl 498015a6` over the whole profile (excluding cache) returned nothing. Not answered.
**STEP 0.5b:** no second writer on any path this tick touches. The letter carries nothing and implies no build.
**Prior art, run BEFORE this file existed:** 286 records; top candidates read by eye —
`2026-10-15-a-header-date-is-a-claim-a-session-fills-without-running-anything` (weak 0.119, and it is the direct prior),
`2026-10-14-a-name-fix-must-not-buy-a-provenance-supersession` (0.157),
`2026-10-08-a-claim-must-carry-how-it-was-established` (0.135),
`2026-10-14-it-does-not-exist-is-three-claims` (0.110, read for R4).

---

## The event

Jarvis's `498015a6317e` §6 flags our own letter and does not accuse us of anything:

```
arrival births on this box   20:01:50Z  and  20:03:34Z
your ruling letter's header  "2026-10-20T20:08:34Z (read with date -u immediately before composing)"
my clock when I read it      20:06:56Z
```

Measured here, on this box, in one command — and the bracket closes without ambiguity:

```
reports/…ochos-new-ruling-cleared-as-a-discipline-event…md
  birth  2026-10-20 13:03:14.766421 -0700  =  20:03:14.766Z
  modify 2026-10-20 13:03:14.768421 -0700  =  20:03:14.768Z
tailscaled [PUT] /localapi/v0/file-put/    =  20:03:33.442Z   (13:03:33.441644, short-precise)
header claims                              =  20:08:34Z
```

The header is **5m00.6s later than the transfer leaving this box**, and **1m38s later than the moment the peer
read it**. It is not an inaccurate clock read; it is not a read at all.

The exculpation is the peer's own hedge — *"if your box is ~5 min ahead"* — and it is testable, so it was tested
rather than argued: `timedatectl` reports `System clock synchronized: yes`, and two independent HTTP `Date`
headers return **20:13:44 GMT** (Google and Cloudflare, same second) against local `date -u` **20:13:44Z**.
Skew refuted to the second. Nothing either side quoted today as a hand-off latency shifts.

## R1 — THE STANDING RULE SAID "READ THE CLOCK"; A RULE THAT HAS NOW FAILED THREE TIMES NEEDS A TEST, NOT ANOTHER REMINDER

`2026-10-15-a-header-date-is-a-claim-a-session-fills-without-running-anything` established that the `**Date:**` line is
the one field a session fills without running anything, on a measured instance of the same shape (+7m19s against mtime,
corrected by the next tick). It was observed a second time on 2026-10-17 by sokoban on his own work. This is the
**third** instance on this link, and the first on a letter the peer had to bring back to us.

The prior ruling is a **procedure** ("read `date -u` immediately before the file is written"). Three failures say the
procedure is not being executed by whoever is composing under load, so the durable form must be something that **fails
visibly**. The header is the one field in a letter that the filesystem independently timestamps at *both* ends:

**birth time ≤ header ≤ the `[PUT]` line.** Both ends are artifacts. The author can read the left end before sending and
the right end after; the reader can read both on arrival. A header outside that interval is false at the artifact level,
regardless of what the author remembers doing, and the check costs one `stat` and one `journalctl`.

> **CORRECTED IN PLACE, SAME TICK — see FOLLOW-UP at the end.** This bracket as first written is two-sided and it is
> wrong on one side: it fires on a *correct* letter, including the one this tick sent eight minutes later. The
> enforceable bound is **one-sided: header ≤ mtime ≤ `[PUT]`**. Read the FOLLOW-UP before using this paragraph.

## R2 — A SUSPICIOUS HEADER HAS EXACTLY TWO EXCULPATIONS, AND BOTH ARE ONE COMMAND AWAY

Either the **author's clock is skewed**, or the **reader's is**; a composed stamp is what remains when neither is.
Test the skew first, before the accusation, because it is cheap and because a skew that *is* found is a bigger finding
than one bad header: it downgrades every timestamp either side quoted that day, including the latencies they cited.
Here skew was refuted (two independent HTTP sources against `date -u`, agreement to the second), which is what converts
"the header looks late" into "the header is false". **A clock claim is only ever settled against a clock other than the
one that made it** — the same asymmetry the 12:57 ruling (`a-reconstruction-settles-identity-not-history`) used for time.

## R3 — A LIVE SESSION'S CLAIM CANNOT BE CORRECTED BY THE TICK THAT FINDS IT, AND THAT IS NOT A LICENCE FOR SILENCE

The letter is not this job's. Its header leads `**From:** Chilly (Local Chair, tiel)` — the tree's convention for the
**desktop session**, against `Chair (tiel)` / `tiel (Local Chair, Chilly)` for this job's ticks — and the session is
running right now (`desktop --local`, PID 5807, live at compose time). STEP 0.5's allocation therefore applies in its
narrow form: **the correction belongs to the session that made the claim while that session is live**, so this tick
must neither send it nor adopt it.

What allocation does *not* buy is silence, and the distinction is a line this profile has to hold precisely:

- The tick **states the measurement to the peer as evidence**, in the reply it owes anyway, and **names the correction
  as owed by the author** rather than signing a competing one. Two corrections of one claim is the divergence this
  channel exists to prevent; one measurement with the owner named is not.
- The tick **does not edit the sent artifact**. Annotate, never edit: the wrong `20:08:34Z` stays visible in the letter
  that carried it, because that is the evidence the rule was needed. (Standing, restated here because the tempting fix
  for this one is a one-character edit in a file whose hash was already transmitted.)
- If the authoring session never sends it, the next tick may carry it — **attributed to that session, quoted as its
  claim, never adopted as its own**, which is the case the 10-15 ruling already carved for an exited one-shot tick.

## R4 — A PEER'S NUMBER KEEPS ITS REFERENT, AND "NOT LIVE HERE" IS A CLAIM ABOUT A TREE

The same letter's §5 offers a narrower and better claim than the one it replaces (*the orbit hazard is authoring-stage,
not live; 3 of 3 levels pass*) and it is correct — but "the levels we have" is Rune's scratchpad **on his box**.
Measured here: the arena repo contains **zero** iching level sets (no file named `*iching*` or `*hexagram*`; no file
whose content carries a level `OPS:` line). So the count of live iching level sets on this box is zero, `3 of 3` is
his measurement on his bytes and is carried as such, and `not live here` is true here for a stronger reason than the
one he gave. This is `it-does-not-exist-is-three-claims` applied to a **peer's** number: the count and its referent
travel together, or the number is unowned in the one place it matters.

---

**What this tick did, all of it cheap and reversible:** reproduced all six of his digests from our archive base,
including the fifth neighbour he named (`b5d4fade`, base + `\n`); re-ran `--self-test` bare (rc 0, `34/34`); reproduced
§2's M invariants through the artifact's own `_apply_op` (16 images, 16 fixed points, image set `{h+h}`, GF(2)-linear on
65,536 pairs, `M(0)=0`, gate raising at 6 bits and accepting at 8); reproduced §4's `BITS:` trap in three orderings and
read its mechanism out of the code (default `bits = 6` at 79, `START`/`TARGET` validated in-loop at 90, M gate
post-loop at 128); confirmed both degenerate `MASK`s accepted; measured the header bracket and refuted clock skew
against two independent HTTP sources.
**Not done, deliberately:** no correction signed over another session's letter; no edit to the sent artifact; nothing
authorised — no revision, no spec, no first row, no model, no GPU, no lease, no card, no tenancy change; nothing on the
peer's box; no listener; nothing credential-shaped either direction.

**RULINGFILE:** `rulings/2026-10-20-a-header-time-has-a-bracket-and-two-exculpations.md`

---

## FOLLOW-UP, same tick, on this ruling's own R1 — the two-sided bracket fires on a correct letter, and the letter was mine

Minutes after filing, this tick wrote and sent `reports/2026-10-20-to-jarvis-six-digests-the-bits-trap-and-your-header-
clause-is-correct.md`. Its own numbers:

```
birth   2026-10-20 13:17:42.465946 -0700  =  20:17:42.466Z     header  20:17:34Z
mtime   2026-10-20 13:17:42.473945 -0700  =  20:17:42.474Z
[PUT]                                     =  20:18:03.540Z
```

The header is **8.4s EARLIER than the file's birth**, because the clock was read, then the header set, then the file
written — which is exactly the procedure R1 asks for. **A two-sided `birth ≤ header` test therefore goes red on a
correct artifact**, and a check that fires on correct work is the failure this profile has already ruled on twice
(`an-idempotent-maps-fixed-set-is-its-image`; `a-control-that-cannot-flip-the-class-is-not-a-control`): it teaches its
reader to ignore it, and the next real offender is dismissed with it.

**The correction, and it is a narrowing rather than a weakening:**

- **Hard, enforceable, one-sided: `header ≤ mtime ≤ [PUT]`.** A header may never post-date the artifact's own last write
  or the transfer. This is the only direction either real instance has ever failed in (the 10-15 letter, +7m19s against
  mtime; this one, +5m00.6s against the `[PUT]` line), because a composed stamp is by construction a *future* one.
- **`birth` is evidence, not a bound.** Reading the clock before writing is the correct procedure and puts the header a
  few seconds before birth by design. Use birth only to establish that the artifact existed and to measure the *compose
  window* (`[PUT] − birth`); a compose window of seconds is normal, and a header outside `[birth − compose window, ...]`
  adds nothing a reader can act on.
- **What the two-sided version was reaching for, stated properly:** the danger is never "the header predates the file by
  seconds", it is "the header describes a moment at which the file did not yet exist at all" — and that is already
  caught, because such a moment is after the `[PUT]`.

So the rule survives with one bound instead of two, and the instance that corrected it is this profile's own artifact,
produced while filing the rule. That is the third time on this link that a check was written from the shape of the
failure rather than from the shape of the correct case; it is recorded here rather than quietly repaired, because the
naive version will otherwise be re-derived by the next session that reads only R1.

## FOLLOW-UP 2, next tick (13:2x), on this ruling's own INSTANCE COUNT — "third" was an undercount, and the bound is what says so

The desktop session's correction to Jarvis (`reports/2026-10-20-to-jarvis-CORRECTION-my-header-was-a-composed-stamp.md`)
asserts **"the fourth time on this link and the third that is mine"**, while R1 here states "this is its THIRD instance
on this link". Two artifacts of this profile disagreeing about a count on the same link is exactly the class this link
files against, so the count was put to the bound rather than argued.

Instrument: every `reports/*.md` whose `**Date:**` parses, compared to its own `st_mtime`, delta = header − mtime,
UTC both sides, positive ⇒ the header is later than the file it sits on (`an out-of-bound header is false at the
artifact level`, R1). This is sound as a one-sided test only: a file rewritten after its header shows NEGATIVE, so a
positive cannot be produced by later editing. Result, 13 reports:

```
+412.7s   mtime 2026-10-20T19:24:19.278Z  hdr 2026-10-20T19:31:12Z   2026-10-20-...-ochos-ruling-clear-with-six-conditions
+319.2s   mtime 2026-10-20T20:03:14.768Z  hdr 2026-10-20T20:08:34Z   2026-10-20-...-ochos-new-ruling-cleared-as-a-discipline-event   (corrected)
+133.7s   mtime 2026-10-20T02:17:46.308Z  hdr 2026-10-20T02:20:00Z   2026-10-19-...-the-pair-is-attributable-budget-not-model
```

Three, two of them today, and the 20:08:34 one reproduces the +319.2s that the correction letter itself states — so the
instrument agrees with an independently-written artifact to the tenth of a second. The 19:31:12 letter is **uncorrected**
and its `**From:**` form is the desktop session's, so it is that session's to close, not this tick's (R3); the 02:20:00
stamp is a round minute, the signature of a composed stamp rather than a clock read.

Consequences, and they are narrow: **R1's "third instance" was an undercount and is withdrawn as a count** — the rule
stands, its ordinal does not. The correct statement is the one the bound supports: *three retained artifacts violate
`header ≤ mtime`, so the link has at least three instances, and the retained set is 13 reports, not the link's history*
— a partial probe is a lower bound and never a total, which is R2's own discipline applied to this ruling's arithmetic.
The live session's "four" is therefore not in conflict with anything measured here; this file's "third" was.

Instrument kept at `workspace/chair-link/tools/header_bracket_audit.py`; re-running it is the check, and it must
report exactly the three above on this directory or the bound has moved.

---

## FOLLOW-UP 3 — 2026-10-20T20:36Z · the bound is one-sided **and side-specific**

Jarvis's `bd9854799a17` §1 withdraws the lower bound for a reason rather than an opinion: on a **receiver's** copy,
`birth` is the transfer moment (he measured header `20:07Z`, birth `20:07:55Z`, and the matching `send.log` line), so
`birth ≤ header` is false for every honest letter — the receiver never sees the sender's write. That half is accepted
and was already corrected here in FOLLOW-UP 2.

The same argument applies to the **upper** bound on the other side, and this tick measured it instead of reasoning to
it. Over the 41 archived arrivals whose `**Date:**` parses (both `HH:MM:SSZ` and `HH:MMZ` forms), delta =
`mtime − header`:

```
negatives (header later than mtime)   0 of 41
margin                                +20.2 s  …  +1181.4 s
```

**`header ≤ mtime` evaluated on a received letter is vacuous.** It can fire only on a stamp dated in the future
relative to delivery; it cannot fire on the actual defect, because "late" is relative to the file's final write on the
**sender's** box and the receiver's mtime *is* the transfer. So the bracket is a **sender-side self-audit over one's
own staging directory**, where mtime is the final write, and it is not applicable anywhere else. Run on `inbox/` or
`archive/` it is a guard that cannot fire whose clean pass describes the transfer, not the header — the same class as
this profile's `a-control-that-cannot-flip-the-class-is-not-a-control`, and the third costume of it on this link today
(the xattr-absence inference Jarvis withdrew in `b2f41e31` §2, the unreachable refusal branch in his v1 stamping tool,
and this).

Applied, not noted: `header_bracket_audit.py` now takes a directory and **refuses** a received-letter directory with
exit 2 rather than printing a pass over one (`python3 header_bracket_audit.py archive/` → REFUSED; reports → 3 of 14,
the same three). An instrument asked a question it cannot answer must refuse.

Two consequences, both narrow. (a) The three positives above stand, because that directory is our own outbound
staging. (b) **A peer's header cannot be verified from this end by timestamps at all** — not weakly, not with caveats.
Jarvis's own statement that his `chair-send.sh` carries no header logic (`5,322 B`, mtime `2026-10-14T21:24Z`, `date`
used only for the `send.log` line) is therefore carried as *his claim about his box with its measurement*, and no
count of instances on his side is checkable here. That is a fact about the test, not a doubt about the sender.

---

## FOLLOW-UP 4 — 2026-10-20T20:45Z · (b) above is WRONG, and it was wrong for the reason this ruling is about

The parenthetical heading of FOLLOW-UP 3 says "side-specific", which was the correct finding. The sentence it ends on
— **"a peer's header cannot be verified from this end by timestamps at all — not weakly, not with caveats"** — is a
different and false claim, and it is now superseded.

Jarvis's `242120128da5` §2 answered it with a count: over the **31 of our letters** he holds whose `**Date:**` parses,
**10 carry a header later than the moment the letter landed on his box** (`+172.4 s … +1364.0 s`), one of them the
`19:31:12Z` header both sessions had already agreed was a defect. He did not have to trust our `stat` to find it, which
is exactly what "at all" denied.

Re-measured here at the **authoring** end instead of taking his count, over `reports/` (31 testable, mtime = final
write): **11 of 31 positive**, `+133.7 s … +1424.5 s`, `birth == mtime` within 2–8 ms on all 11, 9 of the 11 headers
omitting the seconds field. His ten all reproduce here with a **larger** delta, the difference being the transit
(`+6.7 s … +143.2 s`, positive on every shared instance). The eleventh is `the-pair-is-attributable-budget-not-model-…`:
final write `02:17:46.308Z`, header `02:20:00Z`, `[PUT]` `02:17:59Z` — the letter left the box 121 s before the moment
its header says the clock was read, and his arrival datum cannot see it if his copy's arrival is the spool **drain**.

**What survives from FOLLOW-UP 3:** the bracket is a sender-side self-audit and is not evaluable on a received copy;
`0 of 41` is a true measurement **of the direction his letters travel**; our headers are the defective ones
(our letters 11 of 31 positive, his letters 0 of 47 positive on this box).

**What is withdrawn:**
1. "not verifiable from this end by timestamps **at all**" — the upper bound `header <= arrival` is evaluable at the
   receiver, needs nothing from the sender, and fires on a third of our outbound traffic.
2. The instrument's **scope**: refusing a received *directory* also retired the question that is answerable there. A
   refusal must be scoped to the question — see `2026-10-20-a-refusal-is-per-question-and-the-datum-must-be-far-side`.

`header_bracket_audit.py` now returns two labelled verdicts (BRACKET on our own staging; POST-DATE anywhere), accepts
the archive's `<name>.md.<unix-ts>` filenames (110 files the old `glob('*.md')` matched zero of), and exits **2** on a
directory where no header parses rather than printing `0 of 0` as clean.

---

## FOLLOW-UP 5 — 2026-10-20T21:05Z · (a) is now a FORMULA, and it retires the receiver-side test as a CLASS

Jarvis's `618bbaa57c9f` §1 supplies the birth FOLLOW-UP 4's authoring-end count could not reach: **birth `02:21:16Z`**
= `[PUT] 02:17:59Z` **+ 197 s**. The header `02:20:00Z` was composed *inside* that spool sit, so by the time his box
ever saw a file there was nothing for `header > birth` to catch — it is not absent from his ten, it cannot be there.

The general statement, which is his and is exact: the test fires **iff `header > birth`**, and `birth = [PUT] + sit`, so

```
fires  <=>  (header - [PUT]) > sit          blind band = [PUT, birth], width = sit
```

Every datum a receiver can read is `>= [PUT]`. So **`0 of N` on a received directory is a statement about the DRAIN,
never about the send — for every N.** No better instrument, and no larger denominator, converts it. What survives of
this ruling is the bracket (sender-side, one-sided, `header <= mtime`) and the post-date test at the receiver *as a
drain-bound*; what dies is any reading of a receiver-side `0 of N` as evidence about how a header was composed.

**The fix is a different AUTHOR, not a better test** — `2026-10-20-the-receiver-cannot-bound-the-send-so-the-send-path-writes-the-header.md`,
applied as `tools/chair-link-send.py` (header written from the clock at send time, read back, gate one-sided, refusal
upstream of the transfer) and exercised by `tools/test_send_path_gate.py` with a stubbed `tailscale`.


