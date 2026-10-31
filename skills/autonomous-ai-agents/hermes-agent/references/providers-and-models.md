# Providers & Model Aliases

Set via `hermes model` (picker) or `hermes setup`. 35+ provider profiles ship as
plugins under `plugins/model-providers/`; user plugins of the same name override.
Full docs: https://hermes-agent.nousresearch.com/docs/integrations/providers

### Providers

| Provider | Auth | Key env var(s) |
|----------|------|----------------|
| openrouter | API key | `OPENROUTER_API_KEY` |
| anthropic | API key | `ANTHROPIC_API_KEY` (also `CLAUDE_CODE_OAUTH_TOKEN`) |
| nous | OAuth device code | `hermes auth add nous` (or `NOUS_API_KEY`) |
| openai-codex | OAuth | `hermes auth add openai-codex` |
| qwen-oauth | OAuth | `hermes auth add qwen-oauth` |
| minimax-oauth | OAuth | `hermes auth add minimax-oauth` |
| copilot | Token | `COPILOT_GITHUB_TOKEN` / `GH_TOKEN` (Copilot device flow — `gh auth login` tokens do NOT work) |
| copilot-acp | External CLI | Copilot CLI on PATH or `COPILOT_CLI_PATH` |
| gemini | API key | `GOOGLE_API_KEY` or `GEMINI_API_KEY` |
| xai | API key | `XAI_API_KEY` (SuperGrok OAuth also supported) |
| deepseek | API key | `DEEPSEEK_API_KEY` |
| zai (GLM) | API key | `GLM_API_KEY` / `ZAI_API_KEY` |
| minimax / minimax-cn | API key | `MINIMAX_API_KEY` / `MINIMAX_CN_API_KEY` |
| kimi-coding / -cn | API key | `KIMI_API_KEY` / `KIMI_CN_API_KEY` |
| alibaba (+coding-plan) | API key | `DASHSCOPE_API_KEY` / `ALIBABA_CODING_PLAN_API_KEY` |
| xiaomi | API key | `XIAOMI_API_KEY` |
| huggingface | Token | `HF_TOKEN` |
| fireworks / novita / nvidia / deepinfra / gmi / arcee / stepfun / upstage / kilocode / ai-gateway / opencode-zen / opencode-go / ollama-cloud | API key | `<NAME>_API_KEY` |
| bedrock / vertex / azure-foundry | Cloud SDK / key | AWS SDK creds / Vertex ADC / `AZURE_FOUNDRY_API_KEY` |
| custom | Config | `model.base_url` + `model.api_key` in config.yaml |

Multiple credentials per provider pool and rotate automatically (`hermes auth`).
Fallback chain when the primary fails: `hermes fallback add|remove|list`.

### User-defined model aliases

Work with `/model <name>` in CLI and every gateway platform. Resolved by
`hermes_cli/model_switch.py::resolve_alias()`; user aliases are checked BEFORE
the built-in table, so a user `sonnet`/`grok` shadows the built-in.

```yaml
# Full form
model_aliases:
  fav:
    model: claude-sonnet-4.6
    provider: anthropic
  local-qwen:
    model: qwen3.5:397b
    provider: custom
    base_url: "https://ollama.com/v1"
  theta:
    model: theta-1
    provider: custom
    base_url: "https://theta.example.com/v1"
    key_env: THETA_API_KEY        # or: api_key: "${THETA_API_KEY}"

# Short form ("provider/model"), also via CLI:
#   hermes config set model.aliases.fav openrouter/anthropic/claude-sonnet-4.6
model:
  aliases:
    fav: openrouter/anthropic/claude-sonnet-4.6
```

`/model fav` — session-scoped; add `--global` to persist as default.

An alias with its own `base_url` authenticates with its own credential
(`api_key`, which also accepts a `"${VAR}"` reference, or `key_env`). With
neither set the key is resolved from the alias HOST, never carried over from
the provider that was active before the switch.

Built-in aliases (catalog-resolved against the active provider): `sonnet`,
`opus`, `haiku`, `claude`, `gpt5`, `gpt`, `codex`, `o3`, `o4`, `gemini`,
`deepseek`, `grok`, `llama`, `qwen`, `minimax`, `nemotron`, `kimi`, `glm`,
`step`, `mimo`, `trinity`.

