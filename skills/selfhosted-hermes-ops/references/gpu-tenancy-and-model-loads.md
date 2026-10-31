# GPU tenancy and managed model loads

When a load through the managed runtime fails, the answer is almost never the model. Work the list
below in order; each step is cheap and each one eliminates a whole class.

## The card is not yours alone

The runtime plans as though it owns the GPU. It does not. Enumerate tenants before theorising:

```bash
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
ss -ltnp | grep -E 'llama-server|llama-swap'
```

A second llama.cpp stack is a first-class tenant, not a stray. Find what supervises each holder by
walking its parent pid — a `llama-server` whose parent is `systemd --user` may be an orphan from a
supervisor that already exited, which is a different situation from a live unit's child:

```bash
ps -o ppid= -p <pid> | tr -d ' ' | xargs -I{} tr '\0' ' ' < /proc/{}/cmdline
```

**A resident model's process age distinguishes "busy" from "stuck".** `ps -o etime` on the holder:
a child minutes old is in active use; a child hours old with an idle-looking service has a lifecycle
ttl that never fired. Do not report a leak until you have read the age.

**`ttl: 0` in a llama-swap config means NEVER unload** — permanent residency by configuration. A
coordination design built on "wait for the other stack to go idle" cannot work against one, and that
is a policy fact to surface, not a bug to fix.

## Capacity budget vs live budget

`probe_budget(planning=True)` prices against **capacity** (total minus margin);
`probe_budget(planning=False)` prices against **free memory now**, for launch-time fit. The planner
uses capacity on the stated assumption that *"the managed server unloads/relaunches itself, so
capacity is real"* — true only on a card the runtime owns. When a foreign tenant is resident, the
capacity-priced plan is a plan for a card that does not exist.

## The failure signature: the offload flag disables the fitter

A generated preset that moves weights to CPU carries `override-tensor = <pattern>=CPU`. **That flag
makes llama.cpp's automatic memory fitter abort** (`common_fit_params: failed to fit params to free
device memory: model_params::tensor_buft_overrides already set by user, abort`), so the load demands
its full footprint instead of shrinking to the room available, and dies with `cudaMalloc failed: out
of memory` / `failed to allocate CUDA0 buffer`.

The runtime surfaces this only as a bare `500 model name=<id> failed to load`. The reason is in the
child's stderr, not in the unit journal — reproduce it to see it (below).

### `spilled` is not the same as `offloaded` — keying a fix on the wrong one breaks a working model

The runtime's own decision header (`# hermes-decision: {...}` above each preset section) carries
`spilled` and `refusal`. **Both a working model and a failing one can read `spilled: true`.** The
fatal condition is that the plan moves **FFN weights** to CPU, which is what emits `override-tensor`.
Confirm by diffing the presets:

```bash
P=~/.hermes/runtimes/llamacpp/presets.ini
for S in <working-id> <failing-id>; do
  printf '%-42s ' "$S"
  sed -n "/^\[$S\]/,/^\[/p" $P | grep -q 'override-tensor' \
    && echo 'HAS override-tensor  <- fitter aborts' || echo 'no override-tensor  <- fitter runs'
done
```

Also compare the two models' behaviour on the same card at the same moment: **if a small model
answers while a large one fails, you do not have a VRAM shortage — you have a plan that forbids
adapting.** That pair is the control, and it converts a whole theory into a measurement.

`fit_to_free_memory` in `hermes_cli/local_runtime/context_policy.py` returns a spilled plan
**unchanged** (`if ... or decision.spilled: return plan`), deliberately: a live reading once counted
memory the outgoing managed server was about to free, pinning a fitting model to the CPU. The
protection is legitimate — the defect is that "memory my own server will free" and "memory a tenant
holds" are indistinguishable at that line.

## Reproducing a managed spawn — as an argv array, never through a shell

The runtime publishes its own spawn command. Read it, then run exactly that:

