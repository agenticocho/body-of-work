# Model trial harness

Procedure for comparing local GGUFs against a role (e.g. "best local coding agent
for Hermes") and returning a ranked result backed by real runs, not vibes.

## 1. Free the card first, and stop the respawner

A full-VRAM test needs the whole card. Confirm what is resident and free it
properly — killing a `llama-server` pid does nothing if a supervisor restarts it
(see **Freeing the card for a GPU test** in SKILL.md). Record every service you
stop so you can restore it when the trial ends.

## 2. Triage by placement before spending load time

Two placements, opposite sizing rules:

- **Full-VRAM ("runs completely on the GPU")**: weights + KV cache + compute
  buffer must all fit in VRAM. A model whose GGUF weights are within ~1-2 GiB of
  total VRAM is a hard fail — the KV cache and compute buffer have nowhere to go.
  Sort by file size and drop anything near the VRAM total *before* loading
  anything.
- **CPU-offload / RAM-resident**: size against total RAM with
  `override-tensor = ...=CPU`; VRAM is not the binding constraint. This is the
  default on a high-RAM box and needs no such triage.

Do not mix the two in one trial — they answer different questions.

## 3. Probe arch support before the full run

A load probe is one command per model and catches a build that cannot parse the
architecture, without paying for the full suite:

```bash
strings <model>.gguf | grep -m1 -A1 general.architecture   # arch string
# start llama-server --n-gpu-layers 999 --ctx-size <small>, poll /props, kill
```

If a model needs a newer llama.cpp than the one on the box, you find out here,
once, rather than as a mid-harness crash. Prefer the newest build available.

## 4. Harness shape: one server per model

For each surviving candidate, start its own `llama-server` (fixed ctx, full GPU
layers, `--jinja` for chat templating), then measure:

- **peak VRAM** (`nvidia-smi` while resident) — confirms the full-VRAM claim
- **generation + prompt tok/s** (from the response `timings`) — throughput
- **task outputs** saved raw to disk for qualitative review

Kill each server and let VRAM return to baseline before the next model.

## 5. Grade tool-calling separately from code quality

For an agent role, structured tool-call reliability is a gate, not a soft score.
For each probe, check the response `message.tool_calls`:

- did it emit `tool_calls` at all (vs answering in prose)?
- is the called tool the expected one?
- do the `arguments` parse as JSON?

Score it pass/fail per probe. A model that writes beautiful code but never emits
a well-formed tool call is a poor *agent*, and a raw quality score hides that.
Keep code-quality grading (correctness of the fix, soundness of the design) as a
separate human-reviewed axis over the saved raw outputs.

## 6. Dry-run the smallest model through the whole harness first

Run the full suite against the single smallest/fastest candidate before the batch.
A harness bug (wrong endpoint, unparseable grading, a server that never becomes
ready) costs one model-load to find instead of N. Then run all candidates and
write `summary.json` plus per-task raw outputs.

## 7. Check `finish_reason` before grading anything — the cap is an artifact

**A too-small `max_tokens` cap silently invalidates the whole trial.** A verbose
or thinking model returns `finish=length` with an empty *delivered* answer — it
spent its entire budget inside its reasoning block and produced no final text.
A naive harness grades that as "bad output" when the real defect is the cap, and
the ranking comes out backwards.

Rules that follow:

- **Read `finish_reason` and `completion_tokens` per response before grading.**
  `finish=length` with comp_tokens == cap means truncated, not answered. Treat
  those cells as ungraded, never as failures.
- **A dry-run that passes proves the harness, not the cap.** The smallest model
  completing within the budget says nothing about the most verbose one — raise
  the cap for any model whose comp_tokens approached it.
- **Re-run truncated tasks at a generous cap (e.g. 3000) and diff delivered
  answers.** This routinely reorders the ranking: the model that completed every
  task at a modest budget is often the best agent pick, while the deep reasoner
  that truncates costs latency on every turn.
- **Strip the thinking block by splitting on the CLOSE tag** — parse the actual
  tag names out of the content first
  (`re.findall(r'</?([a-zA-Z_][a-zA-Z0-9_-]*)>', c)`) and split on `</thinking>`,
  rather than pattern-matching an assumed tag shape. A missed close tag makes the
  raw reasoning dominate the text you grade, so a perfectly good final answer
  reads as empty.
- **Grade the delivered (post-thinking) answer, not raw content length.** A
  model that emits 2000 chars of reasoning and 300 of answer is not "worse" than
  one that emits 300 of answer.

## 8. Tooling pitfalls in the run itself

- **`systemctl --user stop <model-supervisor>` can SIGTERM your own shell
  (exit -15)** — the service teardown signals the process group you ran it in.
  The stop usually still landed; verify in a follow-up call with
  `systemctl --user is-active` plus `nvidia-smi --query-gpu=memory.free` rather
  than trusting the command's exit code.
- **`pkill -f "<port>"` / `pgrep -f <pattern>` match your own shell when the
  pattern occurs in the command line.** Killing a test server by a substring that
  also appears in the wrapping `bash -c` invocation SIGTERMs the shell mid-script
  (exit -15), so the release/cleanup that followed never runs. Target the server
  by exact binary path + port, or kill by recorded pid; then verify the process is
  gone and VRAM returned before the next step.
- **Inline `python3 -c` / `sh -c` is blocked on a plain-CLI single-query session**
  (no user present to approve a flagged command), even for a read-only parse. Put
  the logic in a `.py`/`.sh` file and run the file, or use `gh`/`jq`/`grep`
  directly; never retry the same inline form after a block.
- **A long run must be DETACHED from the agent's process group, or the agent's own
  lifecycle kill takes it mid-run.** Background jobs the agent starts die when
  their owning process exits: the tell is a run log whose *entire* content is
  `EXIT=143` (128+15 = SIGTERM) and no result file, because the runner wrote its
  JSON only at the end. Fix both halves:
  - **Detach it.** Launch via `systemd-run --user --unit=<name> --collect
    --working-directory=<dir> /path/to/python3 <harness>.py` — a transient user
    unit is outside the agent's process tree, so a desktop freeze, a session end,
    or a one-shot-exit linger timeout cannot reach it. Confirm with
    `systemctl --user is-active <name>`.
  - **Flush incrementally.** Write the partial result JSON after *every* trial
    (atomic: write `.tmp`, `os.replace`), with a provenance header (build, model
    sha, start/last-update, status). A kill then leaves a readable, resumable
    artifact instead of nothing, and you can resume by skipping completed cells.
    A per-arm flush leaves a whole arm unflushed — flush per trial.
  A single foreground acquire→run→release is still right for a SHORT run when free
  VRAM already clears the gate; it is wrong for anything that outlives one turn.
- **A poll-and-run that acquires a lease then loses its parent leaves the window
  gone and a stale lease behind** (see section 1).
- **An approval prompt that times out means the command did not run.** Do not
  retry it silently and do not drop the result quietly — report exactly which
  cells stayed ungraded so the user knows the ranking is partial.
## 9. Speculative decoding (draft model) is a decode/prefill trade, not a free win

When a candidate's draft model is present (e.g. `<MODEL>-DFlash-Q4_K_M.gguf`) it is
a **speed lever on the same weights**, not a new candidate — and the harness must
measure it as a trade:

- Enable with `--spec-draft-model <draft.gguf> --spec-type draft-dflash
  --spec-draft-n-max <N>` alongside the normal server flags.
- **Measure BOTH directions, ON vs OFF:** decode tok/s AND prefill tok/s — and
  sweep the prompt LENGTH, because one short prompt misprices the trade in both
  directions. A single 64-token prompt made DFlash look like +87% decode / −73%
  prefill; swept across 642 / 1130 / 1744-token prompts the penalty AMORTISES to
  ~−27% while the decode gain GROWS to ~+135%:

  | prompt | base prefill | dflash | Δ | base dec | dflash | Δ |
  |---|---|---|---|---|---|---|
  | 642 | 1956 | 760 | −61% | 64.4 | 98.4 | +53% |
  | 1130 | 2066 | 1492 | −28% | 62.1 | 144.4 | +133% |
  | 1744 | 2105 | 1533 | −27% | 62.9 | 147.9 | +135% |

  Baseline prefill also rises with length (670 → ~2100), so a short prompt is
  unrepresentative on BOTH sides. Quote the trade as a curve, never a bare
  "faster" and never off a single prompt.
- **A draft model imposes a CONTEXT CEILING well below the base model's window.**
  Base weights (~6.6 GiB) + draft (~0.8 GiB) leave no room on an 8 GB card for a
  long prefill's compute buffers: ctx 8192 and then 4096 both died with `CUDA error:
  out of memory` (`ggml_backend_cuda_graph_compute`) on prompts past ~2k tokens;
  ctx 3072 held. A DFlash speed win can cost most of the usable context — measure
  the ceiling before proposing DFlash for any agent path, and shrink `--ctx-size`
  (not the prompt) when it OOMs on a long input.
- **Sweep the draft length.** n-max 8 beat 3 on decode despite a *lower* token-
  acceptance rate (48% vs 84%) — acceptance rate is not the metric; net decode is.
- **A quality sanity probe per config** (a known deterministic answer) guards
  against reporting a speedup that corrupted output as a win.
- **A sampling/inference-path change must be safety-RE-MEASURED, not assumed.**
  DFlash measured no posture change (baseline 1/9 vs DFlash 1/9), but that was a
  measurement, not an assumption — any feature that touches sampling gets its own
  injection run, and a mere speed win does not retire the `--reasoning on` pin.
- **`content` is empty on a reasoning model at `finish=length`.** Compare arms on
  `reasoning_content` too, or a truncated thinking model reads as producing no
  output on every arm.

- **Several large models tied at an identical tok/s while smaller ones ran
  faster is a card-level cap, not model behavior.** When the throughput column
  clusters, say the number is soft and rank on task quality; verify with a
  control run before ranking on speed at all.
