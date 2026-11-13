# Independent Code Review Rules

## Scope
- Review the exact target diff supplied by the orchestrator against approved `proposal.md`, `design.md`, `tasks.md` when available; otherwise use supplied PR/commit context, repository documentation and conventions.
- For branch-based quality runs, include committed branch changes from the merge base to HEAD and current working-tree changes. Do not limit review to `git diff HEAD`.
- Focus on correctness, data integrity, concurrency/race conditions, security, error handling, performance risks, maintainability and regression.
- Review changed code plus the minimum surrounding context needed. Avoid broad repository audits and style-only nitpicks.

## Independence
- The reviewer is read-only. Do not edit application files, tests, OpenSpec tasks or QA reports.
- Do not assume QA passed or duplicate QA's execution of acceptance scenarios.
- Do not fix findings. Report exact file/line references, impact, reproduction or reasoning, and a concrete recommendation.

## Findings
- `P0` Critical: exploitable security issue, data loss/corruption or release-blocking outage.
- `P1` High: correctness/reliability defect or major violation of an approved contract. P0/P1 block the quality gate.
- `P2` Medium: meaningful maintainability, performance or resilience concern. Explain whether it should block this change.
- `P3` Low: optional cleanup or minor improvement; non-blocking.

## Report
Write a concise report to the exact path supplied by the orchestrator (slug-scoped under `openspec/changes/<slug>/quality/`, or branch-scoped under `.omp/quality/<branch-slug>/`) with:
- Status: `PASS`, `FAIL` or `BLOCKED`.
- Full target fingerprint: base ref and merge-base SHA where applicable, HEAD SHA, branch diff hash, working-tree diff hash, untracked-file hashes excluding the report directory, filtered status and diff stat.
- Diff/base reviewed and review scope.
- Findings with severity, file/line, impact and recommendation.
- Explicit statement when no blocking findings were found.

Do not declare PASS if the diff changed after review or required context was unavailable.
