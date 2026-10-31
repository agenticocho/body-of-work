# Agent sessions: the pinned model, and the DM transport

The agent-session surface has two things that mislead in the same way: a session's model is **stored
per session** and a message's delivery is **stored per lease**, and in both cases a supported-looking
setting or a successful-looking send is not the fact you wanted.

## A session's model is PINNED in its own store and WINS over the profile config

**Editing `config.yaml` does not change what a RESUMED agent runs.** The session row carries its own
model, so a config change reaches only sessions created *after* it — which is how ten agents kept running
a retired model through a config migration that looked complete.

```
python3 - <<'PY'
import sqlite3
c = sqlite3.connect('file:$HOME/.hermes/profiles/<p>/state.db?mode=ro', uri=True)
for r in c.execute("select id,title,model,billing_provider from sessions").fetchall():
    print(r)
PY
```

- The columns that matter: `sessions.model`, `sessions.billing_provider`, `sessions.model_config`.
- **`follow_profile_config: true` does NOT do what its name says.** A session carrying it *and* a pinned
  `model` keeps using the pin. Do not treat that flag as evidence the config governs — the flag is the
  thing that made the migration invisible.
- **`session_model_usage` is a LEDGER, not a route.** Rows accumulate across every model and provider the
  session has ever used, so reading "the" row is a proxy for the session's current model. The route is
  `sessions.model`.
- **The billing/provider column is historical too** — it records what a session *used*, not what a resume
  will *do*. A second model id that resolves through the current provider is an **alias**, not a route
  change: run one session on each id and ask each to name itself before treating the difference as real.

### The overrides do not persist — measure before believing otherwise

- `hermes -p <p> chat -q '<prompt>' -m <model>` **runs the turn on that model and does NOT write the pin**.
- Piping a prompt (or a slash command) into `hermes ... chat --resume <id> -Q` **does not run a turn at
  all**. `-q` is the one-shot form that actually executes; a run reporting `Duration: 0s` **did not run**,
  so read that before concluding an override failed to persist.
- There is **no `hermes sessions` subcommand that sets a model**, and `hermes migrate` covers only the
  retired-model namespaces it ships with. Do not spend a cycle hunting for the supported verb — the
  pinned column is the mechanism.

### The fix, and the proof

Back up each `state.db` (`state.db.bak-<stamp>`), then `UPDATE sessions SET model=?, billing_provider=?,
model_config=? WHERE id=?` for the sessions that matter — **and change only the sessions that are agent
config, leaving deliberate local-model test sessions alone** (a local-model test that runs on a hosted
model is not a test of the local model): name them rather than silently sweeping them.

**The proof is a resume with NO `-m`** whose reply names the new model. A store that reads correctly is not
a session that is running it — and a changed row takes effect on the session's **next open**, not mid-turn.

## Where the DM transport actually fails

```
DROPS            target_busy: "open on another surface right now" -- FAILS FAST, message NOT delivered
an undrained spool
LAG
the recipient's MODEL COLLAPSES   a repetition loop discards the answer; the message ARRIVES, no reply exists
```

- **A send OCCUPIES the lease it is trying to get past.** A bot-mode delivery takes the target's
  turn-lease for ~300 s, renewed per turn — so a retry contends with the very thing it is retrying
  against: five sends produced five `target_busy` refusals and **zero** deliveries, and the count grew
  while sending continued. **Stop, let the queue drain, then send ONCE.**
- **Kill by MESSAGE IDENTITY, never by process age.** Choosing which queued delivery to keep by pid age
  killed the one carrying the message that mattered. Read each process's own `dm-*.txt` argument and
  match on that.
- **A lease row outliving its holder is not automatically free.** Check `/proc/<pid>` for the holder: if
  it is ALIVE, leave it alone — killing it frees the lease for the next queued process, not for you, and
  the cycle repeats.
- **A model change does not reach a session that is already OPEN.** A stored value is not a live one, and
  stale *holders* keep a pre-change process alive: the loops continued because the process predated the
  pin. `runtime/active_sessions.json` in the profile names the live holder.
- **A display label is not a route.** A resume banner can print the retired model name while the session
  runs the new one. Verify against the session row and the reply, never the banner.

## The rule that makes the transport survivable

**Anything that must reach a peer belongs in the RECORD first.** A message is a pointer; a pointer can
fail, and when it fails the claim it carried has no account anywhere — measured: a decision sent only as a
DM failed twice and existed in no file while it was failing. **File the artifact, then announce it**, and
land peer-critical content on a leg you have VERIFIED delivers (a shared repo the peer reads) rather than a
transport that has been intermittently unclaimable.

## Diagnosing a degenerating agent

- **Attributing a repetition loop to one model and calling it fixed is an over-claim.** A loop that
  recurs after the model changes had that model as a **contributor**; the signature can change (a whole
  delivery corrupted before, only deliberation after) while the presence does not. **Severity and presence
  are different quantities** — say *contributor* until a recurrence is gone.
- **Name a cause as a HYPOTHESIS, with the observation that would settle it, and make the test cheap.**
  "Start a fresh session and report whether it recurs in N turns" is a defined experiment: recurrence
  eliminates the variable, absence supports it, **either outcome is a result**. A half-measure (compressing
  the context instead) leaves the variable half-changed and the observation uninterpretable.
- **Do not start substantial work inside the session under test** — it confounds the test for the same
  reason.
- **Write the queue to a durable file before the session turns over.** A queue that lives only in a
  transcript dies with the transcript; put the open items and their state (read from files, not recalled)
  somewhere in the profile ROOT, not under a pruned scratch path.