```bash
curl -s "$BASE/models" -H "Authorization: Bearer $KEY" | python3 -c "
import json,sys
for m in json.load(sys.stdin)['data']:
    print(m['id'], m['status']['value'], m['status']['args'][:1])"
```

Then execute `args[0]` with `args[1:]` **as a list** (`subprocess.run(args, ...)`), not by echoing
into a shell variable. **Assembling spawn arguments in a shell variable and expanding it unquoted
mangles any argument containing backslashes, parentheses, pipes or `=` — and the mangled error reads
exactly like a real one.** `--override-tensor blk\.(0|1)\.ffn_.*\\.weight=CPU` is entirely such an
argument. A truncated/failed pipe stage also hides the child's exit status.

Run it under `timeout`: **a timeout is SUCCESS** for `llama-server` (it blocks once serving); a fast
non-zero exit is the real failure and its stderr is the real error. Capture stdout+stderr together and
read it — never filter a reproduction's output through a `grep` that can exclude the line you need.

## Read the evidence before naming a cause

- **A path you read from tool output may be redacted.** Credential-shaped segments are masked when
displayed, so retyping a path you saw verbatim can produce `No such file or directory` for a file
that exists. **Resolve paths by glob or by reference — never retype a string you read.** (`ls -d
/home/user/.hermes/tools/python-*/bin/python3` rather than the literal.)
- **A filter that hides the answer looks like a clean result.** Piping a failing command's output
through `grep`/`tail` that matches nothing prints nothing and leaves you reporting an exit code with
no evidence. Read the raw tail first, then narrow.
- **Check the model file resolves** before blaming the runtime: `readlink -f` each symlink is
necessary, because a dead link is invisible in a plain listing.
- **`/health` and a listed model prove nothing about load.** Only real inference does:

```bash
curl -sS -X POST "$BASE/chat/completions" -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' \
  -d '{"model":"<ID>","messages":[{"role":"user","content":"Reply: OK"}],"max_tokens":16}'
```

Expect this to **load the model and hold VRAM**; confirm the card returned to baseline afterwards.

## Config knobs that matter

- `local_runtime.backend: cuda|vulkan` — pins which shipped llama.cpp build the runtime spawns. Worth
  setting explicitly: the runtime's vendor detection reads `nvidia-smi`, and **under a systemd unit
the manager's `PATH` may not contain it**, so detection falls through to a non-`nvidia` backend whose
  build can reject args the presets generate. Verify the choice took effect in the runtime's own
  listing, not in config.yaml:

```bash
curl -s "$BASE/models" -H "Authorization: Bearer $KEY" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['data'][0]['status']['args'][0])"
```

- **`presets.ini` is generated on every runtime start — never hand-edit it.** An edit is provisional
  and silently undone. Plan in memory to check what the planner would emit rather than reading the
  file after the fact.
- Two shipped builds may exist side by side (`llamacpp-cuda-*`, `llamacpp-vulkan-*`); the newest
  directory is not necessarily the one selected.

## Verdict vocabulary — keep these three separate

- **verified working** — real inference returned tokens
- **present but not selected** — installed and healthy, but the live routing points elsewhere
- **absent** — only after a direct check across every plausible root, never from one `ls`

## Making a tenant yield — and why a drain is not a lock

Both stacks expose an unload verb. Neither is documented; both are cheap to prove.

**Hermes managed runtime** — it runs llama.cpp's **model router**, not a bare server:

```
GET  <host>/models          -> every model with status.value loaded|unloaded
POST <host>/models/unload   -> 200 {"success":true}
     body {"model":"<id>"}, header 'Authorization: Bearer <key>'
```

**`<host>` is the published `base_url` with the trailing `/v1` removed.** Posting to `base_url`
verbatim 404s, which reads as "no such endpoint" rather than "wrong suffix". Unloading is safe — the
router autoloads on the next request — and a measured release returned 5105 MiB. POSTing for a model
that is not resident returns a precise `400 model is not running`: that is the endpoint working, not a
fault.

