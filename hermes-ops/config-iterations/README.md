# config-iterations — what these files are, and what they are not

**This README exists because an INDEX row claimed it did. That row was written before the file,
which is the defect this directory's contents are now being used to illustrate.**

## The files

```
nvidia-egl-fallback.json                     67 B   b25bcfd1…   the live config
nvidia-egl-fallback.json.bak-20261006-064246 68 B   c00d6349…   ┐
nvidia-egl-fallback.json.bak-20261007        68 B   c00d6349…   │ five byte-identical
nvidia-egl-fallback.json.bak-20261008        68 B   c00d6349…   │ snapshots
nvidia-egl-fallback.json.bak-20261008-1007   68 B   c00d6349…   │
nvidia-egl-fallback.json.bak-20261008-1339   68 B   c00d6349…   ┘
nvidia-egl-fallback.json.bak-20261029        67 B   b25bcfd1…   byte-identical to the live file
```

**Two byte states across seven files spanning 23 days.**

## What they are not

**They are not an iteration record.** An earlier version of this description called them *"the
seven-iteration NVIDIA EGL fix"*. That was wrong, and the bytes disprove it: **five snapshots are
identical to each other, and the sixth is identical to the file it backs up.** Nothing moved between
Oct 6 and Oct 29 except the clock.

**What they actually record is a backup process running on a configuration that did not change** —
including one run (Oct 29) that produced a copy of the live file and therefore a snapshot of nothing.

## What they are

**Evidence that the backup ran**, and honestly that is all. Anyone reading them for the history of the
EGL fix should read the FINDINGS and the dated iterations elsewhere in this repository — not here.

## Admission status

**Retained, declared, and not to be read as provenance of a change.**

An admission test over this tree flags these files by shape (`*.bak-*`) and it is right to. **This is
the written exemption the test needs, and the reason is the sentence above**: the shape says "backup",
the bytes say "no change", and neither says "iteration". **A directory name is not an admission claim**
— it carries no pattern and no reason. This file carries both.

**Kept rather than removed** for the same reason the attic keeps its file: deleting evidence that a
process ran is not the same as correcting what we said about it.

## The lesson this directory is now an example of

`MANIFEST.sha256` verified all seven of these files, `verify_manifest.sh` passed the tree, and **every
digest was correct while every description of what the files meant was wrong.** Integrity is not
admissibility, and neither of them is meaning. A file can be byte-perfect and still be misdescribed —
and the misdescription is the part a reader is most likely to believe.
