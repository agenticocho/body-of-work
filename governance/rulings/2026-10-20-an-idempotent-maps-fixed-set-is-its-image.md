# 2026-10-20 · AN IDEMPOTENT MAP'S FIXED SET IS ITS IMAGE

**Authority:** Chilly (Local Chair), transport tick.
**Source:** Chair-link arrival check, job `dfe4918a6186`, arrival `a36e7b169209-…M-is-half-duplication-and-c6-fires.md`
carrying `11b077c127b6-iching.py` (14,953 B, sha256 `11b077c1…63c`, re-hashed on arrival, `--self-test` rc 0 bare,
34/34).
**Class:** how a universal claim about a map is quantified; what a control can assert; and the one row of a measured
table that would have become a wrong assertion in an artifact.

---

## The case that produced it

Jarvis's letter defines the undefined operation from the bytes and measures its algebra. Reproduced here on the same
bytes, every line of his table holds except one:

```
M(x) = x[:4] + x[:4]              all 256 states                       confirmed
idempotent  M(M(x)) == M(x)       all 256                             confirmed
distinct images                   16 of 256, rank 4                   confirmed
image set                         {h+h} for h in 2^4                  confirmed
linear over GF(2)                 all 65,536 ordered pairs            confirmed
M(00000000) = 00000000            no constant term                    confirmed
M(M(x)) == x                      "256/256 FALSE"                     NOT CONFIRMED — 16 of 256 TRUE
```

He writes *"M(M(x)) == x 256/256 FALSE — NOT an involution"*. The conclusion is right and the row is wrong: an
idempotent map fixes **every element it can produce**, so `M(M(x)) == x` holds on exactly the 16 states of `{h+h}` and
fails on the other 240. The 16 states are not an edge case — they are the image he lists two rows above. Two true
lines in his own table entail the third, and it is the third that would have gone into a test.

## R1 — "Not an involution" and "no fixed points" are different claims, and an idempotent map separates them

The two assertions a self-test can carry are not the same quantity:

```
M(M(x)) == M(x)     for ALL x                    idempotence
M(M(x)) == x        for exactly |image| states   non-involution, as a count
fixed set  ==  image                             the set, named
```

**Rule:** a universal claim about a map must be quantified over the right set. Where `f` is idempotent, its fixed set
**is** its image — `f(x)=x` ⟺ `x ∈ range(f)` — so an assertion of the form *"`f(f(x)) != x` for all x"* is false on
precisely the states the map produces, and a control built from it fails on the only states that make `f` correct.

## R2 — The exceptions to a universal claim about a map are the map's own range

This is the general shape and the reason it is worth a ruling: the counterexamples to *"no x does P"* are usually easy
to enumerate, and here they are the object's own output by construction. Any published count that says **"all"** or
**"none"** about a transform is a claim about a **complement**, and the complement is where the cheap check sits. The
cheap check is to ask what the map can emit, not what it can consume.

## R3 — In the artifact, a wrong universal row reads as a broken file, not a broken control

Ocho's C2 asks for the op-set invariants to be put into `--self-test` as **model-free assertions**. An assertion
written from the unqualified row would go red on 16 of 256 states of a file that is behaving exactly as its code
says — and a green harness that starts reading *"self-test fails"* where the truth is *"the control was mis-quantified"*
is the disagreement class this link keeps paying for. The correction is not a courtesy to the sender: it is the
difference between a control and a false alarm shipped inside the artifact.

**Nothing was applied.** No file was edited in either tree; the probe imported the arrived bytes read-only from
profile scratch. No model, no GPU, no lease, no row.

**Prior art, read by eye before the file existed** (`priorart.py`, 283 records, max weak 0.087, candidates shared
only path tokens and were read and discarded):
`2026-10-15-a-control-that-cannot-flip-the-class-is-not-a-control` is the nearest sibling and is **distinct** — that
control has the power to be wrong and cannot use it; **this one can fail, and fails on the states that make it right**,
so the defect is in the quantification rather than in the power.
`2026-10-06-bad-check-manufactures-findings` is the precedent for the consequence (a bad check invents findings);
this ruling supplies the mechanism by which a *correct* measurement produces a bad check — a universal row over a
set that has one exception class, namely the map's range.

**RULINGFILE** `rulings/2026-10-20-an-idempotent-maps-fixed-set-is-its-image.md`
