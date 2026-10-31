#!/bin/sh
# Prove a model/projector pair can actually do vision, independent of any router.
#
# The managed llama.cpp runtime only injects --mmproj when a catalog entry declares
# the projector, so a pair that fails there may still be perfectly good. This
# launches llama-server directly with --mmproj on a scratch port, sends a real
# image, and asserts on the answer. That separates "the pair is broken" from
# "the router is not wired", which are very different problems.
#
# Usage: probe-vision.sh <MODEL.gguf> <PROJECTOR.gguf> [PORT]
#
# Exits 0 only when the model returns 200 AND describes the test image correctly.
set -u

MODEL="${1:-}"
PROJ="${2:-}"
PORT="${3:-18777}"
WORK="${VISION_PROBE_DIR:-$HOME/.hermes/cache/scratch}/vision-probe.$$"

[ -n "$MODEL" ] && [ -n "$PROJ" ] || {
    echo "usage: probe-vision.sh <MODEL.gguf> <PROJECTOR.gguf> [port]" >&2
    exit 2
}
for f in "$MODEL" "$PROJ"; do
    [ -r "$f" ] || { echo "probe-vision: unreadable: $f" >&2; exit 2; }
done

SERVER=""
for cand in \
    "${LLAMACPP_SERVER:-}" \
    "$HOME"/.hermes/tools/llamacpp-*/llama-server \
    "$HOME"/llama.cpp/build/bin/llama-server
do
    [ -n "$cand" ] && [ -x "$cand" ] && { SERVER="$cand"; break; }
done
[ -n "$SERVER" ] || { echo "probe-vision: no llama-server found" >&2; exit 3; }

mkdir -p "$WORK" || exit 3
SRV_PID=""
cleanup() {
    [ -n "$SRV_PID" ] && kill "$SRV_PID" 2>/dev/null
    sleep 2
    rm -rf "$WORK"
}
trap cleanup EXIT INT TERM

# VRAM before, so we can report whether the load fits and free it afterwards.
before=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -n1)
echo "probe: server=$SERVER"
echo "probe: port=$PORT  vram_before=${before:-?}MiB"

# --override-tensor mirrors how the runtime offloads FFN experts to CPU, which is
# what lets a large model + projector share a small-VRAM card. Pass extra flags
# through VISION_PROBE_ARGS when a model needs different tuning.
# shellcheck disable=SC2086
"$SERVER" --host 127.0.0.1 --port "$PORT" \
    -m "$MODEL" --mmproj "$PROJ" \
    --override-tensor 'blk\.\d+\.ffn_.*_exps\.weight=CPU' \
    -ngl 99 --ctx-size 8192 --flash-attn on --no-warmup \
    $VISION_PROBE_ARGS >"$WORK/server.log" 2>&1 &
SRV_PID=$!

# Readiness: poll the port rather than sleeping a guessed interval.
tries=0
while [ "$tries" -lt 120 ]; do
    if curl -fsS -o /dev/null --max-time 2 "http://127.0.0.1:$PORT/health" 2>/dev/null; then
        break
    fi
    if ! kill -0 "$SRV_PID" 2>/dev/null; then
        echo "probe-vision: server exited during load:" >&2
        grep -iE 'error|invalid|out of memory|failed' "$WORK/server.log" | tail -10 >&2
        exit 4
    fi
    tries=$((tries + 1))
    sleep 2
done
if [ "$tries" -ge 120 ]; then
    echo "probe-vision: server never became ready:" >&2
    tail -15 "$WORK/server.log" >&2
    exit 4
fi

after=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -n1)
echo "probe: ready, vram_after=${after:-?}MiB"

python3 - "$WORK" "$PORT" <<'PY'
import base64, json, struct, sys, urllib.error, urllib.request, zlib

work, port = sys.argv[1], sys.argv[2]

# A 64x64 four-quadrant PNG whose correct description is unambiguous, built from
# stdlib only (no PIL). Reading all four quadrants correctly means the projector
# actually encoded the image -- a text-only model cannot guess this layout.
W = H = 64
palette = [(220, 30, 30), (30, 200, 60), (40, 80, 230), (240, 240, 240)]
rows = []
for y in range(H):
    row = bytearray([0])
    for x in range(W):
        row += bytes(palette[(0 if y < H // 2 else 2) + (0 if x < W // 2 else 1)])
    rows.append(bytes(row))

def chunk(tag, data):
    return (struct.pack('>I', len(data)) + tag + data
            + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff))

png = (b'\x89PNG\r\n\x1a\n'
       + chunk(b'IHDR', struct.pack('>IIBBBBB', W, H, 8, 2, 0, 0, 0))
       + chunk(b'IDAT', zlib.compress(b''.join(rows), 9))
       + chunk(b'IEND', b''))

body = {
    "model": "probe",
    "messages": [{"role": "user", "content": [
        {"type": "text", "text": "Describe the four quadrants of this image and their colors. One sentence."},
        {"type": "image_url", "image_url": {"url": "data:image/png;base64," + base64.b64encode(png).decode()}}]}],
    "max_tokens": 200,
}

req = urllib.request.Request(
    f"http://127.0.0.1:{port}/v1/chat/completions",
    data=json.dumps(body).encode(),
    headers={"Content-Type": "application/json"},
)
try:
    d = json.load(urllib.request.urlopen(req, timeout=600))
except urllib.error.HTTPError as e:
    print("probe-vision: HTTP", e.code)
    print(e.read().decode()[:600])
    sys.exit(1)

text = (d.get("choices") or [{}])[0].get("message", {}).get("content") or ""
print("probe-vision: content:", repr(text))

low = text.lower()
expect = {"red": "top-left", "green": "top-right", "blue": "bottom-left", "white": "bottom-right"}
missing = [f"{c} ({p})" for c, p in expect.items() if c not in low]
if missing:
    print("probe-vision: FAIL - not described:", ", ".join(missing))
    print("probe-vision: (a text-only model guessing is the tell -- trust this, not the 200)")
    sys.exit(1)
print("probe-vision: PASS - all four quadrants read correctly")
PY
rc=$?

echo "probe: done (cleanup runs on exit; confirm VRAM returned to baseline)"
exit $rc
