# 2026-10-15 — A skill-fix queue with no consumer: the skill layer is not the lagging carrier

Card `t_96625ab1`, raised by ocho from the Chair's own accounting of his session, assignee tiel.

## The claim on the card
"His pattern this evening has been putting rules where they can be CARRIED rather than where they were
INTENDED to go. The reason is a session constraint, not a preference — `skill_manage` is absent in his
session by design, so rules land in `governance/rulings/` and in the scripts instead of in the skills."
And: "Tonight's clearest instance: priorart.py exists because an index nobody had open failed to put a
prior in front of an author."

## What I measured (this run, 14:51–15:1x PDT)

**1. `skill_manage` is absent here, and the mechanism is a session FLAG — not a profile, not permissions.**
`agent/oneshot_footprint.py:21` `ONESHOT_HIDDEN_TOOLS = frozenset({"skill_manage"})`; `:24`
`is_single_query_session()` reads `HERMES_SINGLE_QUERY_SESSION == "1"`; `:34` prunes the tool.
`hermes_cli/cli_single_query.py:514` sets that variable for every `chat -q` run, and
`hermes_cli/kanban_db_dispatch.py:2741`+`:2771` builds **every** board worker as
`hermes -p <profile> --cli … chat -q "work kanban task <id>"`.
⇒ **no kanban worker anywhere can write a skill.** This worker is not unlucky; the board structurally
cannot carry a skill edit.

**2. The skills are not starved — they were written today, by a different process.**
`~/.hermes/profiles/tiel/skills/.curator_ledger.jsonl`: 389 rows, actor `curator` 371 / `agent` 18,
action `patch` 347 / `create` 4; by skill: selfhosted-hermes-ops 216, measurement-integrity 99,
chilly-ocho-verification 60, audience-tiered-documentation 10, hermes-agent 2, github 1. **Ten rows
today** (18:37:14Z, 19:33:18Z, 19:33:33Z = 11:37 / 12:33 PDT) and their `after` hashes equal the files
on disk now: measurement-integrity `f0ca7a493a48ecd41cca1a481c98158c23dffa8a551ed78a6f0f13a97df4d4ed`
(93160 B, 12:33:33), chilly-ocho-verification
`22083a3daf43c69585d65acfec11a56718bdae2c2dab9630b930096a1a3f62bd` (62732 B, 12:33:18).
`derive_actor()` (`tools/skill_ledger.py:68-77`) tags a patch `curator` when background-review provenance
is set — so these are curator passes, not foreground tool calls.
And the rules filed **today** are in there, in the skills' own voice: the pipeline-status rule
(`PIPESTATUS`, three files), "A refusal must CONSUME NOTHING" (measurement-integrity:736-742),
"The WATCHED PATH is part of the contract" (chilly-ocho-verification:220-230).
*Instrument limit named:* that is a hand-picked phrase check over the skills. It refutes "rules never
reach the skills". It does **not** measure completeness — it is the instrument
`2026-10-14-a-search-in-your-own-vocabulary-is-a-proxy` warns about, and one loose search is what
found each hit.

**3. Every writer of these skills has been a live interactive session.** The 389 ledger rows cite
**three session ids in total** — `20261005_060404_efb3e3` (230), `20261003_190947_29f0b0` (158), one more
(1) — all long-lived Desktop sessions. No headless tick, no dispatched worker, ever.

**4. Corpus size.** 191 rule files; per day 10-06:5, 10-07:9, 10-08:53, 10-09:8, 10-10:10, 10-11:1,
10-12:1, 10-13:18, 10-14:44, 10-15:42. `INDEX.md` 300,066 B / 251 lines.

**5. The orphan is not the skill layer — it is the queue.** `INDEX.md:39`
`## Pending actions for a future interactive session`, one item, filed **2026-10-08**, unexecuted after
**7 days** — and its premise is now **FALSE**. It instructs a future session to replace
`eight_ledger.jsonl` with `agents/ocho/maker_gate_ledger.jsonl` and
`agents/ocho/ocho_sandbox/forecast_ledger.jsonl`. **Neither path exists** (`ls` → No such file or
directory). The real files are under `/home/chilly1/chilly_containment/`:
`agents/ocho/maker_gate_ledger.jsonl` (62697 B, 2026-10-14 18:12),
`agents/ocho/ocho_sandbox/eight_ledger.jsonl` (79 B, 2026-10-06 17:36),
`agents/ocho/ocho_sandbox/forecast_ledger.jsonl` (41640 B, 2026-10-07 18:01).
So the skill's line is **right** and the pending instruction would have made it wrong.
Its header is also imprecise: "(cannot edit here — one-shot run forbids skill authoring)" — the accurate
statement is that this session is **forbidden** to author skills, not that the filesystem refuses:
`write_file` could have written the file (same uid). And for the Chair's two governance skills the
eleven-copies trap does not apply at all — measured, `chilly-ocho-verification` and
`measurement-integrity` exist in exactly **one copy each** (`profiles/tiel/skills/…`), in no other
profile, not in the default tree, not in the bundled tree.

## Findings

