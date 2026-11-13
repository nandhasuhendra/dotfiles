# OMP Workflow Governance Rules

## 1. Activation & Context Budget
- Load these rules only for an explicit `/work-*` command or an explicit custom-agent request.
- Guard context: read the active command, this file, `rules/core.md`, and only the stage rules it names. Do not scan unrelated agents, commands, templates or repository trees.
- Shared rules resolve under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/rules/`.

## 2. Pipeline & Rule Map

| Stage | Command | Load |
| --- | --- | --- |
| Spec | `/work-spec <feature>` | `core.md`, `planning.md`, `gates.md` |
| Human planning | `/work-human <slug>` | `core.md`, `planning.md`, `gates.md` |
| Build + quality | `/work-build <slug>` | `core.md`, `gates.md`, `execution.md`, `verification.md`, `review.md` |
| Ship | `/work-ship [slug] [mode]` | `core.md`, `gates.md`, `execution.md`, `verification.md` |

1. `/work-spec` — resolve ambiguity, present Alignment Summary (Gate 1), create `proposal.md`/`design.md`/`tasks.md`, and obtain Gate 2 approval.
2. `/work-human` — optional post-Gate-2 human planning bundle. Documentation only; adds no gate.
3. `/work-build` — implement atomic tasks with focused checks, then ask whether to run independent parallel code review + QA agents or use human review + QA.
4. Quality Gate — automated mode requires both independent reports to PASS; human mode requires explicit user confirmation at ship time. Both approvals are session-local.
5. `/work-ship` — final regression and selected commit/archive/push/PR workflow. Never bypass the quality gate.

## 3. Standalone Utilities
- `/work-status` — read-only inspection of active changes, task progress and quality evidence.
- `/work-resume` — resume at the earliest incomplete step without inferring approvals.

## 4. Two-Speed Execution Model
- **Fast-Track (default):** concise spec → build → optional automated quality → ship.
- **Full-Spec Mode:** deeper exploration and optional specialist review for large multi-system audits. The post-build quality choice remains explicit.
