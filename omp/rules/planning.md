# Planning Stage Rules

## 1. Decoupled Functional Specifications
- `proposal.md` is functional: user problem and personas, journey-level requirements, success metrics and boundaries. It must never reference internal code paths, source file extensions or directory structures.
- `design.md` owns the technical contract: domain models, API payloads and status codes, error handling, dependencies and integration standards.

## 2. Socratic Interview & Gate 1
- Inspect the current system before asking. Surface ambiguities, architectural risks, new dependencies and failure modes.
- Route every clarifying question through OMP's built-in `ask` tool.
- Present the Alignment Summary and obtain Gate 1 confirmation via `ask` before writing any files.

## 3. Schema Compliance & Scope
- Follow the installed OpenSpec `spec-driven` headings shown in `/work-spec`; use `.openspec.yaml` to declare the schema and whether capability deltas are skipped.
- Define `Out of Scope` boundaries explicitly and add no speculative scope.
- For `/work-spec`, do not read `omp/templates/*`; the compact headings in the command are the source of truth.

## 4. Human Planning Bundle (`/work-human`)
- Run only after `/work-spec` has completed and its Gate 2 was explicitly `Approved`. The command re-confirms this through `ask` because gate state is session-local.
- Generate `PRD.md`, `TECH-DOC.md` and `HUMAN-TASK-BREAKDOWN.md` under `openspec/changes/<slug>/human/` from the installed templates in `templates/`.
- Preserve the approved change as the single source of truth. Human documents may clarify and trace but must not add scope, requirements, dependencies or decisions.
- The bundle is a human-review artifact. It adds no gate and does not replace `proposal.md`, `design.md`, `tasks.md`, Gate 2 or implementation evidence.
