---
description: Archive a completed change.
---
## Rule loading

Load `RULES.md`, `rules/core.md`, `rules/execution.md`, `rules/verification.md`, and `rules/gates.md`.

## Load and gate

- Always read installed shared `RULES.md` and `rules/core.md` from `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`, then project `.omp/RULES.md` if present as additive policy. Resolve stage-rule paths under that shared base per its entrypoint. Stop if any required shared or applicable project policy is unreadable. Apply its dependencies, artifact ownership, stricter gates and freshness protocol.
- Change slug: $1. Read all existing `openspec/changes/$1/` artifacts, reviews, approvals and repository state before changing anything.
- Re-enumerate inputs and recompute every upstream SHA-256 manifest and implementation identity, including dirty tracked files, relevant untracked files and deletions. Require current approvals/reviews, complete task evidence, all required scenarios PASS, independent QA and reviewer PASS, no unresolved review defects and installed OpenSpec validation PASS.
- Run OpenSpec validation and other shell checks through `rtk` per shared rules; preserve raw output and exit status.
- Missing, stale, changed/missing/added inputs or NOT_RUN evidence block archive. Request renewed affected approvals/verification rather than inferring success.

## Authorize and archive

- If `approvals.md` already contains a current human archive authorization matching these exact inputs, proceed without asking again. Otherwise show the evidence, manifests, remaining risks and exact archive scope, then present one checkpoint: `approve` (authorize archive only), `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`. Invocation, merge/release approval or a generic "continue" is not archive authorization.
- `approve`: recompute manifests and source identity after the decision. If unchanged, append the human decision reference/quote, UTC timestamp, scope and manifests to `approvals.md`, then archive in the same turn. If anything changed, stop for renewed verification/authorization. `reject` records the decision without authorization; `revisit` reopens the named stage; `pause` writes nothing and points to `/work-resume $1`.
- Only after current verification and human archive authorization, reconcile OpenSpec task checkboxes from proven completion in `verification.md`. Record the completion-only before/after digest change and its authorization; preserve task wording, dependencies and scope. Any other task edit requires renewed tasks review/approval.
- Inspect installed OpenSpec help/config and run supported validation again after checkbox reconciliation. Record the real command/result; stop if validation fails.
- Use only the installed, documented OpenSpec archive lifecycle for this change. Do not invent flags or bypass validation. This authorization permits archive only, not merge, release, deployment or unrelated destructive actions.

## Handoff

- Record the archive command/result, destination, human decision, checkbox reconciliation, final evidence and outstanding risks in the change records retained by OpenSpec. Never claim archive succeeded without tool evidence.
- End with one final checkpoint: archived state, artifacts, remaining risks and next options (`pause`, or a separately authorized merge/release). Do not start merge, release or deployment.