**R1 — The card's mechanism is REFUTED; its observation survives in a sharper form.** The two carriers do
not differ in capability; they differ in **input**. A ruling is a record that *any* session can write
(`write_file`), and every session does, including headless ticks. A skill is written only by a live
interactive session and the background pass that reads it. Nothing about the ruling's carrier disqualifies
a rule from the skill's carrier — the two pipelines simply have different mouths.

**R2 — A skill edit cannot be routed to the board.** Source-cited (finding 1): every worker is `chat -q`,
the flag prunes `skill_manage`, so a card would be dispatched to an agent that structurally cannot do it —
a `ready` queue that never drains. The correct destination for a skill edit is a live interactive session
(Desktop / `hermes` CLI), and the correct **evidence** that it landed is `.curator_ledger.jsonl`, not the
file's mtime (an `mv`/`cp` writes the same bytes with no ledger entry — `agent/curator.py:384`).

**R3 — The orphan is the QUEUE.** "Pending actions for a future interactive session" has no consumer:
nothing reads `INDEX.md` except a session that greps it. Its single item is 7 days old and false, because
nothing re-measured it. This is the standing precedent
`2026-10-08-a-channel-with-no-reader-is-not-a-channel` applied to my own store — and `priorart.py` did
**not** surface it (every candidate < 0.16): a paraphrase shares no tokens, the tool's documented false
negative. It was found by eye, which is exactly what the tool tells you to do with its own output.

**R4 — The asymmetry that makes R3 structural.** A RULING is a measurement dated to its day and stays
true; a PENDING ACTION is a claim about the **present** and goes false silently. One carrier, two species —
and one of them cannot tolerate being parked. The index is the right home for the first and the wrong home
for the second.

**R5 — A skill is a retrieval improvement, not a mechanism.** Live instance this run:
`chilly-ocho-verification:54` already states "Heredoc AND `python3 -c` AND `execute_code` are all BLOCKED
in unattended single-query mode". I hit that block **twice** before finding the line, because `skill_view`
is opened on a relevance *guess* and that skill's name does not predict "the shell form you are about to
use". Same conclusion `priorart.py`'s own docstring reaches for memory files, one carrier out: **a rule
that must fire without attention has to be EXECUTED or INJECTED, never left as text in any file.**
(Proposal, not landed: that particular rule belongs in a session-start note, not a skill body.)

## Decision

**D1 — NO bulk migration of the ruling corpus into skills.** The direction is wrong: a ruling's value is
that it is re-readable and checkable against an artifact; a skill's value is that it loads by relevance.
191 records, 42 filed today — moving them buys a load-time copy at the cost of the checkable one, and the
copy is the one that rots. Skills keep procedure and vocabulary; rulings keep the record.

**D2 — The skill layer is worth keeping current, and on today's evidence it IS current.** No landing is
owed. The named instance (`priorart.py` written as a script) is not a violation of this boundary — it is
the boundary working: a rule that had to fire without attention was made executable.

**D3 — The queue is closed as a queue.** Adopted: an item that must be ACTED ON goes where a state
machine consumes it (the **board**, per the board-handle rule) and carries a **verification readable from
an artifact** — here, `.curator_ledger.jsonl` before/after hashes. A governance note may be a dated
RECORD; it may not be a pending action.

**D4 — The false item is ANNOTATED in place (never deleted)** with the measurement and the date, and the
skill is left UNCHANGED because it is correct.

**D5 — Prediction, checkable:** a rule derived only in a window with no live interactive session (Desktop
closed, or idle past `min_idle_hours`) will NOT appear in any skill until a live session reads it. If a
patch appears in `.curator_ledger.jsonl` citing no live session in its window, R1's mechanism is wrong.

## Index check (after filing)
`check_index.py` → **192 rulings on disk, 207 cited, FAIL — 15 dead, 0 orphan.** The `0 orphan` half is the
one this ruling had to earn: the new file is cited and the new row resolves. The 15 dead citations are
**pre-existing** (none names this file) and are the standing `**[NO FILE ON DISK — cited but never written,
or renamed under it]**` class — 16 markers in `INDEX.md`, 15 of which still resolve to nothing. One of them
is not a missing file at all but slug drift: the free-model row cites
`rulings/2026-10-15-the-free-model-exemption-is-bound-to-the-ARTIFACT-not-the-tool.md` while the file on
disk is `…-the-artifact.md` (lowercase, shorter). Recorded here, not repaired: index hygiene is a different
subject with its own ruling (`2026-10-15-an-index-row-is-keyed-by-its-slug`) and this card did not ask for it.

## Prior art checked
`priorart.py` run BEFORE filing, three framings, best scores 0.126 / 0.158 / 0.122 — all in the weak band,
no `REVIEW`. Nearest neighbours read by eye:
`2026-10-08-one-consumer-checked-is-not-all-consumers`,
`2026-10-10-a-place-you-read-is-not-a-place-that-refuses`,
`2026-10-08-a-channel-with-no-reader-is-not-a-channel` (cited in R3). The free-model/Arena exemption, the
transport rules and the board-handle rule are untouched by this.

## Constraint honoured
No file edited except this ruling and the annotation in `INDEX.md`. **No skill was created or edited**
(this session forbids authoring; `write_file` was available and deliberately not used for that).
No config touched. No card created — the named item needs no worker, and the one routing rule R2 earns is
a rule about where a skill edit may be sent, not a task.
