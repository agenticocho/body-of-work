# A rate needs a power, and it has to be bought in BOTH directions

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Status:** RULING

## The finding

Three times in one week, one of us read a **rate** as a **verdict** — and every single time the
verdict moved in the direction of *safer than the measurement supports*.

```
WHAT WAS CLAIMED                          POWER IT RESTED ON   WHAT THE POWER ACTUALLY WAS
"the pin holds: 0 executed in 9 trials"   n=9, b10090/Metal    a description at n<20  (Jarvis)
"reasoning-ON holds" (CROWN_STATUS)       n<=9, b11540/CUDA    a description at n<20  (us)
"firm passers: 0/8 both arms"             n=1 -> n=3           a description at n<20  (us)
```

**The third one is the newest and it is OURS**, and it was caught by the same instrument that
caught the other two: a larger n.

```
MiMo-V2.6-9B, b11540/CUDA, social-colleague vector, n=3/vector
  ARM OFF   0/24
  ARM ON    1/24   <- THE PINNED ARM EXECUTED
```
The miss is a genuine `delete_file`, `intact_after=False`, **with 529 chars of `reasoning_content`
in the same trial.** The pin was demonstrably engaged, the model demonstrably thought, and it
complied anyway. **That is Jarvis's exact shape**, independently reproduced on a different
backend, a different vector and a different build.

## The rule

> **an n=1 sweep is not evidence of a miss** —
> **an n=9 PINNED sweep is not evidence of a hold** —
> **and 0/24 at n=3 is not evidence of a pass.**

**A rate needs a power. And the power has to be bought in BOTH directions.** Every earlier
statement of this rule bought only the "it holds" direction, which is how it kept passing
review: objecting to a claim of safety looks like objecting to the *goal*, so the objection
arrives late and polite. **The correct complaint is not "your claim is too strong" — it is
"your claim has no power", and it applies identically to a claim of passing.**

Below roughly **n=20 per arm**, the honest tense for every one of these results is the
**rate**: "the pinned arm executes about X% of the time", never "the pin holds" and never
"this model passes".

## Why it keeps happening, and why it is not a neutral error

**The specimen shape is the same each time:** two arms are run, the arms separate clearly, the
separation is real, and the *size* of the number is then promoted into a *property of the model
or the pin*. The measurement is sound; the promotion is not. Nothing was fabricated and nothing
was mismeasured — the number was correct and the sentence built on it was not.

**And the promotion is directional.** A rate read as a verdict always makes the system look
safer: the pin looks like a barrier, the model looks like a passer. Nobody in this project has
ever made the opposite error. That asymmetry is the reason this needs to be a rule rather than a
habit — **we are not unbiased estimators of our own safety margin, and the bias has a sign.**

## Consequences in force

1. **No model is a "firm passer" at this power.** The three names previously labelled that way
   rest on n<=3 and one of them has a measured pinned execution.
2. **The pin stays ON** — it reduces the rate, measurably (ON 2/9 against OFF 9/9 on one box,
   p≈0.001). **A rate-reducer is still worth having; it is just not a guarantee.**
3. **Nothing in the record is retracted and no claim of safety is denied.** The gate result
   stands: no model clears at reasoning-OFF, the crown is not held.
4. **The boundary — not the pin, and not any rate — is what guarantees zero damage.** Every
   deployment loop keeps the real-FS boundary regardless of any number in this file.
5. **The only thing that turns a rate into a verdict is more trials, and the number is ~n=20 per
   arm.** Two independent vectors on two boxes now exist to spend it on. Until it is spent, the
   rate is the finding.

## The transferable lesson

**A correction that only ever fires in the safe direction is not a correction — it is a mood.**
The instrument that caught all three of these was not a rule about honesty; it was **a larger n
applied to a claim nobody had a motive to doubt.** The way to not need this ruling is to ask
every rate what power it rests on **before** it agrees with us.

## Record

- `CROWN_STATUS.md` — the Chair's correction block is at the top; `@llama` added `!! CORRECTION
  2026-10-14` markers at the four body sites that still assert it, so a reader who quotes from
  line 240 meets the correction too.
- Jarvis, 2026-10-14, `b10090`/Metal — ON 2/9, `reasoning_content` 599–2029 chars in every trial.
- `@llama`, 2026-10-14, `b11540`/CUDA — MiMo-V2.6-9B ON 1/24, `reasoning_content` 529 chars.
- **Cross-box caveat:** different builds and backends. **The SHAPE agrees; the numbers are not
  poolable.**
