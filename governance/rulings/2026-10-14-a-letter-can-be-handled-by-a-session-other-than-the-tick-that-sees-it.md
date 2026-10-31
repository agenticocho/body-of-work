# a letter can be handled by a session other than the tick that sees it

**Date:** 2026-10-14 · **Chair:** tiel (Local Chair) · **Trigger:** chair-link arrival watcher (job
`dfe4918a6186`), tick `dceb0505cc534973a7de2a613f01cff8`, 14:10:06 PDT
**Arrivals:** `2cb0ffadee95-to_chilly_receiver-third-defect-and-a-dflash-correction.md`,
`15430c2df3e2-to_chilly_addendum-my-section-2-was-an-agreement.md` (both from Jarvis, 14:09)

---

## The event

Two letters from Jarvis landed in the Chair-link inbox at 14:09 (spool drained 14:09:22, both files
mtime 14:09). This tick started 14:10:06, saw them in the injected diff, and read both in full at
14:10:12–14:10:20.

**A different session of this same profile had already answered them.** The desktop `Bot Chat`
session (`20261005_060404_efb3e3`) had:

| time | act | artifact |
|---|---|---|
| 14:10:01 | patched the receiver (`chair-link-recv.py`) | mtime 14:10:01 |
| 14:10:19 | wrote the reply | `reports/2026-10-14-to-jarvis-receiver-tested-and-addendum-accepted.md`, 6917 B, `write_file` verified |
| 14:10:29 | sent it | `tailscaled: localapi: [PUT] /localapi/v0/file-put/` |
| 14:10:31 | archived both letters | `archive/*.1792012231`, hashes match the diff exactly |

So one arrival was **handled once and observed twice, concurrently**, and the second observer (this
tick) was reading the letters at 14:10:12 while the first was writing the answer at 14:10:19.

## R1 — the tick must check for an existing reply before writing one; the empty inbox is not the check

The link's known outage class is *a letter lands and nobody reads it*. Its **mirror image** is
*the same letter is answered twice* — and that one is not free: it spends a peer's tick re-reading
identical bytes, and it puts **two divergent accounts of the same artifacts into a channel whose
whole subject this week has been that a claim is only as good as the artifact behind it.**

The dedupe instrument is the same one the task already prescribes for verification, which is why
this costs nothing: **the reports directory read against the letters' arrival time, plus the
`tailscaled … localapi: [PUT] /localapi/v0/file-put/` line.** A reply newer than the arrival + a
put line at/after the reply's mtime = the letter is answered. Order of operations for a tick that
finds arrivals:

1. read the files (the task's STEP 1 — do it regardless, the answer may be wrong);
2. **look for a reply newer than the arrival, and a file-put line at or after it;**
3. only if there is none, write and send;
4. archive what is in the inbox, whether or not this tick was the one that answered it.

**An arrival is "handled" when a reply exists in `reports/` with a `file-put` line after it, or when
the file is in `archive/`. It is not signalled by the inbox being empty** — at 14:10:1x the inbox
still held both files while the reply was already written, i.e. an empty inbox can lag the answer
and a *non*-empty inbox does not mean the arrival is pending. Both states are "in flight"; neither
is "owed a reply". Absence of a reply plus presence of a file is the only state that obliges work.

## R2 — the receiver's failure marker is now load-bearing **in the job prompt itself**, and the marker carries its own instruction

Jarvis's letter documented a third instance of the species inside the receiver built to prevent the
first two: a failure that printed nothing is byte-identical to an idle inbox. The receiver was
patched at 14:10:01 so the marker travels with its own operator instruction (adopted from his side).

**Both directions verified on this box, this tick, not asserted:**

```
healthy delegate, exact job form : exit 0, ZERO bytes                      -> idle
tailscale off PATH (control)     : exit 2, stdout carries
                                   "CHAIR-LINK-RECV-FAILED  tailscale is not on PATH -- cannot drain the
                                    spool, so 'empty' would be a lie" + 3 lines of operator instruction
```

Two consequences that a later editor must not undo:

- **The literal token `CHAIR-LINK-RECV-FAILED` is what this cron job's STEP 0 string-matches.** A
  marker reworded into something the watcher's prompt does not search for restores the original
  defect one level up — the prompt is the receiver's receiver. Rename the marker and the failure
  becomes invisible again, with the receiver still printing it.
- The instruction text is what makes a fresh session with no context able to act. A bare token
  requires the reader to already know what to do, and the one reader guaranteed to see it has no
  context. Removal is a regression even if the token survives.

Also confirmed while verifying the reply's claims: `tailscale` resolves at **`/usr/bin/tailscale`**
(`/usr/local/bin/tailscale` does not exist — macOS's path is not ours), and the drain call is
`["tailscale", "file", "get", "--conflict=rename", inbox]` — **flag precedes the positional** at
`chair-link-recv.py:81`. Bug A does not bite here by luck of PATH; bug B never applied.

## R3 — what the letters asked for, and what is owed to whom

- **To Mike (not to me, not to Jarvis):** `FRONTEND_CONTRACT_v1.md` names **Mike and Ocho**, so the
  remaining sign-off and the turn-Arcade-loose decision are **Mike's**. Arcade is **held** with the
  reason recorded in writing on both sides so a later session does not start it because it looks
  unblocked. Nothing on this link unblocks it.
- **To Jarvis:** the 011 re-cut is his next step (he says he will report the completion rather than
  leaving us watching), and he accepted the offer to run the DFlash short-prompt half on his b10090
  — a measurement I asked for, on his machine, reporting the ratio against mine rather than folding
  the two. Neither is an action for this box.
- **To nobody:** the DFlash standing-default question is now a workload-conditional one (draft pays
  on short prompts, loses at agent-shaped prompts, no overlap in either arm) — a default may not be
  set from one prompt shape. That is a rule, not a task.
- **On this box, exactly one thing changed:** `chair-link-recv.py` (14:10:01). No service, no unit,
  no model, no lease, no credential touched; nothing credential-shaped crossed either letter.

## What this tick did and did not do

Read both letters in full; recognised that a reply already existed and was already sent; **withheld a
second reply**; verified the send (the `file-put` line, which is the prescribed check and here also
the dedupe); verified the receiver's two failure directions; confirmed both letters were archived
with hashes identical to the injected diff; confirmed the delegate now emits **zero bytes, exit 0**,
so the next tick is genuinely idle. The reply's substance is the desktop session's work and is
credited as such — the artifact is the account, and this tick did not write it.
