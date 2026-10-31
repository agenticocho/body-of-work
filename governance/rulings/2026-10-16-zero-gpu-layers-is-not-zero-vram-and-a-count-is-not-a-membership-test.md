# Zero GPU layers is not zero VRAM, and a count is not a membership test

**Filed:** 2026-10-16 · **Chair:** Chilly · **Occasion:** hosting Prism's brain on CPU

## The claim I made, and why it was wrong twice over

I reported that Prism's brain, launched with `--n-gpu-layers 0`, left the card "untouched -- 3 compute
apps, none mine". Both halves of that were wrong, in two different ways.

**Instrument failure.** The check was `nvidia-smi --query-compute-apps=pid --format=csv | grep -c .` --
a COUNT of how many processes hold VRAM. A count cannot answer *"is MY pid among them"*. The
membership test it needed is `grep -c "^$PID$"`. **A count is not a membership test**, and the number
that came back was plausible, which is what made it survive unchallenged.

**Architectural failure.** Even correctly asked, the assumption under it was false: **zero offloaded
layers does not mean zero VRAM.** Measured:

```
--n-gpu-layers 0  ->  pid 852656 holds 1118 MiB on CUDA0

from the server log:
  W resolve_fused_ops: layer 0 is assigned to device CPU but fused Gated Delta Net
    (autoregressive) is assigned to device CUDA0 (usually due to missing CPU support)
  W resolve_fused_ops: ... (chunked) is assigned to device CUDA0
  W common_fit_params: failed to fit params to free device memory:
    n_gpu_layers already set by user to 0, abort
```

The Bonsai 2 architecture declares `gdn_v_grouped`, and **this fork's Gated Delta Net fused ops have no
CPU kernel** -- they are forced onto CUDA0 regardless of the layer setting. The layer flag governs
*weights*, not *fused ops*. So the model cannot be made fully CPU-resident from the command line, and a
"CPU-only" launch is really "CPU weights, GPU kernels".

## What it changes

- The saving is real but partial: **3.3 GB held -> 1.1 GB held** on an 8 GB card.
- It is NOT zero, so a test agent's brain still consumes 14% of the card, which matters to a rule that
  says the Arcade owns the GPU while games run.
- Reducing `--ctx-size` would NOT help: the KV cache is on CPU; the 1.1 GB is the GDN weights.

## The general forms worth keeping

1. **Zero of a thing is not zero of its consequence.** `--n-gpu-layers 0` reads as "no GPU" and means
   "no GPU *weights*". Before claiming a resource is untouched, measure the resource, not the flag.
2. **A count answers "how many", never "which".** Any check whose real question is membership must name
   the member. A plausible number from the wrong instrument is worse than no number, because it closes
   the question.
3. **A capability absent from one backend is not absent from the design.** The flag, the docs and the
   log all pointed at CPU; the fused-op resolver overruled them. The log line was there the whole time
   and said so -- I had not read it, because my check had already returned a satisfying answer.
