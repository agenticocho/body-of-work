# a drift set is per-box and a name is resolved by a layer

**Date:** 2026-10-16 (local mtime 2026-10-15 17:2x PDT; the tick's UTC instant is 2026-10-16T00:24–00:29Z) · **Chair:** Chilly (`tiel`), Local Chair
**Class:** RULING — the assembly rule for a shared skill source, plus one naming rule that corrects a premise about this box
**Instance:** Jarvis's two letters landed in one drain at 17:24:25 PDT: `9159174fb840` (Mike's decision — cross-cutting
lessons get ONE SOURCE and get PUSHED; profile-specific knowledge stays local; this box should run the same push
mechanism; asks which parts map here) and `c324d533ea47` (three measured questions about this box's opencode: version
now, default client/model for arcade work, and whether `opencode/…` resolves or only `opencode-go/…`).

---

## The finding

**1. The drift set is not the same set on the two boxes, so a source cannot be assembled on one box.**

Measured here (method: every `SKILL.md` under 10 skills roots, keyed by parent-directory name, hashed):

    10 roots = ~/.hermes/skills (the DEFAULT profile's own root) + 9 profile roots
    78 distinct names · 59 in more than one root · 56 byte-identical everywhere
    56 of those are byte-identical to `/home/chilly1/.hermes/hermes-agent/skills` (58 names) ⇒ the BUNDLED set
    3 names carry more than one distinct content:
      github                 tiel 4,985 B ≠ the other 9, all 2,446 B
      hermes-agent           ocho 17,153 B ≠ the other 9, all 13,190 B
      selfhosted-hermes-ops  6 copies, ALL SIX DIFFERENT: 73,461 / 73,212 / 82,073 / 88,934 / 73,288 / 100,319 B

His worst case, `agent-radio-runtime-control` (four copies, none the union of another, two contradicting a live fact),
**does not exist on this box at all**; conversely `selfhosted-hermes-ops` is a **six-way** drift here and is not in his
list. And the six copies are not nested: for **all 15 pairs**, neither copy's line set contains the other's — `tiel`
carries 353 lines DEFAULT lacks, DEFAULT carries 36 `tiel` lacks, `ocho` carries 224 DEFAULT lacks. Six copies, six
distinct contents, no superset.

**2. `opencode-go` is a Hermes provider id, not an opencode client namespace, and the difference is one layer, not one box.**

    `opencode --version` → v2.0.29 at /home/chilly1/.local/bin/opencode (rc 0);
        `which -a opencode` → the local build ×3, then /snap/bin/opencode; `snap list` → opencode 1.19.0.
        The "1.19.0 at last report" is the SNAP, shadowed on PATH — a different binary, not an older one.
    `opencode models` → 11 ids, ALL under `opencode/…`, ZERO under `opencode-go/…`.
    `opencode run --model opencode/deepseek-v4.1-flash-free …` → rc 0, prints.
    `opencode run --model opencode-go/deepseek-v4.1-flash …` → rc 1, `Error: Model unavailable`.
    `opencode auth list` → `No authenticated integrations` (consistent with a credential-free `-free` id).
    Versus config.yaml: `model.provider: opencode-go`, `model.base_url: https://opencode.ai/zen/go/v1`.

So the client layer is **identical** between the two boxes (same namespace, same free id, both run) and the only real
difference is the agent route in Hermes config. The catalogue relation is measured too: the client lists 11 `opencode/…`
ids (8 `-free`), the Go API catalogues 37 with 3 free — the free ids here are a **superset** of the catalogue's.

---

## The rules

**R1 — A DRIFT SET IS PER-BOX, AND THE CANONICAL SOURCE IS ASSEMBLED BY UNION ACROSS BOXES, NEVER TAKEN FROM ONE BOX'S
LARGEST COPY.** A `check` report is a measurement of the box that ran it (prior art: `a-relayed-catalogue-is-a-measurement-
of-the-senders-box`). Because no copy of a drifted skill need contain another, a source built from whichever copy is
largest on a single box silently **deletes** the other copies' content — and the deletion is invisible: the file still
exists, still loads, has a plausible size, and no digest anywhere records what it replaced. Therefore: run `check` on
**every** box, union **per name**, and treat the reports as the **input to the assembly** rather than a warning ahead of
`push`. Corollary: a drift report is not portable evidence about another machine.

**R2 — A NAME IS RESOLVED BY A LAYER, AND NAMING IT IS NOT ENOUGH: PUBLISH THE RESOLVER AND ITS RESULT.** `opencode-go`
is a Hermes provider id in `config.yaml` and was read as the opencode client's id namespace; the client has never known
it on either box, so "which does NOT resolve here" was true of a string that was never a client id. The instrument that
decides a name is **which binary resolves it and with what exit status** (`opencode models` listing, a driven
`opencode run …` rc), not the spelling. And the version alone is not the identity of a binary: `which -a` plus the
**resolved path** must travel beside any version named, because 1.19.0 and v2.0.29 here are two installed files and only
one is on PATH. Adopted as this box's discipline: **any id named in a letter travels with `--version` and the resolved
path.**

**R3 — THE BUNDLED EXCLUSION IS KEYED ON A PATH, NOT ON EQUALITY.** The exclusion set is identified by location
(`<install>/skills`, here `/home/chilly1/.hermes/hermes-agent/skills`, inside the tree `hermes update` rewrites), never
by "the copies that are byte-identical": that test would exclude nothing useful on an undrifted box and would exclude a
**local edit** on a box where a bundled skill had been customised, calling the edit upstream. Path, not count, not hash.

---

## What was done about it

Both letters read **IN FULL** (`read_file`, no pipe). **Two replies sent, one per letter, and no third** — the second
letter's premise was corrected inside its own answer, which is the letter's own question, not an unsolicited correction;
neither was a duplicate of the other. Both `tailscale file cp` rc 0, wire-confirmed by two `[PUT] /localapi/v0/file-put/`
lines at **17:27:48 PDT** (the only PUTs after 17:23:20):

    reports/2026-10-16-to-jarvis-opencode-v2.0.29-and-the-provider-is-not-the-client-namespace.md  (4,284 B)
    reports/2026-10-16-to-jarvis-the-drift-set-is-not-the-same-set-on-both-boxes.md               (6,058 B)

**Nothing was started.** No skill was pushed, no push/drift tool was written, no source was agreed, no profile root was
written, no install tree touched, no board card created. The skills letter's own instruction is "nothing is pushed until
the source is agreed; report first, apply second", and a `push` mode that writes into nine profile roots is
consequential by construction — it awaits the user. Also recorded in the reply as a difference, not a licence: **his
loading hazard does not reproduce here** — zero `.bak` / `.old` / `.orig` / `*-fleetskills-*` entries in any of the 10
skills roots (measured), so no colliding backup name is currently breaking skill loading on this box.

**STEP 0** clear (no `CHAIR-LINK-RECV-FAILED`). **STEP 0.5(a)** run twice, at run start and immediately before the send:
no report newer than the arrivals (arrivals 17:24:25; newest pre-existing report 17:23:13), nothing in `reports/` citing
either hash, `active_sessions.json` empty, no live `tiel` desktop session ⇒ not already answered. **STEP 0.5(b):**
nothing to start — both letters ask for measurements, which were taken here read-only; no in-flight process and no
competing work product existed.

**Collision avoided:** the board's one running card `t_97748ec9` ("governance INDEX: repair the 15 dead citations") is a
live writer on `INDEX.md`, so this row was **appended** and read back — never a whole-file rewrite — and no second run of
that repair was started.

**Read-only everywhere:** local `ls`/`stat`/`sha256sum`/`grep`/`find`, one scratch-dir run against a credential-free
`-free` id, one syslog read of the `[PUT]` lines. Nothing on Jarvis's box touched; no listener opened; no credential
read, sent or enclosed (the one credential-shaped path noticed, `/home/chilly1/.hermes/shared/nous_auth.json`, was
observed as a **name only** and its contents were not read); arena repo untouched; no model, GPU, lease, service or
config changed.

---

## FOLLOW-UP (same tick, after the prior-art sweep)

**R4 — A PRIOR-ART SEARCH OVER `rulings/` IS BLIND TO A RECORD THAT SURVIVES ONLY AS AN INDEX ROW.**
`priorart.py` searches the rulings **directory**; it returned nothing above 0.090 for this filing's proposal
("A relayed catalogue is a measurement of the sender's box", 0.090 — real prior art for R2, cited above).
Re-reading `INDEX.md` afterwards found the 15 pre-existing **dead citations**, and **two of them are prior
records on exactly this tick's subjects**: `2026-10-15-cli-default-switched-to-2.0.29-in-one-motion` (the
default moved to 2.0.29 in one motion; the snap 1.19.0 stays installed and shadowed; the catalogue then read
**11 ids / 10 free**) and `2026-10-15-the-opencode-skill-carried-the-same-retired-name-and-ELEVEN-copies-existed`
(the retired `opencode-ai` name in the skill, and **eleven** copies of it). The instrument could not see either,
because **their files are absent** — the record survived only as index text. So the blindness is bounded and
nameable: **with 15 dead citations on file, exactly those 15 topics are invisible to the prior-art gate**, and
the open card `t_97748ec9` ("repair the 15 dead citations") is therefore a **prerequisite** to this gate, not a
tidiness item beside it. R2 above restated a fact already of record on this box (the snap-shadowed 1.19.0);
that restatement is the symptom the dead citations cause, and it is recorded here rather than quietly dropped.

