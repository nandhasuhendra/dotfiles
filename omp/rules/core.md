# Universal rules

Load this file for every workflow stage. It contains the baseline safety, scope, ownership, freshness and approval requirements. Then load only the stage-specific rule file selected by `RULES.md`.

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

- Commands and agents must read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Project rules may strengthen, not silently bypass, these gates.
- Read repository `AGENTS.md`, relevant source and existing human documentation before proposing changes. Inspect OpenSpec config/schema during implementation preparation, after human planning approval.
- Keep one change in `openspec/changes/<slug>/`. Use a kebab-case slug; never overwrite an existing change to start another.
- Record route in `interview.md`: product (new/improved user-facing behavior), engineering (internal technical outcome), or mixed. Ask only when business intent cannot be established from the request.
- No application code, production configuration, migrations, or implementation tests before the implementation gate. Reading source and running existing checks are allowed.

## Artifacts and ownership

| Artifact | Owner | Minimum content |
| --- | --- | --- |
| `interview.md` | interviewer | Route, current/desired behavior, users, goals, constraints, non-goals, facts, assumptions, blocking questions, dependency readiness. |
| `prd.md` | product-manager | Human-readable product/mixed route: executive summary, user problem, desired experience, business rules, stable REQ IDs, measurable acceptance and success measures. |
| `design.md` | tech-lead | Human-readable technical design: current/proposed behavior, architecture rationale, alternatives, REQ IDs, impact, contracts, failure/security risks, rollout/rollback. |
| OpenSpec artifacts | product-manager + tech-lead | Installed schema's proposal and delta specs reflecting approved intent; design/tasks when required. Link REQ IDs; do not maintain competing requirements. |
| `test-plan.md` | qa-engineer | TC-to-REQ coverage, Given/When/Then, priority, layer, fixtures, expected results, affected existing-feature regression, manual gaps. |
| `task-breakdown.md` | tech-lead | Human-readable plan: milestones, approach, dependencies, risks and sequence of work. |
| `tasks.md` | tech-lead | Agent-ready OpenSpec implementation tasks linked to REQ/TC IDs, affected files, dependencies, rollout/rollback; created after QA planning. |
| `review.md` | reviewer + security-engineer | Append independent gate/security records: target, input path/digest manifest, PASS/CHANGES_REQUESTED/BLOCKED, file/line findings, risks, tool-use evidence or N/A reasons. Security records include red-team attack paths and blue-team mitigations. |
| `approvals.md` | orchestrator | Append-only human decisions binding exact artifact/input digests; never write approval on a human's behalf. |
| `verification.md` | qa-engineer + reviewer | Per TC/REQ result and real command/browser evidence, dependency invocations/results, implementation identity, regressions, review findings, remaining risks. |

- Product route requires PRD; engineering route requires design; mixed requires both. Schema-required design is still required on product work. Human approval covers the entire spec bundle, not just the PRD title.
- Questions affecting scope, expected behavior, compatibility, security or data integrity block approval. Explicitly accepted nonblocking assumptions remain visible.
- Authors may use their role instructions directly if dispatch is unavailable and disclose it. Gate review and final QA verification require independent agent runs with full context; no self-review fallback. If dispatch is unavailable, mark BLOCKED.

## Approval and freshness protocol

These are agent-enforced gates, not a runtime access-control mechanism. There is no `scripts/workflow_gate.py`; do not call it or claim automated enforcement.

1. Build a sorted manifest of relative artifact paths and SHA-256 file digests. Use real hashing tools, such as `sha256sum` on Linux or `shasum -a 256` on macOS. Never invent hashes.
2. Bind interview approval to `interview.md`; human planning approval to interview plus `prd.md`, `design.md` when applicable, and `task-breakdown.md`; spec approval to the human planning bundle plus all route/schema specification inputs (including proposal and every delta spec); test-plan approval to those inputs plus `test-plan.md`; tasks approval to all previous inputs plus `tasks.md`. Include OpenSpec config/schema inputs used by the change. Exclude the mutable approval/review/evidence ledgers themselves.
3. Reviewer records PASS against the same input manifest for that gate. Show the human artifact paths, review findings, short scope/risk summary and manifest before asking approval.
4. After an explicit human decision, recompute the manifest. If unchanged, append target, UTC timestamp, human decision reference/quote, manifest and matching review record to `approvals.md`. If changed during the decision, ask again. Never modify historical decisions.
5. Before proceeding or resuming, re-enumerate files and recompute every upstream manifest. Changed bytes, missing files or new specification inputs invalidate that gate and all dependent approvals/reviews/tasks/verification. Treat prior records as historical, not current authority.
6. Freeze approved `tasks.md` content. Track execution completion and evidence separately in `verification.md` so checkbox edits do not silently invalidate task approval. Reconcile OpenSpec task checkboxes only after verification and human archive authorization; record that completion-only reconciliation and rerun validation. Any task wording/scope change requires renewed task review/approval.
7. Bind final verification to current source: record HEAD plus a digest manifest of changed tracked and relevant untracked files (including deletions), or a full relevant-source manifest outside Git. HEAD alone does not identify a dirty worktree. Source/test/config changes invalidate verification; rerun affected checks and independent review.

## Readability and evidence

- Prefer short headings, bullets and compact tables; paragraphs at most three sentences. No boilerplate sections with invented content.
- Keep stable `REQ-001` and `TC-001` IDs across artifacts. Each scenario states preconditions, action and observable expected outcome; link tasks and evidence rather than copying paragraphs.
- QA covers positive, negative, boundary, permissions/security, compatibility and affected-feature regressions; add concurrency, performance or migration cases when applicable. Mark N/A with a reason, not silent omissions.
- Report scenario outcomes as PASS, FAIL, BLOCKED or NOT_RUN. Record actual command, exit code and result; browser checks include steps and observed state. Tests alone do not replace a smoke run of the changed path.
- Distinguish observed facts, assumptions and risks. Never weaken tests to match a defect, fabricate delegation/results, or claim existing features cannot regress.
- Status output: `Gate | Evidence/freshness | Blocker | Next command`. Report unavailable dependencies and unrun scenarios honestly.
- Never delete unrelated work, run destructive commands, merge, release, deploy or archive without explicit human authorization.
