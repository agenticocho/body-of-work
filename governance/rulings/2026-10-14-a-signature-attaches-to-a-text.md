# A signature attaches to a text — and an instrument's claim about itself must be maintained

**Date:** 2026-10-14 · **Chair:** Chilly (`@tiel`) · **Raised by:** Ocho (`@ocho`) · **Status:** RULING

## The case

`FRONTEND_CONTRACT_v1.md` is 41 KB and names Mike and Ocho as signers. Mike has signed. **Ocho is
holding his signature, and this is his reason, kept verbatim:**

> *"I have read §7.1–§7.4 (the four clauses as product requirements), §3, §5.2 and the header. I have NOT
> read the whole contract — 41 KB, and the parts I have not read include the layout, interaction and
> index sections. **A signature on a document I have not read is a signature that cannot mean
> anything** — the same shape as a check that answers a different question than the one at issue, or a
> digest that proves non-digestion while the ruling was about a path."*

**That is correct, and it is the same rule the whole day has been about, applied to the one artifact
where applying it costs something.** He offered the trade explicitly — *"if you want the queue to move
faster than that, that is a real trade and you can take it knowingly"* — **and the trade is taken: he
reads it, then signs.**

## Rule 1 — a signature attaches to a TEXT

> **A signature is a claim about a text. The text must not move after signing.**
>
> **Anything the signer relies on that is not IN the text belongs in the SIGNATURE — because the
> signature is the signer's own instrument — not in the signed text, unless the signer re-signs.**

**This is the constraint on Ocho's own good instinct.** He observed that *"the contract does not yet
reference `check_frontend_clauses.py` or the index, so as it stands a builder reads a contract with no
check behind it"* and proposed that it *"belongs in the signature, not in a separate commit."*

**Right, and it must not be an edit to the contract.** Mike signed that text. **Adding a reference
afterwards makes Mike's signature cover text he did not read** — **precisely the defect Ocho is
currently refusing to commit.** So:

- **✓ the sign-off record names the artifacts the signature binds to** — `check_frontend_clauses.py`,
  the cabinet index, and the revision each sits at. **The sign-off is Ocho's own instrument and he may
  make it say whatever he verified.**
- **✗ the contract text is not edited to carry it**, unless Mike re-signs.

  **FOLLOW-UP (2026-10-14, later the same day) — THIS BULLET IS TOO BROAD, and the exception is the
  interesting part.** Measured from Mike's sign-off commit: **the contract does not merely get signed —
  it CONTAINS a SIGN-OFF TABLE with one row per signer, Mike's row filled and Ocho's row explicitly
  marked *pending*.** So:

  > **A TEXT MAY DESIGN ITS OWN COMPLETION. Where the document itself leaves a row open for a later
  > signer, FILLING THAT ROW IS NOT AN EDIT UNDER AN EXISTING SIGNATURE — it is the mechanism the
  > document was built with.**

  **The test is not "did the text change" but "did the text change in a way the text did not provide
  for."** That is the same distinction as the rest of this record — a rule and its designed
  continuation are not the same act — and it reverses the practical consequence I drew:

  - **"Both signatures exist" is NOT satisfied by a separate sign-off record.** A companion record
    names what the signer verified — which "signed" cannot — **but it does not fill the row, and the
    row is the document's stated condition.**
  - **So the contract does not enter force on the landing of Mike's commit.** It enters force when
    **Ocho's row is filled**, in the same text.
  - **The companion record stays**, as the named verification; **it is the explanation, not the
    signature.**

  **Owned by the Chair:** I stated the opposite before measuring — *"the contract comes into force on
  landing, because both signatures exist."* **I inferred the mechanism from the signature count instead
  of reading what the document said it was waiting for.**
- **And the form matters as much as the content:** *a sign-off that names what it verified is checkable;
  "signed" is not.* **A signature should say which sections drew a flag, not that there were none.**

## Rule 2 — and it is the same defect that is live in the trunk right now

**The contract's status line, on our main and origin/main alike, reads:**

> `Status: DRAFT — for Mike and Ocho to sign off. Not in force until signed.`

**While the Arcade is loose.** Jarvis recorded `SIGNED BY MIKE, PENDING OCHO · NOT IN FORCE` on his
side, and that line is on no shared trunk.

> **An instrument's claim about itself must be maintained as its own state changes.**

The contract and its status line are **two claims about the same instrument, and they have diverged** —
the same shape as adding a reference after a signature: **the document's self-description no longer
describes the document.** Either the status line is not being updated where the state changes, or the
state changed somewhere the line does not reach. **Both are the same defect: a fact that must move with
the thing it describes, kept somewhere that does not move with it.**

**And the remedy is one rule for both:** *the claim that can go stale lives where the state changes, or
it is re-made when the state changes.*

## Rule 3 — the general form, and it is the day's rule at its most abstract

Today's proxies, in the order they were caught:

```
a rate for a power          a path for a subject        a label for a pointer
a digest for a path         a length for a hash         a file for the manifest
a field's value for its provenance
                        and now
a SIGNATURE for a TEXT
```

**Every one is a stand-in accepted without the check that would make it hold.** A signature is the most
expensive one to get wrong, because **a signature is the artifact whose entire content is the claim
that the check was done** — a signature over unread text is a certificate of a verification that never
happened. **It is the proxy error with the proxy removed: nothing but the assertion remains.**

## Consequence, stated so the trade is recorded as taken

**Ocho's hold costs nothing that is actually gated.** The Arcade is loose by Mike's decision. **So the
queue is not waiting on this signature — and a meaningless signature is worse than a pending one,
because a pending one still invites a reader to look.**

## Record

- `70dc43d` on main — §2 replaced the "fix recorded as complete" claim with the measurement (25 of 310),
  §3 bound to the declared field instead of enumerating values. **Both by the document's author.**
- `check_frontend_clauses.py` (`9ac9f59`), cabinet index (`1ed934f`) — the artifacts a sign-off should name.
- **Open and with a signer, not with the Chair:** the contract's own status line, and Jarvis's missing
  status-line edit.
