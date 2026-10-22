---
description: Independently review a human-planning or execution bundle.
---

## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/gates.md`; load `rules/planning.md` for bundle reviews, plus `rules/verification.md` when the assigned review includes final evidence. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Optional target: $2, one of `human-planning` or `execution`. Final implementation review runs inside `/work-verify`; do not review a legacy `interview`/`spec`/`test-plan`/`tasks` target as if it were a bundle.
- Infer the target only when existing artifacts and fresh decisions identify it unambiguously; otherwise ask which bundle, without inventing readiness.
- Read the change artifacts, reviews and approvals. Recompute the target's sorted path/SHA-256 manifest per `rules/gates.md`, including added and missing paths. Upstream prerequisite approvals must be current; the target itself is not yet approved.
- If a current matching PASS exists for the same target and manifest, reuse it and skip dispatch. Re-review only when inputs, target or findings changed.

## Independent review

- Dispatch a separate reviewer run independent of the authors, implementation, QA and security run. No self-review or role-adoption fallback: if dispatch or independence is unavailable, append BLOCKED with the reason.
- `human-planning`: `interview.md`, applicable `prd.md`/`design.md` and `task-breakdown.md` together. `execution`: that complete human bundle, proposal, every delta spec, `test-plan.md`, `tasks.md` and OpenSpec config/schema inputs.
- Review fidelity to approved human intent, REQ/TC/task traceability, complete coverage, feasibility and dependencies, compatibility/security/regression work, visible open decisions and successful installed-schema validation evidence for `execution`.
- Check the handoff for actual OpenSpec, Ponytail, Codegraph/LSP, Context7, Playwright and RTK invocations; a missing required invocation or N/A reason prevents PASS. Do not rerun tools only to populate evidence.
- For security-sensitive scope or a credible finding, require a separate security-engineer PASS bound to the same manifest; otherwise the reviewer records a specific N/A rationale.
- Require correct source-backed reasoning, not summaries alone. Separate confirmed defects from suspicions and give file/line or artifact evidence.
- Append one record to `review.md`: target, reviewer identity/run, UTC timestamp, complete input manifest, findings, risks and PASS/CHANGES_REQUESTED/BLOCKED. Preserve prior records and never edit author artifacts to force a pass.
- Recompute manifests after review; changed inputs keep the result only as historical evidence and require affected re-review.

## Handoff

- On PASS, present the review result and manifest identity, then name the single decision command: `/work-approve $1 human-planning` or `/work-approve $1 execution`. Do not record the decision here and do not treat this command's invocation as approval.
- On CHANGES_REQUESTED, route findings to the owning author, allow one repair cycle on the changed inputs, and re-review; then present the findings if it still fails.
- On BLOCKED, state the exact missing prerequisite. Never advance a stage, archive, merge or deploy.
