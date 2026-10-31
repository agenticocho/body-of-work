# Reaching a self-hosted Hermes from another device

A remote client failing is almost never a network problem. Establish which layer
is broken before touching the firewall, the bind address, or Tailscale.

## First: identify which product the client speaks

Several distinct UIs front the same agent, with **separate ports, separate
credentials, and separate lifecycles**. Debugging the wrong one produces a service
that passes every local check while the client still fails.

| Product | Default port | Credential | Serves |
|---|---|---|---|
| `hermes dashboard` | 9119 | `dashboard.basic_auth` (username + password) | the SPA |
| `hermes serve` | 9119 | same backend | JSON only, headless |
| third-party WebUI checkout | 8787 | its own `HERMES_WEBUI_PASSWORD` in its own `.env` | its own frontend |

Do this inventory before any other step:

```bash
systemctl --user list-units 'hermes*' --all      # what exists, enabled or not
systemctl --user show <unit> -p NRestarts        # a huge counter = long-dead
ls -d ~/*webui* 2>/dev/null                      # a third-party checkout
tailscale serve status                           # which port the proxy names
```

Two tells that the client points at a *different* product than the one you are
looking at:

- **"It worked here before" points at prior state.** Go find what was running
  before rather than continuing to tune what is running now. If a client started
  failing right after you disabled a unit, that unit is the answer.
- **A pasted spec naming another repo, port, or `.env` is binding.** Its inventory
  section is a checklist; run it, and where it conflicts with what you already
  have working, stop and report the conflict instead of building a parallel copy.

A browser succeeding against one product says nothing about a native client aimed
at another — that is why "it works in Safari" can coexist with a client that still
fails, and why both facts are worth holding at once.

## Then: walk the layers

| Layer | Probe | Failure signature |
|---|---|---|
| Tailnet reachability | `tailscale ping <peer>` | no pong — genuinely off-tailnet |
| Proxy config | `tailscale serve status` | points at a port with no listener |
| Listener | `ss -ltnp` for the port | no socket — service not serving |
| Bind address | `curl` the tailnet IP vs `127.0.0.1` | loopback answers, tailnet IP refuses |
| Host-header allowlist | `curl` the **DNS name** | `400 Invalid Host header` |
| Auth | `curl` an API route | `401`/`302 -> /login` (this one is working) |

Read the error body at each step. `400 Invalid Host header` looks like a broken
proxy and is actually a DNS-rebinding guard doing its job.

## Check the proxy layer before blaming the service

### First: confirm the upstream serves a UI at all

A headless backend answers every pre-auth probe correctly and still cannot show a
page. **Check `content-type` on an authenticated request to `/` before touching
auth, credentials, or routes** — the answer is one curl:

```bash
# after signing in (cookie jar), the root must be HTML
curl -sS -b cookies -D- -o /dev/null https://<host>/ | grep -i content-type
```

`application/json` on `/` means the upstream is a headless `hermes serve` and the
fix is switching it to `hermes dashboard` — not a credential problem. When the
user pastes the server's own error text, read it literally: that JSON error is
the backend stating it has no UI, which is the whole diagnosis in one string.

If a URL has no port in it, a reverse proxy is in the path and it is the first
thing to inspect — the service may be perfectly healthy while the client gets
`502` from a proxy aimed at nothing.

```bash
tailscale serve status          # HTTPS host -> upstream URL, current mapping
tailscale serve status --json   # same, structured; back this up before editing
```

A `502` with a healthy upstream means the proxy target is wrong, not that the
service is down. Tailscale terminates TLS itself, so a client on
`https://<host>/` (no port) reaches the service through this mapping.

**The proxy target must be the address the service is actually bound to.** When
serve binds a tailnet IP, `http://127.0.0.1:<port>` is empty and yields `502`
even though the service is healthy — this is the single easiest mistake to make
here, because loopback is the reflexive guess:

```bash
# wrong when serve is bound to the tailnet IP -> 502
sudo tailscale serve --bg --https=443 http://127.0.0.1:<port>
# right
sudo tailscale serve --bg --https=443 http://<tailnet-ip>:<port>
```

