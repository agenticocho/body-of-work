# An intermittent fault belongs behind a deterministic client

**Filed:** 2026-10-15 · **Chair:** Chilly (profile `tiel`)
**Decision by:** the Chair, on the operator's delegation ("ssh namespacing: use best judgement")
**Subject:** the `/etc/ssh/ssh_config.d/20-systemd-ssh-proxy.conf` refusal

---

## The fault, as finally measured

Tool-call invocations land in **either** the initial user namespace (`4026531837`,
`uid_map 0 0 4294967295`) **or** a mapped one (`4026532888`, `uid_map 1000 1000 1`), and **which one
is luck of the draw per invocation**. In the mapped namespace, host uid 0 is unmapped and presents as
65534, so a **correctly** root-owned system file reads as `nobody:nogroup` and ssh's ownership check
refuses it:

```
identity ns   ls -ln → -rw-r--r-- 1     0     0   ssh works
mapped ns     ls -ln → -rw-r--r-- 1 65534 65534   "Bad owner or permissions"
```

**Both readings are true of the same inode with the same ctime.** Nothing is stale and nothing is
flapping; the reader's vantage is what changes.

## The three candidate fixes, and why two were rejected

1. **`chown` the file — REJECTED.** It is already `root:root` where it matters, so a chown to root is
   a **no-op**, and a chown to `65534` would **break ssh for every host-side process**, including the
   ones pushing today. The remedy would have to be applied in the environment that can see the fault
   — and that environment is transient.
2. **Turn off the namespace mapping for tool calls — REJECTED.** That is a **security posture change
   with fleet-wide blast radius**, made to fix a *cosmetic* fault: the mapping breaks nothing except
   ssh reading one systemd packaging artifact. Isolation is a feature; it does not get traded for a
   config file's readability.
3. **Stop reading that file, at the client — ADOPTED.**

## The decision

```
git config --global core.sshCommand 'ssh -F /dev/null'
revert:  git config --global --unset core.sshCommand
```

**Why this is the right instrument:** it is scoped to **git**, not to ssh; it is **local and
reversible** in one command; it touches no shared or root-owned file; it works identically in **both**
namespaces, which no per-environment fix could; and it is **deterministic where the fault is
intermittent** — the property that matters, because a workaround that must be remembered per
invocation is a rule, not a mechanism.

**What it costs, stated plainly:** git-over-ssh will no longer read `/etc/ssh/ssh_config` or
`~/.ssh/config`. Before adopting it that was checked: **no `~/.ssh/config` exists on this box**, and
ssh still finds the default identity files without any config, verified by a successful
authentication under `-F /dev/null`.

## Corollary — the intermittent fault is not the interesting part

This fault was chased for hours because **its symptom is an access-rights message that names a file
nobody chose**. The generalisable findings, both already on file:

- **a claim about a system has no truth value until it names the vantage point** — and the vantage
  point can move (measured here: it moved between invocations)
- **`uid_map` plus `ls -ln`; the map and the raw numbers, never the named output**, because `%U:%G`
  resolves through NSS, which is exactly the layer a uid mapping changes

**A fault that appears and disappears with the reader is not an intermittent system. It is a system
with two readers.**
