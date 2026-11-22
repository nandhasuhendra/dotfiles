---
name: review-docs
description: Read-only security and principal-engineering review of OpenSpec, ADRs, RFCs, runbooks, and design documents.
---

# /review-docs [scope] [output-dir]

Review docs only; no implementation. Resolve active/archive/specs/slug/path/glob. Inventory selected units and fingerprint each (proposal.md, design.md, tasks.md in fixed order or sorted selected files). For each unit, dispatch independent fresh `security-engineer` and `principal-engineer` agents if available; neither sees the other's output. Write reports only under output-dir (default `.agy/reviews/<timestamp>-docs/`). Security: named threats/controls, unsafe defaults, authz/validation boundaries, trust boundaries, secrets, SSRF, uploads, tool permissions. Engineering: requirement coverage, durability/reliability, data/query strategy, migrations/backfill/rollback, contracts/error matrix, idempotency/concurrency, observability, tests, task atomicity. Status PASS / CHANGES_REQUESTED / BLOCKED, IDs SEC-SPEC-nnn / ENG-SPEC-nnn, P0-P3, exact section, consequence, smallest design change, acceptance case and fingerprint. P0/P1 blocks Gate 2 / ship. If independent review is unavailable, disclose and BLOCK. Never edit reviewed docs.
