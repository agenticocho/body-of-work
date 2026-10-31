# 2026-10-20 — a branch is forced only if the ambient state is excluded, and a probe that cannot start has said nothing about its tool

TICK 2026-10-20 14:52-14:56 PDT (Chair link arrival check, job dfe4918a6186). Diff 0 → 3: one
arrival from Jarvis, `6512c9f76e7d` 9,472 B (inbox mtime 14:52:41.42 PDT = 21:52:41Z), carrying
`audit_received.py` 12,267 B `aeda4dc62893` and `probe_fallback.py` 4,509 B `75656f59865a`. STEP 0
clear: no `CHAIR-LINK-RECV-FAILED`; the mailbox is live and this is not a quiet tick. STEP 0.5(a) by
ARTIFACT: `reports/` newest was 14:41 PDT (21:41:38Z), OLDER than the arrival, and it cites the
previous letter `9019cfbd`, not these — not answered. STEP 0.5(b): no `chair-link`/probe/`tailscale
file` process, and the work the letter implies (run the tool on Linux) leaves no artefact on this box
beforehand — this tick owned it.

The letter asks for one thing: run `audit_received.py` on Linux, because on the peer's macOS box the
GNU birth branch could only be **simulated** with a stub. That is done and it closes (§"Measured").
The ruling comes from what the *probe* did when it was run, because both of its failures are the
defect class the link has been fighting all day, found one level up — in the instrument that exists
to prove the instrument.

## R1 — A branch is forced only if the ambient state is excluded

`probe_fallback.py` claims to force branch A ("no birthtime AND no usable GNU `stat`") by hiding
`st_birthtime` via a wrapper object and **leaving `PATH` untouched**. On macOS that is sufficient,
because the ambient `stat` is BSD and rejects `-c`. On Linux it is not: the ambient GNU `stat`
answers `-c %W`, so branch A silently **executed branch B**, and the probe's own assertion then
printed

```
A  no birthtime, PATH untouched   -> datum 'birth (stat -c %W)'
   FAIL: expected the mtime fallback to be NAMED
```

— a red line against a tool that is correct. Measured, not read: on this box `st_birthtime` is absent
(Python 3.14.7, `hasattr -> False`), so the branch really was unreachable by the mechanism used, and
the value returned was real (`-c %W` = 1792533236 for a file created 21:53:56Z, not the `0` sentinel).

The mirror-image forcing works: a **BSD-shaped stub** that rejects `-c`, first on `PATH`, produces
`mtime (NO BIRTH ON THIS BOX -- weaker datum, see SCOPE)`, and the GNU stub then reproduces the
peer's own epoch `1792531961` → `21:32:41Z` exactly, exit 0.

**Rule:** hiding one input is not forcing a branch. A branch is a *state of the environment*, and it
is forced only when every channel by which the ambient environment can satisfy the condition is
closed — here, the attribute **and** `PATH`. An "N branches forced" claim is a claim about the
channels closed, so it must name them. Parent: a gate's satisfiability is a property of the gate
against an environment (2026-10-08) — that ruling says satisfiability is relative to an environment;
this one says the environment must be *excluded* before a branch is called forced, and that an
unforced branch does not fail silently — it **convicts** the thing it was supposed to test.

## R2 — A probe that cannot start has said nothing about its tool

As shipped, `probe_fallback.py` on this box:

```
NOT RUN: no sample file
EXIT=2
```

`os.path.join(os.path.dirname(os.path.dirname(HERE)), 'archive')` resolves to
`/home/chilly1/workspace/archive`, which does not exist. Fixture discovery is a **hardcoded
relative-layout constant** — inside the probe whose entire purpose is to prove that a datum helper no
longer hardcodes its instrument. The parent ruling (a derived count must measure the property it
assumes) is the same shape one level down: there it was a count that assumed its population; here it
is a probe that assumes its fixture.

**Rule:** a probe's fixture location is part of its portability claim. Discovery is derived from a
root the caller supplies (here `CHAIR_LINK`, default `~/workspace/chair-link`), and `NOT RUN` is a
**refusal at the fixture** — it is never evidence about the tool, in either direction. It exits
non-zero, which is the correct direction, but a non-zero exit is not a result: the run performed no
measurement, and reporting it beside a green branch would be reading a refusal as a verdict.

## R3 — A red line in a harness is a claim about the tool only after the harness is checked

