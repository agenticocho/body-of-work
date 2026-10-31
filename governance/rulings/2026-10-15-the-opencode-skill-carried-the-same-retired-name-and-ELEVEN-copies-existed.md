# the opencode skill carried the retired name, and eleven copies existed

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Rule recorded:** 2026-10-15 · **FILED:** 2026-10-16 (local 2026-10-15 17:4x PDT)
**Source of this filing:** `INDEX.md` line 228 — `2026-10-15-the-opencode-skill-carried-the-same-retired-name-and-ELEVEN-copies-existed` — the same row the INDEX cites.

**Provenance (read this before citing the rule).** This file is a **BACKFILL BY
TRANSCRIPTION**, created 2026-10-16 (2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ) because no file under
`rulings/` carried the rule — the record survived only as an INDEX row, where the prior-art gate
cannot see it. The rule text below is **the ledger row's own text, carried verbatim** (the row line,
with its `NO FILE ON DISK` marker stripped); nothing in it is reconstructed from memory, and nothing
claims the file was written on the date in its filename. Editorial additions by the filing are
confined to the section *What this filing adds*, and each is marked `[filed]`.

---

## The rule, as recorded in the ledger (verbatim)

    2026-10-15 | the-opencode-skill-carried-the-same-retired-name-and-ELEVEN-copies-existed | Mike: "go for both standing items". ITEM 2 DONE, and it was bigger than one gate. THE SKILL ITSELF PRESCRIBED `npm i -g opencode-ai@latest` -- the exact retired name whose latest dist-tag resolves to 1.19.0, the false-convergence trap Jarvis sent this morning. So every agent on this box, following its OWN skill, would have installed the old build under a new manager and believed the version moved. AND THERE WERE ELEVEN COPIES: one per agent profile (tiel, ocho, ocho2, birdy, llama, sokoban, zork, missile-command, harness-test) plus ~/.hermes/skills/ and the bundled ~/.hermes/hermes-agent/skills/. Editing only the bundled copy would have been DECORATION -- eight agents would have kept the retired name and the permissive gate. All eleven updated and verified identical: md5 a5dceb3ef7ce, version 1.3.0, 0 occurrences of opencode-ai@latest, scope block present. CHANGES: retired name -> @opencode/cli with the reason; auth gate -> -free ids need NO credentials (verified on a box with no auth.json); verify step -> count AND read the ids (a count beside a list is a separate claim); and a Scope section carrying Mikes boundary verbatim -- PERMITTED the Arena own code (destined for public release), FORBIDDEN everything else about this box, in any tool, for any reason, because the permission attaches to the ARTIFACT and not to the skill or the operator. ITEM 1 BLOCKED: `sudo -n snap remove opencode` -> rc=1, "interactive authentication is required"; no passwordless sudo. Mikes command: sudo snap remove opencode (reclaims 181 MB). AND MY OWN REPEAT: the sudo attempt printed rc=0 through `| head -3` -- THE PIPE ERROR, TWICE IN ONE SESSION, on the morning I filed the ruling about it, in the very command written to demonstrate the fix. Re-measured bare: rc=1.

---

## What this filing adds (editorial; marked `[filed]`)

- `[filed]` **The row's own verification handle reproduces at filing (2026-10-15 17:37 PDT):** eleven
  `SKILL.md` copies of `autonomous-ai-agents/opencode` exist under `~/.hermes` (nine profile roots — `tiel`,
  `ocho`, `ocho2`, `birdy`, `llama`, `sokoban`, `zork`, `missile-command`, `harness-test` — plus
  `~/.hermes/skills/` and the bundled `~/.hermes/hermes-agent/skills/`), **all eleven md5 `a5dceb3ef7ce`**, and
  `grep -rl "opencode-ai@latest" ~/.hermes --include=SKILL.md` → **empty**. The md5 the row records is not only
  recordable; it is reproducible.
- `[filed]` **Why filed and not re-pointed:** `priorart.py` best candidate **0.105**
  (`2026-10-10-a-name-is-not-the-thing-it-names`). The related filings `2026-10-15-a-skill-fix-queue-with-no-
  consumer` (which names the eleven-copies trap) and the drift ruling's **R1/R3** (drift set is per box; the
  bundled exclusion is keyed on a **path**, not on equality) develop this record — they do not contain it.
- `[filed]` **The durable rules, stated so the next agent does not have to re-derive them:** a skill fix that
  lands in one copy is **decoration** — count the copies AND read them; an instruction that names a retired
  package reproduces a false convergence in every agent that follows its own skill; and a scope boundary
  attaches to the **artifact**, quoted verbatim, not to the skill or the operator.
- `[filed]` **Disclosed limit:** the permission/scope paragraph quoted in the row is Mike's boundary as
  recorded on 2026-10-15; it is carried because the row carries it, not restated as a new grant.
