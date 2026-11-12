# OMP Workflow Governance Rules

## 1. Activation & Context Budget
- Load these rules only for an explicit `/work-*` command or an explicit custom-agent request. Ordinary prompts do not activate the workflow.
- Guard context: read the active command, this file, `rules/core.md`, and only the stage rules it names. Do not scan unrelated agents, commands, templates, or repository trees.
- Shared rules resolve under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/rules/`.

## 2. Pipeline & Rule Map

| Stage | Command | Load |
| --- | --- | --- |
| Spec | `/work-spec <feature>` | `core.md`, `planning.md`, `gates.md` |
| Human planning | `/work-human <slug>` | `core.md`, `planning.md`, `gates.md` |
| Build | `/work-build [slug]` | `core.md`, `gates.md`, `execution.md`, `verification.md` |
| Ship | `/work-ship [slug]` | `core.md`, `execution.md`, `verification.md` |

1. `/work-spec` — Socratic interview, Devil's Advocate critique, Alignment Summary (Gate 1), `proposal.md`/`design.md`/`tasks.md`, final approval (Gate 2).
2. `/work-human` — optional post-Gate-2 human planning bundle derived from the approved change and installed templates. Documentation only; it adds no gate.
3. `/work-build` — atomic task execution with focused tests/LSP and the Circuit Breaker.
4. `/work-ship` — semantic commit and OpenSpec archive.

## 3. Standalone Utilities
- `/work-status` — read-only inspection of active changes under `openspec/changes/`.
- `/work-resume` — resume an interrupted change.

## 4. Two-Speed Execution Model
- **Fast-Track (default):** the three-stage pipeline for routine work.
- **Full-Spec Mode:** the same three commands with deeper exploration and an optional `security-engineer` review for large multi-system audits. It adds no extra gates or agent handoffs.
