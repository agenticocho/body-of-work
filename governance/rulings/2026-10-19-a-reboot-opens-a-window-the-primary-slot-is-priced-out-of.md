# a reboot opens a window the primary slot is priced out of

**Tick:** `67530e415818` (arcade-window-watch), monitor change detected `2026-10-19T13:30:25.918322-07:00`
(`jobs.json` `monitor_state.last_changed_at`); previous persisted sample `13:19:34` (script `arcade_window_watch.sh`,
2552 B, sha256 `775c4858249ae589e8958ca170952e0c641d5ea07cdf2f3f638ec580678e0e8e`, unedited since 2026-10-13).
**Diff:** `planner_at=planner kev_window=closed -> open`. The planner token is IDENTICAL on both sides — no flip,
no `@ocho` DM. Only the window moved, and it moved by OPENING.

Persisted sample = 34 B `planner_at=planner kev_window=open`, sha256
`8da24188df0a59356aefbcb750a9409311ab79022d30bd98027067c939216fe2` == `jobs.json monitor_state.last_output_hash`
== three fresh runs of the detector in this tick (byte-identical).

## The open edge is a machine reboot, and the reboot was not clean

`journalctl --list-boots`: boot `75dec31f…` **ended 2026-10-19 13:22:08**, boot `785cdf33…` **began 13:22:52**
(`uptime -s` = 13:22:46, kernel banner `Linux version 7.0.0-38-generic` at 13:22:52). The 13:19:34 sample was
taken **inside the old boot** (closed, 9B resident); the detector first saw `open` at 13:30:25.

The old boot's journal **ends with no shutdown sequence at all** — last six lines are `im-config` from a
desktop app launch at 13:22:08, no `systemd-shutdown`, no `Stopping …`, no target transition, no logout.
So the reboot is an **unclean end** (hard reset or kernel-level stop), not an ordered shutdown. What it is
**not**: the 2026-10-16 offline-update lever did not fire — `boot 0` runs `pk-offline` zero times and
`/var/lib/PackageKit/offline-update-competed` is still mtime `2026-10-16 10:52:12` (`Success=false`,
the same unapplied brave 1.97.57→1.97.59 stage). **Cause of the reboot: unmeasured** — the artifact that
would carry it (a shutdown record) does not exist, and the journal dies mid-sentence.

## Live at write (three identical reads, 13:34:4x–13:36:10, nvidia-smi rc 0, values validated numeric)

```
used 1647 MiB / free 6245 MiB of 8192     (first read of the tick, 13:30:31: 1702 / 6190)
gate 4289  ->  open by +1956 MiB
apps: 2434 PrismML Bonsai 9B (--n-gpu-layers 0) 1364 MiB · 2436 LFM2.5-VL 134 MiB   = 1498
no llama-server on :5805 · no arcade/kev/llama-model-test lease anywhere (scopes/ = planner only, lease.d/ absent)
```

Card: boot 0, module 615.71.09 open kernel module, **NVRM lines this boot = 1** (the module-load line only)
⇒ zero GPU faults since the reset.

## The record carries a stamp that predates the boot its own inode was created in

`~/.local/state/gpu-lease/scopes/planner/record.json` — 490 B, sha256
`e5bb9d4330775b821ac08fa85fc66a1099057f3b69b377f5986350b2ec8bc7de`:

```
owner llama-swap-ocho-planner · scope planner · class batch · need_mib 6200 · headroom_mib 256
pid 2196538 (DEAD — ps returns nothing) · mode run
acquired_at 1792440027 = 13:00:27 · expires 1792526427 = tomorrow 13:00:27 · ttl 86400
```

Its **content stamps 13:00:27 and an old-boot pid**, but its **inode was born 13:30:32.411493139**
(mtime `.413493114`, ctime `.415493091`; parent `scopes/` mtime `.406493198`, `scopes/planner/` `.415493091`
— the 7 ms spread of one mutexed `rm -rf` + `mkdir` + `ld_write`). `ld_write()` (gpu-lease.sh:314-320) computes
`now=$(date +%s)` and `pid=$$` **in the writing process**, and a post-boot kernel cannot hand out pid 2196538
(2.19 M forks in 8 minutes is impossible; this boot's pids are 2xxx–16xxx). So the file existing at 13:30:32
with that content **is not explained by the writer's code path**, and I have no artifact that explains it:
the wrapper's stdout capture is gone (`/tmp/gpu-lease.*` is empty — `/tmp` is tmpfs and the reset wiped it,
which is the uninformative-absence rule already on file), llama-swap swallowed the lease output, and the
failed round's own log names only the 500.

**What does not depend on resolving it:** the named holder process is dead, no 9B is resident, and free VRAM
is measured live. The discrepancy is recorded, not narrated — and it is checked next tick by re-statting the
record at the next 9B attempt (13:40/13:50): if `acquired_at` again equals the *previous successful* acquire
while the inode is fresh, the field is being carried across a rewrite and **`expires_at` is being computed
from a stale stamp**; if it matches the write, this was a one-off of the reset.

## R1 — the window cannot close on this card, and now the reason is boot order, not rotation

`gpu-lease` admits on `free >= need_mib + headroom_mib`. The primary slot is
**6200 + 256 = 6456 MiB**, and the post-boot card offers **6190 (13:31) → 6245 (13:34-13:36)**:
**short by 266 → 211 MiB.** The unleased floor tenant that eats the margin is
**pid 2434, PrismML Bonsai 2 9B ternary, `--n-gpu-layers 0`, 1364 MiB resident** (plus LFM 134) — started
**13:23:02**, i.e. *before the first post-boot planner round at 13:30:24*. So the sequence is deterministic:
reboot empties the card → the unleased tenants arm first → the planner's first round prices itself against a
card that is no longer big enough → refusal. Stop pid 2434 and free becomes ~7609, which is 6456 + 1153.

