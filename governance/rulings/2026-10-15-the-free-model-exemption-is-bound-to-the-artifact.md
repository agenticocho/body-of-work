# the free-model exemption is bound to the ARTIFACT, not to the tool or the operator

**Date:** 2026-10-15 · **Chair:** Chilly (`@tiel`) · **Authority:** Mike, in his own words
**Status:** RULING + mechanism. This one has a trap in it, and the trap is the whole point.

---

## What Mike decided, verbatim

> *"cli default approved. Arcade (Arena) code can go to free models since the Arena will be open
> sourced on GitHub when it's ready anyways. As long as Chilly's box and other activities stay off
> trainable models, i'm ok with that."*

**Two clauses, and they are not symmetrical.**

| grant | scope |
|---|---|
| **Arena code may go to free models** | the Arena's own code — **because it is intended for public release** |
| **Chilly's box and other activities must stay off trainable models** | everything else on this machine |

## The trap: the exemption is about WHAT LEAVES, not about WHICH TOOL SENDS IT

**The reason the Arena is exempt is not that it is ours, and not that the model is cheap.** It is that
**the Arena will be published.** A free model seeing it discloses nothing that is not already destined
for `github.com`. **That reason does not transfer to anything else**, and it does not transfer to the
tool that did the sending.

**So the exempt object is the ARTIFACT, and the exemption attaches to it.**

- **`-free` ids are trainable models.** The `-free` suffix is a price, not a privacy property. Nothing
  about a free id makes it safe for anything except material already headed for publication.
- **The tool is not the boundary.** `opencode` is one delegation path among several; the same rule binds
  `claude-code`, `codex`, and any future one. **A rule that named a tool would be satisfied by switching
  tools.**
- **The operator is not the boundary either.** "The Chair was doing it" is not a scope.

## The rule, stated so it can be applied without asking

> **Free and trainable models may see Arena code, and only Arena code. Anything about this box — its
> state, its configuration, its agents, its logs, its credentials, its other projects, its
> conversations — never leaves it for a trainable model, in any tool, for any reason.**

## The mechanism, because a resolution is not one

**A permission that lives in a conversation is a resolution.** This one needs to be somewhere a
delegating agent reads it **before** it delegates:

1. **The bundled `opencode` skill is the natural carrier** — it is what an agent loads before delegating
   to this CLI, and its prerequisite section is where a scope statement belongs. **Not yet edited: the
   skill lives in the bundled and default-profile skill trees, which the Chair does not modify without
   a direct instruction. Flagged to Mike as the one remaining piece.**
2. **The skill's auth gate is also wrong for this case, and in the direction that would *block* the
   permitted work rather than permit the forbidden.** It requires `opencode auth list` to show a
   provider; this box has **zero credentials** and the `-free` ids demonstrably run anyway.
3. **Absent the edit, the fallback is this ruling plus the Chair's report** — which is weaker, because
   the next agent to delegate may not read either.

## Record

- **Operator decision:** Mike, 2026-10-15. **Both clauses are his, and the second was volunteered.**
- **Evidence the capability is real, measured twice on this box:** `opencode run --model
  opencode/longcat-2.5-preview-free` produced a file, ran it, and returned `FREEPATH-OK`, with
  **no `auth.json` on the machine at all.**
- **The non-free ids resolve and then fail `Insufficient account funds`** — so the `-free` suffix is the
  working selector here, which is exactly why the scope matters: **the ids that work are the ones that
  train.**
