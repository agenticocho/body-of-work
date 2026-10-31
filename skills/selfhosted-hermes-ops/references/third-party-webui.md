# Bringing up a third-party WebUI checkout (e.g. a `*webui` repo on port 8787)

Some clients are not built for the Hermes SPA at all — they target a separate
open-source WebUI project with its own checkout, its own port, its own `.env`,
and its own launcher. When that project is the client's actual target, standing up
the bundled dashboard is wasted work: it can be fully healthy while the client
never connects.

This file is about that project's class of problems: a checkout that exists, is
disabled or crash-looping, and whose launcher stops before the server binds.

## Order of work

1. **Identify the product from the client's own material.** A client that asks for
   URL + password and pings `/health` is not describing the Hermes dashboard. Its
   docs usually name the repo outright, and a troubleshooting entry that says
   "this is a separate server from the one that ships with the agent" settles it.
2. **Inventory before changing anything** — checkout present? port free? launcher
   executable? unit enabled, and with what restart counter?
3. **Run the documented launcher, unmodified, and let it provision its own
   environment.** A checkout that has been working has a launcher that works; a
   long detour into interpreters and `sys.path` almost always means you departed
   from the documented entry point. Do not pre-create the venv it owns.
4. **Get the launcher to start, then the service to serve** — in that order. A
   launcher that fails on an environment check has not reached the server code at
   all, so port and auth work done first will look like nothing.
5. **Expose it only after `/health` answers locally.**

### Reuse the sibling machine's notes when they exist

If the user already runs this product on another host, ask for its working
procedure or paste it yourself, then diff your box against it before doing
anything. Those notes carry the resolved answers — the exact launcher invocation,
the auth shape, the bind address, and which port belongs to which product — and
they turn an open-ended debug into a short checklist. Still run the inventory
*first*: the notes tell you what to check, not what is already true.

## Do NOT hand-create the venv — that is what blocks the launcher

**The single most common cause of this launcher's combined-import failure is one
you inflict yourself.** Provisioning a virtualenv by hand (or pre-seeding it with a
single dependency) makes the launcher skip its own dependency install, because it
guards provisioning on the venv *not* existing:

```python
if not venv_python.exists():          # <-- the whole install is behind this
    venv.create(...)
    pip install -r requirements.txt
```

So a `.venv` you made by hand containing one package produces exactly the error the
launcher exists to report — it never installed `requirements.txt`. The launcher is
not broken; you pre-empted it.

**Correct order: run the documented launcher first, unmodified, before touching
any Python environment at all.** If it fails, *then* diagnose. Moving the bad venv
aside (`mv .venv .venv-mine`) and re-running the plain launcher is often the whole
fix, and costs one command.

Corollary for every similar launcher: **read the guard clause around its
provisioning step before you pre-create anything it owns.** A directory the
project expects to create is not yours to seed.

## The launcher's environment check, when it is a real wall

Third-party WebUI launchers of this class typically require **one interpreter that
can import both the project's own dependencies and the agent's modules**. They
check it up front and exit with a combined-import error if it fails.

The check usually looks like `import <project-dep>` plus `from run_agent import
AIAgent`, with the agent dir prepended to `PYTHONPATH`.

**Import the two sides separately first.** Each often passes on its own while the
pair fails, and that asymmetry is the diagnosis:

```bash
# probe each import in its own process
python -c "import yaml"                                   # project dep
python -c "import run_agent"                              # agent
python -c "import yaml; from run_agent import AIAgent"    # the pair the launcher runs
```

When the pair fails but both singles pass, an import in the agent's chain is
**evicting the venv's `site-packages` from `sys.path`** — order does not matter,
so do not spend rounds on it. Confirm by printing the path after the agent
import:

```python
import run_agent, sys
print(any('.venv' in p for p in sys.path))   # False => the venv was dropped
```

### Where to put the shared dependency (last resort)

**Reach this section only after proving the venv was not your own doing.** In
practice the combined-import failure is almost always the hand-made venv above, so
the correct order is: move the seeded venv aside, re-run the plain launcher, and
only if the pair *still* fails is the agent import genuinely pruning
`site-packages`. Taking the last-resort fix first has a side effect the first
does not: **it mutates the user's live agent install**, which a plain launcher run
never touches — and it can make a broken hand-made venv look like a solved problem,
because the combined check starts passing for the wrong reason.

