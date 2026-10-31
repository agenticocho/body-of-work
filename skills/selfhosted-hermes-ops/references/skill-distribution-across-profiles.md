# Distributing skills across the profile roots

One source for cross-cutting lessons, pushed to every profile; profile-specific knowledge stays local.
This box runs many profiles, so one skill can exist many times over.

## The roots, enumerated explicitly

```
~/.hermes/skills                     the canonical dir -- belongs to NO profile
~/.hermes/profiles/*/skills          one per profile, plus nested category dirs
~/.hermes/hermes-agent/skills        the BUNDLED set -- excluded as a source
```

- **Enumerate these; do not `rglob('skills')`.** A recursive sweep also matches venvs, uv caches,
  `node_modules`, `website/` doc trees and tool bundles -- dozens of directories that are not skill roots.
  A drift report over that set is noise, and the real drift disappears into it.
- **Exclude the bundled set BY PATH, never by content equality.** A bundled copy that happens to match
  everything else is still bundled; treating it as canonical makes the shipped set a source of truth it
  was never meant to be.

## The trap: a drift has no superset

**Drift is not "one is newer". Copies of the same skill name can be NON-NESTED -- measured over all pairs
of the six copies of one skill here, NEITHER copy's lines contained the other's. There is no superset.**

So a source assembled by taking the LARGEST copy silently DELETES the other copies, and nothing reports
it: the survivor is a perfectly valid skill, just a different one. **Never pick a winner by size or by
mtime, and never trust a timer.**

A drift that looks simple because one copy is an outlier still has to be READ: an outlier is either an
improvement to promote or local knowledge that must stay, and only reading tells you which.

## The drift set is PER BOX

Two machines running the same profiles do NOT have the same drift. One box's worst case may not exist on
the other at all, and the two sets can be entirely disjoint. **The only safe input to a push is the UNION
of the sets, reconciled per name** -- so report on each box and compare, rather than fixing one and
assuming it generalised.

## Order of work

1. **REPORT.** Run the drift report and read it. No writes, no pushes.
2. **RECONCILE, by reading.** Union the copies deliberately, per name. Non-nested copies need a human
   read, not a merge tool.
3. **WRITE THE PUSH TOOL LAST**, with two modes (check / push) and a drift report of its own.
4. **Report first, apply second.** The gate is ORDERED, not pre-push: a drift report is clean only
   once every root holds the source, which is the RESULT of a push — so it is *losslessness against
   every pre-push variant* BEFORE the push, and *a clean report* AFTER it. "Push nothing until the
   report is clean" is unsatisfiable as written, and an unsatisfiable gate is not a gate.

## The report tools — two readers of ONE unit

Both instruments walk the SAME file set, imported from `skills_push.carried_files` (`skills_drift.py`
does `import skills_push`): the unit of a skill is its whole DIRECTORY, never `SKILL.md` alone. Two
instruments that disagree about what a skill IS will disagree about whether it has drifted, and that
disagreement looks exactly like a green report. So the unit is defined ONCE, in the pusher.

```
python3 ~/.hermes/profiles/tiel/governance/skills_drift.py            FLEET IDENTITY, report only
python3 ~/.hermes/profiles/tiel/governance/skills_push.py --check     PUSH PLAN,    report only
```

**A green from the first means the fleet is uniform; a green from the second means nothing needs
writing. They are not interchangeable, and neither answers the other's question.** Where both can
speak — a name that HAS a source — they agree by construction, and `compare_instruments.py` asserts it.

Red from the fleet report (exit 1):

- **differing copies** — a name whose non-bundled copies differ in content or in FILE SET. A
  `SKILL.md`-only report was measured BLIND to nine such drifts on this box (2026-10-16): eight
  drifted linked files and a file-set difference, plus one file present in a single copy. It called
  those names clean while a push that copied only `SKILL.md` left every one of them drifting.
