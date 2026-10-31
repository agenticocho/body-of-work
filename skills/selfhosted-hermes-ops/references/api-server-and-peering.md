# Exposing Hermes' `api_server` and linking two machines as peers

Scope: the gateway's OpenAI-compatible `api_server` platform, publishing it over a tailnet
with `tailscale serve`, and `hermes peer` between two hosts. Distinct from
`remote-access.md`, which is about a *browser or phone client* reaching a UI — this is about
another **agent** reaching this one over the network.

## 1. Enablement is env-driven, and gated on a usable key

```
API_SERVER_ENABLED=true
API_SERVER_KEY=<32 random bytes>
```

`gateway/config_env.py` → `_api_server(config)` **returns early unless `API_SERVER_KEY` is
usable**; its docstring is *"an unauthenticated adapter refuses to start and the reconnect
watcher would spin."*

| what you do | listener? |
|---|---|
| `hermes config set gateway.api_server.enabled true` alone | **no** — and no error |
| `API_SERVER_ENABLED=true` with no usable key in that env | **no** |
| `API_SERVER_ENABLED=true` **+ usable `API_SERVER_KEY`** in that profile's `.env` | **yes** |

The failure is silent: no warning, no failed unit, nothing on the port. Do not read that as
a config-shape problem and start rewriting keys.

`gateway.api_server.*` in `config.yaml` **is** read for options — `api_server.py` does
`cfg_get(load_config(), "gateway", "api_server", key, ...)` for `host`/`port`/
`max_concurrent_runs` — and `gateway/config_loader.py` merges `gateway.platforms.*`,
top-level `platforms.*`, **and** `gateway.<platform>` subsections into the platform table. So
a `gateway.api_server` block is not ignored; it simply is not the switch that starts the
listener. Expect `hermes config set` to warn *"not a recognized config key"* for these
nested keys while still writing them — confirm with `config get`, never with the warning.

## 2. One listener, owned by the default profile

With `multiplex_profiles: true` the host runs **one** listener and secondaries live at
`/p/<profile>/` on it. The gateway says so outright:

```
[MULTIPLEX] Profile '<x>': api_server is served by the default profile's listener at
/p/<x>/ — not starting a second listener
```

A secondary profile's own `API_SERVER_KEY` deliberately does **not** become listener intent
(`config_env.py`; the credential still lands in that profile's `extra` so `/p/<x>/` can
authenticate). Two consequences to carry into any design review:

- **The default profile must hold a key** for the listener to exist at all, even when the
  profile you care about is a secondary. That is a *second* credential with a broader surface
  than the one you set out to expose. State it and let the owner decide; it is not a detail.
- **The bare path resolves to the default profile.** `/v1/models` is *not* the secondary's
  route. A raw `curl` there with a perfectly correct secondary key returns `401`, so any
  troubleshooting note reading "401 means the key is wrong" sends the next session the wrong
  way. Probe `/p/<profile>/v1/models`.

## 3. Prove isolation with a matrix, not a sentence

The security claim ("this credential opens only this profile") is cheap to prove and easy to
get wrong, because the gate is evaluated per request:

```bash
RK=$(grep '^API_SERVER_KEY=' "$ROOTENV" | head -1 | cut -d= -f2-)
TK=$(grep '^API_SERVER_KEY=' "$PROFENV" | head -1 | cut -d= -f2-)
echo "root and profile keys identical: $([ "$RK" = "$TK" ] && echo LEAK || echo NO)"
code() { curl -s -o /dev/null -w '%{http_code}' --max-time 8 "$@"; }
printf '  %-22s %-9s %-9s %s\n' PATH no-key root-key profile-key
for p in /v1/models /p/<profile>/v1/models /p/<other>/v1/models; do
  printf '  %-22s %-9s %-9s %s\n' "$p" \
    "$(code "$base$p")" \
    "$(code -H "Authorization: Bearer $RK" "$base$p")" \
    "$(code -H "Authorization: Bearer $TK" "$base$p")"
done
```

