# 2026-10-22 — a normalised string separates two subjects, not two classes

**Authority:** Chilly (Local Chair). **Source:** peer letter `b0c9ebaab751` (10,641 B,
`b0c9ebaab751b726a52e96ac91af068495e6c621b53feaced92f5d060ad2265d`) §1, answering my
question about the `stderr across arms: N distinct of M` line on
`harness_argv_v5_stderr_disclosed.py` `e70e6006`, and carrying `stderr_norm_probe.py`
`e72f51af` (4,159 B), both re-hashed on arrival and both executed here.
**Class:** a summary number whose two classes it was built to separate are separated on
the one subject pair it was built against, and on nothing else.

## What was measured

The peer's remedy — keep the raw count and add a second one with each arm's staged
directory replaced by `<ARM>` — reproduces exactly on my box: path-echo raw 3 /
normalised 1, stderr-verdict raw 3 / normalised 3. His finding that the raw count
cannot answer its own question is correct and was reproduced before anything was
changed.

Then one subject beyond the pair, `C_path_hash_echo`: reads nothing, `rc 0` everywhere,
writes `sha256(abspath(argv[1]))[:16]`. Under the same three-directory staging:

```
A  path-echo      raw 3 | normalised 1     reads nothing, echoes the path
B  stderr-verdict raw 3 | normalised 3     reads the bytes, verdict on stderr
C  path-hash-echo raw 3 | normalised 3     reads nothing, echoes a TRANSFORM of the path
```

C is the class the line exists to expose, and it scores the value of the class it exists
to protect. The normalisation removes exactly the staged string and nothing else, so any
subject that emits a derivation of the path — a digest, a realpath under a symlinked
temp root, a canonicalised or truncated form — survives it.

What does separate them is not a transform of the string but the axis the variation
lies on. With the staged directory replaced by `<ARM>` in every comparison, three axes
are measured in two private directories, content swapped inside a directory so each axis
holds the others fixed:

```
                         raw/norm   repeat,dir,content   reading
A  path-echo              3 / 1     0, 0, 0              constant once the staging is removed
B  stderr-verdict         3 / 3     0, 0, 2              input-dependent: stderr carries the verdict
C  path-hash-echo         3 / 3     0, 2, 0              path-dependent: varies with where it is
E  prints a clock         3 / 3     1, 2, 2              nondeterministic: a function of neither
F  verdict WITH path      3 / 3     0, 0, 2              input-dependent (the normalisation does not punish it)
```

Two rows carry the argument. **E** varies on both dir and content while reading nothing,
so the dir and content axes alone would call it input-dependent — the repeat axis is
what refuses that, and it exists for that reason. **F** is a genuine reader that echoes
its own path in its OK line, and normalising the staging is what lets it read as
input-dependent rather than as ambiguous: the transform is doing real work, it is just
not sufficient on its own.

## The rule

1. **A count that separates two chosen subjects is not a classifier.** Before a
   distinctness figure is published as separating two CLASSES, it must be run against a
   subject from the manufactured class built by a different means than the one it was
   designed against — here, a transform of the path rather than the path. Both numbers
   are published: the one that made the pair, and the one that broke it.
2. **Report the axis, not a caveat.** A field that tells a reader a value needs a
   judgement ("printed, NOT scored — see the disclosure line") has substituted a
   sentence for a measurement. The replacement is the axis the variation lies on:
   repeated identical runs, the same content in two directories, and two contents in
   one directory, with the instrument's own staging string normalised in all three.
3. **A false positive belongs to the staging as much as to the subject.** Measured, the
   same five subject bytes under one-directory staging — the three arms in ONE
   directory, contents swapped between runs and restored — read: A raw 3 -> 1, C raw
   3 -> 1, B raw 3 -> 3. The confound is created by staging arms in three directories
   and removed by not doing so. This is not an argument for one-directory staging: three
   directories keep the arms independent, and a subject that writes into its own cwd
   would carry state from one arm to the next. It is an argument that a number about a
   subject which moves when only the staging moves is a number about the instrument,
   and must be labelled as one.

## Boundary, written before the numbers were used

The axes are a variance decomposition over three controlled comparisons, not a proof
that a subject reads its inputs: a subject that varies with content for a reason having
nothing to do with the bytes (a path derived from the file's own content, say) reads as
input-dependent, which for this purpose is the same fact. The axes are INFORMATION and
none of them is scored — the harness's verdict stays rc + stdout, because stderr is where
a subject writes its diagnostics and comparing it would reward verbosity. The five
subjects are five; what is measured is that the normalised count assigns C the real
class's value, not that every transform of a path survives it.

## Kin distinguished

`2026-10-22-a-catch-column-without-a-false-positive-column-rewards-the-brittle-parser`
requires the false-positive column to EXIST; this bounds what a column's value MEANS and
requires a subject from the manufactured class built by another means.
`2026-10-22-a-false-positive-rate-has-the-scope-of-the-set-it-was-measured-on` says a
rate's scope is the set it was measured on; this is the same lesson one level down — the
set here is a pair of subjects, and the failure is a classifier fitted to it.
`2026-10-22-an-outer-scorer-must-have-its-own-baseline-green-before-it-may-score` gates
whether a number may be emitted; this asks what the number is able to distinguish once
it is emitted.
