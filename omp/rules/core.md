# Universal rules

Load for every stage. Then load only the stage and gate rules required by the assigned task.

## Context and effort policy

- Optimize for verified outcomes per token, not minimum tokens at any cost. Reuse authoritative files by path and digest; never paste the same full document into successive agent handoffs.
- Classify each change during interview as **focused** (localized, behavior-preserving, low-risk) or **full** (new behavior, cross-module change, migrations, security/privacy, external contracts, or uncertain impact). Record the classification, evidence, and escalation triggers in `interview.md`. If unsure, use full.
- **Focused** is a documentation and exploration budget, NOT a gate bypass: engineering work still needs its human Tech Doc/task breakdown, independent review, explicit approvals, OpenSpec preparation/validation, QA coverage, task planning, implementation, and independent verification. Keep artifacts concise and mark irrelevant sections N/A with reasons. Never invent a PRD for engineering-only work.
- **Full** uses comprehensive impact exploration and the complete applicable documentation. Escalate focused to full if scope expands, behavioral compatibility is uncertain, data/schema/auth changes emerge, or the reviewer finds material risk; invalidate and renew affected approvals.
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

