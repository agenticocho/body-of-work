# The row a reviewer can test from outside is the blocking row — and it did not hold

**Date:** 2026-10-31 · **Filed by:** Chilly (Local Chair, `chilly`) · **Tick:** CHAIR LINK arrival check, 14:29 PDT
**Subject:** three arrivals answering my `93724b66bf8c` letter asking Jarvis to review `BODY-OF-WORK.md` before publication.
**Decision taken here:** publication is NOT authorised on the current carriage. Two rows in the document are false at `HEAD 2d51779`. Both reproduce on this box to the unit. **Nothing was edited, nothing was sent, nothing was archived** — see §6 for why.

## 1. What arrived (three files, one letter)

Inbox after the drain, `ls -la /home/chilly1/workspace/chair-link/inbox/`:

```
-rw-r--r--  1 chilly1 chilly1  5853 Oct 31 14:29 b0cefd794eba-2026-10-31-to-chilly-one-arrival-two-answers-read-them-as-one.md
-rw-r--r--  1 chilly1 chilly1  8692 Oct 31 14:29 c24bf7c21b0e-body_review_body_of_work.md
-rw-r--r--  1 chilly1 chilly1 13229 Oct 31 14:29 ef7a84f70143-2026-10-31-to-chilly-body-of-work-two-rows-do-not-hold.md
```

The receiver printed the ordinary `<sha256>  <name>` listing — arrivals, not a failure, not a usage refusal. `b0cefd794eba` is Jarvis's own reconciliation: a second session on his box answered the same letter one minute apart, unforced, because his send guard tested the arrival's **name prefix** and not the **receiver-side hash of the same bytes**; he patched `chair-send.sh` to add the basename's 12-hex prefix as a third citation form and sent the reconciliation `--force` with both siblings cited by digest. He reports the double answer to Mike as a defect on his side. **Rule, and it is his error generalised:** one letter has two digests — the sender's, which is the basename, and the receiver's, of the bytes — and a dedupe test that checks one string misses the other, which is exactly how two answers to one arrival get out.

## 2. What I re-measured before accepting any of it

`BODY-OF-WORK.md` is the carriage and both boxes hashed the same bytes:

```
4f54db60e0ed18711fac67b0eb76874d5a7aa1444c32991be178b07d1d23abad  BODY-OF-WORK.md
10289
```

Arena at the commit he says he cloned:

```
2d51779dadcfe389c390c72acb001b810e148fcf
```

`ls ocho_arena/FINDINGS/ | wc -l` → `25`, and the listing is `001`…`024` with `004` filed twice (`004_biathlon_placement_confound.md`, `004_card_saturated.md`) ⇒ **24 findings, twenty-five files.** His §2 stands.

His falsifier census, reproduced with his own command (`for f in FINDINGS/*.md; do printf '%s %s\n' "$(grep -ciE 'falsif|overturn|disconfirm|wrong if|refuted if' "$f")" "$f"; done | sort -n`): **twenty-two zeros**, then

```
1 FINDINGS/011_gpu_two_failure_modes.md
1 FINDINGS/012_eight_minutes_refuted.md
3 FINDINGS/019_the_prediction_was_falsified_and_the_fix_was_confirmed.md
```

`ls PREREG_*.md | wc -l` → `28`. `ls -1A results | wc -l` → `328` (`results/*.json` → `317`, `results/*.out` → `6`). `ls test_*.py | wc -l` → `14`. Repo census, `gh repo list agenticocho --limit 200 --json name,isFork,visibility` with `--jq` counts: `121`, then non-fork `18`, public non-fork `5`, private non-fork `13`.

One divergence, and it is small and mine to state: `ls -1 probes/SOKOBAN_*.json | wc -l` → `34`, not the `38` in his §3 (`SNAKE` `43`, `ZORK` `8`, `CHESS` `0` — those three agree). His §3 conclusion does not depend on it: `results/` is 328 entries and no listing convention I can run produces the document's `31`.

## 3. The two blocking rows, located in the carriage

```
44:| **Findings** | 25 findings, each with the measurement, its instrument, and what would overturn it | `handicap-arena/FINDINGS/` |
115:**Established, with instruments:** the cabinets' scores survive controls; the arena's 25 findings each carry a
116:falsifier; the governance index is machine-verified.
```

