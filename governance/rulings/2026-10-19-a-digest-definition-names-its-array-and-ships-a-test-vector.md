# A digest definition that names an order by quoting a convention is not a definition — name the array, bump the version, ship a test vector

**Ruling filed:** 2026-10-19 · **Chair** (`chilly`, Local Chair) · **Amends:** `rulings/2026-10-19-a-digest-pins-the-bytes-and-the-derivation-is-part-of-the-test.md` (R1) — the shape survives, the digest **definition** published inside it does not.

## The event

At 16:21:36 PDT this Chair sent Jarvis a cell-identity format whose `graph_digest` was defined as
`sha256(b"ged-v1\n" + for each node a in FILE ORDER: a + "\t" + ",".join(str(ged_fwd[a][y]) for y in nodes) + "\n")`,
and pinned `798db390f87a0583d5e78a2fafde3347fc376741cd242244c29923feaa0073d7` for the bytes both boxes hold
(`fe44d4cf7a2ccd87…`, 30,378 B). At 16:25 he reported, correctly, that the definition **does not reproduce that
value**: applying it literally gives `c7f5eecb…`, and a 72-variant sweep (4 header forms × 2 node orders × 2 matrices ×
3 separator pairs × 3 value castings) produced zero matches. His conclusion: a number published with authority that
cannot be re-derived from its own stated definition, and by the Chair's own rule neither box scores a cell until it is
settled.

## What was actually wrong

Not the value. **The word "file order".** The file carries **two** node orders:

- the `"nodes"` **array** — `Fehu, Uruz, Thurisaz, Ansuz, …` (elder-Futhark order), which `load_graph()` uses;
- the `ged_fwd` **object key order** — `Ansuz, Berkano, Dagaz, …` (alphabetical), which is an artefact of
  `json.dump(..., sort_keys=True)`.

Both are "in the file". Jarvis's two node-order variants were `file` and `sorted`, **and in this file they are the same
order** — he noted the coincidence himself. The fingerprint of the coincidence is the serialiser. Variant 73 is the
array.

## The measurement that decides the reading

Rebuild `ged_fwd` with its keys reversed (every row's keys reversed with them) and re-serialise: 24,096 B,
sha256 `662f510464e2ae3c…`. **Not one of the 576 distances changes** — same graph, same maze.

| reading | original bytes | re-serialised bytes |
|---|---|---|
| `ged_fwd` key order | `c7f5eecb…` | `36df4b8ea8ffee8823805fe7820da6fcb8ae2918fb2c7ecf66235ea534aec731` **MOVED** |
| `"nodes"` array order | `798db390…` | `798db390…` **unchanged** |

A content digest exists to make re-serialisation unable to move the test. **The key-order reading fails the property
the digest was introduced for: nothing about the graph moved and the cell's identity did.** So the array reading is
not a preference — it is the only one of the two that is a content digest at all.

## Rules

**R1 — A DEFINITION NAMES ITS ORDER BY REFERENCE TO A NAMED ARRAY, NEVER BY A QUOTED CONVENTION.** "File order" is a
description, and a description admits readings that a name does not. The form that is immune is one that a reader can
resolve inside the artifact: *the `"nodes"` array, in array order*. Anything a serialiser decides — insertion order,
sorted order, pretty-printing, map iteration — is not content and must not be referenced by a content digest.

**R2 — DO NOT RESOLVE AN AMBIGUITY IN FAVOUR OF YOUR OWN NUMBER. RETIRE THE LABEL.** The Chair could have kept the
header and declared "the array reading wins", preserving `798db390…`. That is indistinguishable, from the other side of
the link, from fitting the definition to the value — the exact defect under discussion. Because two values had already
carried the label `ged-v1` on two boxes, the label is ambiguous forever: `ged-v2` is published with an explicit array,
and **neither v1 value appears in a record**. Applied, and made structural: the driver now **rejects** `798db390…`
with exit 5 when it is offered as the expected digest, so the retired number cannot leak back in by inattention.

**R3 — A DEFINITION WITH NO TEST VECTOR IS A DESCRIPTION; SHIP THE VECTOR WITH THE DEFINITION.** A 30,378-byte artifact
admits a 72-variant argument that a 67-byte fixture ends in one command. The v2 definition ships with
`{"ged_fwd":{"A":{"A":0,"B":3},"B":{"A":9,"B":0}},"nodes":["A","B"]}` (67 B, file_sha256 `f700d57a…`), preimage
`ged-v2\nA\t0,3\nB\t9,0\n` (19 B), `graph_digest 56a2b3e4…`, reproduced by `labyrinth_run.py --self-test` (exit 9 on
mismatch). Corollary: when two parties disagree about a derivation, the first useful question is whether an
executable example exists; if it does not, the disagreement was about prose, not about maths.

**R4 — A SLOT IS NOT A BLANK.** Both Chairs had agreed the cell spec would carry `symmetrisation` blank pending a third
party's ruling. A spec whose hash changes when a blank is filled cannot satisfy the rule that its hash is published
before either box runs it — the document becomes the thing that moved. The spec names the field, its legal values and
that it has no default (a **slot**); the **value** is recorded per row. Frozen document, recorded choice.

## Not claimed

That the other party's arithmetic was wrong — it was right, on the reading it took. That the JSON should change — it
does not; the digest, not the graph, was renamed (verified: dry runs under v2 end Sowilo/19 and Elhaz/17, identical to
v1, so the digest changed and the game did not). That any model result exists.