Prove the upstream is reachable *before* repointing the proxy, and prove it with
the proxy's own Host header, since that is what the allowlist will see:

```bash
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' \
  -H 'Host: <dns-name>' http://<tailnet-ip>:<port>/          # 302 -> /login
curl -sS -o /dev/null -w '%{http_code}\n' \
  -H 'Host: <dns-name>' http://<tailnet-ip>:<port>/api/health # 200
```

These changes need root. `sudo tailscale set --operator=$USER` grants the
permissioning afterwards, so later edits need no sudo. Back up
`tailscale serve status --json` first; the revert is the same command with the
old target (or `--https=443 off`).

**`sudo` cannot be automated — hand over the command, do not prompt for a
password.** Running it yourself with `pty=true` reaches a password prompt that
nothing in your toolset can answer, and typing or asking for that password in
chat is never acceptable. Say plainly that you cannot complete it, give the exact
command with the verified target, and predict what its output should look like so
the user can confirm success without another round trip.

Note that the proxy serves **HTTPS only** — nothing listens on port 80 unless you
add it. A client hardcoded to `http://` with no port will keep failing after the
proxy is fixed; add a 80->443 redirect at the proxy if that is the symptom.

### "Offline" from the client may be a TLS-vs-HTTP mismatch

When the proxy is confirmed correct and health passes through it, and the client
*still* reports offline, the remaining variable is the scheme the client requests.
The dashboard works over `https://<host>` but nothing answers on `:80` at all, so
a client defaulting to `http://` gets a connection refused that no amount of
proxy work fixes. Ask what URL scheme the client is configured with rather than
re-verifying a proxy that already passes — re-running a passing check is not
progress.

### A client that reaches the password screen but fails to sign in

Once the proxy and Host allowlist pass, the remaining failures are in the auth
contract itself. But **only after confirming the upstream serves a UI at all** —
if `/` returns JSON you are authenticating into a backend with no pages, and no
credential work will change what the client sees.

Get the real route table from the source rather than guessing endpoints — the
login *page* is GET-only, so `POST /login` returns `405` and looks like a dead
route:

```bash
grep -rnoE '@router\.(get|post)\("[^"]+"' \
  <checkout>/hermes_cli/dashboard_auth/routes.py | sort -u
```

The endpoints a password client needs:

| Route | Method | Notes |
|---|---|---|
| `/api/auth/providers` | GET | which sign-in methods exist; fail-closed `503` if none |
| `/auth/password-login` | POST | the actual credential exchange |
| `/api/auth/ws-ticket` | POST | short-lived ticket for the chat websocket |
| `/auth/logout` | POST | ends the session |

`/auth/password-login` requires `Content-Type: application/json` and this exact
body — `provider` is mandatory and a missing one is a `422`, not a `400`:

```json
{"provider": "basic", "username": "<user>", "password": "***"}
```

Read `_PasswordLoginBody` in the source before assuming field names. Failure
modes are deliberately non-oracular: `404` unknown provider, `401` bad
credentials, `422` shape error, `429` throttled, `503` store unreachable.

**Login throttling keys on the forwarded client IP, not the socket peer**
(`client_ip()` takes the first `X-Forwarded-For` hop). Behind a reverse proxy
that means every device sharing the proxy shares one bucket — and your own failed
probes land in the user's bucket. Budget is small (10 attempts per 60s), so
exercise it deliberately, isolate with a synthetic `X-Forwarded-For`, and never
assume a `429` you caused is the user mistyping.

### A URL+password-only client cannot log in at all

Some clients offer only a server URL and a password — no username field. This
server accepts **exactly two** mechanisms, and neither is reachable from that UI:

| Mechanism | How | Availability |
|---|---|---|
| Session cookie | `POST /auth/password-login` (needs `provider` **+** `username` + `password`) | works |
| Bearer token | PKCE flow; `POST /auth/native/token` needs a `code` from a loopback gateway | native clients only |
| **HTTP Basic** (`Authorization: Basic`) | — | **not implemented** |

There is no `HTTPBasic` handler anywhere in `dashboard_auth/`, so a client whose
only option is Basic auth gets `401 {"reason":"no_cookie"}` forever. Verify before
blaming the credential:

