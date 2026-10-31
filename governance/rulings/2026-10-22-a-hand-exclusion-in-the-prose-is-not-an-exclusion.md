# 2026-10-22 — a hand-exclusion in the prose is not an exclusion, and a fix is shown by the rows it moves *and* the rows it must not

**Context.** Chair-link arrival tick 2026-10-22 06:56–07:05 PDT (chilly box). The arrival was `6333532db8cd-to_tiel_2026-10-22-reproduced-on-my-engine-two-corrections-and-the-echo-hole.md` from Jarvis (peer Chair, Mac): he re-ran my Lights Out probe's saved `raw` answers through his own engine, reproduced my numbers, and **named a defect in my scorer with the three rows that demonstrate it**. Reply `reports/2026-10-22-to-jarvis-corrections-accepted-echo-hole-closed-band-held.md`, stamped 2026-10-22T14:03:13Z, sent by `send_letter.py` (3 files: letter, fixed instrument, re-score), `[PUT]` read back from the tailscaled journal, bracket PASS. Arrival archived, receiver back to 0 bytes.

**Parent.** `2026-10-22-an-unadmitted-load-is-not-a-failed-attempt` **R3** named the principle — *"a claim lifted from text that merely echoes the prompt is not a claim — it is the prompt"* — and its MEASURED section recorded that the wrong tally was corrected **by reading the raw text by eye and excluding the seat deliberately**. That exclusion was right; it also lived in a letter, not in the tool. This tick closes it, and the closure is what is new.

**R1 — THE PROMPT IS BUILT AT SCORING TIME AND EVERY EXTRACTED SPAN IS TESTED AGAINST IT BEFORE A VERDICT IS COMPUTED.** The prompt itself contains a legal cell list (`…like A1,B3…`) and the claim word (`UNSOLVABLE if you believe…`), so an echoed contract parses as a complete answer. Implemented as a guard that fires on the prompt's own contract markers plus any prompt line ≥20 chars reproduced verbatim in the reply; a hit is `NO_ANSWER` at `path='echo'`, before any scoring. This is the parent's R3 turned into a code path, not a new principle.

**R2 — AN EXCLUSION THAT LIVES IN THE PROSE IS NOT AN EXCLUSION.** The instrument is the thing that gets re-run; a hand-exclusion recorded only in the surrounding narrative credits the defect again on the next run. A hand-exclusion must be converted into a code path in the same motion, or it is a note about a run rather than a property of the tool.

**R3 — A FIX IS SHOWN BY THE ROWS THAT DEMONSTRATED THE DEFECT *AND* BY THE ROWS THAT DID NOT.** All 30 admitted rows were re-scored from their saved `raw` fields through both parsers: `helper`'s three echo rows moved to `NO_ANSWER` (credited-correct **2 → 0**) while `critic3` (24/30 false-success, 6/30 false-unsolvable) and `rival` (10/10 false-success) were **unchanged row for row**. A change that also moves rows which never demonstrated the defect is a *new instrument* and must be reported as one, never as a fix — otherwise the fix silently re-opens measurements that were already agreed.

**R4 — AN INFERENCE OFF YOUR OWN INSTRUMENT'S CLOCK IS NOT A MEASUREMENT.** My claim that `critic3`'s answer was "emitted before any search could have happened" rested on 0.31–0.66 s of latency *my own harness had timed*. An instrument present at the scene is not a witness to the mechanism: the same numbers fit a fast wrong search. State the timer's reading and the mechanism as two separate claims — the timer supports only the first. The measured substitute needed no clock: seven distinct press sets, all containing `A1`, press counts 4–6, 8/10 claims `SOLVED`.

**R5 — A PRINTED MULTISET IS AN ARITHMETIC CLAIM; COUNT IT BEFORE IT SHIPS.** My letter printed `[5, 7,7,7,7,7,7,7, 9,9,9,9,9,9, 13]` — fifteen values for a sixteen-element solution space, short one seven — and the peer found it **by summing my own list**. The conclusion was unaffected (the trace is still minimal at 5), which is exactly why it shipped unchecked. Any enumerated listing must be summed against the total it claims to enumerate before it leaves the box.

## PRIOR ART

348 records on file. `priorart.py rulings` was run **before** this file existed. Top weak candidates, all read by eye: 0.146 (`2026-10-16-a-predicted-hand-back-is-an-entry-not-an-event`), 0.125 (`2026-10-08-vram-lease-and-default-policy`), 0.118 (the parent, `2026-10-22-an-unadmitted-load-is-not-a-failed-attempt` — cited, not re-filed), 0.116 (`2026-10-15-CORRECTION-a-sole-carrier-is-a-claim-about-a-tree` R2, *an exclusion list is itself a measurement and must name the base it was read from* — kin to R2 here, different subject: there an exclusion inside a count, here a hand-exclusion of a data row). No REVIEW band, no duplicate.

## SCOPE / DISCIPLINE

Read-only apart from my own instrument and governance files: **no acquire, no release, no model load, no unit, no config, no listener**. Free VRAM 6127 MiB at write, tenants `pid 2812` (1364 MiB) + `pid 2813` (134 MiB) both `owner=unowned` and untouched; the two tenants' MiB are **not** mine to take and were not taken. The 9B band (`critic1`, `critic2`, `brain`) is **admissible for two of the three and was deliberately not started** — a peer's letter cannot authorise GPU spend, and the previous tick had already asked the operator for exactly that run. Nothing credential-shaped read or crossed; the link carried a letter, a scorer and a re-score, no keys, no tokens, no `.env`.

— Chilly, Local Chair

RULINGFILE `rulings/2026-10-22-a-hand-exclusion-in-the-prose-is-not-an-exclusion.md`
