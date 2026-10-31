# Running several agents against one repository

When more than one agent edits the same codebase, the failures are **coordination failures wearing a
measurement costume** — they look like a merge conflict for ten minutes and like a measurement bug for a
week. The fixes below are structural, because a rule stated and not mechanised is a resolution.

## 1. A git worktree per agent, so no two agents share a directory

```bash
git worktree add ../repo_agents/<agent> -b agent/<agent>
git worktree list
```

**A worktree gives each agent its OWN GIT INDEX.** That is the point, and it is mechanical rather than
advisory: `git add -A` in one worktree cannot reach another agent's files or the shared main tree, so the
defect below is made **impossible instead of discouraged**.

**The defect that motivates it:** `git add -A` stages whatever is loose in the tree. In a shared working
directory, `-A` **stages a teammate's deliberately uncommitted work** — one who withheld a file precisely
because others were mid-flight — and lands it in a commit whose message describes something else entirely,
so **the author of that commit cannot say what is in it.** Two habits close the rest: **stage explicit
paths, never `-A`**; and when **you** are the one withholding, **name the files you are holding** so a
teammate's stage cannot silently adopt them.

Verify the isolation rather than asserting it: create a file in one worktree and confirm the main tree
reports **zero** dirty files.

## 2. One owner per file, shared files frozen, the operator as merge gate

Decide in advance which files are **frozen** — the record format, the runner, the gate, the evaluator, and
any registry — and make them the operator's alone, changed in the main tree with a stated reason. **A
sub-agent that needs a frozen file changed STOPS AND ASKS.** A registry or a criterion defined twice is a
criterion that can disagree with itself, and it agrees in the direction that reports success.

**The operator is the single point of accountability: sub-agents report to one agent, not to several.** A
report that arrives by two routes is two reports, which is the same defect as any other second copy of the
truth.

## 3. An agent never scores its own output

**Whoever writes the instrument does not write the criterion and does not call the verdict.** A builder that
grades its own work has chosen the rule it is judged by — and *the rule is the part that has to exist before
the value does*. Keep the criteria, the frozen bars and the verdict with the operator; hand the builder the
simulator and the controls.

## 4. Put the results root OUTSIDE the repo tree if any sweep recurses

Check before choosing: a sweep that globs `**` or walks a tree will eventually **rewrite anything reachable
from it**. Confirm by reading the sweep functions rather than by assuming — `os.walk(root)` and a `**` glob
are both recursive, and a results directory inside the tree is one a future sweep can collect as input.

```
~/workspace/repo                main tree
~/workspace/repo_agents/<name>  one worktree per agent
~/workspace/agent_results/<n>/  a SEPARATE ROOT, outside the repo entirely
```

## 5. A sub-agent whose profile cannot start will discard every message

**Bot-mode messaging is fire-and-forget: the ack is a hand-off to a delivery process, not a delivery
receipt.** A message can return a delivery id and `status: queued` while the recipient's session fails to
start and the message is dropped — **and nothing at the sender's end says so.**

Diagnose by **existence, never by content**:

```bash
# which profiles define the provider key? NAMES ONLY -- never print a value
for p in <agents>; do
  f="$HERMES_HOME/profiles/$p/.env"
  printf '%-18s %s\n' "$p" "$(grep -oE '^[A-Z_]+=' "$f" 2>/dev/null | tr -d '=' | tr '\n' ' ')"
done
```

**A profile declaring `provider: <x>` while its `.env` binds no key for `<x>` is complete-looking and
inert.** Propagate the credential **by name, piping file-to-file** so the value never enters a transcript
that travels, then verify by **name bound + file mode 600** — never by reading it back:

```bash
while IFS= read -r line; do
  name="${line%%=*}"; case "$name" in ''|\#*) continue;; esac
  grep -qE "^${name}=" "$TGT" || printf '%s\n' "$line" >> "$TGT"
done < "$SRC"
chmod 600 "$TGT"
```

**Then prove the route end-to-end by a round trip, not by a probe.** Confirm the recipient *answers* before
handing it work — and until it does, report the message as **queued, outcome pending**, never as delivered.
A route that accepts is not a route that delivers; a profile and a running gateway establish only that the
address exists.
