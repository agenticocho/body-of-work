# A failure streak flips the window by rung admission, not by exit code

**Tick:** 2026-10-25 11:07:52–11:09:30 PDT, `arcade-window-watch`, job `67530e415818`
**Diff:** `planner_at=planner kev_window=closed` → `planner_at=planner kev_window=open` — `planner_at` **IDENTICAL both sides** ⇒ no global→planner branch, **no `@ocho` DM** (his scoped-planner item closed on the 2026-10-23 10:40 4B certificate; re-read closed in today's 10:20 row and unchanged here).
**Nature:** RECORD ONLY. No acquire, no release, no model load, no unit touched, no message. Llama is self-authorized at `--scope arcade` when free ≥ 4289 on his own continuous poll; this tick does not preempt him.
**Method:** every number below is a read taken this tick — `nvidia-smi` (three reads) + `--query-compute-apps`, `ps`, `ss`, `/proc`, `curl :8080/running` and `/v1/models`, `journalctl --user`, `/tmp/gpu-lease.*` captures (content + `stat` + `sha256sum`), `gpu-lease.sh status`, the lease tree, the cron sample dir and `monitor_last_output.txt`. Nothing recalled from a prior tick.

## 1. The bracket, and the one edge in it

| sample | value | mtime |
|---|---|---|
| `2026-10-25_10-24-12.md` (6135 B, the close filed at 10:20) | `… kev_window=closed` | 10:24 |
| `_10-34-52.md`, `_10-45-52.md`, `_10-56-52.md` (155 B, all `no_change`) | CLOSED (baseline carried) | 10:34 / 10:45 / 10:56 |
| `monitor_last_output.txt` (34 B) | `planner_at=planner kev_window=open` | **11:07:52** |

Edge in **(10:56:52, 11:07:52]**, dated by the writer to **11:00:08.091** (§2). Two readings bracket it and no sample sits inside it.
**No swallowed edge in this band.** After the 10:24 filing every sample today is a 155 B `no_change` with no `### Diff`, so today's 10:20 R1 replay rule (a provider outage destroyed seven edges earlier today) has nothing to replay here; the edges it recovered are already in the 10:20 row.

## 2. What opened it — one failed round that evicted and refused

Journal `ocho-planner-polymarket.service`, the two rounds inside the band:

| round | result | wall / CPU / peak | capture born |
|---|---|---|---|
| 10:50:04 → **10:50:13** | `status=1/FAILURE`, `Failed with result 'exit-code'` | 8.617 s / 3.185 s / 142.3 M | `/tmp/gpu-lease.fMngKx` **10:50:10.585** |
| 11:00:00 → **11:00:08** | `status=1/FAILURE`, `Failed with result 'exit-code'` | 7.905 s / 3.103 s / 142.0 M | **none** (newest capture is `fMngKx`, 10:50:10.585) |

- **The 10:50 round FAILED and still closed the card.** Its capture `fMngKx` 1642 B, `sha256 71481ac30382262448155c3037a8c8d584a914fda18681615dd9b7ee70b77190`, loads `SmolLM3-3B-128K-UD-Q4_K_XL` (`model loaded` at 0.00.758.313, listening `http://127.0.0.1:5808`), serves one task (2738 prompt tok @ 5041.62 tok/s, 106 eval @ 144.46 tok/s, `release n_tokens = 2843`), mtime 10:50:12.974 — and then **stays resident and idle**. That idle resident is the only thing that can make the 10:56:52 sample read CLOSED (a closed read requires used > 3903; the unleased aux floor is 1498).
- **The 11:00 round FAILED and opened it.** No capture was born in the 11:00 minute ⇒ it never exec'd a model; it evicted the smol and aborted (`llama-swap.log` last lines: `<ocho-planner-smol> Health check passed` → `non-200 … status=500` → `group: starting ocho-planner failed: aborted`). It left behind the cell: `scopes/planner/record.json` 492 B, ino 9964817, birth **11:00:08.091455053**, mtime 11:00:08.093455024, `sha256 3bca77bb705299c392414efff9a70a1f297d86c4021ce5d57dc4ba93b8061a50`, `owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 headroom=256 pid=2263887 mode=run acquired=1792951208 expires=1793037608 (2026-10-26T11:00:08) ttl=86400`. `pid 2263887` is **DEAD** (`/proc` absent, `ps` empty, absent from `--query-compute-apps`), and the cell is refused by its **own admission test**: 6200 + 256 = **6456 vs free 6198 = 258 MiB SHORT**.
- The smol is gone, measured three ways: `:8080/running` = `{"running":[]}`; `ss` has **nothing listening in 5800–5829**; `/v1/models` lists `ocho-planner-smol`, `ocho-planner-4b` and `brain`(alias `planner`) all `unloaded`.

## 3. The live card at write

| read (PDT) | total | used | free | util | temp |
|---|---|---|---|---|---|
| 11:07:56 / 11:08:1x / 11:08:52 — three identical reads | 8192 | 1693 | **6198** | 1 % | 39 C |

`--query-compute-apps` at write: **only** `pid 976745` 1364 MiB (Bonsai, `--n-gpu-layers 0`) + `pid 979586` 134 MiB (LFM2.5-VL, `--n-gpu-layers 0`) = **1498 MiB aux floor**, both unowned; + ~195 MiB driver = 1693; used+free **7891** vs 8192 = the standing **301 MiB** reservation.
⇒ **OPEN by 1909 MiB** over the Kev gate (4033 + 256 = 4289). `gpu-lease.sh status` agrees: global `lease.d/` **none held**, `scopes/` = planner only (the dead `pid=2263887`), no `arcade` / `kev` / `model-test` scope, lease, record or process (`grep -rliE 'arcade|kev|model-test'` over the state dir **rc 1**; `pgrep` none).
Two gates, one reading: Kev-4B 3800 + 256 = 4056 vs 6198 = **2142 MiB spare**, while the planner's own 9B is **258 MiB short** — `kev_window=open` says nothing about scarcity.

## Rulings

**R1 — Within one failure streak the exit code carries zero window information; the rung's admission decides the token.** 10:50 and 11:00 are the same round twice in every exit field — both `status=1/FAILURE`, 3.185 vs 3.103 s CPU, 142.3 vs 142.0 M peak — and they moved the window in **opposite directions ten minutes apart**: the 10:50 round's rung (smol) *fit*, so it loaded, served one task, failed its request and left an idle resident that held the card CLOSED; the 11:00 round's rung (9B, 6456 vs 6198 = 258 short) *could not fit*, so it evicted that resident, aborted, and left the card OPEN. This is `2026-10-21-a-failed-swap-evicts-before-it-refuses` R1 re-measured, and it upgrades `2026-10-24-an-eviction-inside-an-unsampled-band-opens-the-window-its-receipt-names-the-later-refusal` from *could have* to **did**: that filing had an 11-minute unsampled band and explicitly declined to assert which tenant held it ("which held it at 19:39:52 is NOT asserted"). Here the band is sampled — `_10-56-52.md` is a 155 B `no_change` on a CLOSED baseline, i.e. a direct read of the resident — and the only model load between 10:40:09 and 11:00:08 is the 10:50 smol capture, so the resident the 11:00:08 write removed is named by **elimination plus a reading**, not by admission arithmetic. Corollary for the operator: a failed round is not evidence of an empty card, and a successful round is not evidence of a filled one; occupancy is carried by the load, which the exit code cannot see.

**R2 — A CLOSED/OPEN pair bracketing one eviction yields a LOWER BOUND on the evicted footprint without knowing the model.** Closed at 10:56:52 ⇒ free < 4289 ⇒ used > 3903. Used at 11:08:52 = 1693. Therefore the removed resident supplied **> 2210 MiB** (3903 − 1693). This is derived entirely from two cron samples and one live `nvidia-smi`, and it is deliberately a floor rather than a memory: the "~2672 MiB smol" that appears in earlier filings is a number recalled from a prior tick, whereas 2210 is a reading anyone can re-derive from disk. Rule: cite a footprint as *bracketed floor* unless `--query-compute-apps` is holding the process at the moment of the claim; a footprint carried forward is a remembered number wearing a measurement's clothes.

**R3 — Eighth window today, and the closed band it ended was held by two retainers in succession.** Windows: 00:46–01:23, 01:49–02:49, 03:27–04:26, 05:15–06:15, 06:53–07:20, 07:47–08:47, 09:25–10:20 (all recovered from the provider-outage samples per today's 10:20 R1), and now **11:00:08 → still open at write** (≥ 9 m 21.9 s at 11:09:30). The band that closed was **2394.456 s = 39 m 54.5 s** (10:20:13.635 cell/child → 11:00:08.091) and it was held by **two** retainers: the 10:20 4B (capture `/tmp/gpu-lease.cSpE3f` 3271 B, last serve `task 223` at +19 m 55.6 s ≈ 10:40:09.403) and then the 10:50 smol. The handover is **invisible to the token** — it appears only as a new capture birth, never as a `kev_window` value, so a continuously CLOSED band may contain any number of swaps and the sample chain cannot date them. Width remains the failure streak, not availability anyone chose.

**R4 — At a 9B-refusal open edge the `planner_at` token is guaranteed to read `planner`, so the token is anti-correlated with the state it certifies.** The 492 B cell whose **existence alone** makes `arcade_window_watch.sh:28-35` print `planner_at=planner` is the same write that documents the refusal — born 0.09 s before the round's failure line, pid dead, no capture, no listener. So the freshest possible support for "a model is loaded under the scoped lease" is, at this edge, the receipt of a load that never happened, and the tick that reports the window open reports the lease held by the same artifact. This is instance **five** of `2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R1 and claims no new mechanism; what is worth writing down is the sharp form: **within a planner failure streak the token cannot read `none`**, because every refusal that opens the window rewrites the file the token is derived from.

## Away side (Llama)

`grep -rliE 'arcade|kev|model-test'` over `~/.local/state/gpu-lease` → **rc 1**, no match; `lease.d/` absent; `scopes/` = planner only; no `kev`/`model-test` process. **He took nothing** across the 39 m 54.5 s closed band or the 9 m 21.9 s open so far, including the earlier windows today that free VRAM would have admitted him to. His clock still beats — `profiles/llama/cron/ticker_heartbeat` 23 B mtime **11:07:51.125**, `ticker_last_success` 18 B 11:07:51.131 — over a directory with **no `jobs.json`** and `executions.db` 24576 B stopped at **2026-10-12 06:33**, i.e. a beat certifies a clock, not an evaluation. Flagged to Mike again, **not** a finding against him.

**Fallback not met:** this is the **first** open tick of this window; the `@llama` fallback is defined for a window that stays untaken across a couple of ticks. And he self-runs.

## Messages

**None sent, and none possible from this toolset** (re-measured, not assumed): `tool_search` for an agent-messaging tool returns no matches — deferred sources this run are `browser`, `computer_use`, `session_search`, `terminal`, `todo`. No `@ocho` (token identical both sides, his item closed), no `@llama` (first tick, self-authorized). Escalation channel is this delivery to Mike.

**Read-only throughout:** `nvidia-smi` ×3 + `--query-compute-apps`, `ps`, `ss -ltn`, `/proc` absence checks, `curl :8080/running` and `/v1/models`, `journalctl --user -u ocho-planner-polymarket.service`, `stat`/`sha256sum` on the cell and both captures, the lease tree, `gpu-lease.sh status`, the cron output dir and `monitor_last_output.txt`, `llama-swap.log` tail. `gpu-lease.sh`, `llama-swap.yaml`, the planner lease, the planner unit and every model **untouched**; the dead cell left in place under its own liveness-first reclaim policy.

**Prior art** printed by `priorart.py` on three phrasings BEFORE this file existed (**431 records**): 0.235 **REVIEW** `2026-10-14-a-window-that-only-opens-when-the-planner-is-down` (read; that is a *close* edge on a live 4B holder, the mirror case), 0.229 **REVIEW** `2026-10-23-a-pick-clock-dates-the-cell-when-no-capture-exists` (read; its pick-clock dating is the method reused here for the capture-less 11:00 round), 0.215 **REVIEW** `2026-10-21-a-failed-swap-evicts-before-it-refuses` (read in full; R1 is the mechanism this tick measures with a sampled band), 0.195 `2026-10-24-a-failed-rounds-duration-does-not-say-whether-it-evicted-a-resident` (extended: duration still cannot say it — the *sample* can), 0.188 `2026-10-20-a-window-open-with-no-planner-holder-is-the-one-that-fits`, 0.154 `2026-10-21-a-capture-birth-dates-its-load-and-its-mtime-its-last-serve` (used verbatim on `fMngKx`), 0.151 `2026-10-23-a-refused-pick-evicts-a-tenant-that-could-not-have-remedied-its-refusal`, 0.146 `2026-10-21-a-boundary-forecast-scores-on-which-refusal-evicted`. Also re-read to avoid re-filing: `2026-10-23-a-permanent-exclusion-is-a-live-margin-not-a-filed-number` R2 ("birth inside the band is the writer's identity in both modes and never the verdict") — it **already** carries the correction that a cell born inside its round does not prove a load, so that correction is not claimed as an increment here; and `2026-10-24-a-silent-release-failure-keeps-the-planner-latch` R1, extended as instance five without a new mechanism.
**Increment filed:** R1's same-exit-code/opposite-token pair with the sampled positive control that the unsampled-band filing lacked, R2's bracketed-floor measurement rule, R3's eighth window and the invisible two-retainer handover, R4's sharpened anti-correlation between the token and the state it certifies.

RULINGFILE rulings/2026-10-25-a-failure-streak-flips-the-window-by-rung-admission.md
