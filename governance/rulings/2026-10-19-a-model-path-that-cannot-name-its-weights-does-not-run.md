# a model path that cannot name its weights does not run — the labyrinth driver's model branch, and the two exit codes it spends

**Filed:** 2026-10-19, kanban card `t_030d9bd0` (build the labyrinth model path, code only, no cell run).
**Driver:** `ocho_arena/labyrinth_run.py`, 69,076 B, sha256 `b9f59778ffc149b1df440676c13771521f9808ea13c95f5508000223d7a207cc`,
commit `c509cc1`, pushed (`git rev-parse HEAD` == `git rev-parse origin/main` == `c509cc1dce354726cf045e92c97299694da065ca`).
**Supersedes by hash:** `c41df799a4612bf24a00b012b1ad6244bcb00ff3ddfbcaf5c1ca455c3379ead3` (37,153 B, commit `0086d3f`), which stays
retrievable at that commit. `CELL_01_labyrinth.md` **untouched**, still `6df7437a…` (11,841 B).

## The finding

The gate on the labyrinth arc was never memory. It was that `--model` was refused at admission by
construction: the walk's non-dry branch was an assertion, so any live dispatch exited 2 with *"no non-dry
dispatch exists yet"*. Building the branch is not a capability question, it is a **record-integrity**
question, and the spec says why in §3: the api id carries **no quant**. A row naming `critic3` or `ornith9b`
does not say which weights answered.

So the rule this revision lands is: **the weights are CHECKED, not quoted.** `--model-identity CARD` names
`api_model_id`, `quant`, `server_argv` (an ARRAY — a one-line string is refused because it cannot be
checked), `server_binary_digest`, and optionally `server_binary` for a lease-wrapped argv whose answering
binary is not `argv[0]`. The driver then re-derives what can be re-derived on this box:

- the binary's sha256 is **recomputed** from the file the argv launches; a mismatch is exit 11;
- the card's `quant` must appear in the gguf name the argv loads; a mismatch is exit 11;
- the api id must be served by `--base-url`; if not, exit 11 names the ids that are;
- **on every turn** the model the server reports answering must be the file the argv names — a swapping
  server (llama-swap) can change it mid-cell, and that is the one way a row quietly stops being about the
  model it names. Exit 11 names the ply.

The alternative — copying four fields out of a JSON file into a row — is a record that *asserts* its own
provenance. That is the class this driver has spent three revisions closing one flag at a time.

## The read grammar (it lives in the driver, and the prompt is in the row)

The frozen spec fixes the test and leaves the asking to the driver, so the rule is written down once:

```
one rune name, alone on the first non-empty line, case-insensitive,
surrounding quotes/backticks stripped          -> a proposal; legal set decides moved vs blocked
one of the eight abstention tokens             -> give_up; the cell ENDS
anything else (prose, punctuation, trailing
full stop, two names, fences, JSON)            -> not_an_action. NEVER truncated, never fuzzy.
```

The eight abstention words are borrowed **verbatim** from the sokoban read-grammar §2a list (R1, ratified
2026-10-13) because a second list would be a second convention for the same act.

The prompt names the rune **alphabet** and never the legal set. That distinction is the chess lesson applied
one cabinet over: 24 invented names are not derivable, so omitting them measures vocabulary; a position that
arrives with its candidates listed is a menu, and choosing from a menu measures the menu. The prompt text and
its digest travel in every row, so a prompt cannot move silently.

`--seed-model` is **consumed** now (request seed, record field, and slug component) — its old refusal said it
would be refused "until a model path reads it", and this is that path. It is still refused under `--dry-run`
on presence, not truthiness.

## The codes, and the one that stays unbuilt

`10` remains **reserved and not defined**: `EXIT_OUT_DIR_UNUSABLE` is agreed with the peer box and
deliberately deferred, because the cell authorisation names a driver hash and a fresh out-dir cannot step in
that hole. Moving the hash now would unpin a verified revision for nothing. The docstring says so in the same
breath as the codes it does spend:

```
11  the model path cannot state its identity
12  the model path cannot complete (unreachable, HTTP error, no choices, no token count)
```

`12` exists because a turn with no `usage.completion_tokens` cannot become a row: recording `0` would be a
measurement nobody made.

## Measured, not asserted

- `--self-test` exit 0: `pass`, `edge_counts_pass`, `admission_pass`, `parser_pass` all true, plus two new
  vectors — `parse_pass` (16 awkward inputs incl. `Uruz.`, `I move to Uruz`, a fence, JSON, an alias of self)
  and `identity_pass` (8 cards: 2 accepted incl. the lease-wrapped shape, 6 refused).
- Six live refusals hit at the CLI: no model (2), no identity (11), missing card file (11), api id mismatch
  (11), dead endpoint (12), identity under `--dry-run` (2) — **no out-dir created by any of them**.
- **SMOKE** (not a cell run; no benchmark row published): `critic3` = Llama-3.1-8B-Instruct Q4_K_M, `min`,
  `Fehu`, cap 4, thinking off, **0.5 s inside a 600 s ceiling** — `ended=true`, `plies=4`,
  `tokens_total=15`, end rune `Eihwaz`, 0 blocked / 0 not_an_action / 0 give_up, all four moves re-checked
  legal against the pinned graph by an independent script, `cell_spec_sha256` = the frozen `6df7437a`.
- Repeating that cell exits 7 — the duplicate guard now guards a dispatch that actually writes.

## What this does not claim

Not a benchmark row, not a model comparison, and not permission to run the cell. One model, cap 4, one
starting rune: this is evidence that the path executes and records honestly, which is what the card asked
for and all it asked for. The cell needs Mike's word.

**Flagged for the next session:** the peer box has not been told that 11 and 12 are spent here, and it
believes 10 is the next free code. That letter is owed before either box pins this revision.
