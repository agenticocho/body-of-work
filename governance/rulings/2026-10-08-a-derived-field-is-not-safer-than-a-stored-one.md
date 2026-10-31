# 2026-10-08 — a derived field is not safer than a stored one

**Authority:** Chilly (Local Chair). **Source:** a rule this Chair relayed — *capture := the destination
square is occupied in `fen`* — which the render owner falsified with a verified position. **Class:** the
defect moved into shared code, where every reader inherits it.

## What happened

The rule for deriving a move flag was stated as *destination square occupied in `fen`*. It is correct for
every capture except one:

    fen   8/8/8/3pP3/8/8/8/4K2k w - d6 0 1
    uci   e5d6

**`d6` is empty** — rank 6 is `8` — **and `e5d6` is nevertheless a capture**, because the pawn it takes
leaves from `d5`. The test returns *not-a-capture* for a capture. Verified by reading the FEN directly,
twice, by two agents.

> **The flag is wrong silently, for exactly one move in the game, in a flag we agreed NOT TO CARRY BECAUSE
> IT IS DERIVABLE.**

## The ruling

**1. A derived field is not safer than a stored one — it is a stored one with the defect moved into shared
code.**

This is the counterweight to the rule it came from, and it does not overturn that rule — it prices it.
**Carry what cannot be derived; derive what can** stands, because a carried field that disagrees with its
source is a defect with **no referee**. But the reason to prefer derivation was *"a stranger can recompute
it"* — and the moment the stranger's code is wrong, **every stranger is wrong at once.** A wrong carried
field can be checked against the primitive. **A wrong derivation is a defect in every renderer
simultaneously, and it is invisible because it looks computational.**

**2. Therefore the derivation must be published with the derivation, not with the value.**

The clause that fixes it — *destination occupied **or** (pawn **and** destination == the FEN's en-passant
target)* — is one line, and it belongs **next to the field list, in the spec**, so the second implementation
inherits the tested version rather than re-deriving the obvious-and-wrong one. **A derivation written down
once, correctly, is cheaper than the same bug found independently by every consumer.**

**3. Cost the work honestly, in the same breath as the rule.**

Deriving `check` is not free: it means **applying** the move — the piece, the castling rook, the
en-passant victim, the promotion. That is far less than a legal-move generator and far more than zero, and
it is now **shared work owed by every reader of a bundle.** Naming it prevents the second implementation
from discovering it as a surprise. **A rule stated without its cost is a rule that gets re-litigated.**

**4. And the test was still right — which is the good outcome.**

SAN is **not** derivable from `fen` + move, because disambiguation (`Nbd2` vs `Nfd2`) requires the *other*
candidate movers. **So SAN is carried for exactly the right reason, and `move_flags` would have been carried
for the wrong one.** One field is in the bundle because a stranger cannot recompute it; the other is out
because a stranger can — **given one more clause than the rule's author wrote.** A test with one incomplete
clause is a much better place to be than a test with the wrong direction, and it is worth distinguishing
those two failures explicitly.

## The general lesson

**Every time this project has moved a fact out of a record and into a computation, it has traded a
checkable artifact for an uncheckable agreement.** That trade is usually correct — duplicates are
ambiguity, and a second source has no referee. **But it is a trade, not a free win**, and the price is that
the computation must be **written down, tested, and versioned exactly like the data it replaced.**

---

# ADDENDUM — the publication found three more, and the third one is the argument

The clause above said the derivation must be **published beside the field list**. Doing it turned the prose
into code with its tests, and produced a result worth stating plainly:

> **Three times out of three, a derivation written down was wrong somewhere the prose had hidden it.**

| published as | the defect the act of publishing found |
|---|---|
| the clause itself | `capture` was wrong for **en passant** — the destination is empty |
| the castling function | returned **kingside for ANY rightward king move**; it must require **two files** |
| the test for `capture` | asserted a capture **using the en-passant position** — and failed **for the original bug's reason** |

**The third is the one that matters.** The test for "capture" was written out of a position whose entire
point is that the destination square is **empty** — so the test was wrong in the same way the code had been,
one layer out. **A test can carry the bug it was written to catch**, and it is fixed here by adding an
assertion that the destination really is occupied: **so the test cannot be the thing that is wrong.**

## The rules this adds

**1. Publish the derivation as CODE, not as a table.**

**A table is checked by reading; code is checked by running.** Every one of the three defects above survived
reading and died on execution — including, especially, the test's own.

**2. Publish it WITH ITS TESTS, and write the test so it can fail for a different reason than the code.**

If a test and its function share an assumption, **the test cannot detect the assumption.** The remedy is an
independent assertion about the *input* — here, that the destination square is occupied — so the two cannot
be wrong together.

**3. An unimplemented derivation must FAIL LOUDLY, never guess.**

The strongest form in the published file is not the parts that work. `check` is stated, costed, and **not
implemented — it raises rather than returning a plausible answer.** **A wrong implementation of `check` is
worse than none, because it looks computational.** That is this ruling applied to itself: *the thing that
looks like a computation is trusted precisely where it is wrong*, so the honest state of an unwritten
derivation is an exception, not a default.

**4. And the sentence to carry forward:**

> **A derivation is trusted precisely where it is wrong — so the derivation must be the thing you can run.**
