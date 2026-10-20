# Universal rules

Load for every stage. Then load only the stage and gate rules required by the assigned task.

## Context and effort policy

### Model-agnostic routing and delegation budget

- Respect the operator-selected active model for each session; never force a provider/model in workflow prompts. Model availability and quotas may change between tasks. Subscription OAuth still has usage limits.
- Before dispatch, prefer deterministic inspection, targeted searches and existing tests over agent calls unless independent judgment is required.
- Preserve required independent gate reviews and final QA; batch related findings into one bounded review per gate, not speculative parallel reviews.
- Each delegation specifies one outcome, exact artifact paths, relevant REQ/TC IDs, bounded source scope and a compact result. No broad repository tours or repeated full documents.
- Split work by coherent deliverable only when it reduces repeated context. Parallel agents are not automatically cheaper.
- If the active model is unavailable or quota-limited, report the blocker and let the operator switch models. Never silently switch to a paid provider.
- After fixes, rerun invalidated reviews/checks against fresh manifests; do not repeat unaffected stages.
- Do not truncate authoritative inputs or verification evidence to meet an arbitrary token budget.

### Child-agent budget

- Child agents default to `thinking-level: low`, `advisor: false`, and `spawns: []`. They do not launch nested agents or their own advisor model.
- Do not pin a child to a separate expensive model by default. Unless the operator has explicitly configured `task.agentModelOverrides` or a role override, OMP resolves the child using the parent's active model route; the child still uses its configured low thinking level.
- Keep child assignments narrow: one deliverable, relevant artifact paths, acceptance criteria, and a short output contract. Do not ask a child to redo the main agent's orchestration or reread unrelated project context.
- The main agent owns synthesis, decisions, escalation, and user communication. If a child result is ambiguous, incomplete, or conflicts with evidence, first ask for a focused correction; escalate effort/model only for a material unresolved risk. Never use low effort as permission to skip independent required reviews or verification.
- Keep `task.enableEffort: false` unless per-spawn effort is deliberately needed. When enabled, a caller-provided `effort: hi` can override an agent's configured thinking level; prose instructions alone are not a reliable cap.


- Optimize for verified outcomes per token. Default to **cost-aware mode**: one primary model authors each stage; dispatch an independent reviewer only at the required gate; use specialist agents and tools only when the risk or task requires them. Do not fan out agents for parallel opinions on routine work.
- Reuse authoritative files by path and digest; never paste the same full document into successive agent handoffs. Send compact paths, manifests, REQ/TC IDs and decisions, not repeated document bodies.
- Classify each change during interview as **focused** (localized, behavior-preserving, low-risk), **full** (new behavior, cross-module change, migrations, security/privacy, external contracts, or uncertain impact), or **security-sensitive**. Record rationale and escalation triggers in `interview.md`. If unsure, use full. Security-sensitive changes include authn/authz, tenant isolation, secrets, sensitive data, trust boundaries, payment, dependency/security configuration, migrations with integrity risk, and exposed external interfaces.
- **Focused** reduces exploration depth and artifact verbosity, not human approval or evidence integrity. Keep the human Tech Doc/task breakdown, review checkpoints, OpenSpec validation, QA coverage and independent final verification. Keep artifacts concise and mark irrelevant sections N/A with reasons. Never invent a PRD for engineering-only work.
- **Full** uses deeper impact exploration and additional specialists when justified. Escalate focused to full if scope expands, compatibility is uncertain, data/schema/auth changes emerge, or a reviewer finds material risk; invalidate affected approvals.
- Do not automatically run Context7, Codegraph, Playwright, Ponytail or every specialist at every stage. Use each when it materially informs a decision: Codegraph for nontrivial call/dependency impact; Context7 for version-specific external APIs; Playwright for browser behavior; Ponytail for implementation approach; security-engineer for security-sensitive scope. Record N/A briefly when not applicable.
- At each stage, read complete authoritative inputs required for that decision. Read only relevant source files, test files and dependency docs; expand on discovered callers, risks, or review findings. Do not summarize away requirements, security concerns, or evidence.
- In a continuous session, do not re-read unchanged shared policy or artifact bodies already available in context merely to restate them; verify current file identity/freshness before relying on them. A new agent/session must read the required policy and source documents itself. Digests establish identity, not comprehension.
- Handoffs should contain change slug, route/effort, authoritative paths and digests, REQ/TC IDs, decisions, blockers and next action. Avoid transcript dumps, redundant summaries, and repeated tool/version discovery when existing evidence is current and applicable.
- Collect per-change efficiency evidence when available: input/output tokens, agent calls, review loops, wall time and verification results. Report unknown values as unknown; RTK output reduction is not a token benchmark.


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


## Caveman communication; human-quality artifacts

- Use the bundled `skills/caveman/SKILL.md` communication style for routine agent-to-agent handoffs, tool status and conversational replies: answer first, remove ceremony, keep wording short, and preserve every material fact.
- Shared core policy below is the lightweight operational form; do not repeatedly paste or reload the full skill when these rules are already in context. If the host supports skill activation, activate `caveman`; otherwise follow these rules directly.
- Keep code, commands, paths, identifiers, numbers, units, errors, and required negations exact. Never trade away correctness, safety, traceability, uncertainty, or required evidence for fewer tokens.
- **Do not use caveman style in persisted artifacts.** PRDs, Tech Docs, QA plans, task breakdowns, code/comments, commits, PRs, issues, approvals and other durable outputs use clear, professional prose. These outputs must stand alone for their intended human readers.
- For human documentation, explain the problem and rationale before dense tables; define domain terms/acronyms; state decisions, trade-offs, assumptions and risks; use concise paragraphs, helpful headings and tables only when they improve comprehension. Remove filler, not meaning.
- If brevity and clarity conflict, choose clarity. Use complete sentences for security warnings, irreversible actions, confusing situations, step sequences and questions/approval choices.

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

