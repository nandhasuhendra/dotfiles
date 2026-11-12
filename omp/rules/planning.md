# Planning Stage Rules

## 1. Decoupled Functional Specifications
- `proposal.md` is functional: user problem and personas, journey-level requirements, success metrics and boundaries. It must never reference internal code paths, source file extensions or directory structures.
- `design.md` owns the technical contract: domain models, API payloads and status codes, error handling, dependencies and integration standards.

## 2. Socratic Interview & Gate 1
- Inspect relevant existing code and conversation context before asking. Surface only ambiguities, architectural risks, dependencies and failure modes that can materially change scope or design.
- Ask only for material information not already available. Batch related questions; do not repeat answered questions. Route required clarifications through OMP's built-in `ask` tool.
- Present the Alignment Summary and obtain Gate 1 confirmation via `ask` before writing any files.

## 3. Schema Compliance & Scope
- Follow the installed OpenSpec `spec-driven` headings shown in `/work-spec`; use `.openspec.yaml` to declare the schema and whether capability deltas are skipped.
- Define `Out of Scope` boundaries explicitly and add no speculative scope.
- For `/work-spec`, do not read `omp/templates/*`; the compact headings in the command are the source of truth.

## 4. Human Planning Bundle (`/work-human`)
- Run only after `/work-spec` has completed and its Gate 2 was explicitly `Approved`. The command re-confirms this through `ask` because gate state is session-local.
- Generate `PRD.md`, `TECH-DOC.md` and `HUMAN-TASK-BREAKDOWN.md` under `openspec/changes/<slug>/human/` from the installed templates in `templates/`.
- Preserve the approved change as the single source of truth. Human documents may clarify and trace but must not add scope, requirements, dependencies or decisions. Do not re-interview; record non-blocking gaps as open decisions. If a missing fact would change approved scope or design, stop and return to `/work-spec`.
- The bundle is a human-review artifact. It adds no gate and does not replace `proposal.md`, `design.md`, `tasks.md`, Gate 2 or implementation evidence.
