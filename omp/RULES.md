# OMP Workflow Governance Rules

## 1. Activation & Context Budget
- OMP engineering workflow rules are loaded strictly on-demand via explicit slash commands (`/work-*`).
- Context budget is strictly guarded: avoid recursive directory scans or dumping repository trees unless explicitly requested.
- Common shared rule location resolves to: `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/rules/`.

## 2. Core Command Pipeline
The software engineering lifecycle in OMP is anchored by three primary commands:
1. `/work-spec <feature>` : Socratic interview, gap critique, requirement alignment via `ask`, and OpenSpec artifact synthesis (`proposal`, `design`, `tasks`).
2. `/work-build` : Atomic task execution based on `tasks.md` with physical test runner and LSP verification.
3. `/work-ship` : Semantic commit creation, PR summary generation, and OpenSpec archival.

## 3. Standalone Utilities
- `/work-status` : Read-only inspection of active changes under `openspec/changes/`.
- `/work-resume` : Resume an interrupted session on an in-progress change.

## 4. Two-Speed Execution Model
- **Fast-Track (Default):** The streamlined three-stage pipeline (`spec` -> `build` -> `ship`) for 80% of daily engineering tasks and tight deadlines.
- **Full-Spec Mode:** Deep exploratory multi-agent passes only when explicitly requested for massive multi-system architectural audits.
