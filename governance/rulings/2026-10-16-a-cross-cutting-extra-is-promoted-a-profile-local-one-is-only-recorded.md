# An EXTRA is promoted when its claims are about ANY pair of boxes, and only recorded when they are about this one

**Filed:** 2026-10-16 · **Chair:** Chilly · **Decision on:** card `t_2f1cc28b` — the finding reported and
deliberately not fixed by `t_b76ce8e3`, gated on it and named in
`rulings/2026-10-16-a-drift-report-and-a-push-plan-are-two-questions-on-one-unit.md` (§"The finding this
instrument made on its first live run")

---

## The decision

**PROMOTE.** `references/cross-machine-transport.md` (4,399 B · sha256
`d2bb3a22373e716b5ec48e764e8f98a80b79f527a4571255308e78ec90ff4b72`) was written by a live tiel session
into tiel's copy of `selfhosted-hermes-ops`, exists in no other root, and is now a file of the canonical
source `~/.hermes/skills/selfhosted-hermes-ops/references/`, carried to every non-bundled root by
`skills_push.py --push`. The re-keyed fleet report goes **green** for that name: the EXTRA is gone because
the file is now a source file, not because anything was deleted.

**R1 — THE TEST FOR "CROSS-CUTTING" IS WHAT THE FILE'S CLAIMS NAME, NOT WHICH BOX LEARNED THEM.** Read
full, the file names no profile, no profile-local path, no box-local state and no box-specific fact. Every
claim is about a **channel** (`tailscale file cp`, `journalctl -u tailscaled | grep file-put`,
`git ls-remote`, `ssh -T git@github.com`, `git config core.sshCommand`) or about a **reader** (a uid
rendering through NSS, `/proc/self/uid_map`, `ls -ln`). Knowledge learned on this box whose statement is
about the class of all boxes belongs to the fleet; knowledge whose statement is about *this* profile's
counters, leases, paths or credentials stays local. The learning site is not the test — the claim site is.

**R2 — THE PROMOTION CARRIES THE ARTIFACT BYTE-IDENTICALLY, AND THAT IS THE POINT.** The promoted file is
the bytes tiel wrote, unchanged: same 4,399 B, same digest, now present in all 10 non-bundled roots with
ONE digest. A promotion that silently re-words or re-sections the document destroys the only property that
makes the report checkable — that the thing the report named is the thing the fleet now holds. If the
document needs re-styling, that is a *second* edit, filed at the source, after the promotion.

**R3 — A PROMOTED REFERENCE MUST BE REACHABLE FROM `SKILL.md`, AND THE POINTER IS WRITTEN AT THE SOURCE.**
The source `SKILL.md` gained (a) a pointer paragraph at the top and (b) a `## Support files` row, each
naming the new file and its relation to the two references it overlaps. A reference nothing points at is
cargo: it loads only if someone already knows the filename. The RULE about the relation lives in
`SKILL.md` so the three files cannot silently drift apart in their claims about each other.

**R4 — AN EXTRA IS REPORTED, NEVER DELETED, AND NEVER PROMOTED WITHOUT A RULING.** `EXTRA` is not drift for
a push (a push never deletes) and it is not an instruction either. The class means *"a file this root holds
and the source does not"* — which is exactly what profile-local knowledge looks like from the source's
side, so it must be decided, not swept. Until this card, the red stayed red and the file stayed put;
that is the correct steady state, not a defect. The report's job is to make the file visible; the ruling's
job is to place it.

**R5 — THE PUSH IS THE ONLY PROMOTION MECHANISM.** The file was copied into the source and then carried by
`skills_push.py --push` (17 files, 9 root/name pairs, 9 overwrites backed up under
`skill-push-backups/20261016T010820Z/` with a manifest). Copying it into the nine profile roots by hand
would be the same error inverted: a fleet the source does not hold, with the pusher red for ten roots, and
no path back.

**R6 — THE STATE AFTER IS MEASURED BY BOTH INSTRUMENTS, AND BOTH GREENS MUST BE NAMED SEPARATELY.**
`skills_drift.py` exit **0** (78 names, 11 roots: every source name in every root, same file set byte for
byte, and **no EXTRA anywhere**); `skills_push.py --check --all` exit **0** with **0 root/name pairs
drifting and 0 roots holding files the source lacks**. The invariant `drift red ⟺ DRIFT / ABSENT / EXTRA`
still holds with **0 violations** (`compare_instruments.py`, 59 shared names). The two greens answer two
questions and are two lines of evidence; one of them alone would not have shown that the extra is gone.

**R7 — THE PUSH CHANGED `SKILL.md` FLEET-WIDE, AND THAT IS THE MECHANISM WORKING, NOT A SIDE EFFECT.** The
fleet was uniform before (`SKILL.md` 139,710 B · sha256 `cd1678a9…` in all 9 backed-up copies) and is
uniform after (141,072 B · sha256 `2ca4d186…` in all 10 non-bundled roots). One edit at the source plus one
push is how ten roots change together; the alternative — editing ten copies — is drift by construction.
The bundled tree (`~/.hermes/hermes-agent/skills`) holds no `selfhosted-hermes-ops` at all and was never a
target.

## The measurement that decided it

```
instrument                                   before (card t_b76ce8e3)   after (this card)
skills_drift.py                              exit 1 — DRIFT              exit 0 — OK, no drift
  selfhosted-hermes-ops: 10 live copies      2 distinct file sets        one file set
  tiel's copy                                extra 1 (the file)          no extra
skills_push.py --check --all                 exit 0, tiel OK·EXTRA       exit 0, 0 extra pairs
compare_instruments.py                       PASS, 0 violations          PASS, 0 violations
independent re-walk (not the tools' word)    59×10: 0 missing/differing, 1 extra   0 / 0 / 0
```

The outcome rests on a re-walk that does not import either tool (`verify_promoted_file.py`, card
workspace): it enumerates the 11 roots itself and asserts that the file is present in 10/10 non-bundled
roots, at **4,399 B**, with **one digest** equal to the pre-promote digest of tiel's copy, and that the
bundled tree still does not hold the skill.

## What this card was NOT allowed to do, and did not

- no other profile's copy was edited by hand (the push wrote, with backups);
- nothing was deleted — a push never deletes, and the EXTRA class exists precisely so that nothing needs
  to be;
- the source was not populated and left unpushed (that would be the drift inverted);
- neither instrument was widened, re-keyed or silenced for this one file. The report's red was the
  input, not the obstacle.

## The general form

**A finding class that is reported and never deleted needs a decision path, or it becomes noise.** A red
that names a real file with no ruling behind it can only be tolerated or hacked away. The path is:
read the file, ask what its claims are ABOUT, promote it if they are about the class, record the decision
if they are about this box, and re-measure with both instruments either way — because "expected red" is a
ruling, and an unexplained red is a defect.
