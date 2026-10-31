# Running a second llama.cpp endpoint on a dynamic port

Use this when a model or projector **cannot** go through the managed router — for
example a vision model whose projector has no `catalog.json` entry, so the router
has nowhere to attach `--mmproj`. The managed runtime's rules still apply: the
port is OS-assigned, nothing may hardcode it, and the port must be republished on
every boot.

## Shape

```
hermes-vision.service          llama-server --port 0 --mmproj <projector>
  └─ ExecStartPost
       vision-publish.sh       reads the live port from the log,
                               health-checks it, writes auxiliary.vision.base_url
```

## Unit skeleton

```ini
[Unit]
Description=Hermes <model> local vision endpoint
After=network.target hermes-serve.service

[Service]
Type=simple
# truncate: (NOT append:) — a stale "listening on ..." line from the previous
# boot makes the publisher re-publish a dead port and crash-loop the unit.
StandardOutput=truncate:%h/.hermes/runtimes/<name>/<name>.log
StandardError=truncate:%h/.hermes/runtimes/<name>/<name>.log
ExecStart=<llama-server> \
  --model <model.gguf> \
  --mmproj <projector.gguf> \
  --alias <alias> \
  --host 127.0.0.1 \
  --port 0 \
  --ctx-size 4096 \
  --parallel 1 \
  --n-gpu-layers 0 \
  --no-mmproj-offload \
  --threads <cores/2> \
  --image-max-tokens 512 \
  --api-key-file %h/.hermes/runtimes/<name>/.api_key \
  --cors-origins localhost \
  --sleep-idle-seconds 60 \
  --jinja --no-ui
Restart=on-failure
RestartSec=5
KillSignal=SIGINT
TimeoutStopSec=30
Nice=5
# Prefix with `-`: publishing is secondary to the server being up, so a publish
# failure must never kill a working endpoint.
ExecStartPost=-<publish-script> <args>

[Install]
WantedBy=default.target
```

## Aux config

```bash
hermes config set auxiliary.<task>.provider llamacpp
hermes config set auxiliary.<task>.model <alias>
hermes config set --force auxiliary.<task>.api_key "$(cat <keyfile>)"
```

`api_key`, **not** `api_key_file` — the CLI rejects the latter without `--force`,
and an explicit `base_url` (written by the publisher) makes the runtime skip the
record that would otherwise supply the key.

## Verify the rewire actually works

The only meaningful test is a port change:

```bash
systemctl --user restart <unit>; sleep 60
cat %h/.hermes/runtimes/<name>/port          # new port
grep -A6 '^  <task>:' %h/.hermes/config.yaml | grep base_url
systemctl --user show <unit> -p NRestarts    # must be 0
```

Then send real inference (`vision_analyze` for vision). A restart loop counter
above 0 means the publisher read a stale log line — check `truncate:`.

## Footprint

`--sleep-idle-seconds N` keeps the process up but unloads the model when idle, so
the endpoint costs ~220 MiB VRAM and ~380 MiB RSS at rest and reloads in ~280ms on
the next request. That beats on-demand activation, which pays a full cold load and
buys nothing over the reload.