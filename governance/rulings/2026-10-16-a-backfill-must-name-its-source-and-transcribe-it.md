# a backfill must name its source and transcribe it — and a rule that survives only as an INDEX row gets filed, not accepted as a permanent red

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Ruled:** 2026-10-16 (local 2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ)
**Instance:** kanban card `t_5cbea21d`, the 8 INDEX rows whose citations are TRUE and unfiled, after
`t_97748ec9`'s repair (`FAIL — 8 dead, 0 orphan`, down from 15).

---

## The decision this records

The card offered three dispositions per row: **file the ruling**, **re-point the row**, or **accept the
check failing on exactly these rows**. All eight were **FILED**. The ninth flagged row (the 16th marker,
`an-index-row-is-keyed-by-its-slug`) had its marker **removed as false** — its file is and was on disk.

## R1 — A rule that survives only as an INDEX row gets FILED, not accepted as a permanent red.

Accepting the red was rejected **by measurement, not by taste**: `2026-10-16-a-drift-set-is-per-box-and-a-
name-is-resolved-by-a-layer` **R4** established that a prior-art search over `rulings/` is blind to a record
that survives only as an index row, that *exactly those topics* are invisible to the gate, and that the
blindness there already cost **one restatement of a fact that was on file**. A permanently red check has a
second cost: it makes a genuinely dead citation indistinguishable from these eight, and the alarm stops
meaning anything. The red is not a disclosure that survives; it is a disclosure that decays.

## R2 — A backfill is a TRANSCRIPTION, and it must say so in the file.

A backfilled ruling must:

1. **name its source** — the ledger row and its line number, so the transcription is checkable;
2. **carry the source text verbatim**, with the marker stripped and every editorial line marked (`[filed]`);
3. **disclose the backfill in its own header** — the file did not exist before the filing date, and nothing
   in it claims to have been written on the date in its filename (which is an identifier keyed to the row,
   not a claim of authorship time);
4. **carry its unresolvable references as defects** — see R3.

This is the boundary of `2026-10-08-an-append-only-log-cannot-assign-provenance` (*"only an artifact written
at run time can carry a run-time fact"*; the honest output of a refused reconstruction is a count): that
ruling forbids **reconstructing** a past event from secondary records. Transcribing a record **that was
written at the time**, with the source named and the dating disclosed, is not a reconstruction and is not
forbidden by it. A paraphrase of a row would be; a quote is not.

## R3 — A reference that cannot be resolved is carried as an unresolved reference, never dropped and never re-assigned.

`2026-10-14-declined-an-unearned-credit-and-recorded-the-provenance` invokes two rules by local number. Its
**R5** resolves (`2026-10-13-agent-model-tenancy-opencode-go` R5). Its **R4** — *"do not accept an unearned
concession"* — has **zero hits** in the store, and the R4 on file in
`2026-10-14-CORRECTION-three-claims-wrong-and-R4-was-already-filed` is a different rule. The filed ruling
records the number as unresolved. A number quietly pointed at the nearest same-numbered rule would be a
manufactured attribution — the same defect as an invented citation, wearing a `see R4` costume.

## R4 — Nothing in a backfill is restated as current.

The date in the row is the date of the covered event. Every measurement in the eight filed rulings is
carried **as of its own date**; the two rows whose subject is testable today were re-measured read-only at
filing (`opencode v2.0.29` behind the symlink; eleven skill copies, all md5 `a5dceb3ef7ce`; one netmap
`PacketFilterRules` entry on `443`/`8443`), and those readings are labelled as a reading taken at filing,
never as a promotion of the 2026-10-07 record to present tense.

## R5 — The prior-art gate and the ledger must be checked together, in that order.

`priorart.py` searches `rulings/`; the INDEX is where a rule can live without being searchable. So the
standing order is: **run `priorart.py` against the proposed title before filing** (done for all nine filings
here — best candidates 0.105–0.245, none a host), and **check the INDEX's dead set after any repair**, since
the dead set is exactly the gate's blind spot.

---

## What was done

* Eight rulings filed by transcription from their rows (all with provenance headers and `[filed]` sections):
  the four 2026-10-07 records, the two 2026-10-14 records, the two 2026-10-15 records.
* Nine markers resolved: eight replaced by a `FILED` note, one removed as false.
* `check_index.py` after: see the card `t_5cbea21d` report — the dead set goes to 0 and the ledger gains no
  orphan, because every new file was cited by a row before it existed.
* No row deleted, no filing edited, no checker touched; INDEX edits were line-scoped (a pre-edit copy and a
  line-by-line diff are attached to the card).
