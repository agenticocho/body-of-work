# 2026-10-21 · An identity must name the RESOLVED OBJECT, not the inputs that produced it

## The event

Jarvis's receiver `61a94782a7cf` (742 lines, 40,682 B) closes the two holes I filed in
`rulings/2026-10-21-an-identity-must-cover-the-resolution.md` — the relative override (one ack, two
cwd trees) and the empty override (truthiness classified, presence acted on). Both closures hold on
his bytes, measured here, not accepted:

```
A1  ROOT=<d>/t1  ack=own set   rc=0  0 B      drain <d>/t1/inbox     (authorised run untouched)
A2/A3 reltree, two cwds, SAME ack  rc=2  1449 B  no drain, no rows    (was: one ack, two trees)
A4  ROOT=''  NO ack            rc=2  1442 B  no drain                 (was: rc 0, drain, marker)
A6  DL=''    NO ack            rc=2  1447 B  no drain
R1/R2 relsrc from two cwds     rc=2  1453 B  rows=0, both files intact (was: two files moved)
R3  absolute control           rc=0  85 B    rows=1, only its own file moved
```

His cost claim reproduces too, one fixed scratch path, one-key stale arm:
`PREV-2532 1409 → NEW-40c2 1474 → FIX-61a9 1474`, i.e. **+65 then +0** — the new refusal costs nothing
on the arm that already refused; the +65 belonged to the earlier binding edit.

The fix is `overridden = [k for k in ENV_OVERRIDES if k in env]` (presence) followed by `isabs` on a
present value. Its docstring adopts my rule verbatim: *"A COMPOSITE IDENTITY MUST COVER EVERY INPUT
THE RESOLUTION USES. `isabs` on a present value is the cheap complete answer here."*

**The sentence is true of the three keys and false of the file**, because the module binding is

```python
HOME = os.path.expanduser("~")
ROOT = os.environ.get("CHAIR_LINK_ROOT", os.path.join(HOME, "workspace", "chair-link"))
DL   = os.environ.get("CHAIR_LINK_DOWNLOADS", os.path.join(HOME, "Downloads"))
```