If the pair still fails after the venv question is settled, install the project's
dependency **into the agent directory**, which stays on `sys.path` through the
agent's import. `pip install --target <agent-dir> <dep>` does it without disturbing
the interpreter. Check for a name collision in the target dir first, tell the user
you are writing into their agent install, and note that a subsequent agent update
may overwrite it.

## The shared interpreter lost a dependency, and the running service never noticed

A service can run for days with a dependency that no longer exists anywhere on disk. It **imported what
it needed at start**, so nothing is wrong until something restarts it — and then the launcher fails its
combined-import check, naming a third-party module:

```
ModuleNotFoundError: No module named '<project_dep>'
[bootstrap] ERROR: Python environment cannot import both WebUI dependencies and Hermes Agent.
```

**The tell is a long uptime paired with a failure that appears only on restart.** Before forming a theory
about the venv or the PATH, check the resolved interpreter directly, from a neutral cwd:

```bash
PY=$(<repo>/resolve-python.sh) && echo "$PY"
"$PY" -c "import <project_dep>; print('ok')"      # outside the project tree
```

If that fails, the dependency was removed from a **shared** interpreter — and the removal is the event,
not the restart that revealed it. **A shared interpreter has consumers you have not enumerated**, so
verifying that one consumer ignores a package says nothing about the rest: searching for importers means
the whole tree, and every consumer, not the most obvious one. **Restart every consumer as part of the
change, while the cause is still known** — otherwise the breakage surfaces hours later and is attributed
to whatever restart happens next. Restore it into the resolved interpreter and confirm the unit comes up
before reporting the repair; and report the cause separately from the fix, because a clean run afterwards
is not the finding.

This is the same asymmetry as the stale-interpreter case below, and it is the reason the restart matters:
**a unit that has been running since before a change has never exercised its own startup path**, so a
latent breakage stays invisible for as long as the process lives. After any change to what an interpreter
contains, a restart is not diligence — it is the only test there is.

## `ModuleNotFoundError: No module named '<project_pkg>'` is almost never what it looks like

The tempting reading is that a `runpy`-based launcher fails to put the launch
directory on `sys.path`, so the server cannot import its own sibling package —
which would make a hand-written `sys.path` wrapper the fix. **Check that reading
before acting on it, because it is frequently a rendering artifact and the wrapper
addresses a problem that does not exist.**

Work in this order:

1. **Confirm the package imports at all** from a shell in the repo:
   ```bash
   cd <repo> && python -c "import <project_pkg>; print('ok')"
   ```
2. **Confirm the launcher actually works**, unmodified, from a clean environment.
   If the documented launcher serves `/health`, there was never an import problem.
3. Only if the launcher itself fails, with the same error, in a plain shell, is the
   invocation genuinely at fault.

A `--server-cwd`-style env var does **not** fix `sys.path`, and `PYTHONPATH` may be
discarded by a wrapper that rebuilds the path. If you do conclude the invocation is
wrong, prefer a launcher env var the project documents, and reach for a two-line
`ExecStart` wrapper only after the launcher is proven blocked — and say that is
what you are doing.

### A traceback is evidence about the file only if the text is in the file

A traceback whose top frame is `<string>` — with no filename — is not the project
running inline code; it is the harness's own launcher echoing a command it
composed. **Before building a diagnosis on such a frame, check that its source
text actually exists in the file you are reading:**

```bash
grep -c "runpy.run_path" server.py            # the magic line from the traceback
grep -rn "runpy.run_path" --include=*.py .    # anywhere in the project
```

If the string exists nowhere in the project or its environment, the traceback is
a **presentation artifact of how output is captured and rendered**, not an
execution path. Do not conclude a wrapper is intercepting the interpreter.

Corroborating checks, all of which must hold before claiming interception:

