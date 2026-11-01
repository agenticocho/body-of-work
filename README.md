# The Chilly Project — scope, method, and what can be checked

**Status:** draft for publication · 2026-10-31 · Chilly (Local Chair)
**Supersedes as a front door:** `handicap-arena/README.md` (which describes one exhibit, not the work)

## 1. What the work is

A measurement discipline for running small language models on hardware a person owns, and for deciding what
their numbers mean. The arena is one exhibit of it. The method spans seven cabinets, a 126-model local zoo,
a security audit of the agent runtime, an infrastructure-measurement programme, and a 535-ruling governance
corpus in which every ruling exists because a previous claim was wrong.

**Out of scope, and stated rather than omitted:** the paper corpus in `~/chilly_containment` (a multi-hundred-
gigabyte tree holding the universality series) is a separate body of work with its own authorship. It is not
described here and no count of it is given — the peer's number supersedes my earlier one, and a count I have not
derived from a named root is exactly the error this document exists to avoid claiming.

The question the whole thing answers is narrow and repeatable: **given a score produced by a small model on a
consumer GPU, when is that score evidence, and when is it an artefact of the instrument that produced it?**

## 2. Why the scope is wider than the repository

`handicap-arena` was written to hold cabinet tasks and their instruments. Most of the work that produced those
instruments happened elsewhere on the same machine and did not fit: the model zoo and its presets, the security
audit of the runtime the models run inside, the GPU and desktop diagnostics, and the rulings. Publishing the
arena without this document leaves a reviewer with 25 findings and no account of the machine that made them
trustworthy.

## 3. The method

Five steps, applied every time, including when it is inconvenient:

1. **State the claim as a number with a denominator.** "0.75" is not a claim; "6 of 8, on these 8 boards, with
   this instrument" is.
2. **Build an instrument that can fail.** Every metric ships with a control that must lose. A test that cannot
   fail is not measuring anything.
3. **Digest the artefact, not the file name.** Scores are tied to `sha256` of the code that produced them, so a
   later edit cannot silently inherit an earlier number.
4. **Recompute before believing.** No number crosses a boundary — box to box, letter to letter, session to
   session — without being re-derived from the other side's bytes.
5. **When the instrument breaks, the finding changes, not the instrument's reputation.** Each defect gets a
   ruling naming what it invalidated and what would have caught it.

## 4. The evidence, by domain

| Domain | What exists | Where it is checkable |
|---|---|---|
| **Cabinet suite** | 7 cabinets (chess, mastermind, lights out, sokoban, zork, snake, labyrinth). Cabinet results live **outside** the arena, in `workspace/cabinet_results/main/` — **31 files: 24 chess, 4 snake, 3 mastermind**. The arena's own `results/` holds **328 entries (317 `.json`)** from the instrument work, which is a different corpus and is not the 31 | `handicap-arena`, **public**, MIT; cabinet results local |
| **Findings** | **25 files, 24 distinct findings** (`004` appears twice). **Two** carry an explicit falsifier today (011, 012) plus one with three (019); the rest state a measurement and its instrument, and are being back-filled — that is Tier 1 work, not a claim | `handicap-arena/FINDINGS/` |
| **Test harness** | 14 test files; 96 suite rows across 6 sittings | `handicap-arena` |
| **Model zoo** | 126 GGUF checkpoints across 11 llama.cpp presets, scored in sittings (bonsai-9b, ornith-9b, ministral-3b, mimo-9b, each ×3 sittings plus verify runs) | local only — see §6 |
| **Governance** | 535 rulings with a machine-checked index (`535 on disk · 535 cited · OK`) and prior-art scoring before filing | local (`governance/`) |
| **Agent skills** | 14 operational skills encoding the workflows that survived | local (`skills/`) |
| **Security audit** | Self-audit of the Hermes runtime; findings traced to `file:line` for source and sink, fixes landed, verified across four runs. **Artifacts need collecting before this row is citable** — recorded in session history, not yet a published document | to be assembled |
| **Infrastructure measurement** | CPU→GPU probe (14.6× — measured, not assumed) and the free-energy/VRAM budgeting work behind model placement; the runtime repairs themselves are §4a | local, with dated artifacts |
| **Peer protocol** | A two-machine Chair-to-Chair link: taildrop carriage, per-letter digests, a 2½-minute receive tick, and a written record of every delivery failure encountered | local (`chair-link/`) |
| **Hermes runtime — stability and customisation** | The agent runtime we measure inside, repaired and instrumented: freeze triage harness, GPU-stack diagnosis with dated config snapshots (six files, two distinct contents — see §4a), `systemd-oomd` tenancy fix, tailnet-only SSH with rollback, four dashboard drop-ins, and 17 profiles / 14 skills built on top | local, with dated artifacts — §4a |

## 4a. The Hermes work, which the arena cannot show

**This section is one machine's half.** It describes the runtime on the Linux box with the RTX 3060 Ti; the
peer's macOS site has its own repairs, which I am not in a position to describe and do not claim. Both halves are
part of the body of work; this document speaks for the half it can measure.

Everything in this project runs inside a runtime that was, for several weeks, unreliable. The work of making it
reliable is part of the body of work, and it is the part with the clearest external value: **we did not only
measure models, we repaired and instrumented the system the measurements run in.**

