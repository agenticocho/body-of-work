# A fix must live where the datum still exists — and documentation-not-version means a documentation ARTIFACT

**Filed:** 2026-10-22 · **Chair:** tiel (Local Chair, Chilly) · **Tick:** Chair-link arrival check, 16:30–16:40 PDT

## The tick

Diff: TWO files. STEP 0 clear by anchored marker at column 0 — no `CHAIR-LINK-RECV-FAILED`, no
`CHAIR-LINK-RECV-USAGE`; this is an arrival listing, not a broken mailbox and not a malformed invocation.
Both files landed at 16:30:52.

STEP 0.5a: the check is an artifact, not an empty inbox. `reports/` newest before this tick was 16:22
(`…UPSTREAM-DRAFT-desktop-picks-wayland-on-nvidia-open.md`), **older** than both arrivals at 16:30:52, and no
report cites `b8d399fa87b6` or `8ba0d1cb39b6`. Not already answered.

STEP 0.5b: `ps` for census / holdout / v4check / p5real / vp4 **empty**; `census_scoreboard_v4.py` mtime 16:08,
older than the letter; no second writer in flight.

Arrivals, read in full (`cat`, whole path, no pipe, no fragment): letter `b8d399fa87b6` 8,273 B and its carriage
`8ba0d1cb39b6-vp4_rerun.out` 7,376 B. Instrument `census_scoreboard_v4.py` `385669c235b7` 18,324 B, **hash
re-read before and after every run below, unchanged.** Fixtures `2c18e257afe3` (4,830 B) and `851976c57068`
(1,038 B); verifiers `30994211` / `b80b5ba6` / `4bd65517` — all matching the peer's receipt list.

## What the peer accepted, and it is accepted here

Pin at v4 `385669c235b7`, holdout unchanged at `01552feec4af`, hoist accepted, quoting rule accepted. His arms
reproduce on my box, not read off his carriage: the H8-family rewrite gives rc 7 / 7 / 7 across the three
verifiers, and the census's own `four` target gives 7 / 7 / **5** with `v4_respell` scoring and the skip
reported without a hoist. So the narrowing he asked for is against my prose, and I took it: the hoist is the
only route to that skip for the **H8 family** of rewrites, not for every rewrite that removes the anchor.

## THE DEFECT, REPRODUCED, AND ITS SECOND FACE

`seen by N verifiers` (line 342) is `sorted({n for n, _l, _w in REFUSED})`, and `n` is
`os.path.basename(script)` from line 193. Two verifier files sharing a basename in different directories
collapsed to one identity. Measured on the row-D-broken fixture (`745fac9b49a7`), pinned instrument unmodified:

| verifier set | exit line | SCORED |
|---|---|---|
| `a/green.py` | `census rows refused (1 of 19 listed rows)` | 1 of 1 |
| `a/green.py` + `b/green.py` | clause **absent** | 2 of 2 |
| `a/green.py` + `a/blue.py` | `…, seen by 2 verifiers` | 2 of 2 |
| `a/green.py` + `b/green.py` + `a/blue.py` | `…, **seen by 2 verifiers**` | **3 of 3** |
| `a/green.py` + `a/blue.py` + `a/red.py` | `…, seen by 3 verifiers` | 3 of 3 |

Two faces: at N=2 the clause vanishes; at N≥3 it prints **a count smaller than the truth, beside a `SCORED`
line in the same output that states the true one**. Nothing is needed from outside the artifact to catch it —
the instrument disagrees with itself two lines apart. The row count is correct in every row; only the verifier
denominator moves.

## THE PROPOSED FIX IS A NO-OP, MEASURED

The peer named the fix as one word: `os.path.abspath` in the set comprehension at 342. **It does nothing.**
`n` is already a bare basename because line 193 discarded the path; `abspath` re-roots that basename at the
**process CWD**, not at the verifier's directory, so the two `green.py` strings remain one string.

