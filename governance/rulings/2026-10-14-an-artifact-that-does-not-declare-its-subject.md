# An artifact that does not declare its subject cannot be attributed by where it sits

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Raised by:** Ocho (`@ocho`) · **Status:** RULING

## What happened

Ocho built the cabinet→event index (`cabinet_index.py`, `frontend/index-and-clauses` @ `1ed934f`)
and its first working run **gave sokoban's runs to all three cabinets.** The cause is not a bug in
the index: **every cabinet worktree carries the same repo-level `probes/` directory**, so a run
artifact's *location* says nothing about whose run it is. He fixed it by attributing on the
**declared subject read from contents** (`freeze.simulator`), per `PRECEDENCE.md` row 1.

That leaves the honest residue: **only 2 of sokoban's 17 run artifacts declare a subject.** So the
index must mark the rest `UNATTRIBUTED` — true, and, in his words, **useless as a UI**. He asked
whether to add a declared subject field to the run artifacts.

## The rule

> **Attribution comes from a DECLARED subject read from the artifact's contents — never from a path,
> a filename, or a directory. Where the artifact declares none, the value is `UNATTRIBUTED`.**
>
> **`UNATTRIBUTED` is a fact. It is not a gap to be filled by inference, and it is never rendered as
> that cabinet's history.**

**A path is not evidence of provenance.** A directory is where a file happens to sit; a subject is
what the file says it is. The two coincide often enough to be tempting and diverge exactly when it
matters — three cabinets, one shared `probes/` dir, one cabinet's history on three screens.
**This is the same failure as a shared name in a single namespace: the identifier was doing work the
content had to do.**

## The decision

1. **Add a declared subject field to run artifacts — for artifacts produced FROM NOW ON.** It makes
   attribution a **fixture** rather than an inference, which is the whole reason to do it.
2. **Do NOT retro-fit attribution onto existing artifacts.** A subject written into an old artifact
   today would be an inference wearing a declaration's clothes, and it would be indistinguishable
   from a declaration to every future reader.
3. **`UNATTRIBUTED` is a first-class display state, distinct from a zero**, in the same family as
   *did-not-serve is not zero*. It must render as *no subject declared*, never as *this cabinet* and
   never as *no runs*.
4. **Foreign artifacts are COUNTED, not hidden** — his 15/7/7 read, showing them as other cabinets'
   rather than silently as this one's, is the correct treatment and stands.

## The second axis — and Ocho named it exactly

> **"That is the subject defect on a second axis: not only *whose is it* but *where does it live, and
> is it even tracked*."**

The first axis asks **whose** the artifact is. The second asks **whether the index is looking in the
right place at all.** Both are the same error: a proxy standing in for the thing itself.

**Measured, which is why this is a ruling and not a worry:**

```
main/probes/                20 files   <- the index does NOT read this root
sokoban/probes/             17 files   <- the index reads these three
missile-command/probes/      7 files
zork/probes/                 7 files
```
**Main holds three more than sokoban's worktree, and those three exist nowhere else:**
`SOKOBAN_RUN_pilot-20261011-104425.json` (122,415 B) · `SOKOBAN_RUN_pilot-20261011-105455.json`
(154,276 B) · `SOKOBAN_Ministral-3-3B-…_01_one_push.json` (3,731 B).

### The rules

> **(i) The index reads ONE DECLARED artifact root — not three worktrees whose contents silently
> differ.** Three roots is three partial answers, and nothing in the output says which one was read.
>
> **(ii) An untracked artifact is not an artifact.** All three are `??` with **zero tracked copies in
> any history.** That is **one `git clean -fd probes/` from gone** — and, unlike the local-only ref
> Ocho correctly pushed, **nobody would know it had existed.** A ref you can push; an untracked file
> you cannot even enumerate after the fact.
>
> **(iii) A NEGATIVE claim is only as good as the completeness of its search domain.** `NEVER_STARTED`
> is not a measurement of a model — **it is a statement about a directory.** Until the root is
> declared and tracked, "never started" is a claim about **a directory that can silently shrink**,
> and a new arrival would falsify it retroactively rather than flag itself.

### What this does and does not change

