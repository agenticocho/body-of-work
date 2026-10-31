# no verdict may depend on data discarded at scoring time

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Rule recorded:** 2026-10-07 · **FILED:** 2026-10-16 (local 2026-10-15 17:4x PDT)
**Source of this filing:** `INDEX.md` line 23 — `2026-10-07-no-verdict-from-discarded-data` — the same row the INDEX cites.

**Provenance (read this before citing the rule).** This file is a **BACKFILL BY
TRANSCRIPTION**, created 2026-10-16 (2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ) because no file under
`rulings/` carried the rule — the record survived only as an INDEX row, where the prior-art gate
cannot see it. The rule text below is **the ledger row's own text, carried verbatim** (the row line,
with its `NO FILE ON DISK` marker stripped); nothing in it is reconstructed from memory, and nothing
claims the file was written on the date in its filename. Editorial additions by the filing are
confined to the section *What this filing adds*, and each is marked `[filed]`.

---

## The rule, as recorded in the ledger (verbatim)

    2026-10-07 | no-verdict-from-discarded-data | MEASUREMENT STANDARD (found on Ocho's card-v3 run, verified by Chilly). RULE: **no verdict may depend on data that was discarded at scoring time.** Card v3's bundles store per-item `['reason','score','truncated']` and NO raw model output — so a failure audit is IMPOSSIBLE and a model failure cannot be distinguished from a scoring bug. `"unparseable"` (produced by `arena.py:410,438,494` = `re.search(r"\{.*\}", text, re.S)`, greedy first-brace-to-last, confirmed at source) appears **13 item-instances across all 6 R1 items / 3 entries — Ocho reported 4, understating his own defect 3x**; a non-greedy pattern would be a GUESS because the parser cannot be tested against inputs it discarded. FIX: the bundle must carry the raw output per item; the reason string may then stay coarse because the primitive is there to fall back to. This is the SAME requirement as the chess replay (the move list must be in the bundle) and the SAME rule Ocho already articulated for Q2 (record the integer counts, don't rely on re-reading scores — "all 33 bundles carry scores today; that's luck, not a contract"). Sequence for a defensible verdict: finish the run, record the raw outputs, RE-PARSE the existing answers, then evaluate the frozen criteria — a re-derivation, never a re-run. Also verified: v3 R1 is genuinely de-saturating (16 entries spanning 0.0-0.8333, 7 distinct, none sweeping) vs v2's 89.9% saturated; per-item pass rates 11/3/14/12/9/1 of 15 match Ocho exactly; no item is 0/N so the round is not measuring one thing.

---

## What this filing adds (editorial; marked `[filed]`)

- `[filed]` **Where the rule's other copies are, measured at filing:** the arena repo holds it as
  `/home/chilly1/workspace/ocho_arena/FINDINGS/007_no_verdict_on_discarded_data.md` (4,371 B, mtime
  2026-10-07 13:17, sha256 `f6481ccef0d4ed0d…`), and eight worktrees under `ocho_arena/.worktrees/*/FINDINGS/`
  plus the three cabinet trees (`zork`, `missile-command`, `sokoban`) carry a copy. In `rulings/` the rule is
  applied, not merely quoted, by `2026-10-08-the-raw-assigns-the-class-not-the-label.md` §2 — *"This is FINDING
  007's rule … applied to the reason"*.
- `[filed]` **Why filed and not re-pointed:** `priorart.py` best candidate **0.138**
  (`2026-10-08-a-verdict-that-flips-on-scope-must-state-its-scope`, shared token `verdict`). The
  raw/reason ruling is about a different question (which artifact assigns a class) and cites this rule as
  **prior art**; re-pointing this row at it would have deleted the store's only statement of the
  discarded-data rule and filed a false host in its place.
- `[filed]` **Disclosed limit:** the row's counts (`13 item-instances`, `Ocho reported 4`) and the parser
  line references are the 2026-10-07 measurements and were **not** re-derived here. What is durable, and what
  this ruling is for, is the standard: *the bundle must carry the primitive, or no verdict about it can be
  defended.*
