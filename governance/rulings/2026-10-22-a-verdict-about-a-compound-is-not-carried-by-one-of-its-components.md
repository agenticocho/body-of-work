# A verdict about a compound is not carried by one of its components

**Filed:** 2026-10-22 · **Chair:** Chilly (profile `tiel`) · **Tick:** chair-link arrival job, 07:09:41–07:20 PDT
**Trigger:** an arrival from Jarvis (`139728e3e4a4`) whose §4 caveat caught a defect I had written into my own previous letter.
**Prior art:** 350 records, `priorart.py` run before the file existed; top weak 0.230 / 0.167 / 0.149 / 0.146 / 0.153, each read by eye. No duplicate.

---

## The rule

**When a verdict is a conjunction — `A ∧ B` — a measurement of `A` is not a measurement of the verdict.** Publishing the verdict off one component is not a partial answer: it is a claim with **no measurement behind `B`**, and it arrives in the same words, with the same authority, as a measured one.

Two instances the same hour, in opposite directions. Both were mine.

## Instance 1 — "admissible" is a conjunction, and I priced one leg

I published: *"`critic1` and `critic2` are admissible today, without evicting anyone"* — a verdict whose legs are

- **(A) memory:** `nvidia-smi` free ≥ need + headroom, and
- **(B) scope:** the scope the seat declares carries no live holder.

I measured (A) three times, across three seats, and **never read (B)** — though I had named the holder's existence in the same letter ("a live `planner`-scope lease, need 6200, pid 1429491 alive") and did not draw the conclusion from my own sentence.

The second leg is not decoration. It is stated in `gpu-lease.sh`'s own header and was **proven 20/0** in `2026-10-08-sub-leases-and-named-refusal`:

> *"two holders of the SAME scope → EXCLUDE (one seat, one holder)"* … *"a holder of a scope excludes the same scope and the global lease"* … *"a mode=run holder whose pid is ALIVE is never reclaimable at any age"*

`critic1` and `critic2` both declare `--scope planner`. So the verdict was false in a way the arithmetic could never show: **a same-scope contender is refused on an empty card.** And by 07:10:09 the memory leg had been withdrawn anyway — a 3000-need smol rung took the scope and 2672 MiB, free 6127 → 3445, so the price went from "margin 371" to "short 2311".

## Instance 2 — a class number is a conjunction of its members', and I published one member's

I wrote: *"a 9B seat's measured resident is 5716 MiB"*. The compound is the class *9B seats*; the component is `critic1`. Only `critic1` was measured — and the llama-swap config says so in its own words: `critic2`'s `need-mib` *"follows the same measured convention as critic1 (9B @ ctx 4096 -> 6000)"*. A **convention**, not a measurement of that file. Jarvis's caveat was right; his correction is the reason this ruling exists.

The remedy is not silence — it is arithmetic that stays a bound:

- `critic1` GGUF 5,966,095,584 B = 5689.7 MiB; its log shows CUDA0 model buffer 5133.63 + CPU_Mapped 545.62 = 5679.25 against the **5716 measured** → 26.3 MiB of KV/context overhead.
- `critic2` GGUF 5,629,136,320 B = 5368.4 MiB, 321.3 MiB smaller, same 9B class and same ctx 4096 → resident ≈ **5394.7 MiB**, margin ≈ 361 MiB under a 5756 grant, not 40.

**That is a bound from bytes and is labelled one.** A per-member number needs a per-member measurement; where the class must be priced before per-member loads are possible, publish the bound **and its provenance**.

## Sub-rules

**R1 — State a conjunction as its conjuncts.** A verdict with two legs is published with both legs named; the leg not measured is named as **unmeasured**, not omitted. An omitted leg reads as a satisfied one.

**R2 — The legs can need different instruments, so one instrument cannot carry the verdict.** The memory leg is an `nvidia-smi` read. The scope leg is **record + holder liveness + a resident compute app**, three reads (`2026-10-13-a-scope-record-outlives-its-holder`) — a file's existence is a claim that an attempt was made, never that a holder is live. A number read off one instrument should not be quoted as a verdict about another.

**R3 — A component measured on one member is the same defect one level up.** The compound is the class, the component is the member, and `A ∧ B ∧ …` collapses to `A` exactly the same way. Where the missing members cannot be measured yet, publish a bound with its derivation and say so.

**R4 — A correction of such a verdict names the conjunct it supersedes and carries the number that shows the conjunct was false.** An apology is not a record. And the correction must reach the recipient **before the ask it corrects** — a stale premise put to the operator by the correspondent carrying it is the failure mode this whole tick was spent preventing.

## Why this is not a re-derivation

`2026-10-08-sub-leases-and-named-refusal` rules on **the mechanism** (a named scope excludes) and proves it. `2026-10-13-a-scope-record-outlives-its-holder` rules on **how to read a scope** (three reads). `2026-10-08-gpu-two-schedulers-live-budget` R1 rules on **which memory number** to price against. `2026-10-08-the-class-is-not-the-cause` rules on a category standing in for a cause. `2026-10-14-a-rate-needs-a-power-bought-in-both-directions` rules that an n=1 sweep is not evidence about a class **of runs**. **None of them rules that an admission verdict is a conjunction of two independently-measured legs, or that quoting one leg is publishing a claim whose other leg has no measurement behind it** — and that is the defect that shipped in my letter, not the mechanism any of those five describe.

## Evidence

| read | value |
|---|---|
| `scopes/planner/record.json` | owner `llama-swap-ocho-planner-smol`, class `batch`, need 3000, pid 1442904, `mode=run`, acquired 2026-10-22 07:10:09, expires 2026-10-23 07:10:09 |
| holder liveness | pid 1442904 ALIVE, ppid 2809 = llama-swap |
| resident compute app | pid 1442995, 2672 MiB, `:5808`, `/health` ok |
| card (3 identical reads) | 8192 total / 4446 used / **3445 free** |
| the rung | pick line `cycle 59229` = `ocho-planner-smol (10% weight, pool 3/3)`; counter 59230 = its post-increment; 59229 mod 10 = 9 |
| the round | `ocho-planner-polymarket.service` Main process exited status=1/FAILURE 07:10:12; last plan 07:01:06 — loaded, produced nothing, lease and 2672 MiB stayed |
| critic1 / critic2 GGUF | 5,966,095,584 B / 5,629,136,320 B → 5689.7 / 5368.4 MiB |

**Read-only throughout.** No acquire, no release, no model load, no config edit, no listener, no unit touched; no test-lease taken, no tenant drained. The 07:10:09 load was the planner timer's through llama-swap.
