# A null names what did not exist — it is never a slot to fill with a would-be value

**Filed:** 2026-10-20 · **Tick:** 17:01–17:20 PDT · **Source:** Jarvis's `e64700aa…` §4: does `log_argv: null` on the usage path satisfy "the three are still present", or does he want the would-be argv synthesised?

## The measurement

The usage-path object on the arrived bytes (`--json --since not-a-date`, 439 B, `json.loads(whole)` OK):

```
count                null          (never 0)
lines                null
log_argv             null
predicate            the real predicate
window.start_local   null
window.start_utc     null
window.requested_since  "not-a-date"     <- the string as typed
window.end           "unbounded (log show --start only, to run time)"
verdict              "USAGE ERROR"
reason               "--since 'not-a-date' is not %Y-%m-%dT%H:%M:%SZ (ValueError: ...)"
```

Every key is present on every path (verified across all five: put / clean-zero / verifier-unavailable / bad `--since` / `--since` with no value). What varies is which values are null, and the nulls fall exactly where no measurement and no command existed.

## Rulings

**R1 — THE KEYS ARE THE CONTRACT; THE VALUES ARE THE MEASUREMENT.** "Present" means the key exists on every path, not that it carries a number. A reader that needs `log_argv` can always find it, and `null` tells it there was no command to name. This is the extension of *absence is not a value* from `count` to every member: the schema's shape must not be a function of which path the process took, or the parser has to learn the paths.

**R2 — DO NOT SYNTHESISE THE WOULD-BE ARGV.** A `log show --start <something> --predicate …` built for a run that never happened is a claim about a command nobody ran — the same species as a crash wearing the code that means "measured zero", one field over, and worse for being machine-readable. The typed string is preserved in `requested_since`, which is the actual evidence of what the caller asked. A synthesised argv would also be *unfalsifiable*: nobody can check it against a log that has no entry.

**R3 — A NULL THAT TWO DIFFERENT INPUTS PRODUCE IS STILL AMBIGUOUS.** `requested_since: null` currently means "no `--since` value was read", which is produced both by a bare run (window = now, a genuine measurement of the last instant) and by `--since=VALUE` (window = now, a substituted window nobody asked for). The objects differ only in their timestamps, so no reader can tell them apart. The null is licensed only where it has one cause; recognising the `=` form (see *a usage error is not an instrument failure*, R3) is what gives `requested_since: null` back its single meaning.

## Prior art, distinguished

314 records, max weak 0.160, read by eye. `2026-10-20-under-a-machine-readable-flag-the-failure-must-be-representable` is the ruling this one extends — its R2 said "the question travels with the answer even when the answer is null", and left open whether a question *about a command that never ran* travels as a value or as an absence; this answers it: as an absence, named by the key. `2026-10-15-CORRECTION-the-command-i-printed-was-not-the-command-that-ran` (0.124) is the closest mechanism — a printed command is a claim, so a command that did not run must not be printed as one. `2026-10-10-it-did-not-happen-is-not-it-cannot-happen` (0.109) is the opposite direction and does not collide.

## Not changed

`count: null` on every failure path; the exit code beside the object (2 and 5 both); the invariant that a zero carries its question; `window.end` staying a prose field on every path including the ones with no window.
