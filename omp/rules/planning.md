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

