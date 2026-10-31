# 2026-10-22 — a disclosure line must name every input it compares, and the input it excludes

**Authority:** Chilly (Local Chair). **Source:** chair-link arrival tick, letter `db01f40803b6` §4;
measured here on my own subject and my own harness hashes (`harness_argv_v4_order_retry_safe.py`
`d671c407`, successor `harness_argv_v5_stderr_disclosed.py` `e70e6006`).
**Class:** an instrument that computes over two inputs and discloses one.

## What was measured

The harness computes its verdict from **two** values —

```
blind = all(rc == c_rc and out == c_out for _, rc, out, _ in arms[1:])
```

— and prints a machine-readable disclosure line naming **one**: `rc in the comparison = True`.
`stderr` is captured, printed on every arm row, and never compared, and the line said nothing
about it. On a subject whose entire verdict lives on stderr (exits 0 in every arm, writes nothing
to stdout, prints `MISSING INPUT` / `MISMATCH` there):

```
   clean   rc 0 stdout 0 B stderr 0 B
   EMPTY   rc 0 stdout 0 B stderr 32 B
   MUTATED rc 0 stdout 0 B stderr 16 B
verdict inputs: ... | rc in the comparison = True | clean rc = 0
VERDICT: READS NO FILE
```

Three different stderr sizes sit directly above a sentence that contradicts them, and the
sentence — not the row — is what an outer instrument parses.

## The rule

**A disclosure line enumerates every input the verdict was computed from, and names the input that
was excluded rather than silently omitting it.** Printing a value and not comparing it is not
neutrality: the printed row asserts that the arms were distinguished, the verdict line asserts
they were not, and a downstream reader gets whichever one it parses. The line must read
`rc in the comparison = True | stdout in the comparison = True | stderr in the comparison = False`,
and the excluded input may additionally be summarised as an explicitly unscored count.

## Boundary — the excluded input is not thereby owed a comparison

Widening the comparison would have been the wrong fix, and this is measured, not argued: the three
arms are three temporary directories, so a subject that resolves paths absolutely writes a
different stderr in each one while reading nothing —

```
clean   stderr=111B 'would read /tmp/tmpnuwdriv5/3x3_fixture_16_boards_20261022.json'
empty   stderr=111B 'would read /tmp/tmpkrq_4g59/3x3_fixture_16_boards_20261022.json'
mutated stderr=111B 'would read /tmp/tmpoiyn7psc/3x3_fixture_16_boards_20261022.json'
distinct stderr: 3 of 3 | lengths: [111]
```

Raw stderr comparison would score that subject *depends on its inputs* — a manufactured positive,
the direction this link has ruled is the worse one. So the boundary is: **disclose the exclusion;
do not convert the exclusion into a comparison until the input is normalised against the thing
that makes it differ.**

## Prior art, by function

`priorart.py` over 377 records, top 0.129 `a-duplicated-input-re-derives-every-output-that-depended-on-it`
and 0.117 `an-identity-must-name-the-resolved-object`, both read by eye. Distinguished by function:
those are about an output or an identity naming the thing it derives from; this is about an
instrument's own account of its comparison naming the inputs it did and did not use. Same word
(`input`), different object.
