---
description: Archive a completed change.
---
## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md`, `rules/execution.md`, `rules/verification.md` and `rules/gates.md`. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. This command runs only for an explicit archive request; review-ready status alone does not start it.
- Read all change artifacts, reviews, approvals and repository state. Recompute every upstream manifest and the implementation identity, including dirty tracked files, relevant untracked files and deletions.
- Require review-ready evidence: every required scenario PASS, fresh independent QA and reviewer PASS, risk-required security PASS or a specific N/A rationale, no unresolved blocking defect and installed OpenSpec validation PASS. Missing, stale or NOT_RUN evidence blocks archive.
- Legacy changes map only through an independently reviewed mapping and an explicit human decision; old approvals never become new authority.
- Route shell checks through RTK per core policy and preserve raw output and exit status.

## Authorize and archive

- If `approvals.md` already records a current human archive authorization matching these exact inputs, proceed without asking again.
- Otherwise show evidence, manifests, remaining risks and the exact archive scope, then present one checkpoint via built-in `ask`: `approve` (authorize archive only), `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`. Invocation, merge/release approval or "continue" is not archive authorization.
- `approve`: recompute manifests after the decision. If unchanged, append the decision reference/quote, UTC timestamp, scope and manifests to `approvals.md`, then archive in the same turn. If anything changed, stop for renewed verification and authorization. `reject` records the decision without authorization; `revisit` reopens the named stage; `pause` writes nothing and points to `/work-resume $1`.
- Only after current verification and archive authorization, reconcile schema task checkboxes from proven completion in `verification.md`. Record the completion-only before/after digest change; preserve task wording, dependencies and scope. Any other task edit requires renewed execution review and approval.
- Use only the installed, documented OpenSpec archive lifecycle for this change; inspect its help and validate again after reconciliation, recording the real command and result.

## Handoff

- Record the archive command/result, destination, decision, reconciliation and outstanding risks in the retained change records. Never claim archive succeeded without tool evidence.
- This authorization permits archive only. Merge, PR, release and deployment require separate explicit requests; do not start them.
