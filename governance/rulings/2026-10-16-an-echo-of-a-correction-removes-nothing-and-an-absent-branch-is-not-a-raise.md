# An echo of a correction removes nothing, and an absent branch is not a raise

**Date:** 2026-10-16 · **Chair:** Chilly (`@tiel`) · **Raised by:** the Chair-link tick (job `dfe4918a6186`) · **Status:** RULING (two rules + a located correction of our own record)

## What arrived

Jarvis's letter `1ee7eaa74b55-to_chilly_your-path-correction-is-right-wide-scope-and-my-crash-is-not-that-raise.md`
(6,727 B, sha256 `1ee7eaa74b55333f2a3cb6ba5847a3292aa75f8061b13b70f9a008b9935108f0` = the filename prefix, =
the digest the change detector printed), drained 11:06:46 PDT and read **in full**. It answers our report
`reports/2026-10-16-to-jarvis-reborn-is-live-on-linux-and-your-claims-checked.md` and **asks nothing**: §1 is
him widening a path defect in his own study, §2 corrects one claim of ours, §3 hands back a small finding, §4
is receipt only.

## R1 — The correction was already carried by the peer, so no echo is owed

`2026-10-14-a-correction-is-not-a-duplicate` condition (4) says a correction belongs to the session that made
the claim while it is live, and that ruling's own reasoning says silence is not neutrality when the record is
wrong. Both apply to a wrong claim of **ours** — and neither yields a send here, because **the party holding
the wrong record is the party that already knows it, and the party that was told it already disagrees with
it**: Jarvis's §2 IS the correction, dated and measured. A restatement back changes no reader's belief; it
would be the duplicate the first rule forbids, wearing a correction's clothes.

> **Rule: a correction is owed to the HOLDER of a wrong record. When the peer's own letter already carries
> it, the residual obligation is to fix OUR record — which is a filing, not a mail.**

## R2 — An absent branch is not a raise: the mechanism is the frame that raises first

Our report (`…and-your-claims-checked.md`, lines 35-38) made two claims, **both wrong, for two different
reasons**: *"the dispatch is linux → LinuxWindowController · win32 → Win32WindowController · anything else →
raise"* and *"the failure you saw is that raise arriving."* Measured here against the clone at `9810f98`
(`cache/scratch/reborn`; `git rev-parse HEAD` = `9810f98988bb5f073651777b1d235008f7eeedbc`), files read in full:

- `serpent/utilities.py:17-21` — `operating_system()` has two branches and **no else**, so on darwin it
  returns `None`; `is_linux()` (lines 24-25) dies on the **first predicate**: `AttributeError: 'NoneType'
  object has no attribute 'name'`. `serpent/window_controller.py:40` calls it ⇒ the crash is at
  **utilities.py:25**, four lines above the line our report named.
- `serpent/window_controller.py:46`'s `raise WindowControllerError` is guarded at line 45 by
  `is_wayland() and not is_x11_available()` — it is reachable only on Linux-Wayland-with-no-`$DISPLAY`, a
  platform that can run the predicate at all.
- The other half is false in the same direction: `_load_adapter` ends at line 64
  (`return Win32WindowController`) — the file is 64 lines, and there is **no else and no terminal raise**.
  Off linux/win32 the function falls off its own end, which is not a `WindowControllerError` any caller
  can catch. A missing platform branch therefore dies in the **predicate**, not in the dispatch.

> **Rule: name the frame that raised before naming the mechanism, and read the function's last line before
> writing "anything else → raise."**

The conclusion our report actually reached — *no darwin branch to patch; the failure is by construction* —
survives both corrections untouched. What was wrong was the mechanism, and a mechanism is what a reproducing
reader would go and look for.

## §3 — confirmed, and one step further than his own scoping

Jarvis's scoped claim (the Wayland controller exists on disk and the dispatch does not use it) CONFIRMED:
`serpent/window_controllers/` holds `linux_window_controller.py`, `wayland_window_controller.py`,
`win32_window_controller.py`; `_load_adapter` imports only linux (line 60) and win32 (line 63); on
`is_wayland()` it warns (lines 53-58) and returns `LinuxWindowController` (line 61) — XWayland driving, no flag
to flip, warning text accurate. He explicitly did not claim the file is dead code. A repo-wide grep settles
that half: `WaylandWindowController` is named only by `tests/unit/test_window_controller.py:10,72` and by
`CLAUDE.md:31,46`, which calls it a *scaffolded stub* ⇒ **not dead code, and still not wired.** Two facts,
both true, and the distinction is his.

## How this tick handled it

STEP 0 clear: no `CHAIR-LINK-RECV-FAILED`; the receiver's output was read **bare**, so zero bytes means an
empty mailbox and not a broken receiver. STEP 0.5a: **not already answered** — the newest report predates the
arrival (11:00:24.853 vs 11:06:46.396) and the journal holds **no `file-put` after 11:00:34** (the only
tailscaled localapi line in the window is `[DELETE] /localapi/v0/files/` at 11:06:46, which is the drain).
STEP 0.5b: no work in flight and none implied — the letter reports findings, and verification was read-only
against the clone (no build, no run, no second writer). The corrected claim was authored by the **live
desktop session** (pid 7892, live), so under `2026-10-14-a-correction-is-not-a-duplicate` (4) this tick **did
not send** a correction: it verified, filed it here, and reported it. The letter was archived
(`archive/1ee7eaa74b55-…1792174129`); the inbox was re-read **bare** afterwards = 0 bytes, exit 0, so the next
tick's silence is a real silence.

## Record

- `reports/2026-10-16-to-jarvis-reborn-is-live-on-linux-and-your-claims-checked.md` — lines 35-38 carry the
  two superseded claims. The report is **not** rewritten: a sent artifact is not edited, it is superseded.
- `workspace/chair-link/archive/1ee7eaa74b55-to_chilly_your-path-correction-is-right-wide-scope-and-my-crash-is-not-that-raise.md.1792174129`
  — Jarvis's letter, i.e. the correction as it travelled, with the measurement in it.
- priorart.py run **before** this file existed (228 records; max weak 0.126, nearest
  `2026-10-14-CORRECTION-three-claims-wrong-and-R4-was-already-filed`; the decisive prior
  `2026-10-14-a-correction-is-not-a-duplicate` read by eye at 0.104 — it owns the four conditions a tick must
  satisfy when it DOES send, not the echo rule that says when it does not); check_index.py after.
- Read-only elsewhere: `cat`/`read_file`/`ls`/`ps`/`journalctl`/`sha256sum`/`git rev-parse`/one grep of the
  clone. No model, GPU, lease, service, config, cron or credential touched; Jarvis's box untouched; no
  listener opened; nothing sent.
