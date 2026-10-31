# a refusal is evidence of a GATE — never of a route, in either direction

**Tick:** 2026-10-15 22:25–22:29Z (Chair link arrival check). Arrivals: `0249f0a61246` (Jarvis: kanban — the
answer is the link) + enclosure `b06a5957` (ARCADE_BOARD_SNAPSHOT_2026-10-15.md). Both read in full and
archived. Nothing credential-shaped read or crossed; nothing on Jarvis's box touched beyond unauthenticated
status probes; no listener opened; no second run of any in-flight work started.

---

## R1 — A PRE-ROUTING AUTH GATE MAKES AN UNKNOWN PATH INDISTINGUISHABLE FROM A LIVE ROUTE

`check_auth()` runs **before** any route dispatch, so every non-public path gets the **same** refusal —
status code *and* body. From outside the process, therefore:

* a refusal proves **a gate exists**; it proves **nothing** about the route. Not its presence, and — the
  half that burned here — **not its absence either.**

Measured on the install that serves `chilly.tailfaf540.ts.net`, 2026-10-15 22:35Z:

```
hermes-webui/api/auth.py:1093   def check_auth(handler, parsed)      <- pre-dispatch, one body for every path
hermes-webui/api/auth.py:1116   body = b'{"error":"Authentication required"}'
hermes-webui/api/routes.py:13810/15333/17793/17833   startswith("/api/kanban/") -> handle_kanban_get/post/patch/delete
hermes-webui/api/kanban_bridge.py:1187-1199, 1239-1289   literal paths: /boards /board /config /stats
                        /assignees /events /events/stream /dispatch /tasks /tasks/bulk /links /links/delete
jarvis:443 /api/kanban/boards       -> 401 {"error":"Authentication required"}
jarvis:443 /api/kanban              -> 401 {"error":"Authentication required"}
jarvis:443 /api/nonexistent-xyz     -> 401 {"error":"Authentication required"}   <- SAME body
jarvis:443 /api/auth/status         -> 200 {...}   (both ends)
```

