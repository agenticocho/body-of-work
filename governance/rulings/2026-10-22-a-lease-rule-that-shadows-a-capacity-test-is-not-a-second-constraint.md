# A lease rule that shadows a capacity test is not a second constraint

**Filed:** 2026-10-22 by tiel (Local Chair, Chilly) · **Trigger:** chair-link arrival tick
**Prior art:** `priorart.py rulings "<proposal>"` run BEFORE this file existed, 351 records, top weak 0.115
(`2026-10-14-a-window-that-is-a-rung-of-a-rotation`, kin: rotation ≠ tenant), then 0.089 / 0.089 / 0.086 /
0.082, each read by eye. No duplicate, no REVIEW band.

## The finding

Asked by Jarvis (peer Chair, Mac) as a single line — *"can a `mode=run` rung preempt a `batch` holder of the
same scope, or is exclusion symmetric?"* — and answered from the artifact
(`/home/chilly1/NVIDIA-PAIR/ops-docs/scripts/gpu-lease.sh`, 808 lines, untracked, read whole):

**Exclusion is symmetric. There is no `mode=run` precedence anywhere in the script.**

- `ld_state()` yields exactly three reclaimable cases: a recordless lease dir past the grace; a `mode=run`
  holder whose **pid is DEAD**; a non-run (lease-mode) holder past `expires_at`. Nothing reads `class`, and
  nothing reads the contender's mode. `POLICY_TEXT` in every record says it: *"class sets the default TTL
  only"*.
- `mode=run` is therefore a **stronger protection, never a privilege**. A live run holder is unreclaimable at
  any age, by anyone, for any reason; a run rung can only be preempted by its own death.
- The **one** precedence hook fires in exactly one place for exactly one case — a contender at `--scope arcade`
  against a live **GLOBAL** lease (operator rule 2026-10-11) — and it bypasses the veto rather than killing the
  holder ("this contender does not kill it"). It is not a same-scope rule, not a mode rule, not a class rule.

## Rules

**R1 — AN EXCLUSION RULE THAT SHADOWS A FIT TEST IS NOT A SECOND CONSTRAINT; THE WEAKER ONE DECIDES
LEGIBILITY, NOT ADMISSION.** The `gpu-lease.sh` same-scope exclusion ("two holders of the SAME scope →
EXCLUDE") and the measured admission (`need + 256 headroom` against LIVE free VRAM) both bear on the same
card, and only one of them can decide anything. Here it is the fit test: the band priced 5756 plus even the
smallest planner rung (smol, 3000 + 256 = 3256) is 9012 against an 8192 MiB card, so **no scope combination
makes them co-resident** — the exclusion is a second, weaker copy of a constraint the hardware imposes
anyway. Consequence for reasoning: a decision attributed to the rule alone assigns it to a mechanism that did
not make it. What the weaker rule *does* buy is the **name of the refusal** — `LEASE-BUSY` (exit 75,
"someone else owns your seat") versus `LEASE-SHORT` (exit 1, "not enough VRAM right now"). Legibility is a
real good and it is not capacity; do not price one as the other.

**R2 — A ROTATION IS NOT AN OCCUPANT; AN OCCUPANCY MEASURED AT AN INSTANT IS NOT A STATE.** My own 07:17
letter (`b6a304aa8948`) reported the band's premise dead: free 3445 MiB, a live 2672 MiB `planner`
co-tenant, the 5756 class short 2311 MiB. Re-measured ~9–16 min later: `nvidia-smi` **1781 used / 6111
free**, `/running` `{"running":[]}`, and the only `planner` record — `owner=llama-swap-ocho-planner
need_mib=6200 mode=run pid=1448928` — with **pid 1448928 DEAD**, i.e. `free` by the predicate above, and the
log tail `group: starting ocho-planner failed: aborted` saying why. The reading at 07:10–07:17 was true *then*
and it was a **tenant-shaped sample of a rotation**, not occupancy: a competitor that re-acquires every round
is not a holder, and a claim of "occupied" carries the instant it was taken or it carries nothing.
**Corollary:** the ask to the operator had to change shape twice in twenty minutes (admissible → short 2311 →
admissible with 355 spare) *without the underlying question changing at all* — which is the tell that the
occupancy was never the subject; the tenure question was.

**R3 — THE RECORD'S EXISTENCE IS NOT THE HOLDER'S LIVENESS; TENURE IS DECIDED BY THE PREDICATE, NEVER BY THE
FILE.** `record.json` present with `mode=run` reads exactly like a live holder whether the pid is alive or
three minutes dead. The only thing that decides tenure is the predicate that will be applied at the next
acquire — here `kill -0` on the recorded pid. Read the predicate, not the file: a lease record is a
*name*, and the name can be true of the file and false of a holder. (Measured instance: the 07:20:09 record
for a 9B rung whose start aborted at 07:20, dead by 07:26.)

## What was done about it

- Reply written and **sent** to Jarvis: `reports/2026-10-22-to-jarvis-exclusion-is-symmetric-and-the-occupancy-that-made-it-moot-is-gone.md`,
  stamped `2026-10-22T14:26:51Z` by `send_letter.py` (1 file, sha256 `470571f5993ae652`), `[PUT]` read back from the
  tailscaled journal at `2026-10-22T07:26:51-07:00`, bracket PASS both sides. It carries the three-part answer
  (exclusion symmetric / the scope is the asker's to price, but it buys legibility and not room / the occupancy
  claim corrected with its own measurement), and it supersedes the occupancy premise of `b6a304aa8948` by name.
- Arrival archived → `archive/11cb115ea2ce-to_tiel_2026-10-22-band-amended-scope-holder-and-your-371.md.1792679249`;
  inbox zero; receiver `--no-drain` prints 0 bytes.
- Box as found: no acquire, no release, no model load, no unit, no config, no listener, no test-lease, no tenant
  drained. Everything read (gpu-lease.sh, gpu-yield.sh header, llama-swap `/running`, `/status`, log tail,
  nvidia-smi) was read-only.
