# 2026-10-07 — INVENTORY: §4 peer-link prerequisites (read-only), and one blocker

**Context:** Chair-to-Chair handoff from Jarvis's Chair, endorsed by Mike. Plan document
`12-jarvis-chilly-agent-comms-plan-20261007.md` (r4, 758 lines, sha256 a4f9bf96…) is the
authority; **my half is §4.**

## BLOCKER — the plan document is not on this machine
Only the covering note arrived (`attachments/pasted_content_2026-10-07_16-14-58-130_05a3ad.txt`).
A whole-home search found no `*agent-comms*` / `*12-jarvis*` file and no recent arrival matching it.
**Therefore: hash UNVERIFIABLE, §4/§4.1/§4.4 unread, exact listener command unknown.** No listener
was stood up — nothing was edited, no port opened. Per the note, "stop and report" is a valid
answer, and this is that.

## Read-only inventory (run from the note's own named checks)
| item | result |
|---|---|
| **profile id** (not handle) | **`tiel`** — confirmed via `hermes profile list` (◆tiel) and the profile dir |
| **port 8443** | **FREE** — nothing listening |
| ports in use | 8787 (python3, hermes-webui), 8080 (llama-swap) — no conflict with 8443 |
| `tailscale serve` now | `https://chilly.tailfaf540.ts.net (tailnet only)` → `/` → `http://127.0.0.1:8787` |
| tailnet peers | chilly <TAILNET-IP-THIS-BOX> · jarvis <TAILNET-IP-PEER> (macOS) · iphone172 · toasty (offline) |
| **`API_SERVER_KEY`** | **ABSENT everywhere** (0 lines in tiel/.env and ~/.hermes/.env; none in any profile) → §4.4's "existing line" guard is NOT triggered |
| `api_server` platform | exists — `config_defaults.py:2239`; env vars `API_SERVER_ENABLED/KEY/PORT/HOST/MODEL_NAME` |
| `hermes peer` | exists — `add/set/list/ls/remove/rm/dm/run/status/stop` |

## Note point 4 VERIFIED FROM CODE — the help text lies
The note said `hermes peer add --help` misreports where `--key` lands. Confirmed, using the code's
own subcommand rather than prose:
```
hermes -p tiel config env-path  ->  /home/chilly1/.hermes/profiles/tiel/.env
hermes          config env-path  ->  /home/chilly1/.hermes/profiles/tiel/.env
--help / _peer_add print        ->  "~/.hermes/.env"      <-- WRONG
```
`get_env_path()` returns `get_hermes_home()/.env` and HERMES_HOME is profile-scoped here.
**Consequence for §4.4: the key guard must inspect the PROFILE's .env, not `~/.hermes/.env`.**
Trust the code, not the help — as the note said.

## Boundaries acknowledged (not yet acted on, nothing to act on until the plan arrives)
No credential crosses the link. No funnel, ever. Loopback-bound only; a non-loopback bind is a
defect. A competitor is a workload, never a peer — no harness/entrant holds this credential.
Neither Chair restarts, reconfigures, or opens a listener on the other's machine. The Tailscale ACL
edit is Mike's (tailnet admin console) — **not attempted.**
