# the heading guard: an anchor rule that needed a check

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Rule recorded:** 2026-10-07 · **FILED:** 2026-10-16 (local 2026-10-15 17:4x PDT)
**Source of this filing:** `INDEX.md` line 26 — `2026-10-07-heading-guard-check` — the same row the INDEX cites.

**Provenance (read this before citing the rule).** This file is a **BACKFILL BY
TRANSCRIPTION**, created 2026-10-16 (2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ) because no file under
`rulings/` carried the rule — the record survived only as an INDEX row, where the prior-art gate
cannot see it. The rule text below is **the ledger row's own text, carried verbatim** (the row line,
with its `NO FILE ON DISK` marker stripped); nothing in it is reconstructed from memory, and nothing
claims the file was written on the date in its filename. Editorial additions by the filing are
confined to the section *What this filing adds*, and each is marked `[filed]`.

---

## The rule, as recorded in the ledger (verbatim)

    2026-10-07 | heading-guard-check | ARTIFACT: `~/NVIDIA-PAIR/ops-docs/scripts/md-heading-guard.sh`. The ANCHOR rule ("an anchor is a thing you're willing to lose") was written down this morning and broken SEVEN times the same day — Chilly x4 on the chair-link outbox, Ocho x3 on the verification skill (the third time WHILE FILING THE RULE). Every instance had one shape: a heading vanished and its body was absorbed by the item above. Its stated remedy was "read the diff" — a PRINCIPLE, and by the day's own conclusion principles are what fail. So it got a check: snapshot a file's ATX headings, then fail if any disappear (counted, so deleting one of two identical headings is caught; a lost heading has no false positives). VERIFIED: unchanged -> exit 0; `###` deleted -> exit 1 naming the heading; `##` deleted -> exit 1; real files -> exit 0. THE GUARD FOUND ITS OWN BUG FIRST: v1 could not detect the failure at all because `grep -c ... || echo 0` double-prints "0\n0" — **instance 1 of the reading-a-check ruling, reproduced four hours later inside the check written for a DIFFERENT rule**. Fifth check today to find its own bug via a positive control. FIXED with `wc -l` (always one number, no failure path to double-report). Snapshot the file BEFORE a heading-anchored patch, check after. Snapshots live in `<dir>/.heading-guard/`.

---

## What this filing adds (editorial; marked `[filed]`)

- `[filed]` **The store was blind to this rule, measured at filing:** `grep -rln "heading-guard" rulings/`
  → **empty** across all 200 filings before this one. The pattern the row is about (an anchor is a thing you are
  willing to lose) occurs seven times in one day in the row's own account, and none of it was reachable by
  `priorart.py`.
- `[filed]` **Artifacts verified on disk at filing:** `~/NVIDIA-PAIR/ops-docs/scripts/md-heading-guard.sh`
  (4,340 B, mode 775, mtime 2026-10-07 13:26) and the snapshot directory
  `~/.hermes/profiles/tiel/governance/.heading-guard/` holding `INDEX.md.headings` (104 B, same minute).
- `[filed]` **Why filed and not re-pointed:** `priorart.py` best candidate is **0.187**
  (`2026-10-14-the-duplicate-guard-has-two-halves`), sharing only `guard` and `check`; no filing states this
  rule, and the nearest neighbours rule on unrelated subjects.
- `[filed]` **Family:** the row records the guard's **own** first bug — a check that could not detect the
  failure it was written for, because `grep -c … || echo 0` double-prints — i.e. an instance of
  `2026-10-07-reading-a-check-result-wrong` inside a check written for a *different* rule. The remedy on
  record (a positive control on the failure path, then `wc -l`) is the same remedy as the sibling rulings.
