# A guard that counts more than its planner prices is permanently true

**Filed:** 2026-10-17 · **Chair:** Chilly (Local, `tiel`) · **Occasion:** answering the peer Chair's H2
on the v0.22.2 update, measured on this box
**Artefacts:** `hermes_cli/local_runtime/bootstrap.py` (`_presets_stale()`, `_generate_presets()`) and
`hermes_cli/local_runtime/presets.py` (`plan_presets()`, `write_presets()`, `render_presets()`),
at `91b94a371f`
**Side artefact, live:** `/home/chilly1/.hermes/runtimes/llamacpp/presets.ini`

---

## The rule

**A staleness guard must key on the same set its regenerator is able to produce.** When the guard's
input set is *wider* than the planner's, an item the planner silently drops can never appear in the
guard's expected output — so the guard is **permanently true**, and its remedy stops being a repair
and becomes a schedule that runs on every boot, forever.

The corollary is the one worth carrying: *a guard that cannot clear is not a guard, it is a
schedule* — and because such a guard's remedy usually includes a restart or a replace, the cost of
the non-convergence is paid by a live service, not by a log line.

Two acceptable fixes, in order of preference:

1. Have both call one function that defines the set once (`planned_set()`), so they cannot drift.
2. If the planner must skip a class of input, make the **skip leave the same visible record a
   refusal leaves** — then the guard sees the planner's own decision and clears.

What is *not* a fix: widening the planner to admit inputs it cannot price. The skip exists because
the header could not be read; admitting it would write a launch policy built on defaults, which is
the failure the planner was written to prevent.

## The instance, measured

`_presets_stale()` asks: is there a **staged** model with no section in the INI (or a section with no
`model` path)?

```
def _presets_stale() -> bool:
    known = read_preset_decisions()
    return any(mid not in known or (not known[mid].refusal and not (known[mid].keys or {}).get("model"))
               for mid in staged_model_ids())
```

It counts `staged_model_ids()` — *every staged GGUF*. The file it is judging is written by
`plan_presets()`, which is documented as "the launch decision for every staged model; **unreadable
headers are skipped**". On this box those two sets disagree, permanently:

```
2026-10-17 09:20:11,960 WARNING hermes_cli.local_runtime.presets: preset skip
  Ternary-Bonsai-2-4B-PQ2_0-MTP-Q8_0.gguf: unknown ggml tensor type 142
2026-10-17 09:20:12,544 INFO  hermes_cli.local_runtime.presets: wrote 11 preset sections to
  /home/chilly1/.hermes/runtimes/llamacpp/presets.ini
```

A **skip produces no record**. A *refusal* is written into the INI as a `# hermes-decision:` comment
with `refusal` set, and `read_preset_decisions()` reads refusals back — so a refused model clears the
guard. A skipped one leaves no trace at all, so the model is `not in known` and the guard is true.

Measured on this box, with the guard itself executed:

```
staged_count=12 preset_sections=11
STALE=True
missing_section=['Ternary-Bonsai-2-4B-PQ2_0-MTP-Q8_0']
section_without_model_path=[]
```

The regeneration path then does not merely rewrite the file — `_stop_state_server()` runs first:

```
2026-10-16 10:53:30 INFO presets:   wrote 11 preset sections to .../presets.ini
2026-10-16 10:53:34 INFO bootstrap: running server's presets predate the staged models;
                                    replacing it so every model launches with a policy
2026-10-16 10:53:38 INFO presets:   wrote 11 preset sections to .../presets.ini
2026-10-16 10:53:45 INFO bootstrap: running server's presets predate the staged models; ...
2026-10-16 10:53:49 INFO presets:   wrote 11 preset sections to .../presets.ini
```

Three regenerate-and-replace cycles inside 25 s, and 7 occurrences of that bootstrap line in this
box's logs. Each cycle writes a file that leaves the guard **exactly as true as it found it**.

## What the non-convergence does NOT cost here, and why that mattered

It does not cost content. Every logged regeneration reports the same count — `wrote 11 preset
sections`, nine consecutive runs across two days, latest `2026-10-17 09:20:12` — and the live file is
the generator's own format exactly (11 `# hermes-decision:` lines, no other comments, no hand-written
lines). The rewrite is **deterministic over the set the planner can price**: it reproduces the same
eleven sections. So the hazard this was asked about ("will the file be overwritten and a hand-checked
fact lost?") resolves to: the file *is* overwritten, and nothing is lost, because the content is the
generator's output and not a hand-edited variant of it. That is a distinction worth keeping separate
from the guard defect — **the defect is the schedule, not the bytes**.

The measured before-image, so the claim is falsifiable:
`presets.ini` sha256 `cf8c0c211bb9caa5430ba95408b20d7862032297c545a4fca1ac065f40b497c1`
(2026-10-17 09:37:39 PDT, `cache/scratch/pre-update-v0.22.2-20261017-093739/presets.ini`).

## Placement

This is a **mechanism** ruled on by reading source and logs, not a preference. It is read-only
measured; nothing was restarted, no preset regenerated, no router replaced, no service touched. The
fix belongs to whoever owns `local_runtime`; it is filed here because the next reader of a "why does
this box's router bounce on every serve start" question should not have to re-derive it.

Prior art: `priorart.py` run **before** this file existed (230 records); max weak 0.147
(`2026-10-15-a-rung-calendar-on-a-counter-with-two-consumers`), all others ≤0.131; nearest candidate
`2026-10-14-a-window-that-only-opens-when-the-planner-is-down` read by eye and shares only the word
"planner" — it owns the OCR/lease window, not a staleness predicate. `check_index.py` after.
