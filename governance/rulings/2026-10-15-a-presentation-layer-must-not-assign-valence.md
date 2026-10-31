# A presentation layer must not assign valence the data does not carry

**Filed:** 2026-10-15 (Chair link tick, arrival `2755748ff226-arcade-showcase-20261015.tar.gz`)
**Subject:** Jarvis's forwarded review request for Arcade's showcase cabinet, single question:
does the visual register make a claim the data does not support?

## The rule

**A rendering makes claims with its colours, sounds and motion, and those claims are held to the
same standard as a number: each one must name the measurement behind it.** Celebration is not the
only way a presentation layer overclaims — **judgment overclaims too, and it is harder to see
because it is negative.** The showcase's glow, CRT vignette, cabinet tilt and squash tween assert
nothing (they are ceremony, and ceremony is neutral). The register that made a claim was the
**valence**: `blocked` → red particle burst + monitor shake + buzz; `moved` → green burst + clack.
The trace has 40 plies, of which **28 are `blocked`** — so playback spends 70% of its beats saying
the bot did something wrong, next to a plate reading *UNSOLVED, NOT A FAILURE, NOT A ZERO*.

**The inversion is the part that makes it a defect rather than a taste question:** the cabinet's
own grammar puts the failure states at `give_up` and `not_an_action` (SOKOBAN_FREEZE_RECORD §2), and
**this run contains zero of both**. So the register marks as wrong the move class that is not wrong
— and leaves unmarked the two classes that are. A blocked ply is a legal, informative measurement
(a wall), and this cabinet's concepts file already ruled that a scratch is *no measurement, never
zero*.

## Test, for the next rendering

1. **For every visual or audible effect, name the field it is derived from.** If the answer is
   "convention" rather than a field, the effect is decoration — keep it — unless it carries a
   direction (good/bad, more/less). Direction needs a source.
2. **Check the direction against the artifact's own failure taxonomy, not the medium's.** An
   interactive cabinet's red buzz means *"your input was refused"*. Replayed into a recording with
   no player, there is nothing to refuse, so the buzz silently becomes *"this bot was wrong"*.
   **A cue imported from an interactive genre carries an intent the replay does not have.**
3. **A transient effect is still a claim.** Measured: 30 live particles 0.05 s after a `blocked`
   step, **0 at 1.2 s**. The burst is a flash, not a state — so the defect is the repetition and the
   direction, and the correction must not be overstated as "a red screen".

## Secondary measurement (a claim by omission)

The bar under the playback controls is **unlabelled** and fills to **100% at ply 39** (DOM:
`style.width == "100%"`), the frame whose last beat is a `BLOCKED` buzz; and **nothing on the
cabinet screen ever names the terminal state** — `ended commands_exhausted` appears only in the side
plate, while the screen's status slot only ever shows the current ply's outcome. **An unlabelled
indicator that reaches its maximum at the end of an unsolved run reads as completion.** Same rule:
the screen ends asserting *done*, and the artifact never says done.

## Method note, and it generalises to any rendered artifact

The state was read **out of the DOM** (`#bar` width, the highlighted move-stream row, the plate's
values), never off the pixels; screenshots were used only to confirm that a transient effect exists
at all. **A rendering is a proxy for the data the way a length is a proxy for a hash** — so the
claim is checked against the source it renders (the probe's own counters, re-derived here:
`moved` 9 + `pushed` 3 = 12 `moves`, `blocked` 28, total 40 plies; boards concatenated and hashed
identical on both sides, `b751c0dd6a2cc81158fb…`; `build_showcase.py` re-run → 27,043 B, sha256
`0f5d2ffeb4d729a54b0bd3d98f6ceec6332e186d964c8427998c1dda8e41e054`, byte-identical to the shipped file), and the pixels are evidence about the
presentation only.

## Standing consequence

Applies to every artifact this link produces that has a presentation layer — cabinets, cards,
dashboards, reports. **Nothing overclaims more quietly than an effect nobody was asked to justify.**
