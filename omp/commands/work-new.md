---
description: Start a gated product or engineering change.
---
## Load

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Request: $ARGUMENTS. This is free text, not a required slug. Read repository `AGENTS.md`, OpenSpec config, existing changes/specs and relevant source before choosing a new kebab-case slug.
- Inspect installed `openspec --help` and schema/artifact instructions before creating the change. Stop if OpenSpec is unavailable; never overwrite an existing change.

## Interview

- Dispatch the interviewer with the request and repository context. If author dispatch is unavailable, read and adopt its instructions and disclose that substitution.
- Write `openspec/changes/<slug>/interview.md`. Establish product, engineering or mixed route from intent, not file type. Record users, current/desired behavior, goals, constraints, compatibility, non-goals, stable `REQ-` IDs, confirmed facts, assumptions and blocking questions.
- Ask one to three focused questions per round; do not invent answers. Record dependency invocations, versions and limitations per shared rules, using installed help rather than guessed APIs.
- Before revising an existing artifact, read it and recompute upstream manifests. Preserve human decisions; any changed/missing/added input invalidates dependent approvals, reviews, tasks and verification.
- Do not create implementation code/tests or draft the spec before the interview gate passes.

## Handoff

- Record evidence, unanswered blockers, route and next gate in `interview.md`; do not record human approval.
- When complete, next: `/work-review <slug> interview`, then `/work-approve <slug> interview`. Stop for the explicit human decision before `/work-spec <slug>`.
