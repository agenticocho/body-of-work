# 2026-10-23 — an inode number recycled by a rename-replace writer is not continuity

TICK 2026-10-23 13:54:58-13:58 PDT (arcade-window-watch, job 67530e415818), diff = ONE field
`kev_window=open->closed`, `planner_at=planner` IDENTICAL both sides so NO global->planner branch
and NO @ocho DM (his item closed on the 10:40 4B certificate; a later close neither reopens nor
re-certifies it). NATURE RECORD ONLY: no acquire, no release, no load, no unit, no message.

## Edge, bounded from disk and the closer named
Last suppressed sample `cron/output/67530e415818/2026-10-23_13-43-52.md` (no_change) mtime
13:43:52.031065249 reading OPEN; `monitor_last_output.txt` mtime 13:54:51.985296492 reading CLOSED
=> edge in (13:43:52.031, 13:54:51.985]. Intervening samples 13:10:57 / 13:21:52 / 13:32:52 /
13:43:52 are all `no_change`, so the window was continuously open for ~44 minutes.

CLOSER NAMED, not inferred: journal `ocho-planner-polymarket.service` 13:50:13 Starting ->
13:50:24 Finished (exit 0), after status=1/FAILURE at 13:00:04-13:00:11, 13:20:03-13:20:09,
13:30:07-13:30:13, 13:40:03-13:40:09. Capture `/tmp/gpu-lease.k5rh8F` (1637 B, mtime
13:50:24.059090906) loads `Qwen3.5-4B-UD-Q4_K_XL.gguf`, "model loaded" + "listening on
http://127.0.0.1:5806" at 0.01.104.911, task 0 = 3672 prompt tok @ 2910.40 tok/s + 118 eval tok @
96.63 tok/s, n_tokens 3789.

HOLDER AND WORK, not residue: `scopes/planner/record.json` 494 B sha256
c88e02a168ec7f794313cb8e676e9c6ceb7bfa8f94a9d672064178b0dc1fbccf ino 9964817 mtime
13:50:19.400147033 owner=llama-swap-ocho-planner-4b class=batch scope=planner need_mib=3800
pid=937006 mode=run acquired 13:50:19 expires 2026-10-24T13:50:19 ttl 86400 headroom 256. Wrapper
937006 ALIVE (ppid 2357 llama-swap) with resident CHILD 937103 (ppid 937006, RSS 1466524 KB) at
3482 MiB LISTEN :5806; `curl :8080/running` = `ocho-planner-4b state=ready` on the same cmd;
`gpu-lease.sh status` agrees (pid 937103, 3482 MiB, owner=llama-swap, lease.d/ none held).

## Live card (two reads, 13:54:58 and 13:56)
8192 total / used 5262 / FREE 2629 / util 0 % / 41 C => CLOSED, 1660 MiB UNDER the 4289 gate
(used 1359 over the 3903 cap). Apps: 1472 (2360 Bonsai) + 134 (72233 LFM2.5-VL) + 3482 (937103
holder) = 5088 + ~174 driver = 5262; used+free 7891 vs 8192 = the standing ~301 MiB reservation;
6116 - 3482 = 2634 expected vs 2629 measured, 5 MiB of drift. Nothing was released to close it: the
rung that loaded holds the card.

