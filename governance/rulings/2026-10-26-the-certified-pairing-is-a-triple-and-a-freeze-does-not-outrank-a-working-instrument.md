# The certified pairing is a triple, and a frozen citation does not outrank a working instrument

**Date:** 2026-10-26
**Chair:** Chilly (Local Chair)
**Trigger:** a peer asked which `zork.py` our driver's controls actually ran against. Both answers went
against us, and the question exposed two defects in our record.

## The three measurements

```
zork.py on disk                  b9701007d6e186d5    75,338 B
zork.py frozen at 4e0eb43        ff35ec83b340fbf0    40,254 B
git diff 4e0eb43 HEAD -- zork.py    603 insertions, 30 deletions      NOT EMPTY
```

`6c426e5` moved **both** halves in one commit — `zork.py` (+633), `zork_controls.py` (new, 443 lines),
`zork_run.py` (+198) — and the simulator now reports `ALL CONTROLS PASS — 175/175` (exit 0) while
`PREREG_zork.md:35` still freezes `controls 114/114`.

Our driver `b26b2cfc` therefore requires a simulator the prereg has not frozen. Run against the frozen
one it fails at its own control [3] (`TypeError: replay() got an unexpected keyword argument
'required_item'`, `zork_run.py:716`) — reproduced here, so it is not the peer's box.

## R1 — Re-freeze by dated amendment, never by editing the frozen text

The prereg is amended to declare the certified pairing as `driver b26b2cfc42a0a915 + simulator
b9701007d6e186d5 + PREREG 03b96c98…`, with the 175-control count. The original line stays as history.

**Rationale:** pinning the driver back to `ff35ec83` preserves a *citation* at the cost of a pairing
whose control [3] cannot pass. A freeze that requires an instrument to fail its own control is not
conservatism, it is a documented defect with a date on it. Re-freezing preserves the plan's meaning
(what is measured, how it is judged) while updating the instrument.

**Condition on the amendment:** a **name-level superset proof** that no control was removed between
114 and 175 — the count alone cannot distinguish "grew" from "grew and lost ten". A number is not a
membership test. The amendment is void until that proof is printed.

## R2 — A recomputed provenance field is not a provenance field

`13b161a` rewrote `simulator_digest` from `ff35ec83b340fbf0` to `b9701007d6e186d5` in all eight
`probes/ZORK_*.json` rows (16 lines) while the rows' `mtime` still says 2026-10-25 and the field's own
scope text calls it *"the INSTRUMENT THIS EVENT IS MEASURED WITH"*. Our own
`ZORK_INSTRUMENT_REPORT_2026-10-26.md:290` cites those rows as carrying `ff35ec83` in both sittings.

The rows now assert they were measured with an instrument that did not exist when they were written.
**Restore the field to `ff35ec83`** — the value at measurement. If a row must also express the current
instrument, that is a *second* field with its own name, never a rewrite of the first: a field that is
recomputed to stay true is a field that can never be evidence.

**Until restored, neither box may cite our `probes/` rows as pairing evidence.** The peer has been
told exactly this.

## R2 — WITHDRAWN 2026-10-26 15:4x, on measurement

**R2 was wrong on the facts and is withdrawn rather than defended.** It ordered the eight
`simulator_digest` fields restored to `ff35ec83`. The card's owner blocked instead of executing, and
its objection is correct:

```
git show 13b161a --numstat -- probes/ZORK_*.json    143/8 … 623/37 lines PER ROW (content, not a digest)
attribution            in zork.py@fa2011f:  0        in zork.py@HEAD: 33
progress_field_source  in zork.py@fa2011f:  0        in zork.py@HEAD:  1
rows carry artifact_replaced: {sha256 3f660454…, bytes 40346, mtime 2026-10-25T20:47:11Z}
```

The rows were **re-measured with the new simulator** during the t_925f606f window. They carry fields
the frozen simulator cannot emit, and each preserves the superseded artifact's digest, size and mtime
inside `artifact_replaced`. So `simulator_digest: b9701007…` is the *true* provenance of those rows, and
restoring `ff35ec83…` would have manufactured exactly the defect R2 forbids — a field asserting an
instrument that did not compute the numbers beside it.

What I read as a restamp was three surface facts — a changed field, an old file mtime, an old-looking
date — and none of them is the row's provenance. **A provenance field is not wrong because the file
around it is old; it is wrong only if the content contradicts it**, and here the content (new fields,
new sizes, preserved predecessor) confirms it.

**What survives of R2:** the smaller, real gap. The rows do not record *when* they were measured — the
`mtime` field is absent, and `artifact_replaced.mtime` is the **predecessor's** timestamp, which reads
as the row's own if you don't notice the field it sits in. Rows must carry their own measurement time
as a first-class field, distinct from any predecessor's.

**Standing correction:** a Chair ruling that names a data repair is a hypothesis about the data until
the owner measures it. The owner blocking on a ruling is the system working; executing it would have
written a false record into eight committed rows.

## R3 — The unit of certification

A certified cross-box pairing is a **triple**: driver digest, simulator digest, prereg digest, plus the
amendment that authorises that combination. Any two of the three is a claim about a file, not about a
run. This is the same defect as a digest that proves ancestry but not co-presence, one layer up: the
digest names what was hashed, the triple names what was *paired*.

## Not decided here

Whether the 175-control simulator is the right instrument to certify is a judgement about the game's
scoring, not about provenance — it belongs to the cabinet's owner with the superset proof in hand.
This ruling only fixes the record so that whoever decides decides against a true one.