**A second llama.cpp stack** (llama-swap) yields at `POST http://127.0.0.1:8080/api/models/unload`
-> 200. `GET /unload` is also accepted, which is surprising enough to record: a `200` from it is not
proof the model went away — confirm on the card, not on the status code.

### A drain is a REQUEST, not a LOCK

Measured: a drain succeeded, VRAM freed, and a live pipeline re-acquired the card in **under ten
seconds**. The window between "drained" and "the other side allocates" is unguarded — a TOCTOU hole.
Any tool that drains and then loads must hold a real lock across that window, or report the loss
honestly. **A guard that claims success there hands over a lie that surfaces later as a mystery.**

Three consequences for any coordination design:

- **Mutual exclusion needs a lock *with a TTL*.** Drain-then-load with no lock races; a lock with no
  expiry wedges the card forever when its holder dies. Prove the expiry path fires.
- **Yield policy is a decision, not a detail.** A live batch run must not be evicted for an idle
  interactive load; a stale lease must always be reclaimable. Write owner, class, byte requirement
  and expiry into the lock record so the policy is readable rather than implied.
- **Which side yields is asymmetric in practice.** The Hermes router cannot be asked to wait *before*
  it tries a load — it has no pre-load hook, and patching its source is erased by the next update. So
  a cooperative wrapper must gate the **caller** and retry the known `500 failed to load` a bounded
  number of times after draining, reporting each attempt.

### Price admission against live free memory, never capacity

An admission check reads the card at the moment of the load and refuses when the requirement exceeds
free memory plus headroom for residents it does not own (an always-on vision endpoint, a
Desktop-scope server). State the shortfall, the tenants and the method in the refusal — and exit
non-zero rather than falling back to a remembered number.

## The lease: one lock across the drain-to-allocation hole

The coordination layer lives in `~/NVIDIA-PAIR/ops-docs/scripts/`: `gpu-admit.sh` (measure, drain,
admit or refuse), `gpu-yield.sh` (evict whichever side currently holds the card), and `gpu-lease.sh`
(`acquire` / `release` / `run` / `status`). `run` holds the lease for the whole command via a trap and
releases on any exit including a signal, so a long-lived server is covered by liveness rather than by
bookkeeping. Records carry owner, class, need_mib, pid, mode, acquired_at, expires_at, ttl, headroom
and **the policy text verbatim** — a decision readable in the record, not inferred from code.

### A live process is never evictable by the clock

**A `mode=run` holder whose process is alive must not be reclaimable at any age, whatever `expires_at`
says.** The tempting predicate is `expired OR (mode=run AND pid dead)` — and that `OR` is the defect:
it lets a timer take the card from a server that is alive and serving, which is the double-allocation
the lock exists to prevent. Expiry should reclaim only what liveness **cannot** vouch for: a
recordless lease, a crashed writer, a non-`run` holder with no process to inspect.

Two consequences worth having before you reason about TTL values at all:

- **With that rule, a generous TTL is correct rather than a band-aid.** A resident `llama-server` lives
  for hours or days, so a short TTL on one could only expire harmlessly or evict a live server.
  Liveness is the tenure; the TTL is the backstop against a broken record. If you called a long TTL a
  workaround earlier, correct that in one line rather than quietly keeping both readings.
- **A live-but-hung holder stays protected too, deliberately.** Reclaiming from a wedged process
  double-allocates, so the honest instruments there are a drain request and an operator, not a timer.
  State that as a bounded risk; do not paper over it with a shorter TTL.

### Wrapping a resident server, and the restart that makes it live