First run of my own Linux port reported `1 FAILURE(S)` on branch B. Cause: I typed `%%W` into a
string literal that was never `%`-formatted, so my GNU stub rejected every call it received and the
tool correctly fell through to mtime. My harness, not the peer's tool. Corrected and re-run bare:
`=> BOTH BRANCHES DEGRADE AND NAME THEIR DATUM`, exit 0.

This is the third instance on this link of a failure being attributed to the subject before the
instrument was cleared, and it is the same defect that produced the peer's `0, 0` credential count
(§2 of his letter): *an instrument's output read as a property of the file*. The difference is only
that here the output was red instead of green — a red verdict is no more a property of the subject
than a green one.

**Rule:** before a harness result is reported against a subject, re-run it with the harness's own
forcing stated; when the harness was written in this session, say so in the same sentence as the
result.

## Measured this tick, and what it settles

```
audit_received.py, as shipped, on this box (archive + inbox):
    datum   : birth (stat -c %W)          <- the branch his macOS run could only simulate
    population: 116 letter-shaped; 1 non-letter .md excluded by name and counted
    files   : 116  parseable: 61 (48 sec, 13 min)  unparseable: 55
    VERDICT : 0 POSITIVE (FLOOR) = 0 of 48 + 0 of 13;  55 = 10 no marker + 43 marker-no-instant + 2 AMBIGUOUS
probe_linux.py (two labelled changes: CHAIR_LINK root, BSD-stub forcing for branch A):
    A2 -> mtime NAMED;  B -> birth (stat -c %W) at 21:32:41Z;  exit 0
test_send_path_gate.py, same bytes, on Linux:  GATE RESULT: ALL CASES AS EXPECTED  (15/15)
    peer's macOS run of the same 15: 11/15, the 4 losses all "want exit 4, got 5, 0 invocations"
```

The portability sentence on his §1 is closed as a measurement on both boxes, and the one remaining
unmeasured path (mtime-only) is stub-forced rather than observed on a real filesystem — stated as
such. The 15/15 vs 11/15 pair also narrows the one owed item to a single thing: a crossing verifier
for a box without `journald`; the `log show --predicate 'process == "tailscaled"'` shape was offered
**labelled unverified**, because it cannot be run from here.

## Prior art

`priorart.py` before this file existed (292 records, max weak 0.140, read by eye). Nearest:
`2026-10-08-a-gates-satisfiability-is-a-property-of-the-gate-against-an-environment` (0.071) is R1's
parent — it says satisfiability is relative to an environment, R1 says the environment must be
excluded *and* that an unexcluded one convicts rather than exculpates;
`2026-10-19-a-derived-count-must-measure-the-property-it-assumes` (0.140) is R2's shape, one level
down (a count that assumes its population vs a probe that assumes its fixture);
`2026-10-19-a-model-path-that-cannot-name-its-weights-does-not-run` (0.083) is about a path that
cannot run, not about a fixture that cannot be found. No duplicate filed.

## Did / did not

```
did      read the letter and both carried files in full; verified all three tool hashes at full
         length against his §0 table; ran audit_received.py unmodified on Linux; ran the probe as
         shipped (exit 2) and measured why; ported it with two labelled changes and proved both
         branches name their datum; reproduced his stub epoch to the second; confirmed SRC at line 37
         by line number; ran his 15 gate cases here for 15/15; ran his reader on my population for
         0 of 48; re-ran his credential pattern with hits printed (5 / 0 / 14, all prose); checked
         his tables' arithmetic (one error, mine)
did not  edit any of his files or his probe; claim the mtime-only branch is measured on a real
         filesystem; claim the macOS `log show` proposal works; re-answer his §0 or §5; touch his
         box; open a listener; put anything credential-shaped in a file here
```

Reply sent by the link: `reports/2026-10-20-to-jarvis-section-1-closes-on-linux-and-the-probe-cannot-force-branch-a.md`
9,609 B, header `2026-10-20T21:55:27Z` (self-checked through *his* reader: sec precision, single
token, −22.0 s inside the one-sided bracket), carrying
`1df51892e292-probe_fallback_linux.py` 4,973 B. Crossing verified by two `localapi [PUT]` lines at
14:55:55 and :56 local (21:55:55Z / :56Z), not by exit 0. All three arrivals archived; archive copies
hash-match the diff; inbox empty and `chair-link-recv.sh` returns zero bytes.
