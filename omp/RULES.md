# OMP Workflow Governance Rules

## 1. Activation & Context Budget
- Load these rules only for an explicit `/work-*` command or an explicit custom-agent request. Ordinary prompts do not activate the workflow.
- Guard context: read only the active prompt, `rules/core.md` and the rules for the current stage. Avoid recursive scans or repository-tree dumps.
- Shared rules resolve under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/rules/`.

## 2. Three-Stage Pipeline & Rule Map

| Stage | Command | Load |
| --- | --- | --- |
| Spec | `/work-spec <feature>` | `core.md`, `planning.md`, `gates.md` |
| Build | `/work-build [slug]` | `core.md`, `execution.md`, `verification.md` |
| Ship | `/work-ship [slug]` | `core.md`, `execution.md`, `verification.md` |

1. `/work-spec` — Socratic interview, Devil's Advocate critique, Alignment Summary (Gate 1), `proposal.md`/`design.md`/`tasks.md`, final approval (Gate 2).
2. `/work-build` — atomic task execution with physical tests/LSP and the Circuit Breaker.
3. `/work-ship` — semantic commit and OpenSpec archive.

## 3. Standalone Utilities
- `/work-status` — read-only inspection of active changes under `openspec/changes/`.
- `/work-resume` — resume an interrupted change.

## 4. Two-Speed Execution Model
- **Fast-Track (default):** the three-stage pipeline for routine work.
- **Full-Spec Mode:** the same three commands with deeper exploration and an optional `security-engineer` review for large multi-system audits. It adds no extra gates or agent handoffs.
