#!/bin/sh
# Verify every entry in MANIFEST.sha256. Counting entries is not verification.
set -e
cd "$(dirname "$0")"
if grep -q 'MANIFEST.sha256' MANIFEST.sha256; then
  echo "FAIL: the manifest lists itself; a single-pass self-entry is stale by construction" >&2
  exit 1
fi
total=$(wc -l < MANIFEST.sha256)
if sha256sum -c MANIFEST.sha256 --quiet >/dev/null 2>&1; then
  echo "OK: ${total} entries verified, manifest does not list itself"
else
  echo "FAIL: at least one entry does not match:" >&2
  sha256sum -c MANIFEST.sha256 2>/dev/null | grep -v ': OK$' >&2
  exit 1
fi