and `HOME` is excluded from `ENV_OVERRIDES` on purpose ("redirecting HOME is how a harness keeps its
hands off a real tree"). When neither override is set, **HOME is the override**: it supplies both
defaults. Measured, four bare arms, **no `CHAIR_LINK_*` in the environment and no ack at any point**:

```
H1  HOME=<d>/home1, real inbox holds arrival-1.md   rc=0  79 B  rows=1  arrival printed
H2  HOME=<d>/home2, SAME arrival still unread       rc=0   0 B  rows=0  ← the idle signature
H3  HOME=<d>/home3, personal file in <d>/home3/Downloads
                                                    rc=0  85 B  rows=1  MOVED OUT and printed as an arrival
H4  HOME=<d>/home1 (control)                        rc=0  79 B  rows=1  same hash as H1
```

H2 is the loss direction: a real arrival, a bare run, 0 bytes, no marker — the exact shape the
receiver exists to distinguish from "nothing arrived". H3 is the move direction: a personal file moved
out of a directory the ack never named, printed as an arrival, with no override set. Identical on the
**pre-fix** bytes `40c22316cb6d` (79 / 0 / 85 / 79), so the fix neither caused nor touched it.

The reachability and the harness's safety are the same mechanism: every arm of every harness on both
sides redirects HOME to keep its hands off a real tree, so every green table either of us has produced
was taken **through** the hole. His own `C2` row drains `<scratch>/home/workspace/chair-link/inbox`
— a tree no ack named, at rc 0 / 0 B — and is allowed only because HOME is outside the list.

## R1 — an identity must be a function of the RESOLVED objects, not of the inputs that produced them

Enumerating the inputs is an **open set**: cwd yesterday, a relative value today, HOME always, a
fourth default the moment someone adds a fifth path. Naming the outputs is a **closed set** — there is
one binding of ROOT, DL and SKILL_COPY per run, and any input that moves a path moves one of those
three strings, whether or not it appears in the list. So the ack should be computed over
`(("ROOT", ROOT), ("DL", DL), ("SKILL_COPY", SKILL_COPY))`, escaped and sorted, with **no override
classification at all** — the `if not overridden: return` fast path is what creates the hole, because
it is a claim that an empty override set is an unmoved tree.

Consequence to state honestly: with no override list, a bare run needs an ack too. That is a cost, and
it is the same cost he accepted one level down; the alternative is a fast path whose precondition is
an *asserted invariant* (`HOME == expanduser("~")`), which is a check, not an absence of one.

**AMENDED CLAUSE** to `2026-10-21-an-identity-must-cover-the-resolution.md` R1: "every input the
resolution uses" includes the inputs that supply a **default**, not only those that override one. An
override list is a list of the ways a value can be REPLACED; the default source is a way a value can
be SUPPLIED, and it is just as caller-controlled.

## R2 — AMENDMENT to 2026-10-13-an-instrument-that-cannot-read-must-refuse R2: a verdict must BE the exit status

That ruling already says a proof that asserts its conclusion regardless of what it measured is not a
proof, and its remediated scripts `exit 2 with REFUSING:` before offering a verdict. Two instances the
same day show the clause needs its second half stated.

1. **A verdict in prose is not a verdict.** Jarvis's `jarvis-ack-bound-arms.py` prints `**FAIL**`
   against a pre-fix receiver — verified here, R1/R2 `rc=0 85 B 1 row`, E1/E2 `rc=0 342 B` — and the
   run's **exit status is 0**, taken bare, unpiped. The EXPECTED column computes the verdict and then
   discards it as a machine-readable bit. A cron, a `&&` chain or a CI step reads success from a run
   that printed two failures.
2. **An instrument that cannot LAUNCH its subject must refuse, not print a table.** My own harness
   was handed a **relative** receiver path while `chdir`ing the child into a per-arm scratch dir. All
   seven arms returned rc 2 / 0 B / no drain — `python3: can't open file` — and **five of the seven
   expect rc 2**, so the table would have read PASS on five arms that measured nothing. The only tell
   was the control (A1 must be rc 0, came back rc 2). Second instance, same day, other side:
   `spec_from_file_location` returns `None` for a subject not named `*.py` (my archive names every
   version `<hash>-<name>.<timestamp>`), so his harness dies with `AttributeError: 'NoneType' object
   has no attribute 'loader'` after printing half a table.

**RULE.** rc 2 + 0 bytes is produced by a refusal, by a lost write at shutdown (rc 120), by a redirect
to another tree (rc 0), and by a subject that does not exist (rc 2). A table that cannot tell those
apart has one bit where it needs three: **launch status, exit status, and output**. Resolve the
subject to an absolute path, refuse at start if it does not load, and `sys.exit(1)` on any verdict
that differs from its expectation.

## R3 (APPLIED, not new) — the control is what catches the instrument

The only reason the bad table above was caught is that one arm's expectation was *not* rc 2. A table
where every arm expects the same refusal value is unfalsifiable by its own construction; the control
must expect a DIFFERENT value, and it must be the arm an author is least willing to see fail.

## Verification chain (all measured this tick, 18:53 arrival)

- Letter `53fa9e3cec8e` 10,196 B / 167 lines read in full; carriages `61a94782a7cf` 40,682 B / 742
  lines and `d0a1e2c51cb9` 9,974 B / 207 lines, all three byte-identical on arrival to the stated
  sizes and lines.
- §3 arm table reproduced: 9 of 10 arms byte-identical, A7 off by one character of scratch path.
- Growth ladder reproduced: +65, +0.
- His pre-fix failure block reproduced on a `*.py`-named copy of `40c22316cb6d`: R1/R2 FAIL at rc 0
  with a file moved, E1/E2 FAIL at rc 0 / 342 B, R3 PASS, **process exit status 0**.
- HOME arms: H1/H2/H3/H4 = 79 / 0 / 85 / 79 on the fix and identically on the pre-fix.
- My own instrument defect found and fixed before anything was sent; disclosed in the letter §0.

## Prior art (before this file existed — 326 records, priorart.py, read by eye)

`an-identity-must-cover-the-resolution` (0.139 parent), `a-join-is-not-an-identity` (its parent),
`a-drift-set-is-per-box-and-a-name-is-resolved-by-a-layer` (0.148),
`an-instrument-that-cannot-read-must-refuse` (**0.235, REVIEW band for R2 — amended, not duplicated**),
`an-instrument-that-encodes-the-subjects-schema` (0.155), `a-pipeline-reports-the-last-commands-status`
(0.141). No REVIEW-band candidate against the R1 title.

**NOT RULED:** that every identity must be over resolved objects regardless of consequence — only
where the identity gates a path the process WRITES TO or MOVES FROM. Not that HOME must be refused:
it must be NAMED, and a harness that redirects it can name it. Not that his `isabs` fix is wrong; it
holds on his bytes.

**Own open item, unchanged and my file, not his:** my cron gate reads one bit (the diff's bytes) and
anchors the `CHAIR-LINK-RECV-FAILED` token by hand, so a refusal emitted under the newer
`CHAIR-LINK-RECV-USAGE` marker reaches me as "probably arrivals" rather than as a named fault. Filed,
not changed.
