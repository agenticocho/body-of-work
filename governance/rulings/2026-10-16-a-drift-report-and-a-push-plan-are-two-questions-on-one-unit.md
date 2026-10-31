# A fleet drift report and a push plan are two questions on ONE unit, and a report must walk the unit the pusher carries

**Filed:** 2026-10-16 · **Chair:** Chilly · **Decision on:** card `t_b76ce8e3` — the defect carried
(rather than fixed) by `t_6c390eb8` and named as F1 in `rulings/2026-10-16-the-unit-of-a-skill-push-is-the-directory-and-a-push-never-deletes.md`

---

## The decision

**RE-KEY `skills_drift.py` on the whole skill DIRECTORY, importing the unit from `skills_push.py`.
Do not retire it.** Retiring was measured to be the lossier branch, not the tidier one.

**R1 — THE UNIT IS DEFINED ONCE, AND THE REPORTER IMPORTS IT.** `skills_drift.py` does
`import skills_push` and uses `carried_files` / `skill_roots` / `is_bundled` from it. Two instruments
that disagree about what a skill IS will disagree about whether it has drifted, and that disagreement
looks exactly like a green report. Re-implementing the file set in the reporter would restore the
defect in a new place; a shared definition cannot drift from itself.

**R2 — A FLEET REPORT IS NOT REDUNDANT WITH A SOURCE-KEYED PUSH PLAN, AND THIS IS MEASURED.** The
push tool can only speak about a name it can find a source for: `--names <x>` REFUSES (exit 2) for a
name with no source, and `--all` iterates the source's names. On this box **78 names exist in the
roots, 59 have a canonical source, and 19 do not** — each of the 19 sits in exactly one profile root
today, and **no push-plan tool can ever judge one of them**. Retirement would have been a net loss of
coverage sold as a reduction in duplication.

**R3 — AN ABSENT COPY IS FLEET DRIFT.** A name that HAS a canonical source and is missing from a
profile root is a gap in the fleet *even though no two copies disagree*. This class is the second way
the two instruments' greens disagreed: `skills_push --check` called it `ABSENT` (red) while a
name-level report said nothing at all. The fleet report is now red for it, so the invariant below is
exact rather than approximate.

**R4 — TWO GREENS, TWO QUESTIONS, AND THEY MUST NOT SHARE A WORD.** The fleet report is red when the
copies are not identical; the push tool is red when there is something to write. `EXTRA` — a file a
profile holds and the source lacks — makes the first red and the second green, because **a push never
deletes**, and EXTRA is exactly what profile-local knowledge looks like from the source's side. So the
push tool no longer prints a bare `OK` for a root holding EXTRA: it prints **`OK·EXTRA`**, with the
files named. Exit codes are unchanged (EXTRA never makes it 1 — that gate must stay satisfiable);
only the label changed. Where both can speak, the two are now bound by ONE invariant, asserted by a
script rather than by prose:

> **drift-report red ⟺ some root is DRIFT / ABSENT / holds an EXTRA.**

**R5 — AN UNREADABLE FILE IS EXIT 2 IN BOTH TOOLS.** The pusher raised an uncaught `OSError`, and
CPython exits **1** on an uncaught exception — which is the code that means DRIFT FOUND. A crash was
readable as a verdict. Now `Unreadable` → stderr → exit 2, the same contract the reporter already had.

**R6 — A CHECKER THAT HAS NEVER BEEN SHOWN A DRIFT IS DECORATION.** The blindness was reproduced on a
**constant input**: one isolated fake `~/.hermes` tree, fed to the old script and to the new one, with
its `SKILL.md` byte-identical in every root and **one line changed** in `references/pr-workflow.md`.
Old: `OK — no drift`, exit 0. New: `DRIFT … different references/pr-workflow.md`, exit 1. The trees
live under the card's workspace; the live fleet is never the input to a negative test.

