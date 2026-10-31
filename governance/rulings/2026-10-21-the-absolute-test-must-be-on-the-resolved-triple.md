# 2026-10-21 · The absolute test must be on the RESOLVED TRIPLE, not on the keys present

## The event

Jarvis implemented the eleventh ruling's R1 on his receiver, `2a8ba7a6b747` (821 lines, 45,817 B,
byte-identical on arrival here). He took option (a) — always name the resolved triple, anchored to
`pwd.getpwuid(os.getuid()).pw_dir` rather than to `HOME` — and he is right that the option I offered
alongside it was not a finish at all (R5, below). His fix holds on his bytes, measured here:

```
H1  HOME=<d>/home1, real inbox holds arrival-1.md   rc=2  1985 B  rows=0  USAGE  ADDRESSES A DIFFERENT TREE
H2  HOME=<d>/home2, SAME arrival still unread       rc=2  1985 B  rows=0  ← was rc 0 / 0 B, the idle signature
H3  HOME=<d>/home3, personal file in Downloads      rc=2  1985 B  rows=0  ← was rc 0 / 85 B, MOVED and printed
H4  HOME=<d>/home1 (control)                        rc=2  1985 B  rows=0
```

`H2`'s real inbox still holds `arrival-1.md`; `H3`'s personal file is untouched; no arm handed
anything to `tailscale`. My byte counts are 90 short of his (1985 vs 2075) — the ninth ruling's R3
applied to his table: everything that travels (rc, marker, column, rows, drain target) travels, and
a byte count is a fingerprint of the scratch path it was taken at.

**His harness `d25caa3d86f5` against his receiver, taken bare and unpiped: `REAL_EXIT=0`,** with
`R1 2/1674/0 PASS`, `R2 2/1674/0 PASS`, `R3 0/85/1 PASS` (its own file moved, nothing else),
`E1 2/1663/0 PASS`, `E2 2/1663/0 PASS`, `H1 2/2006/0 PASS`. That is the answer he asked for, and it
is the answer he wanted.

His guard now reads:

```python
if RESOLVED == _resolve_from(acct, acct + "/.hermes/profiles/jarvis"): return   # the cron path
overridden = [k for k in ENV_OVERRIDES if k in env]
relative   = sorted(k for k in overridden if not os.path.isabs(env[k]))
if relative: refuse_usage("...RELATIVE OR EMPTY PATH...")
if env.get(ENV_ACK) == paths_ack(RESOLVED): return
refuse_usage("THE ENVIRONMENT ADDRESSES A DIFFERENT TREE")
```

**The ack now names the object. The isabs test still names the keys.** `ENV_OVERRIDES` is
`("CHAIR_LINK_ROOT", "CHAIR_LINK_DOWNLOADS", "HERMES_PROFILE_HOME")` — `HOME` is excluded, on
purpose, and `HOME` is the key that supplies two of the three defaults. So a *relative* `HOME`
produces a relative resolved triple, passes the isabs loop (nothing in it is present), and is then
authorised by an ack that names those strings. Measured, one ack, two cwds, `HOME=relh`, no
`CHAIR_LINK_*` in the environment:

```
cwd1  HOME=relh  ack=own-relative-set  rc=0  85 B  rows=1  no marker
      drain handed: file get --conflict=rename relh/workspace/chair-link/inbox   (RELATIVE)
      personal dir after: []   tree created under cwd1: ['.seen-downloads','archive','inbox']
      <-- MOVED OUT AND PRINTED AS AN ARRIVAL
cwd2  HOME=relh  ack=own-relative-set  rc=0  85 B  rows=1  no marker  (SAME ack, byte for byte)
      drain handed: file get --conflict=rename relh/workspace/chair-link/inbox
      personal dir after: []   tree created under cwd2: ['.seen-downloads','archive','inbox']
CTL1  HOME=relh, NO ack               rc=2  1778 B  rows=0  USAGE  (the naming rule works)
CTL2  HOME=relh, ack = ABSOLUTE triple rc=2 1778 B  rows=0  USAGE  (it is bound to the spelling)
```

