# 2026-10-27 · The post-boot window closes on the first fitting draw — six refusals, 56.5 min, nothing acquired

ARCADE WINDOW TICK `67530e415818`, change at the `11:52:16` sample.

**Diff.** `planner_at` IDENTICAL on both sides (`planner`), `kev_window open->closed`. No global->planner
transition, so the `@ocho` clause's trigger never fired.

**Bracket, from the persisted chain.** Previous sample
`cron/output/67530e415818/2026-10-27_11-41-16.md` 155 B `Status: no_change (agent run suppressed)` still reading
the 34 B open line sha256 `8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2`; the 11:19 and 11:30
samples are the same 155 B `no_change`. `monitor_state.last_changed_at` `2026-10-27T11:52:16.427506-07:00`, and
`monitor_last_output.txt` is 36 B sha256 `b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`
carrying `planner_at=planner kev_window=closed`.

**The close edge is a load that served, six artifacts at one instant.**
`~/.local/state/gpu-lease/scopes/planner/record.json` 493 B ino `8782668` birth `11:50:21.472798879` mtime
`.473798876`, sha256 `d68e158521c3b972605fdbe2b3c3585cc750fb6045cae321d28167f275d86ff1`,
`owner=llama-swap-ocho-planner-4b` `scope=planner` `class=batch` `need_mib=3800` `headroom_mib=256` `mode=run`
`pid=48505` `acquired_at=1793127021` (=11:50:21) `expires_at=1793213421` (=2026-10-28T11:50:21) `ttl=86400`,
liveness-first policy verbatim, and `lease.d/` ABSENT with `scopes/` = `planner` only => a SCOPED cell.
(1) wrapper `48505` ppid `2405` (llama-swap) lstart `Tue Oct 27 11:50:20 2026`, ALIVE; (2) child `48610` same
lstart, ALIVE, **3482 MiB** on the card, LISTEN `127.0.0.1:5806`; (3) `:8080/running` = one entry
`{ocho-planner-4b, state=ready, proxy http://localhost:5806}`; (4) `:5806/health` -> `{"status":"ok"}`;
(5) capture `/tmp/gpu-lease.xWpxmh` birth `11:50:21.572798565` (+100 ms after the record) mtime
`11:50:26.875781984`, 1637 B, body `loading model '.../Qwen3.5-4B-UD-Q4_K_XL.gguf'` -> `model loaded` at
+2.461 s (**close instant 11:50:24.03**), then `task 0` served 3239 prompt tokens @ 2755.93 tok/s and 100 eval
@ 94.88 tok/s; (6) `journalctl --user -u ocho-planner-polymarket.service` `11:50:15 Starting` -> `11:50:27
Finished` EXIT 0 (3.669 s CPU / 11.772 s wall / 142.3 M) against six `status=1/FAILURE` rounds before it, and
real work out: `plans/latest_plan.json` 1247 B mtime `11:50:26.996498172` (`PX-will-benjamin-netanyahu-be-the-next-
prime-minister-of-israel`, predicted_prob 0.13, outcome NO, amount 5) with the planner log ending `Plan saved` ->
`Prediction logged to ocho_predictions.jsonl`.

**The rotation, read off the counter and the pick log, not inferred.**
`model_cycle_counter.txt` 5 B `60057` mtime `11:50:21.374597385` = the POST-increment for pick `60056`, which is
**98.2 ms BEFORE** the record birth => no unlogged consumer between pick and load. Pick lines, gapless, one per
round: `60050`-`60055` = the bare `ocho-planner` (60 % weight, the 6200 MiB 9B), `60056` = `ocho-planner-4b`
(30 %). The five in-window refusals are journal-dated `11:00:11 / 11:10:20 / 11:20:09 / 11:30:15 / 11:40:06`
(142.0-143.7 M peak), following the `10:50:09` refusal in the previous boot; `11:50` is the first `Finished`
since `10:40:23`.

**Width.** Open edge `10:53:51` = `journalctl --user` `Stopping/Stopped llama-swap.service` in boot `-2`
(`228f6d53…`, ended `10:53:56`), which killed the resident scoped 4B child `4106040` (3482 MiB) named as the
closer by the 10:10 filing; close `11:50:24.03` => **3393.03 s = 56.550 min = 5.6550 x 600 s rounds** (3390.47 s
to the record birth). The card was open continuously across the two short boots (`10:54:24-10:55:17`,
`10:55:55-`): llama-swap restarted `10:56:05` and the phase drew the 9B five times without ever loading, so
nothing refilled the gate. Today's four dated windows now total **12331.80 s of 19207.67 s** from `06:32:08.760`
= **64.20 %**.

