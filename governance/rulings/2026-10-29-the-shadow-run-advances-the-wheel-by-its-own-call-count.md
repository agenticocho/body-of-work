# The shadow run advances the wheel by its own call count

**Filed:** 2026-10-29 (tick 14:19:19.929, job `67530e415818` "arcade-window-watch")
**Trigger:** diff `planner_at=planner kev_window=open->closed` — the planner token
IDENTICAL on both sides, so no scoped-planner flip and no `@ocho` DM.

## What the artifacts said

- **Bracket** `(2026-10-29 14:08:19, 14:19:19.929]`: the 14:08:20 sample is
  `no_change` (155 B stub) reading the 34 B open line; `monitor_last_output.txt`
  36 B mtime `14:19:19.929292834` sha256 `b391e197…145820b1` body
  `planner_at=planner kev_window=closed`. Samples 13:13–14:08 all `no_change`
  on the open line, i.e. the card was open at every 11-minute sample for ~67 min.
- **Close edge is a real holder, triple read positive:** record 494 B ino
  `10272179` birth `14:10:17.090607910` sha256 `3787d8ac…33a4ac`
  `owner=llama-swap-ocho-planner-4b` `need_mib=3800` `headroom_mib=256`
  `pid=302100` `mode=run` `acquired_at=1793308217` `expires_at=1793394617`;
  wrapper `302100` ppid 2345 (llama-swap) ALIVE + child `302200` **3482 MiB**
  LISTEN `127.0.0.1:5806`; `:8080/running` `ocho-planner-4b state=ready proxy
  :5806`; `:5806/health` `{"status":"ok"}`; journal `14:10:11 Starting ->
  14:10:21 Finished` **exit 0** (3.284 s CPU / 10.367 s wall / 143.2 M) against
  `status=1/FAILURE` for the six refusals before it. Capture `/tmp/gpu-lease.6VWs4b`
  1637 B birth `14:10:17.197605389` mtime `14:10:21.833496227`, `model loaded`
  at `+1.126 s` **=> close `14:10:18.32`**.
- **Open edge bounded to `13:02:26 – 13:03:00`:** the 13:03 run's amendment read
  `4675 used / 3216 free` (closed, shadow smol resident) at `13:02:26`, and the
  13:03:00 sample read the card open. Width **67.31–67.87 min = 6.73–6.79
  rounds** of the `*:0/10` clock.
- **Live at write, three identical reads `14:22:2x–:3x`:** 8192 total / **5485
  used / 2406 FREE** / util 7,13,19 % / 41 C => **CLOSED by 1883** under the
  4289 gate (`arcade_window_watch.sh:12,:47` = 4033 + 256, file read this tick).
  Compute apps `2347` Bonsai **1364** + `2349` vision **134** + `87744` bge-small
  **226** + `302200` planner-4b **3482** = 5206; `used+free 7891` => driver/ctx
  **301**; empty-scope ceiling `2406 + 3482 = 5888` => 9B `6456` **568 short**,
  4B `4056` clears by **1830**.
- **Away side measured, not carried:** `grep -rliE 'arcade|kev|model-test'` over
  `~/.local/state/gpu-lease` rc 1; `scopes/` = planner only; `lease.d/` ABSENT;
  no `llama-model-test` record in any tick.

## Rulings

**R1 — the counter's jump between two rounds equals the shadow run's planner call
count, and it is countable BEFORE the round.** The 13:00 round drew `cycle 60371`
(`ocho_planner_polymarket.log:243456`) and the 13:10 round drew **`cycle 60380`**
(`:243506`) — a **+9 jump** with no pick line for `60372–60379` anywhere in that
log. `ocho-shadow-polymarket.service` ran `13:00:15 -> 13:01:39` and its log block
carries **exactly 9** `[shadow-llm] Calling planner for …` lines (`tail -400 |
grep -c` = 9), each a `call_ocho_planner.py` subprocess that read-and-increments
the same `model_cycle_counter.txt` (`call_ocho_planner.py:458-475`) and failed at
the LLM call *after* picking. So the jump is `+9` for `9` calls: the mechanism is
`2026-10-15-a-rung-calendar-on-a-counter-with-more-than-one-consumer` **R1**
(cited, not re-argued — it measured a `+3` from three shadow subprocesses), and
the increment is that the jump is **not an unknown**: `grep -c 'Calling planner'`
on the shadow run's own block predicts it, so the phase after a shadow run is
computable rather than merely unpredictable. The same shadow run also loaded the
smol wrapper at `13:01:36` that closed the card to 3216 free — **one event, two
effects**: it re-phased the wheel and briefly emptied the card.

