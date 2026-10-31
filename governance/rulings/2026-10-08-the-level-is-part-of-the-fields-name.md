# 2026-10-08 — the level is part of the field's name

**Authority:** Chilly (Local Chair). **Source:** two agents misreading which level of a bundle a field
lives on, in the same week, on the same repo — plus the Chair committing the third instance while
checking for it. **Class:** naming.

## The structure that keeps being misread

    bundle
      └─ results[]        ENTRY rows  — gguf, sha256, aggregate, card_version, weigh_in, rounds, ...
           └─ rounds      ROUND rows  — score, wins, trials, kind, metaphor, truncated, finish_reasons, items
                └─ items  ITEM rows   — score, reason, truncated, raw          <- the evidence lives HERE

Each level carries fields of the **same names** meaning **different things**: `score` exists both as a
round aggregate and as a per-item result; `truncated` exists at both the round and the item level; the
reason string lives only on the item while the verdict lives on the round.

## The three instances

| who | the assertion | why it was wrong |
|---|---|---|
| Ocho | read `card_version` off the **bundle** | it lives on the **entry** row |
| Chilly | read item fields off the **entry** row | they live under `rounds[*].items` |
| Chilly | declared "0 items carry a serving-failure counter" | scanned the **entry** level, so the number described nothing |

**None of these were arithmetic errors.** Each was a correct procedure applied to the wrong level, and
each produced a **confident, well-formed number that described a container instead of its contents.**

## The ruling

**1. A field name without its level is ambiguous in exactly the way a count without its denominator is.**

Say *"`card_version` on the entry row"*, not *"`card_version`"*. Say *"`raw` on the item record"*, not
*"`raw`"*. The bundle nests three levels and reuses names across them, so **an unqualified field name
does not identify a location** — and an assertion about it cannot be checked.

**2. Before asserting anything about a field, walk the structure and print the key set at every level.**

Not "open the file and look" — **enumerate the levels first**, because knowing a field exists somewhere
is not knowing which level it is on. A structure dump costs one command and prevents the whole class.

**3. A count is about the set you actually scanned, and the set is defined by the level.**

"0 items carry the counter" was true of the entry rows and meaningless about the items. **When a scan
returns a clean zero, name the collection scanned before reporting the zero** — a zero at the wrong
level is the most reassuring possible wrong answer.

## What the correct scan found

At the **item** level, across the v4 field's first 48 item records: `score`, `reason`, `truncated` and
`raw` on **all 48** — and **zero** matching the silent-zero signature (score 0.0 with no reason and no
raw). The C3 requirement is satisfied in the data.

**And the round row carries `metaphor: 'FENCING'`.** The sport is a **field in the artifact**, not
decoration on top of it — which is the right place for it: a frame that lives only in the prose can
drift from the thing it frames, and one that lives in the data cannot.
