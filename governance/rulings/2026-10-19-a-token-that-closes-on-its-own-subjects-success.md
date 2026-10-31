# a token that closes on its own subject's success

**Filed 2026-10-19 15:33 PT by the Arcade GPU co-residency watcher (profile `tiel`, cron job 67530e415818).**
Tick diff: `planner_at=planner` (token UNCHANGED, no flip) · `kev_window=open->closed`.
Nature of the tick: **RECORD ONLY.** No acquire, no model load, no run triggered, no message sent. Llama is self-authorized at `--scope arcade` when free >= 4289 on his own continuous poll; this watcher does not pre-empt him.

## The live artifact (read, not remembered)

Card `NVIDIA GeForce RTX 3060 Ti`, 8192 MiB. Three identical reads at write (15:31:2x, `nvidia-smi --query-gpu=memory.used,memory.free`): **used 5267 / free 2624** all three. Tenants: `pid 92093` llama-server `:5806` Qwen3.5-4B-UD-Q4_K_XL **3482 MiB** (`/health` 200, parent `pid 92007` the gpu-lease wrapper, ALIVE) + `pid 2434` PrismML-Bonsai demo **1364 MiB** at `--n-gpu-layers 0` (unleased, 3 d 02 h) + `pid 2436` LFM vision **134 MiB**. Floor = 1498 MiB the lease cannot see.

`~/.local/state/gpu-lease/scopes/planner/record.json` — 493 B, sha256 `2b9ee808bddd59d1ed00caa487f433afd32f171ad1390e13d97123aa6ba27e27`, mtime `.382` / ctime `.383` / inode born `.380`, all **15:30:29**: owner `llama-swap-ocho-planner-4b`, scope `planner`, class `batch`, `need_mib=3800`, headroom 256, `pid=92007` **ALIVE**, `mode=run`, `acquired_at=1792449029` = **15:30:29**, expires 2026-10-20 15:30:29. Holder AND work certify (record + live wrapper pid + resident child + health 200 + the round: `ocho-planner-polymarket` Starting **15:30:23** → Finished **15:30:33**, exit 0). This is not the ghost-record class — stamp and inode agree to the millisecond.
`lease.d/` ABSENT; `scopes/` = `planner` ONLY; whole tree searched for `arcade|kev|model-test` = no match.

## R1 — the token pair cannot report this watcher's own subject, because its closed state is the subject's success signature

`kev_window` is `[ free -ge 4289 ]`. A successful Kev-4B acquisition therefore **consumes the very quantity that defines the token** and flips it to closed. Priced against live numbers:

| state | free | 4B admission (3800+256) | gate 4289 | token |
|---|---|---|---|---|
| window open (14:33, five reads) | 6131 | 4056 → admitted | +1842 | **open** |
| Kev resident (measured footprint 3737*) | ≈ **2394** | 4056 → **SHORT 1662** | −1895 | **closed** |
| planner 4B resident (this write) | 2624 | resident | −1665 | closed |

\* Kev's own co-residency run artifact `profiles/llama/model-trials/runs/coresidency_d1_kev.json` (2026-10-15 12:50:41, 851 B): `d1-3B` loaded → 3440 MiB free, `Kev-4B-Q4_K_M` loaded → 7177 used = **3737 MiB resident**. The 4289 gate is need+headroom, not the footprint; both are shown so the arithmetic does not rest on either alone.

So a resident Kev reads **`planner_at=planner kev_window=closed`** — character for character what a healthy resident planner reads — while free (~2394) is under *every* planner rung's admission price (smol 3000+256 = 3256, short 862; 4B 4056, short 1662; 9B 6456). `planner_at` is `[ -f record.json ]`, and the last refused 9B attempt leaves that file behind (this morning's ghost class), so the token pair would show a settled, closed, apparently-served card while the betting planner is locked out for as long as Kev holds.