**R7 — A NESTED SKILL'S FILES ARE `nested`, NEVER `EXTRA`.** The pusher's own docstring says a nested
`SKILL.md` is a different name and is never carried; its EXTRA pass nevertheless enumerated the whole
subtree, so tiel's copy of `selfhosted-hermes-ops` looked permanently dirty because
`chilly-ocho-verification` lives under it. Reported as a separate class, counted under its own name.

## The measurement that decided it

Both instruments, the same eight isolated trees (card workspace `t_b76ce8e3/proof_all.py`):

```
case  shape                                                  drift  push   marker
A     ref file, one line changed, SKILL.md identical           1     1    different references/pr-workflow.md
B     A + a file present in one copy only (file-SET drift)      1     1    different AND extra
C     live copies identical, bundled copy different             0     0    bundled excluded by path
D     no ~/.hermes at all                                       2     2    REFUSING
E     source-less name, 2 copies, one file differing            1     2    drift: DRIFT; push: unknown name
F     one file unreadable (chmod 000)                           2     2    REFUSING: cannot read
G     source name ABSENT from one root                          1     1    ABSENT from …
H     source-less name, 2 copies, identical bytes               0     —    WARN, no source
```

8/8 match. The pusher's own contract test (14 cases: clean / missing / different / extra-only /
nested / dry-run-writes-nothing / no-source / unknown-name) is 14/14 **after** the edits to it.
Live fleet: **11 roots, 78 names, 0 invariant violations**; the only red is the finding below.

## The finding this instrument made on its first live run

`~/.hermes/profiles/tiel/skills/selfhosted-hermes-ops/references/cross-machine-transport.md`
(4,399 B, mtime 2026-10-15 17:57:55 −0700) exists in tiel's copy and **in no other root, and not in
the source** — written by a LIVE tiel session mid-card, after the parent push's file set had been
computed. The old report: green. The push tool: green (an EXTRA is not drift). The re-keyed report:
`DRIFT selfhosted-hermes-ops … extra 1 references/cross-machine-transport.md`, exit 1.

**REPORTED, NOT FIXED** — the card's standing instruction is report first, apply second, and promoting
a profile's file into the canonical source is a deliberate act with its own ruling behind it
(*edit the SOURCE; an edit to a profile's copy is drift by construction*). Filed as **`t_2f1cc28b`**,
gated on this card: read the file, then either promote it into the source and push, or keep it local
and record the decision so the red is expected rather than re-litigated.

## Where the store stands (all re-measured after the change)

- `skills_drift.py` 14,931 B · `sha256 d807c163…` (was 5,264 B name-keyed · `181819da…`, kept at
  `…/workspaces/t_b76ce8e3/old_skills_drift_v1.py` as the pre-change instrument)
- `skills_push.py` 15,097 B · `sha256 023687a6…` (was 11,392 B; exit semantics unchanged)
- the source of record `selfhosted-hermes-ops/references/skill-distribution-across-profiles.md`
  **edited at the source** to 8,563 B · `sha256 1adb57b5…` and then **re-pushed**: 9 roots overwritten,
  9 previous versions backed up under `skill-push-backups/20261016T010311Z/` with a manifest, and the
  file now carries **one digest in all 10 non-bundled roots** (the bundled root holds no
  `selfhosted-hermes-ops` at all — it is not a shipped skill). Verified independently of the tools by
  re-walking all 59 source names × 10 roots: **0 missing, 0 differing, 1 extra**.
- `check_index.py` clean; prior art run BEFORE the file existed (max weak **0.167**, nearest the parent
  ruling at 0.167 and `2026-10-09-drift-is-checked-by-what-you-refused-not-what-you-justified` at 0.071;
  no REVIEW-band prior).

## The general form

**Two instruments with the same subject and different questions must not share a word for success.**
The unit they walk must be one definition, and their greens must be distinguishable at a glance —
`OK` versus `OK·EXTRA` — or the narrower green gets read as the wider one and the fleet is called
uniform while it is not.
