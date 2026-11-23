---
name: review-docs
description: Read-only security and principal-engineering review of OpenSpec, ADRs, RFCs, runbooks, and design documents.
---

# /review-docs [scope] [output-dir]

Review docs only; no implementation. Resolve active/archive/specs/slug/path/glob; if scope is omitted or ambiguous, or any question is needed, use the built-in `ask_question` tool to ask the user. Inventory selected units and fingerprint each (proposal.md, design.md, tasks.md in fixed order or sorted selected files). Do not dispatch subagents: review each unit sequentially in this session, covering the security and engineering checks per unit. Write reports only under output-dir (default `.reviews/<timestamp>-docs/`). Security: named threats/controls, unsafe defaults, authz/validation boundaries, trust boundaries, secrets, SSRF, uploads, tool permissions. Engineering: requirement coverage, durability/reliability, data/query strategy, migrations/backfill/rollback, contracts/error matrix, idempotency/concurrency, observability, tests, task atomicity. Status PASS / CHANGES_REQUESTED / BLOCKED, IDs SEC-SPEC-nnn / ENG-SPEC-nnn, P0-P3, exact section, consequence, smallest design change, acceptance case and fingerprint. P0/P1 findings are surfaced prominently as advisory input; Gate 2 and ship are decided by the user via `ask_question`, not by review status. If independent review is unavailable, disclose and BLOCK the report (never PASS). Never edit reviewed docs.