```bash
curl -sS -u <user>:<pass> -o /dev/null -w '%{http_code}\n' https://<host>/api/auth/me   # 401 = Basic unsupported
curl -sS -H 'Authorization: Bearer <pw>' -o /dev/null -w '%{http_code}\n' https://<host>/api/auth/me  # 401 = invalid_or_expired
```

Note the different `reason` fields — `no_cookie` means no session was presented,
`invalid_or_expired_token` means a token was and it was rejected. A client that
asks for **no username** almost certainly cannot produce either, so its failure is
a client/server capability mismatch, not a wrong password.

Say that plainly rather than continuing to rotate credentials: when a browser on
the same device signs in fine with the same URL and password, the server is
proven good and the client is the incompatible party. Offer the working browser
path as a real alternative, and if the client must work, it needs a username field
or native-PKCE support.

### A JSON client reporting "response could not be read" means non-JSON came back

The response arrived and failed to parse. Do not go looking for a down service;
enumerate the paths that client uses and check `content-type` on each. When every
path returns well-formed JSON — health, providers, a wrong-password `401`, even
the throttled `429` — the fault is **not** in auth: it is either the client's
request shape, its stored URL, or an upstream that answers JSON where the client
wanted a page. Fetch the root path and look at its `content-type` before
concluding anything about credentials.

Bound the investigation rather than looping on the same passing checks: when
health, providers, and a deliberate bad-password `401` all return correct JSON,
that is a *complete* result for the auth layer, and re-running them is not
progress. The remaining hypotheses are the client's request shape and which server
it reaches, and the way to split those is a browser on the same device signing in
with the same credentials.

### Never swap a working root route for a newly requested one

When a new task asks to expose something at the same host and root path that a
route already serves, **stop and report the conflict instead of repointing**. The
existing route is often the thing the user is currently using successfully — here
the root route on 443 was what made a phone client work, and the request to
install a second WebUI at the same path would have traded a working connection
for a new one. Run `tailscale serve status` and `tailscale funnel status` *before*
proposing any route change, preserve every existing route, and never enable Funnel
for a tailnet-only surface.

Safe alternatives when the root path is taken, in order of preference: leave the
route alone if the existing service already covers the need; a different
`--https=<port>` gives a second ts.net URL without disturbing `/`; a subpath
(`/name`) can coexist but only if the app genuinely serves under a prefix and you
can verify it without touching the live route. Report the conflict and the options
— let the user choose which of their working surfaces to give up.

## Close with the client's own credential format, not a status dump

When the task is "make this client work," the deliverable is the handful of values
the user types into that client. Lead with them in a table — URL, credential,
launcher — followed by the two health results in the order they were verified, and
state what remains on the user's device:

```
Server URL : https://<host>.<suffix>.ts.net
Password   : <read back from .env>
1. curl http://127.0.0.1:<port>/health        -> 200
2. curl https://<host>/health                 -> 200 application/json
   root -> 302 (auth enforced); wrong password -> 401
```

Read the credential back out of its source file at report time rather than quoting
it from memory earlier in the session, and say which file it came from. Report
what you verified and what you did not — the client's own websocket or session
flow is the user's to exercise, so name it as unverified rather than implying the
app works because `/health` does.

**Ask which surface to retire before repointing a shared route.** When a second
service wants the root path, the choice of what gives up is the user's, not yours:
the existing route may be the only thing another client of theirs depends on. Put
the conflict and the options in front of them once, then follow the answer — do not
build the newly-requested product start to finish and surface the conflict at the
end, after the work is already done.

## The Host-header allowlist is the usual culprit

Hermes accepts only two kinds of `Host`: the address it is bound to, and a
hostname the operator has explicitly declared. Anything else gets:

```
{"detail":"Invalid Host header. Dashboard requests must use the bound hostname
 or the configured public hostname."}
```

So a working service on a working tailnet answers on its IP and refuses its own
name. The raw IP is the tell — if that returns `200` and the name returns `400`,
the fix is one config key, not a network change:

```bash
hermes config set dashboard.public_url "http://<host>.<suffix>.ts.net:<port>"
systemctl --user restart hermes-serve.service
```

