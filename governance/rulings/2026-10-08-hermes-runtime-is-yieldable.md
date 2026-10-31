# RULING — 2026-10-08 — the Hermes managed runtime IS yieldable: the card now has a two-way referee

**Artifacts delivered:** `/home/chilly1/NVIDIA-PAIR/ops-docs/scripts/gpu-yield.sh` (working) and
`/home/chilly1/.hermes/workspace/RENOVATION_STEP1.md`.
**Class:** venue-plumbing measurement/build. Makes no claim about model capability.
**Extends:** ruling `2026-10-08-gpu-two-schedulers-live-budget` (which ended by saying the
coordination was one-directional and the Hermes side had "no clean external hook"). That
conclusion is now corrected: the hook exists.

## The finding

**The premise "nothing can ask Hermes' managed runtime to yield" is FALSE.** The Hermes runtime is
not a bare per-model `llama-server`; it is **llama.cpp's model router** —
`llama-server … --models-max 1 --models-autoload --models-preset …/presets.ini` — and llama.cpp's
router exposes a model-management HTTP API that Hermes' own supervisor already calls. Verified by
probe on the live runtime, not by reading:

- `POST http://127.0.0.1:48455/models/unload {"model":"Ornith-1.5-9B-Q4_K_M"}` →
  **HTTP 200 `{"success":true}`**; card **5387 used/2451 free → 282 used/7556 free** (5105 MiB freed).
- `GET http://127.0.0.1:48455/models` is the authoritative loaded-list (`status.value`).
- the next `/v1/chat/completions` for that model autoloads it and answers real inference.
- Source of record: `llama.cpp/tools/server/server.cpp:241`; `hermes_cli/local_runtime/supervisor.py:381-384`
  (`unload_model` → `POST /models/unload`, "bogus name -> 400"). Read-only; the checkout was NOT edited.

llama-swap's side is unchanged and re-confirmed live:
`POST http://127.0.0.1:8080/api/models/unload` → HTTP 200, `/running` → `{"running":[]}`,
3 465 MiB freed; `GET /unload` also accepted (the form `gpu-admit.sh` uses).

**Full round trip PROVEN end-to-end on the live machine** (card used/free measured at every step):
llama-swap holds (`ocho-planner-4b`, ttl:0) **3747/4091** → yield **282/7556** → Hermes loads +
answers (`Ornith-1.5-9B`, 16 tokens @12.77 tok/s) **5387/2451** → yield **282/7556** → llama-swap
reloads on demand + answers (`proposer`, 24 tokens) **6155/1683**. The documented OOM also
reproduced verbatim under the same guard (llama-swap holding 5874 MiB → 1677 free → Hermes 35B with
`-ot` → `tensor_buft_overrides already set by user, abort` → `cudaMalloc failed` allocating
2057.55 MiB → HTTP 500).

## Rulings

- **R8 — the Hermes managed runtime's yield verb is `POST <base_url-minus-/v1>/models/unload
  {"model":<id>}` with `Authorization: Bearer <api_key>`, both read live from
  `…/runtimes/llamacpp/server.json`.** No `hermes` CLI verb exists (`hermes local-runtime` is not a
  command; `hermes serve --stop` stops the whole backend, not a model). The HTTP endpoint is the
  yield mechanism, and it is the right one because it is **per-model and non-destructive** — the
  router stays up and reloads on demand.
- **R9 — coordination is now TWO-WAY.** Any design that says "the Hermes side has no external hook"
  is stale. `gpu-yield.sh` is the symmetric counterpart to `gpu-admit.sh`: it names the holder from
  the `/proc` parent chain up to each stack's supervisor pid and calls that stack's own release
  verb, stating the verb and the measured before/after in the verdict. `gpu-admit.sh` + `gpu-yield.sh`
  together are the two arms of the referee.
- **R10 — yield is a REQUEST, not a LOCK.** Observed live: a drain returned 200, the model unloaded,
  and within 10 s the Ocho pipeline (`ocho_sentiment_cycle.sh` → `ocho_reddit_sentiment.py`)
  re-acquired the card (`ocho-planner`, new child pid 456490, 5874 MiB). `gpu-yield.sh` correctly
  reported **REFUSED, exit 1**. So the remaining gap is **mutual exclusion (TOCTOU)**, not a missing
  verb: a broker must hold a **lease** across the window, or the two loaders must be serialised.
  Do not mistake "I can drain it" for "I can keep it drained".
- **R11 — llama-swap models with `ttl: 0` never self-release.** Verified live on `ocho-planner-4b`
  and `proposer`. An external drain is the only way to reclaim the card from them; a broker may not
  rely on TTL. (Extends the earlier suspicion — now measured.)
- **R12 — Candidate B's cost drops materially.** Its "expensive part — the Hermes side has no clean
  external hook" is void (R8). What remains for a real broker is: a lease format carrying the
  who-yields-to-whom policy (a live Ocho batch run should not be evicted for an idle Hermes load),
  a **pre-load** path on the Hermes side (the router can be evicted after the fact but cannot be
  asked *before* a spilled 35B load — Candidate A's honour-code or an upstream patch), and measured
  headroom for the two unowned residents. Eviction is now proven; admission is the open half.
- **R13 — no claim about a stack may be made from a remembered value.** The endpoint, router pid and
  free memory are re-read at every check (server.json, `systemctl show MainPID`, `nvidia-smi`).
  `gpu-yield.sh` refuses (exit 2) when the card or a holder's endpoint cannot be read, and never
  falls back. This is `gpu-admit.sh`'s rule, kept.

## Could not verify

Which actor re-acquired the card after the final drain (strong circumstantial: the running client
pid + `/running`); the `GET /unload` fallback was not exercised live (POST answered 200 every time);
`POST /api/models/unload/{model}` (single-model drain) untested; unloading a model that is mid-load
or mid-generation untested; llama-swap's global default TTL; why `hermes-local-runtime` restarted at
06:44/07:10 today; whether the two stacks run the same llama.cpp build (b11370 vs the local checkout).
All are listed in `RENOVATION_STEP1.md` §6.
