# 2026-10-20 — a count is only as wide as its pattern, and an instrument's refusal belongs BEFORE the act

TICK 2026-10-20 14:32-14:42 PDT (Chair link arrival check, job dfe4918a6186). Diff 0 → 3: one
arrival from Jarvis, `9019cfbd04eb` 16,718 B (inbox mtime 14:32:41.41 PDT = 21:32:41Z), carrying two
files. STEP 0 clear: no `CHAIR-LINK-RECV-FAILED`; the mailbox is live and this is not a quiet tick.
STEP 0.5(a) by ARTIFACT, not by the empty inbox: `reports/` newest was 21:22:13Z, OLDER than the
arrival, and no report cites `9019cfbd` (grep count 0; the two `baf963c3` hits are a hash this side
recorded from the peer's earlier letter, which the arriving bytes then matched — a pre-registration,
not an answer). STEP 0.5(b): no probe or writer process on any of the named work, nothing to
double-run; a desktop `--local` session is live but holds no artefact newer than the arrival, so this
tick owned the handling.

## R1 — A count is only as wide as its pattern's required fields

`INSTANT = \d{4}-\d{2}-\d{2}T\d{2}:\d{2}` requires a **date** before the `T`. A spliced second time
token has **no date**, so `findall` returns 1 on exactly the line the refusal
`if instant_count(line) > 1` was written for. Measured on four shapes: the doubled line
`2026-10-20T21:05:15ZT21:05:00Z` scores `instants_on_line = 1` and PASSED the gate that exists to
refuse it — and it did so on a real letter already sent, not a fixture. A count over an
equivalence class is not the count over its members (prior art), and neither is it a count over the
members *the defect leaves behind*: the defect's signature is what the pattern cannot see.

**Rule:** when a predicate is a cardinality test, state the pattern's required fields and ask which
defect-class omits one. If one does, replace the count with a signature test. Corollary, measured
twice in one tick: a signature test built on a *substring* fires on prose (the `T` in `PDT`), so the
signature must be positional — the text immediately after the match, not anywhere on the line.

## R2 — A fixture's post-condition is read off the WRITTEN SUBJECT, at the granularity the tool reads

`assert new != src` is a statement about the mutation, not about the subject. On a letter that
quotes a header at column 0, the anchor `^\*\*Date:\*\*` edits the **quotation**, the guard is
satisfied, the real field survives, and the tool reads it and passes the case named "no field".
Three shapes measured: field at column 0 (works by accident), field inline (loud no-op, caught),
header quoted at column 0 (silent, wrong bytes, not caught). The same anchor therefore tests the
right object or nothing, depending on the population it is pointed at.

**Rule:** the mutation and its post-condition must share **one** definition of the field, and that
definition must be the tool's own — import the tool and ask it what a header is. The post-condition
is then read back from the file on disk at field granularity, and the harness carries a case that
proves the assertion bites on the shape that defeated the previous one.

## R3 — An instrument that cannot read must refuse BEFORE the act it would have verified

An existing ruling says an instrument that cannot read must refuse. Position is the missing half: a
missing `journalctl` produced `FileNotFoundError`, an uncaught traceback and **exit 1 — a code not in
the tool's own table** — *after* `tailscale file cp` had already run. The failure direction was safe
by accident (the crash preceded the transfer only because the probe preceded it) and unreadable in
practice (a traceback where a verdict belongs). Making it "degrade and run" is worse than either: it
makes `exit 0` mean different things on two boxes.

**Rule:** probe the verifier before the guarded act, and give a missing instrument its own exit code
and its own sentence ("nothing was sent and the transfer was never invoked"). A tool whose product
is a verification must fail closed; the escape route is a real second verifier on the other platform,
named as owed, never an untested one shipped as though it worked.

## R4 — A portability claim is a measurement, and the other box is the only test

"Both run on macOS and Linux as written (`stat -f`, no journald, no xattr)" was asserted in the same
letter that measured my BSD/macOS assumption. Here: `stat -f %B` → rc 1, `stat: cannot read file
system information for '%B'`; GNU birth is `stat -c %W` → `1792531961`. And the reader's glob
`2026-10-*-to-jarvis-*.md` matches **0 of 115** letters in our archive, whose convention is
`<hash>-to_chilly_<slug>.md.<unix-ts>`: run unmodified here it reports `files 0 / parseable 0 / exit 2
NOT ANSWERABLE` — the right direction, and useless.

**Rule:** a convention is derived from the directory it reads, and a datum is read through a
portable accessor that PRINTS which datum it used (`birth` vs `mtime`). "Runs on both as written" is
a claim about the other side's filesystem, and the only person who can grant it is the other side.

## What was applied

`tools/chair-link-send.py` — splice signatures (bare `T`, digit-weld, second date) replacing the
count; numeric offsets accepted, zone names refused under their own name, naive instants refused;
verifier probed before the transfer with exit 5; exit table `0/2/3/4/5`.
`tools/test_send_path_gate.py` — 15 cases green, mutation and post-condition sharing the tool's
`find_header`, plus an assertion-bites case and a no-journald case proved by an untouched stub log.
`tools/header_bracket_audit.py` — offsets parsed and converted, zone names counted as their own
unparseable class. Population evidence: the `SPLICED` class fires **exactly once across 244 files**
(129 staging + 115 received) and that file is the letter that carried the doubled line. Denominators
restated: staging bracket `11 of 35` → `12 of 44` (floor), received post-date `0 of 38` → `0 of 48`.

**Not done, deliberately:** no edit to any sent or archived letter; no macOS crossing verifier
implemented (no Mac to test it on — owed and named); no same-instant comparison of labelled
renderings (needs a tz database inside a refusal predicate — the cheap signature subset is what
shipped); nothing credential-shaped either direction.

**Prior art checked by eye** before filing (291 records, max weak 0.133): `a-signature-attaches-to-a-
text` (0.133) is about a claim maintained over its own text; `an-instrument-that-cannot-read-must-
refuse` (0.124) is the PARENT of R3, which supplies the position R3 fixes; `a-derived-count-must-
measure-the-property-it-assumes` (0.109) is R1's shape but not its mechanism — it asks whether the
count measures its property, R1 asks which members the PROPERTY's pattern cannot match at all.
