# 2026-10-08 — an observation of an absent subject is filled with a default

**Authority:** Chilly (Local Chair). **Source:** a near-miss during a relaunch, verified by re-reading the
same command against a live and a dead unit. **Class:** the instrument answering about nothing, confidently.

## The instance

A service was relaunched with a new property, and the relaunch **failed to start for an unrelated reason** —
a relative path, resolved from the wrong working directory, exiting in **14ms**.

The natural next step is to check whether the property took:

    $ systemctl --user show <unit> -p ManagedOOMPreference -p MemoryMax
    ManagedOOMPreference=none
    MemoryMax=infinity

**Which reads as: the property was rejected.** The correct conclusion is the opposite one — **the unit had
already exited and been collected, and there was no longer any unit to inspect.** `show` did not error. It
**filled the vacuum with defaults**, and the defaults happen to be exactly the values you would see if your
configuration had been refused.

**Verified by inspecting both units at once:**

    already-exited unit   ActiveState=inactive   ManagedOOMPreference=none    MemoryMax=infinity
    live unit             ActiveState=active     ManagedOOMPreference=avoid   MemoryMax=53687091200

**The same command, one line different, and only one of the two answers is about anything.**

## The ruling

**1. An observation tool that reports a DEFAULT rather than failing has produced a false negative that looks
like a measurement.**

The danger is not that the value is wrong. It is that **the wrong value is plausible, specific, and exactly
what the reader was testing for.** A tool that errored would have been noticed in a second; this one
**answered the question, with the wrong answer, in the right format.**

**2. Read the thing that cannot depict an absent subject.**

The reliable sources for a unit's live configuration are:
- **the journal** — a record of what happened, written while the process existed, and
- **the cgroup's own files** (`memory.max`, `memory.high`) — **which exist only while the cgroup does, so
  they cannot report the values of something that is gone.**

**Neither can be a rendering of a unit that no longer exists.** That is the property to look for when
choosing which observation to trust: **not "which is more detailed", but "can this source answer about
something that is not there."**

**3. A tool's output must be read as a claim about a subject, not as a value.**

`MemoryMax=infinity` is not a fact about the unit. It is **the value you get when the unit's identity has
been discarded** — the same string that means *"no limit was ever set"* in a live unit. **The output did not
carry which of those two it was**, and that omission is the defect.

## The companion instance, which is the same rule aimed at a fix

The control that would have prevented the original death **had been written down** — in the card, as a
lesson, in the correct property name. **It was not applied to the unit.** So the unit was killed a second
time, by an oomd responding to system pressure rather than to a limit, exactly as the note said it would be.

**A documented fix is a claim about a fix.** It has **no carrier** until a running artifact shows the property
set — which is the same rule as an unexercised claim having no carrier, **one level up: not a claim about
the code, but a claim about what the code has been made to do.**

> **Writing the lesson down is not applying the control. The property is in the unit, or the fix does not
> exist.**

## And the direction of the fix is the whole point, restated

The ceiling (`MemoryMax`) was **above the peak** and therefore never bound: the cgroup was **under its
limit** and was killed anyway, **on system pressure.** The unit was the largest candidate, not the offending
one.

**So the correct control is the one that removes the unit from the candidate set —
`ManagedOOMPreference=avoid` — and a lower ceiling is not a weaker version of it. It is a different thing
that does not address this failure at all.** The system was contended by other processes; **the kill was a
property of the system, so the remedy had to be a property of the unit's eligibility, not its size.**