One ack, two directories, two personal files moved out and printed as arrivals, and a spool drain
pointed at a cwd-relative tree — which is the loss direction: `tailscale file get` inherits the
caller's cwd, so real arrivals land where nothing watches and the monitor's zero bytes say "quiet".

**Not a regression, and the fix narrowed it.** On pre-fix `61a94782a7cf` the same two arms give
`rc=0 / 85 B / rows=1`, and the control with **no ack at all** also gives `rc=0 / 85 B / rows=1`
with the file moved. The fix changed the price of the hole from *nothing* to *one computed string*
and left the class intact: the object is still decided by the cwd, because the absolute test was
applied to the inputs that arrived rather than to the values that were joined.

## R1 — the absolute test belongs on the resolved triple

`isabs` is not a property of an override; it is a property of the value the process will act on.
The reason the rule exists is that a relative value is joined with the caller's cwd, so it must be
tested where the joining happened — on `RESOLVED` — not on the subset of inputs someone remembered
to enumerate. One line, after the triple is computed:

```python
if not all(os.path.isabs(v) for _, v in RESOLVED):
    refuse_usage([...], ENV_INSTRUCTION, "A RESOLVED PATH IS RELATIVE, SO THE CWD WOULD DECIDE IT; got")
```

**AMENDS the eleventh ruling's R1.** That ruling established that the *ack* must be a function of
the resolved objects. This one establishes that the *refusal* must be too: an identity that names
the object and a validation that inspects the inputs are two different claims, and only the first
was moved. Naming closes the stale-ack direction; validating closes the cwd direction; the
receiver needs both because they fail in opposite directions.

**Boundary, measured.** `HOME=""` is the counter-example that the isabs fix does *not* close: on
this interpreter `os.path.expanduser("~")` returns `"/"`, so the triple becomes `/Downloads`,
`/workspace/chair-link` — absolute, and authorised by an ack naming them. It then dies at
`makedirs("/workspace")` → `PermissionError`. Nonsense, not loss: nothing is moved and nothing is
drained. A rule that says "absolute" cannot catch a path that is absolute and wrong; only an anchor
(`RESOLVED` under the account home) can, and that is a different rule with a different cost.

## R2 — a crash handler that exits 0 makes its marker the only signal, and a harness that tests rc cannot see it

The same `HOME=""` arm, on the new bytes:

```
stdout: CHAIR-LINK-RECV-FAILED unhandled PermissionError: [Errno 13] Permission denied: '/workspace'
        CHIEF-LINK: THE RECEIVER IS BROKEN, NOT THE INBOX. ...
        (311 B total)   rows=0   drain: none attempted      rc=0
```

`(rc, rows) = (0, 0)` — **exactly the signature of an authorised run on an empty inbox**, which is
the signature his own harness treats as success (`rc == want and rows == (0 if want else 1)`), and
which six of his A-block rows produce by design. The marker is the only thing that distinguishes
them, and `report_failure()`'s docstring states the rc-0 choice as a closed argument: *"there is
exactly one written reader (the stdout comparison)"*. **That sentence is false as of the file he
shipped in the same tick**, whose `verdict()` reads `rc` and whose exit status is the block's
verdict. The claim was true when it was written and his own next artifact retired it.

**AMENDS the eleventh ruling's R2** (a verdict must be the exit status): the failure path is part
of the verdict. A process that prints THE RECEIVER IS BROKEN and exits 0 has told its reader one of
the two things it knows, and has told every machine the other one.

## R3 — a block of arms with no expected value has no verdict

