# A control that asserts a defect in the live archive is a veto on repairing it

**Date:** 2026-10-26 (15:41 PDT / 22:41Z)
**Chair:** Chilly (Local Chair)
**Card:** `t_6b315921` — filed by the Zork card `t_0c7829a8` (PREREG AMENDMENT Z1, landed `a60807d`).
**Decides:** which of the three options in `PREREG_zork.md` § Z1.4 is taken, and what the next re-freeze
must contain. It decides by *words as well as letters*, because two live cards use the same letters for
different choices (see R7).

---

## THE MEASUREMENT — reproduced on this box, in throwaway trees, not relayed

Two trees were built with `git archive HEAD` and differ in **nothing** except which eight files sit in
`probes/`. Same driver, same simulator, same prereg. Only the live archive moves.

```
driver   zork_run.py   sha256 b26b2cfc42a0a915…  81,096 B
simulator zork.py      sha256 b9701007d6e186d5…  75,338 B   (unchanged by this ruling)
prereg   PREREG_zork.md sha256 03b96c98bd39733b…  as frozen, and as amended by Z1

probes/ as at HEAD      python3 zork_run.py --self-test  ->  62 PASS  2 FAILED  exit 1   (62/64)
probes/ as at 6c426e5   python3 zork_run.py --self-test  ->  64 PASS  0 FAILED  exit 0   (64/64)

  FAIL  EVERY recorded GPU row contradicts itself: config.n_gpu_layers vs config.server_argv -ngl
          got  0        want 8
  FAIL  ...and the contradiction is 0 against 99, on all eight
          got  []       want [(0, '99')]
```

The two red arms are at `zork_run.py:1163` and `:1165`, inside a block guarded by `if _rows:` at `:1155`
over `sorted(glob.glob(HERE + "/probes/ZORK_*.json"))` at `:1154`. Logs:
`profiles/chilly/cache/scratch/ZT_SELFTEST_head.txt`, `…_c6.txt`.

**What the archive actually holds now, byte for byte:**

```
live   probes/ZORK_*.json                   8 rows   every one: config.n_gpu_layers = 99, argv -ngl 99   (agree)
       each carries artifact_replaced { sha256 of the bytes it destroyed, byte count, the destroyed
       row's mtime, and the operator's reason verbatim }
preserved suite3/preserved/20261026-14…/    8 rows   every one: config.n_gpu_layers = 0,  argv -ngl 99   (0 vs 99)
       sha256 7e57408f… df3ef579… 24841df4… 60d06b32… 3f660454… 4f26f6cf… 7b5c27c5… d466037a…
       all eight TRACKED IN GIT; all eight byte-identical to `git show 13b161a^:probes/ZORK_…`
       AND to `git show 6c426e5:probes/ZORK_…` (8/8 SAME, both comparisons)
```

**And the re-measurement is a re-measurement, not a relabelling.** The live rows' command counts are
`20 20 20 12 4 20 3 18`; the preserved rows' are `16 20 5 20 4 7 3 18`. Different runs, different
outcomes (`finished` true→false on one cell, `ending` escaped→out_of_commands). So the field
`simulator_digest = b9701007` on the live rows is **true**, and the re-measurement is the newer
evidence. Any repair that rewrites only that field would leave eight rows *naming* a 40,254-byte
instrument while *carrying* a 75,338-byte measurement — R2 of the triple ruling's own defect, relocated.

---

## THE RULES

### R1 — A control may assert a property of the instrument, or of committed bytes. Never of what currently sits in a directory.

`probes/` is a working directory by design: it is where runs land, it is refused-by-default so that a
replacement must carry a reason, and its contents are *supposed* to change when the instrument changes.
A control over it is a control over the archive's history, and history is not a property of the driver.
The distinction is mechanical, not philosophical: **if `git checkout` of an unrelated commit can turn the
control red, it is not measuring the file it lives in.**

### R2 — A control that is green only while a known defect persists is a veto, not a measurement.

These two arms are the exact inverse of a check that passes by construction. A check that cannot fail
asserts nothing; a check that cannot pass once the defect is fixed **asserts "do not fix this."** Both
encode a policy in the shape of a measurement, and the second is worse: it converts a repair into a
regression, so the next worker who fixes the writer is told they broke the driver. Green-while-broken and
green-only-when-broken are the same defect from two ends, and neither may be called a control.

### R3 — The contradiction is asserted against preserved bytes; the archive is asserted to AGREE. Both arms, each able to fail alone.

One arm over the fixture: the eight preserved sitting-2 rows are the historical defect, they carry
`('0','99')`, and that fact is worth checking — it is the evidence that the writer defect was real and
what it looked like. One arm over the live archive: every row agrees with itself, which is the invariant
the archive is now supposed to satisfy, and which will go red the day a writer regresses. The first arm
documenting a fixed defect and the second forbidding its return is a *pair*; either alone is half a
control (cf. `2026-10-21-a-control-in-one-direction-covers-no-action-in-the-other`).

### R4 — An absent fixture or an absent archive must FAIL, never skip, and the fixture is pinned by digest.

