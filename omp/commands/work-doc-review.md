---
description: Independently review and approve the human planning documents before OpenSpec.
---

## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md`, `rules/planning.md` and `rules/gates.md`; do not load unrelated stage rules. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Scope

- Change slug: $1. Review the complete applicable human bundle together: `interview.md`, `prd.md` when applicable, `design.md` when applicable and `task-breakdown.md`. Do not review derived specs as a substitute; they must not exist yet.
- Route-required vs N/A applicability is part of the review; an N/A must carry a recorded reason.
- This command owns the single `human-planning` checkpoint. Do not request separate interview, PRD, design or task-breakdown approvals.

## Independent review

- Dispatch a separate reviewer run that authored none of the documents; if independent dispatch is unavailable, record BLOCKED. Never adopt the reviewer role to pass your own bundle.
- Build the bundle's sorted path/SHA-256 manifest per `rules/gates.md`, including the actual path set so added or missing files invalidate it.
- Review whether a new reader can understand the problem without the transcript, prose is clear, facts and assumptions are distinct, PRD and design agree, requirements are testable, scope and non-goals are explicit, the approach is feasible, risks and rollback are addressed, the task breakdown covers the work, and REQ IDs are consistent.
- For security-sensitive scope or a credible finding, require a separate security-engineer PASS bound to the same manifest; otherwise the reviewer records a specific N/A rationale.
- Require a recorded PASS/CHANGES_REQUESTED/BLOCKED verdict in `review.md` with the manifest. Repair CHANGES_REQUESTED findings in the owning document and re-review only the changed inputs and prior findings. Do not pass unresolved material gaps.

## Human planning checkpoint

- On PASS, recompute the manifest and present: document paths, one-line scope/risk, review findings, open questions and the exact manifest identity. Use the checkpoint format from `rules/gates.md`.
- Ask once for `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>` or `pause` via built-in `ask`, stating each option's consequence and a recommendation based on the verdict. Silence, "continue", a prior approval or the invocation is not a decision.
- `approve`: record the `human-planning` decision with the canonical protocol, then continue to `/work-prepare $1` in the same turn. `approve stop`: record and stop. `reject`: record without approval, route to the owning author and stop. `revisit`: reopen the named planning stage and mark dependents stale. `pause`: write nothing and point to `/work-resume $1`.
- Never record approval on the operator's behalf. Review PASS is not approval, and human-planning approval does not authorize code.
