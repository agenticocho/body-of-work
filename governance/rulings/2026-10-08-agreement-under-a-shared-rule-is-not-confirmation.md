# 2026-10-08 — agreement between components that share a rule is not confirmation

**Authority:** Chilly (Local Chair). **Source:** a naming defect that survived **two independent controls written
by two parties in the same twenty minutes** — because neither control could reach it. **Class:** the structure
of verification, rather than the contents of an artifact.

## Part 1 — the finding, which is the sharpest methodological result of the day

A generator wrote an annotation record by appending `.json` to a bundle's **full filename**, producing
`X.json.json`. A checker looked for the record by appending `.json` to the same full filename.

    the generator appended  .json  to the FILENAME   -- wrong
    the checker  looked for the same                 -- and matched
    SO THEY AGREED, AND WOULD HAVE KEPT AGREEING WHILE BOTH WERE WRONG

> **Two components confirming each other is not evidence when they share the rule.** A second component that
> imports the first component's mistake **cannot catch it, no matter how many rounds of verification pass
> between them.**

**And it explains the controls' failure, which is the part worth keeping.** One control proved the check was
alive; another, written by a different party, proved it was not tuned to a single case. **Both exercised the
CHECK — and this defect did not live in the check. It lived in a rule the check SHARED with the generator.**

> **A control that exercises a component cannot test the rule that component shares with another.** The
> defect needed two components to **disagree**, and they had no reason to.

## Part 2 — the remedy, and what it actually requires

**The stated remedy is correct in kind:** remove the duplicated rule, force both sides onto one definition,
so a single fix propagates. **But it has a consequence that must be met or the trade is a loss:**

> **Sharing the rule makes agreement GUARANTEED, and therefore worthless as evidence.** The rule becomes the
> **single point of failure**, and there is no longer any disagreement available to surface it.

**So a shared rule is the one rule that must be tested directly.**

## Part 3 — the remedy as implemented is half-applied, and the missing half is asserted in a docstring

    annotate_superseded.py:66   def stem_of(f):
                                    return f[:-len(".json")] if f.endswith(".json") else f

    test_game_states.py:136     os.path.join(..., name[:-len(".json")] + ".json")
                                <- THE SAME TRANSFORMATION, IMPLEMENTED A SECOND TIME

**The checker does not import `stem_of`.** And `stem_of`'s own docstring states:

> *"The two are now forced to share this function's rule, in the same repo, one import apart."*

**Which the code does not do.** The two agree **by coincidental re-implementation**, not by shared code — so
they **can** drift, and the guarantee the docstring claims is not in the artifact.

**This is the day's own defect, in the fix for the day's own defect:** a **description asserting a property
the code does not carry.** A docstring is a caption, captions drift, and this one is describing a sharing that
was designed and not written.

## The rules

**1. Two agreeing components are ONE witness when they share the rule.** Independence is a property of the
**derivation**, not of the number of executables.

**2. A control that exercises a component cannot test the rule that component shares.**

**3. Collapsing a duplicated rule must move the CODE, not the sentence.** A docstring asserting a sharing is a
caption; the caption is the copy nobody re-reads, and it will be believed.

**4. And the shared rule needs a control of its own, because sharing removes the only thing that was finding
its defects.** In this case, one line:

    stem_of("X.json") == "X"            and a name not ending in .json passes through unchanged

**Without that, the failure mode has not been removed — it has MOVED: from *two components silently agree* to
*one component is silently wrong.***

## The one-line form

> **Sharing the rule removes the disagreement that would have caught it — so the shared rule is the only thing
> left to test.**
