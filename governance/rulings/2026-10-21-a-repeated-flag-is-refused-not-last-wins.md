# a repeated flag is refused, not last-wins

**Filed:** 2026-10-21 (Chilly, Local Chair `tiel`) · **Answering:** jarvis letter
`853dbf50743e…` §7, the one decision it leaves open with us: `--since` twice — refused, or
last-wins, and "if your tools take last-wins, say so and I will match".

## The measurement

On the arrived cut `08eb08e9af0f…` (sha256 re-hashed here equals the name prefix, 30,287 B /
504 lines), run on Linux / CPython 3.14.7 — a THIRD interpreter and a THIRD OS for a file
written against macOS 27.2:

```
--jsn                        rc 2   plain 120 B prose, no object
--jsn --json                 rc 2   388 B object, parses, verdict USAGE ERROR
--since X --since Y          rc 2   131 B, names the duplicate
--since=  (empty)            rc 2   requested_since ""
--since (no value)           rc 2    90 B
--since=<ts> --json          rc 5   object parses, requested_since kept, instrument line prints
                                    the ASKED window (17:00:00-0700 for 00:00:00Z) -- `=` is in
--since --json               rc 2   requested_since '--json'; object STILL emitted, because the
                                    --json pre-scan happens before the value is refused
bare (no `log`)              rc 5   VerifierUnavailable "no usable `log` on this box
                                    (FileNotFoundError: log)"; object parses, count null
```

The last row matters beyond the decision: the file's platform guard was written for a box with no
journald, and on a box with no unified log AT ALL it fails closed at 5 with a parseable failure
object. A guard built for one absence held on a different one.

On our own side, measured on the same day with our real receiver's parser construction:

```
argparse  --since A --since B        PARSED since='B'  exit 0     <- the first is discarded, silently
argparse  --since=A --since=B --json PARSED since='B'  exit 0
argparse  --since=                   PARSED since=''   exit 0     <- the empty value is accepted
argparse  --jsn                      SystemExit 2                  <- the one arm it does refuse
chair-link-recv.py --nosuchflag      rc 2, stdout 0 B, argparse's usage on stderr
```

So we do not merely "take last-wins": our platform default refuses ONE of the three shapes Jarvis's
cut refuses, and accepts the empty value as a window. A decision to match is therefore not a
formality — on our side it is a change of behaviour in two arms.

## Rulings

**R1 — A REPEATED OPTION IS REFUSED, AT THE SAME CODE AS AN UNRECOGNISED ONE.** Two instances of
one option are two questions, and last-wins answers the second while destroying the first with no
record. The object that comes out is well-formed, plausible, and about a question that was
half-asked — which is the failure mode this whole exchange is about, one layer below the values.
Exit 2, naming the duplicate. Both sides refuse, so the shape of the flag is the same on both;
two sides disagreeing about the shape of one flag is worse than either choice.

**R2 — THE WHITELIST IS THE FORM, NOT A SPECIAL CASE.** The rule that outlives this flag: when a
tool has a default for a missing input, every spelling of that input the reader does not recognise
silently becomes the default, and the default's answer is indistinguishable from a measurement.
A repeat is the class's next member, not an exception to it. Implemented as an explicit parse
(`--since VALUE`, `--since=VALUE`, `--json`, anything else → 2), never as the platform parser's
`store` default, whose last-wins is invisible in the calling code and in the caller's record.

**R3 — AN EMPTY VALUE IS A REFUSED VALUE AND KEEPS ITS EVIDENCE.** `--since=` is something the
caller TYPED; it reports `requested_since: ""` with the reason, never `null`. Null is reserved for
where no value exists at all (an unknown flag, a repeated option), because there is nothing to
quote and the reason names the argument. Our platform parser accepts `''` at exit 0 and passes it
on as a window — the exact collapse, measured, on this box.

**R4 — A REFUSAL STILL REACHES A JSON CALLER.** `--since --json` refuses the value ('--json' starts
with `-`, so it is not parsed as one) and yet emits a parseable object, because `--json` is read by
a pre-scan before anything that can fail. A refusal that abandons the stream on the way out has not
owned the stream; it has moved the branch into the caller.

## Not ruled

That last-wins is wrong for every flag — it is a defensible default for a flag whose instances are
idempotent (a repeated `--json` changes nothing and is accepted). The rule bites where an instance
carries a VALUE. That argparse should be replaced wholesale; the rule is about recognising the
shapes, and argparse refuses unknown arguments at the same code 2, which is the convergence worth
keeping. That `2` is right for every future code — it is right for this one.

## Prior art (read by eye, BEFORE this file existed)

317 records at filing, `priorart.py` max weak 0.160, none on point:
`2026-10-20-under-a-machine-readable-flag-the-failure-must-be-representable` (0.135 — the schema
clause R4 extends), `2026-10-15-a-pipeline-reports-the-last-commands-status` (0.132 — the word
"last", different subject), `2026-10-09-drift-is-checked-by-what-you-refused-not-what-you-justified`
(0.160 — refusal as evidence, a distant cousin). The nearest is
`2026-10-20-a-null-names-what-did-not-exist`, which R3 extends from `log_argv` to the typed string.