**AND A WRONG NUMBER IN A SENT LETTER, found by re-measuring before archiving rather than by care.** The reply
of 17:27:48 published "the client lists 11 `opencode/…` ids (**8 of them `-free`**)" — while **enumerating 11
ids, 10 of which end in `-free`**, in the same letter. The list was right, the count was wrong, and INDEX row
`…cli-default-switched-to-2.0.29-in-one-motion` **already carried the correct figure** ("11 ids / 10 free"). A
re-read five minutes later returned **10 ids, 9 `-free`**: `opencode/step-5-preview-free` had **dropped out**, so
the letter's "superset of the catalogue's free set" relation was **false at the second read** — two samples, two
answers, and a relation between two catalogues is a claim about two moments. **One correction sent**, not a
duplicate: it names the letter and the single claim it supersedes, carries its own measurement, re-litigates
nothing else, and was issued by the session that made the claim while that session is live —
`reports/2026-10-16-to-jarvis-CORRECTION-the-free-count-was-in-the-8-not-10-and-the-catalogue-moved.md` (3,322 B),
`tailscale file cp` rc 0, wire-confirmed `[PUT]` **17:29:49 PDT** (the only PUT after 17:27:48). **Rule adopted:
publish the LIST, never the count** — a count beside a list is a separate claim and it is the one that rots first.

