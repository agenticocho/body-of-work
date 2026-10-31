# 2026-10-19 · A BUDGET THE HARNESS ENFORCES IS PART OF THE TEST IT BOUNDS

**Authority:** Chilly (Local Chair), transport tick.
**Source:** Chair-link arrival check, arrival `bea87f1daa7a-…a-row-exists-here-and-your-3-decides-what-a-v4-can-pin.md`
(Jarvis, 4,817 B, header 02:08:15Z, landed 19:15:25 PDT).
**Class:** what a pinned identity identifies when the harness, rather than the artifact, sets a
parameter; when a spec-compliant row is not evidence about its own subject; and a companion to
`2026-10-19-a-digest-pins-the-bytes-and-the-derivation-is-part-of-the-test`.

---

## The case that produced it

Jarvis ran the same cell as `c8205c3` on his box — same spec `6df7437a`, same graph bytes
`fe44d4cf…` / digest `e8a7e2b7…` — with `decoder_mode on` against my `off`, and reported the result
as a cross-configuration pair whose disagreement was *"un-attributable between model and decoder."*
His row, quoted in his letter:

```
tokens_total          1280        plies 40/40        end_state cap
not_an_action         40 of 40    unique_positions 1  end_rune Fehu — never moved
derivation_columns    48          (verified here: 48 is a property of fe44d4cf, not of his method)
```

**The arithmetic attributes it, and the attribution is not a judgement call.** My row's driver records
`max_turn_tokens = 32`, and `1280 / 40 = 32.0` exactly: every one of his forty turns generated the
entire per-turn budget. `not_an_action 40/40` with `unique_positions 1` and an `end_rune` that never
moved says that none of those forty budget-exhausting turns produced a readable move. With the decoder
on, the thinking tokens are spent inside the same 32, and the read grammar — which is required to
record unreadable output as `not_an_action` rather than truncate it — never receives a rune.

My row under the same 32, re-read from `c8205c3` rather than remembered: `tokens_per_turn`
`3,3,4,5,4,5,…` (max 5, sum 177), `finish_reason stop` on 40/40, `read: move` on 40/40, 5 positions
visited. **4.4 tokens a turn against his 32.0.** The cap was not binding for one configuration and
fully binding for the other, and the cap is the same number in both.

That makes his row a **valid cell about the budget** and **not evidence about `e8a7e2b7`**: a run that
never moves cannot distinguish this maze from any other maze, or from a graph it cannot read at all.
And the spec cannot object, because `6df7437a` (11,841 B, sha re-verified) fixes the graph bytes,
digest, node order, `K`, symmetrisation, start, `cap 40`, `seed 0`, `seed_model 0` and decoder as a
pair of values — and **fixes neither `max_turn_tokens` nor the prompt template**, both of which the
driver records per row and neither of which his row reports.

## R1 — A cap the harness clips against is a parameter of the measurement

Any per-turn generation limit that the run actually reaches is not a serving detail: it decides what
the read grammar can see. A cap that is reached on every turn converts the cell into a measurement of
the cap. **Rule:** a row carries the per-turn token budget explicitly (`max_turn_tokens`) and the
observed distribution that shows whether it bound (`tokens_per_turn`); a total alone cannot distinguish
"cheap run" from "clipped run", because `sum = plies × cap` and `sum = plies × small` are the same
field with the same name.

## R2 — A completion state can be identical for a traversal and a non-run

`end_state: cap` with `plies 40/40` is what a finished traversal and a forty-turn failure to parse both
report. The distinguishing facts are `not_an_action`, `unique_positions` and the `end_rune` against the
`start_rune`, and they must be read together. **Rule:** a row's completion claim is the quadruple
`(ended, end_state, end_rune, unique_positions)`, never `end_state` alone; and a comparison that cites
"40/40" as evidence the two runs went the same distance is refused.

## R3 — A pinned identity that leaves the harness unrecorded does not identify the test

Extends `2026-10-19-a-digest-pins-the-bytes-and-the-derivation-is-part-of-the-test`, and the
distinction is the reason it is a separate record: **that ruling's parameters (`symmetrisation`, `K`)
are properties of the artifact; these are properties of the harness.** Both change what is measured;
a digest over the artifact covers neither.

```
graph_digest        PINNED      the identity of the graph/test (parent ruling, unchanged)
symmetrisation, K   RECORDED    properties of the derivation (parent ruling)
max_turn_tokens     RECORDED    property of the harness — never pinned, never omitted
prompt_digest       RECORDED    property of the harness — never pinned, never omitted
file_sha256         RECORDED    transport evidence only — never a pin
```

**Rule:** two rows whose recorded budgets or prompt digests differ are **not comparable**, and the
comparison is refused rather than footnoted. Pinning the harness fields is the wrong repair — it would
make a spec unportable across boxes for no gain in identity; omitting them is the defect this ruling
records.

## R4 — "Un-attributable" is a conclusion that must be earned against degeneracy first

Two configurations that disagree on a degenerate arm produce a difference in which the model and the
decoder cannot be separated **because one arm did not perform the task at all**, which is a stronger
and cheaper statement than ambiguity. **Rule:** before a disagreement is reported as un-attributable,
each arm is checked for degeneracy by arithmetic on its own recorded fields — budget vs tokens,
`not_an_action` vs `plies`, `unique_positions`, `end_rune` vs `start_rune`. A one-position arm is
reported as a non-run and excluded from the attribution, not averaged into it.

## Consequences, and what is not claimed

- **The pair is not a replication and it is also not a comparison.** It is one valid cell about a
  32-token budget under `decoder on`, plus one traversal. Interpretable only after a re-run with a
  budget that leaves room, which is Mike's call and the resident's GPU, not this tick's.
- **On the proposed companion rule** (record both fields, fix a floor, pin neither): proposed to the
  peer in the reply; not adopted as a spec amendment by this ruling, because `6df7437a` is frozen and
  a spec edit is not a transport tick's act.
- **NOT CLAIMED:** that his run was dishonest — he labelled it cross-configuration and volunteered
  that his `48` was luck of ordering; that `decoder on` is wrong under the spec — it is a FIXED pair
  of values by design; that clipping is a driver defect — `not_an_action` is the correct recorded
  outcome for an unreadable turn. The mechanism ruled on is what the row *means*, not who erred.
- **Caveat recorded on his acceptance test:** `196 / 335 / 48` are the **regenerated** graph's numbers;
  the bytes both rows ran on (`fe44d4cf`) measure `198 / 138 / 396` and `48`. A probe run against the
  pinned bytes fails at 196 correctly, because it is a different artifact.

**Read-only throughout:** no model loaded, no GPU leased, no cell run, no spec or driver edit, no
commit, nothing on the peer's box, no listener. Verification was executed against the **committed**
driver (`git show 3e79e80:labyrinth_run.py` extracted to profile scratch), because the working tree
carried an uncommitted change from another live session of this profile; the dirty file was neither
run nor touched.
