# 2026-10-08 — the bundle can be silent too

**Authority:** Chilly (Local Chair). **Source:** the live v4 field, inspected while it runs.
**Class:** the silent zero one level up — fixed at the item, still open at the bundle.

## What is in the field right now

Four of the first 33 v4 bundles are empty. All four carry exactly four top-level keys — `generated`,
`harness`, `results`, `version` — with **`results: []`** and **no reason, no failure class, and no
serving-failure field anywhere in the artifact.**

    Cloudflare_clef-flash-IQ4_NL     exists, ran, results=[]
    Kev-4B-Q4_K_M                    exists, ran, results=[]
    Ternary-Bonsai-2-27B-PTQ1_0      exists, ran, results=[]
    laya_english_f16                 exists, ran, results=[]

**All four GGUFs exist.** This is not an absent-file skip: the entrant is present, the server ran, the
runner exited `rc=0`, and the bundle came back empty. **An empty result with a success code** is a
stronger misleading signal than an error.

## The reason exists and is thrown away

The runner computes it. `run_card.py` builds `why_empty` — *"results list is EMPTY (measured nothing)"* —
and writes it **to the log**, not to the bundle:

    Kev-4B-Q4_K_M_cardv4_...  rc=0  scored=False  14s  results list is EMPTY (measured nothing)

So the information is available at write time, and only the artifact loses it. **The only record that
travels with the file is a filename label**: `run_card.py:221` rewrites `_neutral_` to `_EMPTY_` in the
name. A label, with nothing behind it.

## And it is systematic, not transient

The same entrants are empty in **v3 as well** — Kev-4B, Cloudflare_clef-flash-IQ4_NL,
Ternary-Bonsai-2-27B-PTQ1_0 and laya_english_f16 all appear in the v3 log with the same message. **Two
fields, same four entrants, same silence.** That is not a serving hiccup; it is a repeatable failure of a
class the harness has no vocabulary for, in both versions, costing roughly a tenth of each field.

## The ruling

**1. The silent-zero fix was written at one level and the class exists at two.**

The item path now records its serving failure. The bundle path writes an empty list and nothing else.
**A fix applied at one level of a nesting does not close the class at the others** — the same lesson as
the field-name and level rulings, now with the repair itself as the example.

**2. A filename label is not a record.**

`_EMPTY_` in a name is readable by a convention-aware tool and invisible to anything reading the JSON.
**Every rule this project has about labels applies: the raw assigns the class; a label applied
afterwards does not.** If the reason is known when the file is written, it belongs in the file.

**3. `rc=0` with an empty payload must not be reportable as a completed entrant.**

The runner's own comment says a bundle can exist and be empty, and a cleaner counts it correctly — but
the artifact does not. **Any consumer counting files rather than measurements gets a wrong answer from
these four**, which is the file-versus-measurement defect that started this entire day.

**4. Nothing here is fixed by the v4 criteria.**

C3 requires the failure class as a field written at scoring time. **A bundle that never reaches scoring
has no scoring path to write it**, so C3 as written cannot catch these four. The criterion needs to
cover the pre-scoring failures too, or the version that fixes the class will ship the class.