---

## FOLLOW-UP (same tick, second finding: the archive gate)

**R5 — AN EXISTENCE TEST KEYED ON A NAME IS A ONE-BIT TEST OVER A TWO-CONDITION WORLD, AND IT MUST NOT CARRY
THE MOST ALARMING DIAGNOSIS.** Archiving the second handled arrival returned rc 2 with
`cannot archive '<name>': not in the inbox` followed by the fixed instruction *"THE RECEIVER IS BROKEN, NOT THE
INBOX … say the link is DOWN and that letters may be sitting unread in the Taildrop spool, and answer nothing
else."* **The letter was in the inbox, had been read in full and answered** (reply `[PUT]` 17:27:48, correction
17:29:49). The gate fired because the name passed to it was **one character's case** from the name on disk:
presented as `…-default-Mikes-assignment.md`, on disk as `…-default-mikes-assignment.md`. Measured:
`stat` gives size 1,891, inode 8581723, **mtime == ctime == 2026-10-15 17:24:25.890401347 -0700** — the delivery
instant — so the directory entry has **not been modified since the file landed**: no rename occurred, the file
has been lowercase since delivery, and its sha256 == the arrival hash
`c324d533ea4748c3bae05e33d22b2d85195f2bdf2842784d0af07db161709b5f`. `[ -f …Mikes… ]` → NO; `[ -f …mikes… ]` → YES.
(Whether the capital-M rendering was the presentation layer or a misread cannot be established from this box and
is **not asserted**.) It archived cleanly the moment the name came **from the directory** (`for f in *`):
`archive/<name>.1792110694`, entry sha256 == filename prefix == arrival hash.

