#!/bin/sh
# Prove a local model actually loads and generates -- /health and a listed model
# prove neither. Sends real inference through the supervised llama.cpp runtime.
#
# Usage: probe-local-model.sh <MODEL_ID> ["prompt"]
#
# Exits 0 on a completed completion, non-zero otherwise. Prints the model id and
# the response text. A 400 here usually means the request was malformed (this
# runtime REQUIRES an explicit "model" field even with autoload on), not that the
# model is unusable -- so the error body is printed too.
set -u

MODEL="${1:-}"
PROMPT="${2:-Reply with exactly: OK}"

if [ -z "$MODEL" ]; then
    echo "usage: probe-local-model.sh <MODEL_ID> [prompt]" >&2
    exit 2
fi

SRV="${HERMES_HOME:-$HOME/.hermes}/runtimes/llamacpp/server.json"
KEYFILE="${HERMES_HOME:-$HOME/.hermes}/runtimes/llamacpp/.api_key"

base=$(sed -n 's|.*"base_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*|\1|p' "$SRV" 2>/dev/null | head -n1)
port=$(printf '%s' "$base" | sed -n 's|.*:\([0-9][0-9]*\)/v1.*|\1|p')

if [ -z "$port" ]; then
    echo "probe: no llama.cpp port in $SRV" >&2
    exit 3
fi

key=$(cat "$KEYFILE" 2>/dev/null || true)
[ -n "$key" ] || echo "probe: warning - no api key at $KEYFILE" >&2

out=$(mktemp)
code=$(curl -sS --max-time 600 -o "$out" -w '%{http_code}' \
    -H "Authorization: Bearer $key" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}],\"max_tokens\":64}" \
    "$base/chat/completions")

echo "http=$code  model=$MODEL  port=$port"
if [ "$code" != "200" ]; then
    echo "--- error body ---"
    cat "$out"
    rm -f "$out"
    exit 1
fi

python3 - "$out" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
c = d["choices"][0]["message"]
content = c.get("content") or ""
reasoning = c.get("reasoning_content") or ""
print("content:", repr(content))
if reasoning:
    print("reasoning:", repr(reasoning[:200]))
if not content:
    print("note: empty content with reasoning present - the model spent its")
    print("      token budget reasoning; raise max_tokens to get an answer.")
PY
rm -f "$out"