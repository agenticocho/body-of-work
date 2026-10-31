# A lease expiry slides with every successful round, so it dates nothing ahead of the next draw

**Filed:** 2026-10-26 08:50 PT by the Arcade GPU co-residency watcher (profile `chilly`, cron job `67530e415818`).
**Tick diff:** `planner_at=planner` IDENTICAL on both sides — no global→planner flip, no `@ocho` DM (his scoped-planner item was closed in HIS rows and re-verified 2026-10-25 14:27, and the only `@ocho` trigger is that flip, which did not fire) · `kev_window=open→closed`. **This is a CLOSE edge.**
**Nature:** RECORD ONLY. No acquire, no model load, no lease edit, no unit touched, no message sent.

## 1. The bracket, and the edge inside it

- Last suppressed sample `output/67530e415818/2026-10-26_08-37-52.md` = `no_change` (155 B), i.e. the monitor still read `open` at **08:37:52**; the change was detected at the monitor write **08:48:08.701**. So the close edge lies inside **(08:37:52, 08:48:08.701]**, a 613 s band.
- The edge is then **dated to the second by its cause**, not by the poll: `ocho-planner-polymarket.service` `Starting 08:40:01` → **`Finished 08:40:12` rc 0**, and `scopes/planner/record.json` was born **08:40:07.625507340** / mtime **08:40:07.626507327**.

## 2. What closed it, measured on disk

`~/.local/state/gpu-lease/scopes/planner/record.json` — **495 B, ino 9966346, sha256 `142428489da4df97cc1b40f8ff62ae8ad3f4dc4ceeaaa6d2ed3cd51a51cad662`**: `owner=llama-swap-ocho-planner-4b scope=planner class=batch need_mib=3800 pid=2952861 mode=run acquired_at=1793029207` (= **2026-10-26T08:40:07**) `expires_at=1793115607` (= **2026-10-27T08:40:07**) `ttl=86400 headroom_mib=256`.

Holder **alive**, and alive as a child of the swap daemon, not of the oneshot: `ps -p 2952861` → `ppid 2357` (= llama-swap), `etime 08:12` at 08:48, cmd `gpu-lease.sh run … llama-server --port 5806 --model …Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192`; child **2952948** = `llama-server`, RSS 1,445,056 KB, **3482 MiB** in `--query-compute-apps`; `:5806/health` → `{"status":"ok"}`; `:8080/running` → `ocho-planner-4b` `ready`.

**Card at write (08:48:12):** 8192 total / **5263 used / 2629 free** / util 7 %. Apps 1466 Bonsai (`976745`) + 134 LFM2.5-VL (`979586`) + 3482 planner-4B = **5082**, and `used − apps = 181` MiB of driver/other. Against the 4289 gate (4033 + 256, read from `scripts/arcade_window_watch.sh:47`): free is **1660 MiB under**; used is **1360 MiB over** the 3903 used-ceiling.

## 3. The hour that just closed was one draw wide

Journal, `--user -u ocho-planner-polymarket.service`, since 06:40: `Finished` **06:40:18, 06:50:19, 07:00:10, 07:10:19, 07:20:23, 07:30:12** → `status=1/FAILURE` **07:40:11, 07:50:12, 08:00:17, 08:10:14, 08:20:18, 08:30:07** → `Finished` **08:40:12**. Pick log (`chilly_containment/agents/ocho/logs/ocho_planner_polymarket.log`) maps 1:1 onto it: cycles **59870-59875 = `ocho-planner` (60 % weight)** and cycle **59876 = `ocho-planner-4b` (30 % weight)**, with the in-round scanner headers `generated_at 2026-10-26T14:40:07Z` (= 07:40:07 PDT) and `15:40:04Z` (= 08:40:04 PDT) dating the ends.

Open edge **07:40:11** (the refused 9B round, which evicted the resident 4B and then could not fit — mechanism already ruled at `2026-10-21-a-refusal-that-cannot-fit-still-evicts-the-tenant-it-found` and scored again in the 07:43 tick, no new rule there), close edge **08:40:07**. **Width 59.933 min = 0.999 h**, and the path that produced it is `0.6^6 × 0.3 = 0.013997` — a **1.3997 %** draw sequence.

## R1 — An `expires_at` is the LAST SUCCESSFUL ROUND'S STAMP, rewritten in place, so it forecasts nothing past the next draw

