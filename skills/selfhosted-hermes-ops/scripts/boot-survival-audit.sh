#!/bin/sh
# Audit whether self-hosted Hermes surfaces will actually come back after a reboot.
#
# `systemctl is-enabled` proves only INTENT. An enabled unit whose ExecStart path
# no longer exists fails at boot with no obvious trace, and an enabled
# RemainAfterExit oneshot that never succeeded stays inactive(dead) instead of
# showing a failure you would notice. This checks all three layers.
#
# Usage: scripts/boot-survival-audit.sh [login-user]
# Exits non-zero if a reboot would not restore the stack.
set -u

USER_NAME="${1:-${USER:-}}"
rc=0

echo "== 1. linger: user units start at boot ONLY with this =="
if [ -z "$USER_NAME" ]; then
    echo "  ??   no login user given and \$USER is empty; cannot check linger"
    rc=1
elif linger=$(loginctl show-user "$USER_NAME" -p Linger --value 2>/dev/null) && [ -n "$linger" ]; then
    if [ "$linger" = "yes" ]; then
        echo "  OK   Linger=yes for $USER_NAME"
    else
        echo "  FAIL Linger=$linger -- units will not start until you log in"
        rc=1
    fi
else
    # A failed lookup is NOT a negative result. Cross-check the marker file before
    # reporting a problem, and name which name you asked about.
    echo "  ??   loginctl lookup failed for '$USER_NAME' (wrong username? shell \$USER?)"
    ls -1 /var/lib/systemd/linger/ 2>/dev/null | sed 's/^/        marker file: /' \
        || echo "        no /var/lib/systemd/linger readable"
    rc=1
fi

units=$(systemctl --user list-unit-files --state=enabled --no-legend --no-pager 2>/dev/null \
    | awk '{print $1}' | grep -E '^(hermes-|crw-)' || true)
[ -n "$units" ] || { echo "  (no enabled hermes/crw user units found)"; exit "$rc"; }

echo
echo "== 2. enabled units: ExecStart path must exist on disk =="
for u in $units; do
    path=$(systemctl --user show "$u" -p ExecStart --value 2>/dev/null \
        | grep -oE 'path=[^ ;}]+' | head -n1 | cut -d= -f2- | sed 's/^-//')
    if [ -z "$path" ]; then
        printf '  --   %-26s no ExecStart (oneshot/alias unit)\n' "$u"
    elif [ -e "$path" ]; then
        printf '  OK   %-26s %s\n' "$u" "$path"
    else
        printf '  DEAD %-26s %s\n' "$u" "$path"
        echo "        enabled unit will fail at boot; the script may have moved"
        rc=1
    fi
done

echo
echo "== 3. boot-time assertions must have reached active, not inactive(dead) =="
for u in $units; do
    type=$(systemctl --user show "$u" -p Type --value 2>/dev/null)
    rem=$(systemctl --user show "$u" -p RemainAfterExit --value 2>/dev/null)
    act=$(systemctl --user show "$u" -p ActiveState --value 2>/dev/null)
    [ "$type" = "oneshot" ] || continue
    [ "$rem" = "yes" ] || continue
    if [ "$act" = "inactive" ]; then
        printf '  FAIL %-26s enabled but %s -- ExecStart never succeeded\n' "$u" "$act"
        journalctl --user -u "$u" -n 4 --no-pager 2>/dev/null | sed 's/^/        /'
        rc=1
    else
        printf '  OK   %-26s %s\n' "$u" "$act"
    fi
done

echo
echo "== 4. current state (restarts>0 means a loop, not a blip) =="
for u in $units; do
    act=$(systemctl --user show "$u" -p ActiveState --value 2>/dev/null)
    n=$(systemctl --user show "$u" -p NRestarts --value 2>/dev/null)
    printf '  %-26s %-10s restarts=%s\n' "$u" "$act" "$n"
done

echo
echo "Boot-by-boot history of a unit:  journalctl --user -u <unit> | grep -A4 'Boot '"
[ "$rc" -eq 0 ] && echo "AUDIT PASS: stack should survive a reboot."
exit "$rc"