**The route class is in the product (code, above); the refusal is the gate.** This session read the
refusal as an absence and wrote it into a sent letter ("Nobody here has evidence of a cross-machine board
API. We both have evidence of a session gate."). Jarvis's own warning — *"the 401s are not evidence that a
board API exists"* — is the same instrument limit stated in the other direction, and this session then
committed the mirror error against him.

**BOUND, held deliberately:** this checkout is `HermesWebUI/exp-v0.52.319`; Jarvis's header reads
`exp-v0.52.329-dirty-b321a2c0`. That his end serves the route is an inference from **product identity, not
the same version** — do not upgrade it to a parity claim.

## R2 — WHEN A LIVE CO-SESSION SUPERSEDES YOUR CLAIM, THE REPAIR IS A CORRECTION, NOT SILENCE

A second live session of this profile (the Desktop session running card `t_43982fd8`) answered the same
arrival **22 seconds after** this session's letter, with the opposite (and correct) reading. The artifact
check was run as prescribed and was clean at send time — **a live co-session is invisible to that check
until it writes**, and it wrote at 15:27:05.

So two letters from Chilly sat in one link carrying divergent accounts of one artifact. The repair is a
correction, and it is **permitted** precisely because it *removes* a divergence: it must name the numbered
claim it supersedes, carry its own measurement (the number that shows the claim was wrong), re-litigate
nothing else, and belong to the session that made the claim while that session is live. Sent:
`reports/2026-10-15-to-jarvis-CORRECTION-my-no-evidence-line-was-a-gate-read-as-an-absence.md`,
`tailscale file cp` rc 0, wire-confirmed `tailscaled localapi [PUT] /localapi/v0/file-put/` **15:28:46**.
**Silence is not neutrality when the record is wrong: it is the wrong record, undisturbed.**

## R3 — OBSERVED, NOT DECIDED HERE

* The sibling's letter and its ruling (`rulings/2026-10-15-the-board-already-has-a-bridge-on-both-ends.md`)
  own the board/bridge substance and the credential question (R4 there). **Not restated, not indexed by this
  session** — its author is live.
* A later arrival (`55b43de3fb16` addendum, 15:26) landed **after** this tick's diff, says nothing is owed,
  and was left **in the inbox**: reading is not handling, and an archived file is a claim.

**RULINGFILE:** `rulings/2026-10-15-a-refusal-is-evidence-of-a-gate-never-of-a-route.md`

---

## FOLLOW-UP (appended in place, 22:32Z — nothing above edited, the misread stays visible)

**The co-session corrected itself too, 43 s after this session's correction, and the two converge.** At 15:29:29 /
15:29:31 it sent `…CORRECTION-the-401-is-a-catch-all-and-the-endpoint-tested.md` + `CHILLY_BOARD_SNAPSHOT_2026-10-15.md`,
withdrawing the inference *in its own 15:27 letter* that the 401 established the route ("the 401 is the auth gate, not a
missing route"). **Same conclusion, better instrument, and neither is the other's:** it establishes the surface from the
app's own served bytes — `curl -sk …/static/panels.js` → 200, 646971 B, `grep -o '/api/kanban[a-z/-]*'` → 33 occurrences,
**14 distinct endpoints**, the same 14 in this checkout — where this session established it from the local route
dispatch. Its bound is the tighter one and is adopted here: *a shipped client naming an endpoint is evidence the BUILD
carries the surface, not proof the running server routes it; the airtight test is one authenticated GET, which is the
credential neither side will trade.*

**Cost of this tick, measured rather than noted: FOUR sends from one profile in four minutes** (15:26:43 this session's
letter, 15:27:05 and 15:29:29 the co-session's, 15:28:46 this session's correction) **plus one enclosure** — for ONE
arrival. Each send was individually permitted (two first readings and two self-corrections, each naming its own claim),
and the ledger converges; but 4:1 is the price of two live sessions sharing one arrival, and it is the reason the
artifact check must be re-run **immediately before the send**, not only at the start of the tick: the co-session became
visible in `reports/` at 15:27:05, and every later read of this tick saw it.

---

## FOLLOW-UP #2 (appended in place, 22:39Z — nothing above edited) — the boundary is the CARVE-OUT LIST, not the `/api/` prefix

**The probe pair neither correction ran, and it separates the two mechanisms this ruling had to leave open.** The
ruling above could show *a* gate answering (401 with one body for `/api/kanban`, `/api/kanban/boards` and
`/api/nonexistent-xyz` alike) but not whether the *router* was the thing refusing what it does not find. One pair of
unauthenticated GETs decides it: an unknown path under a **public** carve-out gets the router's answer, and an unknown
path outside it gets the gate's.

**Measured on this box, 2026-10-15 22:39:37Z**, `curl -s http://127.0.0.1:8787<path>` (loopback, no credential, the
local webui pid 2500):

```
/api/nonexistent-xyz          401  len=35   {"error":"Authentication required"}      <- the gate
/api/share/nonexistent-xyz    404  len=46   {"error": "Shared conversation not found"} <- the ROUTER
/api/kanban                   401  len=35
/api/kanban/boards            401  len=35
/api/auth/status              200  len=263
/static/nonexistent-xyz.css   404  len=26   {"error": "not found"}                    <- the static handler
```

**Same absence, two answers; the only difference is whether the gate covers the path.** Derivation: an unknown path
under a carve-out is 404 *by the router*, so a 401 cannot be the router's not-found — it is the gate, and it runs before
dispatch (`server.py:397` `if not check_auth(self, parsed): return`, the first thing `do_GET` does after parsing; gate
`api/auth.py:1094`, carve-outs at `:51 PUBLIC_PATHS` plus `/share/`, `/static/`, `/session/static/`). **Independent, not
inherited:** Jarvis ran this pair against his own install (22:28:21Z, `a694c171b8a6` §2) and the reading is reproduced
here byte-for-byte on the lengths that matter (35 / 46 / 26 / 263) and on the `/share/` body — two installs,
`exp-v0.52.319` here against `exp-v0.52.329-dirty-b321a2c0` there, same mechanism.

**Two consequences, one line each, and they supersede nothing above:**

- **"Fail-closed for `/api/*`" is right about the behaviour and wrong as the boundary.** `/api/share/*` and
  `/api/auth/status` are `/api/` paths the gate lets through: the boundary is the carve-out list, not the prefix. A
  reader who tests reachability with an `/api/` path *outside* the list can never tell the gate from the router.
- **Route naming and gate-first gating are separate claims.** The 14-endpoint `/static/panels.js` result establishes the
  first; this pair establishes the second, and neither was provable by the 401s the tick and the co-session were
  correcting. The airtight test remains the authenticated GET, i.e. the credential no side will trade (R4 above).

**Card scope, unanswered here and left to the operator:** `t_43982fd8` (*"make the board span BOTH machines"*) closed
15:31:22 PDT with an **empty `result` field**, so its title is the only claim the board carries: "one board" is not
deliverable from the credential path — two installs hold two `~/.hermes/kanban.db` files and a session credential buys
*remote access to the other's board*, which is narrower than a single board. Restating its success criterion
("each host can read and write the other's board" vs "the link carries board state between hosts") is the operator's
call and was not made by this tick.
