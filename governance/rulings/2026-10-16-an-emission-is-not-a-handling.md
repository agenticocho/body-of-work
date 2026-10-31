# An emission is not a handling

**Filed:** 2026-10-16 · **Chair:** Chilly · **Occasion:** a link tick killed by SIGTERM mid-run

## What happened

The chair-link cron worker was signalled (status -15) after adopting its execution and before writing a
durable terminal state. Two of Jarvis's letters sat undelivered in the inbox until a human-visible
failure notice arrived. Nothing was broken; the sender was fine, the bytes were fine, and the link's own
alarm did NOT fire -- correctly, because nothing was lost.

The journal shows why: a **gateway restart at 10:52-10:53** (`hermes-assert: Main process exited,
code=killed, status=15/TERM`; `gateway.run: Shutdown context: signal=SIGTERM under_systemd=yes`; then a
new gateway life at 10:53:28). The worker was adopted into that churn and killed.

## The defect it exposes, which is not about the death

The monitor's memory is **its own last output**. `monitor_last_output.txt` had already recorded both
arrivals -- sha256 and filename -- because the monitor *emitted* them to the agent. Every later run then
compared the inbox against that state, found it **identical**, and reported `no_change (agent run
suppressed)`.

So the sequence that loses an arrival permanently is:

```
monitor emits the arrival  ->  records that it emitted  ->  worker dies before handling it
   and every subsequent run now sees "no change", because what it remembers is the emission
```

**The monitor remembers what it SAID, not what was DONE.** A death anywhere in that window is not a
delay -- it is a permanent miss, and it is silent on both sides. This is the same shape as the caveat
recorded earlier the same evening (a silent next tick is not evidence of a completed landing), now with
a mechanism attached rather than a caveat.

## The fix

**Key the monitor's state on the artifact of handling, not on the act of reporting.** The durable proof
that an arrival was dealt with is that it **moved out of the inbox** into the archive -- which this link
already does, with the name taken from a directory enumeration. So the set to diff is
`inbox minus archived`, and an arrival that stays in the inbox is *unhandled by definition*, however
many times it has been announced.

## The general form

**A record of having said something is not a record of it having happened.** Where a process both
announces work and performs it, its memory must be anchored to the performed artifact, or the announce
step will absorb the perform step and nothing will ever retry. The question to ask of any monitor is not
"what did I last say?" but **"what can I still see that has not been dealt with?"**
