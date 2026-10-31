# Testing long-context capability before routing a task to it

How to find the real ceiling of a local model's context window, and why the
ceiling is often lower than the number you would like.

## Why this needs its own procedure

A model's context is not a dial you set; it is a set of ceilings, each of which
fails differently and none of which the API reports up front:

- **trained window** (`n_ctx_train`) — beyond it, quality degrades even if it loads
- **VRAM for the KV cache** — the usual reason a large window "fails to load"
- **PCIe bandwidth** — the silent one: it loads, it answers, and it crawls

Only a real prompt at real size finds the last one. So the procedure is: find the
trained ceiling, then load it, then send a prompt near the ceiling with a
known-answer question at the end.

## Step 1 — find the trained ceiling

llama.cpp states it at startup and refuses politely:

```
n_ctx_seq (524288) > n_ctx_train (262144) -- possible training context overflow
```

That warning is the ceiling. Do not try to exceed it; a model past its trained
window produces plausible-looking summaries built on degraded retrieval, which is
worse than a hard failure because you cannot detect it from the output.

## Step 2 — load it, and know which knob moved the KV cache

At large contexts the KV cache no longer fits beside the weights, and the failure
names itself:

```
ggml_backend_cuda_buffer_type_alloc_buffer: allocating 5120.00 MiB on device 0: cudaMalloc failed: out of memory
failed to allocate buffer for kv cache
```

`--no-kv-unified` does **not** move the KV off the GPU. The flag that works is
`--no-kv-offload`, which keeps the whole cache in host RAM. That makes it *fit* —
and is the trap, because it silently trades bandwidth for capacity.

Confirm what actually loaded rather than trusting the flag:

```bash
curl -sS http://127.0.0.1:$port/props | python3 -c \
  "import json,sys; print(json.load(sys.stdin)['default_generation_settings']['n_ctx'])"
```

## Step 3 — send a real prompt with a known answer at the end

A `200` proves nothing about context handling; a short prompt fits any window.
Build a prompt of the target size, end it with an instruction whose answer appears
only at the very end, and assert on the reply:

```
prompt tokens : 118,920
answer        : '2063.'      expected: 2063
prompt tok/s  : 326.7
```

That is a real long-context result — 91% of a 131,072 window, answered correctly
after reading the prefix. The end-placed question also catches *lost in the
middle*, which is the failure mode that matters for summarizing a conversation.

Measure the boundary too. Over-window prompts should be **rejected with a precise
error**, which proves enforcement is real rather than silent truncation:

```json
{"error":{"code":400,"message":"request (312005 tokens) exceeds the available
 context size (262144 tokens)","n_prompt_tokens":312005,"n_ctx":262144}}
```

## Step 4 — measure throughput, and read the stall signature

Two throughput numbers matter: prompt eval and generation. Prompt eval is the
cost; generation is the canary.

**The stall signature of KV-in-RAM**: the slot reports `is_processing: true` while
the process consumes **zero CPU**. Confirm with jiffies, not `top`'s header:

```bash
A=$(awk '{print $14+$15}' /proc/$PID/stat); sleep 3
B=$(awk '{print $14+$15}' /proc/$PID/stat); echo "$((B-A))"   # 0 = stalled
curl -sS http://127.0.0.1:$port/slots      # n_prompt_tokens_processed vs _tokens
```

Measured on one 35B-A3B, same weights, same prompt shape:

| ctx | KV placement | prompt tok | prompt tok/s | gen tok/s |
|---|---|---|---|---|
| 131,072 | GPU | 118,920 | 326.7 | 36.9 |
| 262,144 | RAM (`--no-kv-offload`) | 149,799 | 289.7 | **3.9** |

Prompt eval barely moved, which makes the RAM placement look fine on the headline
number — but generation fell **9x**. Attention reads the KV cache once per
generated token, so PCIe cost shows up there and nowhere else. Always read both
numbers before recommending a window size.

Also read the slot's cache counters: when `n_prompt_tokens` greatly exceeds
`n_prompt_tokens_processed`, llama.cpp is reusing a cached prefix. Compression
resends a mostly-unchanged conversation, so successive calls are far cheaper than
their raw token count suggests — but only the first one pays full price.

## Step 5 — persisting the window you just verified

`ctx-size` in `~/.hermes/runtimes/llamacpp/presets.ini` is **regenerated on every
start**, so a hand-edited window survives exactly until the next restart. Two
durable mechanisms exist, and they are independent — pick by what you are
persisting:

| Mechanism | Persists | Scope |
|---|---|---|
| `catalog.json` entry `n_ctx_train` | yes, once upstream merges | the **ceiling** the planner may not exceed |
| `runtimes/llamacpp/window_overrides.json` | yes, immediately, machine-local | the **window actually launched** |

**The catalog entry alone will not give you the window you tested.** `n_ctx_train`
is a ceiling, not a request: the planner sizes each launch from the VRAM budget and
will happily pick something much smaller, reporting `spilled: True`. To actually
launch at your verified size, write the override:

```json
{ "<FILESTEM>": 131072 }
```

at **`~/.hermes/runtimes/llamacpp/window_overrides.json`** — note the `llamacpp/`
component. Written one level up at `~/.hermes/runtimes/window_overrides.json` it is
silently ignored, and the loader returns `{}` with no error, so the window stays at
the planner's choice and looks like the override "didn't work".

**Read the override back through the loader before trusting the file exists:**

```bash
python3 -c "import sys; sys.path.insert(0,'<agent-dir>')
from hermes_cli.local_runtime.growth import load_window_overrides
print(load_window_overrides())"
```

Because the override lives outside `presets.ini` it survives the regeneration that
discards hand-edits — which is exactly why it is the right home for a
machine-specific grant. Keep it when reinstalling; a catalog merge is not required
to use a window you have already proven.

## Reporting rule

Report the ceiling as a tested boundary, not a capability: name the context you
actually exercised, the throughput at that size, and the placement (GPU vs RAM)
that produced it. "Supports 128K" is only true if a 128K prompt was sent and
answered.