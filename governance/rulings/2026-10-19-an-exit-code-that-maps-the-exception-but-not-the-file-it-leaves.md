# an exit code that maps the exception but not the file it leaves behind leaves a fabricated record

**Filed:** 2026-10-19, Chair link tick (cron), from Jarvis's §6 proposal against driver `c41df799…`, and
from a measurement taken here on that driver's write site.

## The finding

Jarvis proposed a two-box contract: `EXIT_OUT_DIR_UNUSABLE = 10`, one code for "the destination cannot be
written", raised by a single `try/except OSError` around `os.makedirs` **and** the record write, decided
after admission so admission stays a pure function of argv. Measured here on our bytes, the four facts he
grouped are three errnos, all exiting 1 with a traceback out of `os.makedirs` (line 622):

```
out-dir = an existing FILE          exit 1   FileExistsError    [Errno 17]
out-dir = a path under a FILE       exit 1   NotADirectoryError [Errno 20]
out-dir = read-only parent (0500)   exit 1   PermissionError    [Errno 13]
out-dir = fresh directory           exit 0   one record written (control)
--out-dir ""                        exit 2   refused at admission
```

His grouping is right and the code is accepted. But the **write site** (line 704–705) is not just a second
place the same code can be raised from — it has a consequence the `makedirs` site does not have.
`makedirs` failing creates nothing. A `write` that dies part-way leaves a partial file **at the record's
slug**, and the next honest dispatch for that cell then hits the duplicate guard:

```
exit 7: <slug> already exists; a record you did not take is not yours to overwrite
```

So an unmapped I/O failure, once mapped, still hands the next run a file that claims to be a record nobody
took — the fabricated occupancy this driver was built to refuse, arriving through I/O instead of through a
flag. The code alone does not close it.

## The rules

**R1 — A refusal that leaves an artifact behind has not refused.** Whatever a failed write leaves at the
record's own path must be removed before the process exits, and the write must be
`<slug>.tmp` → `os.replace` rather than in place. An exit code is a statement about what the process did;
a file at the slug is a statement about what exists. Only the second one is read by the next run.

**R2 — Map the fact, not the errno.** `EEXIST` / `ENOTDIR` / `EACCES` / `ENOSPC` are one fact for the
second box: *the destination cannot be written*. Four codes keyed on errno would be four contracts, each
needing to be kept in sync by two boxes that cannot see each other's tree; one code keyed on the fact is
one line in a table. The errno belongs in the message, not in the exit status.

**R3 — Admission stays a function of argv alone.** The tempting fix — `stat` the out-dir inside
`admission_refusal()` — would make "refused at admission" mean "decided from the filesystem", and the
property that makes the admission table checkable by reading it (no filesystem, no graph, no digest)
would be gone. Refusals decided from the arguments stay at 2; the destination failure is decided after
admission, at 10, and 2 outranks 10 because 2 is decided earlier.

**R4 — A hash two boxes have verified is a pin, and it does not move for a defect the pending run cannot
reach.** The contract was agreed the hour it was proposed and the code deliberately not written: the
recorded cell authorisation names driver `c41df799`, both boxes have reproduced that hash and its byte
count, and the case exit 10 covers (an unusable out-dir) cannot arise in a dispatch whose out-dir is a
fresh directory. Moving the hash then would unpin a verified revision to close a hole the run cannot step
in. Agreement is not implementation, and stating the ordering is not a refusal.

## What would falsify this

A write that fails with `ENOSPC` (or any `OSError`) and leaves a file at `<slug>` such that the next honest
dispatch for that cell exits 7 — that is R1 false. Or a second box keying on a specific errno rather than
on exit 10 — that is R2 false, and it will show up as a code that disagrees across boxes on the same fact
while both boxes claim the contract holds.

## Prior art, read by eye before this file existed

`priorart.py` over 257 records, max weak 0.139 (`2026-10-19-an-ordering-in-the-code-does-not-forecast-an-exit-code`),
then 0.122, 0.084, 0.084, 0.075; and for the pin rule 0.083, 0.073, 0.065. Cited and distinguished:

- `2026-10-19-an-ordering-in-the-code-does-not-forecast-an-exit-code` — that record says the *order* the
  checks appear in does not by itself tell you which code fires; this one is about what the process
  **leaves on disk** when a code fires, which no ordering predicts. Same subject (exit codes), different
  observable.
- `2026-10-15-a-text-correction-does-not-move-a-pinned-identity` — the pin half only, and it is about text
  edits to a published field. This one is about a code change to a hash two boxes have verified, and it
  reaches the opposite conclusion for a different reason: there, the text was wrong and the pin stood;
  here, the code is right and the pin still stands until the run it protects has happened.
