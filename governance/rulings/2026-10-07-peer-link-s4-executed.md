# 2026-10-07 — §4 EXECUTED: Chair-to-Chair link live on Chilly (loopback 8642 → tailscale serve 8443)

**Authority:** Chair-to-Chair handoff (Jarvis's Chair, via Mike), plan
`12-jarvis-chilly-agent-comms-plan-20261007.md` r4, sha256 `a4f9bf96…e5a23`. Mike approved
decision 4 (Chilly's api_server + the :8443 serve entry). Tiel's half = §4.

**Hash status: UNVERIFIABLE.** The plan arrived as message content, not a file. No original bytes
exist on Chilly, so `shasum -a 256` cannot be run against it. Proceeded on the received content.

## What now exists (all verified, not reported)

```
127.0.0.1:8642   <- api_server, LOOPBACK ONLY (hermes pid, fd=40)
https://chilly.tailfaf540.ts.net:8443 (tailnet only) -> http://127.0.0.1:8642
https://chilly.tailfaf540.ts.net      (tailnet only) -> http://127.0.0.1:8787   [pre-existing, PRESERVED]
funnel: tailnet-only, NO public handler on 8443
```

Gateway log: `[Api_Server] API server listening on http://127.0.0.1:8642 (model: hermes-agent)`

### Per-profile key isolation — the security claim, measured
| PATH | no key | root key | tiel key |
|---|---|---|---|
| `/v1/models` | 401 | **200** | 401 |
| `/p/tiel/v1/models` | 401 | 401 | **200** |
| `/p/ocho/v1/models` | 401 | 401 | 401 |
| `https://…:8443/p/tiel/v1/models` | 401 | — | **200** (`{"id":"tiel"}`) |

Tiel's key opens **only** tiel. Ocho's prefix fails closed. End-to-end over the tailnet works.

## FINDING D1 — the plan's §4.3 mechanism is wrong (enablement is ENV, not config)

§4.3 says `hermes config set gateway.api_server.enabled true`. That was executed; it did **not**
start a listener. Docs (`…/docs/user-guide/features/api-server`) and code disagree with the plan:

- `gateway/config_env.py:307-315` — `_api_server()` returns early unless `getenv("API_SERVER_KEY")`
  is *usable*: *"an unauthenticated adapter refuses to start and the reconnect watcher would spin."*
- `gateway/config_env.py:197-204` — a **secondary** profile's `API_SERVER_KEY` deliberately does
  **not** create listener intent (it would fight the default's listener; #100397).
- Gateway log: `[MULTIPLEX] Profile 'tiel': api_server is served by the default profile's listener
  at /p/tiel/ — not starting a second listener`.

**Correct mechanism: `API_SERVER_ENABLED=true` + a usable `API_SERVER_KEY`, in the .env of the
profile that must own the listener.** `gateway.api_server.*` in config.yaml is real and read
(`api_server.py:1396`, `config_loader.py:140-171` merges `gateway.<platform>` blocks) — it just
isn't what starts the listener.

## FINDING D2 — §5.2's auth-proof curl will produce a FALSE 401 on Jarvis

§5.2 has Jarvis prove the link with `curl …/v1/models` and expect 200. On a multiplexed host the
bare path resolves to the **default** profile, so a *correct* tiel key yields **401** — measured:
`:8443/v1/models` + tiel key → `401`; `:8443/p/tiel/v1/models` + tiel key → `200`.
§5.4 would then diagnose it as *"the key stored on Jarvis is not the key of the profile being
targeted"* — a false alarm. **Use the profile-scoped path in §5.2: `/p/tiel/v1/models`.**

§5.3 is **correct as written**: `peer.py:92-95` builds `f"{url}/p/{quote(profile)}"`, so
`--url https://chilly.tailfaf540.ts.net:8443` + target `chilly/tiel` resolves to `/p/tiel/`.

## FINDING D3 — NEW exposure the plan did not anticipate (disclose, Mike's call)

The default profile must hold a key for the shared listener to exist at all (D1). Consequence:
**the default profile — the multiplexer, with reach over every profile — now has a live API
surface at `/v1/`.** It is gated by a root key that is distinct from tiel's, 32 random bytes,
`0600`, and **never leaves Chilly**. Measured: root key ≠ tiel key; the root key does **not** open
`/p/tiel/`, and tiel's key does **not** open `/v1/`. So Jarvis's reach is exactly `/p/tiel/…`.
Net effect: the plan's "one credential, one purpose" is now **two credentials** — the second
granting a broader (default-profile) surface, held only on Chilly.

## Process note — a bad check manufactured a false blocker (mine)

My first root-key script used `n=$(grep -c … || echo 0)`. `grep -c` prints `0` **and** exits 1 on
no-match, so `|| echo 0` appended a second `0`; `[ "$n" = "0" ]` then failed and the script took
its STOP branch while reporting "0 existing". The write was skipped and I briefly had a
self-inflicted "blocker". The plan's own guard form (`n=$(grep -c …); [ -n "$n" ] || n=0`) is
correct — I broke it while re-implementing it. Same failure class as
`2026-10-06-bad-check-manufactures-findings.md`: **a guard whose failure mode is indistinguishable
from its success path will lie about which one happened.**

## Boundaries held
No credential crossed the link. No funnel. Loopback bind only (`127.0.0.1:8642`). No cross-machine
restart/reconfigure. Tailscale ACL edit **not attempted** (Mike's). Nothing inbound to Jarvis.

## Remaining (not done, deliberately)
- **§4.6** — the tiel key must reach Mike out of band; it is **not** in this file, chat, or any artifact.
- **§5** — entirely Jarvis-side (peer register, first-contact DM).
- **§6.2** — Tailscale ACL edit is Mike's.

---

## ADDENDUM — the plan file landed; hash VERIFIED; my "unverifiable" claim was WRONG

The plan arrived on disk: `/home/chilly1/.hermes/workspace/12-jarvis-chilly-agent-comms-plan-20261007.md`,
48844 bytes, **mtime 2026-10-07 09:18:35**.

```
expected  a4f9bf968f44ec8d85277fab23faf046a14517b24823338a6533470c848e5a23
actual    a4f9bf968f44ec8d85277fab23faf046a14517b24823338a6533470c848e5a23   MATCH
758 lines · Revision r4
```

**So §4 was executed against the correct, byte-identical r4. The hash question is closed.**

**CORRECTION TO MY OWN RECORD.** The "hash UNVERIFIABLE / plan not on disk" finding above was an
**over-claim**. I listed `/home/chilly1/.hermes/profiles/tiel/attachments/` and generalised from
one directory; I never ran a filesystem search in that turn. The file had been on disk for ~1
minute when I asserted it wasn't, three directory levels away, and a single `find` would have
found it. A negative produced by a check that never looked in the right place is indistinguishable
from a real absence — the same failure class as `2026-10-06-bad-check-manufactures-findings.md`,
pointing the other way. It also cost Chair a round trip, which is precisely what his note 1 warned
about. **Lesson for this profile: "absent" requires a search, not a directory listing.**

**D1 REFINED (fairer to the plan).** §4.3's *preferred* path is `hermes -p "$CHAIR" gateway setup`
(its line 283); the `config set` block I executed is the plan's own "explicit equivalent". Neither
writes the `API_SERVER_ENABLED` + `API_SERVER_KEY` env pair that actually starts the listener —
`grep` finds no api_server env handling in the setup wizard at all. The names are written by the
dashboard's messaging config (`hermes_cli/web_server_messaging.py:191`). So D1 is not "Tiel picked
the wrong branch"; **both branches of §4.3 are insufficient**, and the working mechanism is the
`.env` pair.

**D2 CONFIRMED VERBATIM** at plan lines 423 and 429 — both curls use the bare
`https://chilly.tailfaf540.ts.net:8443/v1/models` and expect 401/200. On this multiplexed host the
bare path is the **default** profile, so tiel's correct key returns 401 there.
