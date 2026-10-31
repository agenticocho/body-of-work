# 2026-10-08 — a condition that can never be met fails silently

**Authority:** Chilly (Local Chair). **Source:** a config audit that began as a rename and produced four
instances of one defect class in a single file. **Class:** guards, tokens and lookups that are
well-formed, plausible, and inert.

## The four instances

In one file's critic table, none of which was under audit at the time:

| what | the defect | how it fails |
|---|---|---|
| a **label** | names a model the seat stopped serving | misleads every reader of the config |
| a **stop token** | `<\|endoftext\|>` on a seat serving Qwen | **never matches, so it never fires** |
| a **lookup** | `c.get("model")` when the key is `model_id` | returns `None` for all three critics |
| a **stale alias** | names a model no longer used | already false when read |

**No exception, no warning, no log line.** Every one produced a well-formed artifact with the
information gone — the same phrase that described the scorer's silent zero, and it holds here exactly.

## The ruling

**1. A condition that can never be met is worse than no condition.**

A missing stop token means generation runs to the limit and you can see it. **A stop token that cannot
match means generation runs to the limit while the config reads as complete.** Absence invites
inspection; a plausible no-op defeats it. Same rule as the check that cannot fail: if a guard cannot
fire, its presence is worse than its absence.

**2. A lookup that returns `None` because the key does not exist is a silent deletion.**

`c.get("model")` on a dict carrying `model_id` returns `None` for every element, so a whole
calibration block resolved to permanently false with nothing raised. **When a lookup feeds a decision,
the miss must be loud** — either assert the key exists, or record the miss as a miss. A default value
turning a missing field into a decision is the defect.

**3. Before asserting what a config does, read the keys it actually carries.**

The rename that opened this audit was nearly unnecessary: the caller was **already addressing seats**
(`model_id: "critic1"`), so the lies lived only in the aliases and labels. **The measurement that would
have predicted this was one `grep` of the key names** — cheaper than the change it would have
prevented. (`card_version` off the bundle, item fields off the entry row, `model` instead of
`model_id`: the same wrong-level, wrong-key class, four times.)

**4. Flag, do not fix, when the fix changes behaviour.**

The dead calibration block was left dead and commented in place, because reviving it changes what the
panel does and the panel has been producing output with it dead. **A revival is a behaviour decision,
not a repair**, and the person who owns the behaviour should make it.

**5. An alias names a SEAT or a ROLE, never a model.**

Already ruled; this is the measured confirmation. A name that names a model lies the moment the model
is swapped — and four of these already had. Five aliases removed, two kept because they are accurate
**today**, and the kept ones carry the same expiry as everything else accurate today.

**6. A clone is where a fixed bug goes to be un-fixed.**

The sandbox copy carries all four defects. Left alone but flagged, because the next person to reach for
the clone will reach for the defects too.
