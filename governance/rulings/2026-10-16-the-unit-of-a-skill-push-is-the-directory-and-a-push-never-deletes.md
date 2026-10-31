# the unit of a skill push is the DIRECTORY, and a push never deletes

**Date:** 2026-10-16 (local mtime 2026-10-15 17:4x–18:0x PDT; the tick's UTC instants are 2026-10-16T00:44–01:05Z)
· **Chair:** Chilly (`tiel`), Local Chair
**Class:** RULING — five rules about pushing one skill source into many roots, extending
`2026-10-16-a-drift-set-is-per-box-and-a-name-is-resolved-by-a-layer` (R1 there is the parent: a drift set is
per-box and a source is assembled by union, never from the largest copy).
**Instance:** board card `t_6c390eb8`, the operator's decision relayed by the previous tick: *cross-cutting
lessons get ONE SOURCE and get PUSHED; profile-specific knowledge stays local; this box runs the push
mechanism rather than a hand-maintained set.* Order of work on the card: reconcile the three drifting names
by READING first, then write the pusher, and push nothing until that is done.

---

## The findings

**F1 — A NAME-LEVEL DRIFT REPORT IS BLIND TO EVERY LINKED FILE, AND THE BLINDNESS IS NOT SMALL.**
`skills_drift.py` keys on `SKILL.md` by parent-directory name: 11 roots · 78 names · 3 drifting. Measured
the same day at the **directory** level, the same three names carry **seven more drifted files** and one
file-set difference, none of which the name-level report can see:

| name | SKILL.md | linked files that also drift |
|---|---|---|
| `selfhosted-hermes-ops` | 6 live copies, **6 distinct** | `references/evidence-discipline.md` 9,628 vs 6,598 B · `references/third-party-webui.md` 19,278 vs 17,305 B; **tiel held 12 reference files the other five copies lack entirely** (10 at run start, 2 written by a live session at 17:37) and llama 2 (`model-trial-harness.md`, `nvidia-gsp.md`) — the union's 22 references are 8 common + 12 tiel-only + 2 llama-only |
| `github` | 10 live copies, 2 distinct | `references/pr-workflow.md` 11,883 (ocho) vs 9,746 B |
| `hermes-agent` | 10 live copies, 2 distinct | `references/background-systems.md` 6,934 vs 5,069 · `desktop-plugins.md` 14,019 vs 13,562 · `providers-and-models.md` 8,088 vs 3,381 · `troubleshooting.md` 6,786 vs 3,767 · **`multi-agent-repo-coordination.md` exists in ONE copy only** (ocho) |

A push that copied only `SKILL.md` would have left all seven drifting and would have called itself done.
**The unit is the directory.**

**F2 — THE SIX-WAY DRIFT IS COMPLEMENTARY, NOT CONTRADICTORY, AND THAT IS A MEASUREMENT, NOT A HOPE.**
All 15 pairs of the six `selfhosted-hermes-ops` copies are non-nested (base-vs-donor extra-line counts
353/224/144/38/36, reproduced). Reconstructing the union with a base chosen by *content* — the canonical
dir's copy, the one that contributes **no** unique line to any shared section — needed **20 additive
insertion blocks and exactly 2 replace-opcodes**: ocho's pointer sentence in the GUI-under-systemd section,
and ocho2's "`ExecStart target exists` **and parses**". Everything else the six copies disagreed about was
**material one copy had and another did not**, including four different write-ups of the same Desktop fault
class (`## Desktop can silently pin itself…`, `## Electron on XWayland renders in software…`,
`## Desktop freezes / crashes on Linux + NVIDIA…`, `## A Desktop that dies before its own log…`) which are
now one section with four subsections. **A union assembled by reading is additive in practice; the
destruction the parent ruling warns about comes from picking a WINNER, not from merging.**

**F3 — "PUSH NOTHING UNTIL THE REPORT IS CLEAN" IS UNSATISFIABLE AS A PRE-PUSH GATE, AND MUST BE RESTATED.**
A report is clean only when every root holds the source, which is the *result* of a push. Read literally the
gate forbids the operation it exists to enable — the same one-bit shape as R5 of the parent ruling. Restated
as two gates that can both be evaluated: **(a) no push until the reconciliation is finished AND its
losslessness is verified against every pre-push variant; (b) the pusher's own `--check` is run AFTER the
push and must come back clean, or the push is not reported as done.**

**F4 — A BACKUP PATH KEYED ON THE LEAF DIRECTORY NAME COLLIDES ACROSS ROOTS, AND THE LOSS IS SILENT.**
Every root's leaf directory is `skills`. The first push wrote **251 files and saved 63 "backups" into 10
files** — one slug per root name, so each profile's backup overwrote the previous one, and only the last
root's copy (zork's) survived. The pusher now slugs from the root's path relative to `~/.hermes`
(`profiles__birdy__skills/…`) and **refuses** if a backup slot already holds different content.

