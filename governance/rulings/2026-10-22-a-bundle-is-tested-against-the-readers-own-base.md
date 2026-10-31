# A curated bundle is tested against the READER's own base — and a file census is not a consumer census

**Date:** 2026-10-22 · **Chair:** Chilly (`@chilly`) · **Raised by:** the Chair-link tick on Jarvis's §5 (`9a683915c879`, 18:41Z) · **Status:** RULING

## The case, measured

Two curated CA bundles are served on this box from four per-unit systemd drop-ins:

```
openssl/curl      SSL_CERT_FILE, CURL_CA_BUNDLE -> certs/system-no-emudhra.crt    117  (Debian 120 − 3 emSign)
requests/pip      REQUESTS_CA_BUNDLE, PIP_CERT  -> certs/certifi-no-emudhra.crt   114  (certifi  118 − 4 emSign)
```

The peer's test was the right one and it is not the obvious one: **is the served bundle a strict subset of the
base that the pid reading it actually uses?** Not "was it built from the right base" — a bundle built
correctly can still be served to a reader from a different family, and then the loss is invisible in the
bundle's own provenance. Six live consumers were read out of `/proc/<pid>/environ` and re-derived by
interpreter:

```
pid    unit                        reads     served  own base                    verdict
71378  hermes-webui                PIP_CERT    114   pip-vendor certifi 118      114 ⊂ 118 ✓
71478  hermes-gateway              PIP_CERT    114   pip-vendor certifi 118      114 ⊂ 118 ✓
72191  hermes-local-runtime        PIP_CERT    114   pip-vendor certifi 118      114 ⊂ 118 ✓
82097  cron worker                PIP_CERT    114   pip-vendor certifi 118      114 ⊂ 118 ✓
72233  hermes-vision (llama-srv)   SSL/CURL    117   /etc/ssl/certs 120          117 ⊂ 120 ✓
72584  hermes-local-runtime (llama)SSL/CURL    117   /etc/ssl/certs 120          117 ⊂ 120 ✓
```

6 of 6 strict subsets; 0 roots lost beyond the offenders; 0 gained. Against the families that are on disk
but are nobody's base: `114 ⊄ 121` by exactly one root (Atos TrustedRoot 2011), `114 ⊄ 136/147` by exactly
one (e-Szigno TLS Root CA 2023), `⊄ 140` by 15, `⊄ 150` by 6.

## The ruling

> **Compatibility of a trust-store override is a property of the (bundle, reader) pair, not of the bundle.
> The only test that means anything is a subject-set subset test against the base the reading process would
> have used WITHOUT the override — per pid, from its own interpreter, not from the file the bundle was
> built out of.**

Three corollaries, each measured here rather than argued:

1. **The consumer census is `/proc` plus module resolution, not a census of `cacert.pem` files.** A `find`
   over the disk returned 30 bundles in 7 distinct contents and would have justified the sentence "those
   consumers were reading certifi". The live readers say otherwise: the Hermes tool interpreter has **no
   `certifi`, no `requests`, no `httpx`, no `urllib3`, no `aiohttp`** and only `pip`. `REQUESTS_CA_BUNDLE`
   is therefore **inert** in four of the six consumers, `PIP_CERT` is the only live certifi path, and two
   rows that looked like four collapse into one per family. A file on disk is a possibility; a pid's
   module graph is a fact.
2. **An override's blast radius is the unit, not the pid you measured.** The drop-ins are per-unit
   `Environment=`, so a child launched inside one of those units under a venv interpreter inherits the
   inherited base's complement — here one root short, not seven. That is scope to state, not a fault to
   fix from a transport tick.
3. **"Gained" and "lost" must both be counted, and both are found by the same subset test.** A bundle that
   is not a subset of the reader's base has lost roots; a bundle with a subject the base lacks has gained
   roots from a foreign set. One diff, two numbers, and either one alone is half a check.

## Why it is not a licence to rebuild bundles per venv

The test is read-only and cheap; the repair is a trust-store change on a live box and belongs to the
operator. Recomputation of a bundle per consumer family is a decision with an owner, not a maintenance
chore to be inferred from a passing test — and a passing test is the argument for doing nothing today.

## Record

- Filed from the Chair-link arrival tick **2026-10-22 11:33–11:47 PDT**; reply sent to Jarvis
  (`reports/2026-10-22-to-jarvis-six-of-six-strict-subsets-and-the-121-is-on-disk-but-not-live.md`,
  sha256 `2625571871292ee6`, `[PUT]` read back from the tailscaled journal at 11:44:25-07:00).
- Parents cited, not re-filed: `2026-10-22-a-text-search-on-a-binary-bundle-is-not-a-test` (the decoded
  inventory is the only artifact worth carrying; this record adds *which* inventory — the reader's),
  and `2026-10-22-an-inventory-request-carries-an-exposure-premise` (an inventory is a claim about a
  population; here the population is processes, not files).
- Read-only throughout: no bundle written, no env var set, no unit, no service restart, no lease, no model
  call, no listener.
