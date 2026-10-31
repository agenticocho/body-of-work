# Adding a catalog entry for a model the catalog does not ship

A projector (`mmproj`) is reachable **only** through a `catalog.json` entry — there
is no config-file route — so the entry is the fix for local vision. Durable in the
strongest sense, because the catalog is refetched from upstream every 6h and swapped
in wholesale, so a local edit vanishes and the entry has to land upstream.

A **context window** is different, and conflating the two wastes an evening: a
catalog entry supplies `n_ctx_train`, which is only a *ceiling* on what the planner
may choose. It does not request the window you tested. To launch at a verified size
you also need a machine-local grant in
`~/.hermes/runtimes/llamacpp/window_overrides.json` — see
`references/long-context-testing.md` step 5. Ship the entry upstream; keep the
override local.

This is the procedure for writing one, plus the traps that make a hand-built
entry either inert or boot-breaking.

## Before writing anything: know which product owns the setting

Catalog entries drive the **managed llama.cpp router** only. They say nothing about
whether a model/projector pair actually works — prove that standalone first (see
`references/long-context-testing.md` and `references/local-vision.md`). Writing a
catalog entry for a pair you have not proven is the wrong order: you get a healthy
service and a model that still cannot do the job.

## Required vs optional fields

A missing **required** scalar raises `KeyError` at import time and **takes the
backend down at boot** — not a warning, an outage. Back the file up before
experimenting and restore it the moment an import test fails.

Required per entry: `id`, `display_name`, `description`, `repo`, `n_ctx_train`,
`full_layers`, `recurrent_layers`, `per_layer_f16`, `variants`. Optional with
defaults: `moe`, `mtp`, `mtp_draft_depth`, `n_vocab`, `sampling`, `min_engine`,
`quality`, `decode_fraction`, `swa_*`, `mmproj`, `draft`.

## Derive the scalars from the model, never from the filename

A filename tells you nothing about architecture. Get the values from the engine
that will actually load the file — llama.cpp prints every one at startup, which
beats hand-rolling a GGUF parser:

```bash
llama-server --model <MODEL.gguf> --ctx-size 512 --port <scratch> --no-warmup --verbose 2>&1 \
  | grep -iE 'arch |n_ctx_train|n_layer |n_vocab|full_attention_interval|n_embd_k_gqa|n_embd_v_gqa|expert_count|expert_used'
```

Two derivations that are easy to get wrong:

- **`per_layer_f16`** = KV bytes per token per full-attention layer =
  `(n_embd_k_gqa + n_embd_v_gqa) * 2`. Not the model's hidden size, and not the
  head dimension.
- **`full_layers` / `recurrent_layers`** come from the architecture's attention
  pattern, not from `n_layer` alone. For a hybrid model with
  `full_attention_interval = 4` over 40 layers: 10 full, 30 recurrent.

### MTP / speculative decoding changes the layer arithmetic

A model with a multi-token-prediction head reports **`n_layer_all` one greater than
`n_layer`** (41 vs 40), and `nextn_predict_layers` > 0 in its metadata. Copy the
base model's entry verbatim in that case and the layer counts are wrong by exactly
the draft head.

