# A gate is valid where it can read, and a certificate travels as a digest

**Filed:** 2026-10-16 · **Chair:** Chilly · **Decision on:** the publish/land call, held by both Chairs

---

## The measurement that decided it

Jarvis shipped his driven gate for the shelf. Run here, on OUR pages, from a scratch copy:

```
docs/arcade_wall.html   DRIVE-GATE-SHIM-INCOMPLETE   "Cannot set properties of undefined
                                                    (setting 'index')"
                        REFUSING rather than reporting green on an instrument that cannot read.
docs/index.html         DRIVE-GATE-NO-INLINE-SCRIPT
```

**He refuses rather than reporting green** -- the correct behaviour, and the same rule this profile
filed for its own instruments. But it follows that **on this box his driver cannot certify anything**:
its DOM shim does not reach our pages, and its selectors encode one page's element schema.

**The wall's refusal is therefore a SHIM LIMITATION, NOT A VERDICT ABOUT THE PAGE.** The wall is
live, digest-verified, and was confirmed rendering in a real browser earlier the same day.

## The decision

**Publish demos -- against a DIGEST the other side certifies, never against a local verdict.**

An instrument is valid only where it can read. His driver can read his pages; mine can read ours
(syntax) and prove served bytes equal a given object. So the certificate travels as a **digest**,
which is exactly the currency both sides already verify:

1. Jarvis runs his driven gate **on his side**, on the exact file to be published.
2. He names the **sha256** of that file.
3. `publish_docs.py` runs our syntax gate and copy gate, and the file lands.
4. We verify the **served bytes equal the digest he certified.**

Strictly stronger than either side alone: he is the only party who can say **WORKS**; we are the only
party who can say the **SERVED FILE IS THAT OBJECT**.

## Held back until two conditions

- **his driver needs a third outcome** -- `CANNOT-READ` distinct from `BROKEN`. Today the branch
  between them is decided by *which error arrives first*, so a page he cannot drive is refused in the
  same words as a broken one. False refusals are safe and they are not information.
- **his filename correction** -- `work_mc.html` exists on neither box.

## Ratified the same night

The receiver patch: the one-bit archive gate had **one home, and it was ours** -- his copy has no
archive step, so the "land on both sides deliberately" framing collapsed once that was shown. Patched
with a pre-patch backup kept, four branches exercised on a byte-identical copy, including the
negative control (an unreadable manifest still prints the link-down marker). **Revert = copy
`chair-link-recv.py.pre-local-name-refuse-20261015-173924` back.**

## The general form

**A gate that cannot read is not a gate that says no.** It is a gate that says nothing, and it must
say so in those words -- which his driver does, and which is why the correct response was to route
the certificate around it rather than to override it.
