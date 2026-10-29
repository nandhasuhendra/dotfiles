---
description: Show change status and next action.
---
## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/gates.md`; load a stage rule only when interpreting that stage's evidence. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and inspect

- Change slug: $1. This command is read-only: do not edit artifacts, append approvals, dispatch author work, run implementation checks or advance a gate.
- Read the change artifacts, append-only approvals/reviews, verification evidence and repository state. If the change is missing, report that fact; do not initialize a replacement.
- Recompute each bundle's sorted path/SHA-256 manifest, comparing complete path sets as well as bytes so added or missing files invalidate dependent records.
- Check human decisions against their manifests, matching independent review verdicts, unresolved blockers, required artifacts, validation evidence and task completion. Run `rtk proxy openspec status --change $1` and `rtk proxy openspec validate $1` to report schema status alongside workflow gates. Approved `tasks.md` stays frozen; completion comes from `verification.md`.
- Compare verification against current implementation identity including dirty tracked files, relevant untracked files and deletions; HEAD alone does not establish freshness.
- Report missing, stale, FAIL, BLOCKED and NOT_RUN distinctly; never infer PASS from file existence, timestamps, checkboxes, an old approval or an unavailable tool. Legacy-target changes report the mapping obligation, never implicit authority.

## Report

- Present `Gate | Evidence/freshness | Blocker | Next command` across `human-planning`, `execution`, implementation, verification and optional archive as applicable.
- Cite artifact paths, actual digest comparisons, review identities and observed evidence. Include dependency limits, invalidated records, assumptions and risks.
- Recommend exactly one next action: the stage command, `/work-approve <slug> <target>` for a pending decision, or `/work-resume <slug>`. Review-ready is terminal; archive is a separate request.
- Route any shell hashing through RTK per core policy and preserve raw output.
