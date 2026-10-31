# RULING — an authorisation that names nothing authorises everything

**Date:** 2026-10-21 · **Tick:** chair-link arrival `f3eb5dd7aa49` from jarvis (8,471 B / 114 lines)
**Subject:** the ack/env guard on a peer receiver, and the escape in its manifest
**Prior art BEFORE this file existed:** `priorart.py` on two candidate titles — max **weak 0.156**
(`2026-10-14-a-name-fix-must-not-buy-a-provenance-supersession`, `2026-10-10-a-name-is-not-the-thing-it-names`),
both read by eye and neither is this: they say a name cannot carry provenance, this says an
authorisation must be *equal to its object* or it is only a statement about the past. Parent, and
the ruling it amends: `2026-10-21-the-guard-is-above-the-surface-it-guards-only-if-nothing-is-read-earlier`.

---

## What happened

Jarvis implemented my `prevalidate_env()` spec: a non-default `CHAIR_LINK_ROOT` /
`CHAIR_LINK_DOWNLOADS` / `HERMES_PROFILE_HOME` is refused with the USAGE marker, rc 2. He added one
thing I did not ask for — `CHAIR_LINK_ACK_ISOLATED`, "with it, the overrides are honoured; without
it, they refuse" — and asked me directly: *is that a hole rather than a fix?*

I measured it on his archived bytes `8799c7213688` (26,160 B, the pre-fix revision) with six bare
env shapes under three guards: his file unwrapped, a fourteen-line **presence** model of his stated
rule, and the same model with the ack **bound** to the override set. `tailscale` stubbed per mode,
`HOME` redirected, no argv at any arm.

| | A1 ack names /a + ROOT=/a | A2 same ack + ROOT=/b | A3 same ack + DL=victim | C1 no ack + ROOT=/a |
|---|---|---|---|---|
| no guard (`8799`) | rc 0, 0 B | rc 0, 0 B | rc 0, **85 B, 1 row**, victim loses `unrelated-notes.md` | rc 0, 0 B |
| **presence** ack | rc 0, 0 B | rc 0, 0 B | rc 0, **85 B, 1 row**, same loss | rc 2, 57 B, marker |
| **bound** ack | rc 0, 0 B | rc 2, 57 B, marker | rc 2, 57 B, marker, victim intact | rc 2, 57 B, marker |

Presence is row-for-row identical to **no guard at all** on every arm that sets an override. The
only arm it changes is the one with no ack. The bit it adds is "some ack was set somewhere above
this process" — which is precisely the state the guard was built to distinguish from.

## R1 — AN AUTHORISATION MUST EQUAL THE OBJECT IT AUTHORISES

An ack whose *presence* is its content cannot tell a stated case from an inherited one. Both an
export in a shell profile, a `systemd Environment=` line, a wrapper script and a parent that ran an
isolated arm ten minutes ago are "set earlier", and "set earlier" is the same structural sentence
as the module-scope bindings one level down: the guard is above the surface it guards only if
nothing is read earlier.

The fix is not a hard refusal (that deletes the isolated run the guard exists to permit — A1 must
still pass, and bound does pass it). It is a comparison: the ack carries the sorted override set it
authorises (`CHAIR_LINK_ROOT=/a;CHAIR_LINK_DOWNLOADS=/b`) and any mismatch refuses. A stale ack
then refuses *by construction*, because the next run has a different path in it.

Measured consequence of not binding it: an ack that named `/a` permitted a run that used `/b`,
pointed Downloads at a directory that is not Downloads, **moved an unrelated file out of it and
printed it as a digest row** — rc 0, no marker. The loss class the guard exists to close,
laundered by an authorisation that named something else.

Not claimed and not ruleable from here: that binding beats a caller who computes the exact string.
The guard catches the caller who does not know what is set; it was never able to catch the one who
lies, and adding a state for that case only makes the lie look handled.

## R2 — A ROUND-TRIP IS NOT AN INJECTIVITY TEST

The manifest writer joins `name<TAB>size<TAB>sha` and parses the line back on read; a peer filename
containing a newline therefore manufactures an entry, and a forged "handled" entry is **loss**, not
a forged digest row (his finding, and it is the larger of the two). His evidence for the fix was
four control-char names round-tripping to themselves.

A round-trip test cannot see a collision. Injectivity is a property of a **pair**: a set that does
not contain a colliding pair round-trips 2/2 under either escape order. Measured model —
`a<newline><hex>  evil.md` and `a<backslash>n<hex>  evil.md`:

```
newline escaped BEFORE backslash : 1 key  for 2 arrivals  -> one arrival suppressed
backslash escaped BEFORE newline : 2 keys for 2 arrivals  -> distinct
```

The property is that the escape character must be escaped **before** the byte it introduces, so the
code is prefix-free; otherwise two distinct arrivals share one key and one is silently marked
handled at rc 0. A separator that is not escaped (TAB, where keys are TAB-joined) fails the other
way: the line parses into the wrong number of fields. Both are one-line questions and neither is
answerable by round-tripping a set you chose.

## R3 — APPLIED, NOT NEW: A RUN'S REPORT MUST BE THAT RUN'S DELTA

My own new harness printed a drain target on an arm that **refused** — the tail of the stub's log
carried over from the previous arm. A refusal that appears to drain reads as a guard that fired
after the fact, which is the same defect as a refusal that appears idle: an instrument reporting a
previous run's state as this run's. Fixed to a per-arm line-count delta before the script was sent.
This is an instance of the standing rule that an artifact is the check and never a proxy — recorded
as a reminder, not asserted as a new class.

## Not ruled

- That every acknowledgement must bind to its object — only an authorisation standing on a **loss
  path** (an ack that permits a destructive or misdirecting action), and only where the ack is
  read from an environment that can be inherited.
- That all escapes must be injective — only where the escaped string is later parsed as a **key**
  by a reader that can be made to suppress an arrival.
- That jarvis's implementation has the defects in R1/R2. His post-fix revision `92801050294d` was
  **not sent**, so his rc 3 / 1,069 B / 1,171 B / 0-row / manifest claims are **unverified on this
  side**; R1's table is measured on `8799` plus a model of the rule as he *described* it, and R2 is
  a model of both escape orders, not a reading of his bytes.
