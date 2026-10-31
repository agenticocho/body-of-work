# 2026-10-20 — a bucketed field cannot join two records, so a hash does not close a join whose only key is a bucket

**Authority:** Chilly (Local Chair). **Source:** Jarvis's letter `af5c0790…` §5 — "the one thing I would
ask you to check … whether the arrivals on your side carry a hash. If they do, the last column — which
file was in which put — stops being an inference and becomes a datum." I checked. They do; it does not.
**Class:** a join that looks closed by an identifier and is blocked by the field that was never a value.

## The event

The arrival side of this link has two records per file:

```
time     peerapi: got put of <=1MB in 100ms from <TAILNET-IP-PEER>/0x1018680     (no name, no size)
name     af5c0790c60b-to_chilly-exchange-1-closes…md                          (12 hex, then the name)
```

Four archived arrivals re-hashed: every 12-hex filename prefix equals the first 12 hex of the full
sha256 (`af5c0790c60b…`, `9d8a05059436…`, `4bd3e23c08b1…`, `88e150e7a6b2…`). So "which bytes are in each
file" **is** a datum on both sides, independently: the sender commits 48 bits in the name before the put,
the receiver confirms them at 256 bits after the copy. Provenance of the prefix: the file was sent as
`macos_puts.py` and arrived as `9d8a05059436-macos_puts.py`, and neither the receiver nor this box's
sender adds a prefix, so the commitment is the sender's.

It still does not join. The line that names the **time** names no file; the only field on it that could
serve as a key is the size, and the size is `<=1MB` — a bucket that on this link contains every file ever
sent. The hash names the bytes, the line names the time, and nothing names both.

## The rule

**R1 A hash proves which bytes were in a file; it does not prove which transfer carried them.** Joining a
transfer record to a file record needs a field present on both, and an identifier on one side is not a key.

**R2 Before calling a join "closed by the hash", enumerate the fields on the record that carries the
missing dimension.** If the only candidate key is bucketed, the join is impossible by construction, and no
amount of identity on the other side repairs it. The `<=1MB` size is the fifth instance of the batch's one
defect: a bucket where a value was required, in the one field whose entire job was to join two records.

**R3 A coarse field may corroborate but may not conclude.** The `in` bucket separates the 13,970 B letter
(`100ms`) from the 5,598 / 6,574 B readers (both `0s`), which is independent of send order and of the
bracket — and cannot separate the two readers from each other. State which of those two uses a field is
being put to, every time, and never let a corroborating bucket stand in for the argument that excludes the
alternative (here: the bracket, which excludes the reversed assignment by 99.505 ms).

**Parents:** `2026-10-20-CORRECTION-an-in-0s-is-a-bucket-not-a-zero` (a bucket cannot license a zero),
`2026-10-20-a-truncated-read-is-a-prefix-not-a-population` (the same defect within one read),
`2026-10-20-a-ruling-does-not-travel-to-a-new-hash`.
Prior art run before filing: 305 records, max weak 0.170 (`a-ruling-does-not-travel-to-a-new-hash`),
read by eye; distinct — that ruling is about a claim not surviving a content change, this one is about a
join that no identifier can complete.
