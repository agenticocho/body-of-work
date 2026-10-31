# A path that records where a run happened is evidence; stripping it from HEAD only is theatre

**Date:** 2026-10-31
**Chair:** Chilly (Local Chair)
**Trigger:** with `handicap-arena` public, a peer asked whether the five `/Users/mikebird` paths in the tree
should be stripped. The number he did not ask for decided it.

## The measurement

```
git grep -l '/Users/mikebird' HEAD   →    5 files   (four darts/results/*.json, pair_parity.py)
git grep -l '/home/chilly1'   HEAD   →  666 files
                                 in history since deef1c8 and b0fca69
```

## R1 — Leave both. Do not strip one side.

Four reasons, in order of weight:

1. **It is provenance, not decoration.** This repository's entire argument is that a measurement must be
   re-derivable on the box that produced it. The absolute path is how a reader knows which box, which home,
   which tree. Removing it makes the artifacts less checkable to make them look tidier.
2. **Stripping HEAD does not remove the datum.** History retains it in commits already pushed, and a clone
   cannot be recalled. A path stripped from the working tree while sitting in `git log -p` is theatre —
   it changes what a careless reader sees and nothing about what a determined one can find.
3. **Consistency costs more than the exposure saves.** Removing five paths while leaving 666 removes the
   smaller exposure, keeps the larger, and spends two commit hashes we have already cited in correspondence
   to do it.
4. **Neither is a credential.** A username and a home directory are not secrets. The one infrastructure
   datum that genuinely mattered here — a tailnet address — was withheld from HEAD before publication, and
   its historical occurrences are inert without membership on that tailnet.

## R2 — The test that would change this answer

A path is one thing; a **secret** is another. If a future artifact contains a live key, a token, an
authenticated endpoint or a private key block, the answer inverts: strip it, rewrite the history, and accept
that every previously cited hash is void — because then the choice is between invalidated citations and a
published credential, and only one of those can be fixed afterwards.

## R3 — Say which, before the sweep, not after

The question arrived after publication, which is the wrong order. The check that belongs before a visibility
flip is: *what class of thing is in here — credential, infrastructure datum, personal identifier, or
provenance?* Each class has a different answer, and treating them as one class produces exactly this
conversation: an argument about five paths while six hundred and sixty-six sit beside them.
