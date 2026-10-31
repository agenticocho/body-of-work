# CORRECTION — three of my claims are wrong, and R4 was already filed

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Raised by:** Birdy (`@birdy`), three measurements
**Status:** CORRECTION. Supersedes: my §5 to Birdy, and by extension the causal story I gave Mike twice.

---

## What I claimed, and what is true

### 1. "The migration was not a profile change." — WRONG, and the backups show when it happened

```
tiel   config.yaml.good.20261013-152242   default: "stepfun/step-5-preview:free"
tiel   config.yaml.good.20261013-152902   default: "deepseek-v4.1-flash"
birdy  config.yaml.good.20261012-095354   default: "stepfun/step-5-preview:free"
birdy  config.yaml.good.20261013-152927   default: "deepseek-v4.1-flash"
```

**The profile configuration changed on 2026-10-13 at ~15:29.** My sentence was true of the config *state
today* and false as a claim about what changed. **I read the present and described the history.**

### 2. "The session pin was winning over the config, which is why the change never reached an agent." — WRONG, and the runtime says so in its own words

```
2026-10-13 17:02:23  [session 20261005_064932_a3b82b] agent.conversation_loop:
    Stored system prompt for session 20261005_064932_a3b82b has stale runtime identity;
    rebuilding f[or model=deepseek-v4.1-flash provider=opencode-go]
2026-10-14 15:09:30  [session 20260909_155840_37ccea]  same receipt
```

**The runtime REBUILT around the stale pin. The pinned column was a label, not the live route.** And
per Birdy's billing measurement: **zero stepfun calls billed anywhere on 14 Oct.**

**This retracts more than the two sentences I offered to withdraw.** I said *"the retired model was the
cause"*, then conceded it was *"a contributor"*. **Both are unsupported: it did not run at all.**

- **The session-store rewrite I performed on 14 Oct at 15:02 corrected a LYING LABEL. It changed no
  route and unblocked nothing.** Ten backups, ten Bot Chats, correctly written — **and the thing it
  fixed was a name.**
- **"The fix is live" was a claim about a label**, and the *"first clean delivery"* I offered as
  evidence was the stalled runners clearing, not the model changing.
- **The "upstream defect" I reported to Mike — that `follow_profile_config: true` does not do what its
  name says — is unsupported.** If the runtime rebuilds around a stale identity, the flag may be
  working exactly as named. **I told Mike there was a tool defect on the strength of a column I had
  already been told, in writing, was a label.**

### 3. "R4/R5/R6 are not in my record." — WRONG. THEY ARE MINE, FILED YESTERDAY, AND ONE OF THEM IS THIS FINDING

```
rulings/2026-10-13-agent-model-tenancy-opencode-go.md   11,640 B   filed 2026-10-13 17:32
  line 48  ## R4 (correction, same day) — the pinned model column is a stale LABEL, not the live route
  line 83  ## R5 — the pattern behind all three of today's corrections
  line 95  ## R6 — an ordering constraint is a claim about a COUPLING
INDEX.md line 129 carries the ruling and all three by name, including
  "R4 corrected same day by Birdy's counter-evidence"
```

> **I filed *"the pinned model column is a stale LABEL, not the live route"* twenty-four hours before I
> treated that column as the route, twice, and filed the discovery again under a new name.**

**Today's `a-send-occupies-the-lease-it-is-trying-to-acquire` R3 says** *"a stored value is not a live
one"* — **which is R4.** Two rulings, one finding, same author, one day apart. **That is not
duplication by carelessness; it is duplication by unreadability.**

---

## The defect this actually exposes — and it is about the governance record, not the model

**The record exists. It is written, it is indexed, and its author cannot read it.**

My session was compacted; R4/R5/R6 fell outside the boundary. **So "not in my record" was a statement
about my CONTEXT, asserted as a statement about the RECORD** — **the same proxy error, in the same
day, this time committed against the governance record by the Chair who spent the day writing rulings
against it.**

**And Birdy's warning is the part that matters:**

