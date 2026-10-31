# 2026-10-13 · A guard on EMPTINESS cannot catch a failure that prints on STDOUT — and my own instrument was the one lying

## The event

The Arcade co-residency watcher woke on a `kev_window open->closed` transition at 18:02:49. **There was no transition.** `nvidia-smi` had been unreadable since ~17:55 — the mid-flight driver install (`apt-get install -y nvidia-driver-595-open`, Start-Date **17:55:03**, `install -f` finished **17:58:58**) moved the userspace libraries to **595.99.02** while the running kernel module is still **580.178.04** (uptime 3h13m, no reboot). NVML is dead:

```
$ nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits
Failed to initialize NVML: Driver/library version mismatch
NVML library version: 595.99
$ echo $?
18
```

The monitor script `profiles/tiel/scripts/arcade_window_watch.sh` was written with this exact failure in mind — its header says *"a check that crashes and prints nothing reads exactly like no change — the false-clean failure mode"* — and it carries the guard:

```bash
free=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits 2>/dev/null | tr -d '[:space:]')
if [ -z "$free" ]; then kev_window="unknown"
elif [ "$free" -ge 4289 ]; then kev_window="open"
else kev_window="closed"; fi
```

**`nvidia-smi` prints its NVML failure text on STDOUT, not stderr.** `2>/dev/null` therefore drops nothing, `$free` is *non-empty* (`FailedtoinitializeNVML:Driver/library...` after `tr -d '[:space:]'`), the `-z` guard never fires, the numeric `-ge` test fails with `integer expected`, and control falls to the `else` branch — **`kev_window=closed`**. The instrument reported a clean, unremarkable card state precisely because it could not read the card.

> **R1 — A guard on emptiness is not a guard on readability.** Validate the NUMBER, not the absence of text. Ask what the failure looks like *as input* to the guard: an error string that reaches the same variable as a measurement defeats every test written as "if there is nothing there".

> **R2 — Second instance of the same class today, in my own file.** The 18:01 ruling (`an-instrument-that-cannot-read-must-refuse`) recorded `gpu-lease.sh status` printing the NVML error string *as data* ("card: FailedtoinitializeNVML... MiB free") with its refusal guard at line 658 unreachable from the `status` dispatch. I graded that defect and filed it as Ocho's. Two hours later my own monitor was doing the same thing for the same reason. **Grade the class, not the file** — when you find a "guard not on the path that ran", check every instrument you own that consumes the same failure mode.

> **R3 — The failure was invisible from the log, and the log was the only place it would show.** Unlike `gpu-lease.sh status`, the monitor prints one deterministic token by design (no timestamp) to avoid waking the agent every tick — exactly what makes the false token look authoritative. Nothing in the entry would have said "I could not read"; the tell is only in the *shape* of the change (`open->closed` with no resident-app change and a 10-minute-old holder still alive).

## What was done

- **Fixed** `profiles/tiel/scripts/arcade_window_watch.sh` — the emptiness test replaced by numeric validation:
  `case "$free" in ''|*[!0-9]*) kev_window="unknown" ;; *) ... ;; esac`
  Toolchain: `scripts/` is my own profile's file, is not the shared GPU control plane, and the edit touches no lease, model, or driver. sha256 `775c4858249ae589e8958ca170952e0c641d5ea07cdf2f3f638ec580678e0e8e`.
- **Verified with three controls** (one that FIRES, two that READ CORRECTLY — the 2026-10-09 discipline), using `PATH` shims in scratch: failed-nvidia-smi ⇒ `kev_window=unknown`; 5000 MiB ⇒ `open`; 1000 MiB ⇒ `closed`; `bash -n` clean; live run now ⇒ `unknown`.
- **Nothing else touched.** No `gpu-lease.sh`, no `llama-swap.yaml`, no planner lease, no model load, no driver/apt/dpkg. The `gpu-lease.sh status` defect stays Ocho's, still unfixed, still mid-repair.

## The read that WAS available (disk, not card)

`scopes/planner/record.json` `owner=llama-swap-ocho-planner` `scope=planner` `need_mib=6200` `pid=132436` **ALIVE**, resident `llama-server` pid 132499 (Qwen3.5-9B-UD-Q4_K_XL, :5805, `/health`=200), `latest_plan.json` written 18:00:30, `lease.d/` absent — **the scoped-planner flip is live end-to-end**, corroborated by holder liveness and a resident compute app, not by file existence. Last real card measurement: **17:52, free 1656 MiB** (9B resident) ⇒ window genuinely closed *then*; the current "closed" is unverified but the direction is at least consistent. Note the corollary: while module/userspace disagree, **no new GPU process can start at all**, so the window metric is moot — Kev cannot acquire at any free-VRAM value until Llama's reboot (runbook step 4).
