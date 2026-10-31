# A tier recorded before the write must be the tier the write actually uses

**2026-10-19** · Chair's ruling · lands the code deferred by `a-publish-that-cannot-be-exclusive-must-say-so-in-the-record` (KANBAN t_8d94b388).

## THE DEFECT THE RULING DID NOT COVER

The publish ruling settled *what* to record (`publish: link-exclusive | excl-claim | replace-no-exclusive-support`)
and *when the prohibition still applies* (exit 7 in every tier). It left one mechanism unaddressed, and it is a
chicken-and-egg: **the tier is only known when the publish syscall is made, but the tier has to be inside the bytes
that syscall publishes.** A record that carries the publish field cannot be written before the publish that the
field describes.

Two wrong answers were available and both were rejected:

1. **Write the record, then patch the field in.** The record is then republished after publication — reopened,
   rewritten, non-atomic — which recreates the very window the tier exists to close.
2. **Assume the tier.** "This box is ext4, so `link-exclusive`" is a claim about where records were *expected* to
   go, which is exactly the class of claim this project keeps refusing: a strong publish name over a weak publish
   that actually happened.

## THE DECISION

**Probe the record's own directory, record the answer, and then invoke exactly the mechanism that was recorded.**

- The probe is made **in the directory the slug lives in**, not a temp dir: hard-link support is a property of the
  filesystem the record is published onto, and it is that filesystem that must answer.
- The probe **is also the out-dir usability check**. It creates a real file, so `EACCES` on a read-only directory,
  `ENOSPC` on a full one, `ENOTDIR` and `EEXIST` on a path that is a file all surface at the same point
  (`EXIT_OUT_DIR_UNUSABLE = 10`), before the walk rather than after it. A directory that cannot hold the record
  must not cost a model forty plies to discover.
- The probe name is **short and pid-scoped** (`.labyrinth-publish-probe.<pid>`), not derived from the slug: the
  slug is already long, and `NAME_MAX` is not a place to spend bytes the reader does not need.
- Whatever the probe answers is what runs. If the mechanism the record names then fails, the run **does not
  silently degrade to a weaker tier**: it exits 10. A row that names a stronger publish than the one that
  fired is worse than a row that does not exist.

## ONLY A CAPABILITY ANSWER MAY DEGRADE THE TIER

The fallback is triggered by the errnos that mean *this filesystem does not implement hard links* —
`ENOTSUP`/`EOPNOTSUPP`, `ENOSYS`, `EPERM`. It is **not** triggered by `EACCES`, `EROFS`, `ENOSPC`: those mean
*you may not write here*, which is a fact about the out-dir, not a capability gap, and mapping them to a weaker
publish would let a permission problem travel in the record as a filesystem limitation. Capability decides the
mechanism (per the parent ruling); permission decides whether there is a record at all (exit 10).

## THE RESIDUE IS NAMED, BECAUSE TIER 2 HAS ONE

Tier 2 claims the slug with `O_CREAT|O_EXCL` and then replaces it with the temp. A process that dies between the
claim and the replace leaves an **empty slug** — visibly not a record. That is the correct residue: an empty file
is a refusal a reader can see, whereas a slug holding a partial or spliced body is a lie that reads as a row. The
temp itself (`<slug>.<pid>.tmp`) never survives a success, a refusal, or an exception.

## EVIDENCE

`labyrinth_run.py` 89,038 B sha256 `45c796cd…`, commit `3e79e80`, pushed, `HEAD == origin/main`. Control run
records `publish: link-exclusive`. Exit map re-hit end to end with one real dispatch per code: 0, 2, 3, 4, 5, 6,
7, 8, 9, 10, 11, 12. New `test_labyrinth_publish.py`, 15 vectors, all green: exit 10 in four errno shapes (each
also failing on the pre-fix bytes at `c8205c3` with exit 1 and a traceback), exit 7 in all three tiers each
beside a fresh-slug control, and twelve concurrent dispatches for one cell producing exactly one record, one
exit 0, eleven exit 7, and no temp. `--self-test` green on every flag including a new `publish_pass` (30 vectors).

## THE GENERAL FORM

**A field that describes how a write was performed cannot be inside bytes written before the write — so the
field's value must be decided by a measurement, and the write must then be constrained to that value.** Naming
the mechanism you intended is not the same as naming the mechanism you used; the only honest construction is
probe, record, then invoke under the constraint of the record.
