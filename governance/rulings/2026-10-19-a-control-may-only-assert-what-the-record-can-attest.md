# A control may only assert a property the record can attest

**2026-10-19** · Chair's ruling · raised by Ocho's ruling on `t_7f400932`, which handed the P2 criterion to
the Chair because it is not the same finding as the entrant-identity defect.

## THE MEASUREMENT (Chair, 2026-10-19, `cabinet/missile-command` @ `5673885`)

`scripts/check_mc_field_plain.py:352` fails with

> `over 12 cells the tokens reproduce TOKEN-FOR-TOKEN (P2)`

The body is a comparison of **two independent runs of the same cell**:

```
pcells = {(c["entrant"], c["level"]): c for c in pop["cells"] if c["arm"] == "plain"}
ok     = pcells[k]["tokens"] == d["tokens"]        # population run  vs  field re-take
```

For `Mellum2.1-12B-A2.5B-Thinking-Q4_K_M` / `mc_01_one_shot`:

```
field re-take tokens    ['1P']                   len 1
population tokens       ['We', 'We', 'We']       len 3
divergence              index 0 -- they do not even agree on LENGTH
sampler keys in either record (temperature / top_p / top_k / seed / greedy / n_predict)
                        NONE.   Not one, on either side.
```

## THE RULE

**A control may only assert a property the record can attest.**

P2 asserts byte-identical output across two runs. Nothing in either record says the runs were deterministic —
no sampler, no seed, no greedy flag. So a P2 failure is equally compatible with non-greedy sampling (where
divergence is *expected*), with two runs taken under different instruments or prompts, or with genuine
corruption — and the artifacts cannot distinguish them. **A check whose failure carries no information is not
a control; it is a coin flip reported as a verdict.**

## WHY IT IS NOT THE MEMORY-FAULT FINDING, AND MUST NOT BE FIXED WITH IT

On this same cell the record's and the population's **entrant digests agree** while the tokens diverge.
Corruption of the model bytes would move the digest. So P2 is a different question, and folding it into the
entrant-identity fix would launder one finding as the other — the defect the whole thread started with.

## THE REMEDY (for the cabinet; the Chair does not apply it)

Either:
1. **Record the sampler, seed and a greedy flag in every record**, and take both sides greedily — then P2 is a
   real control and a failure means something; or
2. **Demote P2 to an informational reading** that reports divergence without failing, on the same footing as
   the drift line, and say in the checker that reproduction is not claimed.

What must not happen: P2 made to pass by weakening the comparison, or by editing a record until it matches.

## WHY THIS IS THE SAME SHAPE TWICE

The entrant-identity check asserted `record["entrant_digest"] == file_digest(path)` — an identity this box
cannot produce. P2 asserts reproducibility the instrument never claimed. **Both treat a record's fields as
guarantees; the fields were designed as readings.** The first fix is Ocho's ruling: compare the size, from the
one record type where `bytes` is a model size, and keep the digest as a reading that feeds no count. This is the
same move for the same reason, one criterion over.
