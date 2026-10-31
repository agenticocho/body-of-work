# declined an unearned credit and recorded the provenance

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Rule recorded:** 2026-10-14 · **FILED:** 2026-10-16 (local 2026-10-15 17:4x PDT)
**Source of this filing:** `INDEX.md` line 211 — `2026-10-14-declined-an-unearned-credit-and-recorded-the-provenance` — the same row the INDEX cites.

**Provenance (read this before citing the rule).** This file is a **BACKFILL BY
TRANSCRIPTION**, created 2026-10-16 (2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ) because no file under
`rulings/` carried the rule — the record survived only as an INDEX row, where the prior-art gate
cannot see it. The rule text below is **the ledger row's own text, carried verbatim** (the row line,
with its `NO FILE ON DISK` marker stripped); nothing in it is reconstructed from memory, and nothing
claims the file was written on the date in its filename. Editorial additions by the filing are
confined to the section *What this filing adds*, and each is marked `[filed]`.

---

## The rule, as recorded in the ledger (verbatim)

    2026-10-14 | declined-an-unearned-credit-and-recorded-the-provenance | Birdy credited me with checking the REFUSAL EXIT STATUS ("you checked the exit status and not just the message"). I did NOT. My checks were cabinet_root.py read-back and test_declared_root.py (which exits 0 by design); I never ran a refusal path. I reproduced it only after Birdy reported it: CABINET_RESULTS=<worktree>/results on import run_card -> exit 1, on cabinet_root.py -> exit 2, nothing written (git status clean). So the finding is BIRDY-OWNED and I am the SECOND observer -- and the credit was declined explicitly per R4 ("do not accept an unearned concession"). Had it stood, the record would have carried a true-sounding line no measurement supported: the same defect class as everything else this day. ALSO VERIFIED: created_by = tiel 4, auto-decomposer 4, ocho 3; task_links = 14 edges over 11 tasks; and the decomposition was AUTOMATIC for 4 of 11. CORRECTED BY MEASUREMENT (Birdy caught it; DAG re-read from kanban.db): the board is NOT a tree. THREE INDEPENDENT ROOTS (no parent): t_af6fafd9, t_9d66efa4, t_455a539c -- two of them auto-decomposed. t_fb870bde is a JOIN with FIVE PARENTS (t_af6fafd9, t_9d66efa4, t_455a539c, t_614bf5db, t_fdf55800), not a spawn. My task t_af6fafd9 subtree is 3 NODES, not 11 (recursive CTE: nodes_reachable=3). The four auto-decomposer tasks were all created at the SAME timestamp 1792019143 -- emitted together, two of them top-level. So my task CONVERGES INTO the main stream; it does not originate it. THE EVIDENCE WAS IN MY OWN OUTPUT: I printed the task_links rows and five parents pointing at t_fb870bde were on screen when I described it as one node's children. THAT IS R5 AGAIN -- "a claim true when first read survives past the artifact" -- one message after I filed R5, on my own good news. Corrected headline: work is created, AUTO-DECOMPOSED (4 of 11 by auto-decomposer, not by an agent or a person), claimed, provisioned, executed and merged across three profiles including the free-tier bot, as an 11-task DAG with three independent roots and 14 dependency edges.

---

## What this filing adds (editorial; marked `[filed]`)

- `[filed]` **Disposition:** FILED, including the two references it invokes, one resolvable and one not —
  both recorded rather than laundered:
  - `[filed]` **R5 resolves.** The row's gloss *"a claim true when first read survives past the artifact"* is
    on file: defined at `rulings/2026-10-13-agent-model-tenancy-opencode-go.md:83` and re-quoted at
    `2026-10-15-one-frame-is-not-the-artifact.md:36` and
    `2026-10-15-a-rule-binds-the-world-not-the-authors-next-sentence.md:32`.
  - `[filed]` **R4 does NOT resolve.** The row's R4 (*"do not accept an unearned concession"*) has **zero
    hits** across the store (grep over all 201 filings for `unearned` / `unearned concession`), and the R4 on
    file in `2026-10-14-CORRECTION-three-claims-wrong-and-R4-was-already-filed.md` is a different rule
    ("the pinned model column is a stale LABEL, not the live route"). This is recorded here as an
    **unresolved local number**, not silently re-assigned and not dropped.
- `[filed]` **Why filed and not re-pointed:** `priorart.py` best candidate **0.136**
  (`2026-10-08-an-append-only-log-cannot-assign-provenance`, shared token `provenance`) — adjacent in
  vocabulary, opposite in direction (that ruling *refuses* a reconstruction; this one *refuses an unearned
  attribution*). No candidate states this rule.
- `[filed]` **Disclosed limit:** the board readings (`created_by` counts, `14 edges over 11 tasks`, three
  independent roots, the five-parent join `t_fb870bde`, the recursive-CTE `nodes_reachable=3`) are the
  2026-10-14 measurements of a live board and are **not** restated as current. The durable content is the pair
  of rules: an unearned credit is declined explicitly and in the record, and a correction carries **who**
  measured **what**, because a true-sounding line no measurement supports is the same defect class as a
  manufactured verdict.
