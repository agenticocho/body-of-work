# Watching a volatile state transition in the background

Some facts you need are **passive events on a moving system** — a lease that
re-scopes on the next natural load, a window that opens when free memory crosses a
threshold, a service that comes up on a new scope. You cannot see them by looking
once, and you cannot see them by polling in the foreground without parking a turn.
The tool is a **change-detector cron job**: a tiny deterministic script whose
stdout is hashed each tick, and the agent is woken only when that output changes.

The value over a foreground poll is that it **survives the turn ending** and does
not double-fire against an agent that is already watching the same state.

## The script: deterministic, single-line, timestamp-free

The scheduler hashes the script's stdout as exact bytes each tick; unchanged output
is a silent no-op, changed output injects a `MONITOR CHANGE DETECTED` diff and wakes
the agent. So the output has three hard requirements:

- **Deterministic.** Run it twice, get identical bytes. Verify this before
  scheduling — two identical runs.
- **No timestamps, no ordering variance, no free memory readings echoed raw.** A
  clock makes *every* tick look changed and the watcher degenerates into a firehose.
  Emit a coarse STATE token (`planner_at=global kev_window=closed`), never the
  underlying number.
- **A check that crashes must not print empty.** A script that exits non-zero or
  dies on an unreadable command and prints nothing reads exactly like *"no change"*
  — the false-clean failure mode, the same one that makes a dead probe report
  success. **Every error path prints a stable `unknown` token**, so a real fault
  stays visible instead of masquerading as a quiet tick. This is the single most
  important line in the script.

Shape:

```bash
#!/usr/bin/env bash
# one line, coarse tokens only, every error path -> 'unknown'
x=unknown
if read_ok; then x=<computed-token>; fi
y=unknown
if other_ok; then y=<other-token>; fi
echo "a=$x b=$y"
```

Place it under `<profile>/scripts/` and `chmod +x` it. Run `bash -n` on it and run
it twice before you schedule it — a watcher that spams is worse than no watcher.

## The cron job

`cronjob_manage` action=create with:

- **`monitor`: the script path RELATIVE to the profile's `scripts/` dir** — pass
  `arcade_watch.sh`, not `scripts/arcade_watch.sh`. The scheduler resolves monitor
  (and `script`) paths under `<profile>/scripts/`, so a `scripts/` prefix doubles
  to `.../scripts/scripts/...` and fails with "Script file not found".
- **`schedule`: an interval at or slightly finer than the fastest event you are
  catching.** A window that closes in minutes needs `every 10m`; a lease that
  re-scopes on a load the same. Coarser than the event and you miss transitions.
- **`no_agent`: false** — you want the agent to *reason* about the change and act
  (message the owner, confirm from disk), not just echo the line.
- **`deliver`: `local` unless you have confirmed the user's messaging target.** A
  silent local log is the safe default; a wrong `deliver` target is a side effect.
  Ask before wiring it to a chat.
- **`prompt`: self-contained.** A cron run is a fresh session with no chat context,
  so the prompt must carry the full situation, what each token means, and the
  boundaries the agent must hold. See below.

## Write the prompt so the agent acts correctly and stays in its lane

The fired agent has none of your conversation. Give it, in the prompt:

1. **The situation and the mechanism** — what changed and why it matters, in a few
   lines, so it can reason rather than pattern-match.
2. **A per-token action table** — *when `planner_at` flips global→planner, read the
   record and message @ocho; when `kev_window` flips closed→open, message @llama
   with the live reading.* Name the recipient and the exact reading to send.
3. **The boundaries that have held all session, restated** — do not touch the files
   the change depends on; agents propose, the owner applies; read the artifact
   (nvidia-smi, the lease files), never a remembered number; if a token is
   `unknown`, say the source is unreadable and stop, do not guess.
4. **What NOT to do** — especially where another agent is already acting on the
   same state. If a human/agent is self-authorized to run the moment the window
   opens, the watcher must RECORD and CONFIRM, not trigger a second run. Two actors
   on one transition is the double-fire the whole design exists to avoid. Retask
   the watcher's prompt the moment standing authority changes.

## Two controls, same as any instrument

A change-detector is a check, so it gets the same two controls:

- **Determinism control:** run the script twice, confirm byte-identical output. A
  watcher whose output drifts with a clock wakes the agent every tick.
- **Trigger control:** the fired prompt must be able to act on a real transition
  and to stop on `unknown`. Read the prompt back asking *what does it do on each
  token, and on the error token* — if any branch is unwritten, write it before
  scheduling, because an unwritten branch is a turn that acts on a guess.

## When the watcher is the wrong tool

- **The event is a one-shot with a known time** — use a one-shot `in 30m`, not a
  monitor.
- **You need the number, not the transition** — emit the state token; read the
  live value inside the fired agent's own turn, not in the script.
- **The state is not externally readable** — a watcher can only see what a command
  in the script can read. If the only evidence is inside an agent's memory, there
  is nothing to hash and nothing to watch.
