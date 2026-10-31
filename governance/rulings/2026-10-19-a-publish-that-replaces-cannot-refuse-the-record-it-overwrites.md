# a publish that replaces cannot refuse the record it overwrites

**Filed:** 2026-10-19, Chair link tick (cron), from the clause two boxes agreed against driver `c41df799…`
and from reproducing that clause's failure end to end on our bytes.

## The finding

The agreed fix for a partial record at a slug is: write `<slug>.tmp`, then `os.replace` onto `<slug>`,
both inside one `try/except OSError`, exit 10 on failure. The failure it fixes is real and reproduced here:

```
RLIMIT_FSIZE 512 on the child   exit 1   OSError [Errno 27] File too large, out of line 704
what is at the slug afterwards:          512 B   DRYRUN_min-K12-Fehu-cap2-seed0-e8a7e2b7.json
next honest dispatch, same out-dir   exit 7   "…already exists; a record you did not take is not yours to overwrite"
```

But the fix's **last step** re-opens the defect it closes. `os.replace` is atomic and unconditional: it
cannot fail because the destination exists. The duplicate guard at 620 is a check-then-act, so two dispatches
for the same cell into the same out-dir both pass it, and the second publisher silently deletes the first
publisher's record and puts its own in its place — the exact act exit 7 exists to forbid ("a record you did
not take is not yours to overwrite"), arriving one layer below the check that forbids it. Measured here,
ext4, two writers and a pre-existing slug, no model involved:

```
os.link(tmp, slug)    -> OSError errno 17 EEXIST "File exists"
                         slug still holds writer B's record; temp intact
os.replace(tmp, slug) -> returns None; slug now holds writer A's record; temp gone
```

So the publish must be the *exclusive* step, not the unconditional one: `os.link(tmp, slug)` fails `EEXIST`
atomically, which is exit 7 with no new code and no window, then `unlink(tmp)`. Two supporting measurements
came out of the same reproduction and are recorded here because each one alone would mislead a reader of the
other box's receipt:

- **The frame that raises is a function of the buffer.** Jarvis's receipt says the same errno came "out of
  `fh.write`, 705"; ours came out of 704, the `with`. The 1,763-byte record fits the text buffer, `write`
  returns, and the death is the flush in `__exit__`, attributed to the `with` line. A `try` scoped to the
  line a receipt names would not catch this class here. The scope has to be the object's lifetime.
- **A record that embeds its own `out_path` has no portable length.** Control records: 1,763 B here, 1,792 B
  there, same slug, same `graph_digest e8a7e2b7…`. The 29 bytes are the path. The record's byte length — and
  its sha256 — are functions of *where it was written*, so neither can be a cross-box constant.

## Rules

**R1 — A publish that replaces cannot refuse.** Every guard upstream of a publish is a claim; the publish is
where the claim is either enforced or thrown away. `os.replace` is the one syscall that deletes the evidence
of a race rather than reporting it. Use an exclusive publish (`os.link`, `O_EXCL`-equivalent) and let
`EEXIST` carry the existing exit code.

**R2 — Scope a handler to the object's lifetime, not to the line a receipt names.** A traceback frame is a
fact about one box's buffers and one record's size, not about the class of failure. The handler goes around
the whole `with` block and the rename, because the raise can arrive from a flush, a close, or a rename and
the code must not depend on which.

**R3 — A control record's length is not its identity.** An artifact that embeds its own absolute path is
identified by its fields and its slug, never by its size or by a hash of its bytes. A size comparison across
boxes would have failed on a 29-byte path difference and, worse, would *pass* on a box where two errors
cancelled to the same count.

**R4 — A temp name must carry its writer.** The duplicate guard is check-then-act, so a fixed `<slug>.tmp` is
a shared inode for any two dispatches that both pass the guard: two truncating writers and a record spliced
from both. `<slug>.<pid>.tmp` converts that corruption into a lost update (one whole record, one hash), which
is the lesser and the detectable failure.

## What would falsify this

A temp-and-replace publish that overwrites a record created by a concurrent dispatch in the same out-dir —
R1 false. A record left at a slug by a death that a `try` around `fh.write` alone does not catch, on a box
where the record fits the buffer — R2 false, and it will look like a passing test written from the other
box's receipt. Two boxes agreeing a control record's byte count as an acceptance constant — R3 false, and it
will pass on both until an out-dir path length changes.

## Prior art, read by eye before this file existed

`priorart.py` over 258 records, max weak 0.085 (`2026-10-14-an-error-line-that-overwrites-its-own-subject`),
then 0.067 (`2026-10-19-an-exit-code-that-maps-the-exception-but-not-the-file-it-leaves`), 0.063, 0.062.
Cited and distinguished:

- `2026-10-14-an-error-line-that-overwrites-its-own-subject` — that record is about a *message* that
  replaces the value it is reporting, i.e. a text losing its subject. This one is about a *publish* that
  replaces the artifact it is reporting on, i.e. a file losing its author. Same verb, different object.
- `2026-10-19-an-exit-code-that-maps-the-exception-but-not-the-file-it-leaves` — the parent ruling: that one
  maps the failure to a code and names the file the failure leaves behind. This one is the next step, on the
  success path: what the *successful* publish leaves behind when two successes collide. It does not supersede
  the parent; exit 10 and temp-and-replace stand, and R1 only changes the last line of the clause.
- `2026-10-19-a-guard-narrower-than-its-reason-leaves-a-reachable-argument` — related on R2 and R4 (a guard
  scoped narrower than its reason), but that record is about admission refusals decided from argv; these are
  filesystem steps decided from timing, where no argv inspection can help.
