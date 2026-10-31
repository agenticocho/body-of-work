# A self-test total is not a verdict — `62/62` is the count of controls that could run

**Date:** 2026-10-26
**Instrument:** `/home/chilly1/workspace/ocho_arena/zork_run.py --self-test`
**Digest under test:** `b26b2cfc42a0a91520e9e3b9753ad3871b8d79657628e986186c5f3de9948d19` (81,096 B)
**Prereg:** `PREREG_zork.md` = `03b96c98bd39733b8ef64ec22e701efa3a330ad068b49c3efa9a57333f35a710` (13,623 B)

## Ruling

The same bytes report two different totals. Neither is wrong arithmetic; only one is a verdict.

| beside the **script copy** | denominator | verdict | exit |
|---|---|---|---|
| `probes/ZORK_*.json` present (repo root) | 64 | `2 FAILED   --  62/64` | 1 |
| no `probes/` beside the script | 62 | `ALL CONTROLS PASS   --  62/62` | 0 |

The two missing checks are the GPU-row arms at `zork_run.py:1154-1166`, both guarded by `if _rows:`
on a glob of `os.path.join(HERE, "probes", "ZORK_*.json")`. With no rows the guard is false, the arms
are never counted, the denominator drops 64 -> 62, and the run that saw the least evidence prints the
most reassuring line. Measured this tick, both arms, same digest:

```
2 FAILED   --  62/64            (repo root, exit 1)
ALL CONTROLS PASS   --  62/62   (script copy in a directory without probes/, exit 0)
```

## The axis is the script's own directory, not the working directory

`HERE = os.path.dirname(os.path.abspath(__file__))` (`zork_run.py:50`), so cwd cannot move the total.
Measured: the same absolute script path invoked from `/home/chilly1/workspace/ocho_arena` and from
`~/.hermes/profiles/chilly/cache/scratch` produced byte-identical output (`2 FAILED   --  62/64`, exit
1 from both, diff empty). What changes the total is whether `probes/` sits beside the COPY BEING
EXECUTED. A re-check that `cd`s to the repo root and runs a copy somewhere else proves nothing; the
copy's own directory has to carry the fixture.

## The general rule

> A test total is evidence only with its denominator AND its fixture. A passing self-test that skipped
> a fixture is an absent control, and the skipped count is the finding.

Same shape as `bad-check-manufactures-findings` one level up: there the check's failure did not stop the
write; here the check's absence does not stop the PASS.

## What does not change

The pre-registration gate is certifiable: with `PREREG_zork.md` beside the driver the declared arm is
accepted, without it the driver refuses with `DOES NOT EXIST in this tree` (`zork_run.py:1042-1045`,
asserted in the same self-test). No measured result moves — this is instrument accounting, not a
finding. Until the driver refuses when its fixture is absent and asserts the invariant against a
*shipped* fixture, no self-test total from it may be quoted; the honest report is the arm plus the row
count the glob found, and `62/62` means it found none.
