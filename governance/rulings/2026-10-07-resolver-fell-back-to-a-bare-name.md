# 2026-10-07 — the resolver that fell back to a bare name

**Authority:** Chilly (Local Chair), on measurement. **Scope:** the Arena card run under systemd.
**Failure:** 26 of 47 card-v3 bundles measured nothing.

## The measured facts

| fact | value |
|---|---|
| card-v3 bundles on disk | 47 (46 distinct entrants) |
| `_EMPTY_` bundles | 26 |
| server logs in `logs/` | 47 |
| **zero-byte server logs** | **26** |
| non-empty server logs | 21 |

**The correspondence is 1:1.** Twenty-six zero-byte logs, twenty-six empty bundles; twenty-one
populated logs, twenty-one bundles carrying a result. The empty bundle is not a model that answered
badly. It is a model that never ran.

## The boundary is a single pid

```
last populated server log : arena-server-186226-55085.log
first zero-byte server log : arena-server-188368-51787.log
systemd MainPID           : 188366
```

**Every server spawned under the systemd unit produced zero bytes. Every server spawned before it
produced output.** The transition is the unit, not the models.

## The cause

`run_card.py:38`

```python
SERVER = (os.environ.get("LLAMA_SERVER") or shutil.which("llama-server") or "llama-server")
```

Under the systemd user manager, `PATH` does **not** contain `~/llama.cpp/build/bin`, which is where
`llama-server` lives. So:

1. `LLAMA_SERVER` is unset.
2. `shutil.which("llama-server")` returns `None`.
3. **The fallback is the bare string `"llama-server"`** — not `None`, not an error.
4. `arena.py:225` receives a **truthy** `binary`, so it never calls `find_llama_server()`.
5. `find_llama_server()`'s list at `arena.py:143` **contains the correct absolute path** and would
   have worked. It was never consulted.

**One line chose a name over a measurement.**

## And the failure reported success

```
Meta-Llama-3.1-8B-Instruct-Q4_K_M   rc=0   scored=False   results list is EMPTY (measured nothing)
```

`rc=0`. The runner's own classification says *the model produced nothing*, which is a statement about
the model. The truth is *the server never existed*, which is a statement about the machine.
**A failure path that reads as its own success path** — the class of `2026-10-07-reading-a-check-result-wrong`,
found here on the run's final state.

Corroboration: GPU at **759 of 8192 MiB** throughout. Nothing ever loaded; there was no contention to
blame. And the 26 are not weak models — the list includes `Meta-Llama-3.1-8B-Instruct-Q4_K_M`, which
scored **0.78 Orange** in the v2 pilot.

## RULING

**A resolver that cannot resolve must REFUSE. It may never fall back to a name.**

`or "llama-server"` is the defect. A bare name is a *plausible* value, which is worse than `None`,
because `None` raises at line 275 and a name raises nothing at all. The chain is
`explicit → env → PATH → REFUSE`; there is no fifth step, and there is never a string literal.

Corollary, same rule as `resolve-python.sh`: **resolution happens once, at start, against the
environment it will actually run in** — and if the answer is not exactly one thing, the process does
not start. Silent fallback is not resilience; it is the failure being hidden at the moment it is
cheapest to catch.

## Consequence for the re-run

**Step 3 of the sequence — re-run v3 for raw output — will reproduce all 26 unless this is fixed
first.** The re-run is being done so the instrument can be checked; a re-run that inherits a broken
resolver produces 26 new empty bundles with *no* raw output in them, and the audit still cannot be
performed. **Fix the resolver, then re-run.**

## Two remedies, both Ocho's to apply

1. **Immediate:** give the unit the absolute binary — `--llama-server /path` or
   `Environment=LLAMA_SERVER=/home/chilly1/llama.cpp/build/bin/llama-server`.
2. **Durable:** delete the `or "llama-server"` fallback and let the existing `arena.py:275` guard
   fire. **The guard already exists; the fallback is what prevents it from ever being reached.**

## The same defect, twice in one day, in two services

`hermes-webui.service` resolved a Python interpreter by PATH and silently picked whatever it found;
it now refuses unless exactly one match exists. The Arena's server resolves by PATH and silently picks
a name that cannot exist. **Same trap, different service, same day** — which is the argument for the
rule being a rule rather than a patch.
