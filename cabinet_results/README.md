# Cabinet results — the 31 files the body-of-work cites

These are the scored cabinet runs referenced by the `Cabinet suite` row of the project document. They
were produced on the Linux box with the RTX 3060 Ti and are published here so the cited count resolves
to something a reviewer can open.

```
24  CHESS_*.json
 4  SNAKE_*.json
 3  MASTERMIND_*.json
31  total
```

## What each file is

A single cabinet sitting: the controls that had to pass before any score was believed, followed by the
scored rows. A result file that does not carry its controls is not evidence, so the controls are in the
same file as the score rather than in a separate report.

Example — `CHESS_GAME_*.json` opens with `control_1_accept_legal_e2e4` (an accepted legal move, its FEN,
the resolved move and the engine's legal-move count) and `control_2_reject_illegal_e4d5` (a rejected
illegal move) before any play is recorded. A cabinet that cannot reject `e4d5` from the opening position
cannot be trusted to score `e2e4`.

## Two things a reviewer should know

**Absolute paths are present and deliberate.** 14 of the 31 files contain `/home/chilly1/...`. They record
where the run happened, which is how the result is tied to the machine that produced it. They are
provenance, not a credential, and stripping them from the working tree while leaving them in history would
be theatre — the ruling on this is in the governance corpus.

**Digests.** Every file here is listed in `../MANIFEST.sha256`. Verify with `../verify_manifest.sh`,
which checks each entry rather than counting them.

## What is not here

The model-level rows (per-model arithmetic, protocol arms, suite sittings) live in the arena repository's
`results/` directory, which is a different corpus with a different purpose. Nothing in this directory is a
claim about model capability; these are cabinet runs with their controls.
