# Evidence discipline, by situation

Rules for not being confidently wrong. Grouped by the situation that triggers
each one, because the trigger is what tells you which rule applies.

## Reading a signal

- **Read the error body before theorizing.** `curl -f` hides the one line that
  explains the failure. Write to a scratch file and parse it.
- **A traceback frame with no filename is a rendering artifact, not an execution
  path.** A `<string>` top frame means something composed that command for
  display. Before diagnosing a wrapper, a shim, or an intercepted interpreter,
  grep the project for the magic line in the traceback — if it exists nowhere on
  disk, the output was reformatted and the theory is dead. Corroborate with
  `readlink -f`, `file -L`, and a hunt for `*.pth` / `sitecustomize.py`.
- **Verify the probe before reading meaning into it.** A check like
  `any('<dir>' in p for p in sys.path)` reports False for a healthy process,
  because the cwd appears as `''`, not an absolute path. The passing result is
  `sys.path[0] == ''`. When a probe contradicts everything else you measured,
  print raw values instead of a boolean, and confirm the expected-pass case
  passes before trusting the fail case.
- **A stale scratch file makes a failed probe look like a pass.** `rm` the output
  file before each curl, or you will read yesterday's body as today's status.
- **Check the expected-pass case first.** A test that never passes on input you
  know is good is measuring itself, not the system.

## Measuring live state

- **A guard on emptiness cannot catch a failure that prints on stdout.** Many
  CLIs write their error to *stdout*, so `out=$(cmd 2>/dev/null)` leaves the
  variable non-empty and a `[ -n "$out" ]` / `[ -z "$out" ]` guard passes while
  the value is an error string. `nvidia-smi` is the canonical offender —
  `Failed to initialize NVML: Driver/library version mismatch` goes to stdout,
  and a probe that tests only for non-emptiness then reports that string as a
  measurement (e.g. `"FailedtoinitializeNVML... MiB used"`), and downstream
  arithmetic on it fails with `integer expected` rather than refusing. **Test the
  exit status, or assert the value's shape (numeric), never its presence.** A
  guard that cannot fail for the reason it exists is decoration.
- **A value true when you first read it does not stay true across another
  process's writes.** Any field naming live state — a session's stored model, a
  cached route, a lease record, a status column — can be overtaken by the thing it
  describes between your read and your report. Re-read before repeating a claim,
  and prefer the record of what actually *ran* (a usage table, a log line) over a
  column that merely *names* it. A label is a claim about the past.
- **A thing that is already holding a resource keeps working after the resource
  breaks.** Processes with already-mapped libraries keep serving, so an inference
  port that still answers `/health` is not evidence the device works — the card
  can be unenumerable while the old holder happily responds. Verify the *device*
  (a fresh minimal command that must initialise it) separately from the
  *service*, and check that a *new* consumer can start before reporting a window
  as usable.
- **An ordering constraint is a claim about a coupling — verify the coupling.**
  Before sequencing work around an expected disruption ("don't restart X, it will
  kill Y"), confirm X and Y actually share the supervisor being restarted. Check
  the cgroup or the unit rather than inferring it from both being "part of the
  same product": `cat /proc/<pid>/cgroup` for each, and compare. Components are
  routinely supervised separately — a gateway, a GUI app, its spawned backends,
  and a CLI child each have their own — and that separation is usually the whole
  point. Getting this wrong invents a blocker and defers work for no reason.
- **A killed run and a finished run are indistinguishable from the last log
  line.** If the runner writes its artifact only at the very end, a mid-run
  SIGTERM leaves *nothing at all* — not a partial file. So a log ending in
  "cleaning up before exit" / "cancel task" must never be cited as a completed
  run, and the correct description is **void, not partial**: no result exists, and
  any number attributed to that run is unsourced. Confirm by looking for the
  result artifact rather than the log, and when you own a runner, make it write
  incrementally with a provenance line so a kill at any point leaves evidence.

## Debugging by bisection

- **Truncating a file mid-block measures your own test.** Cutting source at line N
  leaves a dangling `if` and yields `IndentationError` — which reads as "breaks
  here" and produces a non-monotonic, impossible result (30 fails, 40 passes, 50
  fails on append-only input). Always print the actual error for a failing
  probe before believing the pass/fail pattern, and truncate only at
  syntactically complete boundaries.
