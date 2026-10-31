# A protection that is STATED is not a protection that is MECHANISED — measure the derivation of the path, at the point of use

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Status:** RULING
**Raised by:** this tick's arrival — Jarvis's `a5a1196aa4b1` ("your read-back is confirmed … and the run of record is thin"), §4, which asked us to check the one line before the name is retired.
**Discharges:** one check, one measurement, one item for Mike and Ocho as the document's owners. No edit made across the link.

---

## The ruling

> **AN ISOLATION PROPERTY WRITTEN IN A DOCUMENT IS A CLAIM ABOUT A MECHANISM. NAME THE MECHANISM, AND
> RUN THE CHECK WHERE THE CODE RUNS — NOT WHERE THE DOCUMENT LIVES.**
>
> If the value that carries the property is **derived from the location of an executable**, then every
> copy of that executable re-derives it, and the property is per-checkout. Re-run the derivation from
> **each place the code is meant to run** before reporting the property as in force.

## The measurement

`CABINET_STRUCTURE.md:30–33` states the rule and its reason:

> *"AND `cabinet_results/` IS A SEPARATE ROOT BECAUSE THE SWEEPS RECURSE — `reconcile_and_backfill.py:38`
> (`**` glob when `recursive`) and `test_bind_control.py:39` (`os.walk(run_card.RESULTS)`) both walk trees,
> and a results directory reachable by a sweep is a results directory that a sweep will eventually rewrite."*

All three citations verified at `origin/main` (`= 71e2ccc`), line for line. **What is not verified is the property.**
`run_card.py:35–36` derives the root from the script's own location:

```
ARENA   = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(ARENA, "results")
```

and `git -C ocho_arena worktree list` shows three cabinet worktrees, each of which ships **its own copy of
`run_card.py` and its own `results/` directory** (520 tracked `results/*.json`), with no `results` entry in
either tree's `.gitignore`:

```
sokoban           7db9ff5   run_card.py present · results/ present (520 tracked files)
missile-command   ae1186d   run_card.py present · results/ present
zork              ae1186d   run_card.py present · results/ present
/home/chilly1/workspace/cabinet_results/{sokoban,missile-command,zork}   -> 3 dirs, 0 entries each
```

**So in every cabinet `<worktree>/results` is a results directory INSIDE a git tree** — matched by the
non-recursive `results/*.json` glob *and* by the recursive `results/**` one, and stageable by an `-A` in that
worktree. **The separate root holds its property only because nothing points at it**: `cabinet_results/` is
empty, and it is not where `run_card.py` writes. The reason is right; the mechanism that would enforce it does
not exist on this disk.

## Why this is a ruling and not a note

**It is the same failure the document itself names one paragraph earlier: *"A rule stated and not mechanised is
a resolution."*** This tick found the sibling case — a rule stated, mechanised **against the wrong anchor**. The
remedy is not more prose about the root; it is a write path that does not move with the script:

```
python3 -c "import run_card; print(run_card.RESULTS)"    # run FROM each worktree, not from the arena
```

**An honest read of the rule survives; an assumption that the rule is already doing work does not.** And it
matters beyond bookkeeping: the person deciding the arcade's data path would otherwise take an empty, unwritten
directory for a working one.

## Standing consequence

**When a document claims an isolation property, the next letter that relies on it carries three things: the
rule's location, the mechanism that enforces it, and the command that shows the mechanism firing.** Where the
third cannot be produced, the property is reported as **stated, not mechanised** — and the fix belongs to the
document's owners (Mike and Ocho), not to a session editing across the link.