Wrapping a model entry's `cmd` in a service config (`... gpu-lease.sh run --owner <owner> --class
batch --need-mib N --ttl <generous> -- <server> ...`) is what turns a second stack into a lease
**client**. A yield the other side merely *requests* is not coordination.

Two facts that make the change verifiable rather than hopeful:

- **The service may not hot-reload its config.** The tell is unambiguous — its own "what is running"
  view reports the **old** command line, and `gpu-lease.sh status` shows **no lease held**. Until it
  restarts, the edit is inert. Reporting it as in effect would be reporting an intention as a fact.
- **Derive `need-mib` from a sibling entry's measured value, not from a guess.** A peer model's
  measured residency at the same context is the calibration. Over-estimating is the safe direction —
  admission refuses rather than collides — but an invented number is not a number.

### The config is a dependency graph — check every edge

**A config that references a retired model is worse than an empty one.** The entry still looks
servable; once wrapped it takes the lease and can drain the live stack *before* the server binary ever
fails. And absence is ambiguous: a note reading "wrap it when the file returns" is only correct if the
absence is temporary. **Check every referenced path, not only the ones you were told about**, and
resolve retired-vs-missing before designing around it.

**After repointing entries, the aliases drift.** Names like `falcon` or `granite-8b` keep resolving
while the model behind them changes. Keep them if callers address seats by alias, but say so plainly:
**a label naming the wrong model is the same defect class as a count that drifts from what it
counts**, and it is the kind of wrong name a reader believes.

### One global lock changes multi-group behaviour

A stack with swap **groups** can have two groups resident at once. A single global lease cannot — a
second group is now *drained* rather than merely unable to co-reside. That is a behavioural change to
an existing config, so it belongs in the report rather than in the changelog of the script. Per-group
sub-leases are the shape if two groups ever need to be live together.

### Co-residency already exists — use --scope before inventing a precedence rule

When two workloads need the card at once, **read the lease script for its scope mechanism before
proposing a new rule.** The exclusion rule is stated verbatim in `gpu-lease.sh`'s header:

```
  two holders of the SAME scope      -> EXCLUDE (one seat, one holder)
  the GLOBAL lease and any scope     -> EXCLUDE (the global lease is the whole card)
  two holders of DIFFERENT scopes    -> CO-RESIDE
  VRAM admission unchanged: priced against LIVE free, so a card that cannot hold both is refused