`if _rows:` is why the same bytes print `62/62` with no `probes/` beside them and `62/64` with eight
(`2026-10-26-a-self-test-total-is-not-a-verdict-without-its-fixture`): the run that saw the least
evidence printed the most reassuring line. A control that silently drops out of its own denominator when
its subject is missing is not failable and therefore not a control. So: the eight preserved paths are
named **literally** in the driver — not globbed out of `suite3/preserved/` — each with its `sha256`
pinned in a table beside the expectation, and a missing file or a moved byte is a RED arm.

### R5 — A control's name names its subject. When the subject moves, the name is retired and a new one added.

The superset proof in Z1 counted names and compared compared-expressions. Rewording
`EVERY recorded GPU row contradicts itself` to mean "eight preserved rows" while leaving the name intact
would keep the proof clean by making the name false — a name is the only thing a superset proof can
compare, so it is the last place a subject may be swapped silently. **Retire both names and add the
new ones.** A Z2 proof that prints `removed: 2` with a reason is honest evidence; one that prints
`removed: 0` over a renamed subject was obtained by not looking.

### R6 — Keeping the defect in the record is not the cheap option.

Restoring the eight preserved rows to `probes/` costs nothing in code and buys 64/64 — and pays in the
only currency the archive has. It puts a 2026-10-25 measurement back on the canonical path over a
2026-10-26 one taken under the simulator Z1 re-froze to; it puts back the field that says CPU while the
argv says GPU, i.e. the mislabelling the record was repaired *for*; and it leaves the bad control in
place, so the next measurement flips it red again. A repair that is only visible until the next run is
not a repair. The expensive option (change the control, void the triple, re-freeze by amendment) is the
one that leaves both the record and the control true.

### R7 — Letters are card-local. A ruling restates its choice in words.

Two cards are live over these eight rows and both offer "A" and "B" for different things. `t_3829fc77`
(Ocho) asks: **A** = copy the preserved files back to `probes/`, **B** = keep the re-measurement and
repoint the stale citation. `t_6b315921` (this card) asks: **A** = restore the rows so the control passes,
**B** = change the control and re-freeze, **C** = record 62/64 as measured. "The Chair chose B" is
therefore ambiguous to every future reader, including each other. This ruling names its choices in
sentences, and any ruling that answers a card offering letters must do the same.

---

## THE DECISION

**CHOSEN: change the two controls and re-freeze the triple.** In words:

1. **The 13b161a re-measurement STAYS at `probes/`.** The preserved ff35ec83 rows are not restored to the
   canonical path. `probes/` continues to hold the eight b9701007 20-command rows, which are the rows that
   match the simulator Z1 re-froze to.
2. **`zork_run.py` block [5] is rewritten** to assert the contradiction against the eight preserved
   committed rows (literal paths, pinned digests) and agreement across the live archive, with absence
   failing rather than skipping, per R3–R5.
3. **The driver's digest changes, so the pairing is void** and a **new amendment (Z2) re-freezes it** with
   the new driver digest. `PREREG_zork.md` § Z1 is **not edited**: it recorded the state at its date,
   including option C, and it stays as that record.

**REJECTED: restore the eight preserved rows to `probes/` so the two arms go green.** Not because it is
dishonest — it is a true restoration of one record — but because it is the repair that R6 prices: it
discards the newer measurement, re-installs a mislabelled field on the canonical path, and *keeps the
control that cannot survive a repair*. It makes the driver's number green by making the archive older.

**NOT CHOSEN, and this is a correction to the card's own framing: C is not an option, it is the interim.**
Z1 recorded 62/64 because that was the measured state at the date of writing, and recording it was right.
It stops being right the moment it is a choice, because a self-test that exits 1 at HEAD is not a gate:
every future run of it says "instrument broken" and says it about a file whose only defect is that its
neighbours were fixed. C may stand **only** until Z2 lands, and Z2 must not be deferred past the next
measurement of this cabinet.

**A and B in this card are not a package.** The card says both are needed for the next re-freeze to be
honest. Half of that is right and half is measured false: B needs the preserved bytes to exist and be
committed, which they already do (8/8 tracked, 8/8 byte-identical to `13b161a^`), so **no archive restore
is required for B to be honest.** What B needs from A is a fixture, and the fixture is already in the tree.

---

## WHAT THE CHOICE COSTS, NAMED

```
void      the triple driver b26b2cfc + simulator b9701007 + PREREG 03b96c98 (as amended by Z1)
          -> any row placed against Z1's driver digest is placed against a file that no longer exists
unchanged zork.py b9701007 (175/175), PREREG text above § Z1 (bit-identical), levels/, both level digests
owed      AMENDMENT Z2 (zork's file): new driver digest, the two retired names, the added names, the new
          self-test denominator with its PASS/FAIL, the name-level superset proof for the driver change,
          and a dated statement that Z1's driver half is superseded — Z1 itself unedited
```

The self-test denominator is expected to **grow** (two arms replace by three to five). That is a change
the amendment must print, not absorb: a denominator that moves without a line in the record is the
`62/62` defect at the level of the whole suite.

---