This **extends** `2026-10-19-a-window-that-cannot-close-because-its-closer-no-longer-fits` (priorart REVIEW
0.247, read by eye — it owns "the closer's admission price exceeds the free VRAM", measured mid-rotation with
the 4B resident). The difference is the *phase*: that filing had the closer losing to a resident sibling; here
the closer is priced out of the **whole card at boot**, so no rotation luck can close it either. It also
**instances** `2026-10-13-a-reboot-manufactures-the-window` and
`2026-10-13-a-post-boot-window-is-a-clock-not-capacity` (weak 0.109 / 0.133) without restating them: those own
"a reboot opens the window"; the new part is that on this box the window the reboot opens **has no closer at
the primary rung**, so it is capacity, not a clock.

## R2 — the 9B rounds are failing now, and the failure is at admission

`ocho-planner-polymarket.service`: 13:30:24 Starting → **13:30:32 failed, `Result=exit-code`,
`ExecMainStatus=1`, 8.675 s wall, 189.5 MB peak** (not OOM). llama-swap's log carries
`group: starting ocho-planner failed: aborted` **six times** in the post-boot segment, each paired with
`non-200 response, recording partial metrics: status=500, path=/v1/chat/completions`, and the planner log ends
`Request failed: 500 Server Error`. The 13:00 round on the *old* boot did load: cycle 58802-58804 picked
`ocho-planner` (9B), and the activity log's last shadow trade is `2026-10-19T20:01:37Z` = **13:01:37 PDT,
`model_slot: ocho-planner`** — so the record's 13:00:27 stamp names a real load, and the load is what the reset
took away.

## R3 — a suppressed tick is invisible inside the bracket (again)

Samples inside the bracket that were suppressed as `no_change`: 12:46, 12:57, 13:08, **13:19** (all 155 B
output files) — the 13:19 sample is the last one taken *before* the reset, and the reset happened 2 m 34 s
after it. So the open edge is bracketed `(13:19:34, 13:30:25]` = **10 m 51 s**, inside which the reset at
13:22:08 and boot at 13:22:52 both sit. One more instance of
`2026-10-15-an-edge-already-dated-is-not-a-new-window` R1's family; the detector cannot see faster than its
sample period and this tick does not pretend the edge is the boot instant.

## Prediction published for the next tick to check

1. The window **closes at the first round whose weighted pick lands on `ocho-planner-4b` (3800+256 = 4056) or
   `ocho-planner-smol` (3000+256 = 3256)** — 40 % of rounds by the 60/30/10 weights — and stays open through
   9B picks (60 %). Expect a duty cycle near 60 % open, the inverse of the 10-14/10-15 regime.
2. **Falsifier:** a 9B round succeeding while pid 2434 is alive (would mean free ≥ 6456 with the Bonsai
   resident — i.e. my pricing is wrong), or the window closing on a 9B-picked round.
3. The 13:40 record's `acquired_at` is compared to its inode birth (R above).

## Messages: none, both premises measured

- **No `@ocho`.** The diff's planner token is identical on both sides, so no flip is being announced. His open
  item stays closed in *his* rows: `messages` id 9249 (user, 2026-10-13 17:49:44, "Your open item is closed, and
  I confirmed it from disk") + id 9267 (assistant), and his newest rows 16360-16364 are cabinet/kanban work
  (`mc-field-ruling`) — nothing owed.
- **No `@llama`.** The window is open, and he is **self-authorized** on his own continuous poll: paging him would
  preempt a poll that is demonstrably alive (`profiles/llama/cron/ticker_heartbeat` 1792442070.494 = 13:34:30,
  `ticker_last_success` 1792442063.949 = 13:34:23, 32 s before the live read) and there is no
  `arcade`/`kev`/**`llama-model-test`** lease anywhere. Fallback condition for a later tick, stated so it is not
  invented later: **the window still open at two consecutive samples with a live heartbeat and no
  `llama-model-test` lease** — and then only if the gate is still clear at the moment of sending (the
  `2026-10-15` fallback-can't-fit-inside-its-own-window rule).
- Kev has still not run: `Kev-4B-Q4_K_M.gguf` mtime `2026-10-05 15:55`, no `kev_*` artifact newer, no lease.

Read-only throughout: nvidia-smi seven reads, three detector runs, journalctl, stat/sha256sum, ps, findmnt,
apt-cache policy, one `sqlite3 -readonly` of Ocho's rows. No lease taken, no model loaded, no run triggered,
`gpu-lease.sh` / `llama-swap.yaml` / the planner lease / driver untouched, nothing written outside governance/.
priorart.py run **before** this file existed (236 records; max REVIEW 0.247 on the 12:30 closer-pricing ruling,
then 0.172, 0.135, 0.133, 0.131, 0.109 — the two reboot filings read by eye at 0.133/0.109 and cited, not
restated; second proposal max weak 0.144). check_index.py after.

**FLAGGED FOR MIKE, not acted on:** (1) the box reset uncleanly at 13:22:08 with no shutdown record — worth a
look at `journalctl -b -1 -o short-iso | tail` and the firmware log, since the same pattern (no ordered
shutdown) is what a power/hardware event looks like; (2) stopping pid 2434 (PrismML Bonsai demo, unleased,
1364 MiB, `--n-gpu-layers 0`) is now the single lever that makes the primary 9B admissible — without it every
reboot leaves the Arcade gate open by ~2 GB and every 9B planner round burns 10 minutes into a 500.
