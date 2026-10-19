---
description: Independently review and approve the human planning documents before OpenSpec.
---

## Rule loading

- Read the installed shared `RULES.md` and `rules/core.md` before acting. Also read `rules/planning.md` and `rules/gates.md` for review, approval and freshness requirements; do not load unrelated stage rules.
## Scope

- Read project rules and recompute manifests for interview, PRD, Tech Doc and human task breakdown.
- This is the human-first review gate. Do not review OpenSpec specs as a substitute; they should not exist yet.

## Independent review

- Dispatch an independent reviewer that did not author the documents. If independent dispatch is unavailable, mark BLOCKED.
- Review the complete applicable human bundle together: `interview.md`, `prd.md` when applicable, `design.md` when applicable and `task-breakdown.md`.
- Check whether a new reader can understand the problem without the chat transcript; prose is clear; facts and assumptions are distinguished; PRD and Tech Doc agree; requirements are testable; scope/non-goals are explicit; the approach is feasible; trade-offs, failure/security/compatibility risks and rollback are addressed; the task breakdown covers the work; open decisions are visible; REQ IDs are consistent.
- Return section-specific findings, contradictions and a PASS / CHANGES_REQUESTED / BLOCKED verdict. Do not rewrite the author's work during review.
- If changes are requested, route to the owner and review again after repair. Do not pass with unresolved material gaps.

## Human planning checkpoint

- On PASS, show document paths, concise summary, important trade-offs/open questions, reviewer verdict and exact manifest identity.
- Ask for `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>` or `pause`.
- Approval binds the human planning documents only. On `approve`, record approval and continue to `/work-prepare $1`; on `approve stop`, record and stop. Never create or authorize OpenSpec artifacts before approval is recorded and the manifest rechecked.
