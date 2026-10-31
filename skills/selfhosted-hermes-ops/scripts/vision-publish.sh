#!/usr/bin/env bash
# Publish a second llama.cpp endpoint's live port into the Hermes aux config.
#
# The endpoint binds an OS-assigned port (--port 0), so the port changes every
# restart and must never be hardcoded in config.yaml. Run as ExecStartPost after
# the server is loaded: waits for the port to appear in the server log, health
# checks it, then writes auxiliary.<task>.base_url in place.
#
# Requires the unit to use StandardOutput=truncate: so the log holds only the
# current boot — otherwise this re-publishes the previous run's dead port.
#
# Usage: vision-publish.sh <task> <logfile> <portfile> <timeout-seconds> [config]
set -euo pipefail

TASK="${1:?usage: vision-publish.sh <task> <logfile> <portfile> <timeout> [config]}"
LOGFILE="${2:?missing logfile}"
PORTFILE="${3:?missing portfile}"
TIMEOUT="${4:-120}"
CFG="${5:-$HOME/.hermes/config.yaml}"

[ -r "$CFG" ] || { echo "$TASK: no config at $CFG" >&2; exit 1; }

deadline=$((SECONDS + TIMEOUT))
PORT=""
while [ "$SECONDS" -lt "$deadline" ]; do
  if [ -r "$LOGFILE" ]; then
    PORT="$(sed -n 's|.*listening on http://127\.0\.0\.1:\([0-9]\{1,\}\).*|\1|p' "$LOGFILE" | tail -n1)"
    [ -n "$PORT" ] && break
  fi
  sleep 1
done

if [ -z "$PORT" ]; then
  echo "$TASK: no port in $LOGFILE after ${TIMEOUT}s" >&2
  exit 1
fi

echo "$PORT" > "$PORTFILE"

python3 - "$CFG" "$TASK" "$PORT" <<'PY'
import re
import sys

cfg, task, port = sys.argv[1], sys.argv[2], sys.argv[3]
url = "http://127.0.0.1:%s/v1" % port
key = re.compile(r"^  %s:" % re.escape(task))
lines = open(cfg).read().split("\n")

out, in_task, changed = [], False, False
for line in lines:
    if re.match(r"^  \S", line):          # a sibling task key ends this block
        in_task = False
    if key.match(line):
        in_task = True
    if in_task and re.match(r"^    base_url:", line):
        out.append("    base_url: %s" % url)
        changed = True
        continue
    out.append(line)

if not changed:
    # No base_url key yet: insert one immediately after the task key.
    out, in_task = [], False
    for line in lines:
        if re.match(r"^  \S", line):
            in_task = False
        if key.match(line):
            in_task = True
            out.append(line)
            out.append("    base_url: %s" % url)
            continue
        out.append(line)

open(cfg, "w").write("\n".join(out))
print("auxiliary.%s.base_url = %s" % (task, url))
PY

echo "$TASK: published port $PORT"