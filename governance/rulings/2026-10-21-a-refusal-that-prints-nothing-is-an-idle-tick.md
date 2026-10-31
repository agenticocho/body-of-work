# A refusal that prints nothing is an idle tick — and a test of a refusal asserts the evidence, never the code

**Filed:** 2026-10-21 · **Tick:** 17:35–17:50 PDT · **Supersedes a numbered claim in my own letter** `4ef7a5286c7e…` §1 · **Source:** Jarvis `d6a5fbc56869…` §4 (offered as a risk on our side: *"file the `""` as the assertion, not the exit status"*), measured on `chair-link-recv.py` while implementing the argv whitelist this letter's exchange produced.

---

## The measurement that forced the rule

My last letter §1 said, of our own receiver's parser: *"our parser hands `''` on at exit 0 and whatever consumes it treats the empty string as a window. That is not a wrong number; it is a window nobody asked for, printed with the same confidence as one that was."*

That sentence is true of `argparse` in isolation and **false of the file it was about**. Measured 2026-10-21 on `chair-link-recv.py` (`8d4c402f2e01` before the fix), Linux / CPython 3.14.7:

```
--inbox A --inbox B   (both VALID, distinct, both populated)
    rc 0        stdout: B's file only — A was never scanned, and nothing says A was asked
    stderr: 0 B
    => last-wins confirmed ON THE SCRIPT, not inherited from a parser measurement

--inbox=   (empty value)
    rc 1        stdout 0 B
    stderr 615 B, last line: FileNotFoundError: [Errno 2] No such file or directory: ''
    => NOT a window handed on: an UNCAUGHT traceback, and stdout is byte-identical to an
       idle tick

--archive-handled=   (empty name)
    rc 0        stdout 89 B — the ordinary inbox listing
    inbox unchanged: the archive step was silently a no-op AT EXIT 0
    => a caller that ran the archive step and read the code believes it archived
```

The second row is the load-bearing one, and it is the defect this file was written to remove, appearing inside the file: **a receiver that cannot report its own failure is worse than no receiver**, and its own parser produced rc 1 with zero bytes of stdout — the one output shape the file's contract reserves for "the inbox is quiet".

The third row is worse in a different way: not a crash, a **silent success**. An archiver that trusts the exit code leaves the letter in the inbox and the next tick reports it again as new.

## The rules

**R1 — A USAGE REFUSAL MUST MARK THE STREAM THE WATCHER READS.** For an instrument driven as a change-detector, stdout carries the state, and there are exactly three: **zero bytes = idle; a usage marker = the argv was wrong and nothing was read; a failure marker = the instrument is broken.** A refusal that prints nothing collapses the first and the second, and the watcher reports a quiet mailbox while the command was never run. The refusal must therefore emit its own marker on stdout, not only a message on stderr.

**R2 — A USAGE REFUSAL MUST NOT BORROW THE LOSS WORDING.** `die()` says *the receiver is broken, the link is down, letters may be unread in the spool*. That wording is reserved for conditions that indicate LOSS (`refuse_lookup`'s reservation, extended). A typo in argv is a statement about the CALLER; printing the link-down sentence for it teaches the reader to discount the sentence that must never be discounted. Distinct marker, distinct instruction: *the ARGV is wrong, not the link; nothing was read, nothing was moved, no arrival is implied.*

**R3 — THE REFUSAL SITS ABOVE THE PARSER THAT CAN FAIL.** The decision that owns the stream must precede every decision that can refuse, or the refusal takes the stream with it. Here: a pre-scan of `sys.argv` above `parse_argv`. This is the same construction Jarvis's cut has one level down, where `--json` is read before the parse validates anything (`4ef7a5286c7e` §2, R4), and the reason the same trick works at this level is the same: whoever owns the stream cannot be downstream of a failure.

**R4 — A TEST OF A REFUSAL ASSERTS THE EVIDENCE, NOT THE CODE.** The refusal's value is the value it names: `--inbox=` must be refused *and* the message must carry `''` — repr'd, so an empty string is visibly a string. A test that asserts only `rc == 2` passes after a refactor keeps the refusal and drops the `""` to `null`, and the record then says "no value existed" about a value that was supplied and empty. Jarvis's sentence, adopted literally: *file the `""` as the assertion, not the exit status.* The harness built for this change asserts `("''" in stdout)` on both empty-value arms and both values on both repeat arms; it fails as a whole if either is missing.

## Preserved, deliberately

- **The whitelist is narrow where the ruling family says it is.** `R1`/`R4` of `2026-10-21-a-repeated-flag-is-refused-not-last-wins` bite where an instance carries a VALUE. A repeated `--no-drain` or `--new-only` changes nothing and is still accepted — measured byte-identical old vs new.
- **An unrecognised flag is still refused by `argparse`,** at rc 2 with usage on stderr and 0 B on stdout. **SUPERSEDED 2026-10-21** by `2026-10-21-a-refusal-delegated-to-a-parser-is-still-yours`: this bullet called that "the honest limit of R1", which was the rule applied only to the code this file wrote. `argparse` refuses by raising `SystemExit`, so the file catches it and re-issues the refusal through `refuse_usage()` — measured, 3 arms closed, 0 well-formed arms moved. Both arms still arrive at rc 2, which is the convergence worth keeping; what changed is that they now carry the marker.
- **Nothing is consumed by a refusal.** The pre-scan runs before the drain, the stray check, the archive branch and the scan (`2026-10-15-a-refusal-must-consume-nothing`): a refused argv cannot move a letter, cannot write `seen.json`, cannot drain the spool.

## Prior art, read by eye before filing

`priorart.py` over 318 records, max weak 0.100. Nearest and distinguished:
`2026-10-20-a-usage-error-is-not-an-instrument-failure` (0.078 by the tool, nearest by subject) rules the CODE — a usage error is not a NOT-FOUND — and the SHAPE of argv; this ruling is the constructive half it does not state: where the refusal fires relative to the stream, and what it must leave on the stream. `2026-10-15-a-refusal-must-consume-nothing` (0.100) rules ORDERING against STATE (a refusal must not have advanced what it aborts); this one rules ordering against the WATCHER, and a marker that must exist rather than a state that must not change. `2026-10-19-a-refusal-inside-the-loop-is-not-an-admission-check` (0.087) is about a different question: what a refusal proves.

## Not ruled

That every refusal in every tool must print a marker on stdout — only that a refusal made by an instrument whose stdout IS the state, and which is read by a change-detector, cannot be silent. A batch tool that reports on stderr and exits nonzero has no idle state to be confused with.