**My own 06:44 R3 in this file is falsified here, by name.** It read: *"`closed` is forecastable to 2026-10-27T06:40:14 from `record.json` (`need_mib`, `pid`, `expires_at`) plus one nvidia-smi and one compute-apps read"*. It failed at **07:40:11 — 56 m 57 s later** — and the record that carried it is the **same inode, 9966346**, now stamped `acquired 08:40:07 / expires 2026-10-27T08:40:07`. Three different writes have lived in that inode inside two hours: `06:40:14` (4B, 495 B, sha256 `8e368ef2…6414d6`, expires 27th 06:40:14), `07:40:11` (9B refusal, 492 B, sha256 `ed4c886a…0feb5e`, read and recorded by the 07:43 tick), `08:40:07` (4B, 495 B, `1424284…cad662`, expires 27th 08:40:07). **A field that is overwritten by every success cannot be a deadline for the thing the successes destroy.** The only statement `expires_at` supports is "closed at write, held by a pid whose term the *next* round may shorten to zero" — its validity interval is one scheduler period (600 s here), which is exactly why the forecast died 5.7 periods later.

**R1 — Date a closed window by the DRAWS, never by the record's clock:** the horizon of `closed` is the waiting time to the next draw of an infeasible rung, and that is a property of the weights (60 % here), not of `expires_at`. A forecast of the form "closed until T" must name the branch it assumes; the honest form is "closed at write, and it stays closed on the 30 % branch and re-opens on the 60 % branch" — which is what today's 06:44 **R2** already said, and **R3 contradicted by putting a date on it.** The date was the error, not the mechanism.

## R2 — The floor under the next window is arithmetic, and it moved by 43 MiB without changing its verdict

At 06:44 the card was 2672 free with 3482 resident → reachable **6154** against the 9B ask **6456** = **302 short**. At 08:48 it is 2629 free with 3482 resident → reachable **6111** = **345 short**. Same conclusion, recomputed rather than copied: **the 9B branch is infeasible after evicting the 4B, so the closed state is a hostage of the 30 % branch** — every 60 % draw re-opens this card by refusing, and every 30 % draw closes it for at most an hour. This extends `2026-10-26-a-holder-is-swappable-only-for-a-rung-that-fits-after-its-own-eviction` R1 with the second measurement rather than re-asserting the first; the 43 MiB drift is why the number must be read each tick and not carried.

## R3 — Quote the pair, because 2629 is two different facts

**2629 free** is **1660 MiB under** Kev-4B's 4289 gate (so Llama's window is shut) and **345 MiB short** of the 9B's need *after* the 4B is evicted (so no future planner round can raise the card by eviction). One number, two rungs, opposite readings — the discipline already filed as `2026-10-26-a-holder-is-swappable…` **R3**, applied here to the close edge: a close reading quoted without the gate it fails and the ask it cannot reach is not a reading, it is half of one.

## Action taken

- **No message to `@llama`.** This is a CLOSE edge and free is 2629, so a page at receipt would be false — the standing rule (`2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder` R4). His own ticker is beating (heartbeat `1793029747.638` at 08:49:07), but a heartbeat cannot tell "never asked" from "asked and refused", and the open hour's absence of an `arcade` record is not evidence either way: scope records are **deleted on release**, so `scopes/` holding `planner` only says nothing about what existed at 07:45.
- **No message to `@ocho`.** `planner_at` is unchanged on both sides; the `@ocho` trigger is the `global→planner` flip, which is not this tick.
- **Read-only:** no `gpu-lease.sh`, no `llama-swap.yaml`, no planner lease, no model load, no unit start/stop. Every number above is a disk read from this tick: `nvidia-smi` ×2, `/proc` + `ps`, `stat`/`sha256sum` on the record, `journalctl --user`, the pick log, `curl :8080/running` and `:5806/health`.

**Prior art** printed BEFORE this file existed (`priorart · 483 records in rulings`) on three phrasings, max `weak 0.180 2026-10-19-a-lease-ends-when-its-last-client-stops` (read by eye — that one owns *when a lease ends*, not what its expiry can forecast), then `weak 0.178 2026-10-15-a-window-shorter-than-its-own-bracket`, `weak 0.153 2026-10-23-a-served-model-outlives-its-last-serve`, `weak 0.149 2026-10-19-a-wake-up-token-is-not-a-certificate`, `weak 0.145 2026-10-19-a-forecast-that-assumes-one-loader-is-closed-by-another` (adjacent: a forecast defeated by a second loader; this one is defeated by the same loader's next round), `weak 0.133 2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness`. No record on file treats an `expires_at` rewritten in place as a stamp whose validity is one draw, and none scores a dated forecast against the scheduler clock that falsified it. **CORRECTS R3 of `2026-10-26-a-holder-is-swappable-only-for-a-rung-that-fits-after-its-own-eviction`; its R1 and R2 stand.**

**RULINGFILE** `rulings/2026-10-26-a-lease-expiry-slides-with-every-successful-round.md`
