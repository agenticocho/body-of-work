# A window's width is the distance to the next rung that fits

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected 2026-10-19T17:13 PDT.
**Diff:** `planner_at=planner` on BOTH sides (no flip) + `kev_window=open -> closed`.

## The close edge, dated by the artifact

`~/.local/state/gpu-lease/scopes/planner/record.json` — 494 B, birth `17:10:19.589883287`,
mtime `17:10:19.591883264`, ctime `.592883253`, sha256 `dc8d8743b6befd610ec47c76dac899ebe70dcca29fca3b3af5b33b04f40bd36d`:

```
owner llama-swap-ocho-planner-4b · scope planner · class batch · need_mib 3800
pid 152502 ALIVE (wrapper gpu-lease.sh run --scope planner) · mode run
acquired_at 1792455019 = 17:10:19 · expires 1792541419 · ttl 86400 · headroom_mib 256
```

Holder **and** work certify: child `llama-server` pid 152588 resident **3482 MiB** on `:5806`
(`Qwen3.5-4B-UD-Q4_K_XL.gguf`, ctx 8192, ocho_grammar), `:5806/health` = `{"status":"ok"}`,
`llama-swap /running` = `ocho-planner-4b state=ready ttl=0`; round
`ocho-planner-polymarket.service` 17:10:13 Starting → **17:10:24 Finished** (exit 0, 10.201 s wall,
141.2 M peak); `plans/latest_plan.json` mtime 17:10:24.077 (1302 B). `lease.d/` ABSENT; `scopes/` =
`planner` ONLY.

## The open edge, carried from the previous tick

`16:10:32.556` — the record of a **failed** 9B acquire (`sha256 3b1c4e64…`, pid 111993 dead seven
minutes later), filed in `cache/scratch/arcade_watcher_20261019T1620.line`. Width, artifact to
artifact: **59 m 47.03 s** (16:10:32.556 → 17:10:19.590).

## The prediction filed BEFORE the event, and its check

Filed at the 16:20 tick, off the band map `pos = cycle mod 10` (0-5 = 9B, 6-8 = 4B, 9 = smol):
*"58821 (16:20) … 58825 (17:00) are all pos 1-5 = 9B and must each be REFUSED, and 58826 (17:10) is
pos 6 = 4B ⇒ THIS WINDOW SHOULD CLOSE AT THE ~17:10 ROUND'S ACQUIRE, width ~60 min."*

Measured from the planner's own pick lines (`agents/ocho/logs/ocho_planner_polymarket.log`, cycle is
named in the line, not inferred):

| cycle | round | pick | outcome |
|---|---|---|---|
| 58820 | 16:10 | `ocho-planner` (60%, 9B) | `[llm] ❌ Request failed: 500` |
| 58821 | 16:20 | `ocho-planner` | 500 |
| 58822 | 16:30 | `ocho-planner` | 500 |
| 58823 | 16:40 | `ocho-planner` | 500 |
| 58824 | 16:50 | `ocho-planner` | 500 |
| 58825 | 17:00 | `ocho-planner` | 500 |
| **58826** | **17:10** | **`ocho-planner-4b` (30%, 4B)** | **loaded, health passed, round exit 0** |

`model_cycle_counter.txt` = **58827** POST-increment, mtime 17:10:19.501 — i.e. the file's value is
one cycle AHEAD of the decision that ran, exactly as the 2026-10-14 ruling said. Band map intact;
the previous tick's falsification condition ("if 17:10 passes with the window still open, the band
map or the rotation has changed") did not fire.

Live at write (three identical reads 17:14:5x–17:15:0x): **used 5266 / free 2625 / util 0-1 %** of
8192 → **CLOSED by 1664 MiB** under the 4289 MiB Kev-4B gate; compute apps Bonsai demo 1364 + LFM
vision 134 + planner-4b 3482. (used+free = 7891; the ~301 MiB driver reservation is in neither
column — standing instrument note.)

## Rulings

**R1 — The width of a Kev window is not a constant; it is (cycles to the next rung that fits) × 10
min.** The 2026-10-14 entry measured **10 m 00 s** and named that as *the* window length; that number
was a sample taken while a **9B** was the closer. Today the gate opened on a 9B band, no 9B could be
admitted (6200 + 256 = 6456 MiB against ~6118 MiB free with only the unleased floor resident —
`2026-10-19-a-window-that-cannot-close-because-its-closer-no-longer-fits`), five consecutive 9B picks
were refused with 500s, and the card sat empty for **six cycles / 59 m 47 s** until the rotation
reached a 4B. So the width is a function of *where the band lands*: 1 cycle when a smol/4B opens and
a 9B closes, ~6 cycles when a 9B opens and only the 4B band can close. Quote the window with its
opening rung and its closer, or the width is unreproducible.

**R2 — The forecast is only as good as its mapping key.** The band map predicted the closing cycle to
the round and the close landed within 2 s of the printed estimate, because the cycle was read from the
**pick line** in the planner's log and cross-checked against the counter's post-increment value
(58827 file vs 58826 decision). A forecast read off the counter file directly would have named 58827 —
a smol slot — and predicted the wrong closer and the wrong hour. Same defect family as
`2026-10-14-a-window-that-is-a-rung-of-a-rotation` R2, now demonstrated on the **close** edge and not
just the open one.

**R3 — A certified window that nobody takes is evidence about the tenant lane, recorded as ABSENCE,
never converted into a ping.** This is the second full-width window today that ran its entire length
untaken (11:20:06 → 12:20:27, 59 m 47 s / 60 m 21 s) with the self-authorized poll **certifiably
beating throughout** (`ticker_last_success` 1792455263.93 = 17:14:23, 36 s before the write), no
`kev` / `arcade` / `llama-model-test` lease at any read, and Kev's last run bundle still
**2026-10-12 22:41**. A fallback message remains structurally incapable of being true at receipt
(`2026-10-14-a-prediction-that-closed-on-schedule-is-still-not-an-acquisition` R2): the gate is now
1664 MiB closed and the channel's latency exceeds the remaining window by a factor of infinity. The
record is the deliverable; the absent tenant is an operator flag, not a page.

## Actions

No run action, nothing acquired, no model load. **No `@llama`** (window closed at write; a "window
open" message would be FALSE at receipt — the 2026-10-12 blink class, and the fallback clause belongs
to the `closed->open` edge that was already recorded at 16:20). **No `@ocho`** (diff carries no
`planner_at global->planner` transition; his scoped-planner item was closed on his rows 2026-10-13,
ids 9249 / 9267).

Read-only throughout: `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the driver, the egl marker
and every model load untouched; nothing written outside `governance/`, the watcher log and this
profile's scratch.
