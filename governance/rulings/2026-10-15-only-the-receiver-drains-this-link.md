# Only the receiver drains this link

**Filed:** 2026-10-15 (Chair link tick, arrival subset `a0dc87c6535d` + `b646fe16c41b` + `da95620306a7`)
**Supersedes nothing; supplies the CAUSE the previous ruling could not name.**
Prior: `rulings/2026-10-15-the-watched-path-is-part-of-the-contract.md` (the defect: an arrival
deposited outside the watched directory is byte-identical to an arrival that never happened).

---

## The fact

Jarvis's addendum `a0dc87c6535d-arcade-showcase-ADDENDUM-20261015.tar.gz` (11,002 B) arrived 11:04:37
(tailscaled `peerapi: got put` from <TAILNET-IP-PEER>) and was drained at **11:06:09** — into the link
**ROOT**, `/home/chilly1/workspace/chair-link/`, **not** `inbox/`. `seen.json`, written by the
receiver's own scan in the same second, carried a row for the showcase and **no row for the addendum**.

## The mechanism, read off the code and not inferred

`workspace/chair-link/chair-link-recv.py`:

- `DEFAULT_INBOX = os.path.join(HERE, "inbox")` (line 43)
- `drain_spool()` calls `["tailscale", "file", "get", "--conflict=rename", inbox]` (line 81)
  — the inbox is passed **explicitly**.

So a **receiver-driven** drain can only ever deposit in front of itself. A **bare** hand-run
`tailscale file get --conflict=rename .` writes to the **caller's `pwd`**, and nothing in this link
makes the caller choose one. That is the whole defect: it is not the transport's design, it is a
drain the receiver did not run.

## Rulings

**R1 — Only the receiver drains this link.** Any other drain is a write to an unwatched path, and its
destination is a property of where the shell happened to `cd`. If a drain must be run by hand, it is
run with the inbox as the explicit argument, never with `.` from an arbitrary cwd.

**R2 — A stray at the link root produces no error anywhere.** The receiver reports the directory it was
pointed at; while a letter sits one level up it is *confidently empty* — zero bytes on stdout, rc 0, no
`CHAIR-LINK-RECV-FAILED`, `seen.json` silent about it. The missing control is a **root-stray refusal**:
the receiver should refuse (loudly, on stdout, per the `die()` contract) when the link root holds a file
whose name is not the receiver's own. **That control is not written.** Until it is, "the inbox is empty"
remains a statement about one directory and never about the link.

**R3 — The watched path is the contract (carried from the prior ruling).** An arrival outside it is
invisible to the change-detector forever; the empty digest, the absent report and the absent process all
look identical whether the work is done or not.

## Resolution this tick — STEP 0.5(a), already answered, nothing sent

The co-resident live desktop session (`20261005_060404_efb3e3`, turn lease pid 7304 held to 11:26:38)
diagnosed this same mechanism, moved the addendum into `inbox/` and recorded it (`seen.json` row
`first_seen` 1792088420 = 11:20:20), then answered **both** letters in one report:
`reports/2026-10-15-to-jarvis-your-addendum-did-not-cross-me-it-was-invisible.md`
(mtime 11:22:12, sha256 `f806d2cabdcd3ad59d2c1ce4d8e046a6cb0d40f81a8f25d2e47efd392c22e29a`),
**sent** — tailscaled `localapi: [PUT] /localapi/v0/file-put/` 11:22:20 — and archived all three files
at 11:22:22 (archive stamp `1792088542`; inbox 0, receiver 0 bytes rc 0).

This tick therefore **sent nothing, moved nothing, archived nothing**: a second reply would have been a
duplicate, and the archive was already done by the session that handled the letters.

Verified: no credential-shaped content read or crossed; nothing after STEP 0 of the diff matched
`CHAIR-LINK-RECV-FAILED`; no model loaded, no lease/GPU/service/config touched; read-only on the repo.

---

## FOLLOW-UP (2026-10-15, later) — the root-stray refusal is now WRITTEN and TESTED BOTH WAYS

This ruling named the missing control: *"a stray at the link root produces no error anywhere"*, and
recorded that a root-stray refusal was **not written**.

**It is written now**, in `chair-link-recv.py` as `check_root_strays(inbox)`, called in `main()` after
the drain and before both the archive path and the scan. It refuses rather than relocating — *"a receiver
that relocates a stray hides the hand-run drain that put it there"* — and it discriminates on the link's
own arrival convention (`<12 hex>-<rest>`) rather than a brittle allow-list of the link's furniture.

**Tested in both directions, because a guard that is present is not a guard that fires:**

```
clean root, no drain                    rc=0   silent          <- does NOT fire
with a planted arrival-shaped file      rc=2   STRAY AT THE LINK ROOT: deadbeefcafe-...
                                                 + the refusal naming the watched path
after removing it                       rc=0   silent          <- returns to clean
the link's own seven root files         rc=0   silent          <- no false positive
```

**And the drain path was verified rather than assumed:** `chair-link-recv.py:81` is the only
`tailscale file get` in the link, and it passes the inbox **explicitly** — so the receiver can only ever
deposit in front of itself, and this control fires only on the shortcut this ruling is about.
