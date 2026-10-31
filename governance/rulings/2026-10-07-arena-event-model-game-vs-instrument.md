# The Arena's event model: the game is the interface, and an instrument is not boring

**Date:** 2026-10-07 · **Author:** Chilly (Local Chair) · **Status:** RULING (product/design standard)

Set by Mike, corrected once by him, and reduced to checkable form here. Applies to every event in
the catalogue.

## 1. Every shipped event declares one of two classes

- **CONTEST** — has a **game**. The bundle carries the game's state. The audience watches the game.
- **INSTRUMENT** — **may not declare a game**. It must instead declare what it is **staged as**: the
  visible artifact of *its own* measurement.

**An INSTRUMENT declaring a game is the defect** — the referee in a costume. **A CONTEST that cannot
show its game's state is the other defect** — a skin over someone else's result.

## 2. The test: can a stranger reconstruct the game from the recorded bundle?

- **Yes** → the game *is* the measurement, and the visual is honest.
- **No** → decoration. The same defect as a count carried as a literal, one layer up.

**Mechanically checkable, and it must be enforced by a test, not a principle:** the catalogue holds a
`game` field and a `game_state_in_bundle` field. `game` set + empty state = fail. A positive control
confirms the check fires when a game name is reintroduced with nothing behind it. *(Model:
`test_doc_counts.py`.)*

**Why a test rather than a rule:** at 55 events, "cleverly naming tests to match games" stops being an
incident and becomes a production line. The current card carries `metaphor: CHESS` on a
tool-selection task about the weather in Reykjavik — proof the drift is already happening.

## 3. Choose the game from the measurement math, not the reverse

| sport shape | measurement property | consequence |
|---|---|---|
| **Olympic / absolute** (100m, long jump) | same bar for everyone, measured independently | **the Arena's native shape** — use it |
| **Combat / head-to-head** (boxing, MMA) | **pairing-dependent** — the score depends on who you drew | needs Elo/round-robin → **a different event class with its own criteria** |
| **Team / relay** | the unit is the team; footprint is the **sum** of members | already correct in the catalogue |

**Head-to-head is the most spectacular and the least comparable.** It is the sport version of the
moving weigh-in baseline: two entrants measured against different opponents instead of different
machines. Both directions of that error produce a number that looks like a measurement.

**Noted:** the Arena already speaks combat sport — weight classes (Featherweight → Heavyweight),
belts (white → red), and divisions assigned by *measured* footprint. The metaphor system is half-built
and internally consistent.

## 4. CORRECTION — an instrument is not the boring half (Mike, same day)

Tiel first proposed: *"INSTRUMENT — deliberately unwatchable, no game, and that is correct."*
**Wrong.** Mike's counterexample: **a weigh-in for a UFC title fight is an instrument, and it is one of
the most-watched events on the card.**

**The error was bundling two independent axes:** what an event *does* (contest vs instrument) and what
the audience *gets* (spectacle vs dry). **Being an instrument does not make something boring; not
being staged does.**

**And the line moves to a more precise place: the defect is not "instrument as spectacle" — it is
"instrument as a FAKE CONTEST."** A weigh-in is honest: it shows a weighing, and never pretends to be
a fight.

### The weigh-in recipe, all five already present in the Arena

1. a number everyone understands
2. a hard threshold with a consequence
3. a scheduled, public moment
4. a **legible way to fail** — the miss *is* the drama
5. side-by-side comparison

`gpu_free_gb_at_weigh_in` · divisions by measured footprint · a real threshold (exceed your VRAM and
the model does not run) · and the miss is already documented: **a 2B model swinging 0.00 → 0.33 → 0.67
→ 0.33 → 0.67 with its weights never changing**, every swing from a config flag. **A fighter missing
weight because someone left a grammar file switched on.**

## 5. Consequence worth acting on

**For the Arena's actual audience the weigh-in may be better content than the fight.** The fight
answers *"which model is better."* The weigh-in answers *"can this thing run on my desk at all"* —
the question everyone with a GPU has, and the Arena's own thesis televised: *VRAM is the absolute
bottleneck for the democratization of AI.*

**So League I should not be written off as the plumbing half.** On the audience evidence it may be the
lead product, and it has been filed as infrastructure by both agents working the project.

**Ownership:** event design and criteria are Ocho's; the standards above are the Chair's to hold. The
run-state protocol (`arena-run-state.sh`) is a weigh-in that does not yet know it is a show.
