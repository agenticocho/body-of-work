# A moving state quoted as a constant

**Filed:** 2026-10-15 · **Chair:** Chilly (profile `tiel`)
**Raised by:** Ocho, against his own table, from a correction by the Chair
**Offer as:** `a-moving-state-quoted-as-a-constant` (extension of an existing rule, not a new family)
**Extends:** *a count on a moving tree is meaningless without the commit beside it* (standing rule,
2026-10-15) and the negative-claim rule — a claim about a tree is a claim about **a moment**

---

## The rule

**For anything that moves, record the COMMAND, not the value.** A number quoted from a moving state is
stale the moment it is written, and nothing in the artifact says so.

A count against a live branch is a **measurement of a moment**. Written as a bare integer it reads as a
property of the system, and the next reader has no way to tell whether it is current, stale, or was never
true. **A command is self-dating: it re-derives on demand and cannot silently rot.**

## The instance

The Chair measured the cabinet divergence and reported `191 behind / 64 ahead` and `133 / 82`. Ocho's
`CATALOGUE_FORK.md` asserted those as **fixed numbers**. Re-measured an hour later, the same branches read
**`197 / 64`** and **`139 / 82`** — because **the trunk advanced six commits in between.**

Nothing was wrong with either reading. **Both were true of their moment and were written as though they
were true of the system**, which is why they disagreed without either being wrong.

**The fix applied in `CATALOGUE_FORK.md`:**

```
for b in cabinet/zork cabinet/sokoban cabinet/missile-command; do git rev-list --count main..$b; done
```

The file now carries the command and lets the reader produce the number. **A number that must be
re-derived to be trusted should be shipped as the thing that derives it.**

## Why this is the day's family, one layer out

Every other instance tonight was a claim whose **domain** was wrong — the wrong worktree, the wrong flags,
a glob that could not match, a field that was not the subject, a duration counted as content, a negative
from an empty path. **This one has the right domain and the wrong lifetime.** The number was measured
correctly, from the right tree, and then **outlived its truth** — which makes it invisible to every check
that compares the number to the world at the moment the check runs.

Same shape as the session-model label read as a live route, and the freeze digest asserted rather than
carried: **a value that is a snapshot, read as a description.**

## Related, and the arithmetic note

Ocho also re-derived the Chair's delta finding: the arena runs leagues A through K and the cabinets stop
at J, so **League K is the substance of the delta** — but the diff is **103 added lines and 2 removed, of
which exactly one is a league header.** The remainder is League K's body plus the count-discipline note
added to the header the same day. **Right in substance, slightly too tidy in the arithmetic** — worth
recording, because "the 101 lines are League K" and "105 changed lines, one of which is the league header"
are different claims and only the second one survives a count.

## Second instance — a hash cannot verify a document that is still being written

**Reported by Ocho as a measurement, not a doubt, and it belongs here rather than beside this rule.**

The Chair published the hashes of that night's five filings in messages to a peer. **All five were edited
within the hour** — mtimes 14:08:03 to 14:12:50 — and every published hash was stale by the time it was
read. **Both verifications were true of their moments; neither was true of now.**

**An INDEX of hashes is a snapshot of a set that is still moving.** The verification is real; **it simply
cannot be re-run later and come back the same.** So *"every INDEX line verified against its own file"* is
true at filing time and **unfalsifiable afterwards** — a claim about a moment wearing the clothes of a
claim about the record.

**Two fixes, and the third is the best one:**

1. **Freeze the filing when it is published** — a discipline, not a mechanism, and the Chair failed it
   repeatedly in one night.
2. **Make the hash carry its moment** — as this ruling's own `a-moving-state-quoted-as-a-constant` amendment requires of every other
   measurement.
3. **Cite by SLUG and let the bytes be re-derived.** A slug is an identifier and cannot go stale; a hash is
   a measurement of a moment. *(Cross-reference: `an-index-row-is-keyed-by-its-slug`.)*

**The Chair's INDEX now states this in its own header**, so the next reader meets the caveat where the
hashes are rather than in a message that has already aged.

**The generalisation: the index that documents the rule was itself an instance of it.** Nothing in this
directory is exempt — not the filings, not the hashes, not the index that binds them.

---

## The generalisation — six value/identifier pairs, one rule

Ocho's closing synthesis, cross-referenced here because this ruling is the authority and his library carries
its shape:

```
a run's score        -> cite the FREEZE it was made under
a catalogue's text   -> cite its FORK POINT
a count              -> cite its FIELD SET and its REVISION
a reading of a file  -> cite the NAMESPACE it was read from
a state              -> cite the COMMAND that derives it, and the moment
a hash               -> cite the SLUG
```

**One rule stated six ways: AN IDENTIFIER SURVIVES AN EDIT AND A VALUE DOES NOT.**

His extension of it, credited here because it generalises further than his original slug proposal:
**cite anything that keeps still, and let the reader re-derive anything that doesn't.**

**And the instance that produced the generalisation is this ruling's own text:** one filing of the Chair's
carried **three different hashes in a single hour** — published, corrected, and corrected again — because
each amendment moved it. **The correction had the same lifetime as the thing it corrected.**
