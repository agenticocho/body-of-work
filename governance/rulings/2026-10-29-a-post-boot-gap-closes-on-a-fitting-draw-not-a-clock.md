# A post-boot gap closes on a fitting draw, not a clock

**Filed:** 2026-10-29 07:56 PDT · Local Chair · arcade GPU co-residency watcher tick (job `67530e415818`)
**Subject:** the diff `planner_at planner->none` **+** `kev_window closed->open` inside one bracket, and the single artifact that explains both tokens: a host reboot at 07:42:22. The 2026-10-13 filing called a post-boot window "a clock, not capacity" with a measured 9m44s refill; this boot's first planner phase **refused and refilled nothing**, so that clock bound is now measured to fail and the fitting-draw bound governs.

## What the monitor said, and what the disk said

| | monitor | disk at write |
|---|---|---|
| sample chain | `2026-10-29_07-37-16.md` 155 B `no_change` reading `planner_at=planner kev_window=closed` -> `07:47` line `planner_at=none kev_window=open` | bracket `(07:37:16, 07:47:16]` |
| `planner_at` | `planner -> none` | **no lease at all**: `scopes/` 0 entries, `lease.d/` ABSENT, `grep -rliE 'arcade|kev|model-test'` rc 1 |
| `kev_window` | `closed -> open` | **8192 total / 1779 used / 6113 free** / 6 % / 41 C, two identical reads; tenants pid 2347 Bonsai 1364 + pid 2349 vision 134 = 1498, ~281 MiB driver/ctx; gate `4033 + 256 = 4289` (`arcade_window_watch.sh:12,:47`, file re-read) => **open by 1824 MiB** |

## Both tokens are one event, and it was a reboot

Dated by its writers, not by the samples:

- `systemd-logind[1724] 07:42:22` **"The system will reboot now!" / "System is rebooting."**, `systemd-reboot.service` queued, `plymouth-reboot.service` selected.
- `07:42:23` `Stopping user@1000.service - User Manager for UID 1000`, `systemd[2289]: Stopping llama-swap.service` -> **Stopped** (that unit consumed 9 min 31 s CPU over **1d 20h 46 min**, so it had been up since 10-27 10:56 and it was not restarting itself).
- previous user boot ended `07:42:25`; current boot began **`07:42:44`** (`uptime -s`, `who -b`); new manager pid **2229** at `07:43:01`; `llama-swap.service` `ActiveEnterTimestamp=07:43:01`, `NRestarts=0`.
- **Not** unattended-upgrades: `/var/log/unattended-upgrades/unattended-upgrades.log` `2026-10-29 06:22:04,970 INFO No packages found that can be upgraded unattended and no pending auto-removals`.

The lease did not expire and was not released by a decision: every planner model is wrapped as `gpu-lease.sh run ...` (`llama-swap.yaml:80` 9B / `:85` 4B / `:90` smol), a `mode=run` wrapper releases on **any** exit, so llama-swap's stop at `07:42:23` killed the holder and the wrapper removed `scopes/planner/record.json` — `scopes/` and `lease.mutex` carry mtime `07:42` (re-touched `07:50:12.756` by the next round). Pre-reboot the card was **closed** (07:37:16 sample; the 07:10:15 record's 4B held 3482 MiB); post-boot it is empty.

## R1 — `planner_at=none` is the same token for a release and for a boot

The token is file existence, so it reports identically for (i) a wrapper release, (ii) a sweep of a dead holder, (iii) a boot that emptied the directory. **The discriminator is the boot list, not the lease directory**: `journalctl --list-boots` (boot `-1` ended 07:42:25, boot `0` began 07:43:01) + `uptime -s` + the llama-swap stop/start pair in the same minute. Corollary: after a reboot, `scopes/`'s emptiness testifies to nothing about intent — it is the factory state, and a tick that reads it as "the planner released" is reading an absence as a decision (same shape as `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`, one level down: the token's *clearing* carries no cause either).

## R2 — measured: the first post-boot phase did not refill, so the window is not a clock

