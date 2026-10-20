# Universal rules

Load for every stage. Read only the active prompt, this file, and required stage/gate rules. Never read every agent, command, skill, template or rule file. OMP already supplies the active prompt; do not reopen it.

## Context and effort policy

- Respect the operator-selected model. Never pin models in workflow prompts or silently switch providers.
- Prefer direct inspection/search/tests over delegation unless independent judgment is required. Keep required independent reviews and final QA.
- Delegate one outcome with exact paths, REQ/TC IDs, bounded scope and compact result. Do not ask agents to repeat orchestration or reread unrelated context.
- Child agents use low thinking, no advisor, no nested spawns, and inherit the active route unless the operator configured overrides. Keep per-spawn effort disabled by default.
- Use one primary author per stage, one independent reviewer at required gates, and specialists only for material risk. Parallel agents are not automatically cheaper.
- Load tools/skills/docs only when relevant: Codegraph for nontrivial dependency impact; Context7 for version-sensitive external APIs; Playwright for browser behavior; Ponytail for implementation guidance; security specialist for security-sensitive scope. Never invoke a tool only to fill a checklist.
- Reuse paths, IDs, digests and existing evidence instead of copying full documents into handoffs. Read full authoritative content needed for the decision; supporting context is on demand.
- For unchanged artifacts already in context, verify identity/freshness without rereading their bodies. New agents must read the specific authoritative inputs needed for their own task.
- Optimize verified outcomes per token. Record real tool calls/results; unknown cost metrics remain unknown. If quota blocks required work, report BLOCKED and let the operator choose a model.

## Scope and risk

Classify work as focused (localized, low-risk, behavior-preserving), full (new behavior, cross-module, migration, uncertain impact), or security-sensitive. If unsure, use full. Focused reduces exploration and verbosity, never approval, review, QA or verification gates. Escalate when scope or risk expands; invalidate affected approvals.

## Stop, escalate and retry policy

Stop exploration and move forward when the current decision has enough source-backed evidence to satisfy its completion condition; do not keep searching for theoretical completeness.

| Stage | Stop when | Escalate or reopen when |
|---|---|---|
| Interview | Goals, route, constraints, non-goals, acceptance outcomes and blocking questions are explicit. | A material behavior, business rule, compatibility or data/security decision remains unknown. |
| Repository exploration | Relevant entry points, callers, tests, contracts and risks are mapped for the proposed change. | Evidence reveals broader coupling, hidden consumers, data migration, security exposure or uncertain compatibility. |
| Design | The approved outcome has a feasible approach, key trade-offs, dependencies and failure/rollback handling. | An unresolved alternative could materially change correctness, risk, cost or scope. |
| Implementation | Every approved task is complete and deviations are recorded. | Scope/acceptance changes, a task cannot be completed safely, or new material risk appears. Stop and return to the relevant approval gate. |
| Review | The assigned manifest was inspected, findings are evidence-backed, and all blocking findings are resolved. | Inputs changed, evidence is missing, or a finding cannot be resolved from available source. |
| Verification | Every required scenario has a current result and all required independent reviews/checks pass for the current source identity. | Any required scenario is FAIL, BLOCKED or NOT_RUN, or source/artifact identity changes. |
| Retry | A concrete failure has a likely cause and the retry targets that cause or invalidated evidence. | Repeated attempts produce no new evidence; report the blocker rather than looping or silently increasing effort. |

- Before each agent/tool call, state the decision it must resolve and the evidence that would change the next action. If neither is clear, do not call it.
- Use one targeted correction cycle for a bounded finding before broadening exploration or effort. Increase effort/model only when the remaining uncertainty is material; the operator controls model selection.
- Re-run only checks and reviews invalidated by changed inputs, plus any dependent checks. Never reuse stale evidence or treat skipped work as PASS.
- Do not optimize for a fixed number of calls. Stop when the gate's evidence requirements are met, not when a token budget is exhausted; if limits block required work, mark BLOCKED and hand back the exact next action.


## Communication and artifacts

- Use `skills/caveman/SKILL.md` style for routine communication only when needed; this compact policy is sufficient in ordinary runs, so do not load the full skill just to save tokens.
- Keep handoffs/status concise and preserve facts, IDs, paths, numbers, errors, uncertainty and evidence. Never trade away safety or correctness.
- Durable artifacts (PRDs, Tech Docs, QA plans, tasks, code comments, commits and PRs) use clear, professional, self-contained prose. Remove filler, not rationale or meaning.
- Use full sentences for security warnings, irreversible actions, confusing situations, ordered steps and approval questions.

## Load and scope

- Always read the installed shared `RULES.md` and `rules/core.md`. If the repository has `.omp/RULES.md`, read it as additional project policy; it may strengthen but must not silently bypass shared gates. Stop if required shared rules or applicable project rules cannot be read.
- Read repository `AGENTS.md`, relevant source and existing human documentation before proposing changes. Inspect OpenSpec config/schema during implementation preparation, after human planning approval.
- Keep one change in `openspec/changes/<slug>/`. Use a kebab-case slug; never overwrite an existing change to start another.
- Record route in `interview.md`: product (new/improved user-facing behavior), engineering (internal technical outcome), or mixed. Ask only when business intent cannot be established from the request.
- No application code, production configuration, migrations, or implementation tests before the implementation gate. Reading source and running existing checks are allowed.

## Readability and evidence

- Prefer short headings, bullets and compact tables; paragraphs at most three sentences. No boilerplate sections with invented content.
- Keep stable `REQ-001` and `TC-001` IDs across artifacts. Each scenario states preconditions, action and observable expected outcome; link tasks and evidence rather than copying paragraphs.
- QA covers positive, negative, boundary, permissions/security, compatibility and affected-feature regressions; add concurrency, performance or migration cases when applicable. Mark N/A with a reason, not silent omissions.
- Report scenario outcomes as PASS, FAIL, BLOCKED or NOT_RUN. Record actual command, exit code and result; browser checks include steps and observed state. Tests alone do not replace a smoke run of the changed path.
- Distinguish observed facts, assumptions and risks. Never weaken tests to match a defect, fabricate delegation/results, or claim existing features cannot regress.
- Status output: `Gate | Evidence/freshness | Blocker | Next command`. Report unavailable dependencies and unrun scenarios honestly.
- Never delete unrelated work, run destructive commands, merge, release, deploy or archive without explicit human authorization.

