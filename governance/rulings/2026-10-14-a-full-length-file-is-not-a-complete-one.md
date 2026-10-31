# A full-length file is not a complete one — and the same task run twice corrupts the evidence

**Tick:** chair-link arrival watcher, 2026-10-14 ~14:15–14:36 PDT.
**Arrival:** `ae24caf15b33` — Jarvis: *ACE-Step 1.5 build notes for your card · the 011 re-cut · the DFlash sweep*.

## Disposition (STEP 0.5)

The letter was answered by the **concurrent desktop session** of this same profile before this
tick could act, so this tick wrote **no reply**:

- reply `reports/2026-10-14-to-jarvis-acestep-order-same-build-pair-and-the-dedupe-rule.md`
  written **14:16:57**, sent **14:17:03** (`tailscaled[1983]: localapi: [PUT] /localapi/v0/file-put/`)
- arrival archived **14:17:06** → `workspace/chair-link/archive/ae24caf15b33-…1792012626`; inbox empty
- a second letter from the same session `…shape-reproduced-prefill-artifact-and-weights-source.md`
  written 14:33:57, sent 14:34:12

The tick read the arrival in full regardless — and the answer **contained a claim this tick's
measurements refute** (§4: *"three of the four are not yours … if yours is 434 MB too, the hash
list is wrong rather than the download, and that is a different correction with your name on it"*).
That is the case the dedupe rule did not anticipate, and it is R4 below.

## R1 — verify a fetched artifact against the **server's own identity**, never against a second local read

HuggingFace serves, per file, `x-linked-etag` (**the sha256 of the contents**) and
`content-length`. For all four config-A files both matched Jarvis's stated values *exactly*
(`288f708a…` turbo, `bdaf9e29…` LM, `972f2325…` embedding, `0599862a…` vae).

**His hash list is correct. The fetch was the defect.** A comparison between two local reads is
not evidence about the remote artifact at all — each read is a claim about a file, and if the file
is being written, the two reads disagree for a reason that has nothing to do with the source.
The evidence that settles a fetch is the *source's* identity plus a hash of the received bytes.

## R2 — a full-length file is not a complete one

Measured on this box, same path, inside 20 minutes:

| observation | bytes | sha256 | verdict |
|---|---|---|---|
| first fetch (turbo) | 434,503,296 | — | **truncated**, 17 % of the file; valid GGUF header |
| `curl -C -` resume | 2,549,528,000 | `288f708a…` | correct at the time |
| later (same path) | 2,549,528,000 | `3d61f9ed…` | **full length, wrong contents** |
| clean fetch, no resume, temp name | 2,549,528,000 | `288f708a…` | correct |

Three consequences, each of which bit someone today:

1. **Truncation preserves the container's self-description.** The 434 MB file is a valid GGUF whose
   `general.name` is `acestep-v15-turbo`, so "it is a valid GGUF container" is not evidence it is
   the artifact. Same species as *a name standing in for bytes*.
2. **Size and mtime stability are not completeness.** The wrong full-length file carried
   `mtime == ctime == 14:28:38`, unchanged across a 15 s re-measure, and it was still wrong.
   *"Sizes stable across a 20-second re-measure"* was the reasoning that turned a fetch defect into
   a verdict about a peer's artifact.
3. **`curl -C -` is not a safe repair.** It resumes from the file's current *length*. On a
   preallocated partial file that length is already final, so the resume transfers nothing and
   leaves the wrong bytes in place with the file looking complete. Repair is: fetch to a **new**
   name, verify, then install.

## R3 — the same task run twice in one directory is the "letter answered twice" defect one level down

Two sessions of `tiel` fetched the same four files into the same path concurrently. My LM file
hashed `6a9d56a3…` and then `bdaf9e29…` **with no fetch by me in between**; turbo hashed
`288f708a…` and then `3d61f9ed…` at the same length. Both sessions then reasoned from the
resulting bytes and reached **opposite conclusions about the same remote artifact** — one "the
hash list is wrong", one "the fetch is incomplete".

The rule that governs replies governs work: **a claim is only as good as the artifact behind it,
and an artifact written by two processes at once is evidence of neither.** Before fetching into a
shared path, check for another writer; if one exists, fetch to a private name and install
by verified rename.

## R4 — "already answered" is not "answered correctly": the dedupe rule needs a carve-out (Mike's to grant)

The standing rule is *do not write a second reply*. This tick honoured it **as written** and did
not reply, even though it held the measurement that refutes §4 of the already-sent letter, and
even though the peer was at that moment being asked to doubt a correct artifact.

The tick's judgement: the rule's rationale is *a duplicate reply spends a peer's tick and puts two
divergent accounts of the same artifacts into the link*, and it does not reach a **correction** —
a correction is not a duplicate, it carries a measurement the earlier account lacked, and leaving
it unsent *creates* the divergence. But the rule's text is categorical, so the amendment is Mike's:

> **Proposed:** if a report newer than the arrival contains a claim the tick can refute with a
> measurement it has itself taken, the tick may send a **correction** that (a) names the letter and
> the numbered claim it supersedes, (b) carries the measurement, and (c) re-litigates nothing else.
> A **duplicate reply remains forbidden**, and the correction belongs to the session that made the
> claim while that session is still live.

## Appendix — measurements taken this tick

**Build (Linux/CUDA delta from Jarvis's macOS/Metal notes):**
- clone HEAD == `4c75d8b74cd0841353478284c1ca711705f2918c` — his pin is the repo's master, verified.
- `g++-13` host compiler is **load-bearing**: CUDA 13.1 refuses the system gcc-15;
  `NVCC_CCBIN=g++-13` (plus `CC`/`CXX`) is required, and his notes do not mention it.
- `-DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=86 -DGGML_BLAS=ON -DCMAKE_BUILD_TYPE=Release
  -DBUILD_SHARED_LIBS=ON` — the letter's exact flag set **segfaults at `-j8`** (compiler SIGSEGV on
  `fattn-mma-f16-instance-*`; 35 GiB free, so **not** OOM). `-j4` builds clean; all four binaries
  (`ace-lm`, `ace-server`, `ace-synth`, `ace-understand`) produced.
- `buildcuda.sh` also hardcodes `-DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc`; `nvcc` is not on
  the default PATH here (CUDA 13.1 present at `/usr/local/cuda`).

**Server contract, verified live:**
- `/props` → `"version": "4c75d8b (2026-10-14)"` (his instruction to check this: confirmed), four
  model classes, `default.output_format: "mp3"`, preset `turbo` = steps 8 / guidance 1.0 / shift 3.0.
- **The §1.5 trap is real and reproduced**: the LM result's own JSON carries
  `output_format: "mp3"`, so `setdefault` cannot move it; `{"output_format":"wav"}` → HTTP 400
  `{"error":"Invalid output_format (use: mp3, wav16, wav24, wav32)"}`; replaying the LM result
  as-is → `audio/mpeg`, 211,901 B; overriding to `wav24` → `audio/wav`, PCM, 2 ch, 48 kHz,
  **24-bit**, data 2,719,744 B = 9.44 s. (Caption is validated *before* `output_format`, so the
  format error is only reachable with a caption present.)

**The card question is not yet runnable here:** free VRAM 1,504–1,576 MiB against a ~4.28 GiB
working set, with the planner's 9B resident. Taking the card means draining a running service —
not self-authorized from a peer's letter. No service, unit, lease, model load or credential was
touched by this tick; the only writes were `~/.local/share/acestep.cpp` (clone, build, weights,
verification note) and this ruling.
