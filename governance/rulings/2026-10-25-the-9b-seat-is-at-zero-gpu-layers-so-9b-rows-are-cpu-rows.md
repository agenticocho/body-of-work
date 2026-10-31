# The 9B seat is at zero GPU layers, so every 9B row from this box is a CPU-only row

**Filed 2026-10-25, from the chair-link letter `3652ac0de9a5` (Jarvis) and this box's own instrumentation. Prior art: 433 records, top candidate 0.127, no duplicate.**

## The finding

`prism-brain.service` serves `Ternary-Bonsai-2-9B-PQ2_0-MTP-Q8_0.gguf` on `127.0.0.1:58595` through
the PrismML fork's CUDA build, with `--n-gpu-layers 0`. Measured from the live process, not from a
unit file:

```
Ternary-Bonsai-2-9B-PQ2_0-MTP-Q8_0.gguf --mmproj Ternary-Bonsai-2-9B-mmproj-Q8_0.gguf
--alias prism-bonsai-9b --ctx-size 65536 --cache-type-k q8_0 --cache-type-v q8_0
--n-gpu-layers 0 --port 58595
```

The 9B Mastermind arm recorded in `ocho_arena/probes/mastermind/rows_9b.json` ran against
`base: http://127.0.0.1:58595` — this same seat. **Therefore that row is a CPU-only row.**

## Why this is a ruling and not a note

A CUDA build was present, the seat was named `prism-bonsai-9b`, and the run header recorded a `base`
URL but no `n_gpu_layers`. Every one of those reads as "the model ran on the card" to a reader who
does not check the argv. The row's provenance was therefore misdescribable in a report that otherwise
carries hashes and digests — the exact class this link exists to prevent, on the one field nobody
stamped.

**Rule: a row's hardware provenance comes from the serving process's argv — not from the binary's
build flags, not from the seat's alias, and not from the presence of a `.so`.** The corollary binds
the row schema: a run header that records `base` and omits `n_gpu_layers` does not record where the
numbers ran.

## The kernels are present and unrun — do not confuse the two

```
~/src/PrismML-Bonsai-demo-20261016/bin/cuda/libggml-cuda.so   195658536 bytes
strings … | grep -icE 'pq2_0|tq2_0'                            102
dequantize_pq2_0   k_get_rows<… dequantize_pq2_0 …>   QK_PQ2_0   GGML_CUDA_PTQ1_0_MMQ_MAX_BATCH
```

PQ2_0 has CUDA kernels compiled into this build. That makes a GPU run *possible*, not *measured*, and
not *correct*: presence of a symbol is not a forward pass. The one GPU failure on record here is in
the vision path, `clip_model_loader::load_tensors` → `ggml_backend_buffer_set_usage` → `ggml_abort`
while loading the mmproj at `-ngl 0` — the weights loaded and the projector did not.

**The unrun experiment is: projector dropped, text-only, `-ngl` raised.** It is a launch line, not a
build. It spends the card and would replace a live agent's brain, so it requires Mike's decision and
must not be started inside a transport tick.

## What this does not say

- Not that the model is wrong on CUDA. Nothing has asked the card to use the kernels.
- Not that the CPU row is invalid. It is a CPU row, correctly produced, wrongly describable.
- Not that the fork lacks the build. It ships one; that question is closed.
