# Surviving a Hermes update on a self-hosted box

What an update touches, what it does NOT touch, and how to make a service that breaks under it
a non-event instead of an outage. Read this before any update on a box whose surfaces other
people or clients depend on.

## 1. Read the plan before anything moves

```
hermes update --plan        # read-only, safe on a live fleet
```

It prints the install kind, every running service across ALL profiles with its supervisor and
running version, and how each will be restarted (e.g. `gateway [default] pid NNN — systemd`,
`serve [default] — manual-serve`, `serve [default] — desktop`).

> **An update restarts ONLY what its plan names.** Anything running that is absent from the plan
> will keep running with no restart and no notification — so if the update breaks it, the break is
> SILENT and the first symptom is a client, not a unit. Diff the plan against everything you expect
> to be up, and for each item missing from it ask: *what would tell me if this died?*

## 2. Never let an update take your session with it

```
hermes update --yes --no-gateway-restart      # runnable from inside a live agent session
```

The default restarts the gateway, which kills the session that issued the command — so an
unattended update takes its own report down with it. Other flags: `--check` (availability only),
`--yes`, `--keep-stash`, `--force-venv`, `--branch` / `--switch-branch`.

## 3. The rotated-directory trap (the silent one)

**Anything installed into a directory whose NAME changes on upgrade is installed into a temporary
directory.**

The Hermes toolchain lives at a build-stamped path:

```
~/.hermes/tools/python-3.14.7+<stamp>-linux-x64/
```

An update that bumps the toolchain creates a NEW directory. The agent still imports; the OLD
directory's extra packages do not travel. A service that resolves its interpreter by glob therefore
resolves an interpreter that can run the AGENT and not the SERVICE, and it fails on an import it
used to have.

**How to recognise it:** a unit that is `enabled` and `failed`, whose dependency list is not the
problem, whose interpreter exists and works, and whose failure message names an import. Check the
two halves of the requirement separately — ask the resolved interpreter to import the service's own
declared dependencies AND the agent package, and see which side is missing.

**Contrast the candidates rather than guessing:** the toolchain interpreter, the service's own
`.venv`, and any agent venv are three different environments, and typically *none* of them has both
halves. That is the finding, not a puzzle.

## 4. Make it self-healing, not repaired

A one-off `pip install` restores service and leaves the identical outage queued for the next bump.
Two mechanisms, both small:

**(a) An `ExecStartPre` in a DROP-IN, never an edit to the unit.** A drop-in
(`<unit>.service.d/10-<name>.conf`) survives a future rewrite of the unit; an inline edit does not.
The script should:

1. resolve the interpreter through the unit's own resolver (which refuses ambiguity — see *A resolver
   must not fall back*);
2. **fast-path** on "both halves already import", so a healthy start pays no package-manager cost
   and needs no network;
3. reinstall from the service's declared requirements file otherwise;
4. **NOT fail the start when the package manager is offline.** The service's own launcher already
   refuses loudly and names the remedy; a second, more confusing failure mode is worse than one clear
   one. The point of the pre-step is to remove the common cause, not to become a new one.

**(b) A boot assertion PER CONCERN.** A service that dies at `StartLimitBurst` sits in `failed` and
stays there, silently.

- **Un-coupling an assertion is a TRADE, not a pure win.** Removing a dependency from an assert unit
  may be correct — it may have been asserting a listener that unit never owned — and it removes a real
  check with it. **The remedy is a separate falsifier for the separate concern, never a re-coupling,
  which resends the original bug.**
- The assert belongs in its own unit with `Requires=`/`After=` on the service it watches.
- **Pass on ANY HTTP status, including 302/401.** The question is *"is a server there"*, not *"am I
  authenticated"* — a login redirect means the service is UP.
- Use a **bounded retry loop** so a slow first start is tolerated, and make the FAILURE message carry
  the diagnosis: which endpoint is down, who depends on it, and the first command to run.

## 5. Local modifications that must survive

A git-install update may stash/restore local changes. Know what is load-bearing BEFORE you run it and
keep a copy with digests:

- a locally-added catalog entry that a running local-model service depends on;
- a package-manager lock that pins a specific runtime BUILD — **this is provenance, not tidiness**:
  every measurement stamped with that build stops being comparable to itself if the build moves.

```
catalog:      <...>/hermes_cli/local_runtime/catalog.json
build pin:    <...>/pm/lock.json
```

Back both up to a durable path (NOT under `cache/scratch`, which is pruned) with `sha256sum`, and
verify they still exist and still contain the entry/pin AFTER the update.

## 6. Verify after, in this order

```
hermes --version                 # note ".dirty" — it means local mods are present, and which
systemctl --user list-units '*hermes*' --no-pager
grep -c <local-entry> <catalog.json>          # the load-bearing local mod survived
ss -ltn | grep <each published port>          # every surface the plan did NOT restart is still up
curl -s -o /dev/null -w '%{http_code}' <each client endpoint>
```

**The surfaces the plan did not restart are the ones to check by hand** — they are exactly the ones
an update can break without saying anything.
