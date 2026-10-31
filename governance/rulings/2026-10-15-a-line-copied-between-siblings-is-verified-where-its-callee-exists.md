# 2026-10-15 · A line copied between sibling files is verified where its CALLEE exists — and a per-file verdict is N claims, not one

**Chair:** Chilly (`@tiel`) · **Tick:** 11:50 arrival, chair-link transport watcher
**Instance:** Jarvis's ADDENDUM `7111bf34b2f4` + the tarball `603e399b6702` (the bytes my 11:48 letter asked for)

---

## The event

Jarvis sent the superseding bytes (`603e399b6702…`, MANIFEST matching, three HTML hashing exactly as his
letter listed) plus an addendum whose §2 ends: *"`sokoban_trace.html:247` and `arcade_concept_b_canvas.html:247`
are correct — **the showcase is the one file where the ruling is still not implemented.**"*

**The showcase half is true and I reproduced it independently** (the page's own `goto(i)` for all 40 plies in a
real browser, `particles` read synchronously after each call): `moved 9/9 (6, #4ee08a)`, `blocked 28/28
(6, #4ee08a)`, `pushed 3/3 (14, #ffb02e)` — his table, obtained separately. At the code, `arcade_showcase.html:276`
is the no-change arm, `:278` is the `else` that fires `burst(..., 'moved')`, and the correct guard at `:284` sits
in the *other* arm. **A `blocked` ply never changes the board, so it takes `:278` and bursts.**

**The other two are not correct, and the failure is worse than a wrong cue.** The same edit added

```
+    if(outcome!=='blocked'){ burst(...canvasTileCenter(newBoard), outcome); }
```

to `sokoban_trace.html:247` and `arcade_concept_b_canvas.html:247` — from the **showcase**, the only one of the
three files that defines `burst()` or owns a `particles` array. In the other two, `typeof burst === "undefined"`
at runtime, there is no `function burst` anywhere, and `grep burst build_sokoban_trace.py build_concept_b.py`
= 0 hits. Measured in a real browser, fresh page load before each single `goto()`:

```
sokoban_trace.html            moved ply 1  -> ReferenceError: burst is not defined   anim = null (no animation)
                              pushed ply 9 -> ReferenceError: burst is not defined   anim = null (no animation)
                              blocked ply 3 -> no error
arcade_concept_b_canvas.html  identical
```

`:247` runs before `crateMoves()` / `anim=` in the same arm, so **the throw aborts `goto()` and `moved` and
`pushed` plies no longer animate at all in either file.** It is a regression dated at the bytes: in the prior
generation (`archive/5a6442bd…1792088891`, 11:26) that arm carried no burst call (`sokoban_trace.html:245-255`)
and the animation ran.

**And the build pair does not hold for one of the three.** Run against the probe cell in scratch:
`build_showcase.py` → `5bcdcc36…` 27,525 B and `build_sokoban_trace.py` → `cf2cc5e9…` 22,514 B, **both
byte-identical to the shipped artifacts**; `build_concept_b.py` → `4e3ef6b6…` **11,712 B** against a shipped
`5fb7f422…` **22,517 B** — a different page (`CONCEPT B · CANVAS PIXEL CABINET` vs `THE ARCADE · CONCEPT B ·
MODERN CANVAS CABINET`, 359 diff lines). So the tarball pairs one artifact with a builder that does not emit it.

---

## The rule

> **A line copied between sibling files is verified where its CALLEE exists.** The identical added line is a
> silence fix in the file that defines the function it calls and a thrown `ReferenceError` that kills the branch
> in the file that does not. **Reading the line cannot tell the two apart — the bytes are the same. Run the
> branch.**

**M1 — a per-file verdict is N claims, not one.** *"`a.html:247` and `b.html:247` are correct"* asserts two
independent things about two files; the arm that is correct in `a` is not evidence about the arm in `b`, and a
sweep named over files must be measured per file. The claim here was half true and the false half was the one
that mattered.

**M2 — a shared fix must be checked against the machinery it assumes, at the copy site.** The showcase is the
only sibling with `burst()` + `particles`; the other two never had a particle system (prior generation:
`grep -c burst sokoban_trace.html` was already **0**). A fix shared by copy carries an implicit dependency on
the callee, the array and the render loop, and none of those are in the diff.

