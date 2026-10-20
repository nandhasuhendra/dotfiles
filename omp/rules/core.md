# Universal rules

Load for every stage. Then load only the stage and gate rules required by the assigned task.

## Context and effort policy

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

