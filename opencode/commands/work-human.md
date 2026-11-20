---
description: Generate the documentation-only human planning bundle (PRD, Tech Doc, Task Breakdown) from an approved OpenSpec change. No code, no gates.
---

# /work-human $ARGUMENTS

Documentation-only. Never edits application code, installs packages or rewrites OpenSpec artifacts. Dispatch synthesis to `tech-lead` via `task`; this session owns preconditions and verification.

The generated documents are standalone, human-oriented artifacts: they communicate the problem, goals and what needs to be delivered in plain language, and must be understandable and shareable with other humans and stakeholders who know nothing about this agentic workflow, the `/work-*` commands, gates or OpenSpec.

## Preconditions (fail closed)

1. Slug from `$ARGUMENTS`; if omitted and exactly one active change exists under `openspec/changes/`, use it — otherwise stop and ask.
2. Require `openspec/changes/<slug>/{.openspec.yaml,proposal.md,design.md,tasks.md}`; if missing, stop and point to `/work-spec <feature>` or `/work-resume <slug>`.
3. `openspec validate <slug>` (via `rtk openspec` when rtk exists) must pass.
4. Gate 2 re-confirmation via `question` (approval is session-local, never inferred from files): `Yes — Gate 2 was Approved` / `No — stop` / `Not sure — run /work-status`. Continue only on Yes.
5. Read only the OpenSpec artifacts plus `~/.config/opencode/templates/{PRD,TECH-DOC,HUMAN-TASK-BREAKDOWN}.md` (installed by the installer). Pass template paths to `tech-lead`; do not duplicate their bodies here.

## Synthesis

Dispatch `tech-lead` to write `openspec/changes/<slug>/human/{PRD.md,TECH-DOC.md,HUMAN-TASK-BREAKDOWN.md}`:

- `proposal.md`/`design.md`/`tasks.md` are the single source of truth; re-settled decisions only, no re-interview. Non-blocking gaps become "Open decisions". A missing fact that would change approved scope → stop, return to `/work-spec`.
- Template fidelity: preserve frontmatter and headings; fill `title/created/updated/status/tags`; replace every `{{...}}` and `<...>` placeholder; `TBD` only for genuinely unknown names/owners; inapplicable sections become `N/A — reason`; never invent people, metrics, incidents or verification results. Internal links: PRD ↔ TECH-DOC ↔ HUMAN-TASK-BREAKDOWN via relative paths.
- Stakeholder-facing rules (non-negotiable): the documents must not mention `/work-spec`, `/work-human`, `/work-build`, `/work-resume`, `/work-status`, `/work-ship`, Gate 1/Gate 2, approval gates, the tech-lead/software-engineer agents, `openspec/` paths, `.openspec.yaml`, or any other workflow-internal jargon. Rewrite references to retired bundles, `test-plan.md` or `verification.md` into plain forward-looking language (e.g. "verification evidence will be recorded separately once available"). The documents must read as if written directly for and by the team.
- Mapping — PRD: the problem to solve, goals/non-goals, personas, journeys, requirements, and a Data Flow Diagram (DFD), written for business and stakeholder readers; the DFD must show how data moves through the change (actors/external entities, processes, data stores, and key data flows/boundaries) and stay consistent with journeys and requirements. TECH-DOC: plain-language background, decisions and reasoning, contracts, error matrix, risks for human readers — no workflow or tooling jargon; BREAKDOWN: a human-oriented delivery plan with milestones, deliverables, owners and sequencing. Each task must state the clear expectation of the code changes it will produce: for backend tasks, the expected HTTP contracts (endpoints, methods, request/response shapes) and the data model changes (ERD — tables, relations, migrations); for frontend tasks, the expected UI/UX changes (screens, components, interactions, states) — concrete and verifiable, without workflow-internal file paths. One stable traceability set across all three (`REQ-*`/`FR-*`, `US-*`, `CT-*`/`Q-*`/`EV-*` plus internally derived task IDs); never name the internal source files by path or describe where the content came from.

## Verify

Re-run `openspec validate <slug>`; scan the three files for unresolved placeholders (`{{`, `Authoring guidance:`, `<...>`), fix residue; verify internal links resolve; confirm no workflow/OpenSpec jargon remains in the documents. Report paths, compact REQ→task coverage, open decisions, and state that these are human-review documents — Gate 2 remains the `/work-build` approval.
