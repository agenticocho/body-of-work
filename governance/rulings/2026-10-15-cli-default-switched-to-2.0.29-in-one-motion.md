# the CLI default moved to 2.0.29 in one motion

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Rule recorded:** 2026-10-15 · **FILED:** 2026-10-16 (local 2026-10-15 17:4x PDT)
**Source of this filing:** `INDEX.md` line 227 — `2026-10-15-cli-default-switched-to-2.0.29-in-one-motion` — the same row the INDEX cites.

**Provenance (read this before citing the rule).** This file is a **BACKFILL BY
TRANSCRIPTION**, created 2026-10-16 (2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ) because no file under
`rulings/` carried the rule — the record survived only as an INDEX row, where the prior-art gate
cannot see it. The rule text below is **the ledger row's own text, carried verbatim** (the row line,
with its `NO FILE ON DISK` marker stripped); nothing in it is reconstructed from memory, and nothing
claims the file was written on the date in its filename. Editorial additions by the filing are
confined to the section *What this filing adds*, and each is marked `[filed]`.

---

## The rule, as recorded in the ledger (verbatim)

    2026-10-15 | cli-default-switched-to-2.0.29-in-one-motion | Mike approved. DONE and verified: ~/.local/bin/opencode -> ~/.local/share/oc-2.0.29/bin/opencode, PATH precedence ~/.local/bin at index 1 vs /snap/bin at 27, so the default moved with a single symlink. command -v opencode = /home/chilly1/.local/bin/opencode, --version = opencode v2.0.29. The snap 1.19.0 rev 267 STAYS INSTALLED but shadowed and unreachable by name -- sudo -n is denied so it cannot be removed without Mikes password; recorded as dormant rather than removed. THE TOOLCHAIN DID NOT MOVE UNDERNEATH THE DAY ARTIFACTS: check_frontend_clauses.py rc=1 FAILED -- 85 failure(s) C1 14 / C2 25 / C3 42 / C4 4, --selftest rc=0 controls caught 5/5, trunk a608b5f -- identical to before the switch. Free tier works from the new default: `opencode run --model opencode/longcat-2.5-preview-free` -> SWITCH-OK. Catalogue now 11 ids / 10 free, matching Jarvis count. ALSO A REAL GATE PROPERTY, found by my own script failing: the gate exits NON-ZERO ON THE RECORD BY DESIGN, so any caller using `set -e` DIES at it -- my verification script aborted at the gate step for exactly that reason. A checker that reports through its exit status must be called by something that tolerates a non-zero status; the gate is correct and `set -e` around it is the defect.

---

## What this filing adds (editorial; marked `[filed]`)

- `[filed]` **Re-measured read-only at filing (2026-10-15 17:37 PDT), reproducing the row:**
  `~/.local/bin/opencode` is a symlink → `/home/chilly1/.local/share/oc-2.0.29/bin/opencode`, and
  `opencode --version` → `opencode v2.0.29`. The record is therefore checkable today and not merely true when
  written.
- `[filed]` **Why this row in particular:** `rulings/2026-10-16-a-drift-set-is-per-box-and-a-name-is-resolved-by-
  a-layer.md` **R4** names *this row* and its sibling (the ELEVEN-copies row) as prior records its prior-art
  sweep could not see **because their files were absent** — and states that the blindness there cost one
  restatement of a fact already on record. Filing is the remedy R4's own argument implies: a rule that survives
  only as an index row is invisible to the gate; a file is what the gate can see.
- `[filed]` **One figure of record this row carries:** the catalogue read `11 ids / 10 free`. The drift ruling
  used exactly this row's figure to catch a wrong count in a letter already sent and adopted *"publish the LIST,
  never the count."* That a **dead** row was still the correct source is the sharpest argument in this batch
  against accepting the red as merely cosmetic.
- `[filed]` **Disclosed limit:** the gate's failure counts (`85 failures C1 14 / C2 25 / C3 42 / C4 4`,
  `--selftest rc=0`, trunk `a608b5f`) are 2026-10-15 readings before the switch and are not re-derived here;
  the durable rule is the exit-status property: *a checker that reports through its exit status must be called
  by something that tolerates a non-zero status; the gate is correct and `set -e` around it is the defect.*
