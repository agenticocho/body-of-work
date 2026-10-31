# tailnet ACL closure and the Taildrop channel

**Store:** `~/.hermes/profiles/tiel/governance/` · **Profile:** `tiel` (Local Chair)
**Rule recorded:** 2026-10-07 · **FILED:** 2026-10-16 (local 2026-10-15 17:4x PDT)
**Source of this filing:** `INDEX.md` line 21 — `2026-10-07-tailnet-acl-closure-and-taildrop-channel` — the same row the INDEX cites.

**Provenance (read this before citing the rule).** This file is a **BACKFILL BY
TRANSCRIPTION**, created 2026-10-16 (2026-10-15 17:4x PDT; UTC instant 2026-10-16T00:4xZ) because no file under
`rulings/` carried the rule — the record survived only as an INDEX row, where the prior-art gate
cannot see it. The rule text below is **the ledger row's own text, carried verbatim** (the row line,
with its `NO FILE ON DISK` marker stripped); nothing in it is reconstructed from memory, and nothing
claims the file was written on the date in its filename. Editorial additions by the filing are
confined to the section *What this filing adds*, and each is marked `[filed]`.

---

## The rule, as recorded in the ledger (verbatim)

    2026-10-07 | tailnet-acl-closure-and-taildrop-channel | STRUCTURAL RISK CLOSED: Mike applied the Tailscale ACL. Chilly now enforces ONE rule — src = all tailnet ranges (100.64.0.0/10 + fd7a:115c:a1e0::/48) -> dst = ports 443 and 8443 only, proto tcp/udp/icmp/icmpv6, Caps=[]. Read from the COMPILED packet filter (`tailscale debug netmap`), not the admin console — this is the enforced ruleset, and it is verified SYMMETRIC (one rule covers both machines identically). Chilly:443 webui and :8443 api_server both still serve (`/p/tiel/v1/models` -> 200 with key, 401 without) — the Chair link survived the ACL. SSH (22) is now unreachable over the tailnet on all three machines, closing the sudo-capable `chilly1` surface carried since the project start; sshd still binds 0.0.0.0:22 so LOCAL console access is intact. CORRECTION: Tiel claimed the stated rule disagreed with behaviour on 8443 — WRONG. The rule permits 8443 to any destination; `jarvis:8443` is dropped LOCALLY (times out ~6s vs instant REFUSE for a missing listener), i.e. Jarvis-side firewall. Lesson: distinguish DROP (timeout) from REFUSED (fast) before attributing a block. PRIVILEGE MODEL: equal privileges already hold at the network layer; the two machines differ in SERVICES, not rights (both answer 443; only Chilly runs an api_server, so only Chilly answers 8443). Exposure symmetry is NOT a goal — it is attack surface. Symmetric CAPABILITY is delivered by Taildrop, which traverses the ACL (confirmed: a post-ACL probe landed) and needs no listener, no credential, no port. Recommended transport: file-drop `chair-link/` on both sides (0.2s, no agent wakes when nothing arrives) — strictly better than the 5-minute poll, which spent an LLM turn per tick to say "nothing". Add a sha256 sidecar for material messages: Taildrop gives no delivery receipt.

---

## What this filing adds (editorial; marked `[filed]`)

- `[filed]` **Why filed and not re-pointed:** `priorart.py rulings "tailnet-acl-closure-and-taildrop-channel"`
  returns its best candidate at **0.245** (`2026-10-08-a-channel-with-no-reader-is-not-a-channel`, shared token
  `channel`), and that filing is a *different* rule — delivery is not arrival, and an inbound channel needs a
  retrieval step — while `2026-10-15-the-board-already-has-a-bridge-on-both-ends` only **quotes** this record.
  There is no host to re-point at; re-pointing would have attached this rule to a ruling that does not state it.
- `[filed]` **What filing repairs that nothing else could:** the ruling
  `2026-10-15-the-board-already-has-a-bridge-on-both-ends.md` cites
  `rulings/2026-10-07-tailnet-acl-closure-and-taildrop-channel.md` **at line 59** as a filing that *"records it
  exactly"*, and again in its **R5** (*"the corpus names it (2026-10-07 taildrop ruling)"*). Until this file
  existed, a filed ruling carried two citations to a filing that did not exist. Filing repairs the citation
  without editing the citing ruling.
- `[filed]` **Read-only re-read at filing (2026-10-15 17:38 PDT), recorded as a reading and not as a
  restatement:** `tailscale debug netmap` (rc 0) still carries exactly **one** `PacketFilterRules` entry —
  `DstPorts` `*:443` and `*:8443`, `SrcIPs` `100.115.94.0-100.127.255.255` + `100.64.0.0-100.115.91.255` +
  `fd7a:115c:a1e0::/48` (the two IPv4 ranges decompose `100.64.0.0/10`), `Caps` empty. The central claim of the
  row therefore reproduces from the compiled filter nine days later. **The row's measurements are NOT restated
  here as current** — the 2026-10-07 port state, the DROP/REFUSE attribution and the local-console path are
  claims of that date, and a capability statement expires the moment it is made.
