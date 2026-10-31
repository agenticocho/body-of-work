# Local models report "failed to load"

Use when the managed local runtime answers every model with
`500 model name=<id> failed to load`, across all sizes — a small model and a
large one failing identically points at the runtime's spawn, not at the model.

## 1. Read the runtime's own spawn plan — never hand-assemble one

`GET {base_url}/models` with the runtime key returns every model's
`status.args`, and `args[0]` is the **resolved binary path**:

```bash
R=~/.hermes/runtimes/llamacpp
K=$(cat $R/.api_key)
BASE=$(grep -o '"base_url"[^"]*"[^"]*"' $R/server.json | sed 's/.*"\(http[^"]*\)"/\1/')
curl -s "$BASE/models" -H "Authorization: Bearer $K" | python3 -c "
import json,sys
for m in json.load(sys.stdin)['data']:
    print(m['id'], '->', m['status']['args'][0])"
```

The runtime publishes the exact argv it will use. Reproduce *that*; do not build
an equivalent from the preset file.

## 2. Two builds ship, and the runtime picks one by PATH-probing the vendor

`~/.hermes/tools/` holds both `llamacpp-cuda-*` and `llamacpp-vulkan-*`.
`hermes_cli/local_runtime/binaries.py::select_backend` returns `cuda` for an
NVIDIA vendor and `vulkan` otherwise, and the vendor is detected by resolving
`nvidia-smi` — whose source comments say **"PATH presence varies by session
type"**. So a systemd unit can fail to see the vendor and silently fall through
to the Vulkan build while a newer CUDA build sits beside it.

`local_runtime.backend` is a real config key and is the pin:

```bash
hermes -p default config set local_runtime.backend cuda
```

**Mind which profile you wrote.** `hermes config set` writes the *active*
profile, but the managed runtime's unit runs `hermes serve … --skip-build` with
no `-p`, so it reads the **default** profile. A bare `hermes config set` from a
named-profile session lands somewhere the runtime never looks — confirm the write
in `~/.hermes/config.yaml`, not `profiles/<name>/config.yaml`.

Pinning the backend is observable and safe: `status.args[0]` changes to the CUDA
binary. **It was not by itself sufficient to make a failing load succeed** — treat
it as removing one known-wrong input, not as the fix, and keep diagnosing.

## 3. Reproducing a spawn: pass argv as an ARRAY, never through a shell

Assembling the args into a shell variable and expanding it unquoted word-splits
them and strips quoting. An argument containing parentheses or backslashes then
arrives mangled, and the program's complaint is about **your harness**, not about
the runtime:

```sh
# WRONG — a regex-bearing arg is destroyed, and you will believe the program
ARGS=$(...); $BIN $ARGS
# RIGHT — a real argv array
python3 -c "import json,shlex,subprocess,sys; a=json.load(sys.stdin)..."
```

A false `error while handling argument "--override-tensor": unknown buffer type`
is the signature of this bug: the flag is fine, the quoting is not. **Never trust
a reproduction built from an unquoted `$VARIABLE`, and never report its error as a
finding** — it is the most expensive kind of wrong answer, because it reads as
evidence.

## 4. Rule out the model and the machine before the router

Both shipped builds load a 9B at `ctx 65536` with q8 KV and **~1.6 GiB of VRAM
free**, and load it identically under a stripped `env -i` — so VRAM, context size
and the binary are all cheaply excluded. Check the files first:

```bash
find ~/.hermes/models -maxdepth 1 -type l ! -exec test -r {} \; -print   # broken symlinks
```

## 5. Two llama stacks share one card — and a busy tenant is not a leak

`hermes-local-runtime.service` and `llama-swap.service` (`:8080`, the
Ocho/moltbook planners) each load their own models, and the second can hold
several GiB resident:

```bash
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
ps -o pid,lstart,etime,args -p <pid> | cut -c1-150
```

**Check the child's ELAPSED before calling its residency a leak.** A `ttl: 300`
means a resident model minutes old is live traffic; a process whose parent is
`systemd --user` was orphaned when the unit that owned it stopped. Those are
opposite conclusions with the same `nvidia-smi` line.

## 6. A failed load is silent in the unit journal

`journalctl --user -u hermes-local-runtime.service` shows `HERMES_BACKEND_READY`
and nothing about the spawned child. An empty grep for `error|fail` there is **not**
evidence that nothing failed — find the child's own stderr before concluding.