```

`--scope NAME` places the lease under `$STATE/scopes/NAME/` instead of the global `lease.d/`; the
scope is the unit of mutual exclusion. **The common failure is a workload that never passes `--scope`
and therefore holds GLOBAL** — which excludes every scoped contender, making co-residency impossible
regardless of free memory. Confirm before theorising:

```bash
grep -c 'gpu-lease.sh' <workload-config>            # how many invocations
grep -c 'gpu-lease.sh.*--scope' <workload-config>   # how many are scoped — expect a real number, not 0-by-assumption
```

So the cheap lever is usually **config, not code**: give each side its own `--scope` and two
different scopes co-reside under the rule the script already documents. A genuine precedence rule
(the durable fix) is only needed when the guarantee must hold regardless of how the workload happens
to be configured.

**One gate survives both routes: live free VRAM.** A scoped contender is still priced against free
memory at acquire time, so co-residency only *fits* when the resident workload is small enough. The
mechanism wins the right to share; it does not create the headroom. Both must be true — say so
separately, because "approved" is routinely heard as "it runs now".

### Never state a model-fit number without measuring the card it has to fit on

A fit claim — *"model X fits beside resident Y"* — is arithmetic against two moving numbers, and
every one asserted from memory was wrong in this session's record. The discipline that prevents it:

- **Read the peak from a measured table, never from a recalled run.** A peak measured on a clear card
  is a snapshot with a date, not a property; a remembered peak is a guess.
- **Price peak + resident + safety margin against the card total**, and state the headroom. A margin
  under ~500 MiB is nothing — a context bump or KV drift eats it instantly, so report the number and
  call a thin margin thin.
- **Distinguish the GATE from the INPUT.** VRAM arithmetic is the input; the lease is the gate. A
  model that fits arithmetically is still refused by a global lease, and a model the lease would admit
  still does not fit. Neither statement licenses the other — run them as two checks and report both.
- **Verify against live free VRAM at the moment of the run**, not against the snapshot. The resident
  workload's size is the variable that moved all morning.

When a fit decision will gate work, pre-compute the table (model, arch, measured peak, build tested
on, derived fits-beside-resident and needs-clear-card) and **place it in a durable location, not
scratch** — scratch prunes on a 24h idle timer, so a fit table that lives only in scratch can vanish
before the window it was built to serve. That is the same durability hazard as a commit on a detached
HEAD: correct work one cleanup from gone.

### A model that fails to load is an instrument condition until proven otherwise

Two failures that read as *bad model* are properties of the build, and the discriminator is the build
itself, not the file:

- **An architecture the build does not know** (`unknown model architecture: '<arch>'`).
- **A tensor-count mismatch** (`wrong number of tensors; expected N, got M`) — a GGUF built against a
  different tensor layout than this build expects.

**The same GGUF can load on one build and fail on another**, so a load failure is a fact about the
build-vs-model pair, never about the model alone. When several builds coexist, say which binary the
run used and record the build beside the result — otherwise a build change silently reads as a model
change in a later comparison.

**Do not use `strings | grep <arch>` on the server binary to test architecture support.** It returns
zero even for architectures that demonstrably run, because support lives in the loaded `.so`
libraries rather than in the binary. This is the check-that-cannot-discriminate class in its purest
form: its output looks like evidence and cannot in principle answer the question. **The only sound
evidence is a load attempt on each build** — one that loaded and one that refused, side by side.

### Freeing a seat by hand, when no lease verb will do it

**A live `mode=run` holder is correctly not reclaimable, so freeing the card for another workload means
stopping the holder — and stopping it means stopping its SUPERVISOR.** Read the parent chain first, because
its two ends behave completely differently:

```
systemd --user  ->  llama-swap (unit)  ->  bash gpu-lease.sh run --owner <o>  ->  llama-server
```

- **Killing the CHILD alone accomplishes nothing.** A unit with `Restart=always` / `RestartSec=5` replaces
the server within seconds, `MainPID` moves, and every check run in the gap still looks correct. Stop the
  **unit** itself; the wrapper and its child go with it.
- **The `run` wrapper releases its own lease as it exits**, so the record clears with no `release --force`:
  `status` reads `none held` and the lease directory empties. **Do not reach for `release`** — a forced
  release against a live holder would leave the process running, which is the double-allocation the liveness
  rule exists to prevent.

**Write down how to put it back before you stop anything, because the window is the operator's to price.**
`systemctl --user is-enabled <unit>` decides whether a reboot restores it; `systemctl --user start <unit>` is
  the restore. Say both, and say what the displaced workload loses while the seat is free — a dependent
  timer firing into a stopped backend errors once per cadence, and those failures are yours to name.

**Check whether anything would pull it back up**, and report it either way:

```bash
grep -rn 'Requires=\|BindsTo=\|Wants=' ~/.config/systemd/user/*.service | grep <unit>
```

**Verify the restore by a far-side effect, never by `is-active`** — `active` is a presence reading, and the
three checks below reach successively further:

```bash
curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:<port>/v1/models   # it SERVES -> 200
systemctl --user status <dependent>.service | head -6                     # a real cycle ran, exit 0
gpu-lease.sh status                                                       # the lease was RE-ACQUIRED
nvidia-smi --query-compute-apps=pid,used_memory --format=csv              # the tenant is back on the card
```

**And price the open window before opening it.** A hand-freed seat is an **unguarded opportunity, not a
lock**: nothing holds it for the workload you freed it for, it costs the displaced workload for as long as
it stays open, and it closes on the next reboot or the next person to start the service. Hand it over as a
time-bounded chance with its cost stated — and if it expires unused, say that too, rather than letting a
free card read as work in progress.