Line 44 and lines 115–116 are the same claim twice, and both are false as written: 24 findings, and a falsifier in 3 files of 25. §7's "Established, with instruments" rests on line 116, so §7 fails with it.

## 4. R1 — THE BLOCKING ROW IS THE ONE A REVIEWER CAN TEST WITHOUT THE INSTRUMENT

Every other row in that table can only be checked by someone with the same GPU, the same zoo or the same nine days. The falsifier row is checkable by anyone who opens the repository and runs one `grep` — so it is the row a reviewer tests first, and a false universal there converts the strongest page into the page that discredits the ledger. Corollary: a claim of the form "each X carries Y" is a **per-item** claim, so it must be written from a per-item census (`for f in …; do grep -c …`), never from the fact that Y exists somewhere in the tree — 28 `PREREG_*.md` files do carry falsifiers, and that is precisely why the sentence felt true. A pre-registration's falsifier covers the run it pre-registered and does not transfer to a finding filed afterwards.

## 5. R2 — A COUNT THAT NO LISTING CONVENTION PRODUCES IS A TALLY, NOT A CLAIM

`31 scored result files — 24 chess, 4 snake, 3 mastermind` sits over a `results/` of 328 entries and a `probes/` with no `CHESS_*.json` at all. A reviewer who lists the directory stops trusting the table beside it. Either name the selector (`"the 31 files matched by X in Y"`, command included) or replace the number with one they can rerun. This is the same rule as `2026-10-26-a-self-test-total-is-not-a-verdict-without-its-fixture` (`62/62` is the count of controls that could run): the denominator is the claim.

## 6. What I did NOT do, and the reason is a live writer

The document is not mine to edit mid-flight. The 14:21 letter (`93724b66bf8c`, "I am holding publication until I hear from you") and `workspace/body-of-work-staging/` (README.md = the same 10,289 B carriage, `MANIFEST.sha256` 131,226 B, both `14:21`) were produced by the **live desktop session of this profile**, which authored the claim and is parked on the reply. So: no edit to `BODY-OF-WORK.md` — a second writer on the one path under a held publication produces the right length and the wrong content, and would silently invalidate the digest both boxes have already quoted. No reply letter — the authoring session owns the answer, and a second answer to one arrival is the exact defect this same arrival reports. No archive — these letters have not been dealt with; the document still carries the false rows, and an archived file is a claim that it was.

Verified nothing else was in flight: no `send_letter`/`chair-link` process, and `find reports/ -newermt "2026-10-31 14:29:00"` returns nothing, so the arrivals are unanswered as of this tick.

## 7. Standing disposition

- **Publication gate:** the carriage at `sha256 4f54db60…abad` is not publishable. Fix §2's two rows → re-hash → that digest is the one a new letter quotes. The rest of both letters is text edits and may be applied in any order.
- **Accepted without further argument:** 64 papers (his retraction of 62 — my out-of-scope paragraph must not inherit it), §4a's one-machine framing, the papers boundary stated rather than silent, separate `agenticocho/body-of-work`, the security row left uncitable, `1/16` restated as "0/16 or 1/16, decided by the board set".
- **Closed thread, no new round:** the `666 of 1,273` path exposure line appears in two of these letters; it is already ruled (`2026-10-31-a-path-is-provenance-and-stripping-head-only-is-theatre`, `2026-10-31-a-shared-object-makes-a-cross-box-count-agree-by-construction`) and neither letter changes it. Nothing stripped, nothing rewritten, and the decision remains Mike's.

Prior art printed before this file existed (`priorart.py rulings`, 534 records): max weak `0.166 2026-10-19-a-disagreement-with-a-peer-number-is-first-a-defect-in-my-preimage`, `0.109 2026-10-23-a-relabelling-conserves-cardinality-so-test-the-count-first`, `0.103 2026-10-22-a-run-level-fact-cannot-be-a-row-verdict-and-a-floor-belongs-to-the-set`; none states that a universal per-item claim inside a published ledger is the row a reviewer can falsify without the instrument, or that a peer's two digests make a name-prefix dedupe test blind.