- The cross-check against the base entry below only holds for the *attention*
  profile. An MTP fine-tune of a cataloged base needs its own `mtp: true` and
  `mtp_draft_depth` (the head's `nextn_predict_layers`), and its
  `full_layers + recurrent_layers` must still sum to `n_layer`, **not**
  `n_layer_all` — the draft head is not an attention layer.
- **Tensors present ≠ MTP engaged.** A file full of `nextn` tensors still gets no
  `spec-draft` line in `presets.ini` until an entry sets `mtp: true`, so the
  headline speedup is absent from a preset that looks correct. Confirm by grepping
  the generated preset for `spec-draft`, not by the filename containing `MTP`.
- Enabling it costs VRAM the draft head needs *on top of* an already
  VRAM-constrained model, so budget it against the same card rather than assuming
  it is free.

### Vision tokens do not imply a usable projector

Checking the tokenizer for `<|vision_start|>` / `<|image_pad|>` proves the model
was *built* to accept image embeddings, which is a useful capability signal. It
says nothing about whether the matching projector exists, is staged as an asset, or
is attached by a catalog entry. Two same-architecture fine-tunes can differ here:
one carrying vision tokens and a catalog entry, the other carrying them and nothing
else, so the second returns the projector error despite identical capability.

Treat "has vision tokens" and "can serve an image" as two separate findings, and
only the second is what an image request needs.

**Cross-check against the base model's entry.** A fine-tune inherits its base's
layer profile, so if the model is a fine-tune of something already cataloged, your
computed numbers should match that entry exactly. Ours did —
`full=10 recur=30 per_layer_f16=2048`, identical to `qwen3.6-35b-a3b`. That
agreement is worth more than any single field you read, and a mismatch means
stop and re-derive.

## The lookup key is the GGUF filename stem, not your catalog `id`

This is the trap that makes a correct-looking entry do nothing. Lookup goes
`entry_for_model(model_id_from_stem(gguf.stem))`, and `variant.model_id` derives
from `files[0].path`. So the **filename** is what must match, not `id`:

```python
# catalog.py
model_id = model_id_from_stem(PurePosixPath(self.files[0].path).name.removesuffix(".gguf"))
```

Your `id` is a human-facing label and never participates in the match. Verify the
whole chain resolves before committing:

```bash
python3 -c "
import sys; sys.path.insert(0,'.')
from hermes_cli.local_runtime.catalog import find_entry_for_model
from hermes_cli.local_runtime.presets import _asset_path
hit = find_entry_for_model('<FILESTEM>')
print('hit:', bool(hit))
if hit: print('asset:', _asset_path(hit[0].mmproj))"
```

## Validate through the real loader, not a hand-rolled parse

Import the catalog module and call its own `_load_catalog()`. The package
`__init__` pulls in heavy deps, so if the plain interpreter lacks them, install
into the agent dir rather than stubbing the package — stubbing breaks
`importlib.resources` and the loader then fails for an unrelated reason:

```python
import sys; sys.path.insert(0, "/path/to/hermes-agent")
import json
from hermes_cli.local_runtime import catalog as cat
entries = cat._load_catalog(json.load(open(".../catalog.json")))
print(len(entries), "entries")
t = [e for e in entries if e.id == "<your-id>"][0]
assert t.full_layers + t.recurrent_layers + t.swa_layers == <n_layer from the model>
```

That last assertion is the one worth keeping: layer counts that do not sum to the
model's real layer count produce a KV cache sized wrong, which shows up much later
as a context overflow at load.

## Stage the projector as an asset, at the size you declared

The entry's `mmproj.local` must exist at `~/.hermes/models/assets/<local_name>`,
and its `size_bytes` must be the real file size:

```bash
stat -c '%s' <PROJECTOR.gguf>     # must equal the entry's size_bytes exactly
ln -sfn <PROJECTOR.gguf> ~/.hermes/models/assets/<local_name>
```

Never at the top level of `~/.hermes/models/` — the model scan walks that
directory and skips only `assets/`, so a top-level projector registers as a
servable model.

## Confirm the entry actually takes effect

A validated entry that never activates is the usual outcome of testing on the
wrong backend. **Find out which process owns the managed runtime** before
concluding anything:

```bash
ss -ltnp | grep <llamacpp-port>            # who holds the port
PPID=$(ps -o ppid= -p <llama-server-pid> | tr -d ' ')   # its parent
tr '\0' ' ' < /proc/$PPID/cmdline | tail -c 80          # which backend, which flags
```

Only the backend that called `generate_presets` rewrites `presets.ini`. A
third-party WebUI process may run the agent in-process **without ever calling it**,
so restarting that service regenerates nothing and the preset looks unchanged. If
the managed runtime turns out to be owned by a GUI app rather than a systemd unit,
then no systemd unit regenerates presets at boot — say so, because it changes what
"persistent" means for every window and projector setting.

**The asset must exist before the backend starts, not after.** The check is a
stat-plus-resolve at generation time, so staging the projector after the owner has
already started means the next start is the *first* one that sees it — and until
then every symptom looks identical to "my entry is wrong". When the entry is
validated and correct but nothing changed, compare the two timestamps before
re-deriving anything:

```bash
stat -c '%y' ~/.hermes/runtimes/llamacpp/presets.ini          # when it regenerated
stat -c '%y' ~/.hermes/models/assets/<your-local-name>       # when you staged it
```

Presets older than the asset means the owner has not started since. Equally, check
the owner's **start time** against your commit time before blaming a stale import:
a backend that started *after* your edit already read the new catalog, so "the
process is holding an old catalog" is the wrong diagnosis and sends you re-checking
the file you already proved correct.

**When the runtime is owned by a GUI, add a systemd unit for it** rather than
leaving every setting a session experiment — see *Who owns the service you are
proxying to* in `references/remote-access.md`. Note what such a unit must *not* set:
the Desktop flag changes backend lifecycle and auth exemption, so a standalone unit
that inherits it behaves differently from the one you meant to replace. Omit it, and
prefer `ExecStart` against the `hermes` launcher (which resolves the interpreter
itself) over a hand-built `python3 -c` invocation that has to reproduce the
toolchain's `sys.path` setup.

## What to commit, and what to leave behind

Keep the diff to the one JSON file. Packages you installed into the agent
directory to make imports work are untracked build aids, not part of the change:

```bash
git status --porcelain          # untracked yaml/, psutil/ etc — do NOT add
git diff --name-only            # should be just catalog.json
```

Put the measured configurations — including the ones that **failed** — in the
commit message. A reviewer needs the boundary, not just the success: which window
loaded, which OOM'd, which collapsed on generation, and what `n_ctx_train` said.
That evidence is what makes the entry reviewable rather than a guess.

## Before pushing

Do not push to the upstream repo without the user's explicit go-ahead — a remote
write is a side effect they did not ask for. Set up a fork and a PR as an offer,
and report the branch and commit locally so they can inspect it first.