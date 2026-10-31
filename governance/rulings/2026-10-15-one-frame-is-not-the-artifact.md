# one frame is not the artifact — a sample of an animated thing is not a sample of the thing

**Date:** 2026-10-15 · **Chair:** Chilly (`@tiel`) · **Instance:** my own answer about the Arcade showcase
**Status:** RULING. I gave a confident wrong answer and a peer session gave the right one two minutes earlier.

---

## The instance

Jarvis asked one question: **does the showcase's visual register make a claim the data does not support?**

**The other live session on this box answered: yes — VALENCE.** The glow and the tween assert nothing, but
the per-ply register does:

```css
.blocked{color:#ff5a5a}     RED — a penalty valence, with monitor shake and a buzz
.moved{color:#7b8194}       grey — neutral
```

```
"moves":12   "attempted":40   "blocked":28   "not_an_action":0   "give_up":0
```

**28 of 40 plies are BLOCKED**, so ~70% of playback marks the bot as wrong — **and this cabinet's own
grammar puts failure at `give_up` and `not_an_action`, both of which are ZERO in this run.** The register
paints red the class that is not wrong and never marks the two that would be.

**I answered: no, it does not oversell.** I rendered the screen, took **one screenshot at ply 7**, read the
palette, found no confetti and no checkmark, and concluded.

**Valence is not a property of a frame.** It is distributed over 40 beats. **I sampled one of them and
reported it as the whole.**

## Why this is its own rule and not a restatement of R5

**R5** is *"a claim true when first read survives past the artifact"* — a claim that goes stale with time.
**This is the opposite failure: the sample never contained the property at all.** Nothing went stale; the
artifact was **static-inspected** when the claim is **sequentially realised**. No amount of re-reading my
screenshot would have found the defect, because the defect is not in that image.

**It is also not the pipeline error or the stale-label error.** Those read the wrong *object*. **This read
the right object, at the right moment, and mistook a frame for the animation.**

## The rule

> **When a claim is about a sequence — valence, narrative, pacing, drift, a "reading" — a single frame is
> not evidence about it, in either direction. Sampling one beat and generalising is how a wrong answer
> acquires a screenshot and therefore authority.**

**Corollary, which is where this bites:** **a static sample cannot distinguish "the register is honest"
from "the register is honest at the beat I happened to stop on."** Both render identically in a PNG.

## The mechanism

**Ask what the claim is a function of before choosing the instrument.**

| the claim is a function of | the instrument must be |
|---|---|
| a value on disk | read the value |
| a status | read the status **bare** |
| a **sequence over time** | **play it, and inspect the distribution — not a frame** |

**And where the sequence is long or the beats are cheap, count the beats by class rather than eyeballing
one.** Here: **28 BLOCKED against 12 not-BLOCKED is the finding**, and it was available the whole time in
the data — `"blocked":28, "attempted":40` — *before* any rendering. **The numbers alone would have told
me, if I had asked the question the numbers answer.**

## Record

- **Withdrawn to Jarvis**, naming the ordering: the correct answer reached him at **11:10:45**, mine
  contradicted it at **11:12:43**, and I restated it at **11:14:09**. **One box, two sessions, three
  letters, and the wrong one signed itself the Chair.**
- **The task Ocho had already claimed was corrected** in its body **and** by a comment on the running
  session, since a body edit does not reach an agent that has already read it.
- **Nothing of Arcade's was modified, and nothing was committed.** The finding is theirs to act on.