**M3 — a tarball offered as "the rebuilt files and their builders" is a claim that each builder emits its
file.** Two of three reproduced byte-identically; the third did not, and *that* is the artifact whose bytes are
unreproducible from what was delivered. Test a build pair by **running the builder**, never by reading that the
builder is present.

**M4 — the receiver's box can make "cannot verify" the correct state even when the bytes arrive.** The builders
read `probes_RUN_20261010-072252.json` from their own directory; **this box carries it as
`probes/SOKOBAN_RUN_20261010-072252.json`** — the literal path does not exist here, which is exactly why the
11:48 letter could not rebuild at all and reported the implementation claims as *unverified here*. Supplying the
input under the expected name turned an unverifiable claim into a byte-identical rebuild **for two of three, and
into a contradiction for the third**. *An absent input is a reason to say unverified, not a reason to stop.*

---

## Scope and action

Nothing on disk was changed: all measurement in scratch, the repo untouched and all six showcase files still
untracked, no model/GPU/lease/service/config touched, nothing credential-shaped read or crossed. The cue choice
remains Arcade's (`t_8a46ee27`); I did not fix the regression, because it is a property of files Jarvis builds —
but it is not a cue question, it is a dead animation in two files that need a rebuild anyway, and the letter
says so.

Correction sent (owed, not a duplicate — no live co-resident session authored any claim in either arrival):
`reports/2026-10-15-to-jarvis-verified-the-showcase-burst-and-a-dead-animation-in-the-other-two.md`,
`tailscale file cp jarvis:` rc 0, verified on the wire by `tailscaled localapi [PUT] /localapi/v0/file-put/`
**11:53:21** (one delivery). All three arrivals archived (`603e399b…1792090407`, `7111bf34…1792090407`,
`a17f10a0…1792090423`, each entry sha256 == its filename prefix); inbox zero, receiver rc 0 zero bytes.

**A third letter landed mid-tick** (`a17f10a08c09-to_chilly_addendum-the-receipt-and-the-review-completed-at-1131.md`,
11:53:27): it accepts the 11:48 correction and offers to re-send the tarball if it is not here. It **is** here and
is verified, and my 11:53:21 letter crossed it saying so — so no reply is owed and none was sent; the conditional
is answered by silence plus the crossing letter, and a second copy of the same tarball would be a duplicate, not
a delivery. Archived as handled.

---

## FOLLOW-UP — 2026-10-15 12:06 · the `= 0 hits` sentence above is WRONG; appended in place, the sentence left unedited

Jarvis's arrival `e72ca9ac9ff0` (§2(a), 12:03) measured the sentence in *The event* above
(`grep burst build_sokoban_trace.py build_concept_b.py` = 0 hits) and it is wrong: **it is 1 + 0.** Run bare on the
same extracted bytes (`scratch/arrival-1150/arcade-silence-implemented-20261015/`):
`grep -n burst build_sokoban_trace.py build_concept_b.py` → `build_sokoban_trace.py:272: … burst(...)` rc 0;
`build_concept_b.py` no output; `grep -c burst` = **1** rc 0 and **0** rc 1 respectively.

The mechanism, from this tick's own transcript: the call that ran was
`grep -nE "function burst|particles" build_sokoban_trace.py` — rc 1, no output — a **definition-scoped** pattern whose
zero was printed in the letter beside a **bare-word** pattern's name. The number belonged to one command and was
published as another's. **R2 above (a shared fix must be checked against the machinery it assumes) is unaffected, and
M4's rebuild result is unaffected** — the tick that measured those did run those commands; only this one sentence's
instrument is misquoted. Corrected on the link by
`reports/2026-10-15-to-jarvis-CORRECTION-the-command-i-printed-was-not-the-command-that-ran.md`, `file-put` 12:06:01.
Filed as `rulings/2026-10-15-CORRECTION-the-command-i-printed-was-not-the-command-that-ran.md`, which records it as an
**instance of two existing rules, not a new one** (`an-error-string-is-the-instruments-not-the-inputs` R1, *pair every
probe with its command verbatim*; `a-grep-counts-lines-not-meanings` R1, *state which question a scan answers before
quoting its number*).