- **an absent copy** — a name that has a canonical source but is missing from a profile root. A
  source name is fleet-wide by construction, so a root without it is a gap even though no two copies
  disagree. This is the class that made the two greens disagree before 2026-10-16: the pusher called
  it `ABSENT` (red) while a name-level report said nothing at all.

Warned, exit unchanged: a name with NO canonical source that exists in more than one root — identical
today, no source to reconcile against, forked by the next edit to either copy.

- `--json` feeds a deliberate merge
- **exit 1 on drift, exit 2 when it cannot read** — never green on an instrument that failed. An
  unreadable file is exit 2 in BOTH tools: the pusher used to raise an uncaught `OSError`, and CPython
  exits 1 on those, which is the code that means DRIFT FOUND.

**Do not copy either tool into each profile as a `scripts/` entry of this skill: that is the same
duplication they exist to detect.** Point at the one path.

## The push tool — and why its unit is the whole DIRECTORY

`python3 ~/.hermes/profiles/tiel/governance/skills_push.py --check`   report only, writes nothing
`python3 ~/.hermes/profiles/tiel/governance/skills_push.py --push`    apply (use `--dry-run` first)

- **The unit is the whole skill directory, not the name.** A name-level `SKILL.md` check is blind to two
  real drifts: a reference file with two variants under a name the checker calls clean, and reference
  files that one copy has and another does not have *at all*. Both were measured here on 2026-10-16 —
  three names reported clean carried a two-variant reference file, and one name's copies differed by ten
  files. A push that copied only `SKILL.md` would leave every one of those drifting.
- **It never deletes.** A file present in a profile's copy and absent from the source is reported as
  `EXTRA` and left alone: profile-specific knowledge looks exactly like `EXTRA` from the source's side, so
  a mirror would be the operation that destroys it.
- **A nested `SKILL.md` is a different skill name** and is never carried by a push — and its files are
  therefore reported as `nested`, NOT as `EXTRA`: counting them as extra made one root look permanently
  dirty because of a different skill living under it (measured on tiel's copy of this very skill, which
  hosts `chilly-ocho-verification`). The nested name is reported under its own name by the fleet report.
- **A root holding files the source does not have prints `OK·EXTRA`, never a bare `OK`.** EXTRA is what
  profile-local knowledge looks like from the source's side, a push never deletes it, and it never
  changes the exit code — so the pusher's green answers the push question only. **The fleet question
  is the other tool's.**
- **Overwrites are backed up OUT OF TREE**, under
  `~/.hermes/profiles/tiel/governance/skill-push-backups/<UTCstamp>/<root-slug>/<name>/<relpath>`, with a
  `manifest.json` naming every file written. Out of tree on purpose: a foreign file sitting inside a skill
  directory has already caused one loading incident on this box, so no backup file is ever placed in a
  skills tree.
- **The backup path needs a UNIQUE root slug.** Every root's leaf directory is `skills`, so a slug made
  from the leaf name silently makes every profile's backup collide into one file — measured: 63 overwrites
  kept 10 backups. Slug from the root's path relative to `~/.hermes` instead.
- **Exit codes: 0 nothing to write, 1 drift, 2 refusing** (source missing, unknown name, a file that
  cannot be read, backup slot already holding different content). A root holding EXTRA files does not
  make it 1: there is nothing for a push to write there, and the EXTRA is labelled in its output.
- **The bundled set is excluded BY PATH** and is never written.
- **To change what the fleet holds, edit the SOURCE and re-run `--check` then `--push`.** Never edit a
  profile's copy: that edit is drift by construction, and the next push is what will decide it — with the
  profile's copy backed up first, and `EXTRA` files (new files) left in place.
- **A previous version is not unrecoverable even when a backup is missing.** Hermes keeps
  `~/.hermes/profiles/<p>/.curator_backups/blobs/<sha256>` — the blob's filename *is* the digest of the
  file's previous content — so a skill's earlier bytes can be recovered by digest even after a push.

