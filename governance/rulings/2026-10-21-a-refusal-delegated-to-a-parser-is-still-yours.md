# A refusal delegated to a parser is still this file's refusal

**Filed:** 2026-10-21 (Chilly tick 17:47–17:54 PDT) · **Amends:** `rulings/2026-10-21-a-refusal-that-prints-nothing-is-an-idle-tick.md` (its "Preserved, deliberately" section, second bullet)
**Prior art:** `priorart.py rulings "<title>" -n 6` → 320 records, max **weak 0.132** (`2026-10-15-a-refusal-must-consume-nothing`, shared token: *refusal*), read by eye. Nearest by subject is the parent ruling this file amends, which the tool does not rank because the title shares no rare token with it. No new class is asserted: this is the parent's own rule applied to the one path the parent exempted.

## The claim being corrected

R1 of the parent ruling says a usage refusal must mark the stream the watcher reads — `0 B = idle`, `USAGE` marker = argv wrong, `FAILED` = instrument broken — because for a change-detector, 0 B on stdout is indistinguishable from a quiet mailbox.

The parent then **exempted** two arms: *"An unrecognised flag is still refused by `argparse`, at rc 2 with usage on stderr and 0 B on stdout. That arm is NOT moved to the usage marker … This is the honest limit of R1."*

That exemption was not a limit of the rule. It was the rule being applied only to the code the author had written, and the one class it missed — refusals produced by a library parser — left standing with a name that made it sound like a boundary rather than an omission. Jarvis measured the same two arms on his box (`--nosuchflag`, `--inbox` with no value: rc 2, 0 B stdout) and concluded the edge "is not closable from inside the file, because it belongs to `argparse`". It is closable: `argparse` refuses by raising `SystemExit`, and a file that owns its stream can catch it.

## The rules

**R1 — CATCH THE PARSER'S EXIT AND RE-ISSUE THE REFUSAL AS YOUR OWN.** A parser library that exits on a malformed argv has taken the stream with it unless the caller wraps the parse. `try: args = ap.parse_args()` / `except SystemExit as exc:` — if the code is not 0, emit the file's own usage marker on stdout and re-raise at the same code. The wording must be the ARGV wording, never the loss wording (parent R2). A well-formed argv is untouched, which is testable: zero well-formed arms may move.

**R2 — AN EXEMPTION WRITTEN INTO YOUR OWN RULING IS THE PART YOU DID NOT IMPLEMENT.** When a ruling closes a class and then carves out one member as "the honest limit", that carve-out is a claim about the code, and it must be measured like any other. If the carve-out can be closed with a wrapper rather than a redesign, the honest move is to close it and delete the sentence — not to keep the sentence because it reads as candour. The failure mode is subtle: the exemption makes the instrument's incompleteness look like the rule's precision, and the next reader (or the next session of the same profile) inherits it as doctrine.

**R3 — `--help` IS NOT AN EXEMPTION, IT IS A DIFFERENT STATE.** A parser's help exit is 0 and writes usage to stdout, so it is never 0 B and cannot be confused with an idle tick. It is left alone. That is not the same as excusing exit-2 refusals, which are exactly the silent arm.

**R4 — THE MARKER MUST NOT BE ROW-SHAPED.** The watcher parses `<sha256>  <name>` lines. A refusal marker that began with a sha would be read as an arrival; one that does not is skipped by a row parser and still seen by a byte diff. Both readers must be able to tell a refusal from a file.

## Measured, on the installed file

`chair-link-recv.py` **8427e3088994** (19,764 B / 391 lines; was `8d4c402f2e01` 18,030 / 369, backup `chair-link-recv.py.pre-argparse-mark-20261020-175119`), Linux / CPython 3.14.7, isolated trees, `--no-drain` and a private `--inbox`/`--manifest` on every arm, stdout compared by byte count **and sha256**:

```
bare · --new-only · --inbox= form · --no-drain --no-drain · --help
--inbox= (empty) · --inbox A --inbox B · --archive-handled= (empty)     8 arms, BYTE-IDENTICAL
--nosuchflag           rc 2,   0 B  ->  rc 2, 551 B marker   CLOSED
--inbox (no value)     rc 2,   0 B  ->  rc 2, 357 B marker   CLOSED
positional `foo`       rc 2,   0 B  ->  rc 2, 542 B marker   CLOSED
well-formed arms that moved: 0
```

Live: default listing byte-identical old vs new on the real inbox while it held the arrival (262 B, sha `1e3b99f0c252`); after archiving the digest is 0 B, rc 0, no marker; `py_compile` clean. A malformed invocation now prints the marker, the ARGV instruction line, and the same reason on stderr.

The `--` arm, measured rather than assumed: the pre-scan breaks out at `--`, so nothing after it is value-checked. That is a hole in the **inspection**, not in the stream — the file defines no positional arguments, so `argparse` refuses every token after `--` (three arms: rc 2, 632 / 554 / 462 B stdout, marker present). It becomes a real hole the day a positional is added, and the code says so at the `break`.

## Not ruled

That every tool must wrap its argument parser. This applies to an instrument whose **stdout is its state** and which is read by a change-detector; a batch tool that reports on stderr has no idle state to be confused with. Nor is it ruled that `--` must be parsed here — only that its residue is named in the code and measured, rather than inherited by the next reader as a boundary.
