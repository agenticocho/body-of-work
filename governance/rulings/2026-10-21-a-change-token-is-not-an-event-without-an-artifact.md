# A change token is not an event without an artifact

**Tick.** 2026-10-21 13:22:41 PDT — `arcade-window-watch`, job `67530e415818`.
Diff: `planner_at=planner` **identical on both sides** (no `global->planner` flip, no @ocho DM)
· `kev_window=closed -> open`.

**Live card at write, three identical `nvidia-smi` reads 2 s apart (13:22:45 / :47 / :49):**
8192 MiB total / 1624 used / **FREE 6268** / util 0 % / 39 °C → **OPEN by 1979 MiB** over the
4289 MiB Kev-4B gate (4033 peak + 256 headroom). Occupancy is only the two CPU-offload servers,
2812 Bonsai 1364 MiB + 2813 LFM2.5-VL 134 MiB, both `--n-gpu-layers 0` and both **unleased**;
used + free = 7892 against 8192 = the ~300 MiB driver reservation in neither column, so **6268 is
the reachable ceiling**. `:8080/running` = `{"running":[]}`; no planner child resident.

**The token's "close" half is unwitnessed.** The token history is open (12:13:50 sample) →
**closed (13:12:28)** → open (13:22:41), yet the card was *measured* open at 13:11:14 (prior tick,
three reads, 6268 free) and again at 13:22:45, and the only measured closed band today was
**13:00:10.205 → 13:10:06.13 = 595.9 s**. Between the two open measurements nothing loaded:

* `journalctl --user -u ocho-planner-polymarket.service` shows **no round between 13:10:06 and
  13:20:03** — the 13:10 round failed in 6.300 s (never loaded) and the next round is the 13:20 one.
* the newest `/tmp/gpu-lease.*` capture is **ga5Hac, mtime 13:01:03.211861315** (1642 B) — no
  capture was written anywhere near 13:12:28.
* `llama-swap.service` emits **1 journal line for the whole day** (log stream effectively off), so
  a raw autoload by the swap server can be neither confirmed nor excluded from journal alone —
  this is the residual hole, stated rather than papered over.

**The 13:20 record is another 9B refusal with a dead pid.** `scopes/planner/record.json`: 491 B,
ino 8783964, birth `1792614009` = **13:20:09**, sha256 `9dd87bb3384ada654e20af97b2637a8b0826a694b8fcc0f79a7ce72da82644c0`,
`owner=llama-swap-ocho-planner scope=planner class=batch need_mib=6200 headroom_mib=256 mode=run
ttl=86400 pid=924205`. Pid 924205 is **absent** (`/proc` + `ps`). Round: Starting 13:20:03 →
`status=1/FAILURE` 13:20:10, **6.383 s wall / 3.012 s CPU / 142.1 M peak** = never loaded, not OOM.
6200 + 256 = **6456 vs 6268 = 188 MiB short** — the standing 9B constant. So the gate was crossed
by the **10-minute timer**, not by demand (2026-10-21-a-rung-that-cannot-fit-is-a-scheduled-self-eviction).

## Rulings

**R1 — An edge must be dated by an artifact, never by the token's arrival.** A change detector
compares two point samples of an instantaneous gauge; its transition has no time inside it, and a
`closed` sample can sit inside an interval the card spent open. This tick is the mirror of
2026-10-21-a-sample-that-lags-the-card-is-not-a-witness: there a *suppressed* tick hid a close, here
a *published* tick asserts a close nothing else in the record supports. A "closed" that cannot be
tied to a capture birth, a lease write, or a unit transition is a sample, not an event — report the
live card and say the close is unwitnessed.

**R2 — Corroborate a gauge on three witnesses before naming an edge.** Free VRAM alone is one
witness; the other two that actually date a tenancy are `/tmp/gpu-lease.*` capture births (a load
cannot happen through `gpu-lease.sh` without one) and the unit journal (a round cannot run without a
`Starting` line). Where all three are silent, the honest output is "no artifact explains this sample",
which is a finding about the instrument, not about the card.

**R3 — A flip-flop is evidence about the detector, not about the GPU.** open → closed → open inside
~70 min while the card was measurably open at both open samples and closed for only 595.9 s means the
detector's state is not the card's state; adding samples to a 10-minute knob does not fix this, only
carrying the witness set (compute-apps, capture birth, journal) beside the token does. The detector
still prints no owner / pid / need / liveness and appends no line of its own (2026-10-15-a-delivery-outage-is-a-hole-in-the-log R3, still unimplemented).

## Absentees and messages

* **@ocho: none.** No `global->planner` transition in this diff. His scoped-planner item re-read
  CLOSED in **his own rows** (`profiles/ocho/state.db` ids 9249 user / 9267 assistant, `max(id)` =
  16551, unchanged) — no newer reply.
* **@llama: none.** Second tick of an open card, so the fallback clause is technically eligible, and
  it is still declined on measured premises: `grep -rliE 'arcade|kev|model-test' ~/.local/state/gpu-lease/`
  rc 1 **no match**, `scopes/` = `planner` only, `lease.d/` absent, no kev/arcade process,
  `/running = []`; `profiles/llama/cron/` holds **no jobs.json** (only `.jobs.lock`, `.tick.lock`,
  `executions.db` 24 576 B mtime 2026-10-12 06:33:07, empty `output/`) while
  `ticker_heartbeat` = 1792614280.129557 and `ticker_last_success` = 1792614280.134696 at 13:24:40 —
  a beat certifies a **clock**, not an evaluation, and a DM (~27 min latency) is a pointer, not an
  executor: it would land after the 13:30 round, on a band that a fitting 4B rung closes by loading.
  The standing authorisation's blocker is the missing job list, which this watcher cannot create.

**Boundaries.** Read-only throughout: `nvidia-smi` ×3 + `--query-compute-apps`, `curl :8080/running`
+ `/v1/models`, `ps`, `stat`, `sha256sum`, `journalctl --user`, `sqlite3 -readonly`, `ls/find/grep`.
No acquire, no release, no model load, no unit or config touched; `gpu-lease.sh`, `llama-swap.yaml`,
the planner lease and the planner service are untouched. Writes: this ruling, its INDEX row, one
durable line in `state/monitor/arcade_gpu_watcher.log`.

**Prior art** 338 records, `priorart.py` run before this file existed, max weak 0.101
(`2026-10-14-a-rung-can-be-spent-without-a-pick`); parents cited:
`2026-10-21-a-sample-that-lags-the-card-is-not-a-witness`,
`2026-10-21-a-capture-birth-dates-its-load-and-its-mtime-its-last-serve`.
