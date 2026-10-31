# A removal in the diff is the archive side of a letter, not an arrival

**Filed:** 2026-10-14 (Chair link, tick at 15:00 PDT) · **Scope:** the chair-link change-detector and its archive

## What was measured

The gate's diff for this tick was `-456bb8146e01-…withdrawal-accepted…md` against a **zero-byte**
current output — a *removal*, not an arrival. The receiver was run at decision time: inbox `0` files,
`tailscale file get` drained nothing pending, `chair-link-recv.sh` **rc 0**, no `CHAIR-LINK-RECV-FAILED`.
The archive holds the name with its arrival hash intact:

```
456bb8146e019df82ea16af36beb03a78fe67de47a1bf39fa3cb23b36afbb472  archive/456bb8146e01-to_chilly_withdrawal-accepted-and-it-retires-one-of-my-instructions.md.1792014758
```

The hash equals the filename prefix, i.e. the archived bytes are the arrival, byte for byte. Archive
timestamps, decoded (`date -d @<suffix>`):

| archive entry | mtime (arrival) | suffix = archive time |
|---|---|---|
| `456bb8146e01…` | 14:49:07 | `.1792014758` = **14:52:38** |
| `0c11af417af5…` | 14:51 | `.1792014758` = **14:52:38** |
| `a1aac31edcb7…` | 14:52 | `.1792014970` = **14:56:10** |

The inbox directory mtime, `14:56:10`, is the last `--archive-handled` (the receiver `dst` is
`"<name>.<int(time.time())>"`). So the disappearance at 14:56:10 *is* the archival of the last of the
three letters the previous tick read — not a loss, not a second delivery gone missing.

## Rulings

**R1 — A change-detector diff is a difference of two SNAPSHOTS, so its change can point either way.**
An arrival and a removal are both "change detected", and the removal is the normal signature of a
handled letter. Read the diff as a set difference and nothing more; the question it cannot answer is
which direction the state moved, and it must never be read as a list of arrivals.

**R2 — A removed name is decidable only against the archive, and the name must carry its own hash.**
An inbox name vanished and no archive entry named it is a deletion — data loss. Vanished *and* present
in `archive/` as `<sha256-prefix>-<name>.<archive-epoch>` is handled. The gate, a length, and a
directory listing are all identical in both cases; the archive entry's own hash is the entire
difference. **A name that does not carry its arrival hash makes its own archival unverifiable.**

**R3 — The two timestamps on an archive entry answer two different questions and must not be conflated.**
`mtime` is the **arrival** (preserved by the move); the numeric **suffix is the archive moment**
(`int(time.time())` at `--archive-handled`). So `14:49:07` is when Jarvis's letter landed and
`14:52:38` is when we dealt with it — a lag of 3m31s on that name. Dating handling by the suffix and
the letter by the mtime is what lets "was it read before it was archived" be an arithmetic check
instead of a claim.

**R4 — A stored gate snapshot can lag the state it was taken from; run the receiver at decision time.**
The snapshot this tick diffed *against* still listed `456bb8146e01` as in the inbox although that name
had been archived at 14:52:38. The same rule as the previous tick's R2, now with the direction
reversed: the diff is a notification, never the set, and the live receiver run is the set.

**R5 — Silence remained the right answer on the link.** The recovered letter closes itself
("Nothing else in this correction is open on my side", "Reply: not needed unless you disagree with
§3"); a reply would spend a peer tick to add nothing, and the artifact showing it was read is the
archive entry — which is now the only place this tick's evidence lives. Nothing was re-archived:
re-archiving what another session archived is the duplicate this link forbids.

## State at close (15:00 PDT)

Inbox `0`; archive `18` entries, all hashes read back intact; receiver rc `0`, spool empty; the desktop
`tiel` session is live but on Ocho work (`bot_mode_dm.py … --profile-home …/ocho`); nothing on the box
was touched by this tick — no merge, no cherry-pick, no GPU load, no service drain, no reply sent.
Still with Mike, unchanged: the **merge decision** on Jarvis's `findings/011-gpu-two-failure-modes`
branch (it also carries `e0e5d75`, a sign-off explicitly not in force, and `a365fa1`), and the
**deferred ACE-Step measurement** ("Not now").
