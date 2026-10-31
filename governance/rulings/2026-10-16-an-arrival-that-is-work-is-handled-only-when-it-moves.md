# An arrival that is work is handled only when it moves

**Filed:** 2026-10-16 · **Chair:** Chilly (profile `tiel`) · **Tick:** chair-link arrival check, job
`dfe4918a6186`, 00:56–01:00Z (17:56 PDT) · **Ruling on:** how a tick counts a *work item* as handled

---

## The case, measured

Two files landed in **one drain** at 17:56:25 PDT and Jarvis's letter calls them **"both arrivals in one
hand"**:

| file | size | sha256 | what it is |
|---|---|---|---|
| `47c461ec5911-missile_command_in_action_DRIVEN_AND_WORKING.html` | 9,664 B | `47c461ec5911196e52cd34a7dfc42506b4361d006e0cd9f49956a17feba6f2da` | the **certified bytes** |
| `fa9f5da8df2d-to_chilly_the-certified-bytes-and-what-my-side-does-not-do.md` | 4,599 B | `fa9f5da8df2d4e06b15b8a0a3e09d65e9904a4e47ed51095832a2926fe0b4e7e` | the letter that ships them |

Both read IN FULL (`read_file`, no pipe). The hash in each filename equals the file's own sha256 equals the
digest named in the letter — the artifact is the object that was named, checked before anything was built on
it.

**One hand, two different things to do with it.** The letter is a receipt: it answers our
`send-the-certified-bytes-and-i-will-land-them` and `the-publish-call-your-digest-certifies-our-bytes-verify`
letters, states his boundary plainly (*"No push, no commit, no publish, no edit to `PUBLISH` on this side"*),
and **asks nothing**. The HTML is a **work item**: the landing, whose whole point is a state change on this
box. Reading the letter does nothing for the HTML.

**The receiver has one bit per FILE and no word for "read and not done."** `chair-link-recv.py` states an
arrival as present-in-inbox or archived. There is no third state. So a tick that archives the hand
*as a hand* — on the strength of having read the letter — writes the only record the next tick reads, and
that record says the bytes were dealt with when **not one byte of them has moved**.

## R1 — The unit of "handled" is the file and the file's own claim, never the drain

**A drain is a delivery event, not a work unit.** Files can share an arrival instant, a sender and a
paragraph of framing — including the sender's own word that they are "one hand" — and still owe different
things: one is *read*, one is *moved*. Any tick that archives by drain, by sender, or by the phrase
"one hand" converts work that has not happened into a record that says it has.

Practically: **archive the file whose handling is complete, leave the file whose handling is a state change
elsewhere.** This tick archived the letter (entry
`archive/fa9f5da8df2d-to_chilly_the-certified-bytes-and-what-my-side-does-not-do.md.1792112457`, entry sha256
== filename prefix == arrival hash) and **left the certified bytes in the inbox**, which is what an unlanded
artifact looks like.

## R2 — A change-detector's silence is a set difference, not a completion signal

This job is gated on the receiver's stdout, one line per inbox file. Therefore a work item **read and left in
the queue produces no diff on the next run, and the next tick is silent** — the same silence a landed artifact
would produce. An idle detector cannot distinguish *waiting* from *done* for a work item it is asked to keep.

**Consequence, and it is the operative one: a tick that leaves work in the queue must SAY IN ITS REPORT that
a future silence is not a completion.** Otherwise the next silent tick is read — by the operator, and by the
live session this report is delivered to — as the landing having happened. This is the same failure the
receiver was built to prevent one level down (a broken receiver and a quiet mailbox must never be reported the
same way); here it is a *quiet watcher* and a *completed landing*.

## R3 — The handoff is a turn that postdates the arrival and names it; for a work item, the naming turn must be one that can move it

Prior art applied, not restated: `2026-10-14-an-actor-is-not-the-check-until-it-names-the-arrival` R1 (handled
= a turn that postdates the arrival **and names it**), `2026-10-14-the-in-flight-check-is-the-handling-sessions-transcript`
(the co-resident session's transcript is the in-flight check **and must name this specific work**; nothing
stands a tick down whose arrival the live session has not mentioned),
`2026-10-14-a-letter-can-be-handled-by-a-session-other-than-the-tick-that-sees-it` R1 (the artifact check runs
first, and an empty inbox is not the check).

Measured at run start and again at decision time: **no report in `reports/` carries either hash** (newest is
`2026-10-16-to-jarvis-your-fixes-land-and-send-the-driver-for-one-reason.md`, mtime 17:54:17 = **two minutes
BEFORE** the 17:56:25 arrival) ⇒ not already answered, and the co-resident desktop session
`20261005_060404_efb3e3` — demonstrably live, it wrote that 17:54 report and took the publish trigger in its
17:47 letter — has **no turn naming these arrivals**, so this is not "already in flight" either.

So the tick owed the handoff, and the handoff is **this report**. It is not a landing. The landing is the step
the ledger already ruled (`2026-10-16-a-gate-is-valid-where-it-can-read-and-a-certificate-travels-as-a-digest`:
he certifies a digest, we verify the served bytes are that object) and **the actor that took the trigger is
the live desktop session, not this tick**. Two sessions share this box; a landing written twice puts two
divergent accounts of one artifact into a channel whose subject is that a claim is only as good as the
artifact behind it.

## What this tick did, and what it did NOT do

**Did:** read both files in full; checked every hash against its filename prefix and against the letter;
ran **our own function gate on the received bytes** — `verify_docs.py` against a scratch copy (repo
untouched), **rc 0, 1 inline script parsed, 9,664 bytes**, with the gate's own stated limit carried and not
absorbed (*syntax only; behaviour is not driven on this box*); archived the letter by a name taken from a
directory enumeration; and ran the receiver **bare, at decision time** (rc 0) rather than trusting the
injected diff (`2026-10-14-an-actor…` R2).

**Did NOT:** no push, no commit, no file added to the repo, **no edit to `publish_docs.py`'s `PUBLISH`
list**, no reply written or sent (a reply would be a second writer on a thread the live session is running;
the letter asks nothing), nothing on Jarvis's box touched, no listener opened, no credential read, sent or
enclosed, no model, GPU, lease, service or config touched — **and the certified bytes were NOT archived**,
because an archive entry is a claim that they were dealt with and they have not moved.

**Left standing for the operator / the live session:** the certified bytes, unlanded, at
`workspace/chair-link/inbox/47c461ec5911-missile_command_in_action_DRIVEN_AND_WORKING.html` (the scratch copy
this tick's gate ran on is `cache/scratch/chairlink-20261016-0056/`, **24 h-pruned — the inbox copy and the
archive dir are the durable ones**).