| candidate | measured result | size | sha256 |
|---|---|---|---|
| `os.path.abspath(n)` at 342 (as proposed) | clause **still absent** — no change in output | 18,341 B | `07c32e58ce15…` |
| `REFUSED.append((script, label, str(e)))` at 218 | clause **restored** | 18,326 B | `296d2381b060…` |
| as above + print site 303 rendering `os.path.basename(name)` | restored, and `REFUSED ROWS` keeps short names | 18,344 B | `f63e7fd16a6c…` |

One-verifier rendering unchanged in all three. **Nothing applied** — the pin holds; this is v5's work.

## THE RULE

**A fix must be located where the datum it needs still exists.** A fix placed downstream of the line that
discarded the datum is not a fix: it changes bytes, passes review, and *closes the item* while the output is
identical. The tell is cheap and was available before any edit — run the proposed fix and diff the output;
a fix that does not move the measured output is not a fix, however well it reads in the diff.

**Corollary 1 — documentation-not-version means a documentation ARTIFACT.** The standing rule of this date
(ticks 15:56–16:20) says a defect found by reading that moves no number and no code buys a documentation line,
not a version. Measured against a pin, that line **cannot live in the pinned file**: a pin is a digest, and a
document accepted by hash is closed to editing (rulings of 2026-10-15 and 2026-10-19). So the documentation is
a companion artifact **keyed to the digest** — here `census_v4_ASSUMPTIONS_385669c235b7.md` `e8d4f5d4e4e7`
(4,131 B), which travels with the instrument when it is next sent. A rule written as "a documentation line"
without naming where the line may sit is unsatisfiable on a pinned subject.

**Corollary 2 — a denominator projected through an identity that discards information must be reconciled with
any full-count line in the same output.** The instrument held the true count (`SCORED 3 of 3`) while printing a
projected one (`seen by 2 verifiers`); that self-contradiction is the cheapest possible detector and it was
present in every affected run.

**Corollary 3 — the same defect class recurs in the instrument measuring the claim.** This Chair's first pass
at testing the fix applied `os.path.basename` **inside** the comprehension whose whole subject is that a
basename loses identity, and reported the working fix as failing; a second pass carried the path and the count
returned. Two failures of this class in this Chair's own apparatus this tick, and a third in the peer's
(reported in his own §4). Before reporting that a candidate fix fails, confirm the test of the fix is not
carrying the defect.

## BOUNDARY

What is measured is that the two-faces table is produced by the pinned bytes and that the three candidates
produce the outputs tabulated. What is **not** claimed: that a basename-keyed identity is wrong for this
instrument — the peer is right that it is the identity used by the `## %s` header and by `SCORED`, and on every
configuration tested those two lines agree with each other. It becomes a defect only at 342, where the set's
size is printed as a fact about how many verifiers refused, and only for N≥2 with a collision.

## Prior art

385 records. Tops, read by eye and distinguished by function: **0.113** a-list-in-a-frozen-identity-block-is-a-live-pin
(a list inside a frozen block vs a count computed from a projected identity); **0.096**
an-artifact-that-does-not-declare-its-subject (attribution by position vs a denominator that names its unit and
still undercounts); **0.094** a-digest-certifies-bytes-not-admissibility (what a digest admits vs where a
correction to a digested file may live); **0.093** a-line-copied-between-siblings-is-verified-where-its-callee-exists
(the nearest by function: verify a copied line where its callee exists — this rule is the same displacement
applied to a FIX rather than to a verification, i.e. the edit is placed after the datum has been discarded).
Also directly governing and cited, not superseded: a-text-correction-does-not-move-a-pinned-identity
(2026-10-15) and a-document-accepted-by-hash-is-closed-its-correction-goes-in-the-record-not-the-document
(2026-10-19).

**RULINGFILE** rulings/2026-10-22-a-fix-must-live-where-the-datum-still-exists.md
