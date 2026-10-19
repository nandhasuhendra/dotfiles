---
description: Show change status and next action.
---
## Load and inspect

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Read existing `openspec/changes/$1/` artifacts, append-only approvals/reviews, verification evidence and repository state. If missing, report that fact; do not initialize a replacement.
- Re-enumerate all route/schema inputs and recompute each gate's sorted path/SHA-256 manifest with real hashing tools. Compare complete path sets as well as bytes so added/missing files invalidate dependent approvals, reviews, tasks and verification.
- Check each human decision and matching independent target review, unresolved blockers, required artifacts, validation evidence and task completion evidence. Approved `tasks.md` stays frozen; use `verification.md` for execution completion.
- Recompute current source identity, including changed tracked files, relevant untracked files and deletions, against verification evidence. HEAD alone does not establish freshness.
- Read dependency readiness and existing command/scenario results; do not invent PASS from file existence, timestamps, checked boxes, an old approval or an unavailable tool. Distinguish missing evidence, stale evidence, FAIL, BLOCKED and NOT_RUN.
- Run any shell checks through `rtk` per shared rules. Report actual tool invocations or N/A reasons, and use `rtk gain -p` only as adoption evidence, not correctness.

## Report

- Present `Gate | Evidence/freshness | Blocker | Next command` for interview, spec, test-plan, tasks, implementation, verification and archive as applicable.
- Cite artifact paths, actual digest comparisons, review identities and observed command/browser evidence. Include dependency limitations, invalidated records, assumptions and risks.
- Recommend exactly one next action with the command or checkpoint options. A completed artifact's review runs as part of its stage command; a pending decision uses `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>` or `pause`. A verification PASS still needs explicit archive authorization.
- This command is read-only: do not edit artifacts, append approvals, dispatch author work, execute implementation checks or advance a gate.
