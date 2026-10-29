---
description: Create the human-readable Tech Doc and task breakdown.
---

## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/planning.md`; load `rules/execution.md` only when implementation details are needed for impact analysis. Load `rules/gates.md` for decisions. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Read the change's `interview.md`, applicable `prd.md` and relevant source/repository instructions. Inspect existing capability specs under `openspec/specs/` to evaluate technical delta impact on existing architectural contracts. Stop on blocking questions or an incomplete interview.
- Do not create OpenSpec change artifacts, delta specs or schema `tasks.md` here; execution preparation owns them after `human-planning` approval.
## Technical planning

- Dispatch `tech-lead`; disclose if adopting the role directly.
- Resolve `TECH-DOC.md` and `HUMAN-TASK-BREAKDOWN.md` through shared template resolution.
- Write `design.md` for engineering/mixed work and for product work needing technical decisions: current behavior, proposed architecture and flow, rationale, alternatives, contracts, data impact, failure modes, security, compatibility, rollout and rollback, with a 2–4 sentence executive summary.
- Write `task-breakdown.md` as a readable milestone/work-package sequence with dependencies, affected areas, risks and completion outcomes. Keep a focused change proportional and escalate to full when impact analysis widens scope.
- Link stable REQ IDs to decisions and work packages; surface decisions that need the operator. Avoid repeating the PRD and avoid schema-specific checkboxes as the primary presentation.
- Use Codegraph/LSP for non-obvious impact and confirm in source; record coverage limits if unavailable. Use Context7 for relevant external documentation per core policy.

## Handoff

- Continue to `/work-review $1 human-planning` when both documents are complete and no material question remains; otherwise stop and ask.
- The applicable human bundle is reviewed and approved once as `human-planning` via `/work-review $1 human-planning` → `/work-approve $1 human-planning`; do not request a separate design or task-breakdown approval.
