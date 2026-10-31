# 2026-10-13 · Agent main-model tenancy: all profiles to OpenCode Go `deepseek-v4.1-flash`

**Operator directive (Mike, 2026-10-13):** "update all agent main models to OpenCode Go deepseek-v4.1-flash (med reasoning)." Confirmed scope: **all nine** agent profiles, `harness-test` included (moved off its local `llamacpp` model).

## What was changed

Uniform across `tiel, ocho, ocho2, birdy, llama, sokoban, missile-command, zork, harness-test`:

| key | value |
|---|---|
| `model.default` | `deepseek-v4.1-flash` |
| `model.provider` | `opencode-go` |
| `model.base_url` | `https://opencode.ai/zen/go/v1` |
| `agent.reasoning_effort` | `medium` |

The `default` profile was already on exactly this configuration — it was the template, not a target. `llama` moved `none → medium` and `harness-test` left `llamacpp` (local `Tiel-Inspired-Coder-9B-UD-Q4_K_M`, `base_url http://127.0.0.1:8080/v1`), whose stale route `hermes config set` cleared automatically.

## R1 — a `config set` that reports success is not a credential that resolves

Setting the model is the easy half; the migration was blocked on credentials, and only a live call proved it. All nine profiles lacked `OPENCODE_GO_API_KEY`. Hermes isolates credentials per profile **by design** (the multiplex gateway refuses to union profile `.env` keys into `os.environ`, so profile A's key cannot leak into profile B's turns or subprocesses) — there is **no fallback to the root `~/.hermes/.env`** for a profile home.

The decisive check is a live probe, not config inspection:

```
hermes -p llama --model deepseek-v4.1-flash --provider opencode-go chat -q "reply with exactly: PROBE_OK"
  → "No usable credentials found for provider 'opencode-go'. Set OPENCODE_GO_API_KEY."
```

Rule: **when a change spans a credential boundary, the verification is an end-to-end call. A config write proves intent, not capability.**

## R2 — one shared key across all agents, operator-authorized (supersedes the earlier per-agent-key preference)

Mike chose, from three options, to **copy the single `OPENCODE_GO_API_KEY` from the `default` profile's `.env` into all nine profiles — all agents share the one key.** This qualifies the earlier stated preference that agents hold narrower, distinct keys ("Birdy should have a narrower one of its own"). Recorded here so a future session does **not** re-litigate an operator decision already made, and so the blast radius is explicit: **one key, nine agents — revoking or rotating it revokes all nine at once.**

Handled without exposing the value: the key was copied programmatically, verified by re-read, written `0600`, never echoed to the transcript and never placed on a command line (a command-line value lands in `ps` and in the session log). A bare `UPPER_SNAKE` key is the one `hermes config set` route that writes to `.env` — deliberately not used here, since it would require the value as an argument.

## R3 — the residual defect is the provider's, and it is named, not fixed

`opencode-go` + `deepseek-v4.1-flash` rejects the structured-output format on the auxiliary title call:

```
Error code: 400 - {'error': {... 'message': 'Upstream request failed: [invalid_request_error]
This response_format type is unavailable now'}}
```

Hermes handles it: it retries without the field and degrades schema enforcement to prompt compliance. Intermittent — the warning prints only when the retry also fails, and the session title then falls back to the first user message. **Inherent to the provider, not caused by this migration** (the `default` profile shows the same behaviour). Cosmetic. Recorded so it is not later mistaken for fallout from this change.

## R4 (correction, same day) — the pinned model column is a stale LABEL, not the live route

**I got this wrong first and am recording the correction rather than the tidy version.** I read the `model` column of the long-lived Bot Chat sessions (stepfun / deepseek) and the `Model restored from session: <old model>` banner, concluded the agents were still running the pre-migration model, and offered to renew every agent session to make the migration take effect. **That was wrong, and the offer was withdrawn.**

Read at source, `tui_gateway/server.py:1646-1673`:

- `_row_follows_profile()` is true when `model_config.follow_profile_config` is set **or** the row's title is `"Bot Chat"` (the legacy fallback).
- For such a row, `_stored_session_runtime_overrides()` returns `{}` — **no restoration at all.** The docstring says why outright: Bot-Mode sessions "normally rebuild from the member profile's CURRENT config (a stale provider pin left room bots 'out of Nous credits' after a profile switch)."

Confirmed on every Bot Chat row across all ten profiles (`follow_profile_config: true`; `ocho2` absent the marker but following by the title fallback). Decisive evidence is the **billed route**, `session_model_usage`, not the session label:

```
tiel  Bot Chat  model(col)=deepseek-flash          BILLED=deepseek-v4.1-flash @ opencode-go
birdy Bot Chat  model(col)=stepfun/step-5-preview  BILLED=deepseek-v4.1-flash @ opencode-go
ocho  Bot Chat  model(col)=stepfun/step-5-preview  BILLED=deepseek-v4.1-flash @ opencode-go
```

All three billing `opencode-go` after the 15:34 migration, while their label columns still read the old model. **The migration was already live in the Bot Chats from the moment it was written.** Corrected rule, in the same family as R1 above:

> **A stale display label is not the live route. When they disagree, the billed/completed route decides — read `session_model_usage`, never the session's pinned `model` column, and never a resume banner.**

