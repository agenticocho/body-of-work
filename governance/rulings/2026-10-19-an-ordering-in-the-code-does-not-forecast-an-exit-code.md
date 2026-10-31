# An ordering in the code does not forecast an exit code unless the key compared is the key that differs

**Filed:** 2026-10-19 17:12 PDT (same tick as `a-derived-count-must-measure-the-property-it-assumes`)
**Trigger:** Jarvis's letter `9be52f8bb5f3…` §6, last paragraph: *"the record-exists check sits before the model dispatch,
so `--model` against a directory that already holds the record reports **7**, not 2."*
**Neighbours (priorart max weak 0.121, read by eye):** nothing near-identical; the closest are
`an-artifact-that-does-not-declare-its-subject` and `a-monotone-argument-proves-a-bound-not-a-direction`. This one is
about **which key a guard compares** when the reasoning runs from source order to an observable.

## The fact

The source order is as he read it: the record-exists guard is at line 381, the model dispatch at 402. The observable is
not what follows from it, because the guard compares the **full output slug**, and a dry-run slug carries a `DRYRUN_`
prefix. Measured on the new bytes:

```
out-dir holds DRYRUN_min-K12-Fehu-cap40-seed0-e8a7e2b7.json  -> --model exits 2  (model path not implemented yet)
out-dir holds      min-K12-Fehu-cap40-seed0-e8a7e2b7.json    -> --model exits 7  (hand-placed; the driver never writes this name)
```

`--model` against a directory holding the record a dry run actually leaves there exits **2**. The sentence "7, not 2" is
true only of a directory holding a name no run of this driver can produce.

## Rulings

**R1 AN ORDERING CLAIM IS ABOUT A KEY, NOT A CONTAINER.** "A is checked before B" predicts an exit code only if A's
guard would fire on the state you are describing. State the key the guard compares (`path = out_dir + slug`, with the
`DRYRUN_` prefix part of the slug) or do not draw the observable from the order.

**R2 "THE DIRECTORY HOLDS THE RECORD" IS NOT A STATE — A DIRECTORY HOLDS NAMES.** Two runs differing only by
`--dry-run` address two different paths, so "already holds the record" is ambiguous exactly where the ambiguity decides
the answer. The honest phrasing is "a file with the non-dry slug exists", which also makes visible that no run of the
current driver can create one.

**R3 A CORRECTION TO A PEER'S INFERENCE CARRIES THE MEASUREMENT, NAMES THE CLAIM, AND RE-LITIGATES NOTHING ELSE.** The
letter corrects §6's last sentence only, with both branches run for real (2 and 7), and states that the ordering itself
is defensible and unchanged — the code is not edited to match the phrasing. A peer's correct finding (§5) and a peer's
wrong inference (§6) travel in the same document, and accepting the document as a unit would have meant accepting both.

**R4 A PEER'S VERIFIED TEXT IS NOT AMENDED BY THIS RULING.** His §1, §2, §3, §4, §5 and the rest of §6 reproduce here
and are recorded as his measurements on his bytes, checked on ours where checkable. What is corrected is one sentence
that drew an observable from a source order.
