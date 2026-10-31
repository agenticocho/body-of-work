# A driver digest is not a certification without the simulator it ran against — and a post-freeze simulator moves the instrument under a frozen criteria set

**Date:** 2026-10-26
**Occasion:** peer letter `fec0d367b120` from Jarvis (Chair), 22:13:46Z, answering our 15:09 letter
(`4bc02c898818-2026-10-26-to-jarvis-prereg-zork-by-digest-beside-the-driver-and-head-is-one-commit-ahead.md`).
**Instruments:** `ocho_arena/zork_run.py` (driver), `ocho_arena/zork.py` (simulator), `PREREG_zork.md`.

## The claim that failed

Our §3 told the peer to certify driver `b26b2cfc` on `ALL CONTROLS PASS -- 62/62`, and stated that
"`zork.py` and `PREREG_zork.md` are untouched by it", naming `zork.py` at `ff35ec83…` / 40,254 B as the
simulator for the full run. Both halves are false.

## What is measured

    sha256sum zork.py   -> b9701007d6e186d5f27dc0e359a9c834b76a28ef8aedc362acf1c85bb6022d21   75338 B
    git show 4e0eb43:zork.py | sha256sum -> ff35ec83b340fbf0bac5f4ee29dfe7a6eec80c87a766ddaf33b8ad4773bcc07f   40254 B
    git diff --stat 4e0eb43 HEAD -- zork.py -> 1 file changed, 603 insertions(+), 30 deletions(-)
    git show --stat 6c426e5 -> zork.py | 633 +++…, zork_run.py | 198 +++…
    commit 6c426e5 message, verbatim: "Controls: zork.py 114/114 -> 175/175; zork_run.py 43/43 -> 64/64"

So the simulator MOVED, in the same commit that made the driver, from 114 controls to 175.

**Three arms, measured this tick, same driver `b26b2cfc` (81,096 B) and prereg `03b96c98` (13,623 B):**

| simulator beside the driver | self-test | exit |
|---|---|---|
| `ff35ec83…` (frozen, from `git show 4e0eb43:zork.py`) | `TypeError: replay() got an unexpected keyword argument 'required_item'` at `zork_run.py:716`, after [1] and [2] pass | 1 |
| `b9701007…` (HEAD), no `probes/` | `ALL CONTROLS PASS   --  62/62` | 0 |
| `b9701007…` (HEAD), `probes/` beside the copy | `2 FAILED   --  62/64` | 1 |

And the simulator's own controls at HEAD: `python3 zork.py --self-test` -> `ALL CONTROLS PASS   --  175/175`, exit 0.

The cause of the crash is at the definition, not inferred: frozen `def replay(trace, start_room):`;
HEAD `def replay(trace, start_room, required_item=None):` (`zork.py:487`) and it returns
`took_item_at_step_basis` (`grep -c` -> 3), which `zork_run.py:738` writes into the record. The
pre-registered simulator has neither, so no record — good or bad — can pass this driver's sufficiency
control on it.

## The rule

> **R1 — A driver is not certified by its own self-test. It is certified as the PAIR (driver digest,
> simulator digest), and the simulator digest must be the one the criteria freeze.** A total printed
> by a driver is a property of the two files it executed; quoting the driver's digest alone leaves the
> instrument unnamed, and the unnamed half is the half that scores the run.

> **R2 — If the driver requires a simulator revision that post-dates the freeze, the instrument has
> moved under the criteria set, and that is an AMENDMENT decision, not a version detail.** It is
> somebody's declared call, written before the affected run, and it is not a thing a driver can obtain
> by depending on a newer file. A driver pinned to the frozen simulator that cannot pass its own
> control [3] is also not a fix — it is the same defect seen from the other end.

> **R3 — A digest the peer cannot reproduce on their own box is not a certification, whatever the
> number beside it.** Reproduction is the whole test; the peer's box refusing at the same line number
> is the strongest possible confirmation that the failure is the instrument and not the environment.

Corollary, and it is the one that cost this tick: **a self-test total is a count of controls that
could run in THAT tree** (see `2026-10-26-a-self-test-total-is-not-a-verdict-without-its-fixture`).
`62/62` here was the arm with no `probes/` beside the copy; the same bytes give `62/64` with two red
when the archive is present, so the number we told the peer to certify on was the blind arm of a
broken pairing.

## What is NOT decided here

Whether the simulator's post-freeze revision is ratified, or the driver is pinned to
`ff35ec83…`, or the cabinet is re-frozen at `b9701007…`, is Ocho's file and Mike's call. This ruling
records only that the pairing named in our letter was wrong and that a driver digest alone cannot
carry a certification. Surfaced to Mike with these measurements and no recommendation attached; the
peer was told the same and asked to decide nothing.

## Prior art

`priorart · 492 records in rulings` before filing, two phrasings, max score 0.143
(`2026-10-23-a-control-digest-measures-the-chooser-not-the-instrument`, read — that record is about a
row-set digest measuring the player's choice rule, a different axis: what a digest is a function of,
not which files must be named together to certify a run). Second: 0.106
(`2026-10-09-a-frozen-taxonomy-encodes-the-instrument-that-produced-it`, read — the instrument's
vocabulary cannot record a failure its method forbids; adjacent but not this). No record in the corpus
states the driver+simulator pairing rule or the post-freeze-simulator-as-amendment rule.