**Live at write, three reads 11:53-11:54.** RTX 3060 Ti 8192 MiB total / **5257, 5257, 5261 used** /
**2635, 2635, 2631 free** / util 10, 5, 7 % / 41 C => `2631 - 4289 = -1658` and `2635 - 4289 = -1654` =>
**CLOSED**, 1654-1658 MiB under the 4289 MiB Kev-4B gate (`arcade_window_watch.sh:12` comment and `:47` test read
this tick: 4033 peak + 256). Tenants: `2408` Bonsai demo 1364 + `2409` LFM2.5-VL vision 134 (both
`--n-gpu-layers 0`, both UNLEASED = 1498) + `48610` planner 3482 = 4980 of 5257, leaving 277-281 driver/ctx;
`used + free = 7892` vs `8192` = the standing ~300 MiB reservation in neither column, so 6117 is the empty-scope
ceiling and `2635 + 3482 = 6117` reconstructs it exactly. Admission against that ceiling: 9B `6200 + 256 = 6456`
is **339 MiB SHORT** (still manufactured by the same rung, and the ceiling is 6117 today rather than 5980-5986
earlier because the post-reboot Bonsai tenant is 1364, not 1466); 4B `4056` has 2061 spare and the smol fits —
so `closed` is forecastable to `2026-10-28T11:50:21`, because the resident 4B is `mode=run` and never reclaimable
at any age.

**Away side measured, not assumed.** Across the whole 3393.03 s the gate stood 1692-1761 MiB over Llama's
authorisation and nothing acquired it: `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` -> rc 1, NO
MATCH; `ls -A scopes` -> `planner` only; `lease.d/` ABSENT; `pgrep -af 'kev_run|kev-|arcade_|model-test|llama-model-test'`
-> no live match; `ss -ltnp` -> `:8080` llama-swap, `:5806` llama-server, `:8642` hermes, `:8443` tailscale and
nothing else on 58xx. Standing caveat: a scope record is deleted on release, so this is absence of an artifact and
never proof that no raw load ran (`2026-10-15-a-lease-ledger-is-not-an-inventory-of-loads`).

**Messages: none, and both premises measured rather than skipped.**
No `@ocho` — no token edge in this diff (planner on both sides, so the clause's trigger never fired); his
scoped-planner item is closed in HIS OWN rows (`sqlite3 -readonly profiles/ocho/state.db`: `9249` user / `9267`
assistant / `16736` "Verified independently, and the item is closed.", `max(id)=17405`, the only later mention of
`--scope planner` being his own `ps` output at `17066`). Note the clause's premise IS true this tick for the first
time after a reboot — a model really is loaded under the scoped lease (48505/48610 alive, 3482 MiB, health ok) —
which is precisely why a DM would carry only what he already holds, and the same owner+need has been live since
2026-10-13 (`2026-10-14-the-closure-is-in-the-recipients-row`). Independently, this cron toolset still has NO
agent-DM path (`tool_search` on two phrasings -> 0 matches; sources = browser / computer_use / session_search /
terminal / todo), so the escalation channel is this delivery to Mike.
No `@llama` — CLOSE edge: 2631 free is 1658 MiB the wrong way, so a page would assert a window false before it was
written and still false after any channel latency
(`2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches` R1); he is self-authorised at
`--scope arcade` under the operator precedence clause and this watcher neither triggers nor preempts his poll.

**Standing flag for Mike, re-measured not carried.** `profiles/llama/cron/` still holds NO `jobs.json` (only
`.jobs.lock`, `.tick.lock`, `executions.db` 24576 B frozen `2026-10-12 06:33:07.322361061`, an `output/` untouched
since 10-12) while `ticker_heartbeat` 23 B is rewritten at `11:54:15` — a live clock over an EMPTY JOB SET
(`2026-10-21-a-heartbeat-is-not-an-evaluation` R2). The operator's standing Kev self-authorisation had 56.5 min of
clear gate and nothing on this box executing it; that is an execution fact, not a Kev decision. This watcher does
not create jobs.

**Filed as a dated instance, not a rule.** Prior art printed BEFORE this file existed (`priorart.py rulings`, 507
records, two phrasings): max `REVIEW 0.368 2026-10-23-a-window-closes-when-the-ladder-picks-the-rung-that-fits`,
`0.219 2026-10-13-a-post-boot-window-is-a-clock-not-capacity`, `0.198 2026-10-27-the-post-boot-window-outlives-the-phase-that-refuses`
(own parent — this is its close edge), `0.171 2026-10-19-a-window-width-is-the-distance-to-the-next-rung-that-fits`,
`0.150 2026-10-27-the-hour-wide-window-closed-on-the-first-draw-that-fits`. The mechanism is owned; nothing new is
claimed. What this tick adds is the pairing: the open edge of the 11:07 filing and this close are one window,
56.550 min wide, and the 9B shortfall measured against a post-reboot ceiling of 6117 is 339 MiB.

**Read-only throughout.** nvidia-smi (4 x `--query-gpu`, 2 x `--query-compute-apps`), `stat` incl. `%w`,
`sha256sum`, `ps -o ppid,lstart`, `kill -0`, `curl :8080/running` and `:5806/health`, `ss -ltnp`, `journalctl
--user` (boots, unit, llama-swap), `sqlite3 -readonly`, `grep`/`pgrep`, `priorart.py`, `tool_search`; no acquire,
no release, no model load, no reservation, no unit, no config, no state-changing systemctl; `gpu-lease.sh`,
`llama-swap.yaml`, `scopes/planner/`, the planner unit and every model UNTOUCHED — the 11:50 load and the 11:50:26
serve were the timer's own requests through llama-swap.
