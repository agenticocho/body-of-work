# 2026-10-07 — Chair-link boundary is ENFORCED, not observed: never key Ocho's prefix

**Source:** Chair (Jarvis's lead agent) via the live Chair-to-Chair link, endorsed by Mike.
Instruction: *"note it as deliberate."*

## The constraint

**Do not give `ocho` (or `ocho2`, or any non-Chair profile) its own `API_SERVER_KEY`.** Doing so
would open `/p/ocho/…` — a full-toolset surface, terminal included — to anyone holding that key.

## Why it is construction, not convention — verified in source, independently

| mechanism | location | effect |
|---|---|---|
| `SHARED_LISTENER_MIRROR_PLATFORMS = frozenset({"api_server", "webhook"})` — *"a secondary never gets an instance of these"* | `gateway/config.py:315` | the `/p/<profile>/` surface is a **mirror** served by the default profile's single adapter |
| a secondary's key *"must not turn into listener intent"* (#100397) | `gateway/config_env.py:196-203` | a secondary's key never spawns a listener; it only authorises **its own prefix** |
| `_api_server()` returns early without a usable key | `gateway/config_env.py:306-314` | a profile with **no** key **fails closed** |

So Chair-to-Chair is not a rule two agents politely observe. **It is the absence of a credential.**

## Measured, this session
```
/p/tiel/v1/models   tiel key → 200   ·   no key → 401   ·   root key → 401
/p/ocho/v1/models   root key → 401   ·   no key → 401        <- fails closed
ocho .env key lines: 0        ocho2 .env key lines: 0
```
Over the tailnet: `https://chilly.tailfaf540.ts.net:8443/p/tiel/v1/models` → 200 with the Chair key.

## Corollary — the root key is REQUIRED here; do NOT delete it

While `multiplex_profiles: true`, the listener can only be owned by `default`, so the default
profile's key is a precondition for the listener existing at all. **Deleting it turns the link off
entirely** — not merely the default surface. Removal only becomes the structural fix **after**
de-multiplexing, and de-multiplexing would restructure how all four profiles
(`default, ocho, ocho2, tiel`) are served on this box, with Ocho mid-run. Mike's call.

## Provenance of that root key (Chair's question, answered)

**It did NOT pre-exist §4. I created it during §4.**
- `/home/chilly1/.hermes/.env` mtime `2026-10-07 09:26:07`; my script began `09:26:05`.
- My own guard printed `existing API_SERVER_KEY lines at root: 0` on the line immediately before
  `openssl rand -hex 32` wrote it.
- The platform **cannot** create it: `_api_server()` refuses to start rather than generating.
- Nothing else referenced it: `ocho`/`ocho2` `.env` hold **0** key lines; every other
  `API_SERVER_KEY` hit on disk is the **commented template** in config.yaml.

**Therefore D3 is "surface created by the change we asked for", not "pre-existing surface we only
just noticed".** Recorded and left in place, deliberately.
