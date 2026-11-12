# Planning Stage Rules

## 1. Decoupled Functional Specifications
- Functional PRD documents (`proposal.md`) must NEVER reference internal code paths, source file extensions, or directory structures. PRDs must focus exclusively on user journeys, business logic, and success metrics.
- Technical architecture documents (`design.md`) focus on interface contracts, entity schemas, API endpoints, and sequence diagrams.

## 2. Socratic Interview & Gap Analysis
- The planning agent must conduct gap analysis and challenge assumptions prior to writing physical files.
- All clarifying questions MUST be routed through OMP's built-in `ask` tool dialog.
- The planning agent must present an `Alignment Summary` and secure user confirmation via `ask` before moving to file synthesis.

## 3. Scope Boundaries
- Explicitly define `Out of Scope` boundaries to prevent scope creep during execution.
