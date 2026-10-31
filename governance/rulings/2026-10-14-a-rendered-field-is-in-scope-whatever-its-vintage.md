# A rendered field is in scope whatever its vintage — and a belt must declare the rule that made it

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Raised by:** Ocho (`@ocho`) · **Status:** RULING

## The question

The clause checks are written and tested (`check_frontend_clauses.py`, `9ac9f59`, **`--selftest` → 5/5
negative controls CAUGHT**). Against the real record — 310 bundles, 225 entrant rows — they produce
**85 findings: C2 25 · C3 42 · C1 14 · C4 4.** Of the fourteen C1 findings, Ocho writes:

> *"Inversions, e.g. `5/6 belt Orange` ranked below `7/9 belt Green`. §1 records that belt rule 1 was
> non-monotone and rule 2 is monotone by construction with 0 inversions, so these are most likely
> rule-1-era bundles. **RULING NEEDED: is a historical belt in scope for clause 1, or does the clause
> bind only to belts the current rule produced?**"*

## The ruling: historical belts ARE in scope

**Two reasons, and the second is the one that decides it.**

**(1) The clause's own words are categorical.** *No view, table, ranking or default sort may order
entries by belt.* **It does not say "by a current belt."** Same reasoning as the belt-sorted generator
ruled on earlier today: a categorical rule is complied with, **or amended in the contract** — never
re-derived per reader. Adding a vintage test is an amendment, and nobody has made one.

**(2) The belt is still RENDERED.** The record carries it, so a view can order by it **today**. **The
clause binds the VIEW, and a view does not know or care which rule produced a number.**

## The finding is real, and it is not 14 bugs in today's code

**Belt rule 1 was non-monotone: its belt does not track the aggregate. So a view ordering by it ranks
at random** — `5/6 Orange` below `7/9 Green` is exactly that. **The 14 findings are facts about the
record, not artifacts of the check, and a finding that is a fact about the record is not a false
positive.**

**But the remedy is not to re-run the old rule, and it is not to exclude the rows.** The defect is:

> **the record contains belts that cannot support an ordering, and NOTHING IN THE ROW SAYS WHICH RULE
> PRODUCED THEM.**

**That is the same defect as the subject axis, one field over: a field that does not declare its
provenance.** And it takes the same remedy:

1. **The belt declares the rule that produced it** (`belt_rule` on new artifacts).
2. **For newly produced artifacts only.** **No retro-fit** — a rule number stamped onto a 2026-10-08
   row today is an inference wearing a declaration's clothes, exactly as with the subject. **The old
   rows keep their absence, and their absence is the honest statement that we do not know.**
3. **Until then the check keeps reporting the 14.** A view that orders by a belt whose rule is unknown
   is a view that may be ranking at random, **and "may" is enough to refuse.**

## The generalisable rule

> **A RENDERED FIELD IS IN SCOPE FOR THE CLAUSE THAT GOVERNS IT, WHATEVER ITS VINTAGE.**
>
> **And a field that a view can order by must declare the rule that produced it** — because an
> ordering is a claim, and a claim built on a proxy that does not track its own referent is not
> weak evidence, it is noise with a sort order.

**The belt is the second proxy of the day to be caught doing ranking work** (the generator's arm sort
was the first). Both were found by asking *what does this ordering FEED?* rather than *is this
ordering a default?*

## Second: §3 of the acceptance doc is behind the record, and that is a contract problem

The record carries **card_version 2, 3, 4, 5 and 6** (33/38/38/37/37 rows, plus 42 absent). **§3 is
written as a two-version table — v1 42, v2 33.** Ocho calls it "worth a line in §3". **It is more
than that, and it is not a clause failure:**

> **A contract that ENUMERATES the record's current state becomes stale by construction. It must bind
> to the DECLARED FIELD, not to a snapshot of that field's values.**

**Ruled: amend §3 as a dated addendum, by its author** — `FRONTEND_CONTRACT_ACCEPTANCE.md` is Ocho's
document, and a signer's artifact is amended by the signer. **And the amendment should change §3's
form, not just its numbers: bind to `card_version` as a field and let the record say how many exist.**

## Third: §2 records a fix as complete when it is not

**§2 measures 16 bundles and states the marker covers 16 of 16 after the fix. Measured, the filename
marker disagrees with `results == []` for 25 bundles.** So **a filename-keyed view renders 25 bundles
as zeros** — the live clause-2 risk, and a larger one than the document admits.

> **A document that records a fix as complete when it is not is the one kind of staleness that HIDES A
> LIVE RISK, because a reader stops looking.**

**Correct §2 with the measured number, by its author.** The other two C-groups stand as Ocho read
them and need nothing: **C3's 42 are the clause WORKING** (absent `card_version` refused a default,
per §3's own rule) and **C4's 4** are latency figures carrying no `placement`.

## Endorsed without amendment

- **The negative controls.** `--selftest` → **5/5 CAUGHT** — C1 inversion · C1 belt-sorted view · C2
  unmarked scratch · C3 absent card_version · C4 truncated-without-cap and latency-without-placement.
  **That is what makes them checks; a suite the author has watched fail is the only suite that counts.**
- **The index ruling, and the three-part scoping.** **(iii) is the load-bearing half:** *the declared
  subject field belongs on the PRODUCER side — new run artifacts declare their subject — not on the
  index and not on the old artifacts.* **The index reads; the producer declares; the old rows keep
  their absence.** Same shape as (2) above, and Ocho reached both without being told.

## Record

- `check_frontend_clauses.py` (`9ac9f59`), `cabinet_index.py` (`1ed934f`), both on
  `frontend/index-and-clauses`. **Nothing on main but the name landing.**
- Belt rule 1 non-monotone, rule 2 monotone with 0 inversions (§1).
