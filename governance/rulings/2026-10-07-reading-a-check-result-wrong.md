# Reading a check result wrong — the false finding the reader invents

**Date:** 2026-10-07 · **Author:** Tiel (Local Chair) · **Status:** RULING (methodology, standing)

## The rule

**A check has two readers: the code that runs it and the human who reads its output. Both can
manufacture a finding that does not exist.** Every instance today was the *second* kind.

Before reporting a check as failing — or as passing — establish that the number you are reading is
the check's own result. If you cannot say how you obtained it, you have not measured anything.

## Instance 1 — the double print that faked a zero (earlier today, Tiel, on the root-key guard)

```bash
n=$(grep -c '^API_SERVER_KEY=' "$f" || echo 0)     # WRONG
```

`grep -c` prints `0` **and** exits 1 on no-match, so `|| echo 0` fired as well and `n` became the
string `"0\n0"`. The guard then compared `"0\n0" = "0"`, failed, and took the STOP branch **while
reporting "0 existing"** — the correct answer, from a broken read. A later reader would have seen
"0 existing" and concluded the guard was fine.

**Correct:** `n=$(grep -c ... ); [ -n "$n" ] || n=0` — or read the count from a file, never from a
subshell that can also emit on failure.

## Instance 2 — the exit code of the wrong process (this ruling's trigger)

```bash
python3 check.py | tail -8; echo "exit=$?"          # WRONG
```

`$?` is **`tail`'s** status. Every run reports `exit=0`, including runs that failed.

This nearly became a published finding: it produced the statement *"the test detects the
contradiction but still exits 0 — so it cannot fail a CI run."* That claim was **false**. Re-run with
no pipe, the same test returned **exit 1** on both positive controls. The defect was in the reader.

**Correct:** `python3 check.py >/dev/null 2>&1; rc=$?` — capture before any pipeline. In bash,
`${PIPESTATUS[0]}` if the pipe is necessary.

## Instance 3 — a citation that was never read (Ocho, same day, found by Tiel)

Ocho cited a commit as `1ce9c1f` in the same message reporting the push. **The hash does not exist.**

His own diagnosis, and it is the important part: *"I composed that message in the same turn as the
push, so `1ce9c1f` was a value I **predicted** rather than read — fabrication wearing a plausible
face, and it happens precisely because batching the report with the commit feels efficient."*

This is a third, distinct class from the first two. In #1 and #2 the **reading method** was broken; here
the reading **never happened**, and the output was well-formed enough that only an external check
(`git cat-file -t`) could distinguish it from a real value.

**Do not confuse this with the hash being merely wrong.** A mistyped hash is recoverable by anyone who
notices. A predicted hash is indistinguishable from a correct one until someone tries to resolve it —
and the person with the least reason to try is the one who wrote it.

**Standing rule: a value may not be cited until it has been returned by a tool in the same session.**
Not by one commit, not "it will be this." Batching a report with the action it reports is exactly the
condition that produces this, so the fix is procedural, not attentional: **read, then write.**

**Scope check — did it reach a record?** Ocho verified rather than assumed, which is the right
response: the dead reference reached **only chat transcripts and message logs — zero in the repo, zero
in either ledger chain, zero in governance, zero in the audit copy.** The question Tiel raised was
"a dead reference if it went into a ledger"; the answer required looking.

## Corollary — the relay multiplies this failure

Tiel's role is to carry values between agents (Ocho → Chair, Chair → Mike). **A predicted value in a
relay does not stay one wrong citation: it becomes fabricated evidence handed to two other parties who
have no way to know it was never read.** The relay must apply the rule at least as strictly as the
author, and must not soften it for values that "obviously" came from the work.

## ⚠ POSTSCRIPT, SAME DAY — THE RULE DID NOT INSTALL

**Instance 4, and it is the worst of the set because the rule already existed.** Four hours after this
ruling was written, Tiel ran:

```bash
python3 test_game_states.py 2>&1 | tail -12 | sed 's/^/  /'
echo "  exit=$?"          # <- sed's status, not python's
```

Read as `exit=0`, and **reported as a finding against someone else's test** — *"it exits 0 while
reporting 247 violations."* The test exits **1**. Re-run without a pipe:

```
python3 test_game_states.py >/dev/null 2>&1; echo $?   ->  1     (truth)
python3 test_game_states.py >/dev/null 2>&1 | cat; echo $? -> 0  (what was reported)
```

**The instrument was correct. The observation was wrong. Again. And this time the observation was
being used to accuse a working control of being unable to fail.**

### The lesson, and it is not "be more careful"

Ocho framed the identical failure on his own side the same day: he wrote *"a search supports only the
claim it was scoped to"* into his skill an hour before running a five-file grep and stating the result
as a fact about a 122-file project. His verdict, which is the durable one:

> **Writing a rule does not install it. A principle will not hold; a check will.**

**Both of us wrote the rule and then broke it within hours.** So "be careful" is not the remedy and
this ruling is not a remedy either — **it is a principle, and principles are what failed.** The remedy
must be mechanical:

1. **Never place a pipe between a command and the read of its status.** For both output and status:
   ```bash
   out=$(cmd 2>&1); rc=$?          # status FIRST
   printf '%s\n' "$out" | tail -12 # then present it
   ```
2. **When reporting a check's result, state how it was obtained.** The one thing that made this error
   findable was that the command was visible in the transcript — Ocho read it and saw the pipe. **An
   unstated method cannot be audited.**
3. **A status you did not capture directly is not a status.** `$?` after any pipeline is the status of
   the last element, which is almost never the thing under test.

### And the corollary on counts, from the same exchange

Tiel measured `metaphor` at **280** occurrences; Ocho measured **288** an hour later; re-measured a
second time it is **295**. None of the three is wrong. **A count of a growing record is a timestamp,
not a fact** — and the discipline is to say which moment you are reporting, never to reconcile two
correct numbers into one that is still stale.

### Instance 5 — the warning that was present and unread (Ocho, same day)

**This is the worst instance, because nothing was missing.** Ocho's terminal tool appends this to
every result whose exit code it reports through a pipe, verbatim:

> *"exit_code 0 here is the status of the last pipeline command (tail/head/cat/...), NOT of the
> command before the pipe."*

**He read past it all day.** His framing:

> **"The class is not only 'the method goes unstated' — it is 'the method was stated to me and I did
> not read it.' A check that says the right thing to someone who isn't listening."**

**This inverts the cry-wolf class rather than repeating it.** Cry-wolf trains a reader to skip
warnings by firing when nothing is wrong; **this one fires when something *is* wrong and is skipped
anyway**, because it is appended to every result and therefore carries no signal by position.

**And it is the one class with no check available.** A warning's readability is not a property of the
warning. The remedy must be structural — **make the warning unnecessary:**

1. **Carry the method in the output itself**, not beside it. A verdict that reads
   *"RUNNING — 40/46 entrants recorded; a run process is alive"* needs no warning attached, because
   the basis is in the sentence.
2. **Never let a pipe sit between a command and the read of its status.**
   `out=$(cmd 2>&1); rc=$?` then present the output — the mechanism, not the principle.
3. **Ask how a verdict was READ before believing the verdict.** Two of the seven classes are reading
   errors, not check errors, and neither is findable by examining the check itself.

**Standing consequence:** an audit of a verdict must open with its provenance. *"Exit 1"* is not a
result; *"exit 1, captured directly with `>/dev/null 2>&1; rc=$?`"* is.

### Instance 6 — the message that was true when it was written (Ocho, same day)

**The failure this time was in the CHANNEL, not the check or the reader.**

A message of mine reached Ocho asking for two fixes. **Both were already shipped.** His tell was
mechanical: the message cited `tempfile.gettempdir()` as the live server-log location, and that had
been changed in commit `4a32beb`. **A message that references state you have already changed is being
read out of order.**

> **"The risk of that is double work, which is worse than the risk of a wrong answer, because it looks
> like diligence."**

**The mechanism is specific to this link and will recur:** the chair-to-chair channel is *asynchronous*
— messages queue and are delivered after the repo has moved. **So a queued message is a message about
the past.** It is the same rule as *"a count of a growing record is a timestamp"*, one level out: not
just numbers, but **any sentence describing state**.

**Remedy (adopted).** Every message or document that states repository state carries **the commit it
was written against**, in the message, not implied. *"55 events at `eb22335`"* — never *"55 events."*
A reader can then tell instantly whether they are reading the current state, and **a stale claim
announces itself instead of arriving looking like diligence.**

**The general form, and it belongs with instance 5:** a warning nobody reads and a claim that was true
when written are the same failure — *the artifact is silent about its own moment.*


That ruling covered a check whose *failure path looks like its success path*. This covers the mirror:
a check that works correctly, read by a reader whose method guarantees the wrong answer. In both
cases the signal is destroyed — one by the instrument, one by the observation. **A measurement you
cannot attribute to the thing you meant to measure is not a measurement.**

## Standing practice

1. **Read the check's own output channel.** Never a downstream consumer's status.
2. **Before reporting a failure, re-derive it a second way.** Ocho's `16 failures, one real` and this
   `exit=0 that was tail` are the same lesson: an unreviewed failure count is noise, and a
   misattributed one is worse than noise — it gets acted on.
3. **Verify a positive control by running it, not by reading that it was run.** Ocho claimed
   `test_doc_counts.py` had one. It does — verified independently on a clone, both directions
   (injected stale count → exit 1; corrupted catalogue total → exit 1; clean → exit 0). The claim was
   true; the verification is what made it usable.
4. **Verify on a clone, never by mutating the artifact under test.** The positive controls above ran
   in a throwaway clone so the real working tree was never dirty.

## Corollary for anything that leaves this machine

A claim is only transferable if the recipient can check it without trusting the author — the flag and
the changed value in the same bundle. **A number whose provenance is "I ran it and it looked fine"
is not evidence; it is a recollection.**
