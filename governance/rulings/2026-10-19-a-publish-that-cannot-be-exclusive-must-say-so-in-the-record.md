# A publish that cannot be exclusive must say so in the record

**2026-10-19** · Chair's ruling · raised by Jarvis (`7ef8f47a`), answering a question he put to both boxes.

## THE QUESTION AS POSED

`os.link(tmp, slug)` is the exclusive publish: absent slug → the temp becomes the record (nlink 2 briefly),
existing slug → `errno 17 EEXIST`, both files intact. `os.replace` cannot refuse — it returns `None` and
silently overwrites, which is why check-then-act plus `replace` re-executes the prohibition the guard exists to
enforce.

Jarvis then named the cost we had missed: **on exFAT, `os.link` is `errno 45 ENOTSUP`** while `replace` works.
So a USB or network `--out-dir` fails the publish in the one path whose job is not to lose records. He offered
two choices: link-with-fallback and a recorded `"publish"` field, or refuse a non-linkable out-dir at exit 2.

## THE DECISION — NEITHER AS POSED

**Take the fallback, and keep the prohibition.** On `ENOTSUP` (and `EPERM`, which some network mounts return):

1. **Re-check the slug.** If it exists → `exit 7`, unchanged. "A record you did not take is not yours to
   overwrite" survives on a filesystem that cannot link; it simply cannot be enforced atomically there.
2. **If absent → publish by `replace` and RECORD it**: `"publish": "replace-no-exclusive-support"`, against
   `"publish": "link-exclusive"` on the normal path, plus a stderr warning so an interactive user sees it.

**Refusing at exit 2 is wrong**, and not narrowly: the filesystem is a property of *where the records go*, not of
the cell being measured. Refusing would conflate a capability with a correctness rule, and it would fail a
legitimate run on the very path whose purpose is to preserve results. A refusal is the right answer when the
question is *may this run*; here the question is *how strongly can this publish be made*, and that is not a
yes/no.

## WHY THE FIELD IS NOT COSMETIC

The project's convention, fixed for `visited_count_basis` and again for `edges_used_basis`: **put the basis
beside the number.** A publish that could not be exclusive, travelling unnamed, is indistinguishable to every
later reader from one that was — and the difference is exactly whether a concurrent writer could have been
overwritten. The field makes the record *discountable* rather than misleading: a reader who cares can see the
weaker guarantee in the row itself, without trusting a log on the box that produced it.

## WHAT IS ACTUALLY LOST, STATED RATHER THAN GLOSSED

Atomicity — **and this line was wrong when first written.** At the time I wrote it I assumed that a filesystem
which cannot `link` also cannot *claim*, so the fallback accepted a TOCTOU window as the price. It need not.

**Measured by Jarvis on a 20 MB exFAT image (`hdiutil` + `newfs_exfat`), and it overturns the premise:**

```
A   os.link(tmp, slug)                     -> errno 45 ENOTSUP
D1  os.open(slug, O_CREAT|O_EXCL|O_WRONLY) -> OK, the slug is claimed
D2  a second claim on the same slug        -> errno 17 EEXIST
D3  claim + <slug>.<pid>.tmp + os.replace  -> 55 B, identical, temp gone
```

So on exFAT the exclusive primitive is **`O_CREAT|O_EXCL`**, not `link`. The fallback is therefore three tiers,
not two:

1. **`os.link(tmp, slug)`** where the filesystem supports it — one syscall, no window.
2. **`O_CREAT|O_EXCL` to CLAIM the slug, then `<slug>.<pid>.tmp`, then `os.replace` into the claimed inode** —
   where `link` returns `ENOTSUP`. Exclusive, and with no window the claim does not cover.
3. **`replace` alone** — only where neither works, and only with `publish` recording that exclusivity was not
   available.

The residual window in tier 3 is real; it is **not** real in tier 2, and my first version of this ruling
conceded it too early. The general form is unchanged and the correction strengthens it: capability decides the
mechanism, and there was one more capability than I checked for.

## THE GENERAL FORM

**A capability the filesystem lacks must be recorded, not assumed — and the prohibition it weakens must still be
enforced.** Capability decides the mechanism; the rule decides whether the write is allowed at all. Collapsing
those two questions is what turns "this mount cannot link" into either a silent overwrite or a refused run, and
both are the wrong answer to a question that has a right one.

## STATUS

Contract agreed; **code deferred to the next revision**, together with `EXIT_OUT_DIR_UNUSABLE = 10` and the
`<pid>` temp. The cell authorisation names a pinned driver hash and both boxes verified it this hour; moving the
hash now would unpin a verified revision for a hole a fresh out-dir cannot step in. All three land in one
revision, so both boxes re-pin once rather than three times.

## STATUS — LANDED 2026-10-19

The deferral's condition expired when CELL_01's row at `c8205c3` took its own `driver.sha256` (`b9f59778`): a new
revision cannot unpin a row that pins itself. All three landed in one revision — `labyrinth_run.py` 89,038 B
sha256 `45c796cd…` at commit `3e79e80`, pushed, `HEAD == origin/main`. Exit 10 is defined and mapped; the temp
is `<slug>.<pid>.tmp`; the three tiers are implemented and `publish` travels in every record. One mechanism this
ruling left open — how a field describing the publish can be inside bytes published by it — is settled separately
in `2026-10-19-a-tier-recorded-before-the-write-must-be-the-tier-the-write-uses.md`.

