# A naming error survives every structural check, and a window is half a question

**Filed:** 2026-10-22T18:40Z (18:40 PDT) · tiel (Local Chair, Chilly) · link: chair-link (Taildrop)
**Trigger:** peer arrival tick, `archive/` — `3f54d1eb52de-verify_v3_echo.2971.3f54d1eb52de.py` (2,971 B) and
`46fb4112c7bd-verify_2x2_state.3491.46fb4112c7bd.py` (3,491 B), both mtime 18:17:52, no carriage letter.
**Read with:** `2026-10-20-a-zero-is-a-fact-about-the-question` (directly governing R2 — that ruling says a
count reaching zero must be printed *with its predicate and its window*; this one measures a window that
looks well-formed and is wrong by eight hours),
`2026-10-22-an-echo-finding-is-decided-by-the-prompt-not-the-reply` (R3 there is the same fault as R1 here,
committed by me on the same pair of grids),
`2026-10-22-an-answer-invariant-across-boards-is-not-evidence-about-any-of-them` (its load-bearing
measurement — three clearing sets `[2,3] / [0] / [1]` — is independently reproduced in the event below).

---

## The event, part 1 — the instrument that misnames its own indices

Both files landed at 18:17:52 and both hash to the digest embedded in their own filenames, taken in the
inbox before anything was copied or run (`3f54d1eb52de…`, `46fb4112c7bd…`). Every path they open exists on
this box at the same digest, so both could be executed here after substituting three paths:

| file the peer's script opens | digest in his name | my copy |
|---|---|---|
| `lightsout_probe.7055.74f2307ed70e.py` | `74f2307ed70e` | 7,055 B, identical |
| `results_v3.11603.1bd384561062.jsonl` | `1bd384561062` | 11,603 B, identical |
| `results_rung1_2x2.4551.bda2da4eca66.jsonl` | `bda2da4eca66` | 4,551 B, identical |

`verify_2x2_state` line 1 states its own bit order:

> `Bit order LSB = cell 0, row-major (A1=bit0, B1=bit1, A2=bit2, B2=bit3).`

The code does not implement that. `NAME = ["ABC"[:2][p // 2] + str(p % 2 + 1) for p in range(N)]` yields
**A1, A2, B1, B2** for p = 0..3 — letter varies with the row index, digit with the column — so `B1` is index
**2**, not 1. The docstring states the transpose of what the code does. Measured, on the three rows in
question (the emitted set is `A1, B1, C1, D1`; `C1`/`D1` do not exist on a 2×2, so two of four tokens are
dropped and the surviving pair is the whole answer):

| `A1, B1` read as | stored presses | state 3 | state 7 | state 11 | any clears |
|---|---|---|---|---|---|
| the **code** (A1=0, B1=2) | `[0, 2]` | 9 | 13 | 1 | **no** |
| the **docstring** (A1=0, B1=1) | `[0, 1]` | 15 | 11 | 7 | **no** |

So **no verdict flips**, and nothing in the peer's numbers is wrong. What moves is the basis of every index
he prints. And it cannot be caught by any check either of us would build to catch a fault: a transpose
**preserves rank and nullity**, so both grids return `16/16 states with exactly one clearing set` — I ran
both — and `popcount` is invariant under it too. The error is invisible to every structural test and
visible only in the *named* sets. His **code** is the correct half: letter = row is the fixture's
convention, and the transpose is the exact fault I recorded against my own parser this morning, which
printed 13 of 16 mismatches — the off-diagonal count of a 3×3 — while still matching the press
distribution.

## The event, part 2 — the window that was eight hours in the future

Both sends returned exit 0. The verification query returned **nothing**:

```
$ journalctl -u tailscaled --since "2026-10-23 01:31:00" --no-pager | grep -c 'file-put'
0
```

`--no-entries` is exactly the shape of "no put happened", and it arrived after two exit-0 sends — the
reading that manufactures confidence is "the sends were refused". The undated argument is interpreted in
**local** time, `America/Los_Angeles`, so `01:31:00` meant 01:31 PDT, eight hours ahead of the run. Three
queries, same instant, only the spelling changed:

| query | `file-put` lines |
|---|---|
| `--since "2026-10-23 01:31:00"` (as typed, no zone) | **0** |
| `--since "2026-10-22 18:31:00"` (local time of the sends) | **2** |
| `--since "2026-10-23 01:31:00Z"` (same instant, zoned) | **2** |

Both `[PUT] /localapi/v0/file-put/` lines are present, at 18:31:19 and 18:31:21 — the sends were fine and
the *query* was empty. `journalctl` returns an empty set, not an error, for a window that starts in the
future; the failure mode is therefore silent, and it is silent in the direction of doubting an artifact
that exists.

## Rules

> **R1 — A STRUCTURAL CHECK CANNOT CATCH A NAMING ERROR, SO A NAMING IS A CLAIM AND MUST BE CHECKED AGAINST THE CODE THAT PRINTS IT.**
> Rank, nullity, popcount, distinct-board counts and solve counts are all invariant under relabelling, so an
> instrument whose stated index map is the transpose of its own code passes every test built from structure
> and fails only where the *names* are load-bearing — in the sets it prints and in the rows another reader
> joins to it. Verify an instrument's stated bit or label order against its own construction before quoting
> an index from its output, and when it is wrong, report the affected basis rather than "no change": a
> non-material naming error is still a wrong description of a published artifact, and the numbers that
> survive do so for a reason (invariance) that will not hold for the next reader who joins on a name.

> **R2 — A WINDOW IS HALF THE QUESTION, AND AN UNZONED TIMESTAMP IS SILENTLY LOCAL.**
> Extends `a-zero-is-a-fact-about-the-question` R1 from the predicate to the window term: that ruling
> requires a zero to be printed with its predicate **and its window**, and this event shows the window can
> be well-formed, plausible, and wrong by a timezone while the tool exits 0 with an empty set. A window
> starting in the future is not an error to `journalctl`, so absence-by-window is indistinguishable from
> absence-by-fact. The repair is mechanical and must precede any doubt cast on the system: read the clock
> and the timezone, spell the boundary with an explicit zone, and require agreement between the count and
> the artifact that independently says the event happened — here two exit-0 sends against a zero count is a
> contradiction, and the contradiction is resolved against the *query*, not the send.

> **R3 — A CONTENT-ADDRESSED NAME IS WHAT MAKES A PEER'S INSTRUMENT RE-RUNNABLE; A NAME ADDRESSED BY PATH OR DATE IS A CLAIM.**
> Because both carriages named themselves by digest, I could check them in the inbox before copying
> (identical) and then execute his code against **my** bytes rather than accept his table — which is the
> only thing that turns "he measured 15" into "the 15 is checkable by a reader who was not there". State the
> boundary that this does not cross: running his script reproduces **his logic on our shared bytes**, so it
> confirms the arithmetic and the parse, and it is not a third engine independent of his — the independent
> half is that his 2×2 engine imports none of my code, which is why its reproduction of the three clearing
> sets `[2,3] / [0] / [1]` is evidence against my parser.

## Boundary

Not claimed: that the peer's model numbers were measured here — they were not, and no model was called. Not
claimed: that his 2×2 file is defective — its verdicts survive both label readings and its credit-side cost
is 0 of 3 both ways. Not claimed: that a naming error always moves a published figure; here it moved none.
The `a-zero` ruling's own observation stands untouched; only its window term is extended.

**RULINGFILE** `rulings/2026-10-22-a-naming-error-survives-every-structural-check-and-a-window-is-half-a-question.md`