**The runtime says it in its own words.** The strongest artifact is not a count but a repair statement, logged by the runtime at the moment the session resumed (`profiles/birdy/logs/agent.log`):

```
2026-10-13 17:02:26,987 INFO [20261007_192947_371918] agent.conversation_loop:
  Stored system prompt for session 20261007_192947_371918 has stale runtime identity;
  rebuilding for model=deepseek-v4.1-flash provider=opencode-go.
```

The runtime **declared the stored identity stale and rebuilt it toward the profile** — it did not restore the pin, it healed away from it. Corroborating counts for that session the same day: `deepseek-v4.1-flash @ opencode-go` = 52 calls; `stepfun @ nous` = 19 calls, first 2026-10-12 10:05, last 2026-10-12 10:55 — **not billed once since the migration.** (Two `provider=nous` lines appear in the day's log; both are `OpenAI client created` at 06:55 and 12:43, *before* the 15:34 migration, and neither is an `API call #` line. A client construction is not a request.)

**Latent edge, recorded because it is what would DEFEAT the follow-profile behaviour:** the suppression returns `{}` only when `_row_follows_profile(row) and not composer_profile_matches`. Every Bot Chat here carries a `composer_override_profile` holding the *old* model, which does not match the current config target, so the branch fires and they follow the profile. If a composer pick were ever set to **exactly** the current profile model, `composer_profile_matches` turns true, suppression stops, and the stored stale route can resurface. Do not "help" by pinning a bot to the model it already runs.

**Verified unexploited, 2026-10-13** (`@birdy` re-derived the branch; confirmed independently here): across all nine profiles the `composer_override_profile` either is absent (follows by the title fallback) or holds a model differing from the current target — `tiel` stepfun/nous, `birdy` Ornith/llamacpp, `ocho` stealth/missingno — so `composer_profile_matches` is false everywhere and the `{}` suppression holds on every row. The edge is a **live trap for a future pin, not a present defect.**

## R5 — the pattern behind all three of today's corrections: a claim true when first read survives past the artifact

Three corrections happened in one day, and they are one shape. **A statement was true when it was written, and the artifact moved underneath it while the statement kept being repeated.**

1. *"gpu-lease.sh mentions the Arcade zero times"* — true of the pre-Oct-12 script; the precedence clause landed at 12:12 and the sentence kept being carried.
2. *"the agents are still on stepfun"* — true of the session *label*; the billed route had already moved to opencode-go.
3. *"the pinned column is a live route"* — the mechanism I inferred from a display field instead of reading the runner.

> **For anything with a live runner behind it, the truth is the log line and the usage table — the session table's own columns are labels, and a label is a claim about the past.** Re-read before repeating; a fact that was verified once does not stay verified across another process's writes.

Credit: `@birdy` supplied the counter-evidence for 1 and 2 (the billed route, the source read, and here the runtime's own repair line) against my claims. Verification in this ruling was independent — from disk, source, and log — not taken from his message.

## R6 — an ordering constraint is a claim about a COUPLING; verify the two things share a supervisor

I told Mike not to run the update while Ocho's delivery was in flight, "since a gateway restart could kill it." **That is false, and it was checkable in one command.** Measured cgroups:

```
delivery pids 81328 / 86919 / 95019  -> .../app.slice/app-org.chromium.Chromium-77831.scope
hermes-gateway.service  MainPID 2449 -> .../app.slice/hermes-gateway.service
```

Different cgroups, different supervisors. Those deliveries are children of the **Desktop app** (pid 77831), whose parent chain runs the Desktop's own `serve --host 127.0.0.1 --port 0` backend — no gateway anywhere in the path. Restarting `hermes-gateway.service` cannot touch them. The updater agrees by construction: `update_inventory.py:104`, `CLIENT_OWNED_SERVE_SUPERVISORS = frozenset({"desktop", "desktop-ssh"})` — *"The updater never restarts either; stopping one out from under its client only makes the client respawn it."*

> **Before sequencing work around an expected disruption, verify that the things you are protecting actually share the supervisor being restarted.** "X could kill Y" is a claim about *containment*: check the cgroup or the unit. Do not infer a coupling from both parties being "part of the same product" — the gateway, the Desktop, its serve backends, and each agent's CLI are supervised separately, and that separation is the whole point of the client-owned-supervisor rule.

**Residual, left honest rather than resolved:** the update swaps the checkout while a live python process is executing `bot_mode_dm.py` from it. Already-imported modules live in memory, so a mid-run swap is *usually* inert — but that was not measured, and it was not called safe on a guess. Waiting for the deliveries to land is therefore a **zero-risk preference, not a mechanism.**

Credit: `@birdy` produced the cgroup measurement and the source citation against my sequencing claim; I re-verified both independently (cgroup read + source read) before filing this.

## Verified state

- All nine profiles answer end-to-end through `opencode-go` (live `chat -q` probes, 3–4 s each; `harness-test` visibly emitting its medium-reasoning trace).
- `hermes -p <profile> config check` clean on all nine; no stale `model.api_mode` anywhere.
- The running gateway's multiplex reconciler detected the changes on its own: `[MULTIPLEX] Re-scanned profile '<p>' after config/.env change`.
- Change takes effect on each agent's **next session**; running sessions keep their current model until restart.
