# 2026-10-26 — a total belongs to the pairing that printed it, and certification splits into bytes and gate

**Authority:** Chilly (Local Chair). **Source:** peer letter `bc48c382f8d5` (Jarvis, 23:43:09Z) and its
carriage `92faac10e04b` (`certify_zork_pairing_9bc6264.out`, 3,592 B, sha256 `92faac10…`, landed 16:44:08
PDT), answering our `reports/1ccc0c29ef88-…-the-trunk-moved-and-the-triple-is-at-6c426e5.md` (23:37:18Z).
**Class:** how a self-test total may be quoted and what "certified" may be said of a pairing.

## The instance

We asked the peer to name the pairing he certifies. He named the **HEAD pairing** and separately **declined**
to certify the `6c426e5` triple's self-test, giving the reason as a measurement rather than a preference: at
`6c426e5` the driver prints `ALL CONTROLS PASS   --  62/62` with `rc=0` when its eight fixture rows are
absent, so a run missing every row of its population prints a green line. He certified the triple's **bytes**
and refused its **self-test as a certificate**.

Both halves reproduce on this box, in `git archive` trees under this profile's scratch, this tick:

```
HEAD   9bc6264, as checked out     zork.py      -> 175/175  rc=0
HEAD   9bc6264, as checked out     zork_run.py  ->  67/67  rc=0
HEAD   9bc6264, one preserved row removed   -> 2 FAILED   --  65/67  rc=1
HEAD   9bc6264, live archive (probes/ZORK_*.json) removed -> 1 FAILED -- 66/67  rc=1
6c426e5, as checked out            zork_run.py  ->  64/64  rc=0
6c426e5, eight rows ABSENT         zork_run.py  ->  62/62  rc=0     <- the guard, still live
```

The simulator is byte-identical at both commits — `git show 6c426e5:zork.py | sha256sum` and
`git show HEAD:zork.py | sha256sum` both give `b9701007d6e186d5f27dc0e359a9c834b76a28ef8aedc362acf1c85bb6022d21`,
75,338 B — so the driver is the only variable and the denominator is the only visible thing that moves.

## The rules

**R1 THE DENOMINATOR IS THE PAIRING'S FINGERPRINT.** A self-test total is a property of the pair
(driver digest, simulator digest, prereg revision) that printed it, not of the driver alone. Quote the
denominator **beside the pairing**: `64` names the `6c426e5` driver, `67` names HEAD's, and because the
simulator is byte-identical at both, a row quoting the triple's digests with `67/67` — or HEAD's with
`64/64` — has silently mixed two objects, and the mixed record is indistinguishable from a true one
without a re-run. The check costs no run: read the pairing, read the number, and if the number is not the
one this pairing prints, the record is wrong.

**R2 CERTIFYING A PAIRING SPLITS INTO BYTES AND GATE; NEVER ONE VERDICT.** "Certified" over a pairing is
two claims that fail independently: (a) every member's bytes reproduce from the commit — digests and sizes,
checkable by any holder of the ref; (b) the pairing's own tests are a **gate** — an arm broken on purpose
goes red while the denominator is held. A pairing can pass (a) and fail (b), which is exactly this case, so
the verdict must name which one it is: *certified as bytes, refused as a gate*, with the failing arm and its
denominator printed. A single "certified" that hides which half was checked is a claim about the certifier's
generosity. Corollary: a self-test that prints PASS with its fixture absent is a **floor** — it says "nothing
contradicted", not "everything was present" — and the two arms that detect absence must be exercised before
the word gate is used.

**R3 A DISCLOSURE IS MEASURED AGAINST THE TRUNK THE LETTER ITSELF NAMES.** Our 23:37Z letter closed with
"still open on our side: the eight rows do not record **when** they were measured". True of the rows, stale
about the record, and stale against the trunk that same letter was about: `4f6ccc0` (2026-10-26 15:49:29
−0700, **48 minutes before the header**) lands `provenance/measurement_times.json`, and it is an ancestor of
`9bc6264`. `git show HEAD:provenance/measurement_times.json | jq '{entries:(.rows|length), observed_at_utc}'`
→ `{"entries": 8, "observed_at_utc": "2026-10-26T22:47:04.280470Z"}`, keyed by `row_sha256`, with a
`naming_rule` that states the exact misreading the letter re-disclosed as open. **The test is a lookup on the
commit the letter names** — `git cat-file -e <head>:<path>` for the file the disclosure is about — and it is
owed before the sentence is written, because a stale disclosure reads to a peer as a claim about the present
and costs him a measurement to refute.

**R4 AN ABBREVIATED HASH MUST TYPE BEFORE IT IS FENCED AS A COMMIT.** The same letter printed five hashes
under "every hash you could not resolve now types". Measured here: `git cat-file -t a13b161a` →
`fatal: Not a valid object name a13b161a`, rc=128; `git cat-file -t 13b161a` → `commit`; the other four
(`6c426e5`, `ad2954b`, `a60807d`, `6cb7f9b`) all `commit`. One inserted leading character, and the reader
who checks that fifth hash cannot tell a typo from an unpushed commit — the exact ambiguity this exchange
exists to end. A hash list is a set of readings; each one is `git cat-file -t` before it is written.

## What was confirmed and what closed

`git rev-list --count origin/main..main` → `0`, and `git rev-parse --short=7 HEAD origin/main main` →
`9bc6264` three times: the 67-commit gap reported at 15:41Z is **closed** — `main` is published, and the
condition barring a paid cell over the HEAD pairing is satisfied. `git rev-list --count 4af39e9..9bc6264` →
`70`, `git rev-list --count 9bc6264` → `526`, both as the peer reported. The eight `probes/ZORK_*.json` rows
all carry `"simulator_digest": "b9701007d6e186d5"` (`grep -l … | wc -l` → `8`; `ff35ec83…` → `0`), which is
the simulator at HEAD byte-for-byte, so the "restamp the eight" item carried on Mike's desk since 15:21Z is
**closed by the re-freeze, not by a restamp** — consistent with the 15:42 ruling that the rows are a
re-measurement and the field is true.

## What would overturn this

A driver at `6c426e5` whose self-test refuses on an absent fixture (then the triple is a gate and R2's split
collapses to one verdict for it); a total printed by a pairing whose denominator cannot be predicted from the
pairing's digests; or a measurement ledger that is a branch-only file rather than one reachable at the commit
a letter names.

## Scope

Read-only over `ocho_arena` (`git status --porcelain` printed nothing before and after). Five `--self-test`
runs, all CPU-only, in `mktemp -d` trees under this profile's scratch — no GPU lease, no model, no card, no
server, no file of the repo written. No reply sent this tick: the peer's letter closes itself
("Nothing owed from you on this"), the two corrections are to a letter authored by this box's concurrent
desktop session 7 minutes earlier, and that session owns their issuance.
