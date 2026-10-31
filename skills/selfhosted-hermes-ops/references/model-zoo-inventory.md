# Inventorying a local model zoo before adding models

A directory of GGUFs is usually far larger than what the runtime can serve, and the
gap is invisible: files sit there looking available while the runtime cannot see
them. Inventory first, because "which models can I actually use" and "which models
do I own" are different questions with different answers.

## The zoo is not the serving set

The managed runtime discovers models by scanning **top-level `*.gguf` in its models
dir** and skipping only the `assets/` subdir. Everything else — however large, in
whatever archive directory — is inert. So split the inventory explicitly:

```python
staged = {os.path.basename(p): os.path.realpath(p)
          for p in glob.glob("<models-dir>/*.gguf")}
assets = {os.path.basename(p) for p in glob.glob("<models-dir>/assets/*.gguf")}
zoo    = {os.path.basename(p): os.path.getsize(p)
          for p in glob.glob("<zoo-dir>/**/*.gguf", recursive=True)}
inert  = sorted(set(zoo) - set(staged))
```

Report three numbers: total GGUFs and bytes in the zoo, the count staged for the
runtime, and the **bytes still inert**. The last one is the actionable finding —
it is what the user cannot currently use, and it is usually much larger than they
expect.

Two related facts to check in the same pass, because they masquerade as the same
problem:

- A **projector at the top level of the models dir registers as a servable model**,
  so it appears in `/v1/models` as a chat-selectable ~500 MB entry. Assets belong
  only under `assets/`.
- Staging a model **regenerates presets and changes runtime behaviour
  immediately** on the next backend start. Bulk-staging is therefore a config
  change, not a filing exercise: inventory read-only first, and stage deliberately
  with the user's agreement about what becomes servable.

## Reading metadata: let the engine do it

Hand-rolled GGUF parsers are a known trap in this domain — the dialect stores KV
key lengths as uint32 rather than uint64 and nests array element types, so a
spec-faithful parser misreads the file and you spend rounds debugging your own
reader. llama.cpp prints every scalar an entry needs at startup:

```bash
llama-server --model <MODEL.gguf> --ctx-size 512 --port <scratch> --no-warmup --verbose 2>&1 \
  | grep -iE 'arch |n_ctx_train|n_layer |n_layer_all|n_vocab|full_attention_interval|n_embd_k_gqa|n_embd_v_gqa|expert_count|expert_used|nextn_predict_layers'
```

Use a tiny `--ctx-size` and a scratch port so this is cheap. Every value a catalog
entry needs comes from that one command — see `references/catalog-entries.md` for
which field is which, and for the MTP case where `n_layer_all` exceeds `n_layer`.

## Decide what is worth testing before loading anything

Two 22–24 GiB models cost minutes each to load and VRAM you may not have spare.
Rank candidates by what the metadata already told you, then test only those:

- **Same architecture as a working model** — a fine-tune of something already
  proven is a cheap prediction rather than a gamble. Two models reporting an
  identical profile is a strong signal they differ only in weights.
- **Vision tokens present** — a candidate for the projector question, and it
  decides whether a catalog entry needs an `mmproj` at all.
- **MTP present** — worth knowing it is *not* engaged until an entry says so.

## What to report

Sizes and counts per directory, the staged-vs-inert split with byte totals, the
capability signals per candidate model, and — for each model that looks promising —
what is still missing to make it usable (a catalog entry, a staged projector, a
window override). "Inert" and "broken" are different states and must not be merged:
the files are fine, nothing points at them.