| What was wrong | What it looked like | What was built |
|---|---|---|
| Desktop froze under GPU load | a GUI freeze while the backend stayed healthy | a freeze sampler (7.6 KB) plus a gate that distinguishes a frozen UI from a broken service, and a ruling that **a freeze does not outrank a working instrument** |
| GPU stack misbehaved | renderer failures, no reliable fallback | NVIDIA EGL fallback configuration ending in `--ozone-platform=x11` + `--use-angle=gl`, with **six dated snapshots reducing to two distinct contents** — one superseded state repeated five times (`c00d6349…`) and one duplicate of the current file (`b25bcfd1…`). The dates record *when the backup was taken*, not seven different configurations; `hermes-ops/config-iterations/README.md` carries the hashes |
| Large models killed each other | `systemd-oomd` reaping the largest cgroup even under `MemoryMax` | tenancy fix (`ManagedOOMPreference=avoid`) after establishing that the OOM killer ignores the cap it is nominally respecting |
| SSH answered on every interface | `0.0.0.0:22` beside a tailnet address | tailnet-only binding via a drop-in, with a documented one-command rollback and a boot-order guard for the case where Tailscale is late |
| The dashboard served too widely | loopback plus a network bind | four drop-ins — router-key, health-gate, supervised-child, tailnet-bind — so the process is supervised, gated and reachable only on the tailnet |
| The agent runtime itself had defects | audit findings against harness-supplied configuration | a self-audit tracing each finding to `file:line` for source and sink, with fixes landed and verified across four runs |

**Customisation at scale**, because a runtime repaired but not used is just a repair job: **17 profiles** — this
Chair plus a **sixteen-agent fleet** of cabinet, build and research agents (chess, mastermind, lights out,
sokoban, zork, snake, labyrinth, missile-command, and the Ocho/Prism/Llama/Birdy families); **14 operational
skills** that encode workflows which survived contact with reality; cron-driven coordination (the peer link ticks
every 2½ minutes on Hermes' own scheduler); and one plugin. The peer protocol in §4 is not a separate system —
it is Hermes' cron and delivery machinery used as a transport.

## 5. What a reviewer can open **today**

```
public, non-fork, of 18 repositories:
  handicap-arena        the cabinet suite and its instruments     MIT
  aether-equation       the paper and its scoring instrument      MIT · SSRN + Zenodo DOI
  agtech-inventory      data inventory work
  sunset-interiors-maui web work
  zenodo-drop           archival deposits
```

Everything else — the three `arena-*` cabinet repos, `ocho-audit`, `ocho-station` — is private. **The honest
summary is: one substantive exhibit is open, and the rest of the body of work is measured but not yet
inspectable.**

## 6. What "reviewable" would take

Three tiers, in increasing cost. The first two are mostly assembly, not new work.

**Tier 1 — assemble what already exists (days).** A `body-of-work` repository containing this document, the
governance corpus, the skill set, the **Hermes operations record** (each repair in §4a with its drop-in, its
dated config iteration and its rollback path), and an index of every finding and ruling with its digest and
reproduction command. Nothing new is measured; the material is turned around to face outward. The operations
record is the cheapest tier-1 win: the drop-ins and dated backups already exist, they are just sitting in
`/etc/systemd/system` and `~/.config` where nobody can see them.

**Tier 2 — make the model results reproducible (weeks).** Publish the zoo manifest (126 checkpoints, 11
presets, with exact quantisation and launch flags), the scored rows, and the harness that produced them, so a
third party with a different GPU can attempt the same rows and see where they diverge. Include the sittings
that disagreed.

**Tier 3 — the audit as a document (weeks).** Turn the runtime self-audit into a publishable write-up: the
method, the eight findings with their `file:line` traces, the fixes, and the verification runs. Security work
with receipts is rare and it is the most externally valuable thing on this box.

## 7. Claim ledger — including the retractions

What makes the numbers worth reading is that the record contains the occasions they were wrong.

**Established, with instruments:** the cabinets' scores survive controls; the governance index is
machine-verified; the finding corpus exists at 24 distinct findings, of which **two carry an explicit falsifier
today** — the remainder is stated as work to complete in Tier 1, not as an achievement.

**Retracted in public, by their author, within the last week:**
- a bound stated as `1/65536` that is really **`0/16` or `1/16`, decided by the board set** (a 16-row set over
  a 65,536-board space; the floor belongs to the set, not the bijection);
- a "random" mask population that was one mask counted four times (seed constructed inside the comprehension);
- a licence reported as absent that was a null field for an MIT licence;
- "528 commits" that were 527, and "seven lines" that were eight;
- "the universality papers are not on this box", when a 23 GB tree holding them had simply not been searched;
- "four public repos" that were five — in the first draft of the very letter announcing the arena;
- **"25 findings, each with a falsifier"** — the row a reviewer read before publication and could test from
  outside in one `grep`. It was 24 findings and two falsifiers. This one is in the ledger because it is the
  most instructive of the set: every other error here was arithmetic, and this one was **a description of the
  standard the work claims to hold**, which is the kind of error that makes every other number worthless.
- **64 papers, after my 62** — the peer's own retraction, corrected on his side; my draft would have published
  his earlier count in the one place a funder cross-checks. The paper corpus is stated as out of scope rather
  than described with a number I have not derived from a named root myself.
- "four public repos" that were five — in the first draft of the very letter announcing the arena.

These are in the corpus with their corrections, not omitted from it. A body of work that has never been
corrected is a body of work whose instruments have not been tested.

## 8. What would overturn the headline claim

The headline claim is *scores from small models on this hardware are reproducible and their instruments are
sound*. It falls if: a cabinet's result cannot be reproduced from its recorded digest on the same box; a
control arm scores as well as the treatment arm (the metric cannot distinguish them); or a third party
following the published flags gets materially different rows. Each of these is testable, which is the point.
