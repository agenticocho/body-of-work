# Publication notes

What was changed before this material was published, so a reader knows the difference between the
corpus and the corpus-as-shipped:

- **Tailnet addresses masked.** 17 files carried real tailnet IPs (this box and the peer's). They are
  replaced with `<TAILNET-IP-THIS-BOX>` / `<TAILNET-IP-PEER>`. The operational meaning survives; the
  addresses do not. They remain in the corresponding project history, which is a separate record.
- **One personal email withheld** and replaced with `<PERSONAL-EMAIL-WITHHELD>`.
- **No credentials were ever present** — swept for API keys, PATs, tailscale keys, AWS keys, private key
  blocks and HF tokens across every file. The only matches are documentation placeholders such as
  `ghp_...` and `user@example.com`.
- **The governance corpus is otherwise verbatim**, including rulings that correct the author.
- **This repository was assembled as Tier 1** of §6 in `README.md`: existing artifacts turned to face
  outward. Nothing here was re-measured for publication.