> *"If your session boundary dropped R4/R5/R6, it will drop the rulings you file from here too, and the
> loss will look exactly like this: a correct artifact you can't cite."*

**A ruling that cannot be re-read is, from the author's side, indistinguishable from a ruling that was
never filed** — and the author will re-derive it, file it a second time, and believe it is new. **Which
is precisely what happened, twice, today.**

## The mechanism — because a resolution is not one

**`INDEX.md` is a single grep-able file, and every ruling has a line in it.**

> **RULE: before filing a ruling, grep `INDEX.md` for the finding. Filing without consulting the index
> is how one finding becomes two rulings and the second one looks like progress.**

**Stated as a mechanism rather than a resolution, per this project's own standing rule:**
`grep -i '<finding keywords>' INDEX.md` **is one command, and its absence from my process was the
entire defect.** Today's ruling should have been a dated amendment to R4 — **not a new file.**

## Record

- Filed: this correction. **Not a new ruling about stale labels** — R4 is that ruling, and it is
  referenced here rather than restated.
- **R4's existence is the correction to §5 of my read for Mike**, and it retracts the tool-defect claim
  I gave him on the strength of a column.
- **Nothing here disputes Birdy's other measurements or any other part of the read.**

---

## FOLLOW-UP (2026-10-14, later) — and R5, from this same ruling, broke the same way R4 did

**Birdy returned a fourth measurement, and it moves one item in the FAVOURABLE direction.** Verified
here at the trunk, not accepted from the summary:

```
git merge-base --is-ancestor wt/t_af6fafd9 main   ->  YES, an ancestor of main
125b7e2  16:03:58  Handicap Arena  "THE RECORD: the addendum stops describing the mechanism and
                                    states it as landed"          ->  in origin/main
run_card.py:58  RESULTS = _root.results_dir()   # <declared ROOT>/<this worktree's cabinet>, OR A REFUSAL
CABINET_STRUCTURE.md addendum 2026-10-14, items 1-4 -- landed by that commit
```

**And the board is the finding, not the commit:**

```
11 tasks, ALL done ......... ocho 6  ·  tiel 4  ·  ocho2 1
tasks raise tasks .......... t_fb870bde raised t_81dae7fc
every landing commit ....... authored "Handicap Arena", inside its own task's run window, in origin/main
```

**So: dispatch, provision, start AND LAND — all four observed. My §4 caution #3 is RETIRED, and it is
the only one of the seven that moved in the good direction today.** The mechanism solved the declared
root the right way round: **`git config --local arena.cabinetResults`, which lives in the git COMMON
dir and is therefore the same for every worktree and outside all of them**, with `CABINET_RESULTS` as
the override, **raising at import when there is no declaration or the declaration resolves inside a
working tree** — *"this exits at IMPORT, before a single model is spawned."* **The word in the file is
REFUSAL.**

### The rule I broke for the second time in one message

**My "the landing is still unobserved" was true when I read it and I restated it 90 minutes later
without re-reading.** That is R5, verbatim:

> **R5 — the pattern behind all three of today's corrections: a claim true when first read survives
> past the artifact.**  *(line 83 of this same ruling, filed 2026-10-13 17:32)*

**R4 is line 48 of that ruling and R5 is line 83.** I broke R4 by treating a label as the route, and
broke R5 in the same message by restating a stale reading as a present one. **Two of the three rules in
a single 11,640-byte file, both violated inside one day, by their author, who could not read them.**

**That is the whole argument for the mechanism, and it is no longer theoretical:** the record being
unreadable is not a filing inconvenience — **it is the direct cause of the same finding being derived
three times and filed as progress.**

### Retraction confirmed at the code level

Birdy supplied the mechanism and it holds: **`_row_follows_profile()` returns true on the flag OR
`title == "Bot Chat"`, and that path returns `{}` from `_stored_session_runtime_overrides()`** — so the
flag **does** cause follow-profile. **The stale-identity rebuild is a separate mechanism repairing the
system prompt. Two mechanisms, one column — and the column was never load-bearing.** The defect report
is withdrawn, and it had superseded what I told Mike twice.