`dashboard.public_url` is the single source of truth: it feeds the Host and
WebSocket-Origin allowlists, the OAuth redirect, and the public-host check. Set
it; do not disable the guard. `HERMES_DASHBOARD_PUBLIC_URL` in the environment
overrides the config value when you need a per-unit override instead.

Verify both forms after the restart, plus that auth is actually enforced:

```bash
curl -sS -o /dev/null -w '%{http_code}\n' "http://<dns-name>:<port>/api/health"   # 200
curl -sS -o /dev/null -w '%{http_code}\n' "http://<tailnet-ip>:<port>/api/health" # 200, no regression
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "http://<dns-name>:<port>/" # 302 -> /login
curl -sS "http://<dns-name>:<port>/api/sessions"   # 401 unauthenticated
```

`/api/health` is public and reports `"auth_required":true`. That flag plus a `401`
on an API route is what proves the dashboard is gated; a `200` on health alone
proves nothing about auth.

## Get the hostname from Tailscale, not from memory

MagicDNS names are easy to misremember — dropping digits from the suffix yields a
name that does not resolve and looks like a dead server. Read it:

```bash
tailscale status            # peer hostnames and IPs
tailscale status --json     # Self.DNSName and MagicDNSSuffix are authoritative
```

`Self.DNSName` carries a trailing dot. Prefer the name over the raw IP in anything
the user has to type on another device — it survives an IP change.

## Bind to the tailnet IP via a drop-in, and wait for the address

Never edit the unit's `ExecStart` to change the bind address; use a numbered
drop-in so the override is visible and reversible:

```ini
# ~/.config/systemd/user/hermes-serve.service.d/30-tailnet-bind.conf
[Service]
ExecStart=
ExecStart=/home/chilly1/.local/bin/hermes serve --host <tailnet-ip> --port <port> --skip-build
```

The empty `ExecStart=` is required — it clears the base value before the
replacement. Pair it with a wait so boot does not race Tailscale, since the
address may not exist yet when the unit starts:

```ini
# 40-wait-tailnet.conf
[Service]
TimeoutStartSec=300
ExecStartPre=/bin/sh -c 'for i in $(seq 1 45); do ip -4 addr show tailscale0 2>/dev/null | grep -qF "inet <tailnet-ip>/" && exit 0; sleep 2; done; exit 1'
```

A bind to a tailnet IP makes the unit depend on Tailscale being up. That is the
trade: it is not reachable off-tailnet, and it fails to start if Tailscale has not
assigned the address yet. Binding `0.0.0.0` removes both problems but disables the
Host-layer defence entirely, so only do it on a network you already trust.

## Who owns the service you are proxying to

A route is only the address; something has to be listening at the other end, and on
a desktop-class install that is often not the unit you assume. Establish the owner
before concluding anything about reachability:

```bash
tailscale serve status                 # what the route names
ss -ltnp | grep <port>                 # who actually holds it
PPID=$(ps -o ppid= -p <listener-pid> | tr -d ' ')
tr '\0' ' ' < /proc/$PPID/cmdline | tail -c 80   # which backend, which flags
```

A GUI app spawning and supervising its own backend is the common answer. That has
one consequence worth stating to the user rather than discovering later: **nothing
regenerates that backend's generated files at boot**, so every derived setting is a
session experiment until a unit exists.

**To close the gap, add a `systemd --user` unit for the backend** rather than
leaving the GUI as a prerequisite:

- **`ExecStart` against the `hermes` launcher**, not a hand-built interpreter
  invocation. The launcher resolves the toolchain and its `sys.path` itself; a
  `python3 -c` reimplementation has to reproduce that setup to survive systemd's
  narrower `PATH`, and when it half-works the unit crash-loops on an import while
  the same command succeeds in a shell.
- **Do not inherit the GUI's environment flag.** The Desktop flag changes backend
  lifecycle and auth exemption, so a standalone unit that sets it is not the backend
  you meant to run.
- **Keep the OS-assigned port** (`--port 0`) and read the published record; a unit
  that hardcodes a port re-creates the stale-proxy bug this file exists to prevent.