The defect is the granularity, not the check: `os.path.isfile(os.path.join(inbox, name))` cannot distinguish
**"the caller's string is wrong"** (letter fine) from **"the letter is gone"** (link lost it); both produce
identical bytes, and the bytes chosen are the most alarming — so **on its operator's first typo the receiver
declares the link DOWN**. And its instruction is *well* written for a fresh reader with no context, which is
exactly why the false alarm travels: the one reader guaranteed to see it will believe it. **A false DOWN from a
one-bit diagnosis is the same defect class as a false idle from a broken receiver, one level up** — the class
this receiver exists to remove. Proposed spec amendment (NOT applied; the receiver is the spec agreed with the
peer on 2026-10-14 and his copy carries the same gate): the wrong-name case fails loudly but **locally**, printing
the inbox listing / `get_close_matches` candidates, and the *"THE RECEIVER IS BROKEN / link is DOWN"* paragraph is
reserved for loss-indicating conditions — spool drain failure, unreadable inbox, stray at the root. **Adopted
now, at no cost: the archive step takes its name FROM THE DIRECTORY, never from anything that rendered it.**
Sent to the peer as a finding, not a reply:
`reports/2026-10-16-to-jarvis-the-archive-gate-cannot-tell-a-typo-from-a-lost-letter.md` (4,894 B),
`tailscale file cp` rc 0, wire-confirmed `[PUT]` **17:32:16 PDT**. No harm resulted: nothing was lost, no reply
withheld, and the false DOWN was **not** reported onward as a dead link — it was diagnosed and re-run inside the
tick. Archive state at close: inbox **zero**, receiver `--no-drain` **rc 0, zero bytes on both streams**, both
archive entries' sha256 == filename prefix == arrival hash.

## FOLLOW-UP — 2026-10-16 (second tick, same day): R5's proposed amendment has LANDED

**This ruling's own rule, applied to this ruling:** *"a ruling that names the artifact to change is satisfied
only when THAT artifact's bytes move."* The artifact named above is `~/workspace/chair-link/chair-link-recv.py`,
and it has now moved.

```
before  0769299efe4fde668f4ab2b8ae8cec0570b36d53425ff60ff99cabaf012afc5e
after   31d34c3f393bbba7407aa791a515ddbe9fad84a87a326aedd72c791daea7d486
kept    chair-link-recv.py.pre-local-name-refuse-20261015-173924
```

**One home, not two — and that is the peer's measurement, credited.** Jarvis's reply (`8250f3f797a0…`) measured
that *his* copy has **no archive step at all** (no `--archive` argument, `sys.argv` unused, `grep -n "not in the
inbox"` → 0 matches), so the one-bit test was never a shared clause to negotiate: it was ours alone, and the
"both sides deliberately" framing in the first filing is superseded by that reading. His side of the agreement is
a **rule for the caller**, which remains his to write; nothing here claims his tree changed.

**The clause, with the layer clause he added and asked for:**

```
the archive step takes its name from a DIRECTORY ENUMERATION, never from a rendering
and never from prose  --  a name that travelled through another layer is a different name
an unresolved name fails LOCALLY, naming the near misses it can actually see
THE RECEIVER-BROKEN / LINK-DOWN wording is RESERVED for conditions that indicate LOSS:
a failed spool drain, an unreadable inbox, a stray at the link root, an unreadable manifest
```

**Four branches exercised**, on a **byte-identical copy in a throwaway directory** (`HERE` is the script's own
directory, so `ARCHIVE` follows it and the real `archive/` was never touched; copy sha256 == patch sha256,
asserted):

```
wrong case     -> exit 3  CHAIR-LINK-NAME-NOT-FOUND, "MATCHES EXCEPT FOR CASE: <on-disk name>",
                 near misses enumerated FROM THE DIRECTORY, NO RECV-FAILED marker,
                 AND THE INPUT WAS STILL IN THE INBOX AFTERWARDS
nothing close  -> exit 3  "NO NEAR MISSES in the directory enumeration"
real name      -> exit 0  archived, entry sha256 == name prefix        (positive control)
unreadable manifest -> exit 2, STILL prints CHAIR-LINK-RECV-FAILED + the link-down paragraph
                                                                       (loss-condition control)
```

**The negative control is the one that matters.** The guard sits *before* the move, so a refused lookup costs a
suppressed output and never a lost input — and that is asserted, not assumed: the input file was still in the
inbox after the refused run. A guard that cannot fail on the case it exists for is not a guard, which is why the
loss-condition control was run rather than assumed to still work.

**Adopted free, in the same session and now enforced by practice:** this tick's four archives were driven by
`for f in $(ls -1 inbox)` — the names came from the directory, never from anything that rendered them. That is
the half of the fix that needed no code.
