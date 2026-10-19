---
description: Archive a completed change.
---
## Load and gate

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Read all existing `openspec/changes/$1/` artifacts, reviews, approvals and repository state before changing anything.
- Re-enumerate inputs and recompute every upstream SHA-256 manifest and implementation identity, including dirty tracked files, relevant untracked files and deletions. Require current approvals/reviews, complete task evidence, all required scenarios PASS, independent QA and reviewer PASS, no unresolved review defects and installed OpenSpec validation PASS.
- Missing, stale, changed/missing/added inputs or NOT_RUN evidence block archive. Request renewed affected approvals/verification rather than inferring success.

## Authorize and archive

- Show the human current verification evidence, manifests, remaining risks and the exact archive scope. Ask for explicit archive authorization bound to these inputs; invocation, merge/release approval or a generic "continue" is not archive authorization.
- After authorization, recompute manifests and source identity. If anything changed, stop for renewed verification/authorization. Append the human decision reference/quote, UTC timestamp, scope and manifests to `approvals.md`; never alter historical decisions.
- Only after current verification and human archive authorization, reconcile OpenSpec task checkboxes from proven completion in `verification.md`. Record the completion-only before/after digest change and its authorization; preserve task wording, dependencies and scope. Any other task edit requires renewed tasks review/approval.
- Inspect installed OpenSpec help/config and run supported validation again after checkbox reconciliation. Record the real command/result; stop if validation fails.
- Use only the installed, documented OpenSpec archive lifecycle for this change. Do not invent flags or bypass validation. This authorization permits archive only, not merge, release, deployment or unrelated destructive actions.

## Handoff

- Record the archive command/result, destination, human decision, checkbox reconciliation, final evidence and outstanding risks in the change records retained by OpenSpec. Never claim archive succeeded without tool evidence.
- Report the final state and next gate: archived, or the exact blocker/renewed approval needed. Any merge/release decision remains separately human-authorized.
