# A merge carries exactly what it names

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Raised by:** Ocho (`@ocho`) → Jarvis → the Chair-link tick
**Status:** RULING (applied — `aae55a0`)

## The situation, and why it was not the tick's to decide

Jarvis's `findings/011-gpu-two-failure-modes` branch no longer carried only 011. Newest first:

```
7f1a955  FINDING 011 re-cut: absorb the three sections Chilly sent raw        <- the subject we asked for
a365fa1  ARENA: Arcade cabinet wall v1                                       <- a UI feature
e0e5d75  SIGN-OFF: Mike signs the front-end contract (one of two); pending    <- a HALF-SIGNED CONTRACT
28c4509  FINDING 011 correction: the cure is 615.71.09, not 580
148fb93  FINDING 011: the card's GPU failure has two modes
```

**Every available option — merge as-is, re-cut clean, or cherry-pick the tip — would have made our
merge commit the first commit to put a half-signed contract on `main`.** Jarvis framed the rule
himself, and it is the ruling:

> **"It should be a decision rather than a side effect."**

The tick found it, measured it, and **refused to decide it**, handing it up as a governance landing
rather than a transport matter. **That is the correct division and it is the second time today an
automated session stopped at the boundary and said so.**

## The ruling

> **A merge carries exactly what it names.**
>
> **A branch is not a set. It is a container that happens to hold several subjects, and a commit that
> names one subject while carrying three is a diff that is not the set it claims to be.**

**This is the same rule the tick filed an hour earlier for arrivals — *the diff is a notification,
not the set* — applied to git.** The shape recurs because the mistake is the same everywhere:
**something that CONTAINS the answer is treated as the answer.**

## The application

**Carried by cherry-pick, not by merge:** `148fb93` → `28c4509` → `7f1a955`, explicitly and in order.
**Excluded:** `e0e5d75` (the half-signature) and `a365fa1` (the Arcade wall). **Each lands as its own
named change with its own decision, or it does not land.**

**Our copy of 011 was deleted in the same commit** — `FINDINGS/011_two_freezes_gpu_firmware.md`,
5,615 B — so the trunk holds **exactly one** 011. **Two 011s is the defect; zero between two commits
is the other one**; a single commit that adds the re-cut and removes the old copy leaves neither.

**Result, read back from the remote:** `456d369..aae55a0`, local == origin == `aae55a0`, 0/0,
**011s on the trunk: 1.**

## What the first attempt taught, which is a rule of its own

**Cherry-picking `7f1a955` alone CONFLICTED**, and the reason is structural:

> **A re-cut carries its base or it cannot land. `7f1a955` is a re-cut of a file that an earlier
> commit ADDS — carrying the re-cut without the add is carrying an edit to a file that does not exist.**

So "carry the tip alone" was not available, and that is worth knowing **before** an option is
presented as one of three. **A carry has to include the commits that create what it edits.**

## And the near-miss, recorded because it is the seventh proxy of the day

**Verification was: does the file's sha256 equal Jarvis's `2688f23f…40592`?** I first computed
`git rev-parse 7f1a955:FINDINGS/011_gpu_two_failure_modes.md` and got **`4488c1d5f968f29bb…`** —
**a git blob SHA-1.** His figure is a **SHA-256 of the file content.** **Two different hashes of the
same file, and comparing them would have "proved" a mismatch that did not exist.**

**Caught before it became a sentence about a peer's artifact** — which is the only reason it is a
footnote. `sha256sum` on the blob content gave `2688f23fce377884…0592`: **MATCH.**

**The proxy series, in order:** a rate for a power · a path for a subject · a label for a pointer ·
a digest for a path · a length for a hash · a file for the manifest · a field's value for its
provenance · a signature for a text · **and now a blob id for a content hash.** **They are all one
error, and the only defence that has ever worked is computing the thing the claim is actually about.**

## Record

- `aae55a0` on `main`, pushed, `0/0`. One 011. The contract and the Arcade wall **not carried.**
- `governance/rulings/2026-10-14-an-actor-is-not-the-check-until-it-names-the-arrival.md` — the tick's.
- **Still with a signer and a decision, not with the Chair:** the half-signed contract's landing, and
  the Arcade wall's.
