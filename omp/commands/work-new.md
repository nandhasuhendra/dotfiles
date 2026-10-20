---
description: Start a gated product or engineering change.
---

## Rule loading

- Read the installed shared `RULES.md` and `rules/core.md` before acting. Also read `rules/planning.md`; load `rules/gates.md` when recording approvals or transitioning stages. Do not load unrelated stage rules.
## Load

- Always read installed shared `RULES.md` and `rules/core.md` from `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`, then project `.omp/RULES.md` if present as additive policy. Resolve stage-rule paths under that shared base per its entrypoint. Stop if any required shared or applicable project policy is unreadable. Apply its dependencies, artifact ownership, stricter gates and freshness protocol.
- Request: $ARGUMENTS. This is free text, not a required slug. Read repository `AGENTS.md`, existing human documentation and relevant source before choosing a new kebab-case slug. Do not inspect/generate OpenSpec specs during interview.
- Create a human-planning workspace under `openspec/changes/<slug>/` only if unused. Do not create `proposal.md`, delta specs or agent tasks until the human planning bundle has passed review and approval.
- Inspect existing docs and relevant source first. Do not invoke dependency CLIs or run shell commands merely to complete the interview; if a shell command is genuinely needed, use `rtk` per shared rules and record its real result.

## Interview

- Dispatch the interviewer with the request and repository context. If author dispatch is unavailable, read and adopt its instructions and disclose that substitution.
- Ask one to three plain-language questions per round, following the interviewer's question sequence. Prefer OMP's built-in `ask` selector for answerable choices, with an Other/custom free-text path; allow Skip/Not sure only when the question is optional, and do not auto-select or infer approval. For open-ended detail, request free text. If `ask` is unavailable (including non-interactive sessions), use concise numbered text questions instead. Keep interviewing until its readiness checklist passes; a finished round, a drafted artifact or "continue" does not end the interview. Follow up on vague or conflicting answers instead of filling gaps yourself.
- Write `openspec/changes/<slug>/interview.md`. Establish product, engineering or mixed route from intent, not file type. Classify focused/full effort with evidence and escalation conditions. Focused changes use concise documentation and scoped exploration but retain every required review, approval, QA and verification gate; do not imply a fast-track gate bypass. Record users, current/desired behavior, goals, constraints, compatibility, non-goals, stable `REQ-` IDs, confirmed facts, assumptions and blocking questions.
- Summarize the fitted requirements and ask "Is anything wrong, missing or out of scope?". Record confirmed facts, assumptions and blockers. Defer dependency/version discovery until a later stage actually needs it.
- Before revising an existing artifact, read it and recompute upstream manifests. Preserve human decisions; any changed/missing/added input invalidates dependent approvals, reviews, tasks and verification.
- Do not create implementation code/tests or draft the spec before the interview gate passes.

## Review and checkpoint

- Once the readiness checklist passes, dispatch the independent interview reviewer. If it returns CHANGES_REQUESTED, repair the named gaps and re-review once; if it still fails, present the findings and the decision menu.
- On review PASS, present the shared human checkpoint: route, artifacts, what changed, open questions, manifest identity and the options `approve`, `approve stop`, `reject: <reason>`, `revisit: <question/stage>`, `pause`. Do not ask the human to run `/work-review` separately.
- `approve`: record interview approval with the shared protocol, then continue to `/work-product-plan <slug>` in the same turn. `approve stop`: record and stop.
- `reject`: record the rejection without approval and reopen the interview around the stated reason. `revisit`: reopen the named requirement and repeat review. `pause`: record nothing; the next action is `/work-resume <slug>`.
- Never record approval on the human's behalf or continue after a rejection, silence or unrelated reply.
