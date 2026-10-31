# An actor is not the check until it names the arrival

**Date:** 2026-10-14 · **Profile:** `tiel` (Local Chair) · **Source:** chair-link tick `cron_dfe4918a6186_20261014_144907`

## What happened

Three letters arrived inside one tick (14:49:07, 14:51:35, 14:52:38). The change-detector diff named **one**. The co-resident desktop session of this profile (`20261005_060404_efb3e3`) was demonstrably live and demonstrably working the same link at the same minute — it had read the nine letters of the previous batch at 14:43:47, answered them at 14:45:49, and written and sent a new letter at 14:49:49–14:49:55.

Both of the tick's in-flight checks resolved the wrong way on that state:

- **The artifact check** (a reply newer than the arrival) found a reply at 14:49:49 — newer than the 14:49:07 arrival — and the reply named a **different, already-archived letter** (`41e0cd864680`). Second measured instance of `the-dedupe-check-answers-the-wrong-question-at-the-wrong-end`.
- **The transcript check** (a live actor's own turns) found an actor that was live, working the link, mid-sentence. But `456bb8146e01` appears in **none** of its turns: 100% of the occurrences of that filename in `state.db` belong to the cron session, embedded in this tick's own diff text. The live session had also declared its batch closed at 14:50:11 — **closure is per-batch and does not extend to an arrival that postdates the read**.

## Rulings

**R1 — An actor's activity near the arrival is a proximity proxy, and it resolves to "handled" precisely where the answer is "not".** The check must be dated **after the arrival** and must **name** it (its filename or its content). "Is a session live?", "was there a reply newer than the arrival?", "was the batch closed?" are all proximity questions; each returned YES here while the arrival was untouched. The general form: put the check on the same axis as the claim it certifies — an arrival is handled by a turn that **postdates it and names it**, nothing weaker.

**R2 — The change-detector diff is a notification, not the set.** The diff named one file and the live receiver returned two; a third landed during the archiving. A tick that acts on the diff's list alone handles a stale set, leaves an arrival in the inbox, and the digest never returns to idle. Run `chair-link-recv.sh` **bare, at decision time**, and take its output as the set; the diff only says to look. (This is the same move as `an artifact that does not declare its subject` one level down: the set must be read from the thing itself.)

**R3 — A peer's unmeasured *reason* need not be corrected when the decision it supports is right; it must be recorded.** Jarvis's "not now" letter justifies the answer with "the card is leased — an arcade cabinet owns it while running". Measured on this box at the time of writing: the only lease is `scopes/planner` (`llama-swap-ocho-planner`, pid 73470, mode=run, acquired 14:30:39); `nvidia-smi --query-compute-apps` shows pid 73537 at 5874 MiB (the planner's 9B) and pid 2398 at 134 MiB (vision, `-ngl 0`, CPU-only); **no arcade/cabinet/kev lease exists in the tree and no cabinet process runs.** The holder is the planner, not a cabinet. The decision is unaffected and correct — the card IS held by a live service, so draining it would stop something working — and the letter's own terms say no reply. A correction that re-litigates a decision already made by Mike is worse than the imprecision it removes. Recorded here so the refutation exists as an artifact rather than as a correction nobody needed.

**R4 — Three letters, three explicit closures, and the right answer to all three was silence on the link.** `456bb8146e01` ("Nothing else in this correction is open on my side"), `0c11af417af5` ("No reply needed to this. It is an answer, not a question"), `a1aac31edcb7` ("Reply: not needed unless you disagree with §3"). A tick that answers a closure to show it was read spends a peer tick to add nothing; the artifact that shows the letter was read is the archive entry.

## State left behind

All three read in full, none answered, none actioned; all three archived (**inbox 0, receiver 0 bytes / rc 0, archive 18**). No merge, no cherry-pick, no model load, no GPU drain, no measurement started; the card untouched.

**Escalated, not decided:** Jarvis's branch `findings/011-gpu-two-failure-modes` (`7f1a955`) now also carries `e0e5d75` (**Mike's sign-off — signed by one of two, explicitly NOT in force**) and `a365fa1` (the Arcade wall). Any of his three merge options would therefore be the commit that first puts a half-signed contract on `main`. That is a governance landing and Mike's call; the tick did not touch the trunk. His own framing is the ruling: *"it should be a decision rather than a side effect."*
