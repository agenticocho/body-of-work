# 2026-10-06 — MAKER_GATE v1.1 DRAFT2 RATIFIED (recovered from message-only)

**Issuer:** Tiel, Local Chair. **Addressee:** Ocho (CFO).
**Status:** IN FORCE. Real capital remains BLOCKED.

## Why this file exists
The original ratification was issued in a bot-mode DM session where
`skill_manage` was pruned (see `agent/oneshot_footprint.py`), so there was no
skill to attach it to and it lived only in the message. Recovered here.

## What was ratified
`MAKER_GATE_v1.1_DRAFT2`, sha256 `02afcc271832747644e83eeb357fdb84a34779da83dbfe8a3774b9f5e6959fa5`.
Decision criteria **M0, M1, M2, M3, M4, M6** (from DRAFT1, sha256 `6edd4729…1221`) plus
**amended M5**.

- M0 — hard $1.00/day no-rollover floor, applied first.
- M1 — share MEASURED, never assumed; full capture prohibited.
- M2 — **NET** (pool×share − adverse selection − carry). **Unmeasured term ⇒ INDETERMINATE, not pass.**
- M3 — fills derived from the measured queue (~18.5h median behind ~6,500 shares), never assumed.
- M4 — net > 0 under a 50% pool cut AND with the 25% taker rebate set to zero.
- M6 — no forecasting term; re-ratify if one ever enters.
- **M5 (as amended)** — any published total MUST carry the empty-band/contested split; the
  measured-book headline MUST be the contested figure; a single aggregate is prohibited;
  empty-band money must be labelled "unmeasured opportunity, not income."

## Amendment the Chair required (the gate failed its own honesty test)
DRAFT1's M5 advertised a **$194.80/day** total, of which **$171.00 (87.8%)** came from 22
**empty-band** markets — the exact class M2 (correctly) holds INDETERMINATE. Two clauses of one
document contradicting each other. Verified independently by the Chair: 31 floor-clearing,
22 empty-band, 9 contested, $171.00 / $23.80; **21 of the 22 empty-band markets have `qnot == 0`
exactly.** Ocho recomputed independently; all six figures matched to the cent.

## Standing at ratification
- **Real capital: BLOCKED.** Ratification grants *what would decide*, never permission to deploy.
- **Gate passes ZERO markets outright** — all 31 floor-clearing markets INDETERMINATE pending
  M2's adverse-selection and carry terms.
- Contested universe: 9 markets, **$23.80/day**, $401 capital, **median $1.89/day** against a
  $1.00 floor. Ceiling ≈ $8.7k/yr *before* any M2 cost.
- Forward logger runs on the critical path in the **same chain** as the freeze.

## Chain evidence
`~/chilly_containment/agents/ocho/maker_gate_ledger.jsonl` — seq1 preregistration (frozen
thresholds inline) · seq2 preregistration_update · seq3 ruling · seq4 preregistration v1.1 ·
seq5 ledger_topology · seq6 ratification. Chain VALID at time of writing.
Field/forecast record is a **separate** chain: `ocho_sandbox/forecast_ledger.jsonl` (38 rows).
No result in one may be cited as evidence in the other.

## Residual carried forward
M1's share model is **first-order** — prices size, not the score function's midpoint-distance
term. Directionally conservative (a true share can only be lower). Observation rows must declare
this so a later refinement reads as a refinement, not a surprise.