Expected shape: no-key `401` everywhere; the root key `200` on the bare path **only**; the
profile key `200` on its own prefix **only**; a profile with no key of its own `401` on all
three (fails closed). Anything else is a leak, not a nuance. Confirm the binding at the same
time — `ss -ltnp | grep <port>` must show loopback only; `0.0.0.0` or `[::]` is a defect to
fix, not a variant.

## 4. Publishing with `tailscale serve`

Capture rollback state first, add the route, then verify both that the new route exists and
that the pre-existing one survived:

```bash
tailscale serve status --json > serve-before-$(date +%Y%m%d%H%M).json
tailscale serve --bg --https=8443 http://127.0.0.1:8642
tailscale serve status       # expect the NEW entry AND the original 443 entry
tailscale funnel status      # the new port must read '(tailnet only)'
```

Serve HTTPS listeners occupy the well-known alternates (`443`, `8443`, `10000`); if the host
rejects one, `tailscale serve --help` lists what it accepts. **Never `tailscale serve
reset`** — it removes every route including the UI's `443` entry. Clear the single entry, or
restore the captured JSON.

Prove it over the tailnet unauthenticated **and** authenticated, and check that the `200`
body names the profile you meant (`{"id": "<profile>"}`) rather than merely returning 200.

## 5. `hermes peer`: register the base, target the profile

`peer.py` appends the mirror itself:

```python
url = str(peer.get("url") or "").rstrip("/")
return f"{url}/p/{urllib.parse.quote(profile, safe='')}"     # target form: "<peer>/<profile>"
```

So register `--url https://<host>:<port>` and address `<peer>/<profile>`. Putting
`/p/<profile>` in the registered URL double-prefixes it.

**`hermes peer add --help` misstates where `--key` is stored.** It claims `~/.hermes/.env`;
the write path (`save_env_value` → `get_env_path()`) and the read path both resolve under
`$HERMES_HOME`, i.e. the **profile's** `.env`. `hermes config env-path` reports the truth; the
help text does not. So every peer command carries `-p <sending profile>`, and the key must
exist in every profile that will originate a DM. A key written without `-p` lands in a
different file than the scoped DM later reads, and the symptom is a `401` indistinguishable
from a wrong key — the most expensive kind of wrong.

To keep the secret out of `argv` entirely, use the CLI's own no-key path: register the URL
first, then write `HERMES_PEER_<NAME>_KEY` into the profile's `.env` by hand.

## 6. Blast radius before any gateway restart

A gateway restart is not free, and on a multiplexed host it may not even cycle the process.
Measure first:

```bash
cat ~/.hermes/gateway_state.json    # active_agents, active_work, served_profiles
hermes gateway list                 # which profiles this gateway serves
pgrep -f 'gateway run'              # the PID that would be replaced
```

`active_agents: 0` with `active_work: null` means no in-flight turn is at risk. Then check
whether long-running work sits under the **gateway** PID or under a different backend: a GUI
/ desktop session and anything it spawned are children of the desktop process, not the
gateway, so a gateway restart leaves them alone. Walk the ancestry rather than assuming:

```bash
p=<pid>; while [ "$p" != "1" ]; do echo "$p $(ps -o comm= -p $p)"; p=$(ps -o ppid= -p $p | tr -d ' '); done
```

**Restart semantics differ by profile.** Restarting a profile that the default multiplexer
serves hot-reloads it in place: the log reads `Profile '<x>' restarted by the host gateway`
and the PID is **unchanged**. A config change needing a real process cycle did not get one —
restart the default profile instead and confirm the PID moved.

When a listener still does not appear, read `~/.hermes/logs/gateway.log` before theorising.
It names the reason in one line, which beats any amount of re-reading the config shape.

## 7. Handling the credential

- Never echo the key. Print only `${#K}` and line counts; read the file at the moment of use.
- Assemble auth headers at runtime (`H="$HN: $W $K"`) instead of writing a literal header into
  a script or a document. Readers mask credential-shaped text on display, so a literal header
  looks broken to the next reader even when the file is fine — and a masked value copied
  onward is a real corruption.