## Moving a model + provider across MANY profiles

`hermes model` is **interactive only** — a scripted migration goes through
`hermes config set`. Target a profile with the global `-p` flag (there is no `--profile` on `config`):

```bash
hermes -p <profile> config set model.default <model>
hermes -p <profile> config set model.provider <provider>   # clears the old route's base_url/api_mode
hermes -p <profile> config set model.base_url <url>        # only if the provider needs an explicit one
hermes -p <profile> config set agent.reasoning_effort medium   # none|minimal|low|medium|high|xhigh
```

- **`agent.reasoning_overrides` has NO `config set` support** — it is a dict, so it must be edited in YAML.
- **Setting `model.provider` clears the previous route's `model.base_url` and `model.api_mode`** with a
  notice naming what it dropped — but when a *local* provider's URL was set it instead **warns that the
  stale URL still applies to the new provider**. Overwrite it, and check separately that no stale
  `model.api_mode` survives (`hermes -p <p> config get model.api_mode`).
- **Read an existing working profile as the template, and treat it as the specification** — the exact
  `model.default` / `provider` / `base_url` triple is easier to copy than to infer. **Beware that bare
  `hermes config get` resolves the ACTIVE profile, not the `default` one**, so read the default profile's
  `~/.hermes/config.yaml` directly rather than assuming `config get` without `-p` shows it.

### Credentials are per-profile, and there is NO fallback to the root `.env`

The `default` profile's `.env` does **not** serve the other profiles. In a multiplex gateway the profile
environments are deliberately isolated — one profile's keys are never unioned into the shared process env,
so its credentials cannot leak into a sibling's turns or subprocesses. A provider change across N profiles
needs the key in **each** profile's own `~/.hermes/profiles/<p>/.env`. Budget for that before promising a
migration: the config half is trivial and the credential half is the actual work.

**Verify capability with a live call, not by reading the config.** One probe settles it and changes nothing
on disk:

```bash
hermes -p <profile> --model <m> --provider <pv> chat -q "reply with exactly: PROBE_OK"
# "No usable credentials found for provider '<pv>'. Set <KEY>."  → the key is absent for that profile
```

A `config set` that reports success proves *intent*, not that the credential resolves. After the change,
re-probe every profile end-to-end — a profile that answers is the only evidence the migration landed.

### Handle the key without exposing it

- **Never pass a credential value as a command argument.** It lands in `ps` for any local user and in the
  session transcript. Note the trap: a bare `UPPER_SNAKE` key is exactly the one form `hermes config set`
  routes to `.env` — which is the reason **not** to use it here, since it takes the value as an argument.
- **Copy the value programmatically** from the source `.env` to each target `.env`: create the file `0600`,
  write to a temp file and `os.replace` it into place, then **verify by re-reading and comparing** rather
  than printing. Report the names and lengths, never the value.
- **State the blast radius when one key serves many agents:** rotating or revoking it revokes all of them at
  once, which is a different posture from per-agent keys — and a standing preference for narrower per-agent
  keys is worth re-confirming before you consolidate.

### After the change

- **The gateway's multiplex reconciler detects profile `config.yaml`/`.env` edits on its own** and re-scans
  the profile; you do not need to restart it.
- **The change takes effect on each profile's NEXT session** — a running session keeps the model it
  started with, so say that explicitly rather than implying an immediate cut-over.
- **`hermes -p <p> config check` on every profile** before declaring the migration done.

### Provider quirk: structured-output rejection on an auxiliary call

A provider can accept a model for chat and still reject the **auxiliary** calls. Observed with an
opencode-go deepseek model: the title-generation call sends `response_format` (json_schema) and gets
`400 — "This response_format type is unavailable now"`. Hermes handles it by retrying without the field and
degrading schema enforcement to prompt compliance, so the symptom is an intermittent
`WARNING ... Title generation failed: 400` and a session title falling back to the first user message.
**Cosmetic, and not caused by your migration** — check whether the already-working profile shows the same
behaviour before attributing it to the change.