- **Isolate each probe's environment.** Mutating `os.environ` between iterations
  inside one loop leaks state across cases and manufactures phantom
  non-determinism. Build a fresh env dict per probe.
- **Non-monotonic results mean the harness is wrong, not the code.** Append-only
  changes cannot produce a real pattern that alternates; suspect the test.

## Probing a service

- **Don't certify a client's path using endpoints that bypass its hard part.** A
  public health route and a login *page* both answer before authentication, so
  `200` on each proves only that the process is up and TLS is valid — nothing
  about the session, credential, or websocket flow the client performs.
  Exercise the authenticated path, or say plainly that you did not, before
  telling a user their client "should work".
- **A "response could not be read" style message in a JSON client means non-JSON
  came back** — an HTML page, or an empty body from the wrong port. Check
  `content-type` on every path the client uses. When all return well-formed
  JSON, the fault is the client's request shape or its stored URL, and
  re-checking the proxy is not progress.
- **Bound the investigation.** Once health, providers, and a deliberate
  bad-password `401` all behave, that layer is done. Name the remaining
  hypotheses instead of re-running passing checks.
- **Your diagnostic traffic shares the user's quota.** Probes through the same
  reverse proxy consume their rate-limit bucket. Isolate with a synthetic
  `X-Forwarded-For`; if you exhaust the real one, say so rather than blaming
  their next failure.
- **Read the bind address before writing a command that targets it.** A proxy
  aimed at `127.0.0.1` when the service binds a tailnet IP yields a `502` that
  reads as "down".

## Acting on the world

- **Never hand over a command you have not verified end-to-end.** Prove the whole
  path yourself, then give the command with its expected output. An unverified
  command the user runs costs a round trip and teaches them to distrust
  everything else you say.
- **A security control scolding you is not an obstacle.** `400 Invalid Host
  header`, `422`, `429`, and a `sudo` prompt each name their own precondition.
  Read the message as the diagnosis.
- **Check resource assumptions against measured values** before advising against
  something. A load OOM is not proof a model is too big — check what is currently
  resident with `nvidia-smi --query-compute-apps` first.
- **Prefer the user's literal artifact over your reconstruction.** A paraphrased
  symptom loses the clause that names the product at fault.
- **When the user asks for layman's terms, give the conceptual model in a few
  sentences before any command or status table.**

## Tooling traps

- **Don't hand-roll a binary parser when `strings` answers it.** A GGUF metadata
  read written from the spec draft misreads (this dialect stores KV key lengths
  as uint32, not uint64) and burns several rounds. `strings -n 4 model.gguf |
  grep -iE 'clip|vision|patch_emb'` reveals capability in one command. Reach for
  a real parser only when you need values, and check the header against the
  actual bytes first.
- **Persistent-code toolcalls share module state.** A file handle opened at module
  level in one call is still open — at the wrong offset — in the next, producing
  garbage reads and phantom parse errors. Open files inside the function.
- **Your own commands can be shadowed by harness wrappers.** A `pgrep -af llama`
  pattern matches the shell running the grep itself. Filter out your own PID.
- **Interactive surfaces prompt for input and hang under automation.** Drive them
  through their library API in a scratch script rather than the CLI when you need
  a deterministic answer.
- **A `405`/`404` on a probe usually means wrong endpoint shape, not a down
  service** — list the app's own route table before assuming the API you guessed
  is the one in use.
- **Don't pipe `curl` into an interpreter.** The security scanner blocks it.
  Write to a scratch file and parse that.

## Reporting

- State the fix, then the evidence, then what you did *not* verify.
- Distinguish three states and never collapse them: **verified working** (real
  inference, real UI, real log line), **present but not selected** (installed and
  healthy, but live config routes elsewhere), **absent** (and only after a direct
  check).
- When the user corrects you, say so in one line, name the *specific* bad step,
  and move on. "I gave you a proxy target that serve is not bound to" is
  actionable; "my networking diagnosis was off" is not.