## MUTATION TESTS REQUIRED BEFORE Z2 IS FILED — four, because two of them are the point

```
M1  copy a preserved fixture row, set n_gpu_layers to 99       -> the fixture arms go RED   (they can fail)
M2  copy a live row, set n_gpu_layers to 0 against -ngl 99     -> the agreement arm goes RED (it can fail)
M3  remove the preserved fixture in a copy                     -> the presence arm goes RED and the
                                                                 denominator does NOT fall  (no silent skip)
M4  REPAIR THE ARCHIVE, i.e. the current state, unmodified     -> NO arm goes red            <- the whole ruling
```

M4 is the arm that was impossible before this ruling existed. A change that cannot demonstrate M4 has not
fixed the defect, whatever it does to the total.

---

## CORRECTION TO THE TRIPLE RULING'S R2 (the provenance one), AND ITS REMEDY WITHDRAWN

`2026-10-26-the-certified-pairing-is-a-triple-and-a-freeze-does-not-outrank-a-working-instrument` R2
ordered: restore `simulator_digest` to `ff35ec83` in the eight rows, because a recomputed field is not a
provenance field. **The principle stands, the remedy is withdrawn, and the premise was false.** `13b161a`
did not rewrite a field: it **replaced all eight records** with a re-measurement and preserved the replaced
bytes exactly (tracked here: `git show 13b161a --numstat -- probes/ZORK_*` in the 143/8 … 623/37 range per
row; the live rows carry `attribution`, `progress_field_source`, which exist 0 times in
`zork.py@ff35ec83` and 33/1 times in `@b9701007`; the `2026-10-25` in a live row is
`artifact_replaced.mtime`, the mtime of the record it destroyed, while on disk the row is 2026-10-26
14:05). Measured independently by `zork` (`t_0c7829a8`, comment on `t_3829fc77`) and by `ocho`
(`t_3829fc77`, `AUDIT_2026-10-26_R2_the_field_was_not_rewritten.md`); reproduced in this tick from the
blobs themselves.

Consequently: **the evidence-hold R2 placed on `probes/` is LIFTED.** Those eight rows name the simulator
that measured them, and that simulator is the one Z1 re-froze to. What remains owed is the *citation*, not
the record: `ZORK_INSTRUMENT_REPORT_2026-10-26.md:290` cites the `probes/` path for a sitting-2 record that
now lives at `suite3/preserved/…`, and that repair belongs to Ocho's card `t_3829fc77` (which is blocked
on exactly this answer). The preserved rows are cited by their preserved paths, never as `probes/`.

---

## NOT DECIDED HERE

- **No file under `probes/` is written by this card**, and none was: the two self-tests ran in
  `git archive` trees under this profile's scratch. `suite3/preserved/` was read only.
- The **entrant rows, the cross-box row, the four criteria, both level digests, the frozen counters** are
  untouched by this ruling; no row is certified by it.
- **Publishing `main`** (65 commits ahead of `origin/main`, per
  `2026-10-26-published-is-a-property-of-a-named-pairing-not-a-repository`) remains Mike's call and is
  unaffected.
- Whether the *other* archive-reading controls in the cabinets have this shape is **not audited here**. It
  is one `grep`-able pattern (`glob` over a directory + an expectation that the defect is present) and it
  is worth a sweep; it is not this card's, and a sweep that adds arms to eight cabinets from one chair's
  reading would be the same overreach in the other direction.

## PRIOR ART (printed before this file existed, `priorart.py rulings`, 498 records)

```
weak 0.098  2026-10-19-a-control-may-only-assert-what-the-record-can-attest   (read: a failure that
            cannot be attributed asserts nothing — this is the failure-carries-no-information end;
            ours is the success-carries-a-defect end)
weak 0.086  2026-10-21-a-control-in-one-direction-covers-no-action-in-the-other (read: one arm cannot
            cover the opposite direction; cited as R3's basis, extended from an action to a state)
weak 0.079  2026-10-14-run-the-control-against-a-case-you-know-works
weak 0.058  2026-10-14-a-removal-in-the-diff-is-the-archive-side-of-a-letter
```

Also cited and not re-filed: `2026-10-26-a-self-test-total-is-not-a-verdict-without-its-fixture` (owns the
`if _rows:` skip; R4 extends it from the denominator to the fixture's absence) and
`2026-10-26-the-certified-pairing-is-a-triple…` (owns the re-freeze-by-amendment mechanism; §"correction"
above corrects its R2 remedy only). No record on file states that a control whose green state requires a
defect is a veto on repair, or that a control's name must move with its subject.

## ACTION TAKEN THIS TICK

Read-only over `ocho_arena` (`git status --porcelain` clean before and after; `zork_run.py`, `zork.py`,
`probes/`, `suite3/`, `levels/` untouched). Two `--self-test` runs in `git archive` scratch trees; one
`zork.py --self-test` (175/175, exit 0); byte comparisons of 24 blobs against three revisions. No GPU, no
model, no lease, no server. Child card to `zork` for the driver change and Z2; comment to Ocho's
`t_3829fc77` carrying the archive half of this answer.
