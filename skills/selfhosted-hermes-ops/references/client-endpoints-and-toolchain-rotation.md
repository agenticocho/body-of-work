# When a toolchain rotation takes a client's endpoint down, silently

`hermes update` can ROTATE the Python toolchain. The directory carries a build stamp in its name
(`tools/python-3.14.7+<stamp>-linux-x64`), so a bump creates a NEW directory — and **whatever was installed
into the old one is gone.**

## The failure shape

- A client that resolves its interpreter by glob (a WebUI's `resolve-python.sh`) starts returning an
  interpreter that can run the AGENT but not the CLIENT. The client's bootstrap refuses with *"cannot
  import both WebUI dependencies and Hermes Agent"*, retries to its `StartLimitBurst`, and the unit sits at
  `failed`.
- **Nothing reports it.** The endpoint is simply absent, and the first notice is a REMOTE CLIENT — a phone
  showing "offline" — not a log line. An endpoint a remote party depends on therefore needs its own
  falsifier; the service's own health check cannot see a service that will not start.
- Where the endpoint is behind `tailscale serve`, the mapping still reads correctly in `tailscale serve
  status` while nothing is listening on the proxy target. **A correct route to a dead port looks healthy
  from the route side.** Probe the port.

## Cure it at every start, and assert it separately

**1. A drop-in `ExecStartPre` that heals the interpreter at every start.**

```ini
# <unit>.service.d/10-ensure-deps.conf   (a drop-in, never an edit to the unit itself)
[Service]
ExecStartPre=/home/<user>/<client>/ensure-deps.sh
```

`ensure-deps.sh` should:

- resolve the interpreter the SAME way the service does (`$(resolve-python.sh)`) — **never a literal path
  into a version-stamped directory, which rots on the next bump**;
- **fast-path**: if the client's deps already import, exit 0 silently (no pip, no network, no output on a
  healthy start);
- otherwise reinstall them from the client's own requirements file;
- **NOT fail the start when pip is unavailable.** The client's own bootstrap already refuses loudly and
  names the remedy; a second, more confusing failure mode is worse than one clear one.

A drop-in rather than an edit to the unit means a later rewrite of the unit cannot silently drop the cure.

**2. A SEPARATE assert unit for the endpoint.**

- Probe the port with a **bounded retry**. A single-shot check declares a healthy service dead while it is
  still coming up — a measured instance needed attempt 2.
- **Any HTTP status passes**, including 302/401: the question is *"is a server there"*, not *"am I
  authenticated"*. A login redirect is a pass.
- Fail with the DIAGNOSIS in the output (which unit to inspect, what usually causes it), not just a code.
- **Do not re-couple it to an unrelated assert.** If a previous assert was deliberately un-coupled from
  this service for a good reason — it was waiting on a listener a different unit owns — re-coupling resends
  that bug. **Un-coupling removed a real check along with a false dependency, so the remedy is a second
  falsifier, not the old coupling.**

**3. Prove the cure by inflicting the failure.** Remove the deps, restart the unit, and confirm it heals
with no human in the loop. **A repair restores the state; only a self-healing step removes the recurrence**
— and the next toolchain bump is the next opportunity to find out which one you wrote.

## Two verification traps that produce confident wrong answers

- **The Hermes reader MASKS credential-shaped text**, including build-stamp directory names — they come
  back as `<name>+202…0901`. **A path echoed back from masked output is not a literal.** Rather than
  concluding anything from it, resolve with a glob and **print what resolved**. `No such file or directory`
  from a retyped masked path means your STRING is wrong, not that the file is missing.
- **Test the artifact, not your expectation of it.** Read the client's own requirements file and import
  what it actually lists. Assuming a framework's usual dependencies and reporting those as missing measures
  your guess, not the system — and it produces a plausible failure list that survives review.

## Corollary for any dependency installed by hand

**A dependency installed into a directory whose NAME changes on upgrade is installed into a temporary
directory.** Before curing such a failure by hand, ask whether the same install will survive the next
upgrade; if not, the cure is the startup step, not the install.