**R2 — the congruence survived; the clock did not.** The 12:58 filing
(`2026-10-29-the-rotation-is-a-deterministic-wheel-…` R3) forecast
`60376 = 6` at **13:50** was a 4B draw => closes, "barring `pool 2/3` or a
fitting 9B". Measured: 13:50 drew **`60384`** and 14:00 drew **`60385`**, both
`ocho-planner` (9B), both `status=1/FAILURE` (journal `13:50:18`, `14:00:06`),
so the window survived two extra rounds and closed at **14:10 on `60386`** — a
cycle whose `% 10` is **6**, exactly as the wheel requires. The forecast was
wrong by **20 min (2 rounds)** because it projected the slot from **wall-clock
rounds** while the phase had already moved by 9; `60371+9+6 = 60386` reproduces
the real close. Durable form: **a wheel forecast must state the counter value it
starts from and add the intervening shadow call count; a forecast quoted in
rounds is valid only for rounds with no shadow run between them** — the shadow
timer is hourly (`*:00`), so the 13:00 slot is exactly where such forecasts fail.

**R3 — a long window is the refusals' length plus the wheel's phase, and every
interior draw here was a refusal, not a miss.** Interior picks `60380` (13:10),
`60381` (13:20), `60382` (13:30), `60383` (13:40), `60384` (13:50), `60385`
(14:00) are all `ocho-planner` 60 % with journal `FAILURE` at `13:10:06`,
`13:20:21`, `13:30:11`, `13:40:16`, `13:50:18`, `14:00:06` (and `13:00:22` for
`60371`), each 142.3–143.5 M — the 9B's `6456` against a 5888 empty-card ceiling
is 568 MiB short in **every** state of this card, so no interior round could
close it; only a slot-6/7/8 draw could, and the phase put the next one at 14:10.
Width **67.3–67.9 min** is therefore `7 refusals x 10 min - the shadow run's
absorption`, not a scarcity event and not evidence the rotation changed.

**R4 — the resident rung absorbs the next 4B draw without re-acquiring.** The
`14:20:15` round drew `cycle 60387` — also a 4B slot — and the journal shows
`14:20:15 Starting -> 14:20:23 Finished` while the record is **still birth
`14:10:17.090607910` with `pid 302100`** and `/running` still the same instance:
the pick found the slot resident, so no new lease was taken and no new load
occurred. Instance of `2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`
(cited): **the `planner_at=planner` token dates the last LOAD, not the last
round**, and a `gpu-lease.sh status` read after a round can show a holder whose
`acquired_at` is one round older than the reader expects.

## Actions

RECORD ONLY. No acquire, release, load, reservation, unit or config touched:
`gpu-lease.sh` (status only), `llama-swap.yaml`, `scopes/planner/`, the planner
unit and timer, all four compute processes, the driver, `call_ocho_planner.py`
and `model_cycle_counter.txt` untouched. **No messages:** no `@ocho` — the token
never moved in this diff, and his item is closed in his own rows
(`profiles/ocho/state.db`, ids 9249/9267/16736, `max(id)=17405`); a DM would
re-open a closed item into a channel that drops on `target_busy` with no receipt
— no `@llama` — CLOSE edge, 2406 free is 1883 MiB the wrong way, the fallback
clause is for an open window that survives several ticks untaken, and he
self-authorises at `--scope arcade`. Read-only throughout: `nvidia-smi` x8,
`stat %w/%i/%s`, `sha256sum`, `ps -o ppid,lstart`, `ss -ltnp`, curl `:8080/running`
and `:5806/health`, `journalctl --user` (planner, shadow, timers), log greps,
`gpu-lease.sh status`, `priorart.py` (521 records, two phrasings: max weak
`0.136 2026-10-16-a-pick-that-finds-the-slot-resident-is-not-a-load`,
`0.134 2026-10-29-the-rotation-is-a-deterministic-wheel-…`,
`0.121 2026-10-21-a-counter-read-at-a-rounds-end-names-the-next-round`,
`0.099 2026-10-15-a-rung-calendar-on-a-counter-with-two-consumers` — read in
full, owner of R1's mechanism and cited as such).

**Standing flag for Mike, re-measured 14:22:** `profiles/llama/cron/` still has
**no `jobs.json`** while `ticker_heartbeat` is rewritten every tick — a live clock
over an empty job set, so the operator-approved precedence clause has no
executor; this window stood open **67 min at +1604 MiB** untouched in the same
period. An execution fact, not a Kev decision; this watcher creates no jobs.
