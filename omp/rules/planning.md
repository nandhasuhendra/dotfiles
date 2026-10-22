# Planning-stage rules

Load with `core.md` for interview, product planning, technical planning, human document review, OpenSpec preparation, QA planning and task planning. Load `gates.md` when checking approvals or transitioning between stages.

## Human-readable product and technical documents

- Treat `prd.md` and `design.md` as durable documentation for teammates, not merely handoff payloads for agents. A reader should understand the problem, proposed outcome and important decisions without reading the conversation transcript.
- Start each document with a 2–4 sentence executive summary in plain language. Explain the current situation, why it matters and what the change will accomplish before dense tables or IDs.
- Use narrative prose for problem framing, user experience, architecture and decision rationale; use compact tables for comparisons, contracts, requirement traceability and measurable acceptance. Add diagrams only when they improve understanding, and explain them in text.
- Define domain-specific terms, avoid unexplained acronyms, repeated paragraphs, generic filler and invented facts. Keep paragraphs short, remove unused template sections/placeholders, and state uncertainty explicitly.
- Keep stable REQ IDs and testable acceptance criteria so downstream agents can trace and verify the work. Human readability must not weaken requirement coverage, review independence, approval gates or evidence freshness.


- Caveman applies to agent communication only, not to the documents being authored. Write `prd.md`, `design.md`, `test-plan.md` and `task-breakdown.md` in clear professional prose for a teammate who never saw the chat; retain the 2–4 sentence executive summary, rationale, definitions, trade-offs, risks and readable examples. Concise does not mean cryptic.
- Use the same human-first standard for OpenSpec descriptions and handoff artifacts likely to be read by maintainers. Agent-only status/handoff messages may be terse if all decisions, blockers, IDs and evidence remain explicit.

## Human-first lifecycle

Human planning is the source of truth. There are two pre-build approval bundles, defined in `gates.md`, not an approval at every authoring step.

1. **Interview and human planning** — inspect current behavior/callers/tests, actively resolve material decisions, and capture stable REQ IDs in `interview.md`. Write the applicable PRD/Tech Doc and readable `task-breakdown.md` using one informed primary author where practical. Independently review the complete bundle, repair findings, and request `human-planning` approval once.
2. **Execution preparation** — only after fresh human-planning approval, inspect installed OpenSpec schema/config and derive proposal/delta specs, `test-plan.md`, and schema-compatible `tasks.md`. Prepare these together in dependency order; QA case design can inform task refinement without separate human checkpoints. Independently review the entire execution bundle for fidelity, coverage and feasibility, obtain risk-required security review, validate OpenSpec, then request `execution` approval once.
3. **Implementation and verification** — after execution approval, implement with stable-checkpoint targeted feedback, then obtain separate final QA and reviewer verdicts with current evidence. Finish review-ready; archive, PR and deployment are separate requests.

For engineering-only work, record PRD N/A before human-planning review. Product work still needs design where technical decisions or the installed schema require it. Preserve human-readable documents; proportionality removes irrelevant sections and duplicate authoring, not acceptance criteria or required evidence. Do not conflate `task-breakdown.md` with schema execution `tasks.md`.

## Source-backed interview

- Read the relevant current system, consumers, tests and constraints before asking what tools or source can answer. Distinguish facts, hypotheses, confirmed choices and explicitly accepted assumptions.
- Use built-in `ask` for unresolved material choices: batch related questions with two to five concrete options, trade-offs and a recommendation. Challenge an unsafe or inconsistent preference with current-state evidence and a safer option; honor an informed explicit decision unless it violates a mandatory boundary.
- Cover affected users/roles, happy/error/permission journeys, compatibility, dependencies, data/security, non-goals and observable acceptance, with applicable N/A reasons. Follow answers to newly exposed impacts rather than a fixed interview round count.
- Record the actual selected option, rationale and resulting REQ/journey/acceptance links automatically. Do not invent an answer from silence or make the human copy questions and answers into a document. If `ask` is unavailable, disclose that and use numbered options awaiting an explicit response.
- Reuse settled choices. Reopen only for new material evidence or changed intent, naming the decision and affected downstream inputs. Do not promise that future information can never require a revisit; classify avoidable planning misses separately from new scope.
- Stop interviewing when material decisions align and no blocking unknown remains. The interview joins human-planning review/approval; do not create a separate interview approval.

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

