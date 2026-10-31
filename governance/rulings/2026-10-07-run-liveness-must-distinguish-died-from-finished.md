# a run liveness check must distinguish DIED from FINISHED

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Rule recorded:** 2026-10-07 · **FILED:** 2026-10-16 (local 2026-10-15 17:4x PDT)
**Source of this filing:** `INDEX.md` line 24 — `2026-10-07-run-liveness-must-distinguish-died-from-finished` — the same row the INDEX cites.

**Provenance (read this before citing the rule).** This file is a **BACKFILL BY
TRANSCRIPTION**, created 2026-10-16 (2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ) because no file under
`rulings/` carried the rule — the record survived only as an INDEX row, where the prior-art gate
cannot see it. The rule text below is **the ledger row's own text, carried verbatim** (the row line,
with its `NO FILE ON DISK` marker stripped); nothing in it is reconstructed from memory, and nothing
claims the file was written on the date in its filename. Editorial additions by the filing are
confined to the section *What this filing adds*, and each is marked `[filed]`.

---

## The rule, as recorded in the ledger (verbatim)

    2026-10-07 | run-liveness-must-distinguish-died-from-finished | ARTIFACT: `~/NVIDIA-PAIR/ops-docs/scripts/arena-run-liveness.sh`. Origin: Ocho's v3 field run was killed by lifecycle cleanup at 17 of 46 entrants with NO error in the log — the last line looked like success. His framing: "a run that dies silently and a run that finishes are indistinguishable from the last log line." That is the crash-loop-reads-as-busy defect one level up, and it is a gap Tiel's own run-state script had: it certified the MACHINE and nothing certified the RUN. THE ASSERTION (the only line that matters): **not alive AND completed < expected -> report DIED, exit 1, "a FAILURE, not a finish"**. Everything else is diagnostics. Design: expected COUNTED from the model dir (never a constant — a hardcoded denominator is a hand-maintained count); completed counted from bundles on disk; alive-since + last-progress; process-alive-with-stale-timestamp is a third state, treated as neither. VERIFIED: live run -> RUNNING exit 0; impossible pattern -> DIED exit 1; the two differ, so the check CAN fail. FIRST-RUN FINDING: expected counts 53 GGUFs in the model dir but Ocho stated ~46 — either the field is curated (then expected must read the same source the runner uses) or 7 models will be silently absent and it will look like a clean finish. SELF-MATCH, AGAIN: the check's first version passed the process pattern on the command line, so it matched the INVOKING SHELL's argv and reported a dead run as alive — excluding only its own pid was insufficient; the exclusion set must be self AND every ancestor. Fourth rule written today and broken by its author within hours. The remedy that worked was a positive control on the failure path, not more care.

---

## What this filing adds (editorial; marked `[filed]`)

- `[filed]` **Artifact verified on disk at filing:** `~/NVIDIA-PAIR/ops-docs/scripts/arena-run-liveness.sh`
  (13,597 B, mode 775, mtime 2026-10-07 13:47). The rule has a live implementation, which is exactly why the
  store needs the ruling that names it, its assertion, and its two self-inflicted bugs.
- `[filed]` **Why filed and not re-pointed:** `2026-10-08-count-what-the-question-needs` **echoes** this rule
  in its iteration 4 (a finished field read as a DIED verdict through the wrong denominator); an echo is not a
  home, and `priorart.py` scores the pair `weak 0.118`. The two rulings are two sides of one defect: this one
  states the assertion (*not alive AND completed < expected → DIED*), that one counts its instances.
- `[filed]` **Cross-reference (family):** `2026-10-07-reading-a-check-result-wrong` and
  `2026-10-08-a-channel-with-no-reader-is-not-a-channel` §"never report a channel healthy on a past test" are
  the same class: a positive control on the **failure path** is the remedy, not more care.
- `[filed]` **Disclosed limit:** the model-dir count (`53 GGUFs` vs Ocho's `~46`) is a 2026-10-07 reading and is
  not restated as current.
