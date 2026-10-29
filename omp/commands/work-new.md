---
description: Start a gated product or engineering change.
---

## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. This command activates the workflow only for this request and change; an unrelated later request does not inherit it. Invoking the command is not approval.
- Read `rules/core.md` and `rules/planning.md`; load `rules/gates.md` for checkpoint recording and transitions. Do not load unrelated stage rules. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}` and read project `.omp/RULES.md` when present; stop if required policy is unreadable.

## Load

- Request: $ARGUMENTS. Free text, not a required slug. Read repository `AGENTS.md`, existing human documentation, relevant source and tests before choosing a kebab-case slug.
- Inspect existing project capabilities and active specifications using `rtk proxy openspec context` and `rtk proxy openspec list --specs` to ground the change in current architecture and avoid duplicate requirements.
- Create `openspec/changes/<slug>/` only when unused; never overwrite an existing change. Do not create `proposal.md`, delta specs or schema tasks before `human-planning` approval.
- Route genuinely needed shell commands through RTK per core policy and keep the real result.

## Interview

- Dispatch the interviewer with the request and repository context; if dispatch is unavailable, adopt its instructions and disclose it.
- Use built-in `ask` for each unresolved material choice: 2–5 concrete options, trade-offs and a recommendation, with a custom/free-text path. Record the selected option and rationale automatically; never invent a selection from silence, skip or timeout. If `ask` is unavailable, disclose it and ask concise numbered questions awaiting an explicit answer.
- Inspect before asking, and never ask for facts source already answers. Challenge an unsafe or inconsistent preference with source-backed evidence.
- Establish the product/engineering/mixed route from intent and focused/full effort with escalation triggers. Focused work reduces exploration and verbosity, never review, approval, QA or verification.
- Write `openspec/changes/<slug>/interview.md` with users, current/desired behavior, constraints, compatibility, non-goals, stable `REQ-` IDs, selected decisions with rationale, facts, assumptions and blocking questions.
- Reuse settled decisions; leave OpenSpec schema inspection and generation to execution preparation after `human-planning` approval.
- Stop when the interviewer's readiness checklist passes and no blocking unknown remains; a finished round, a drafted artifact or "continue" does not end it.

## Handoff

- Continue to the human planning commands: `/work-product-plan <slug>` when a PRD applies, then `/work-tech-plan <slug>`. Those draft the human bundle only.
- The bundle's single pre-build checkpoint is `/work-review <slug> human-planning` → `/work-approve <slug> human-planning`. Do not request a separate interview review or approval, and do not create application code, tests or derived specs.
- Report the route, artifacts, evidence visibly missing, blocking questions and the next command.
