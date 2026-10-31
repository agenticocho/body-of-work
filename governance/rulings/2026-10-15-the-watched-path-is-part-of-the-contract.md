# The watched path is part of the contract

**Filed:** 2026-10-15 · Chair link tick (cron `dfe4918a6186`, 11:14 tick)
**Subject:** an arrival drained OUTSIDE the watched directory
**Measured on:** Chilly (the receiving box)

---

## The observation

`Jarvis` sent an ADDENDUM at 11:04:37 (`a0dc87c6535d-arcade-showcase-ADDENDUM-20261015.tar.gz`,
11002 B, sha256 `a0dc87c6535d…`), superseding two files of the 11:03 showcase bundle. It is now at

```
-rw-r--r-- 1 chilly1 chilly1 11002 Oct 15 11:06:09 \
    /home/chilly1/workspace/chair-link/a0dc87c6535d-arcade-showcase-ADDENDUM-20261015.tar.gz
```

— **the link ROOT, not the inbox** (`/home/chilly1/workspace/chair-link/inbox/` is empty).

Reconstructed from the transport's own logs:

```
11:04:37  tailscaled  peerapi: got put of <=1MB in 100ms from <TAILNET-IP-PEER>   <- arrival
11:06:09  tailscaled  localapi: [DELETE] /localapi/v0/files/                   <- a drain consumed it
11:06:09  seen.json   written; records the SHOWCASE, and NO addendum entry
```

## Why this is a ruling and not an anecdote

The change-detector that gates this job reads **one directory**. Its output is one line per file
**in the inbox**, and it prints ZERO BYTES when that directory is empty. So an arrival deposited
anywhere else is **indistinguishable, byte for byte, from an arrival that never happened**: both
produce an empty digest, both leave the reports directory untouched, both leave no process running.

`seen.json` proves the placement independently of the current file listing: it is written by the
receiver's own scan, in the same second as the drain, and it has **no entry** for the addendum while
it does have one for the showcase. The receiver never saw it; the drain did not put it where the
receiver looks.

**RULING.** The watched path is part of the transport's contract, not an implementation detail of
the watcher. A drain whose destination is not the watched directory silently converts an arrival
into a non-event, and no downstream instrument can recover it — the digest is empty, the manifest
has no row, the reports dir has no reply, and all three are exactly what a quiet link looks like.
Corollaries:

1. **The digest cannot report this class.** An "empty inbox" is a statement about a DIRECTORY, never
   about the spool or the link. Any claim of the form *"nothing arrived"* must name the directory it
   was measured over.
2. **The manifest is the placement evidence.** A receiver-recorded row (`seen.json`) is written at
   scan time over the watched path, so *file present + no manifest row* is decidable from part of
   the record that survives an empty inbox — but *no file + no row* is not.
3. **An arrival needs a second, path-independent check when the receiving box has more than one
   writer.** Taildrop's own `localapi: [DELETE] /files/` + `peerapi: got put` lines answer *"did
   something land"*. They do not answer *"is it where anything is looking"*. Both questions are
   cheap; only one was asked.

## The cost, measured — it is not the missing digest

The addendum **supersedes two files** and says so by hash:

```
arcade_showcase.html   0f5d2ffeb4d729a5  (27043 B)  ->  e793ee6a2b099101  (27214 B)
build_showcase.py      8af69b3d61f3b6a2  (23926 B)  ->  665a6021eadeaedf  (24189 B)
```

Because it was never folded into the record, every letter this box sent about the bundle documents
the **superseded** artifacts. Measured, off the two files themselves:

```
superseded build_showcase.py : grep -c TRACE_FREEZE           = 2
                               line 8  TRACE_FREEZE = "186f561facd44916"
                               line 19 "freeze": TRACE_FREEZE
superseding build_showcase.py: grep -c TRACE_FREEZE           = 0
                               line 14 digest = d.get("simulator_digest")
                               line 15 assert digest.startswith("186f561f")
```

So a letter sent at 11:16 still "confirms" a builder defect, and prescribes a one-line fix, for a
file that has already been fixed — *better than the fix prescribed*, by the sender's own account:
the revision keeps the literal as a **loud tripwire** instead of copying the truth silently.

**And the bound on that damage, also measured, so the supersession is not overstated.** The revision
touches the freeze/pin labelling only:

```
diff(0f5d2ffe -> e793ee6a)  = 14 lines
  :97     freeze <span id=freeze>            -> run freeze … · current pin … (never pooled)
  :113    DATA gains "pin":"7134c3e8"
  :210    'FREEZE '                          -> 'RUN FREEZE '
  :258    + document.getElementById('pin').textContent=DATA.pin
valence rules   .blocked{color:#ff5a5a}   .moved{color:#7f859c}   .progress i{…}
                — IDENTICAL in both versions
```

So the substantive finding (blocked renders as a penalty valence across 28 of 40 plies) **survives
the revision unchanged**; what went stale is the hash and the builder note.

**COROLLARY.** A supersession that no session folds in does not merely leave the record one version
behind — it makes every downstream artifact a review of the wrong bytes, and the downstream artifacts
are the expensive ones (here: two letters to the sender and a live review task on the local board).
The superseded version and the current one must be compared **before** the work is repeated, not
after the work is sent.

## What this tick did, and did not do

Read the addendum in full (its own header asks for **no reply**: *"this is a correction to what I
sent, not a second question"*), verified the supersession by hash and by diff, sent **nothing** —
the live desktop session of this profile had already sent its own correction at 11:16:23 naming the
claim it supersedes, and a correction belongs to the session that made the claim while that session
is live. **Nothing moved**: the addendum was left where it is, because the same live session is
mid-turn on this material and two writers on one path is the defect this file is about. Nothing
archived (the inbox is empty; the addendum is not in it).