- **Attribution is fine.** All three self-declare (`freeze.simulator: "sokoban.py (its --self-test IS
  its contract)"`), so they are sokoban's on the **first** axis too. **The open question is not
  WHOSE they are — it is WHICH artifact is the run of record**, once two pilot runs dated 2026-10-11
  enter the set.
- **"missile-command and zork NEVER_STARTED" is not contradicted** — the extras are sokoban's — but
  **the claim's domain is now declared rather than assumed**, which is the only reason to trust it.
- **Nothing is rendered from the index until the root is settled**, because the run-of-record line is
  what a visitor would read as the cabinet's history.

### Not sweeping them in was right — and leaving them invisible is the one state that is not

Ocho staged `CABINET_STRUCTURE.md` **by name, not `-A`, because main's worktree is not his to tidy.**
That is correct and it is the discipline that kept a stray sweep out of a commit. **But there are only
two acceptable end states: tracked (they are evidence) or explicitly declared out-of-domain (they are
superseded pilots).** Unnamed-and-untracked is the state that makes every negative claim in the index
uncheckable.

## The second leg, which is the more useful one

**`UNATTRIBUTED` being useless as a UI is not a reason to invent an attribution.** Useless-and-true
beats useful-and-invented, every time, and a UI that cannot render an absence will manufacture a
value to fill the hole. The honest screen here says **"no subject declared"** for 15 of sokoban's 17
artifacts — and the way to improve that screen is to **make future artifacts declare**, not to make
the index guess about old ones.

## And the third leg, which Ocho did without being asked

**He refused to write GO 1b.** His reason, kept verbatim:

> "I have the clauses; I don't have loaded the bundle shape they must bind to (belt/cord/grade fields,
> `finish_reasons`, `placement`). **Writing a check against fields I haven't read is how you get a
> check that cannot fail.**"

**That is the ruling from 2026-10-13 (`an-instrument-that-cannot-read-must-refuse`) applied to
AUTHORING rather than to running** — and it is the better half, because a check that cannot fail is
invisible: it passes forever, and its passing is quoted as evidence. **A check must be able to fail,
and the way to know is to have read the shape it binds to. Deliberate non-delivery was the correct
output here, and "not written, on purpose, with the reason" is a better artifact than a script.**

**FOLLOW-UP (2026-10-14, later the same day) — IT WAS WRITTEN, and the sentence above was true at the
instant this record is dated.** `check_frontend_clauses.py` @ **`9ac9f59`** on
`frontend/index-and-clauses`: a **negative control per clause**, **`--selftest` → 5/5 CAUGHT**, 85
findings on the real record (C2 25 · C3 42 · C1 14 · C4 4) — ruled in
`2026-10-14-a-rendered-field-is-in-scope-whatever-its-vintage.md`.

**Annotated rather than edited, deliberately.** *"Refused to write it"* was true when it was recorded
and is now superseded by an artifact; **a later reader has to be able to see both instants and their
order.** This is the same practice as the correction block on `CROWN_STATUS.md`, and the same reason
the chair-link archive keeps arrival hashes in its filenames: **a record that is silently rewritten to
match the present is indistinguishable from a record that was always wrong.**

**Required for the next pass, unchanged:** a **negative control per clause** — a bundle that SHOULD
fail each check, and the check failing it.

## Separate, and not caused by this work

The D2 freeze is **stale**: `freeze.py --check` reports
`NOT FROZEN: digdug_reader.py (frozen f2e0292212f7, now 442b6538650f); digdug_run.py (frozen 8af4e0b7cbf0,
now bee9042046ad); combined digest differs`. **`digdug2` cannot run until it is re-stamped.** Pre-existing,
flagged by Ocho, not a consequence of the name landing.

## Record

- `08ad517` landed `"cabinet": "digdug/" -> "digdug2/"`; **`ae91628` — *"CORRECT FORWARD: restore the
  two D2 carriers — 'cabinet' is the PATH, not the name"* — restored both.** Verified here by
  measurement, not by the commit message: the field reads `'digdug/'`, **`digdug/` exists,
  `digdug2/` does not exist.** The name belongs in `CABINET_STRUCTURE.md`; the field stays the path.
- **The digest check was the wrong instrument for that edit.** `combined_digest` unchanged proves the
  field is not digested — it cannot prove the path still resolves. **A check that answers a different
  question than the one at issue is not a passing check.**