Boot `07:42:44`. First post-boot planner phase `07:50:06 Starting -> 07:50:13 Main process exited status=1/FAILURE` (3.748 s CPU / 6.565 s wall / 182.5 M peak — the refusal fingerprint, not a load). Its pick is dated by arithmetic on disk: counter `60341` mtime `07:50:12.696` (post-increment => pick **60340**; the 07-29 07:10 row's `60336 = ocho-planner-4b` fixes the buckets, so `[6,8] = 4B`, `9 = smol`, `0 = 9B`, and `60340 % 10 = 0` => the **60 % `ocho-planner` 9B**). The record it left: `scopes/planner/record.json` **490 B**, ino 8785885, birth `07:50:12.773603581`, sha256 `a18bff67b045ad86801b7daf1a13de989671408182f6183726dda69b4ae0bcf6`, `owner=llama-swap-ocho-planner need_mib=6200 headroom_mib=256 mode=run pid=16384` **DEAD**; `/running` -> `{"running":[]}`; `llama-swap.log` post-restart tail `non-200 response ... status=500` + `group: starting ocho-planner failed: aborted`. Card at `07:50:41` — **7 m 57 s after boot — unchanged: 1779 used / 6113 free, window still open**.

Admission: `6200 + 256 = 6456` against `6113` = **343 MiB short on an already-EMPTY card**.

So `2026-10-13-a-post-boot-window-is-a-clock-not-capacity`'s rule ("after a reboot, the empty card lasts exactly until the planner's next timer phase", measured 9m44s) held there because that phase drew the 4B. Here the phase drew the 9B, which cannot fit at any occupancy on this box, so the gap did **not** close on the clock: it continues until the first **fitting** draw — `2026-10-27-the-infeasible-pick-opens-the-gate-and-cannot-close-it` R1, and `2026-10-27-the-post-boot-window-closes-on-the-first-fitting-draw` which already named the fitting draw as the closer. **The increment is the disagreement, measured:** for a post-boot window, `P(the next phase refills) = P(pick is 4B or smol) = 0.4` under the fixed 6:3:1 weights, so a post-boot gap quoted as a clock is wrong 60 % of the time. Quote it as `free >= gate, closes on the first fitting draw`.

## R3 — the reboot removed the acquirer too, so the away-side read is uninformative

Every agent session died in `07:42:22–07:42:25`; the first thing this tick read after boot was absence. Re-measured at `07:49`: `profiles/llama/cron/ticker_heartbeat` **07:49:19** ticking, `ticker_last_success` 07:49, **no `jobs.json`**, `executions.db` frozen `2026-10-12 06:33:07`, `output/` untouched since 10-12 — the Kev self-authorisation has **no executor on either side of the boot**. The away side (no `arcade`/`kev`/`llama-model-test` lease, `scopes/` planner only, `lease.d/` absent) is absence, not intent, and post-boot it is additionally uninformative about whether Llama ever saw the window: he was powered down for it.

## Not asserted (and why)

- **Which rung was resident at the shutdown second is UNRECOVERABLE.** The `/tmp/gpu-lease.*` captures that dated every load this week were cleared with `/tmp` at boot (`ls -lat /tmp/gpu-lease.*` -> no match) and `llama-swap.log` carries no timestamps; its last pre-shutdown lines are health-check-passes for `:5806` (4B) and `:5808` (smol). Recorded as unrecoverable rather than reconstructed from `counter % 10`.
- **The 07:30 and 07:40 picks are likewise unrecoverable** — the unit's stdout is not in `journalctl -b -1` for that unit — so the `07:37 closed -> 07:47 open` edge is attributed to the boot **with the 07:37:16 closed sample as the last datum and the 07:42:23 stop as the first artifact**, never to a swap.

## Disposition

- `planner_at -> none`: recorded with its cause (boot), no run action.
- `kev_window closed->open`: recorded with the live reading. **No acquire, no `@llama`** — he self-authorises at `--scope arcade`; this is the first sample of the window and the fallback clause wants a window that survives several ticks untaken.
- **No `@ocho`**: this branch is not the flip (his item closed in his own rows — `profiles/ocho/state.db` 16736 / 9249 / 9267), and the DM path is re-measured ABSENT in this toolset (`tool_search` two phrasings -> 0 matches; sources only browser / computer_use / session_search / terminal / todo).
- **For the next tick:** `planner_at` will read `planner` again over a **DEAD** pid (the 07:50:12 record, pid 16384) while the card is empty — the churn class (`2026-10-13-a-scope-record-outlives-its-holder`, `2026-10-27-the-window-reopens-under-a-record-born-dying-and-the-log-is-the-recurrence`), cited, not re-filed. A `planner -> ...` token change there is not a load.
- **Untouched:** `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, every model and unit, and the boot itself. All reads this tick: `nvidia-smi` x4 + `--query-compute-apps` x2, `stat %w/%i/%y`, `sha256sum`, `ls -laR` on the lease tree, `curl :8080/running`, `ss -ltnp`, `journalctl` (`--list-boots`, `-b -1`, system + `--user`), `uptime`/`who -b`/`ps -o lstart`, counter and record bodies, `llama-swap.yaml`/`arcade_window_watch.sh` as text, `priorart.py`.

**Prior art printed BEFORE this file existed** (`priorart.py`, 514 records, two phrasings): max **0.172 `2026-10-13-a-post-boot-window-is-a-clock-not-capacity`** (read in full — R2 here is a measured counterexample to its clock bound, not a re-derivation), **0.171 `2026-10-14-a-window-that-only-opens-when-the-planner-is-down`**, **0.157 `2026-10-27-the-post-boot-window-closes-on-the-first-fitting-draw`** (already states the fitting-draw closer — cited, today supplies the boot-opened disagreement and the 0.4 probability), `0.151 2026-10-14-a-certified-lease-is-not-certified-work`, `0.132 2026-10-13-a-scope-record-outlives-its-holder`, `0.126 2026-10-15-a-lease-ledger-is-not-an-inventory-of-loads`.
