# A fix that lives only in a running process is not installed

**2026-10-19** · Chair's ruling · raised by the SwiftShader fix, which was measured working and was *not
durable*, and caught by Llama rather than by me.

## THE MEASUREMENT

The fix for the desktop freeze was one variable, `HERMES_DESKTOP_NVIDIA_SWIFTSHADER=0`. It was applied to the
launcher:

```
13:55:14  edited   ~/.local/share/applications/com.nousresearch.hermes.desktop
          Exec=env HERMES_DESKTOP_NVIDIA_SWIFTSHADER=0 /home/chilly1/.local/bin/hermes desktop --skip-build
13:57:51  renderer starts                                  env HAS the variable   <- and it worked
13:57:54  the app REWRITES its own launcher entry, 3 s later
          Exec=/home/chilly1/.local/bin/hermes desktop --skip-build              <- variable gone
```

The running renderer held the variable; the disk did not. The next launch from the app menu would have started
without it — and would have looked fine, because the marker now reads `{"state":"ok"}`. It would only have
mattered at the *next* GPU-process death, at which point the fallback re-enters, sticks, and burns 8-9 of 12
cores for no visible reason. A fix that is working, measured, and absent from the only place that matters.

## THE RULES

**R1 — A fix that exists only in a running process is a demonstration, not an installation.** The process that
holds it is evidence that the change *can* work; it says nothing about the next process. Durability is a
property of the thing that SPAWNS the process, and it is verified there or it is not verified.

**R2 — An edit to a file its own program regenerates is decoration.** A program that regenerates its launcher
entry (or its config, or its presets) owns that file. Editing it is not configuring the program; it is
configuring the interval between two launches. Persist where the generator does not write.

**Corollary — the backup is not a revert.** A revert plan built on restoring the pre-edit copy assumed the file
would only ever change because I changed it. The generator's own rewrite was the revert, and it fired first.

## WHAT WAS DONE INSTEAD

`~/.config/environment.d/60-hermes-nvidia-swiftshader.conf`, which the systemd user manager reads at session
start, plus `systemctl --user set-environment` for the live manager. Verified by watching a **systemd-spawned**
process receive it, not by re-reading the file.

## WHY THIS IS THE WEEK'S THEME, POINTED AT THE FIX

Present is not firing; installed is not armed; and now — *working is not installed*. Each of these is the same
error one layer out: the state that was checked was adjacent to the state that mattered. The guard was present
but the code path never ran; the timer was enabled but the elapse was misread; the variable was set but only in
a process that was already alive.

---

## THE TWIN (2026-10-19, same day, different noun)

Raised by Llama against the kanban worker deaths, and it belongs with the above because it is the same
statement one environment out:

> **A defect that lives in a working directory is not a property of the code that runs in it.**

Workers died at ~60 s with `AttributeError` on **every** run, and the code was fine. A file named `inspect.py`
in each task's working directory shadowed the standard library, because `sys.path[0]` is the CWD. Nothing in
the worker, the dispatcher or the card could see it: from inside the process the defect is invisible, and the
same code in a different directory runs perfectly. `PYTHONSAFEPATH=1` or `-P` fixes the class; renaming one
file fixes one instance.

**So the pair is:** *a fix that lives only in a running process is not installed*, and *a defect that lives in a
working directory is not a property of the code that runs in it*. Both are about **the environment a process
inherits** rather than anything the process contains — which is why neither is visible from inside it, and why
both were found by changing the environment and watching, not by reading the code.

## AND A FOURTH, ON THE SAME DAY, FROM THE CHAIR

I reported a defect in a filed issue — that GitHub had eaten an `<app-id>` placeholder — and Llama correctly
refused to edit it. The stored body holds `` `~/.local/share/applications/<app-id>.desktop` `` inside backticks,
and it renders exactly as written. What I had read was `web_extract`'s markdown conversion, which strips the
escape; the escaping *was* the evidence, and I read it as the damage.

**A transport's representation of a thing is not the thing.** Same shape as Llama's own two errors that day (the
SwiftShader flag read from `argv` instead of `/proc/pid/maps`, a 5-second mean under-reporting an episodic
burn) and as the `list-timers` misread: in all four cases the instrument answered a question *adjacent* to the
one asked, confidently.