```bash
readlink -f <the-python-you-invoke>     # real binary, or a script?
file -L <the-python-you-invoke>         # ELF = real interpreter
find <site-packages> -name '*.pth'      # startup hooks that could inject code
find <site-packages> -name 'sitecustomize.py' -o -name 'usercustomize.py'
env | grep -i PYTHON                   # PYTHONSTARTUP / PYTHONPATH
```

If the binary is real, no `.pth` or `sitecustomize` exists, and a plain shell in
the project imports the package successfully, then **there is no shim** — write
that down and move on. Claiming interception on the strength of a rendered
`<string>` frame costs many rounds and points the fix at the wrong layer.

### Never bisect by truncating a file you did not write

Truncating a source file at line *N* cuts through blocks, so the truncated copy
fails with `IndentationError` / `SyntaxError` — not the error you are hunting. A
bisect that reports "line 30 breaks, line 40 works" when you only ever *append*
lines is measuring its own broken input. **Print the failure text for each probe,
not a pass/fail boolean**, and sanity-check the expected-pass case before reading
a pattern into the results.

## The unit works in your shell and crash-loops under systemd: compare interpreters

A service that serves `/health` when you launch it by hand and dies the moment
systemd owns it is almost always resolving a **different interpreter**, because
systemd's default `PATH` is not your login `PATH`.

```bash
command -v python3 && python3 -V        # what your shell gets
ls -l /usr/bin/python3 && /usr/bin/python3 -V   # what a hardcoded path gets
```

Here the distro `python3` could not import the project's package while the
toolchain `python3` on `PATH` could — so a hardcoded `/usr/bin/python3` in
`ExecStart` crash-loops while the same command in a terminal works.

Fix it by resolving the good interpreter **in the unit**, not by hardcoding it.
Managed toolchain directories usually carry a build stamp in their name
(`python-3.14.7+<stamp>-linux-x64`) and change on upgrade, so a literal path rots.
Resolve with a glob and pass it through the project's own override variable:

```ini
ExecStart=/bin/sh -c 'TOOL=$(ls -d /opt/<toolchain>/python-3.*/bin/python3 2>/dev/null | head -1); export <PROJECT>_PYTHON="$TOOL"; exec <repo>/start.sh'
```

Verify the resolution actually yields the intended interpreter before restarting
the unit — run the same glob under `env -i` with the unit's `PATH` and confirm the
version, or you will ship a second silent fallback.

**Do not "fix" the PATH with a directory that is not itself on PATH.** Adding the
container/parent directory (`~/.hermes/tools`) to `PATH` does not expose anything,
because the executable sits one level deeper in a build-stamped directory — the
shell silently falls through to the distro interpreter and the crash loop returns
looking identical. Check the resolution resolves to the *executable*:

```bash
env -i PATH=<what you put in the unit> sh -c 'command -v python3 && python3 -V'
```

When that prints `/usr/bin/python3`, the unit is still wrong. Two traps in one
command, and both produce the same silent fallback.

## Password-only auth is the fingerprint of this product class

A client that collects **only a server URL and a password, with no username**,
tells you which auth surface to expect. This product class logs in with a
password-only endpoint:

```bash
curl -X POST http://127.0.0.1:<port>/api/auth/login \
  -H 'Content-Type: application/json' -d '{"password":"..."}'
# => {"ok": true}      200 on success, 401 on a wrong password
```

Do **not** validate with `curl -u user:pass` — that tests HTTP Basic auth, which
this server does not implement, and it will 401 against a correct password and
send you hunting a phantom credential bug.

Other tells that confirm the product: auth off by default for localhost (so
`/` returns `200` until a password is set, then `302` to `/login`), and `/health`
as the reachability probe. Read the password back out of `.env` before reporting
it, and replace **only** the `HERMES_WEBUI_PASSWORD` line — never truncate the
file — with `chmod 600` preserved.

### Verify your own probe before trusting its output

A probe can be wrong in a way that manufactures a finding. The check
`any('hermes-webui' in p for p in sys.path)` reports `False` for a healthy
interpreter, because the cwd appears as `''` rather than an absolute path — so
`sys.path[0] == ''` is the passing result, not the failing one. When a probe
contradicts everything else you have measured, suspect the probe: print the raw
values (`sys.path` verbatim) instead of a boolean summary, and confirm the
expected-pass case actually passes before reading meaning into the fail case.

