# Gate, ownership and approval rules

Load when creating, reviewing, approving, transitioning, verifying, or archiving a workflow stage.

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
- Authors may use their role instructions directly if dispatch is unavailable and disclose it. Required independent gate review and final QA verification must be separate from the author/implementer; no self-review fallback. Use a separate security-engineer run only for security-sensitive changes or when a reviewer identifies a credible security risk. For routine low-risk changes, the independent reviewer checks security relevance and records why specialist review is N/A. If a required independent reviewer or QA run is unavailable, mark BLOCKED.

## Approval and freshness protocol

These are agent-enforced gates, not a runtime access-control mechanism. There is no `scripts/workflow_gate.py`; do not call it or claim automated enforcement.

1. Build a sorted manifest of relative artifact paths and SHA-256 file digests. Use real hashing tools, such as `sha256sum` on Linux or `shasum -a 256` on macOS. Never invent hashes.
2. Bind interview approval to `interview.md`; human planning approval to interview plus `prd.md`, `design.md` when applicable, and `task-breakdown.md`; spec approval to the human planning bundle plus all route/schema specification inputs (including proposal and every delta spec); test-plan approval to those inputs plus `test-plan.md`; tasks approval to all previous inputs plus `tasks.md`. Include OpenSpec config/schema inputs used by the change. Exclude the mutable approval/review/evidence ledgers themselves.
3. Reviewer records PASS against the same input manifest for that gate. Show the human artifact paths, review findings, short scope/risk summary and manifest before asking approval.
4. After an explicit human decision, recompute the manifest. If unchanged, append target, UTC timestamp, human decision reference/quote, manifest and matching review record to `approvals.md`. If changed during the decision, ask again. Never modify historical decisions.
5. Before proceeding or resuming, re-enumerate files and recompute every upstream manifest. Changed bytes, missing files or new specification inputs invalidate that gate and all dependent approvals/reviews/tasks/verification. Treat prior records as historical, not current authority.
6. Freeze approved `tasks.md` content. Track execution completion and evidence separately in `verification.md` so checkbox edits do not silently invalidate task approval. Reconcile OpenSpec task checkboxes only after verification and human archive authorization; record that completion-only reconciliation and rerun validation. Any task wording/scope change requires renewed task review/approval.
7. Bind final verification to current source: record HEAD plus a digest manifest of changed tracked and relevant untracked files (including deletions), or a full relevant-source manifest outside Git. HEAD alone does not identify a dirty worktree. Source/test/config changes invalidate verification; rerun affected checks and independent review.

## Gates

Every transition rechecks all upstream evidence. Missing, stale, FAIL, BLOCKED or NOT_RUN evidence never means PASS. Review PASS is not human approval. OpenSpec readiness is not human approval either.

| Next action | Required evidence |
| --- | --- |
| Product planning (`work-product-plan`) | Interview complete, independent interview review PASS and human interview approval. |
| Technical planning (`work-tech-plan`) | Interview approved; PRD draft/product context available; technical questions resolved; design and human task breakdown complete. |
| Human document review (`work-doc-review`) | Independent review of the complete human planning bundle PASS and explicit human approval of its manifest. |
| Implementation preparation (`work-prepare`) | Human planning bundle approved and fresh; generate OpenSpec artifacts and validate fidelity before spec review. |
| Write QA scenarios (`work-qa`) | Human planning bundle approved; OpenSpec preparation complete, independent spec/security review PASS and explicit human approval of generated specs. |
| Plan tasks (`work-plan`) | Every REQ covered by QA scenarios, independent test-plan review PASS, explicit human test-plan approval. |
| Implement (`work-implement`) | Fresh interview/spec/test-plan approvals, complete tasks, independent tasks review PASS, human tasks approval binding the full planning bundle, successful OpenSpec validation. |
| Verify (`work-verify`) | Implementation tasks complete; approved scope preserved; current source identity, test changes and runnable checks available. |
| Archive (`work-archive`) | All required scenarios PASS, no unresolved review defects, OpenSpec validation PASS, independent QA and reviewer PASS for current source, explicit human archive authorization. Merge/release requires its own authorization. |

- Each stage command runs its required independent review, repairs findings within approved scope, then presents one checkpoint. Avoid duplicate review runs: reuse a PASS only when the exact input manifest is unchanged; the human does not need to run a separate review command.
- Stop at every human approval boundary. Do not chain past a pending decision, infer approval from silence, or treat a generic "continue" as approval of undisclosed content.
- Material scope changes return to interview/spec. Changed QA expectations return to QA approval. Repair code within approved scope, then repeat affected verification.
- For security-sensitive specs, require a separate `security-engineer` red-team/blue-team assessment of the same input manifest before the reviewer can PASS; QA must cover its threat scenarios. For routine low-risk specs, the independent reviewer checks the change classification and records a concise security-N/A rationale.
- Final verification always requires independent QA and reviewer PASS. Add a fresh security-engineer PASS bound to the current source/planning manifests only for security-sensitive changes or when a credible security issue is found. Missing required specialist evidence or unresolved findings blocks the gate. Record applicable security results in `review.md` and reference them from `verification.md`; no extra human approval target.

## Human checkpoints

Every stage ends with exactly one checkpoint, not a chain of questions. Keep it scannable:

```text
Stage: <stage> | review: <PASS/CHANGES_REQUESTED/BLOCKED>
Artifacts: <paths or "none">
Reviewed: <what changed since the last decision>
Open questions: <none or blocking list>
Decision: approve | approve stop | reject: <reason> | revisit: <question/stage> | pause
```

- `approve`: record the decision with the approval protocol, then continue to the next stage in the same turn.
- `approve stop`: record the decision and stop. The next stage remains available.
- `reject: <reason>`: record the rejection without approval, route to the responsible author and stop.
- `revisit: <question/stage>`: reopen that stage; changed inputs invalidate dependent approvals/reviews/tasks/verification.
- `pause`: record nothing and point to `/work-resume <slug>`.
- One explicit reply is enough. Do not ask for the same decision twice; do not make the human re-run review after a PASS unless inputs changed.
- Show artifact paths, a one-line scope/risk summary, review findings and the manifest identity before asking. Invocation, silence, "continue" or an earlier approval is not a decision.
- `work-doc-review` reviews the human planning bundle before OpenSpec; `work-review` performs later independent gate reviews and presents this checkpoint. `work-approve` resumes a pending decision or records one supplied after a review.

## Agent handoffs

- Each author reads its gate inputs, writes only its owned artifacts and returns a handoff block to the orchestrator. The orchestrator, not a subagent, presents the human checkpoint and records decisions.
- Required handoff block:

```text
Gate: <stage> | <PASS/CHANGES_REQUESTED/BLOCKED>
Artifacts: <paths>
Evidence: <actual commands/tools/results, or N/A reason for each required dependency>
Open questions: <none or blocking list>
Next: <one command or action>
```

- Keep handoffs factual: actual commands, observed results, limitations and unresolved blockers. Never claim approval, verification or delegation that did not happen.
- Do not repeat information already in an approved artifact; link it. If an upstream contract changes, state which downstream records are invalidated.

