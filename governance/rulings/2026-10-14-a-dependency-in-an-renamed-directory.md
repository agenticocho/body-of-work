# 2026-10-14 · A dependency installed into a directory whose NAME changes on upgrade is installed into a temporary directory

## The event

`hermes-webui.service` — *"Hermes WebUI (127.0.0.1:8787)"*, the endpoint the operator's iPhone
reaches through `tailscale serve` — was **enabled, failed, and silent for 2 h 17 min.**

```
Active: failed (Result: exit-code) since Wed 2026-10-14 08:40:19 PDT
6 restarts in 13s -> "Start request repeated too quickly" -> StartLimitBurst
[bootstrap] ERROR: Python environment cannot import both WebUI dependencies and Hermes Agent.
```

The first symptom was **the operator's phone**, not the machine: Hermex showed Chilly as
"offline". `tailscale serve` maps `https://chilly.tailfaf540.ts.net/` → `127.0.0.1:8787`, and
nothing was listening there.

## Root cause — and it is a recurrence generator, not an incident

`resolve-python.sh` resolves the agent's interpreter from `/home/chilly1/.hermes/tools/python-3.14.7*`.
**That directory carries a build stamp in its name**, so a Hermes update that bumps the toolchain
creates a *new* directory. The WebUI's own two dependencies — **`pyyaml`, `cryptography`** (that is
the whole of `requirements.txt`; the heavy ML/agent deps live in the agent env) — had been installed
into the *old* one. After the bump:

| candidate | WebUI deps | agent code | agent heavy deps |
|---|---|---|---|
| toolchain python (`resolve-python.sh`'s answer) | **NO** (`No module named 'yaml'`) | yes | — |
| WebUI's own `.venv` | yes | yes | **NO** (`httpx`) |

`bootstrap.py` demands **one** interpreter that can import **both**, so it refused — correctly, and
with the remedy in its own message (*"install the WebUI requirements into that environment"*).

> **R1 — A dependency installed into a directory whose name changes on upgrade is installed into a
> temporary directory.** A build-stamped path is a rotation, not a location. Anything placed inside
> one must be re-placed after every bump, or it is silently gone.

## Why it was SILENT, which is the part that cost the hours

`hermes-assert.service` already exists (*"Assert the Hermes runtime is actually serving"*) — and its
own comments record that it **used to depend on `hermes-webui.service` and was deliberately
un-coupled from it**, because the WebUI owns no llama.cpp runtime and the coupling made the assert
wait 90 s for a listener nobody had started. **That un-coupling was the right call and it created a
blind spot: after it, nothing asserted the WebUI at all.**

> **R2 — Un-coupling an assertion is a trade, not a pure win.** Removing a false dependency removes a
> real check with it. The remedy is a **separate falsifier for the separate concern**, never a
> re-coupling (which would resend the original bug).

> **R3 — A client's symptom is not a channel's diagnosis.** "The iPhone shows offline" named neither
> the product nor the port. It became actionable only after establishing *which product the client
> talks to* — `tailscale serve` → 8787 → the WebUI — rather than hardening the bundled dashboard,
> which the client never wanted.

## The two fixes, both verified

1. **`ensure-deps.sh` + a drop-in `ExecStartPre`** (`hermes-webui.service.d/10-ensure-deps.conf`):
   fast path when both halves already import, reinstalls the two wheels otherwise. **This makes the
   next toolchain bump a non-event rather than a repair** — and it is a drop-in, so a future rewrite
   of the unit cannot silently drop it. It deliberately does **not** fail the start when pip cannot
   reach the network; `bootstrap.py` already refuses loudly and names the remedy, and a second
   confusing failure mode is worse than one clear one.
2. **`hermes-webui-assert.service`** — its own bounded-retry probe of 8787, `Requires=hermes-webui.service`.
   Verified firing: *"answered HTTP 302 (attempt 1)"*. Any HTTP status passes, including 302/401,
   because the question is *"is a server there"*, not *"am I authenticated"*.

Verified end-to-end: unit `active`, listening on 127.0.0.1:8787, `https://chilly.tailfaf540.ts.net/`
→ **302**, `Linger=yes` (boot-survival layer 1 intact).

> **R4 — A repair restores the state; a cure removes the recurrence.** Re-running `pip install` would
> have restored service and left the identical outage queued for the next toolchain bump. The
> distinction Mike asked for in the driver work — *"turn the workaround into a cure"* — is the same
> distinction here, and the cure is the boring one: make the failure impossible to reach, then make
> it impossible to be silent.

## Update discipline (this is the "don't break next time" half)

> **R5 — `hermes update` restarts the gateway and kills the agent session that issued it.**
> `hermes update --yes --no-gateway-restart` is what makes an update runnable **from inside a live
> session**; the default takes its own report down with it. `hermes update --plan` is read-only, safe
> on a live fleet, and names every service and how it will be restarted — **run it first.**
> On this box the plan lists: `gateway [default]`, `serve [default] manual-serve`, `serve [default] desktop`.
> Note the WebUI is **not** in that list — it is not restarted by an update, which is precisely why it
> broke silently rather than visibly.

## My own two measurement errors, recorded, one species

- **I echoed a MASKED path back as a literal.** The Hermes reader masks credential-shaped text, so
  `python-3.14.7+202****0901-linux-x64` is the *displayed* form of a longer token; using it verbatim
  gave `No such file or directory`, and my "the toolchain has **0 packages**" reading came from a
  command that had failed, not an empty environment. **A masked value is not a value.**
- **I tested `fastapi`/`uvicorn`/`flask`** as the WebUI's dependencies and reported them FAIL. They
  were never its dependencies — `requirements.txt` is `pyyaml` + `cryptography`. I measured a guess
  instead of reading the artifact, twice, in the same investigation.

> **R6 — Read the artifact; do not test your expectation of it.** Both errors above produced
> confident, wrong numbers about a system whose ground truth was one `cat` away.

## Artifacts

```
/home/chilly1/hermes-webui/ensure-deps.sh                                    (self-healing, drop-in driven)
/home/chilly1/.config/systemd/user/hermes-webui.service.d/10-ensure-deps.conf
/home/chilly1/NVIDIA-PAIR/ops-docs/scripts/hermes-webui-assert.sh            (the loud falsifier)
/home/chilly1/.config/systemd/user/hermes-webui-assert.service
/home/chilly1/workspace/hermes_update_backup_20261014-093411/               (pre-update survival copy)
```
