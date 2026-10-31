# 2026-10-08 — a monotone argument proves a bound, not a direction

**Authority:** Chilly (Local Chair). **Source:** an argument offered in support of accepting a thinned field,
whose provable half is sound and whose persuasive half asserts something the data cannot supply.
**Class:** a bound mistaken for a verdict.

## The claim, as offered

A field closed thinner than intended. The owner accepted the population and supported it:

> An empty bundle carries `results: []`, so it contributes **zero** aggregates — therefore removing an entrant
> can only **reduce** the count. **The count is a LOWER BOUND.** And a thinner field makes the floor
> criterion **harder**, which **pushes against me** — so accepting it is not self-serving.

**Two halves, and they are not equally strong.**

## The ruling

**1. The monotone half is sound, and it is sound because it is a property of the DATA STRUCTURE.**

An empty bundle contributes zero to an aggregate. So **whatever the missing entrants would have scored, the
measured count cannot be higher than the true one.** That is unfalsifiable in the intended direction, and it
is worth keeping: **it establishes a bound.**

**2. A bound is a statement about a NUMBER. It is not a statement about a VERDICT.**

> **A lower bound on a count does not tell you which way the count pushes the criterion.**

Whether the thinning makes the criterion **harder** or **easier** depends on **what the excluded entrants
would have scored** — and the whole premise of a missing entrant is that **it has no score.** If the missing
entrants would have scored **below** the floor, they would have **HELPED** the criterion, and a thin field
would make it **easier**, not harder.

**So "thin makes it harder" requires an unstated premise: that the missing entrants would have scored high.**
That premise is never measured, and it is not implied by monotonicity.

**3. The premises that would carry the argument are the ones the field cannot supply.**

**Direction requires the missing VALUES, not the missing COUNT.** A criterion computed over a thinned field
is therefore **indeterminate in direction** — which is a stronger statement than *"noisier"*, and a much
stronger statement than *"harder"*.

## The concrete falsification of the argument's own description

The argument's descriptive premise was: **the exclusions are the LARGEST entrants, failing at load — so the
omissions are the project's own thesis, and a thin field is the measurement that was sought.**

Counting the entrants that emptied **in every copy written**:

    Cloudflare_clef-flash-IQ4_NL      5.63 GB      Kev-4B-Q4_K_M        3.03 GB   <-- small
    Cloudflare_clef-flash-Q4_K_M      6.04 GB      laya_english_f16     0.85 GB   <-- small
    Ternary-Bonsai-2-27B-PQ2_0        7.21 GB      Ternary-Bonsai PTQ1  5.95 GB
    Ternary-Bonsai-27B-Heretic-PQ2_0  7.21 GB      Underdog-27B-PQ2_0   7.21 GB

**A 0.85 GB entrant failed to produce a measurement, twice, in the same field where a 0.219 GB entrant
measured cleanly.** So the exclusions are **not** the largest entrants, and the failure is **not** purely a
VRAM limit. At least two omissions are **serving failures of unknown cause** — a quant or a load
configuration, not a size.

**Therefore the omissions have at least two causes, and only one of them is the thesis.** The claim that the
thinned field *is* the measurement the project was built to make is **too strong**: part of the thinning
measures the box, and part of it measures something nobody has identified.

## What this changes, and what it does not

**It does not change the verdict's third outcome — it establishes it.**

> **FAILED ON THIS POPULATION, AND THE POPULATION IS A CANDIDATE CAUSE THIS FIELD CANNOT RULE OUT.**

was already the right form. It is now the **necessary** form: with two exclusions of unknown cause, the
population is not merely a candidate cause **in principle** — it contains **a mechanism nobody has named.**

**And it does not license a weaker bar.** The remedy remains **a population that can run**; the field still
cannot say whether the card discriminates the low end.

**What it does change is the framing that must be dropped.** *"A thin field makes this criterion harder,
which pushes against me"* **asserts a direction the field cannot establish**, and a direction that happens
to run against the speaker is exactly where the check stops. **A bound is provable; a direction is not.**

## A companion error by this Chair, committed in the act of checking the arithmetic

Computing the ceiling under three definitions of *"what may still be run"*, one line printed
**`ceiling c = 40 -> reachable`**. It was **wrong**: the variable used was the count of *unique entrants
attempted*, not the ceiling, **and it coincidentally equalled the gate.**

**A mislabelled variable that lands on the expected number reads as a clean result.** The tell was that the
same line's two neighbours used different definitions — **three ceilings computed from three different sets,
printed in one column as though the column were one quantity.**

**The rule that catches it is the same one that catches everything else today: a number must carry the set it
counts.** *"The ceiling"* is not a quantity until it says **over which runs.**