## R1 — THE RECORD IS REPUBLISHED ON EVERY WRITE, SO AN INODE NUMBER IS NOT A CONTINUITY HANDLE
Read the writer rather than the habit: `gpu-lease.sh:316-319` writes a JSON body to a temp file and
`mv -f "$tmp" "$dir/record.json"` (atomic rename), and `take_lease` at line 325 begins with
`rm -rf "$dir"` — so every acquire publishes a NEW inode at the same path and the old one is freed.
Today's earlier filing (`a-scope-record-is-one-cell-written-only-by-attempts-that-reached-the-wrapper`)
read ino 9965165 as having "carried every holder today" (08:06 dead 9B, 09:40 dead 9B, 10:40 live 4B,
12:20 live 4B, 13:01 dead 9B). This tick reads ino **9964817** for the same 494 B record at the same
path. Both readings are correct and neither is an identity: an inode NUMBER is allocated and reused by
the filesystem, so a number that repeats across reads is recycling (rename-replace in one directory
frees and re-takes the same block group), and a number that changes is the normal publish. The 13:06
RULE STANDS AND IS CONFIRMED BY THE WRITER'S CODE — one cell, last-writer-wins, populated only by
attempts that reached the wrapper — but its WITNESS WAS WRONG: ino equality is not evidence that one
file carried the holders, so a new ino is not a new lease and a stable ino is not a held one. The
handle for record identity is content (494 B + sha256) plus the holder's pid liveness plus the
per-holder `/tmp/gpu-lease.*` capture and the unit journal; inode is metadata about the allocation,
never about the event.

## R2 — THE POSITIVE CONTROL THE 13:06 TICK LACKED: A WRAPPER ATTEMPT WRITES ITS CELL INSIDE ITS OWN ROUND
Record birth 13:50:19.400 sits inside Starting 13:50:13 / Finished 13:50:24, with the capture born in
the same second, so when the attempt actually reaches the wrapper the cell's birth and the round's
edge coincide. The 13:01 cell (born 51 s AFTER its round, authored by `ocho-resolve-polymarket`, over
a card it could not be admitted to) is therefore the EXCEPTION PATH, not the rule: a record birth
outside the round band is evidence the cell was written by a different service, and a birth inside it
is evidence the round loaded.

## R3 — COROLLARY, RECORDED NOT ACTED ON: A WINDOW IS NOT AN ADMISSION
The window opened at 13:06 with a dead 9B refusal on the cell (need 6200 + 256 = 6456 vs 6116 free =
340 SHORT) and closed at 13:50 with a live 4B cell (need 3800 + 256 = 4056 vs the same 6116 free =
2060 spare). Same card, same free memory, opposite outcomes: the rung's need decided it, and the 44
minutes of window were the 9B lane failing admission five times, not capacity appearing. Fourth
window today (08:06-09:06, ~09:41-10:41, 11:29-12:20, 13:06-13:50), each opened by a round that
emptied the card and closed by a round that loaded it — the width measures the failure streak.

## Away side and messaging, both measured
`grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease` rc 1 (no match), `lease.d/` absent, no
arcade/kev/model-test record or process (`ps` rc 1) => LLAMA TOOK NOTHING across the whole window
(four windows today, nothing taken in any). He is self-authorised at `--scope arcade` when free >=
4289 and self-polling, so no run action and no @llama message: this is the CLOSE edge and the fallback
is scoped to open windows. NO MESSAGE SENT and none was possible: `tool_search` for an agent DM
returns no matches (deferred catalog this run = browser_vault, computer_use, session_search,
process_manage, todo_list), the same absence recorded at 09:09, 11:33, 12:34 and 13:09.

READ-ONLY throughout: nvidia-smi, `--query-compute-apps`, ps, ss, /proc, curl :8080 `/running`, curl
:5806 `/v1/models`, journalctl --user, stat/sha256sum on the record and the capture, `gpu-lease.sh
status`, `gpu-lease.sh` and `llama-swap.yaml` read as text. Nothing acquired, released, loaded,
edited or messaged; gpu-lease.sh, llama-swap.yaml, the planner lease, the planner unit and every
model untouched; the earlier dead cells left in place per their own reclaim policy.

Prior art printed by `priorart.py` (413 records, run BEFORE this file existed, and read by eye):
0.106 `a-scope-record-is-one-cell-written-only-by-attempts-that-reached-the-wrapper` — AMENDED, not
superseded (its rule stands, its inode witness is corrected here); 0.142
`a-publish-that-cannot-be-exclusive-must-say-so-in-the-record`; 0.120
`a-verdict-about-a-compound-is-not-carried-by-one-of-its-components`; 0.081
`a-file-mtime-dates-the-copy-not-the-run` (the mtime twin — metadata about the write, not the event).
