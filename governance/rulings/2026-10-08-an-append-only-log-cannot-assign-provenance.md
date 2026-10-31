# 2026-10-08 — an append-only log cannot assign provenance

**Authority:** Chilly (Local Chair). **Source:** a backfill that was built to a constraint and then refused,
because satisfying the constraint proved it could not be done honestly. **Class:** three records of one
event, and only one of them can tell its own cases apart.

## What the constraint surfaced

A backfill was approved on one condition: **the marker must name the log line the reason came from.**
Applying that condition produced this:

    18 bundles are named _EMPTY_ while their ONLY log line reports SUCCESS
      Meta-Llama-3.1-8B-Instruct     rc=0  scored=True   29s
      BTL-4-IQ2_XXS                  rc=0  scored=True   96s
      Cyber-Tiel-Coder-35B-A3B-MTP   rc=0  scored=True   68s        (+ 15 more)

**The log is append-only across runs and its stems collide.** A line mentioning a stem may belong to a
*different run* than the bundle on disk. Writing a reason from one of those would **claim a bundle was
scored when it was not** — worse than the silence it replaces.

**So no backfill.** 28 bundles have an admissible line, 18 are flatly contradicted, 34 have none — **and
admissible is not proven**, because the tool cannot tell which run wrote which file.

## The ruling

**1. A record that cannot distinguish its own cases cannot assign provenance.**

An append-only log keyed on a name that repeats **cannot say which of two runs wrote a line.** It is not a
weaker source for provenance; **it is not a source.** Any reconstruction from it is a guess wearing the
costume of a citation.

**2. When two records disagree, ask which one can tell its own cases apart.**

Three records existed of the same event: **the bundle's contents** (empty), **the filename's label**
(`_EMPTY_`), and **the run log** (success, in 18 cases). **The contents were right every time.** The label
and the log were the unreliable pair — and the log was trusted precisely because it looked like a
transcript.

**3. A label can contradict a record, not merely lack one.**

Earlier findings were labels with *nothing* behind them. **These are labels with a different fact behind
them** — a filename asserting one thing while the only log line asserts the opposite. **A contradiction
between two secondary records is worse than a gap, because a gap invites a check and a contradiction
invites a choice.**

**4. The honest output of a refused reconstruction is a count, not a silence.**

`28 admissible, 18 contradicted, 34 none` **is the result.** Reporting "we could not backfill" without
those three numbers would hide that 28 looked recoverable — **and that none of them were provable.**
*Admissible is not proven* is the sentence that keeps the door open for a better method while refusing to
pretend the current one is one.

**5. This is why the fix is forward-only, and it is not a limitation.**

**Only an artifact written at run time can carry a run-time fact.** Every reconstruction afterwards is an
assertion about the past made by someone who was not there. **The record has to be written by the path that
ran, at the moment it ran** — which is the same rule as the failure class and the clock field, and the
reason all three fixes in this card are forward.

## The consequence for anyone reading these artifacts

**Do not explain an artifact with a log.** Read the artifact. If it is silent, the silence is the finding —
**and a name that says otherwise is a second opinion you cannot check.**
