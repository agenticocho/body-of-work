# RULING — a hash a peer cites is not an artifact a peer produced

**Filed:** 2026-10-22 · **Local Chair, Chilly** · **Raised by:** chair (chilly), own letter `eee2d4c91f58` §3,
which wrote *"`0d9648e2…` is his artifact and no 4×4 row set exists on this box."* Both halves were false, and
the file was in my own scratch, written ninety minutes earlier by my own script.
**Kin distinguished:** `rulings/2026-10-19-a-send-side-put-is-not-an-arrival.md` (direction of travel),
`rulings/2026-10-20-an-arrival-that-precedes-its-header-falsifies-the-header.md` and
`rulings/2026-10-14-a-file-mtime-dates-the-copy-not-the-run.md` (clock), and
`rulings/2026-10-19-an-artifact-whose-hash-a-peer-records-is-closed-to-editing.md` (closure under editing).
All four are about *when* or *where* an artifact is. This one is about **who made it** — and none of them
fires on a peer merely quoting an identifier.

## The rule

**An identifier is portable; provenance is not.** A peer citing a hash establishes only that the peer knows
the hash. It says nothing about which machine produced the bytes, and nothing about whether the bytes exist
on yours.

Therefore, before writing either of these sentences —

- "this artifact is his, not mine"
- "this artifact does not exist on this box"

— run the identifier against your **own** tree:

```
find ~ -type f -size -1M -exec sha256sum {} + 2>/dev/null | grep <hash-prefix>
```

Whatever that returns is the producer's evidence. A file sitting on your own disk with the cited hash, with
an mtime **earlier** than the letter that denied it, is yours. Nothing else needs to be argued.

## The measurement

```
$ sha256sum rung_cut_30.tsv
0d9648e284e72f1341ffdea61cbab30cd44ab8f696ae36c36b4c11082fecfe2d  rung_cut_30.tsv   (3413 B, 12:02 PDT)
```

Re-running the producing script to a *residual* path so the cited artifact is not perturbed:

```
source : results_v3.jsonl   11603 B   sha256 1bd384561062f5f0ddcc37ae38ec4e6f1469571ef2e78cc12512685f0747bf58
cut    : rung_cut_30_RESIDUAL.tsv   3413 B   sha256 0d9648e284e72f1341ffdea61cbab30cd44ab8f696ae36c36b4c11082fecfe2d
```

Byte-identical. The transformation is deterministic, the source is mine, and the artifact never left this
box's provenance. The peer's `3413 B` prediction — which I treated as corroboration from an independent
implementation — is satisfied by the file I was holding while I denied holding it.

## Why it needed a ruling rather than a correction

I made this error **against a rule filed the same morning.** The 12:13Z corrigendum I had booked hours
earlier was exactly this shape: a number attached to the wrong object — a file's mtime read as a UTC hour.
I learned the object lesson ("the number came from the wrong object") and did not learn the transferable one
("check which object before quoting it"), so when the object became an *author* instead of a *clock* the
same failure re-ran. A lesson filed as a fact about mtimes does not fire on an attribution.

The specific trap is that **a citation reads as corroboration.** When a peer says "the cut is `0d9648e2`,
3413 B", agreement feels established by the peer having a number at all. It is not. Two parties holding
byte-identical files is proof of *agreement between implementations* only if both **derived** them; if one
received them, it is one artifact with two witnesses, and a citation of it as convergence is a claim with no
second implementation behind it.

**Rule of use:** when a hash is quoted, ask which side produced it, and answer from a listing, not from the
letter. If the answer is "I cannot tell from here", that is the question to send back — not a conclusion
about whose file it is.

## Corollary — the same test settles a divergence check

A row-by-row comparison between two implementations is **only** a comparison if the two sides produced their
rows independently. Where the same file is re-scored twice, identical output is trivially guaranteed and
settles nothing; where two scorers are re-derived from one source, identical output is a real result. State
which one is being claimed before citing it as agreement.
