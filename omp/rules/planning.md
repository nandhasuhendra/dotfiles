# Planning-stage rules

Load with `core.md` for interview, product planning, technical planning, document review, OpenSpec preparation, QA planning and task planning.

## Human-readable product and technical documents

- Treat `prd.md` and `design.md` as durable documentation for teammates, not merely handoff payloads for agents. A reader should understand the problem, proposed outcome and important decisions without reading the conversation transcript.
- Start each document with a 2–4 sentence executive summary in plain language. Explain the current situation, why it matters and what the change will accomplish before dense tables or IDs.
- Use narrative prose for problem framing, user experience, architecture and decision rationale; use compact tables for comparisons, contracts, requirement traceability and measurable acceptance. Add diagrams only when they improve understanding, and explain them in text.
- Define domain-specific terms, avoid unexplained acronyms, repeated paragraphs, generic filler and invented facts. Keep paragraphs short, remove unused template sections/placeholders, and state uncertainty explicitly.
- Keep stable REQ IDs and testable acceptance criteria so downstream agents can trace and verify the work. Human readability must not weaken requirement coverage, review independence, approval gates or evidence freshness.

## Human-first lifecycle

The workflow has two distinct documentation layers. Human planning documents are the source of truth for people; OpenSpec artifacts are derived for agent execution only after the human planning bundle has passed review and received explicit approval. Never start by drafting OpenSpec specs.

1. **Interview** — gather context, goals, users, constraints, current/desired behavior, facts, assumptions and stable REQ IDs. No OpenSpec specification artifacts.
2. **Product planning** — write `prd.md` for product/mixed routes. For engineering-only work, explain why a PRD is not applicable.
3. **Technical planning** — write `design.md` for engineering/mixed work and when product work needs technical decisions. Write `task-breakdown.md` as a readable implementation approach and milestone sequence.
4. **Human document review** — independently review the complete planning bundle for clarity, completeness, consistency, feasibility, risks, scope, traceability and unresolved questions.
5. **Human approval** — approve the exact PRD/Tech Doc/task-breakdown bundle and manifest. No OpenSpec proposal, delta specs, agent task files or implementation before this approval.
6. **Implementation preparation** — inspect the installed OpenSpec schema and translate approved documents into `proposal.md`, delta `specs/**/spec.md` and required design artifacts. Validate fidelity to approved intent.
7. **Specification review** — independent spec/security review and explicit human approval of generated artifacts. Any material discrepancy returns to human planning.
8. **QA planning** — derive test scenarios from approved requirements and threat analysis; review coverage and obtain approval.
9. **Agent task planning** — create schema-compatible `tasks.md` linked to REQ/TC IDs; review, validate and obtain approval.
10. **Implementation, verification, completion review and archive/release approval** — preserve all existing gates and require real evidence.

Do not conflate `task-breakdown.md` (human planning) with `tasks.md` (agent-ready execution checklist).

## Document templates

| Output | Template | Author |
| --- | --- | --- |
| `prd.md` | `PRD.md` | product-manager |
| `design.md` | `TECH-DOC.md` | tech-lead |
| `test-plan.md` | `QA-TEST-CASES.md` | qa-engineer |
| `task-breakdown.md` | `HUMAN-TASK-BREAKDOWN.md` | tech-lead |
| `tasks.md` | `TASK-BREAKDOWN.md` | tech-lead |

- Before authoring, read the matching project `.omp/templates/<file>` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/templates/<file>`. Stop if neither exists; pass the resolved path and template content to dispatched authors.
- Templates guide document content, not business policy. Fill them from confirmed inputs and source evidence; preserve IDs, explain applicable N/A cases and remove example rows/unresolved template tokens before review. Unknown material decisions stay explicit blockers, never invented defaults.
- For OpenSpec-owned design/tasks, installed schema instructions take precedence over template headings, metadata and checkbox syntax. Adapt the content checklist to that schema; do not introduce a second lifecycle or requirement set.
- Keep generated documents concise, link existing contracts rather than duplicating them, and add only known owners/dates and real references. Draft metadata or a filled checklist never counts as approval or execution.
- Template changes do not silently regenerate approved documents. Rewriting an existing artifact follows the normal digest/review/reapproval rules.

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

- Each stage command runs its required independent review, repairs findings within approved scope, then presents one checkpoint. The human does not need to run a separate review command.
- Stop at every human approval boundary. Do not chain past a pending decision, infer approval from silence, or treat a generic "continue" as approval of undisclosed content.
- Material scope changes return to interview/spec. Changed QA expectations return to QA approval. Repair code within approved scope, then repeat affected verification.
- Spec review requires a separate `security-engineer` red-team/blue-team assessment of the same input manifest before the reviewer can PASS. QA must cover its threat scenarios; subsequent gate reviews check that coverage and mitigation tasks remain intact.
- Final verification requires a fresh independent security-engineer PASS bound to the actual source and approved planning manifests, in addition to QA/reviewer PASS. Missing dispatch, stale security evidence or unresolved security findings blocks the gate. Record security results in `review.md` and reference them from `verification.md`; no extra human approval target.

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
