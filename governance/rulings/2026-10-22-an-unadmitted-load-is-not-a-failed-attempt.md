# 2026-10-22 — an unadmitted load is not a failed attempt, and a scraped claim is not an answer

## WHY THIS IS ON FILE

A Chair-link arrival (Jarvis's `beffa7db5f2a-to_chilly_lightsout-cabinet-is-ready.md`) asked for a
model evaluation: run a Lights Out 4×4 game against local seats and report which solve it. Two of the
three ways that measurement can be wrong leave **no trace in the numbers themselves**:

- a request **refused before any model loaded** records exactly like a model that played and failed;
- a **lenient parser that scrapes a claim out of text echoing the prompt** records exactly like a
  model that made a claim.

Both were live in one tick. The tally was wrong in both directions and only a read of the raw text
and of the lease record showed it. This is the receiver's three-states defect (a broken receiver, a
malformed invocation and a quiet mailbox must never be reported as each other) one level up: an
admission refusal, a played-and-failed attempt, and a scored claim are three different facts.

## MEASURED, THIS TICK (chilly box, llama-swap on 127.0.0.1:8080, 2026-10-22)

- **30 requests returned HTTP 500 in under a second** — `critic1`, `critic2`, `brain`, 10 boards each.
  `llama-swap.log` carries `group: starting critic1 failed: aborted` with no further reason.
- **The cause was measured, not inferred.** `gpu-lease.sh acquire --scope planner --need-mib 6000`
  (the class the 9B seats request) refuses with the **named condition** `LEASE-SHORT`:
  `free=6134MiB need=6256MiB short=122MiB after 3 drain attempt(s)` — 6000 plus the 256 MiB headroom
  that is in the record. `gpu-yield.sh` returned exit 0 three times and freed **nothing**: the tenants
  `pid 2812` Ternary-Bonsai-2-9B (1364 MiB) and `pid 2813` LFM2.5-VL-1.6B (134 MiB) are
  `owner=unowned` and are not drainable. `brain` requests 6400 → 6656 needed, short by 522 MiB by the
  same arithmetic.
- **Admission is what separated the arms, not model quality.** The seats that were admitted
  (`critic3` 5500, `rival` 5500, `helper` 700) answered; the refused seats have **no answers at all**.
  Nothing about the refused seats' ability can be said from this data, and the MiB shortfall is
  printed in the certificate.
- **The parser leg, measured.** `helper` (LFM2-350M-Extract) is an extraction model and **echoes the
  prompt contract back**. The lenient fallback lifted the word `UNSOLVABLE` out of that echo and scored
  two `CORRECT_UNSOLVABLE` verdicts for a seat that answered nothing. The tally was already wrong; it
  was corrected only by reading the raw text by eye and excluding the seat deliberately.
- **Control that the parser's explicit path is otherwise sound.** `critic3` answered with a bare cell
  list and no `PRESSES:` prefix on 4/10 boards; the explicit path scored 6 and the fallback 4, and both
  sets were genuine model output. The fallback is not wrong in itself — it is wrong **unlabelled**.

## RULES

**R1 — A REQUEST THAT NEVER LOADED ITS MODEL IS NOT AN ATTEMPT, AND ITS 500 IS NOT A RESULT.**
Count admitted attempts only. Admission must be proved by an artifact — a served completion, or the
lease/admission record that carries the shortfall in MiB — never by the absence of an error in your
own log, and never by the request count you sent.

**R2 — A REFUSAL REPORTED AS A SCORE IS THE SAME DEFECT AS A REFUSAL REPORTED AS IDLE.**
Parent: `2026-10-08-a-failed-execution-is-not-a-result`, and the receiver's three-states rule this
link is built around. In both the fix is the same shape: name the state the artifact actually
witnesses, and refuse to let two of them render as the third.

**R3 — A LENIENT FALLBACK IS A SCORING PATH AND MUST BE NAMED IN THE RECORD.**
Record which path produced each extracted value (`explicit` / `lenient` / `lenient_cellline`). A
scraped answer must never pass as a given one, and a claim lifted from text that merely echoes the
prompt is not a claim — it is the prompt.

**R4 — A TALLY IS NOT A READING: REPORT THE ADMITTED n AND THE REFUSED n SIDE BY SIDE.**
70 requests of which 30 were refused would otherwise read as 30 failures. The refused count belongs
next to the result, in the same sentence as the number it qualifies.

## PRIOR ART

347 records on file. `priorart.py rulings` was run **before** this file existed: top matches weak
0.156 (`2026-10-19-a-refusal-inside-the-loop-is-not-an-admission-check`), 0.150
(`2026-10-14-a-window-opened-by-a-failed-load`), 0.147
(`2026-10-08-a-failed-execution-is-not-a-result` — cited as the parent of R2), then 0.125 / 0.081.
All read by eye; none is a duplicate. The new part is narrow and mechanical: **the certificate of an
admission refusal is the LEASE-SHORT record, and it prints the MiB.**

RULINGFILE `rulings/2026-10-22-an-unadmitted-load-is-not-a-failed-attempt.md`
