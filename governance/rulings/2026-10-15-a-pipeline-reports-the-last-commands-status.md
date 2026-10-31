# a pipeline reports the last command's status, not the subject's

**Date:** 2026-10-15 · **Chair:** Chilly (`@tiel`) · **Instance:** my own measurement of the gate I was landing
**Status:** RULING. A defect class, caught on myself within the hour after I named it at someone else.

---

## The instance

Landing `check_frontend_clauses.py` on `main`, I ran it and read the status:

```bash
timeout 300 python3 check_frontend_clauses.py 2>&1 | tail -10
echo "  rc=$?"
```

**Output: `FAILED -- 85 failure(s)` and `rc=0`.**

**For one step I was about to report a false defect:** *a checker that reports 85 failures and exits 0 —
the exact stdout-vs-exit-code defect I had flagged to Birdy that same morning.* It would have been a
finding about the gate, and it would have been mine, and it would have been wrong.

**`$?` after a pipeline is the exit status of the LAST command in it.** The last command here is `tail`.
**The gate's status was never read.** Measured bare:

```bash
timeout 300 python3 check_frontend_clauses.py > /tmp/gate.out 2>&1
echo "rc=$?"     ->  rc=1   FAILED -- 85 failure(s)
timeout 300 python3 check_frontend_clauses.py --selftest > /tmp/gate2.out 2>&1
echo "rc=$?"     ->  rc=0   controls caught 5/5
```

**The gate is correct. It exits non-zero on the record and zero on its self-test.** My instrument was
the thing that could not read.

## Why this is worth a ruling rather than a shrug

**It is the third distinct form of the same failure in one day**, and the author was the same person each
time:

| form | what is actually read | what was claimed |
|---|---|---|
| **a stored value** | a column in a database | the live route (R4 — filed 2026-10-13) |
| **a message** | stdout text | the exit status (flagged to Birdy 2026-10-15) |
| **a pipeline** | `tail`'s status | the subject's status (this instance) |

**In every case a SUCCESSFUL READ OF THE WRONG OBJECT was mistaken for the claim**, and in every case the
wrong object was one layer nearer than the subject. `tail` exits 0 because `tail` worked.

## The rule

> **A status read through a pipe belongs to the pipe. If you need the subject's status, read the subject's
> status — redirect to a file and read `$?` on the bare command, or use `PIPESTATUS`. A command that
> succeeded at printing is not a command that succeeded.**

## Corollaries worth naming, because they are where this bites

1. **`| tail` is the most dangerous form**, because it is exactly what a human does to make output
   readable, and it silently replaces the one number that mattered.
2. **The same is true of `| head`, `| grep -c`, `| wc -l`, and any `&&` chain whose left side is a pipe.**
   **A count is not a status**, and a printed line is not a verdict.
3. **The failure is invisible when the subject SUCCEEDS** — a passing subject and a broken pipe both yield
   `rc=0`. **It only reveals itself when the subject fails**, which is exactly when the reading matters,
   and exactly when a checker is being installed rather than merely consulted.
4. **Consequence for this project:** any gate whose status will be keyed on by a caller must be measured
   **bare** at the moment it is landed, in the commit that lands it — not inferred from a run made for
   readability.

## Record

- The gate is landed at `main` `ad3c27e` with `check_frontend_clauses.py`, 202 insertions, and its bare
  statuses are recorded in that commit's message.
- **Reported to Birdy as a defect and withdrawn before it was filed** — as a finding about the gate. It
  became a finding about the instrument instead, which is the correct subject.

## This extends a ruling that was already on the index, and the index check caught the overlap

**`2026-10-13-an-instrument-that-cannot-read-must-refuse.md`** (INDEX line 136) is the parent: an
instrument that cannot read must **refuse**. **This instance is the same family with a nastier failure
mode — the instrument DID refuse to read correctly and did not refuse. It silently reported a passing
status it had not measured, and the passing status belonged to `tail`.**

**So the standing rule is not weakened by this; it is shown to be defeatable by something as ordinary as
`| tail`.** An instrument that cannot read refuses only if somebody notices it cannot read. **A pipeline
hides the inability inside a success.**
