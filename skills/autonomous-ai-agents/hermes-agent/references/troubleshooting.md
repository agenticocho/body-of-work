# Troubleshooting

### Voice not working
1. Check `stt.enabled: true` in config.yaml
2. Verify provider: `python -c "import pm; pm.sync_venv(['stt-whisper'], explicit=True)"` or set API key
3. In gateway: `/restart`. In CLI: exit and relaunch.

### Tool not available
1. `hermes tools` — check if toolset is enabled for your platform
2. Some tools need env vars (check `.env`)
3. `/reset` after enabling tools

### Model/provider issues
1. `hermes doctor` — check config and dependencies
2. `hermes auth` — re-authenticate OAuth providers (or `hermes auth add <provider>`)
3. Check `.env` has the right API key
4. **Copilot 403**: `gh auth login` tokens do NOT work for Copilot API. You must use the Copilot-specific OAuth device code flow via `hermes model` → GitHub Copilot.

### A profile that cannot START — and reports success to every sender anyway

A profile whose `config.yaml` names a provider it holds no credential for fails at session start, and
**every sender sees a normal `delivery_id` and `status: queued` regardless.** Check the SHAPE, never the
values:

```bash
grep -oE '^[A-Z_]+=' ~/.hermes/profiles/<p>/.env      # key NAMES only, never the values
[ -f ~/.hermes/profiles/<p>/auth.json ] && echo has-auth
```

An empty `.env` is evidence for two opposite conclusions at once — *this profile fails closed* and *this
profile cannot reach the provider its config declares* — so read it for both rather than for the one you
were looking for. A local-model profile needs no external provider key at all; a profile pointed at a
remote provider needs one. **`hermes profile list` showing a row, and `hermes-gateway.service` being
active, are not evidence that an agent can run** — the test is a session that actually starts.

### A profile HANGS on the first turn (local model endpoints)

A hang is nearly always an endpoint that no longer exists, not a model that is thinking.

1. **Run it and read what comes back:** `timeout 100 hermes -p <p> chat -q 'reply with one word: pong'`.
   A hang ending in `KeyboardInterrupt` is an endpoint problem; a real failure names the provider. Note
   that a piped `echo "exit=$?"` reads the last stage of the pipeline — capture the status before any pipe.
2. **Test the endpoint DIRECTLY, with no profile in the path:** `curl -s http://127.0.0.1:<port>/v1/models`,
   then a one-shot `/v1/chat/completions` with `max_tokens: 8`. **Do not isolate config-from-software by
   comparing one profile against another** — a profile whose `model.provider` is a remote API answers in
   seconds and proves nothing about the local path, so the comparison is two instruments and not one
   control. Test the thing itself.
3. **Read the endpoint the profile names,** and look for a SECOND one:
   `hermes -p <p> config get model.base_url` / `model.provider`, plus
   `grep -n 'base_url' ~/.hermes/profiles/<p>/config.yaml` — a `model_aliases` block can carry its own
   endpoint. **A high, arbitrary port (3xxxx / 5xxxx) in a config is usually an EPHEMERAL port captured
   from a transient server that has since exited** — true for one instant, never re-derived. `ss -ltn`
   shows what is actually bound; point the profile at that, deriving the value from a profile that works
   rather than inventing one.
4. **Check what the ALIAS resolves to.** An alias is a name, not a model. A request naming a `helper` alias
   returned `{"inventory": [` and the response's own `model` field named a 350M *extraction* model — a
   schema-filling model answering a prompt with a form. Read the resolved model in the RESPONSE, not the
   alias in the request.

Change an endpoint with `hermes -p <p> config set model.base_url <url>` / `model.provider` / `model.name` —
**never by hand-editing `config.yaml`** (see Hard Invariants in SKILL.md).

### Changes not taking effect
- **Tools/skills:** `/reset` starts a new session with updated toolset
- **Config changes:** In gateway: `/restart`. In CLI: exit and relaunch.
- **Code changes:** Restart the CLI or gateway process

### web_extract shows a stale page (result caching)
`web_search`/`web_extract` cache results for 20 minutes (PR #94618) — a
repeat fetch of the same URL within the TTL is served from cache, which
can look like "my website changes aren't showing up."

Automatic carveouts (always fetched live, never cached):
- localhost / 127.0.0.1 / `*.local` / `*.localhost` / single-label LAN
  hostnames / private + link-local IP ranges (dev servers, hot-reload
  builds, chat-GUI artifact previews)
- URLs matched by `security.website_blocklist`
- failed responses and keyless-rescue-served responses

Developing a site tested over the PUBLIC internet (Vercel/Netlify
preview, ngrok/cloudflared tunnel, staging domain)? Public DNS isn't
auto-carved-out — list the host in config.yaml:

```yaml
web:
  cache_exempt_hosts:      # always fetched live; effective immediately
    - mysite.vercel.app
    - "*.ngrok-free.app"
    - mysite.dev           # suffix match: also covers preview.mysite.dev
```

Blunt instruments: `web.cache_ttl_minutes: 1` (min) or
`web.cache_enabled: false` disables both caches entirely.

### Skills not showing
1. `hermes skills list` — verify installed
2. `hermes skills config` — check platform enablement
3. Load explicitly: `hermes -s name` (or the skill's own `/<name>` slash command)

### Gateway issues
Check logs first:
```bash
grep -i "failed to send\|error" ~/.hermes/logs/gateway.log | tail -20
```

Common gateway problems:
- **Gateway dies on SSH logout**: Enable linger: `sudo loginctl enable-linger $USER`
- **Gateway dies on WSL2 close**: WSL2 requires `systemd=true` in `/etc/wsl.conf` for systemd services to work. Without it, gateway falls back to `nohup` (dies when session closes).
- **Gateway crash loop**: Reset the failed state: `systemctl --user reset-failed hermes-gateway`

### Platform-specific issues
- **Discord bot silent**: Must enable **Message Content Intent** in Bot → Privileged Gateway Intents.
- **Slack bot only works in DMs**: Must subscribe to `message.channels` event. Without it, the bot ignores public channels.
- **Windows-specific issues** (`Alt+Enter` newline, WinError 10106, UTF-8 BOM config, line endings): see `references/windows-quirks.md`.

### Auxiliary models not working
If `auxiliary` tasks (vision, compression, session_search) fail silently, the `auto` provider can't find a backend. Either set `OPENROUTER_API_KEY` or `GOOGLE_API_KEY`, or explicitly configure each auxiliary task's provider:
```bash
hermes config set auxiliary.vision.provider <your_provider>
hermes config set auxiliary.vision.model <model_name>
```

### "Reset permissions" / auto-approving everything
See `references/security-privacy.md` — wipe the "Always allow" stores, don't touch yolo mode.

