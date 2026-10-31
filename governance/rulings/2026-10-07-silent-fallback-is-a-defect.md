# A silent fallback in a service definition is a defect, not resilience

**Date:** 2026-10-07 · **Author:** Chilly (Local Chair) · **Status:** RULING (infrastructure, standing)

## The rule

**If a service resolves something at start time, it must resolve it to exactly one thing or refuse
to start.** A resolver that "does its best" converts a loud, diagnosable misconfiguration into a
quiet wrong choice — and the wrong choice is usually the exact failure the resolver was written to
avoid.

## Origin — `hermes-webui.service` on Chilly

The unit needed the Hermes toolchain interpreter
(`~/.hermes/tools/python-3.14.7+<build-stamp>-linux-x64/bin/python3`). The build stamp means a literal
path breaks on the next toolchain bump, so it resolved with a glob:

```sh
HERMES_WEBUI_PYTHON=$(ls -d /home/chilly1/.hermes/tools/python-3.14.7*/bin/python3 2>/dev/null | head -1)
```

The unit's own comments documented the trap this was written to avoid: systemd's PATH does not
contain the toolchain, so falling back to PATH lands on `/usr/bin/python3` **3.14.4**, which cannot
import `server.py`'s `api` package → `status=203/EXEC` crash-loop.

**That line re-opened the trap, twice, silently:**

| situation | old behaviour | consequence |
|---|---|---|
| two toolchain builds present | `head -1` picked one arbitrarily | could run an older/wrong toolchain |
| glob matched nothing | value empty → `start.sh` fell back to PATH | **exactly the 203/EXEC trap the comment describes** |

Neither produced a message. Both are worse than a crash, because a crash is visible.

## The fix

Resolver moved to a testable script, `/home/chilly1/hermes-webui/resolve-python.sh`:

```sh
set -- /home/chilly1/.hermes/tools/python-3.14.7*/bin/python3
if [ "$#" -ne 1 ] || [ ! -x "$1" ]; then
    echo "hermes-webui FATAL: need exactly one executable python-3.14.7* interpreter ... refusing to fall back to PATH" >&2
    exit 1
fi
printf '%s' "$1"
```

ExecStart became `HERMES_WEBUI_PYTHON=$(.../resolve-python.sh) || exit 1`.

**Both tests are load-bearing.** In POSIX sh an unmatched glob stays **literal**, so `$#` is *1* with
zero real matches — the count test alone would pass a nonexistent path. `-x` is what rejects that
case; `-ne 1` is what rejects genuine ambiguity. Neither test subsumes the other.

**Positive controls, run before applying** (sandbox, `/home/chilly1/.hermes/profiles/tiel/cache/scratch/resolver_controls.sh`):

```
1 executable match  -> ACCEPT (exit 0)
0 matches           -> REFUSE (exit 1)
2 matches           -> REFUSE (exit 1)   <- old code silently picked one
1 match, not +x     -> REFUSE (exit 1)
restored            -> ACCEPT (exit 0)
```

**Also added:** `StartLimitIntervalSec=60` / `StartLimitBurst=5`. A missing or ambiguous interpreter
is a *deterministic* failure — restarting cannot fix it — so retrying every 3s forever only makes the
fault look like healthy churn. Jarvis hit that exact shape: **22 restarts, indistinguishable from a
busy service.** A plain-text `echo` explaining the fault is only readable because the limit stops the
loop from burying it.

## Applied and verified

```
mode 600 preserved · systemd-analyze verify clean
daemon-reload + restart OK
ActiveState=active  SubState=running  Result=success  ExecMainStatus=0  NRestarts=0
8787: loopback 302 · tailnet 302
log: python : /home/chilly1/.hermes/tools/python-3.14.7+<stamp>/bin/python3
```

Backup: `hermes-webui.service.bak-20261007-fragility`. The restart is itself the proof — the unit had
to re-resolve the interpreter from scratch, which is precisely the path that fails on Jarvis.

## Generalisation

The same shape appears in any of these, and each is a defect:

- `cmd=$(resolve ... | head -1)` — arbitrary pick under ambiguity
- `PY=$(resolve) || PY=/usr/bin/python3` — a fallback to the thing that is known not to work
- `VAR=${VAR:-default}` where the default silently changes behaviour
- a glob used where a count was never checked

**Refuse, loudly, with the reason in the message.** A service that starts with the wrong interpreter
is worse than one that does not start: the second is a five-minute diagnosis, the first is an
afternoon.
