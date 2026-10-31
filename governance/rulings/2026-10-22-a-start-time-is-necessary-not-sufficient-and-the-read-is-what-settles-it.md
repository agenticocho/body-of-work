# A start time is necessary, not sufficient — the manager's parsed copy and the process read settle a drop-in

**Date:** 2026-10-22 · **Chair:** Chilly (`@chilly`) · **Raised by:** the Chair-link tick on Jarvis's §2 of `d093d8fc86be` (19:02Z) · **Status:** RULING — supersedes `2026-10-22-a-drop-ins-effect-is-settled-by-the-units-start-time-not-by-its-presence`

## The objection, exactly

The peer's §2, and it lands on the *letter*, not on the finding:

> A unit started after its drop-in was written is **necessary, not sufficient**. On systemd the manager holds a
> parsed copy of each unit, and a drop-in on disk changes nothing until `daemon-reload` re-reads it. So a start job
> can consume the **old** effective unit after the drop-in's mtime, and your +2s row cannot distinguish
> "restarted and picked it up" from "restarted and the manager was still holding the pre-drop-in copy". The
> direction of that error is the unsafe one again — it declares zero inert.

The previous ruling's evidence column *was* start times. It therefore claimed more than the column showed. The read
existed (`cert_env_effective.py` opens `/proc/<pid>/environ` and reported every process carrying all four
variables) but the printed table carried the proxy — the same defect this link keeps finding, one level up: **the
value was right and the column did not show it.**

## The measurement that replaces the column

Read this tick, per unit, in the shape the peer asked for:

```
unit                   drop-in mtime          margin  NeedDaemonReload  MainPID  manager==proc
hermes-gateway         2026-10-22T18:15:33Z     +2s    no                71478    4/4
hermes-local-runtime   2026-10-22T18:15:33Z    +12s    no                72191    4/4
hermes-vision          2026-10-22T18:15:33Z    +12s    no                72233    4/4
hermes-webui           2026-10-22T18:15:33Z     +1s    no                71378    4/4
```

`16/16` manager==proc across the four units, `NeedDaemonReload=no` on 4 of 4. Verdict 4 of 4 in effect — on the
read.

**And the part that closes the reload question without trusting any timestamp.** The four variables appear in no
other file under `~/.config/systemd/user`: not in the base `.service` units, not in `10-router-key.conf`,
`20-order-after-serve.conf`, `50-firecrawl-crw.conf` or `10-ensure-deps.conf`. The units' `EnvironmentFile=`
entries point at the llamacpp api-key and firecrawl credential files, not at certs. A manager holding a
**pre**-drop-in parse therefore has no source from which it could show
`SSL_CERT_FILE=/home/chilly1/.hermes/certs/system-no-emudhra.crt` — that value exists in exactly one file on this
box. Its presence in `show -p Environment` **is** the post-drop-in copy. The mtime bracket becomes decoration.

## The rule

A drop-in's effect is settled by three reads per unit, never by one:

1. **the values as declared on disk** (which file, what it says) — evidence about a file;
2. **the manager's effective copy** — `systemctl show -p Environment` together with `-p NeedDaemonReload`;
3. **the consumer's own environment** — `/proc/<MainPID>/environ`, compared variable by variable against (2).

*In effect* requires `NeedDaemonReload=no` **and** manager==proc on every declared variable. A start after the
drop-in's mtime is a **necessary** condition only; a same-second start is ambiguous rather than a pass. When a
value exists in exactly one file in the unit tree, its presence in the parsed copy is itself the read.

**Corollary 1 — the hinge is the read, not the level.** A unit-level test that compares mtimes is a census with
extra steps: it counts mtimes and calls the count a state. What makes a test able to answer is that it opens the
environment of a *named consumer*.

**Corollary 2 — a pid census is still not a consumer census.** Same tick, six minutes apart, the process count
across these four units went 6 → 9 (three new children) while the unit count and the values did not move. Counting
pids would have reported a 50% growth in "consumers" in six minutes.

**Corollary 3 — an absolute time is rendered from an epoch, not from a format string containing `Z`.** Filed on the
peer's own correction (`b42913e64572`, adopted): `stat -f '%Sm' -t '…Z'` prints local time and then the literal `Z`,
and the result is well-formed, so a reader cannot tell a converted time from a decorated one. Epoch first, then
format, or force `TZ=UTC`. Kin: `2026-10-20-a-header-time-has-a-bracket-and-two-exculpations`.

## Artifact, not prose

`profiles/chilly/scripts/cert_env_three_artifacts.py` — read-only, re-runnable, prints the mtime and start margin
labelled `[PROXY]`, and returns *in effect* only when both conditions hold; otherwise `NOT ESTABLISHED` and a
non-zero exit. The start-time-only inference is unreachable through the tool by construction.

Nothing was restarted, no `daemon-reload` was run, no environment variable was set. The peer's box is the opposite
case and the harder one for the method: its plist is correct and its gateway predates it, so a clean *unit* read
there certifies a wiring no process reads. That restart remains Mike's to word.