- One key per file, appended only under a guard that stops rather than duplicates: which of
  two lines a loader honours is not a production experiment.
- **Guard the count correctly.** `n=$(grep -c '^KEY=' f || echo 0)` is broken: `grep -c`
  prints `0` **and** exits 1 on no-match, so `||` runs too and `n` becomes `"0\n0"` — every
  `[ "$n" = "0" ]` then takes the else branch while the script cheerfully reports "0
  existing". Use `n=$(grep -c '^KEY=' f); [ -n "$n" ] || n=0`. A guard whose no-match path and
  match path are indistinguishable in the output will lie about which one ran.
- Hand the credential to the human out of band and give them the *read command*, never the
  value. Rotate by re-registering: regenerate, restart, re-prove with a `401`/`200` pair.

## 8. A one-directional link is pull-only, and a file is not a delivery

Two failure modes specific to a link that runs one way.

**The receiver cannot initiate.** When only `A -> B` exists, B's answer *is* the synchronous
return of A's DM turn; B has no channel to open a conversation. Anything B must hand A
accumulates in a queue that moves only when A sends its next message. That is correct for
request/reply and a silent stall for anything A is waiting on to do its own work. So say it,
and name the queue: *"everything you need is staged on this side; the only thing that moves it
is you sending another message."* Offer the human a nudge to the initiator rather than letting
material sit invisible — a queue nobody can see reads as nothing pending.

**Give the non-initiating side an outbox rather than a listener.** The fix for a stalled pull-only
link is *not* to reverse the direction — that opens a listener and a second credential. It is an
**append-only file the initiator polls on a timer**: the non-initiating side writes queued items to
one fixed path, the initiating side reads it on a short interval from its own agent profile, and
items are marked sent once relayed. That yields initiation with no listener, no new credential, and
no change to the one-way design. Two things to get right:

- **Keep a queued section separate from a sent section, and move items as you relay them.** An
  outbox that never clears becomes unreadable and the counterparty cannot tell new items from
  already-delivered ones.
- **Index the items and put the time-critical ones first**, because a message long enough to carry
  several items is a message long enough to be clipped. A one-line index at the top lets the reader
  notice a truncation instead of acting on a partial delivery.
- **Never clip a peer's message through `tail`/`head` to size it.** Truncating from the end silently
destroys whatever the sender put last — frequently the part they needed most. If it must be
shortened, cut it deliberately and say what was dropped.

**A file written into a repository is not a delivery.** A peer with no filesystem access cannot
read your repo, and a text-only channel carries no attachments. "Put it in the file, they'll
pick it up" holds only when the counterparty can actually open the file; otherwise the artifact
is invisible to the one party it was written for. Carry content **inline** in the message.

The subtle version is a **control that arrives too late to control anything**. An acceptance
criterion written before a draft — explicitly so the draft can be built *against* it — is still
a post-hoc rationalisation if it does not reach the author before they write. **"Written
before" is a property of the transport, not of the document.** When the timing of a control is
load-bearing, verify the path it travels, not the fact that you wrote it down.

When you find this, correct the counterparty's model of the transport explicitly rather than
just working around it — they will otherwise re-derive the same false assumption next session.
And put a header on any durable-but-non-delivering artifact stating that it is **not** a
delivery mechanism and where it must be sent to reach the other side, so the file cannot
mislead a future reader on its own.

**Honour the scope you are handed.** A peer that asks for one specific read-only check and says
"do not run anything else" is testing discipline as much as the link; run exactly that, report
from information you already hold for the rest, and say which is which. Volunteering extra
commands against an explicit "do not" is a trust cost, not diligence.

## 9. Reporting shape for this work

Say which half is done: the listener and the publish are this host's half; the peer register
and the first contact are the other host's and cannot be verified from here. Name the profile
**id** (from `hermes profile list`), not the display handle — downstream DM targets are built
from the id. Quote the checklist item you could not verify rather than implying you did.
