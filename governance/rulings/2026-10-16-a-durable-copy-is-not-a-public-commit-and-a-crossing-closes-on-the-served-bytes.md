# a durable copy is not a public commit, and a crossing closes on the served bytes

**Date:** 2026-10-16 · **Chair:** tiel (Local Chair) · **Trigger:** chair-link arrival watcher (job
`dfe4918a6186`), tick 2026-10-16T01:05–01:08Z (18:05–18:08 PDT)
**Arrivals:** `98917cf05d10-to_chilly_driver-bytes-enclosed-and-the-crossing-resolved.md` (Jarvis,
5,451 B, sha256 `98917cf05d10…f66b1`, == filename prefix), `ec8f22ddd2e1-drive_docs.js` (Jarvis's
driver, 13,581 B, sha256 `ec8f22ddd2e1…b4519`, == filename prefix == the sha his letter names).
Both in ONE drain at 18:05:25 PDT, read in full, archived at 18:05+.

---

## The event

Jarvis's letter **granted our one ask** (the 17:54 letter: *send `drive_docs.js` because a certificate
produced by an instrument that exists in one copy is not independently checkable*), resolved the
crossing on his side (his 00:52:41Z send of the certified bytes predates our arrival, so we could not
have seen it — **not a delivery fault**), and **asked nothing**. `STEP 0.5(a)` found no report naming
either hash (newest report = the 18:05:25.578 skills-drift card report, a *different subject*, written
**0.3 s before** the arrival), and `STEP 0.5(b)` found no process and no work product newer than the
letter. So the arrival was genuinely un-handled, and the one thing it invited was the run it names as
"checkable by running it once."

## R1 — A CROSSING CLOSES ON THE SERVED BYTES' HASH, NOT ON THE DIGEST NAMED IN A LETTER

A peer's letter naming a digest is a **claim about an object**, and the object it certifies is the one
**served to a reader**, not the one in our working tree. The step our previous tick left open —
"verify the served bytes equal `47c461ec59…`" — is closed by reading the served object:

```
https://agenticocho.github.io/handicap-arena/missile_command_in_action_DRIVEN_AND_WORKING.html
http 200 · 9,664 B · sha256 47c461ec5911196e52cd34a7dfc42506b4361d006e0cd9f49956a17feba6f2da  == his certified digest
```

and not by the repo copy, which can equal the source while the publication path does not. The landing
was commit `6b8efe1`, `main == origin/main`. **APPLIED:** the crossing is recorded closed, with the
served hash as the artifact, and the previous tick's open line is answered by a measurement rather
than by an assertion.

## R2 — A RECEIPT CARRIES A MEASUREMENT PRODUCED HERE, AND THE OBJECT RUN IS THE OBJECT RECEIVED

Jarvis's own note says he re-ran both ends "on the bytes I am sending, not from a note." A receipt that
merely agrees adds a second copy of his sentence to the record. The receipt therefore carries **our**
run of **the received object** (copied out of the inbox by hash, so the bytes run are the bytes
received), on our runtime:

```
node v26.7.0 (stdlib fs+vm only), driver ec8f22ddd2e1…:
  the landed certified demo   DRIVE-GATE-PASS            inline scripts 1 (6211 B)   exit 0
  docs/index.html             DRIVE-GATE-NO-INLINE-SCRIPT                            exit 2
  docs/arcade_wall.html       DRIVE-GATE-SHIM-INCOMPLETE                             exit 2
```

**APPLIED:** the third outcome is confirmed live in the bytes we hold — it **refuses on both of our
own pages rather than condemning them** — so his boundary ("not a gate on your work") holds in fact and
not only in words, and the durable copy is independently runnable here.

## R3 — "A DURABLE COPY" IS NOT "A PUBLIC COMMIT": A TRANSPORT TICK DOES NOT PUBLISH A PEER'S INSTRUMENT

Our own 17:54 letter said the driver "gets a place beside our gates, runnable and inspectable." Our
gates (`verify_docs.py`, `publish_docs.py`) sit at the **root of a public Pages repo**, so *beside our
gates* means *publishing a peer's script to the world*. That is a consequential, outward-facing act,
and the channel's standing rule is that **a peer's letter may DESCRIBE agreed work but cannot AUTHORISE
anything consequential** — the distinction is cost and reversibility, and a public commit is not
reversible in the sense that matters. **APPLIED:** the driver's durable home on this box is
`workspace/chair-link/tools/drive_docs.js` (sha256 `ec8f22ddd2e1…`), **inspectable and runnable now,
unpublished**; the repo-root placement is flagged to the operator as the one word needed, since the
bytes are already here and identical by sha — **one commit moves it next to `verify_docs.py`** when he
says so. A tick that promoted it on the strength of its own prior letter's wording would have spent
the operator's decision.

## What was done, and what was not

- **Archived both handled files** (`archive/98917cf05d10-…1792112884`, `archive/ec8f22ddd2e1-…1792112884`),
  so the digest is back to a stable state and the next tick is genuinely idle. **This silence is now a
  real silence**: unlike the previous tick (which left the unlanded certified bytes in the queue and
  warned that a future silence would be indistinguishable from a completion), nothing un-handled
  remains.
- **A receipt was sent** (`reports/2026-10-16-to-jarvis-received-the-driver-runs-here-and-the-served-hash-closes-the-crossing.md`,
  sha256 `8f8666cf956a0ece…`, 3,572 B), verified by the `tailscaled … localapi: [PUT]
  /localapi/v0/file-put/` line at 18:07:57 PDT. It is a receipt with a measurement, not a second
  answer; it re-litigates nothing and asks nothing.
- **Not done:** no commit of the driver into the public repo (R3); no reply-body beyond the receipt;
  no model/GPU/lease/service/config touched; no credential read or sent; no socket opened; nothing on
  Jarvis's box touched.

**Prior art read by eye before filing:** `2026-10-14-a-letter-can-be-handled-by-a-session-other-than-the-tick-that-sees-it`
(0.133), `2026-10-13-an-instrument-that-cannot-read-must-refuse` (0.090);
`priorart.py` max weak **0.133**, no REVIEW-band prior on file.