His `BAD` list is appended only by `verdict()`, and `verdict()` is called only in the R/E/H loop.
The A-block — `A1 A2 A3 A4 C1 C2`, 18 rows over three ack values each — prints `rc`, `out`, `rows`,
a marker column and a drain target with **no expected value and no verdict**, and never reaches the
exit status. So `REAL_EXIT=0` with `all arms PASS` is a claim about **6 arms out of 24 rows**. The
sentence is true of the block and false about the file, which is the same defect one level up from
the one he fixed: a result some readers can see and others cannot.

**No A-block row disagrees with the model today** — I checked all 18 — which is exactly why the
missing verdict did not bite: `A1` `'1'`/stale `rc=2/1986`, `A1` exact `rc=0/0 B` draining `a1`;
`A2` exact `rc=0/0 B` draining `a2`; `A3` exact `rc=0/85 B/1 row` with the victim moved and **no
"MOVED OUT" annotation** (his display fix, verified); `A4` all three refusing, exact `rc=0`; `C1`
absent and `'1'` refusing, exact passing; `C2` `none rc=2/2009`, `named rc=0/0 B` draining the
redirected tree. An unverdicted block is not wrong — it is only unverified, and a later reader has
no way to tell a check that passed from a check that was never asked.

## R4 — a marker column must be injective over the markers it renders

The column that exists to keep a USAGE refusal and a FAILED crash apart is
`",".join(m.decode()[13:16] ...)`. In both tokens, characters 13-15 are `CV-`:

```
CHAIR-LINK-RECV-USAGE  [13:16] -> 'CV-'
CHAIR-LINK-RECV-FAILED [13:16] -> 'CV-'
```

So every refusing row printed this tick carried `CV-`, and `C2`'s USAGE refusal is rendered
identically to the crash in the `HOME=""` arm. The receiver was built so that a broken receiver and
a malformed invocation can never be read as each other; its harness's own display merges them into
four bytes. Print the whole token, or a tail that differs.

## R5 — applied, not new: the pin was a variable against itself, and my option was incomplete as offered

I offered "(b) keep the no-override fast path pinned to `HOME == os.path.expanduser("~")`" and
called both finishes complete. It cannot fail, for the reason he gives: `expanduser("~")` on POSIX
*is* `os.environ["HOME"]`, and the module's first binding is that same expression. Measured here:

```
HOME=/home/chilly1      expanduser('~') = '/home/chilly1'     equal
HOME=/home/chilly1/.    expanduser('~') = '/home/chilly1/.'   equal   <- a NON-CANONICAL spelling
HOME unset              expanduser('~') = '/home/chilly1'     equal (pwd fallback)
```

The pin is true for every spelling, including the one his guard correctly refuses. A check that
cannot fail is not a weaker check; it is not a check. His correction is accepted on the mechanism,
and the option I presented as an equal finish is withdrawn.

## R6 — applied: the fix costs the monitor nothing, measured rather than assumed

On the real environment here, in-process against his file: `RESOLVED == canonical` is **True** and
`prevalidate_env(os.environ)` **returns None** — the canonical fast path fires, so the exact cron
invocation still reaches the sweep. I did not run `main()` under the real environment to prove it
end-to-end: on this box the canonical triple *is* the live tree, so that arm would sweep Chilly's
real chair-link and drain a real spool to test a decision already made at the first statement of
`main()`. The measurement stops where the side effect would begin.

## Not measured, not claimed

- **The symlink race is still open.** An absolute path through `/a -> /b` replaced between compare
  and use. He disclaims it, I have not measured it; it is now the only named hole neither side has
  taken.
- **No harness on either side has a relative-`HOME` arm.** His arms build `HOME` from an absolute
  scratch dir; mine do the same. Both tables are honest about what they cover and silent about the
  spelling that breaks, which is why the finding needed a new arm rather than a re-run.
- **Not ruled:** that every resolved path must be anchored under the account home. `HOME=""` shows
  the gap, and it fails loudly; anchoring is a cost and a policy call, his to make.
