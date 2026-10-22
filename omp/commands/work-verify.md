---
description: Verify implementation independently.
---
## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md`, `rules/execution.md`, `rules/verification.md` and `rules/gates.md`. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Recompute every upstream manifest and the current implementation identity, including dirty tracked, relevant untracked and deleted files; HEAD alone is insufficient.
- Require fresh `human-planning` and `execution` approvals, approved scope preserved, all tasks complete in `verification.md` and runnable checks available. Missing or stale evidence blocks verification.
- Keep `tasks.md` frozen; read execution completion from `verification.md`.

## Independent verification

- Dispatch `qa-engineer` as a separate run with the acceptance criteria and TC IDs, implementation identity, relevant diff/source context, regression surface and known risks. Give paths and manifest identities instead of duplicating documents. If dispatch is unavailable, record BLOCKED; never adopt the QA or reviewer role as a fallback.
- QA runs the real repository-supported tests/checks and a smoke run of the changed path. Record raw commands, exit codes, observed results and rerunnable logs; RTK compression is not proof.
- Browser changes require real Playwright execution of changed flows, error states, keyboard access and relevant viewports in an authorized environment; unavailable required browser evidence is BLOCKED, never simulated PASS.
- Cover every approved TC/REQ plus affected existing-feature regressions, recording PASS/FAIL/BLOCKED/NOT_RUN per scenario. Manual gaps and unavailable dependencies never become PASS.
- Decide from the recorded risk classification and findings whether a separate security-engineer run is required; require it for security-sensitive scope or a credible finding, otherwise have the reviewer record a specific N/A rationale.
- After QA evidence exists, dispatch one independent reviewer with the authoritative bundle paths, implementation identity, QA evidence, applicable security verdict and validation evidence. Do not run duplicate reviewers against an unchanged manifest.
- Run installed OpenSpec validation and record the actual result. Recompute manifests after the runs; changed source/test/config invalidates affected evidence and requires affected checks plus independent delta review, reusing unchanged recorded evidence.

## Handoff

- Write `verification.md` with QA and reviewer run identities, planning/source manifests, task completion evidence, scenario results, actual commands/exits, validation results, security reference or N/A rationale, findings and remaining risks.
- On PASS, deliver the review-ready handoff: documents, changes, tasks, evidence, identities, remaining risks and the concrete review path. Review-ready is terminal here; do not infer human acceptance.
- On FAIL/BLOCKED/NOT_RUN, state the exact missing or failing evidence and the smallest permitted next action within approved scope.
- Archive, PR, deployment, merge and release require separate explicit requests; this command never performs or implies them.