**F5 — AN OVERWRITTEN SKILL FILE IS STILL RECOVERABLE BY DIGEST, AND THAT IS WHAT BOUNDS F4.**
Hermes keeps `~/.hermes/profiles/<p>/.curator_backups/blobs/<sha256>` — **the blob's filename IS the digest of
the file's previous content.** All five `selfhosted-hermes-ops` variants whose in-tree backups F4 clobbered were
recovered byte-for-byte by digest (100,319 B/`897b11d7`, 88,934/`d2fc2d4e`, 82,073/`9c5fb07c`, 73,288/`03f7627f`,
73,212/`2308b9cc`), and the sixth (`73,461`/`426c61c2`) from the source-side pre-change backup. **So the rule
for F4 is "fix the slug", not "never push": the previous bytes have a home outside the tree you are writing.**

**F6 — WHAT THE PUSH DELIBERATELY DOES NOT DO.** It never deletes: a file present in a profile's copy and
absent from the source is reported `EXTRA` and left alone — from the source's side, profile-specific knowledge
and junk look identical, so a mirror is the operation that would destroy exactly what the operator asked to
keep. A nested `SKILL.md` is a **different skill name** (tiel's `chilly-ocho-verification/`, 7 files) and is
never carried. The bundled set is excluded **by path** and is never written. A skill loaded from the pushed
copy is verified through `skill_view`, not assumed: the three names load, and the union enumerates its 22
references and 6 scripts.

---

## The rules

**R1 — THE UNIT OF A SKILL PUSH IS THE DIRECTORY, AND THE REPORT MUST SEE WHAT THE PUSH CARRIES.** A
`SKILL.md`-by-name check is blind to a drifted reference file and to files a copy lacks entirely; both were
measured here under names the checker called clean. Check and push the same file set, or the check certifies
a push that does something else.

**R2 — A PUSH NEVER DELETES. `EXTRA` IS REPORTED, NOT REMOVED.** Profile-specific knowledge is
indistinguishable from junk when viewed from the source. A nested `SKILL.md` is a different name and is never
carried. The bundled set is excluded by path, never by content equality.

**R3 — A RECONCILIATION IS JUDGED BY ITS LOSSLESSNESS AGAINST EVERY PRE-PUSH VARIANT, NOT BY ITS SIZE.** For
each variant, every non-blank line must be present verbatim, or present in substance (token coverage ≥ 0.55,
measured), or be a recorded supersession. An unaccounted line is a failure of the reconciliation, and the fix
is to read the copy again — never to accept the difference.

**R4 — THE GATE IS ORDERED, NOT SINGLE: RECONCILE, VERIFY LOSSLESSNESS, PUSH, THEN REQUIRE THE REPORT CLEAN.**
A pre-push "clean report" gate is unsatisfiable by construction (F3). What must be clean *before* the push is
the losslessness check; what must be clean *after* is the drift report.

**R5 — A BACKUP PATH MUST BE UNIQUE PER ROOT (slug from the path, never the leaf name) AND MUST NOT BE
PLACED INSIDE A SKILLS TREE.** The leaf of every skill root is `skills`, so a leaf-keyed slug silently keeps
one root's backups; and this box has already had a skill-loading incident caused by foreign names sitting
inside skill directories, so backups go out of tree
(`~/.hermes/profiles/tiel/governance/skill-push-backups/<UTCstamp>/<root-slug>/<name>/<relpath>` + a
`manifest.json` naming every file written).

**R6 — BEFORE CALLING A PREVIOUS VERSION LOST, SEARCH BY DIGEST.** `.curator_backups/blobs/<sha256>` holds
prior content of anything the curator touched, keyed by the digest you already have from the drift report.
Five of six variants here were recoverable from it after their backups were clobbered. "The backup was
overwritten" is a finding about the backup, not yet about the content — and a backup path that collides is
not evidence that anything was destroyed.

---

## What was done about it

**The reconciliation (read-based, before any push).** Six `selfhosted-hermes-ops` copies read in full at the
section level (all orphans, all differing blocks, both replace-opcodes); `github` and `hermes-agent` read as
single-outlier drifts — in both cases the longer copy is a measured **superset** (every line of the shorter is
in the longer), so the outlier is an improvement to promote, not local knowledge. The union was then built by
a script that states its rule: base = the canonical dir's copy (contributing no unique line), every other
copy's extra blocks inserted against that original base in **one pass** — after a sequential per-donor merge
was measured to *revert* an earlier donor's insertion (a copy that still holds the original text "displaces" a
sibling's addition). Result: **2,338 lines, 139,710 B, sha256 `cd1678a9…`, from a 1,352-line base**; the file
that lands is `/home/chilly1/.hermes/skills/selfhosted-hermes-ops/SKILL.md`, with
`github` and `hermes-agent` taking their measured-superset variants.

**The push.** `skills_push.py` (`--check` / `--push` / `--dry-run`, exit 0/1/2) at
`~/.hermes/profiles/tiel/governance/skills_push.py`, beside the report tool it extends. Applied: **251 files
across 27 root/name pairs — 63 overwrites, 188 creates** (4 roots that never had `selfhosted-hermes-ops` now
do), then a deliberate source edit re-run end-to-end to exercise the loop: **9 roots drifted → 9 files
pushed → `--check` exit 0**.

**Verification (all read-only, all measured, none asserted).** 15 pre-push variants re-derived from the
curator blobs and the source-side backups and re-checked against the pushed files: **0 unaccounted lines**.
The bundled tree's digests are unchanged (`github/SKILL.md` `9d70e7c8`, `hermes-agent/SKILL.md` `dcdc4b2d`) and
its copy has no source-only file. `skills_push.py --check` exit 0 (0 drifting root/name pairs) and
`skills_drift.py` exit 0. `skill_view` loads all three from the pushed copy; the union enumerates 22
references and 6 scripts (the two extensionless gate scripts are not enumerated by the loader — pre-existing,
unchanged). Every root holds the source byte for byte.

**Collision noted, not fought:** while this card was reading, a **live `tiel` session wrote two reference
files into tiel's `selfhosted-hermes-ops` tree (17:37)** and touched `chilly-ocho-verification/SKILL.md`
(17:36). Those files were read into the union before the push, so nothing was lost, and the pusher leaves
`EXTRA` files alone. But it makes the point R1 implies for humans: **an edit to a profile's copy is drift by
construction** — it survives the next push only as `EXTRA` (a new file) or as a backup (an edited one). Edit
the source.

**Read-only elsewhere:** no model, GPU, lease, service, config, credential or repo touched; nothing written
outside `~/.hermes/skills`, the profile skill roots named above, and
`~/.hermes/profiles/tiel/governance/` (tool, backups, ruling).

**Carried as a defect, not fixed here:** `skills_drift.py` still reports at name level and therefore still
cannot see F1's seven files. `skills_push.py --check` sees them; the two instruments now disagree in scope,
and the older one should be retired or re-keyed on the directory. Filed as a follow-up card rather than
silently widening a tool whose behaviour other writers may rely on.