**R1: the closed state is simultaneously the subject's success signature and the protected workload's outage signature; the pair cannot distinguish them, and cannot distinguish them by construction, not by bug.** The capacity half is already ruled (2026-10-14-a-window-that-only-opens-when-the-planner-is-down R1: co-residency with the planner's 4B/9B is arithmetically impossible on this card; cited, not restated). What is new here is the *instrument* consequence: the first successful Kev run will be recorded by this watcher as an ordinary close, and the only reads that can tell it apart are pid liveness + a resident compute app — which the watcher does not take. The precedence clause is therefore self-cancelling in the state it authorises: the one state where Kev may acquire is the state in which the planner can recover, and Kev's own footprint removes the planner's ability to recover. Fix proposed, NOT applied: qualify the token by residency (`kev_resident / planner_resident / none`) rather than by free alone — a token rewrite with the prompt bullet map, because a new token without a rule is a change nobody is told how to read.

## R2 — the window's width is admission arithmetic, and today it is the planner's longest outage

- **Open edge 14:30:32** — the 9B attempt `owner llama-swap-ocho-planner need 6200 pid 57470 DEAD acquired_at 1792445432` (record since overwritten; measured in the 14:33 filing), round 14:30:26 → exit status=1 at 14:30:33.
- **Close edge 15:30:29** — the 4B acquire above. Width **59 m 57 s**, the widest window this watcher has recorded on this boot, and it contains **six consecutive failed rounds**: 14:30:26→:33, 14:40:26→:33, 14:50:03→:09, 15:00:26→:33, 15:10:26→:32, 15:20:23→:30, every one `status=1/FAILURE` in 6–9 s (not OOM; admission refused), against the 15:30 round which loaded 4B in 10 s.
- Five of those samples were `no_change` (155 B: 14:47:25, 14:58:25, 15:09:25, 15:20:25 … one per round), so the entire hour is reported to the delivery path as its two edges only. Day total: **65 Finished / 29 status=1** on `ocho-planner-polymarket`.
- The window state was **not** spare capacity: free 6131 at 14:33 existed because no rung was resident, i.e. because the pipeline was failing. Read the token with which rung is ABSENT, never as a free number (2026-10-14 R1 again, applied).

## R3 — Kev did not run in an hour of gate-clear time: recorded as ABSENCE, not as a miss

No `arcade` / `kev` / `llama-model-test` lease exists anywhere under `gpu-lease/`; no kev process; `Kev-4B-Q4_K_M.gguf` still 2026-10-05 15:55:40 (3,033,489,824 B); newest kev artifact `model-trials/runs/coresidency_d1_kev.json` 2026-10-15 12:50:41 and `kev_run_bundle_full.json` 2026-10-12 22:41 — nothing written inside the window. His poll lane was up throughout (ticker heartbeat 1792449144 = 15:32:24, 40 s before my read; no reboot this boot). This is the **second** measured window under the precedence clause (the first, 13:30→13:50 = 20 min, is in 2026-10-19-a-fallback-that-fires-on-a-suppressed-tick-delivers-nothing); the gate has now been clear for ~80 minutes today in two blocks and been used for zero.

## Messages: none, each withheld for a measured reason

- **@ocho — withheld.** The diff is `kev_window`; `planner_at` is IDENTICAL on both sides. His scoped-planner item was confirmed and closed on the live channel **2026-10-13 17:22/17:25:42/17:28:53**; no delivery newer than 18:08. A true-but-redundant DM into a closed item is the drop hazard (18th stand-down of this class).
- **@llama — withheld.** The fallback clause is conditioned on the window being open *at the moment of sending*; at write free is **2624 MiB, 1665 under the gate**, so a page would be FALSE at his read across a ~27 min channel (2026-10-15-a-fallback-clause-that-cannot-fit-inside-the-window-it-watches). And per 2026-10-19-a-fallback-that-fires-on-a-suppressed-tick-delivers-nothing R1 the clause cannot execute on a suppressed sample anyway.

## Prediction for the next tick (published so it is an entry, not an event)

The window stays closed while the 4B holder lives; it reopens at the next round whose weighted pick is the 9B, because admission is 6456 against ~6131 free with the Bonsai floor present. **Falsifier:** a 9B round succeeding while `pid 2434` (1364 MiB, `--n-gpu-layers 0`) is resident.

## Touch log

Read-only throughout: nvidia-smi ×6 (three identical at write), two detector-consistent reads, `curl /health` + `/props`, `systemctl --user`/`journalctl --user` (planner + llama-swap), `ps`, `stat`, `sha256sum`, `find`, `grep`. No lease taken, no model loaded, no run triggered; `gpu-lease.sh`, `llama-swap.yaml` (mtime 10-12 12:11:41), the planner lease and the driver untouched; nothing written outside `governance/`. priorart.py run BEFORE this file existed (241 records; max weak 0.079 on 2026-10-10-a-discipline-that-lives-in-one-file, then 0.073/0.072/0.070/0.057/0.054, all read by eye — the family owns window capacity and instrument blindness, not the token closing on its own subject); check_index.py after.

**Flagged for Mike (not acted on):** the live betting slot `ocho-planner` (9B, 6200+256 = 6456) has been unpriced-out of the whole card by `pid 2434` since the 13:22 reset — free at an empty card is 6131, short 325 — so the pipeline burns 10-min rounds into HTTP 500s (29 today) and survives on the 4B fallback, which is exactly the state that keeps `kev_window` open and the Arcade gate clear ~2 GB. Stopping `pid 2434` restores ~7495 free and both problems at once. Second, per R1, the first successful Kev run will look to this watcher like a normal close.

RULINGFILE rulings/2026-10-19-a-token-that-closes-on-its-own-subjects-success.md
