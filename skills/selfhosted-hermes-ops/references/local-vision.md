# Local vision on the managed llama.cpp runtime

Two independent failures look identical from the outside — a vision model that
"doesn't work". Separating them is the whole job.

| Layer | What it controls | Failure signature |
|---|---|---|
| Model + projector | whether the pair can see at all | text-only replies, or a wrong image description |
| Managed router wiring | whether llama-server is *given* the projector | `500 image input is not supported` |

A 500 from the managed runtime proves the wiring is missing. It proves nothing
about the pair. Always test the pair standalone before reporting it broken.

## Prove the pair first

```bash
scripts/probe-vision.sh <MODEL.gguf> <PROJECTOR.gguf>
```

Succeeds only when all four quadrants of a generated test image are described
correctly. A text-only model that guesses `200` still fails the assertion, which
is why the script checks content and not status.

Launch flags that matter:

- `--mmproj <PROJECTOR.gguf>` — the projector, as a process argument. This is the
  one thing the managed router will not do for you.
- `--ctx-size 8192` — small context is fine for a one-image probe and keeps the
  KV cache off the critical path.

## Put small vision models on the CPU

For a 1-3B vision model, CPU inference beats GPU offload on both footprint and
prompt throughput. Measured on LFM2.5-VL-1.6B serving one 64x64 image:

| flags | VRAM | prompt eval | generation |
|---|---|---|---|
| `--n-gpu-layers 0 --no-mmproj-offload` (CPU) | +220 MiB over idle | 138.9 tok/s | 57.8 tok/s |
| `-ngl 99` (GPU) | 2405 MiB | 72.6 tok/s | 249 tok/s |

The GPU path is *slower on prompt* because a small model crosses PCIe twice, and it
holds ~2.2 GiB the main chat model needs. The CPU path also composites better with
everything else, so a CPU-resident vision endpoint can stay up permanently without
starving the main model. Reserve GPU offload for models too big to run usefully on
CPU, where `--override-tensor 'blk\.\d+\.ffn_.*_exps\.weight=CPU'` moves FFN
experts off-card to make room.

**Reuse a disabled unit's flags before inventing an invocation.** A `disabled` unit
for the same model is a field-tested recipe: it already encodes the flags that let
this model coexist with the main one. Reading it beats guessing, and guessing
`-ngl 99` produces an OOM that reads like an incompatibility but is only a busy
card.

Expect `-ngl 99` to fail while the supervised runtime holds a resident model, and
to succeed once that is idle. Check
`nvidia-smi --query-compute-apps=pid,used_memory` before concluding a size limit.

## Identifying which projector belongs to which model

Projector filenames are not unique. A name like `mmproj-BF16.gguf` is declared
by several catalog models with different byte sizes — the name tells you nothing.

Match on **byte size against the catalog's declared `size_bytes`**:

```bash
stat -c '%s %n' <PROJECTOR.gguf>
python3 - <<'EOF'
import json
for m in json.load(open('hermes_cli/local_runtime/catalog.json'))['models']:
    p = m.get('mmproj')
    if p: print(m['id'], p['path'], p['size_bytes'])
EOF
```

A match within a few hundred bytes is the same artifact. Then confirm the *model*
was built to accept image embeddings by checking its tokenizer for vision tokens:

```bash
head -c 60000000 <MODEL.gguf> | strings -n 4 | grep -iE 'vision_start|image_pad|vision_end'
```

`<|vision_start|>`, `<|image_pad|>`, `<|vision_end|>` in the tokenizer plus
`<Image` handling in the chat template means the model has a vision path. The
projector should be a CLIP variant — confirm with
`strings -n 4 <PROJECTOR.gguf> | grep '^clip\.'` and look for
`clip.has_vision_encoder`, `clip.vision.block_count`, `clip.projector_type`.

Fine-tunes inherit their base's projector. A fine-tune of `qwen3.6-35b-a3b` works
with that model's projector, and a near-exact size match confirms it.

`is_deepstack_layers` in the projector keys marks the Qwen3-VL family, which is a
useful hint when the base architecture is otherwise ambiguous.

## Why the router cannot be fixed by config

The projector must be injected by the **catalog**, not by any settings file:

- It must exist at `~/.hermes/models/assets/<local_name>` (a subdir, so the model
  listing does not pick it up as a servable model).
- The `mmproj` argument is added only when a `catalog.json` entry declares that
  asset — a projector file on its own is inert.
- `presets.ini` cannot substitute: it is rewritten on every start, and an
  `mmproj =` line there is reinterpreted as a *model* definition, producing a
  bogus `[<projector-name>]` section that then shows up in `/v1/models`.
- A projector symlinked at the **top level** of `~/.hermes/models/` registers as a
  servable model, because the model scan walks that directory and skips only the
  `assets/` subdir. Keep it *only* under `assets/`. When a projector appears in
  `/v1/models`, check for a stray top-level symlink before suspecting presets.
- There is **no sideload API for assets**; the sideload endpoint takes `.gguf`
  models only.
- `catalog.json` is refetched from upstream every 6h and swapped in wholesale, so
  a local entry disappears silently. Fetch the remote and compare before trusting
  a local edit.
- Entries are strict — a missing required scalar raises `KeyError` **at import
  time and takes the service down at boot**. Back the file up, and restore it the
  moment a test import fails.

So router-driven vision means: use a model the catalog already ships with a
projector, or add a catalog entry upstream. The refetch pulls from `main`, so a
local patch is not durable — and the same change would fix any projector that
lacks an entry, not just one model.

## Choosing what to leave switched on

Never leave an aux task pointed at a model that cannot serve its modality. A
guaranteed 500 on every call is worse than the paid fallback it replaced. If a
vision pair works standalone but cannot be wired, restore that single task:

```bash
hermes config set auxiliary.vision.provider auto
hermes config set auxiliary.vision.model ""
```

Leave the other local aux tasks alone — one broken modality does not invalidate
the rest.

## The escape hatch: a second endpoint, when the router cannot be wired

A projector with no catalog entry is not the end of the road. Run the pair as its
own llama-server on an OS-assigned port and point `auxiliary.vision` at it with an
explicit `base_url`; the port is published at boot so nothing is hardcoded. This
is exactly what the old standalone aux units did, and it works — see
`references/second-llamacpp-endpoint.md` for the unit, the publisher, and the
verification. Reach for it when the model must be yours specifically (a
fine-tune, a projector the catalog lacks) rather than one the catalog ships.

Two things to accept when you do: an explicit `base_url` bypasses the runtime's
dynamic key lookup, so `auxiliary.vision.api_key` must be set explicitly too; and
a second server is a second thing to keep alive.
