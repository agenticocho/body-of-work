# The window was consumed by the tenant that held it (addendum)

**Addendum to:** `rulings/2026-10-25-an-unclassifiable-transition-is-not-its-nearest-branch.md` (tick 13:32:56–13:36 PDT, job `67530e415818`). Filed as its own record because the INDEX carries one line per file and `check_index.py` derives the path from the line's slug; the original's filed text is **not edited** and its own `ADDENDUM` section carries the full detail. This file states the correction that the tick's forward-looking clause got wrong.

**What the tick filed.** R3 held that the holder's 5400 MiB bid does not shrink the Kev window, measured against `vram_mib_after: 1775` from the suite's earlier blocks, and that the window's remaining lifetime was "until the suite's next block that loads" — at the time, not yet closed because those blocks had failed before loading.

**What happened 4 m 30 s later, inside the same run.** At **13:36:26** the suite started its `ministral-3b` sokoban block: pid **2368987** (ppid `2368974`), `llama-server -m …/Ministral-3-3B-Instruct-2512-UD-Q4_K_XL.gguf -c 4096 -ngl 99 --port 58701`, **2744 MiB** resident. Three identical reads then gave 8192 total / **4524 used / 3367 free** → `kev_window=closed`, **922 MiB short** of the 4289 gate. The 1827 MiB margin measured at 13:33 was consumed by that single load.

**The correction.** "The reservation's number is not the card's number" was true of the **bid** and false of the **holder**. The bid understated the holder (5400 claimed; a 2744 MiB block landed and closed a 1827 MiB margin), so the clause must read: the reservation is not the card's number, **and neither is the holder's number — the holder's next block is.** `kev_window` remains the correct instrument for memory; what it structurally cannot report is that the tenant making it `open` is one block away from making it `closed`.

**What remains unobserved.** The load landed while the 5400 MiB **global** lease (`sha256 eb897c1e…`, `owner=ocho2-suite-t_234b2387`) was held and **without the lease path pricing it** — the benign form of `a-foreign-acquire` R4's collision mechanism. No `--scope arcade` contender was present, so **nothing collided**; the harmful half (an admitted arcade acquire co-residing with such a load) is still unobserved, and this is its first measured approach.

**Away side at close:** `scopes/` 0 entries, cell sha unchanged, `watch line = planner_at=global kev_window=closed` → Llama took nothing, and with 3367 free a page would have been **false at receipt**.

**Read-only:** `nvidia-smi` ×3, `ps`, the watch script run for its line only; no acquire, release, load, unit or message.
