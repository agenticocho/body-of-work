#!/bin/sh
# Print the OS-assigned port of the supervised llama.cpp runtime, reading the
# record `hermes serve` publishes. Never hardcode this port: it is reassigned on
# every restart, and a stale literal in a health gate is a crash loop.
#
# Usage:
#   eval "$(scripts/llamacpp-port.sh)"   # sets LLAMACPP_PORT and LLAMACPP_BASE
#   . /path/to/llamacpp-port.sh
#
# Emits LLAMACPP_PORT (e.g. 43021) and LLAMACPP_BASE (http://127.0.0.1:<port>/v1).
set -u

SRV="${HERMES_HOME:-$HOME/.hermes}/runtimes/llamacpp/server.json"

if [ ! -r "$SRV" ]; then
    echo "llamacpp-port: no runtime record at $SRV (is hermes serve running?)" >&2
    return 1 2>/dev/null || exit 1
fi

base=$(sed -n 's|.*"base_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*|\1|p' "$SRV" | head -n1)
port=$(printf '%s' "$base" | sed -n 's|.*:\([0-9][0-9]*\)/v1.*|\1|p')

if [ -z "$port" ]; then
    echo "llamacpp-port: could not parse a port from $SRV" >&2
    return 1 2>/dev/null || exit 1
fi

LLAMACPP_PORT="$port"
LLAMACPP_BASE="$base"
export LLAMACPP_PORT LLAMACPP_BASE

# Only print when executed, not when sourced, so `eval` stays clean.
if [ "${0##*/}" = "llamacpp-port.sh" ]; then
    echo "$port"
fi