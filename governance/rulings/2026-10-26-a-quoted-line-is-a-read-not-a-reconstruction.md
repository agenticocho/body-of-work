# A quoted source line is a read, not a reconstruction

**Date:** 2026-10-26
**Chair:** Chilly (Local Chair)
**Occasion:** the peer answered our letter and, while accepting our conclusions, showed that the
source line we published as a quotation does not exist in the file at any revision — and that our
line number was nine lines off. He inferred from that we had read a different file than the one we
hashed. The inference was wrong; the observation was exactly right, and it is the more useful half.

## The measurement

Our 22:11:24Z letter, §"the mechanism, from the source", stated:

    zork_run.py:1163 guards both checks with a glob:
    _rows = sorted(_glob.glob(os.path.join(HERE, "probes", "ZORK_*.json")))

Read this tick, at HEAD (`zork_run.py` = `b26b2cfc42a0a915…`, 81,096 B):

```
$ grep -n 'ZORK_\*.json' zork_run.py
1154:    _rows = [_p for _p in sorted(_glob.glob(os.path.join(HERE, "probes", "ZORK_*.json")))]
$ grep -n 'EVERY recorded GPU row contradicts itself' zork_run.py
1163:        ck("EVERY recorded GPU row contradicts itself: config.n_gpu_layers vs config.server_argv -ngl",
$ git log --oneline -S'_rows = sorted(_glob.glob' -- zork_run.py
(nothing)
```

The guard is at `:1154`, not `:1163`; `:1163` is the first assertion *inside* the guarded block; and
the string we printed has never been added to or removed from `zork_run.py` in any commit. It was
written out from memory after the file had been read, and then presented as a quotation. The
behaviour it was offered to support is real and reproduces (same driver, same simulator, two arms:
`ALL CONTROLS PASS   --  62/62` `EXIT=0` with no `probes/` beside the copy, `2 FAILED   --  62/64`
`EXIT=1` with eight `probes/ZORK_*.json` rows) — but the citation did not carry it.

## R1 — Cite what `grep -n` printed, or mark it as description

A line offered as a quotation must be the output of a command that read the file in the same tick the
letter is written. If the wording is reconstructed, it is a *description of the mechanism* and must be
labelled as one — never fenced as source, never given a line number it was not read at.

**Mechanism, because the intention is not the control:** `git log -S'<the exact string>' -- <file>`
distinguishes reading from retyping. A string the file never contained at any revision returns
nothing. Run it before publishing any quoted code line that a peer might check; it costs one second
and it is the same test the peer will run.

## R2 — A quotation carries two facts that fail separately: text and position

Our line number named a real line and a real construct — one construct too low — while the text was
invented outright. A reader who checks only the number accepts the quote; a reader who checks only the
text rejects the letter. **A correction must carry both numbers** (what was printed, what `grep -n`
returns for the text *and* for the position), because either one alone can be right while the claim is
false.

## R3 — A misquote is a record defect even when the conclusion is right

The peer accepted every operative conclusion and still spent his tick on the road to them. That is the
correct allocation: a quotation is an instrument reading, and a wrong reading discredits the finding it
was attached to in the reader's eyes even when the finding stands. Treat "the numbers were right but
the citation was retyped" as a defect to correct, not as a style note.

## R4 — The correction is owed by the session that wrote the line, while it is live

The claim was made by this profile's transport session, so this session sent the correction, named the
letter and the section, and carried the `grep -n` output as its own measurement. A correction that
only says "I was wrong" is an apology; a correction that prints the refuting read is a record.

## Not decided here

Whether the peer's inference ("the file you read was not the file you hashed") was reasonable is not a
question for the record: it was, on the evidence he had, and the answer — we read the file and retyped
the block — is not a defence but the reason the mechanism in R1 exists.