- **Do not add `Conflicts=` against the GUI.** Both may legitimately exist and the
  first to start owns the port; a mutual conflict means a race can leave neither
  running. Enable the unit and let precedence fall out naturally.

Verify by stopping the GUI, starting the unit, and confirming the generated files
regenerated and `NRestarts` stayed at 0 — then confirm the proxy path again, because
stopping the GUI can move the port the route was aimed at.

## Read the effective unit, never the base file

**The base unit file does not describe the running service.** An `ExecStart=` in a
numbered drop-in replaces the base value entirely, so reading
`hermes-serve.service` can show a bind address the process is not using — and you
will conclude the wrong thing about what is exposed.

```bash
systemctl --user cat hermes-serve.service     # base + every drop-in, in order
systemctl --user show hermes-serve.service -p ExecStart   # what systemd will run
ss -ltnp                                     # what is actually listening
```

Cross-check `ExecStart` against `ss` before reporting any bind address. On a stack
with several drop-ins, `systemctl --user cat` is the only complete answer.

## Verify the peer, not just the server

The server answering locally says nothing about the remote device. Confirm the
peer is on the tailnet and reachable, then let the user confirm the client:

```bash
tailscale ping -c 2 <peer-hostname>
```

A `direct connection not established` line with a successful pong is normal on
some networks — traffic is relayed through a DERP server and still works.

## A dead unit behind the proxy is a client-visible outage

When the proxy points at a unit that is crash-looping, the client reports
"offline" while the service everyone is checking is healthy. The unit's own state
is the giveaway, and the counter is the finding:

```bash
systemctl --user show <unit> -p NRestarts -p ActiveState
```

A restart counter in the thousands means the unit has been failing structurally
since some boot — frequently because a reinstall replaced the interpreter its
`ExecStart` names (a `venv/` that no longer exists fails at `203/EXEC` forever,
invisibly). Do not file such a unit as "redundant" without checking the counter
first: here the dismissed unit was the entire reason a phone could not connect,
and the proxy had been quietly pointing at its dead port the whole time.

Once the proxy is repointed at a working service, disabling the dead unit is safe
— re-verify the client path *after* stopping it, since the two can share a
hostname.

## Swapping a headless backend for a browser-serving one

When the proxied service turns out to be a headless `hermes serve` and the user
wants a UI, the change is an `ExecStart` swap — same host, same port, same proxy,
same drop-ins. `serve` and `dashboard` accept the same flags:

```ini
# hermes-dashboard.service
ExecStart=/home/chilly1/.local/bin/hermes dashboard --host <tailnet-ip> --port <port> --skip-build --no-open
```

Four things make or break this:

1. **`Conflicts=hermes-serve.service`** (or stop serve first). One backend owns
   the port; a second invocation attaches to the owner and exits `0`, so leaving
   serve enabled means it reclaims the port on the next restart.
2. **Rewrite the bind drop-in, do not copy it.** `30-tailnet-bind.conf` overrides
   `ExecStart` wholesale, so a verbatim copy runs `serve` under a unit named
   `dashboard`. Confirm with the live cmdline:
   `tr '\0' ' ' < /proc/$(systemctl --user show <unit> -p MainPID --value)/cmdline | grep -oE '(serve|dashboard)'`
3. **Repoint every dependent's `Requires=`/`BindsTo=`/`After=`** at the new unit
   name. Miss one and boot ordering silently validates the dead service.
4. **Flip enablement**: enable the new unit, disable the old one, or the next boot
   starts the headless backend again.

Then verify the thing that actually matters — HTML, not JSON:

```bash
curl -sS -b cookies -D- -o /dev/null https://<host>/ | grep -iE '^HTTP|content-type'  # 200 text/html
asset=$(curl -sS -b cookies https://<host>/ | grep -oE '/assets/[^"]+\.js' | head -1)
curl -sS -b cookies -o /dev/null -w '%{http_code}\n' "https://<host>$asset"             # 200
```

A `200 text/html` root with a `200` JS asset is a loaded app. Stop there and let
the user confirm in their client; do not pre-empt their report with a claim that
chat works, which only their client can exercise.