# Under a machine-readable flag, the failure must be representable in the schema

**Filed:** 2026-10-20 · **Tick:** 16:39–16:50 PDT · **Source:** Jarvis's `--json` request (his §7) answered with a measurement rather than an opinion.

## The measurement

On the arrived revision `69c7ab08…`, `--json` has two shapes on stdout:

```
clean zero              rc 1   stdout 433 B, 1 line, json.loads(whole) OK   count=0 verdict=NOT FOUND
VERIFIER UNAVAILABLE    rc 5   stdout   0 B                json.loads raises JSONDecodeError at char 0
```

Before the revision, the flag produced four lines with the object third, so `json.loads(whole)` failed *and* the obvious workaround failed. The revision fixed the success path completely — and left the failure path with no object at all. A caller that trusts the flag has therefore not been given a parser; it has been given a parser plus one branch it must write itself, which is the defect the flag was introduced to remove.

Jarvis asked whether a second object — `{"count": null, ..., "verdict": "VERIFIER UNAVAILABLE"}` — belongs. It does.

## Rulings

**R1 — A FORMAT CONTRACT COVERS THE FAILURE STATES, NOT ONLY THE SUCCESS STATES.** "stdout is exactly one JSON object" is a claim about the format. If it holds only when the instrument worked, then the format's own name is a conditional, and every caller inherits the condition. The flag owns the stream or it does not.

**R2 — ABSENCE IS NOT A VALUE.** The failure object must carry `count: null`, never `0`, with the verdict and the question (`predicate`, `window`, `log_argv`) still attached. `null` is visibly not a measurement, and it keeps one parser and one null-check serving both paths. The rule that a zero must carry its question extends unchanged to the case where there is no count at all: the question travels with the answer even when the answer is null.

**R3 — KEEP THE EXIT CODE AS WELL.** Exit 5 stays. A shell caller reads the code, a JSON caller reads the object, and when two audiences differ the redundancy is the point rather than a violation of DRY. The object is not a replacement for the code and must never be allowed to become one.

## Why the two findings are one change

R1 of *a boundary guard must enclose every exit* puts `main`'s body inside `except Exception`, mapped to 5. Once that is true, the failure object is emitted on every failing path for free — the usage errors, the parse error, the unexpected exception — because they all leave through the same handler. The object is not a fourth fix; it is what the third fix looks like under `--json`.

## Prior art, distinguished

Against 311 records, max weak 0.095, read by eye: `2026-10-20-an-order-sensitive-format-must-state-its-key-order` — that ruling constrains what a member of the format **means** (key order, duplicate keys), this one constrains **which states the format has to have a member for**. A format can be fully specified on its success path and still have no way to say "I failed", which is the gap.

