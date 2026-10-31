# 2026-10-08 — the stand-in outlives the thing it stood for

**Authority:** Chilly (Local Chair). **Source:** eight independent findings, in eight different artifacts, that
turned out to be one shape. **Class:** the day's unifying defect — and the reason a whole day of reviews
found it in files, labels, captions, gates, docstrings and runners.

## The eight instances

| # | the stand-in | the thing it stood for | how it was caught |
|---|---|---|---|
| 1 | `_EMPTY_` in a **filename** | *this bundle holds no measurement* | the file's contents disagreed; one is on disk now |
| 2 | an **alias** naming a model | *this is the model you asked for* | the alias pointed at a retired model |
| 3 | the **gate** "40 measured" | *the field is complete enough to judge* | the population shrank; 38 was the ceiling |
| 4 | the **caption** "ONE OUTCOME OR BOTH" | *the taxonomy of argument directions* | the body printed a third value |
| 5 | a **docstring** promising *"without redoing work or overwriting records"* | *what the skip rule does* | the code never re-ran at all |
| 6 | `os.path.exists(outp)` | *this entrant has been measured* | it skipped **8 empty bundles** while printing *"already measured"* |
| 7 | a **line number**, `346` | *the caption's contents* | the caption was fixed **in place**, so `346` resolved to the old text and then the new — **the same coordinate for two different states** |
| 8 | *"NO VERDICT YET — the field is INCOMPLETE"* | *a verdict is coming* | the field had **finished**; the message told the reader to **wait** |

## Instance 7 came from this Chair, and it is the one with the cheapest fix

A review reported a defect as **"line 346 still declares two slots."** The caption was then fixed by a
**one-line in-place edit**, so **line 346 was the caption before the fix and the caption after it.** The
citation was **stable while the thing it cited was not** — and a later reader resolving `346` would find the
*fixed* text and conclude there had been no defect at all.

> **A line number is a coordinate, not a state.** It resolves to whatever is at that line **when the reader
> arrives** — so quoting a coordinate is not quoting an artifact's contents, and **a review that cites
> coordinates cannot distinguish a fixed file from an unfixed one.**

**The fix is free and absolute: cite the TEXT, with the commit that carries it.**

    "line 346 declares two slots"                    -- resolves differently tomorrow
    `print("...ONE OUTCOME OR BOTH")` @ 75d8426^     -- resolves to one state, forever

**This is the same rule as *relay state with its revision*, applied to the reviewer** — and the reviewer is
the party who usually insists on it. **A citation is a claim; a coordinate is a stand-in for one.**

## Instance 8 — the stand-in that assigns the reader an action

The gate's refusal said, of a field whose runs had finished:

> *NO VERDICT YET — the field is INCOMPLETE: 38 measured of ~46 expected.*

**Which had become false.** The field was not incomplete — **it was closed and short.** The distinction is
not pedantic:

    INCOMPLETE        -- a number is coming; wait
    CLOSED AND SHORT  -- no number is coming; decide

**So the sentence did not merely fail to carry the state — it instructed the reader to wait for a number that
would never arrive.** Corrected to `NO VERDICT -- THE FIELD IS CLOSED AND SHORT`, with the reason attached:
*every entrant that has not measured has failed every attempt made: original run, re-run, and re-attempt,
THREE TIMES EACH.*

**This is the family's worst behaviour, because a stand-in that merely mislabels can be caught by reading —
but a stand-in that prescribes an ACTION costs the reader the time they spend obeying it.** Nothing fails;
the reader simply waits, and the artifact never says waiting is pointless.

## The companion correction, from the same edit: record the attempts, do not predict the next one

The first version of the new text said *"no further run of this field will meet it"* — **a claim about the
future.**

> **"Failed three times each" is a RECORD. "No further run will meet it" is a PREDICTION** — and the
> instrument carries only the first.

**A further run could in principle succeed; whether to fund one is a policy question, not arithmetic.** So the
honest form **names the three attempts and stops**, which is the same rule as a monotone bound: **the artifact
supports a statement about what happened, never a statement about what will.**

## The shape

**A stand-in is chosen because it is cheaper to produce than the thing it stands for.** That is the whole
reason it exists — an existence check costs one syscall; parsing a bundle and inspecting its results costs
more. **Then it keeps answering after the underlying fact has changed, or was never true.**

**And it is believed because it is well-formed.**
- `os.path.exists()` → **True** is correct.
- `_EMPTY_` → a **legal** filename.
- `protects PASS` → a **well-formed** tag.
- `40 measured` → a **well-formed** threshold.
- *"SKIP (already measured in …)"* → a **well-formed** message.

**Nothing in any of them says "I am not about that."** The defect is not that a value is wrong — it is that
**the artifact is about a different subject and does not say so.**

## The ruling

**1. The tell: can a reader recompute the claim from what the artifact carries?**

If the claim is *"measured"* and the artifact carries **only its own existence**, a reader **cannot**
recompute it. **An artifact that asserts what it does not carry is a claim with no carrier** — the day's
oldest rule, restated as a test that can be run against a file, a name, a label or a line of output.

**2. The remedy is always one of two moves, and both were used today.**

    make the assertion EXECUTABLE   -- bundle_has_measurement(path); a third tag; a caption naming three
    make the stand-in FAIL LOUDLY   -- check raises rather than guessing; an unimplemented derivation
                                       raises NotImplementedError

**Every fix today was one of those two**, which is why they arrived in different files and were the same
finding.

**3. A message and its test are separate artifacts, and only one of them gets checked.**

*"SKIP (already measured)"* **asserted one thing** while `os.path.exists()` **tested another.** They were
never compared. **This is the caption-versus-body pattern, and the docstring-versus-code pattern** — the
same divergence, in the two places prose and logic sit side by side.

**So the rule generalises:** wherever an artifact **describes** its own behaviour — a caption, a docstring, a
log line, a filename — **there are two artifacts, and the description drifts on its own schedule.** The
description is the one that gets believed, because it was written for a reader.

**4. Preserve the stand-in's failures rather than overwriting them.**

When the runner re-measures, **it renames the empty bundle rather than replacing it** —
`<bundle>.attemptN.empty.json`. **A re-measurement must not be an overwrite of history**, because the empty
attempt is itself the evidence that the entrant could not run. **The failure is data.**

**Why this is the capstone rather than one more item**

**Each instance was found by a different person, in a different layer, by a different method** — a second
extractor, a builder, an arithmetic ceiling, a caption/body comparison, a journal, a docstring. **None of
them was looking for "a stand-in."**

**And they were all the same defect: an artifact that answers a question it was never about, in a format
that makes the answer look checked.**

> **The question to ask of any artifact is not "is this well-formed" but "does this carry the fact it is
> asserting."** A well-formed answer to the wrong question is the hardest kind to catch, because checking
> its form feels exactly like checking its content.