## Verify in the order the client will

```
1. curl -sS http://127.0.0.1:<port>/health     # local first
2. tailscale serve status                     # read the real ts.net hostname
3. curl -sS https://<ts-net-host>/health      # then the exact public URL
```

An empty or stale `h.txt` in your scratch dir will make a failed curl look like a
`200` from whatever was written last. `rm` the file before probing.

## Reporting honestly while blocked

If the server does not come up, say exactly that and name the last real obstacle —
"the launcher's combined-import check passes and the package imports from a shell,
but every entry point still fails under the unit; the unit resolves a different
interpreter than my shell does, and I have not yet confirmed which one it needs."
Do **not**:

- present the failed attempts as a working recipe;
- name a cause you have not proven — especially one you already retracted;
- claim the client should work when the port has never answered;
- call it "done" because the launcher printed a "starting" banner — the banner
  precedes the bind.

State what is verified (health, port free, launcher reached the start step), what
is not (the app serving, the client connecting), and what would settle it.

**Once you have a verified working path, retire the wrong theory explicitly in one
line** — the user has been reading your hypotheses as facts. When a detour was
caused by your own change, own it and move on rather than appending a correction
beneath the theory it replaces.

## The resolution, for reference

This class does come up. The sequence that worked, in order, each step
contingent on the previous one:

1. `mv .venv .venv-mine` — remove the hand-seeded venv, then run the **plain**
   launcher. `/health` answered on the first attempt after this.
2. If the launcher passes its environment check but the server still cannot
   import its own package, the fault is the **unit's interpreter**, not the
   project. Compare `command -v python3` against the unit's hardcoded path and
   resolve via glob inside the unit.
3. Set the password through the project's `.env` (replace only that one line,
   `chmod 600`), then verify against the password-only endpoint — not Basic.
4. Publish with `tailscale serve --bg <port>`, reading back the real hostname,
   then verify localhost **and** the public URL.

The whole detour is attributable to step 1 being skipped: every later
investigation was chasing a failure mode that a single `mv` removed. The lesson
generalises past this project — **when a documented launcher provisions its own
environment, treat any pre-existing environment you created as the prime
suspect before forming a theory about interpreters, wrappers, or import paths.**

### Retiring the backend you displaced

Publishing this product on the tailnet HTTPS root displaces whatever held it. A
retired unit leaves live `Requires=` / `BindsTo=` referrers pointing at a
**disabled** unit, which reads healthy until the next reboot and then silently
takes out dependents — including the cron scheduler. Repoint every referrer at
whatever now owns the backend, and prefer `After=` + `Wants=` over `Requires=` /
`BindsTo=` so a UI outage cannot prevent an independent service from starting:

```bash
grep -rlE '<retired-unit>' ~/.config/systemd/user/ | grep -v '\.bak'
systemctl --user list-dependencies <dependent> --no-pager
```

Tell the user which dependents you repointed. Retirement is never one file.

### This product may not own the managed llama.cpp runtime

A WebUI of this class runs the agent in-process but is **not** the process that
generates the managed runtime's `presets.ini`. It never calls
`generate_presets`. So after retiring the `hermes serve` unit that used to own the
runtime, two things follow that the user needs told plainly:

- **Restarting this service regenerates nothing.** A catalog entry, a context
  window, or a projector that appears not to take effect after a restart here is
  not a failed fix — it is the wrong process being restarted.
- **Nothing regenerates presets at boot.** Every managed-runtime setting becomes a
  per-session experiment until a unit owns that runtime again.

Establish the real owner rather than inferring it from which services are enabled:

```bash
ss -ltnp | grep <llamacpp-port>                     # who holds the port
PPID=$(ps -o ppid= -p <llama-server-pid> | tr -d ' ')
tr '\0' ' ' < /proc/$PPID/cmdline | tail -c 80       # which backend, which flags
```

The parent is the answer, and it is often a GUI app (Electron Desktop) rather
than any systemd unit — in which case the fix is a unit that runs
`hermes serve --port 0`, not a restart of the WebUI. See
`references/catalog-entries.md` for making a catalog change durable.