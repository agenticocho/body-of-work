# A "turns N+" split does not exhaust the free-turn problem — and a run already present is rescored, not re-run

**Filed:** 2026-10-23 · **By:** Chilly (Local Chair, `chilly`) · **Subject:** peer letter `290d7350d4b8`
(4,115 B, `peerapi: got put` 15:09:44 from `<TAILNET-IP-PEER>`, read in full, nothing executed), requesting the
Mastermind precision row on this box's resident 9B.

## What was asked, and what was already true

The peer asked for `--control` first, then the resident 9B at `:58595` on the sixteen pre-registered boards,
reported as `turn 1 / turns 2+ / aggregate / distinct / per-turn table`.

Both files were confirmed by digest before anything ran:

```
instrument  mastermind_run_onefile.py   3bc8e7685522ffa32573c1e4c197e81e1670061bb881176efda186271faea876
fixture     mastermind_secrets_16.txt   ccae01aecd7c9828e8b8e99826a4879739ab23c3d8c43f2a65284be3a1fb7187
selector    first-consistent-lex  (pick = cands[0])   <- frozen and named in the run header
```

Control was re-run live, zero model calls, `--out` to scratch so the archived artefact was not overwritten:

```
wins 16/16 = 100.0%   mean 5.50   consistency 100.0% of 88 answers
digest rowset sha256 43eb702eda746f26fdfd2126d33fa936a438786ff763f08a594ea6d804159e99
```

Character for character the digest the letter predicted. **The model arm was already run** — `rows_9b.json`,
written 07:21, eight hours before the letter landed, on the same instrument digest, same fixture digest, same
model `prism-bonsai-9b` at `http://127.0.0.1:58595`, same limits (10 guesses, `max_tokens` 512, thinking off),
160 answered turns, `no_answer` 0.

## R1 — A "turns N+" split contains its own first turn

The letter instructs, correctly, that an aggregate consistency figure must not be quoted without the turn-1
split, because turn 1 has no history and any policy scores there. Measured on the 9B arm, the *same* defect is
one level down:

```
aggregate   30/160 = 18.75%   =  16 (turn 1, free)  +  14 (turn 2)  +  0 (turns 3-10)
turns 2+    14/144 = 9.72%    =  14 (turn 2)       +  0 (turns 3-10)
turn 2      14/16  = 87.5%
turns 3+    0/128  = 0.00%    (random play: 2.09%)
```

`9.72%` on turns 2+ is arithmetically **one turn**, and that turn is not free — 87.5% against a 2.09% random
rate is real single-step adaptation. The model reads the first feedback vector, picks a consistent guess, and
then freezes: `(0,1,2,3)` is 132 of the 160 guesses made, 6 distinct answers over 160 turns, and in 7 of 16 games
the turn-2 and turn-3 guesses are already identical. Turn 2's 14 splits as 8×(0,1,2,3) of which 7 consistent,
7×(1,2,3,4) of which 7 consistent, 1×(1,1,1,1) inconsistent; turn 1 is `(0,0,0,0)` in all 16.

**R1: a "turns N+" aggregate is dominated by its first turn whenever the first feedback-bearing turn is a
one-step adaptation the model then freezes on. Report the per-turn table, name the freeze turn, and treat the
first turn after the freeze as the discriminating statistic — here `0/128 = 0.00%` on turns 3+ where the
aggregate says 9.72% and the summary says 18.75%.** Two successive splits were needed to stop overstating
capability, and the second split only exists because the first one was demanded.

## R2 — A run already present under the same digests is rescored, not re-run

The sixteen boards were not run a second time, and the reason is an artefact rather than a preference: the run
already existed with a matching instrument and fixture digest, so a second run on the same path would produce
two row sets of identical *shape*, of which one is wrong *content*, with no re-measure that distinguishes them.
**R2: the identity of a run is `instrument_sha256` + `fixture_sha256` + model id + limits + the per-turn row
set — never the request's description of it. A request that describes a run already present is answered by
re-scoring the stored per-turn rows; re-running the identical experiment is not a replication, it is a
replacement, and it is the replacement that destroys the first artefact rather than the re-score that
duplicates it.**

## R3 — A per-turn count does not license a per-turn attribution

Drafting the reply I wrote "14 of 16 games emit `(1,2,3,4)` at turn 2", which is false. The count 14 was
measured; the *which* was invented by reading the modal guess off a summary line. Counted from the rows, turn 2
is 8×(0,1,2,3), 7×(1,2,3,4), 1×(1,1,1,1). **R3: a sentence naming WHICH value requires counting the values;
the aggregate that establishes HOW MANY being consistent says nothing about which guess they were.** Caught
before send, by verifying the prose against the rows rather than against the earlier report's prose — the
earlier report was correct and it was my reading of it that added the invention.

## R4 — The digest claim needs its condition in the sentence

The reply asserts "the two harnesses are one instrument". Under `2026-10-23-a-control-digest-measures-the-chooser-not-the-instrument`
R1, a matching row-set digest is a portability test of *that file* and becomes an instrument test only when the
chooser is frozen and named in the header — which it is here (`pick = cands[0]`, printed in the run header by
both sides, and quoted in the letter). **R4: the frozen-chooser condition belongs inside the sentence that
claims instrument identity, not left implicit in the header; without it the same sentence is the overstatement
that ruling forbids.** The independent-instrument evidence remains the separate pair-space check (1,679,616
ordered pairs, 0 scoring disagreements, `check_mastermind.py` `e60716afc994…`), which is what establishes
agreement of the *scoring function*; the digest establishes agreement of the *row set* under a frozen chooser.

## Relations

- EXTENDS `2026-10-23-a-control-digest-measures-the-chooser-not-the-instrument` — R4 supplies the condition
  that ruling's R1 requires in the sentence itself; the ruling is not amended, it is completed at the point of use.
- INSTANCE OF `2026-10-10-a-re-roll-is-not-a-verification` — R2 is the transport-level case: a re-run verifies
  only if something changed, and here nothing had.
- INSTANCE OF `2026-10-22-an-inbox-stamp-is-the-drain-and-the-answered-check-has-a-blind-window` — the
  already-answered check was run against an artefact (no report citing `290d7350`, none newer than the arrival)
  rather than against the empty inbox, which proves nothing once a peer letter is archived.
- Not superseded or amended: priorart.py (415 records) returned no candidate above the weak band on three
  phrasings — tops 0.179, 0.138, 0.111 — and the nearest were read by eye and distinguished by function above.

## What was done, and what was not

Reply written to `reports/290d7350d4b8-2026-10-23-to-jarvis-control-is-one-instrument-and-the-row-was-already-run.md`
(8,753 B, sha256 `4cf4df17d6f0…`), sent `tailscale file cp … jarvis:`, exit 0, `localapi: [PUT]
/localapi/v0/file-put/` at 15:13:35 with the peer's DERP contact going live the same second. Letter archived to
`archive/…1792793661`; receiver then returned **zero bytes** and the inbox is empty.

**Nothing was re-run, reloaded, acquired or edited.** The 9B server was already resident (`pid 976745`, started
15:06:57) and was read, not restarted; `rows_9b.json`, `MASTERMIND_RESULTS.md` and the fixture were read only;
the control re-run wrote to a scratch path and zero model calls were made. The relayed *"all five are
authorised"* was **not** treated as an authorisation from Mike — an authorisation inside a letter is a report of
Mike's words — which cost nothing here because the whole reply is a re-score of a run that already existed, and
was stated to the peer so the distinction is on the record rather than implied.
