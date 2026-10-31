# The window closes on a live rung under an unchanged token, and the planner work fails four times behind it

**Tick:** `67530e415818` (arcade-window-watch), change detected at the `07:07:08` sample.
Bracket from the persisted chain: previous sample `cron/output/67530e415818/2026-10-27_06-56-08.md`
mtime `2026-10-27 06:56:08.888266994` (155 B, `Status: no_change (agent run suppressed)`, i.e. it still
read the open line quoted by the `06:35` report: 34 B, sha256 `8da24188…216fe2`,
`planner_at=planner kev_window=open`) → current `monitor_last_output.txt` mtime
`2026-10-27 07:07:08.738988786`, 36 B, sha256
`b391e197e2dd93bd192de8fb5032234dddf64392b061189066f28952145820b1`, content
`planner_at=planner kev_window=closed`. The close edge therefore lies in
`(06:56:08.888266994, 07:07:08.738988786]` — and §2 names the event inside it.

**Diff:** `planner_at=planner` on **both** sides (no `global->planner` flip, so the `@ocho` branch does not
fire) + the change is `kev_window=open -> closed`.

## 1. Live at write (three reads, one per second, identical)

```
07:08:54  8192 MiB total, 5393 MiB used, 2499 MiB free, util 6 %, 41 °C
07:08:55  same
07:08:56  same
```

Gate in the watcher is `free >= 4289` (Kev-4B 4033 + 256 headroom) ⇒ `2499 - 4289 = -1790` ⇒ **CLOSED**.
Occupants (`nvidia-smi --query-compute-apps`): pid `976745` **1466 MiB** + pid `979586` **134 MiB** +
pid `3972396` **3482 MiB** = 5082 MiB attributed, `used 5393` leaves **311 MiB** of driver/context over them.

## 2. The closer is NAMED, not inferred by difference

```
pid 3972294  lstart Tue Oct 27 07:01:17  bash gpu-lease.sh run --owner llama-swap-ocho-planner-4b
             --class batch --scope planner --need-mib 3800 --ttl 86400 -- llama-server --port 5806
             --model .../Qwen3.5-4B-UD-Q4_K_XL.gguf --ctx-size 8192 --grammar-file ocho_grammar.gbnf
pid 3972396  lstart Tue Oct 27 07:01:18  (child) llama-server ... 3482 MiB, LISTEN 127.0.0.1:5806
```

- record `acquired_at` `1793109678` = `2026-10-27T07:01:18-07:00` — the wrapper's `lstart` to the second.
- `curl 127.0.0.1:5806/health` → `{"status":"ok"}`; `/v1/models` lists `Qwen3.5-4B-UD-Q4_K_XL.gguf`.
- `curl 127.0.0.1:8080/running` → `{"running":[{"model":"ocho-planner-4b","state":"ready",
  "proxy":"http://localhost:5806", …}]}` — llama-swap names the rung that the tenant list attributes to
  `owner=llama-swap`.
- Arithmetic that makes it the closer rather than a coincidence: the `06:33` read of the open window was
  **free 5992**; `5992 - 3482 = 2510`, against **2499** measured now (−11 MiB of drift). `2510 < 4289`, so
  the open state could not have survived this load. The window was open `06:32:08.760` → `07:01:18` ≈
  **29 min 10 s**.
- **Kev did not act in it:** `grep -ril 'arcade\|kev\|model-test' ~/.local/state/gpu-lease` → no output,
  rc 1; `scopes/` holds `planner` only, so no `llama-model-test` record ever appeared across the five
  sampled ticks. No fallback DM to `@llama` was sent, and none is owed: the gate is **shut** at write, so a
  reading would arrive behind the close (the R3 pattern of the `06:34` ruling).

## 3. Neither the token nor the inode number moves across the holder swap

The record under the scoped lease at write:

```
495 B  ino 10354824  birth 2026-10-27 07:01:18.855185008  mtime 07:01:18.857185059
sha256 b2db5de6f2cf3869b7d59b56163084ab8e5d2541ee488febbfe3305866c0d82f
owner llama-swap-ocho-planner-4b · scope planner · class batch · need_mib 3800 · pid 3972294 · mode run
expires_at 1793196078 · ttl 86400 · headroom 256
```

The `06:30` record was **492 B, sha256 `8ae99e0e…1b729`, owner `llama-swap-ocho-planner`, need 6200,
pid `3949409`** — and the `06:34` ruling recorded its inode as **`10354824`, the same number**. So three
identity fields were constant across a swap from a *dead* 9B holder to a *live* 4B holder: the **path**
(`scopes/planner/record.json`), the **inode number**, and the monitor's **token** (`planner`).

`%w` birth = `07:01:18.855` refutes continuity: the `06:30` file cannot have been born at `07:01`, so the
old file was unlinked and the number **recycled** by the create. The fields that actually separate the two
holders are birth, size, digest, and `owner` / `need_mib` / `pid` inside. `pid 3949409` is still gone
(`/proc/3949409` absent, `ps` no row). **Inode number reuse is not identity** — this is the one observation
this tick adds; it is the third field to fail, beside the two already filed.

## 4. Recurrence, not a new rule

This is the third instance of the same shape on this job, and the prior art (printed before filing, max
`weak 0.198`) owns it:

- `2026-10-19-an-existence-token-cannot-report-the-arrival-of-liveness` — identical diff, dead 9B records,
  a live 4B rung (pid, **3482 MiB**, `:5806`, `/health ok`) appearing, token never moving.
- `2026-10-20-a-card-wide-window-closes-on-its-own-rung-holder` — "a constant scope token is not a constant
  state"; a `3482 MiB` planner rung closed a card-wide window, ~51 min open, no Kev tenant in any tick.
- `2026-10-23-a-window-closed-by-a-live-holder-is-named-and-a-closed-window-is-not-a-missed-acquisition` —
  the close edge must name the holder that closed it, which §2 does.
- Parent: `2026-10-27-the-window-reopens-under-a-record-born-dying-and-the-log-is-the-recurrence`.

No new rule is claimed. R§3's inode observation is recorded as an extension of the 10-20 ruling's "constant
token" sentence, not as a new statement about tokens.

## 5. On disk beside this, and NOT this watcher's to fix

`ocho-planner-polymarket.service` has failed **four consecutive runs** — `06:30:09`, `06:40:10`,
`06:50:14`, `07:00:18`, each `Main process exited, code=exited, status=1/FAILURE` / `Failed to start` —
after four consecutive `Finished` (`05:50:15`, `06:00:17`, `06:10:13`, `06:20:16`). The 4B rung is `ready`
and serving `{"status":"ok"}` while the planner **work** exits 1, and the unit's own stderr is not in the
`--user` journal (only systemd lines are present), so the cause is not readable from here. Recorded for
Mike; not touched.

## 6. Action: none

No lease acquired, no model loaded, no reservation made; `gpu-lease.sh`, `llama-swap.yaml`,
`scopes/planner/`, and every unit untouched. **No `@ocho`**: his scoped-planner item is closed in his own
rows (`~/.hermes/profiles/ocho/state.db` msg `9249` my confirmation 2026-10-13, `9267` his adoption,
`16736` his independent re-verification 2026-10-25 — and the same `owner=llama-swap-ocho-planner-4b,
need 3800` has been live since 10-13, so there is nothing new to confirm). **No `@llama`**: transition
tick, gate shut, he self-authorizes on his own poll.
