#!/usr/bin/env bash
# Test boot ORDERING without a reboot.
#
# Why this exists: `systemctl --user restart <unit>` cannot surface an ordering
# bug, because the dependency is already up when the restart happens. Starting a
# unit on its own proves it can start; it says nothing about whether it starts
# correctly at boot, where systemd activates everything at once.
#
# This stops the dependent and its dependency, then starts them in ONE command so
# the [Unit] ordering constraints actually govern which comes up first -- the same
# race default.target runs at boot.
#
# Usage: boot-order-test.sh <dependency-unit> <dependent-unit> [settle-seconds]
#
# Always prints what it did and leaves both units running, so it is safe to run
# against a live stack. Read the journal afterwards to see which attempt was the
# ordered one.

set -uo pipefail

DEP="${1:?usage: boot-order-test.sh <dependency-unit> <dependent-unit> [settle]}"
DEPNAME="${2:?missing dependent unit}"
SETTLE="${3:-75}"

say() { printf '%s\n' "$*"; }

active_dep="$(systemctl --user is-active "$DEP" 2>&1)"
say "dependency  $DEP: $active_dep"
say "dependent   $DEPNAME: $(systemctl --user is-active "$DEPNAME" 2>&1)"

if [ "$active_dep" != "active" ]; then
  say ""
  say "REFUSING: $DEP is not active, so this would prove nothing about ordering."
  say "Start it first, then re-run."
  exit 2
fi

say ""
say "Stopping both (the dependent first, so nothing is pulled up behind us)..."
systemctl --user stop "$DEPNAME" 2>&1 | sed 's/^/  /'
systemctl --user stop "$DEP"    2>&1 | sed 's/^/  /'
sleep 5

say "  $DEP now:    $(systemctl --user is-active "$DEP" 2>&1)"
say "  $DEPNAME now: $(systemctl --user is-active "$DEPNAME" 2>&1)"

# Reset any prior failure so the start is not short-circuited.
systemctl --user reset-failed "$DEPNAME" 2>&1 | sed 's/^/  /'

say ""
say "Starting BOTH in one command -- systemd applies After=/Requires= here."
systemctl --user start "$DEP" "$DEPNAME" 2>&1 | sed 's/^/  /'

printf 'Waiting %ss for the ordered start to settle' "$SETTLE"
for _ in $(seq 1 "$SETTLE"); do printf '.'; sleep 1; done
printf '\n\n'

STATE_DEP="$(systemctl --user is-active "$DEP" 2>&1)"
STATE_DEPNAME="$(systemctl --user is-active "$DEPNAME" 2>&1)"
say "RESULT"
say "  $DEP:    $STATE_DEP  (restarts=$(systemctl --user show "$DEP" -p NRestarts --value))"
say "  $DEPNAME: $STATE_DEPNAME  (restarts=$(systemctl --user show "$DEPNAME" -p NRestarts --value))"

say ""
say "Journal for this test (the ordered attempt is the LAST 'Starting'):"
journalctl --user -u "$DEPNAME" -n 12 --no-pager 2>&1 | grep -E 'Starting|PASS|FAIL|Failed' | tail -6 | sed 's/^/  /'

if [ "$STATE_DEPNAME" = "active" ]; then
  say ""
  say "PASS: the dependent came up under a real ordering race."
  say "Caveat: this is a simulation, not a reboot. It exercises After=/Requires=,"
  say "which is where ordering bugs live, but a cold boot also exercises linger,"
  say "network-online.target, and the graphical session."
  exit 0
fi

say ""
say "FAIL: the dependent did not survive an ordered start. Its Requires= is"
say "probably pointing at a unit that does not own what it asserts."
say "Find the real owner by walking the parent of the listening process:"
say "  PPID=\$(ps -o ppid= -p <listener-pid> | tr -d ' ')"
say "  tr '\\0' ' ' < /proc/\$PPID/cmdline | tail -c 80"
exit 1