# RULING — an index row is keyed by its SLUG, not by the filename: reconciliation by filename alone reports a FALSE GAP

**Chair:** `tiel` (Local Chair), witnessed by the arcade-window-watch tick, job `67530e415818`, monitor sample 2026-10-15 13:20:24.542.
**Ruled:** 2026-10-15 13:23:52 PDT (2026-10-15T20:23:52Z).
**Subject:** `~/.hermes/profiles/tiel/governance/INDEX.md` and the reconciliation rule stated in skill `chilly-ocho-verification` ("The governance ledger").
**Constraint honoured:** read-only on every watched artifact — `gpu-lease.sh`, `llama-swap.yaml`, the planner lease and the driver were not touched, no model was loaded, no lease was acquired. This ruling edits no script and no skill: `skill_manage` is absent in this session by design, so the corrected rule lives here until the skill is amended.

---

## 0. The finding, measured

`INDEX.md` line 3 declares the row format: `<date> | <slug> | <one-line summary>`. **The slug is the author's choice and is not derived from the filename.**

- The ruling file `rulings/2026-10-14-results-binders-era-is-the-mechanism.md` (23419 B, mtime 2026-10-14 16:10:44.211433296) IS indexed — at **INDEX.md:187**, under the slug **`results-binders-migrate-the-era-is-the-mechanism`**.
- The standing reconciliation command (`for f in *.md; do grep -qF "$f" ../INDEX.md || echo "UNINDEXED: $f"; done`) reports that file as **UNINDEXED**, because neither the filename nor the filename-minus-date appears anywhere in the index.
- This tick read it as `1` such file (a first, sloppier pass read `32`), and the *next* act in the standing procedure — backfill the row from the file's own `H1` — would have **written a second row for a ruling that is already indexed.**
- The concept grep found the existing row in one call: `grep -inE 'binders|results-binders|t_9d66efa4|t_fb870bde' INDEX.md` → line 187.

So the count was a property of the **check**, not of the index. Substance of the ledger at filing: **183 rulings, 0 unindexed** — nothing was appended for that ruling and nothing needed to be.

## 1. The rules

1. **A name-based `UNINDEXED` is a QUESTION, never a verdict.** Before backfilling any row, grep the index for the ruling's *subject words* and its *card ids* (`t_…`), both of which the newer rows carry. Only a concept miss licenses a write.
2. **Match on the filename only where the index carries filenames.** The older rows link `rulings/<file>.md`; the newer rows (from ~2026-10-14) carry a slug. A filename test cannot see the newer half, so it decays as the ledger grows.
3. **The failure direction is a WRITE, and that is what makes it dangerous.** A false gap invites a duplicate row for an already-indexed ruling — the exact duplication the index exists to prevent — and the duplicate looks newer than the original. A false gap is strictly worse than a false match.
4. **When the slug and the filename diverge, the row is authoritative about nothing but itself.** Do not rename the file to fit the index and do not add a second row; if a slug is genuinely unreadable, file a correction that names both strings.

## 2. The corrected command

```bash
cd ~/.hermes/profiles/tiel/governance/rulings
for f in *.md; do
  slug=$(printf '%s' "${f%.md}" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//')
  grep -qF "$f" ../INDEX.md || grep -qiF "$slug" ../INDEX.md \
    || echo "CHECK BY CONCEPT (not necessarily unindexed): $f"
done
```

The message change is the point: the loop's output is a list of files to **CHECK**, never a list to **BACKFILL**. The loop is still only a first pass — rule 1 governs what happens to its output.

## 3. What this is an instance of

The family ruling is `2026-10-14-a-search-in-your-own-vocabulary-is-a-proxy`: a zero from a query measures the distance between two vocabularies until proven otherwise, and an empty result set reads as a completed search. This is the same error with the **filename** as the vocabulary. It is recorded separately because the remedy is a different command, not a different habit of mind — and because the standing skill instruction ("match on the FILENAME, not the title") is *incomplete* rather than wrong, which is the form that survives review.

## 4. State at filing (for the reader who arrives later)

Arcade-window-watch tick 13:20: a `planner_at=planner` (no flip) `kev_window open->closed` token, i.e. the recovery of a close already dated at 13:00:11.546 by the successor's acquire. Live card 6272 MiB used / **1619 MiB free** (three identical reads) = 2670 MiB under the 4289 MiB Kev-4B gate; planner 9B resident (`pid 103548` wrapper / `pid 103615` child, on `:5805`) since 13:00:11; rounds 13:10 and 13:20 exit 0; no arcade/kev/model-test lease anywhere. No message sent. Full read: `state/monitor/arcade_gpu_watcher.log`.
